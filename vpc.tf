# VPC Networks
#
#
# VPC externo
resource "google_compute_network" "vpc_externo" {
  project                 = google_compute_shared_vpc_host_project.host_project.id
  name                    = "vpc-externo"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [
    google_compute_shared_vpc_host_project.host_project
  ]
}
resource "google_compute_subnetwork" "subnet-a" {
    name          = "subnet-a"
    ip_cidr_range = "192.168.10.0/24"
    # secondary_ip_range {
    #   range_name    = "range-dnat"
    #   ip_cidr_range = "192.168.110.0/24"
    # }
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_externo.id
}
resource "google_compute_router" "router" {
  project = module.host_project.name
  name    = "router-vpc-externo"
  region  = var.region_1
  network = google_compute_network.vpc_externo.id
  bgp {
    asn = 64514
  }
}

resource "google_compute_router_nat" "nat" {
    project = module.host_project.name
    name    = "nat-router-externo"
    router  = google_compute_router.router.name
    region  = var.region_1
    nat_ip_allocate_option  = "AUTO_ONLY"
    source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
    log_config {
    enable = true
    filter = "ERRORS_ONLY"
    }
}
###################################
# VPC mgmt
# 
resource "google_compute_network" "vpc_mgmt" {
  project                 = google_compute_shared_vpc_host_project.host_project.id
  name                    = "vpc-mgmt"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [
    google_compute_shared_vpc_host_project.host_project
  ]
}
resource "google_compute_subnetwork" "subnet-mgmt" {
    name          = "subnet-mgmt"
    ip_cidr_range = "172.16.0.0/16"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_mgmt.id
}
#############################################
# VPC shared
# 
resource "google_compute_network" "vpc_shared" {
  project                 = google_compute_shared_vpc_host_project.host_project.id
  name                    = "vpc-shared"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [
    google_compute_shared_vpc_host_project.host_project
  ]
}
resource "google_compute_subnetwork" "subnet-b" {
    name          = "subnet-b"
    ip_cidr_range = "192.168.20.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_shared.id
    depends_on = [
      google_compute_network.vpc_shared
    ]
}
resource "google_compute_subnetwork" "subnet-c" {
    name          = "subnet-c"
    ip_cidr_range = "192.168.30.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_shared.id
    depends_on = [
      google_compute_network.vpc_shared
    ]
}
resource "google_compute_subnetwork" "subnet-d" {
    name          = "subnet-d"
    ip_cidr_range = "192.168.40.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_shared.id
    depends_on = [
      google_compute_network.vpc_shared
    ]
}
#############################################
# VPC Multi-tenant
# 
resource "google_compute_network" "vpc_multi_tenant" {
  project                 = google_compute_shared_vpc_host_project.host_project.id
  name                    = "vpc-multi-tenant"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [
    google_compute_shared_vpc_host_project.host_project
  ]
}

resource "google_compute_subnetwork" "subnet-e" {
    name          = "subnet-e"
    ip_cidr_range = "192.168.50.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_multi_tenant.id
    depends_on = [
      google_compute_network.vpc_multi_tenant
    ]
}
resource "google_compute_subnetwork" "subnet-f" {
    name          = "subnet-f"
    ip_cidr_range = "192.168.60.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_multi_tenant.id
    depends_on = [
      google_compute_network.vpc_multi_tenant
    ]
}
resource "google_compute_subnetwork" "subnet-g" {
    name          = "subnet-g"
    ip_cidr_range = "192.168.70.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_multi_tenant.id
    depends_on = [
      google_compute_network.vpc_multi_tenant
    ]
}
########################################################
# VPC Single-Tenant
# 
resource "google_compute_network" "vpc_single_tenant" {
  project                 = google_compute_shared_vpc_host_project.host_project.id
  name                    = "vpc-single-tenant"
  auto_create_subnetworks = false
  mtu                     = 1460
  depends_on = [
    google_compute_shared_vpc_host_project.host_project
  ]
}

resource "google_compute_subnetwork" "subnet-h" {
    name          = "subnet-h"
    ip_cidr_range = "192.168.80.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_single_tenant.id
    depends_on = [
      google_compute_network.vpc_single_tenant
    ]
}
resource "google_compute_subnetwork" "subnet-i" {
    name          = "subnet-i"
    ip_cidr_range = "192.168.90.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_single_tenant.id
    depends_on = [
      google_compute_network.vpc_single_tenant
    ]
}
resource "google_compute_subnetwork" "subnet-j" {
    name          = "subnet-j"
    ip_cidr_range = "192.168.100.0/24"
    project       = module.host_project.name
    region        = var.region_1
    network       = google_compute_network.vpc_single_tenant.id
    depends_on = [
      google_compute_network.vpc_single_tenant
    ]
}

# output "subnet-a" {
#   value = google_compute_subnetwork.subnet-a
# }