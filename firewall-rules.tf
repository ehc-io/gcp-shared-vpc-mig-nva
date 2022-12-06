# SSH Management
resource "google_compute_firewall" "allow-ssh-vpc-externo" {
    project = module.host_project.name
    description = "allows ssh connections from the internet to host on the external subnet (subnet-a)"
    name = "allow-ssh-vpc-externo"
    network = google_compute_network.vpc_externo.name
    priority = 1000
    direction = "INGRESS"
    disabled = false
    source_ranges = ["0.0.0.0/0"]
    target_tags =  [ "ssh-mgmt" ]
    allow {
    protocol = "tcp"
    ports    = ["22"]
    }
}
resource "google_compute_firewall" "allow-ssh-vpc-mgmt" {
    project = module.host_project.name
    description ="allows ssh connections from jumphost to virtual machines in service projects"
    name = "allow-ssh-vpc-mgmt"
    network = google_compute_network.vpc_mgmt.name
    priority = 1000
    direction = "INGRESS"
    disabled = false
    source_ranges = ["172.16.0.0/16"]
    target_tags =  [ "ssh-mgmt" ]
    allow {
    protocol = "tcp"
    ports    = ["22"]
    }
}
######################################################################
# EAST-WEST Traffic
resource "google_compute_firewall" "allow-east-west-shared" {
    project = module.host_project.name
    name = "allow-east-west-shared"
    network = google_compute_network.vpc_shared.name
    priority = 1000
    direction = "INGRESS"
    disabled = false
    source_ranges = [ "192.168.0.0/16" ]
    target_tags =  [ "east-west" ]
    allow {
    protocol = "all"
    }
}
resource "google_compute_firewall" "allow-east-west-multi-tenant" {
    project = module.host_project.name
    name = "allow-east-west-multi-tenant"
    network = google_compute_network.vpc_multi_tenant.name
    priority = 1000
    direction = "INGRESS"
    disabled = false
    source_ranges = [ "192.168.0.0/16" ]
    target_tags =  [ "east-west" ]
    allow {
    protocol = "all"
    }
}
resource "google_compute_firewall" "allow-east-west-single-tenant" {
    project = module.host_project.name
    name = "allow-east-west-single-tenant"
    network = google_compute_network.vpc_single_tenant.name
    priority = 1000
    direction = "INGRESS"
    disabled = false
    source_ranges = [ "192.168.0.0/16" ]
    target_tags =  [ "east-west" ]
    allow {
    protocol = "all"
    }
}
#########################################################################
# NORTH-SOUTH Traffic - including health checks
resource "google_compute_firewall" "allow-nginx-vpc-externo" {
    project       = module.host_project.name
    name          = "allow-nva-hc-ingress"
    direction     = "INGRESS"
    network       = google_compute_network.vpc_externo.id
    source_ranges = [ "0.0.0.0/0" ]
    target_tags =  [ "nva-health-check" ]
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports    = ["8081", "8082", "80" ]
    }
}
resource "google_compute_firewall" "allow-nginx-shared-vpc" {
    project       = module.host_project.name
    name          = "allow-nginx"
    direction     = "INGRESS"
    network       = google_compute_network.vpc_shared.id
    source_ranges = [ "0.0.0.0/0" ]
    target_tags =  [ "nginx" ]
    allow {
        protocol = "icmp"
    }
    allow {
        protocol = "tcp"
        ports    = ["8081", "8082", "80" ]
    }
}

#########################################################################
# health-checks NVAs ILB
# shared VPC
resource "google_compute_firewall" "allow-nva-hc-shared-vpc" {
    project       = module.host_project.name
    name          = "allow-nva-hc-shared-vpc"
    direction     = "INGRESS"
    network       = google_compute_network.vpc_shared.id
    source_ranges = [ "130.211.0.0/22", "35.191.0.0/16" ]
    target_tags =  [ "nva-health-check" ]
    allow {
        protocol = "tcp"
        ports    = [ "22" ]
    }
}
# external VPC
resource "google_compute_firewall" "allow-nva-hc-external-vpc" {
    project       = module.host_project.name
    name          = "allow-nva-hc-external-vpc"
    direction     = "INGRESS"
    network       = google_compute_network.vpc_externo.id
    source_ranges = [ "130.211.0.0/22", "35.191.0.0/16" ]
    target_tags =  [ "nva-health-check" ]
    allow {
        protocol = "tcp"
        ports    = [ "22" ]
    }
}
# Multi-tenant
# resource "google_compute_firewall" "allow-nva-hc-multi-tenant-vpc" {
#     project       = module.host_project.name
#     name          = "allow-nva-hc-multi-tenant-vpc"
#     direction     = "INGRESS"
#     network       = google_compute_network.vpc_multi_tenant.id
#     source_ranges = [ "130.211.0.0/22","35.191.0.0/16" ]
#     target_tags =  [ "fw" ]
#     allow {
#         protocol = "tcp"
#         ports    = ["22"]
#     }
# }
