# virtual appliance instance
# 
# Firewall instance
resource "google_compute_instance" "vm-firewall" {
    project      = module.host_project.name
    name         = "vm-firewall"
    machine_type = "e2-standard-4"
    zone         = var.zone_1
    can_ip_forward = true
    tags = [ "fw", "ssh-mgmt" , "east-west", "north-south" ]

    boot_disk {
        initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

    metadata = {
        startup-script = <<EOT
        #!/bin/bash
        # networking tools
        apt -y update
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
        # Source NAT - Egress
        iptables -t nat -A POSTROUTING -o ens4 -j MASQUERADE
        # Destination NAT - Ingress
        iptables -t nat -A PREROUTING -d 192.168.10.103 -p tcp --dport 80 -j DNAT --to 192.168.30.5
        iptables -t nat -A PREROUTING -d 192.168.10.104 -p tcp --dport 80 -j DNAT --to 192.168.40.5
        EOT
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-a.self_link
        network_ip = "192.168.10.10"
        alias_ip_range {
            ip_cidr_range = "192.168.10.96/28"
        }
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-b.self_link
        network_ip = "192.168.20.10"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-e.self_link
        network_ip = "192.168.50.10"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-h.self_link
        network_ip = "192.168.80.10"
    }

  service_account {
    email  =  module.host_project.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
    depends_on = [ google_project_organization_policy.ip_forward_policy ]

}
# instance jumphost
# 
resource "google_compute_instance" "jumphost" {
    project      = module.host_project.name
    name         = "jumphost"
    machine_type = "e2-micro"
    zone         = var.zone_1
    tags = [ "ssh-mgmt" ]

    boot_disk {
        initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

    metadata = {
        startup-script = <<EOT
        #!/bin/bash
        apt update -y
        apt install -y net-tools traceroute
        EOT
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-a.self_link
        network_ip = "192.168.10.15"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-mgmt.self_link
        network_ip = "172.16.10.15"
    }

  service_account {
    email  =  module.host_project.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
}
# instance client-a
resource "google_compute_instance" "client-a" {
    project      = module.host_project.name
    name         = "client-a"
    machine_type = "e2-micro"
    zone         = var.zone_1
    tags = [ "ssh-mgmt" , "north-south"]

    boot_disk {
        initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

    metadata = {
        startup-script = <<EOT
        #!/bin/bash
        apt update -y
        apt install -y net-tools traceroute
        EOT
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-a.self_link
        network_ip = "192.168.10.20"
    }

  service_account {
    email  =  module.host_project.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
}
#
# instance svc-c
resource "google_compute_instance" "nginx-c" {
    project      = module.service_project_c.name
    name         = "nginx-c"
    machine_type = "e2-micro"
    zone         = var.zone_1
    tags = [ "nginx", "ssh-mgmt", "east-west", "north-south" ]
    allow_stopping_for_update = true

    boot_disk {
        initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

    metadata = {
        enable-oslogin: "TRUE"
        startup-script = <<EOT
        #!/bin/bash
        apt update -y
        apt install -y nginx net-tools traceroute
        EOT
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-c.self_link
        network_ip = "192.168.30.5"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-mgmt.self_link
        network_ip = "172.16.30.5"
    }

  service_account {
    email  =  module.service_project_c.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
    depends_on = [
    google_compute_instance.vm-firewall
  ]
}
# instance svc-d
resource "google_compute_instance" "nginx-d" {
    project      = module.service_project_d.name
    name         = "nginx-d"
    machine_type = "e2-micro"
    zone         = var.zone_1
    tags = [ "nginx", "ssh-mgmt", "east-west", "north-south" ]
    allow_stopping_for_update = true

    boot_disk {
        initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

    metadata = {
        enable-oslogin: "TRUE"
        startup-script = <<EOT
        #!/bin/bash
        apt update -y
        apt install -y nginx net-tools traceroute
        EOT
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-d.self_link
        network_ip = "192.168.40.5"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-mgmt.self_link
        network_ip = "172.16.40.5"
    }

  service_account {
    email  =  module.service_project_d.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
    depends_on = [
    google_compute_instance.vm-firewall
  ]
}
#
# instance svc-f
resource "google_compute_instance" "nginx-f" {
    project      = module.service_project_f.name
    name         = "nginx-f"
    machine_type = "e2-micro"
    zone         = var.zone_1
    tags = [ "nginx", "ssh-mgmt", "east-west", "north-south" ]
    allow_stopping_for_update = true

    boot_disk {
        initialize_params {
        image = "ubuntu-os-cloud/ubuntu-2004-lts"
        }
    }

    shielded_instance_config {
        enable_secure_boot = true
        enable_vtpm = true
        enable_integrity_monitoring = true
    }

    metadata = {
        enable-oslogin: "TRUE"
        startup-script = <<EOT
        #!/bin/bash
        apt update -y
        apt install -y nginx net-tools traceroute
        EOT
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-f.self_link
        network_ip = "192.168.60.5"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-mgmt.self_link
        network_ip = "172.16.60.5"
    }

  service_account {
    email  =  module.service_project_f.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
    depends_on = [
    google_compute_instance.vm-firewall
  ]
}
