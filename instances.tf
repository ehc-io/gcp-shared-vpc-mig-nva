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
# resource "google_compute_instance" "client-a" {
#     project      = module.host_project.name
#     name         = "client-a"
#     machine_type = "e2-micro"
#     zone         = var.zone_1
#     tags = [ "ssh-mgmt" , "north-south"]

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
#         startup-script = <<EOT
#         #!/bin/bash
#         apt update -y
#         apt install -y net-tools traceroute
#         EOT
#     }

#     network_interface {
#         subnetwork = google_compute_subnetwork.subnet-a.self_link
#         # network_ip = "192.168.10.20"
#     }

#   service_account {
#     email  =  module.host_project.service_accounts.default.compute
#     scopes = ["cloud-platform"]
#   }
# }
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
        # web server-1 config
        curl -o /etc/nginx/sites-enabled/default https://gist.githubusercontent.com/ehc-io/de926bb5370b171234f4873ed1ab251a/raw/09427e85c8dc3fc5e7a43eac449c2653dc5a4ef3/app.conf
        sed -i 's/listen 8080/listen 8081/' /etc/nginx/sites-enabled/default
        curl -o /usr/share/nginx/html/index.html https://gist.githubusercontent.com/ehc-io/5248879e9aabbe4444e2ead09be754c0/raw/f4f15bf317f920a0982b0e29d87d66434cd57212/demo-index.html
        # web server-2 config
        host=$(hostname) ; echo "Webserver: $host" > /usr/share/nginx/html/txt.html
        systemctl restart nginx.service
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
      google_compute_instance_group_manager.mig-nva
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
        apt install -y nginx net-tools traceroute
        # web server-1 config
        curl -o /etc/nginx/sites-enabled/default https://gist.githubusercontent.com/ehc-io/de926bb5370b171234f4873ed1ab251a/raw/09427e85c8dc3fc5e7a43eac449c2653dc5a4ef3/app.conf
        # sed -i 's/listen 8080/listen 8080/' /etc/nginx/sites-enabled/default
        curl -o /usr/share/nginx/html/index.html https://gist.githubusercontent.com/ehc-io/5248879e9aabbe4444e2ead09be754c0/raw/f4f15bf317f920a0982b0e29d87d66434cd57212/demo-index.html
        # web server-2 config
        host=$(hostname) ; echo "Webserver: $host" > /usr/share/nginx/html/txt.html
        systemctl restart nginx.service
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
      google_compute_instance_group_manager.mig-nva
    ]
}
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
        # web server config
        curl -o /etc/nginx/sites-enabled/default https://gist.githubusercontent.com/ehc-io/de926bb5370b171234f4873ed1ab251a/raw/09427e85c8dc3fc5e7a43eac449c2653dc5a4ef3/app.conf
        sed -i 's/listen 8080/listen 8082/' /etc/nginx/sites-enabled/default
        curl -o /usr/share/nginx/html/index.html https://gist.githubusercontent.com/ehc-io/5248879e9aabbe4444e2ead09be754c0/raw/f4f15bf317f920a0982b0e29d87d66434cd57212/demo-index.html
        # web server-2 config
        host=$(hostname) ; echo "Webserver: $host" > /usr/share/nginx/html/txt.html
        systemctl restart nginx.service
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
      google_compute_instance_group_manager.mig-nva
    ]
}
# instance svc-g
resource "google_compute_instance" "nginx-g" {
    project      = module.service_project_g.name
    name         = "nginx-g"
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
        curl -o /etc/nginx/sites-enabled/default https://gist.githubusercontent.com/ehc-io/de926bb5370b171234f4873ed1ab251a/raw/09427e85c8dc3fc5e7a43eac449c2653dc5a4ef3/app.conf
        sed -i 's/listen 8080/listen 8082/' /etc/nginx/sites-enabled/default
        curl -o /usr/share/nginx/html/index.html https://gist.githubusercontent.com/ehc-io/5248879e9aabbe4444e2ead09be754c0/raw/f4f15bf317f920a0982b0e29d87d66434cd57212/demo-index.html
        # web server-2 config
        host=$(hostname) ; echo "Webserver: $host" > /usr/share/nginx/html/txt.html
        systemctl restart nginx.service
        EOT
    }

    network_interface {
        subnetwork = google_compute_subnetwork.subnet-g.self_link
        network_ip = "192.168.70.5"
    }
    network_interface {
        subnetwork = google_compute_subnetwork.subnet-mgmt.self_link
        network_ip = "172.16.70.5"
    }

  service_account {
    email  =  module.service_project_g.service_accounts.default.compute
    scopes = ["cloud-platform"]
  }
    depends_on = [
      google_compute_instance_group_manager.mig-nva
    ]
}