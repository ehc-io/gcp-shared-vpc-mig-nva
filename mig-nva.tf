data "google_compute_image" "default" {
  family  = "ubuntu-2004-lts"
  project = "ubuntu-os-cloud"
}
resource "google_compute_disk" "default" {
    project      = module.host_project.name
    name  = "ubuntu-image-disk"
    image = data.google_compute_image.default.self_link
    size  = 10
    type  = "pd-balanced"
    zone         = var.zone_1
        depends_on = [
        module.host_project.name
        ]
    }

resource "google_compute_instance_template" "nva-template" {
    project      = module.host_project.name
    name        = "nva-template"
    description = "This template is used to create nginx server instances."
    instance_description = "Network Virtual Appliance instance"
    machine_type         = "e2-standard-4"
    can_ip_forward       = true
    tags = [ "nva-health-check", "ssh-mgmt" , "east-west", "north-south" ]

    metadata = {
        startup-script = <<EOT
        #!/bin/bash
        apt update -y
        apt install -y net-tools traceroute
        # static routes
        route add -net 192.168.30.0 netmask 255.255.255.0 gw 192.168.20.1
        route add -net 192.168.40.0 netmask 255.255.255.0 gw 192.168.20.1
        route add -net 192.168.60.0 netmask 255.255.255.0 gw 192.168.50.1
        route add -net 192.168.70.0 netmask 255.255.255.0 gw 192.168.50.1
        route add -net 192.168.90.0 netmask 255.255.255.0 gw 192.168.80.1
        route add -net 192.168.100.0 netmask 255.255.255.0 gw 192.168.80.1
        # iptables install
        echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
        echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
        apt install -y iptables-persistent
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
        sysctl -p
        # SNAT ens4 config
        iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
        # DNAT config
        # md_vm="http://metadata.google.internal/computeMetadata/v1/instance/"
        # md_net="$md_vm/network-interfaces"
        # dnat_ip=$(curl -s $md_net/0/ip -H "Metadata-Flavor:Google")
        # iptables -t nat -A PREROUTING -d $dnat_ip -p tcp --dport 80 -j DNAT --to 192.168.30.5
        # iptables -t nat -A PREROUTING -d $dnat_ip -p tcp --dport 8081 -j DNAT --to 192.168.30.5
        # iptables -t nat -A PREROUTING -d $dnat_ip -p tcp --dport 8082 -j DNAT --to 192.168.60.5
        EOT
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

  // Create a new boot disk from an image
    disk {
        source_image      = "ubuntu-os-cloud/ubuntu-2004-lts"
        auto_delete       = true
        boot              = true
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-a.self_link
        # alias_ip_range {
        #     ip_cidr_range = "/28"
        # }
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-b.self_link
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-e.self_link
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-h.self_link
    } 

  service_account {
    email  =  module.host_project.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }

    depends_on = [ google_project_organization_policy.ip_forward_policy ]

}
resource "google_compute_instance_group_manager" "mig-nva" {
    project            = module.host_project.name
    name               = "mig-nva"
    zone               =  var.zone_1
    target_size        = 1
    base_instance_name = "nva"
    named_port {
        name = "http"
        port = "80"
    }
    # named_port {
    #   name = "web1"
    #   port = "8081" 
    # }
    # named_port {
    #   name = "web2"
    #   port = "8082"

    # }
    version {
        instance_template = google_compute_instance_template.nva-template.id
        name = "primary"
    }
}
#########################################################################
# External LB - subnet-a
#########################################################################
# external ip
resource "google_compute_global_address" "external-ip-1" {
    name            = "external-ip-1"
    project         = module.host_project.name
    address_type    = "EXTERNAL"
    ip_version      = "IPV4"
}
# health check elb ingress-1
resource "google_compute_health_check" "nva-mig-hc-ingress-1" {
    project             = module.host_project.name
    name                = "nva-mig-hc-ingress-1"
    http_health_check {
        port = 80
        port_specification = "USE_FIXED_PORT"
    }
    check_interval_sec  = 3
    healthy_threshold   = 2
    timeout_sec         = 1
}
# external backend service-1
resource "google_compute_backend_service" "bs-vpc-externo-ingress-1" {
    project               = module.host_project.name
    name                  = "bs-vpc-externo-ingress-1"
    provider              = google-beta
    load_balancing_scheme = "EXTERNAL_MANAGED"
    protocol              = "HTTP"
    port_name             = "http"
    health_checks         = [ google_compute_health_check.nva-mig-hc-ingress-1.id ]
    backend {
        max_rate = 100
        balancing_mode = "RATE"
        group           = google_compute_instance_group_manager.mig-nva.instance_group
    }
}
# url map elb-1
resource "google_compute_url_map" "default-1" {
    project         = module.host_project.name
    name            = "url-map-default-1"
    default_service = google_compute_backend_service.bs-vpc-externo-ingress-1.id
}
# http proxy elb-1
resource "google_compute_target_http_proxy" "default-1" {
    project         = module.host_project.name
    name    = "http-proxy-default-1"
    url_map = google_compute_url_map.default-1.id
}
# forwarding rule elb-1
resource "google_compute_global_forwarding_rule" "fr-vpc-externo-ingress-1" {
    project         = module.host_project.name
    name                  = "fr-vpc-externo-ingress-1"
    ip_protocol           = "TCP"
    load_balancing_scheme = "EXTERNAL_MANAGED"
    port_range            = "80-80"
    target                = google_compute_target_http_proxy.default-1.id
    ip_address            = google_compute_global_address.external-ip-1.id
}
#
########################################################################
# health check ilb egress
resource "google_compute_region_health_check" "nva-mig-hc-egress" {
    project         = module.host_project.name
    name            = "nva-mig-hc-egress"
    region          = var.region_1
    tcp_health_check {
        port = "22"
    }
}
# ILBaNH subnet-B
resource "google_compute_region_backend_service" "bs-egress-shared-vpc" {
    project               = module.host_project.name
    name                  = "bs-egress-shared-vpc"
    region                = var.region_1
    protocol              = "TCP"
    load_balancing_scheme = "INTERNAL"
    network               = google_compute_network.vpc_shared.id
    health_checks         = [ google_compute_region_health_check.nva-mig-hc-egress.id ]
    backend {
        balancing_mode = "CONNECTION"
        group           = google_compute_instance_group_manager.mig-nva.instance_group
    }
}
# ILBaNH subnet-B forwarding rule
resource "google_compute_forwarding_rule" "fr-egress-shared-vpc" {
    project               = module.host_project.name
    name                  = "fr-egress-shared-vpc"
    backend_service       = google_compute_region_backend_service.bs-egress-shared-vpc.id
    region                = var.region_1
    ip_protocol           = "TCP"
    load_balancing_scheme = "INTERNAL"
    all_ports             = true
    network               = google_compute_network.vpc_shared.id
    subnetwork            = google_compute_subnetwork.subnet-b.id
}
# # #########################################################################
# # ILBaNH subnet-E
# resource "google_compute_region_backend_service" "bs-egress-multi-tenant-vpc" {
#     project               = module.host_project.name
#     name                  = "bs-egress-multi-tenant-vpc"
#     provider              = google-beta
#     region                = var.region_1
#     protocol              = "TCP"
#     load_balancing_scheme = "INTERNAL"
#     network               = google_compute_network.vpc_multi_tenant.id
#     health_checks         = [ google_compute_region_health_check.nva-mig-hc-egress.id ]
#     backend {
#         balancing_mode = "CONNECTION"
#         group           = google_compute_instance_group_manager.mig-nva.instance_group
#     }
# }
# # ILBaNH subnet-E forwarding rule
# resource "google_compute_forwarding_rule" "fr-egress-multi-tenant-vpc" {
#     project         = module.host_project.name
#     name                  = "fr-egress-multi-tenant-vpc"
#     backend_service       = google_compute_region_backend_service.bs-egress-multi-tenant-vpc.id
#     provider              = google-beta
#     region                = var.region_1
#     ip_protocol           = "TCP"
#     load_balancing_scheme = "INTERNAL"
#     all_ports             = true
#     network               = google_compute_network.vpc_multi_tenant.id
#     subnetwork            = google_compute_subnetwork.subnet-f.id
# }
# # #########################################################################
# # ILBaNH subnet-H
# resource "google_compute_region_backend_service" "bs-egress-single-tenant-vpc" {
#     project               = module.host_project.name
#     name                  = "bs-egress-single-tenant-vpc"
#     provider              = google-beta
#     region                = var.region_1
#     protocol              = "TCP"
#     load_balancing_scheme = "INTERNAL"
#     network               = google_compute_network.vpc_single_tenant.id
#     health_checks         = [ google_compute_region_health_check.nva-mig-hc-egress.id ]
#     backend {
#         balancing_mode = "CONNECTION"
#         group           = google_compute_instance_group_manager.mig-nva.instance_group
#     }
# }
# # ILBaNH subnet-H forwarding rule
# resource "google_compute_forwarding_rule" "fr-egress-single-tenant-vpc" {
#     project         = module.host_project.name
#     name                  = "fr-egress-single-tenant-vpc"
#     backend_service       = google_compute_region_backend_service.bs-egress-single-tenant-vpc.id
#     provider              = google-beta
#     region                = var.region_1
#     ip_protocol           = "TCP"
#     load_balancing_scheme = "INTERNAL"
#     all_ports             = true
#     network               = google_compute_network.vpc_single_tenant.id
#     subnetwork            = google_compute_subnetwork.subnet-i.id
# }
