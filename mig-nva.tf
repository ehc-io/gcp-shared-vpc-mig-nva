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

resource "google_compute_instance_template" "default" {
    project      = module.host_project.name
    name        = "nva-template"
    description = "This template is used to create nginx server instances."
    instance_description = "Network Virtual Appliance instance"
    machine_type         = "e2-standard-4"
    can_ip_forward       = true
    tags = [ "fw", "ssh-mgmt" , "east-west", "north-south" ]

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
        # iptables
        echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
        echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
        apt install -y iptables-persistent
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
        sysctl -p
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
        network_ip = "192.168.10.10"
        # alias_ip_range {
        #     ip_cidr_range = "192.168.10.96/28"
        # }
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-b.self_link
        # network_ip = "192.168.20.10"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-e.self_link
        # network_ip = "192.168.50.10"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-h.self_link
        # network_ip = "192.168.80.10"
    } 

  service_account {
    email  =  module.host_project.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }

    depends_on = [ google_project_organization_policy.ip_forward_policy ]

}

resource "google_compute_instance_group_manager" "default" {
    project            = module.host_project.name
    name               = "mig-nva"
    zone               =  var.zone_1
    target_size        = 2
    base_instance_name = "nva-id"
    version {
        instance_template = google_compute_instance_template.default.id
        name = "primary"
    }
}
