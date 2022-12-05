# #
# static routes for VPC-Shared
resource "google_compute_route" "east-west-vpc-shared" {
    project     =  module.host_project.name
    name         = "east-west-vpc-shared"
    dest_range   = "192.168.0.0/16"
    network      = google_compute_network.vpc_shared.id
    next_hop_ilb  = google_compute_forwarding_rule.fr-egress-shared-vpc.id
    priority     = 1000
}

resource "google_compute_route" "north-south-vpc-shared" {
    project     =  module.host_project.name
    name         = "north-south-vpc-shared"
    dest_range   = "0.0.0.0/0"
    network      = google_compute_network.vpc_shared.id
    next_hop_ilb  = google_compute_forwarding_rule.fr-egress-shared-vpc.id
    priority     = 1000
}

# static routes for VPC-Multi-Tenant
resource "google_compute_route" "east-west-vpc-multi-tenant" {
    project     =  module.host_project.name
    name         = "east-west-vpc-multi-tenant"
    dest_range   = "192.168.0.0/16"
    network      = google_compute_network.vpc_multi_tenant.id
    next_hop_ilb  = google_compute_forwarding_rule.fr-egress-multi-tenant-vpc.id
    priority     = 1000
}

resource "google_compute_route" "north-south-vpc-multi-tenant" {
    project     =  module.host_project.name
    name         = "north-south-vpc-multi-tenant"
    dest_range   = "0.0.0.0/0"
    network      = google_compute_network.vpc_multi_tenant.id
    next_hop_ilb  = google_compute_forwarding_rule.fr-egress-multi-tenant-vpc.id
    priority     = 1000
}

# static routes for VPC-Single-Tenant
resource "google_compute_route" "east-west-vpc-single-tenant" {
    project     =  module.host_project.name
    name         = "east-west-vpc-single-tenant"
    dest_range   = "192.168.0.0/16"
    network      = google_compute_network.vpc_single_tenant.id
    next_hop_ilb  = google_compute_forwarding_rule.fr-egress-single-tenant-vpc.id
    priority     = 1000
}

resource "google_compute_route" "north-south-vpc-single-tenant" {
    project     =  module.host_project.name
    name         = "north-south-vpc-single-tenant"
    dest_range   = "0.0.0.0/0"
    network      = google_compute_network.vpc_single_tenant.id
    next_hop_ilb  = google_compute_forwarding_rule.fr-egress-single-tenant-vpc.id
    priority     = 1000
}