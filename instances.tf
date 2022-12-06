# virtual appliance instance
#
# instance jumphost
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
        # network_ip = "192.168.10.20"
    }

  service_account {
    email  =  module.host_project.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
}
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
        # web server config
        sudo sed -i 's/listen 80/listen 8081/' /etc/nginx/sites-enabled/default
        hostname=$(hostname)
        echo "<html><h1>Hello World</h1><h2>server: $hostname</h2></html>" > /var/www/html/index.html
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
    # depends_on = [
    #   google_compute_instance_group_manager.mig-nva
    # ]
}
# instance svc-d
# resource "google_compute_instance" "nginx-d" {
#     project      = module.service_project_d.name
#     name         = "nginx-d"
#     machine_type = "e2-micro"
#     zone         = var.zone_1
#     tags = [ "nginx", "ssh-mgmt", "east-west", "north-south" ]
#     allow_stopping_for_update = true

#     boot_disk {
#         initialize_params {
#         image = "ubuntu-os-cloud/ubuntu-2004-lts"
#         }
#     }

#     shielded_instance_config {
#         enable_secure_boot = true
#         enable_vtpm = true
#         enable_integrity_monitoring = true
#     }

#     metadata = {
#         enable-oslogin: "TRUE"
#         startup-script = <<EOT
#         #!/bin/bash
#         apt update -y
#         apt install -y nginx net-tools traceroute
#         EOT
#     }

#     network_interface {
#         subnetwork = google_compute_subnetwork.subnet-d.self_link
#         network_ip = "192.168.40.5"
#     }
#     network_interface {
#         subnetwork = google_compute_subnetwork.subnet-mgmt.self_link
#         network_ip = "172.16.40.5"
#     }

#   service_account {
#     email  =  module.service_project_d.service_accounts.default.compute
#     scopes = ["cloud-platform"]
#   }
    # depends_on = [
    #   google_compute_instance_group_manager.mig-nva.id
    # ]
# }
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
        sudo sed -i 's/listen 80/listen 8082/' /etc/nginx/sites-enabled/default
        hostname=$(hostname)
        echo "<html>\n<h1>Hello World</h1>\n<h2>server: $hostname</h2>\n</html>" > /var/www/html/index.html
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
    # depends_on = [
    #   google_compute_instance_group_manager.mig-nva
    # ]
}