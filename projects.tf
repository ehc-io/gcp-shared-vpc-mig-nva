# 
provider "google" { 
  region = var.region_1
}

provider "google-beta" { 
  region = var.region_1
}

resource "google_folder" "default" {
  display_name = "shared-vpc-nva-${var.timestamp}"
  parent       = var.parent_org
}

##############################################################
# project host
module "host_project" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.host_project}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = google_folder.default.name
    services = [
    "compute.googleapis.com"
    ]
}

resource "google_compute_shared_vpc_host_project" "host_project" {
    project = module.host_project.name
    depends_on = [
    module.host_project
    ]
}
#
#############################################################
# service project service c
module "service_project_c" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.service_project_c}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = google_folder.default.name
    services = [
    "compute.googleapis.com"
    ]
}

resource "google_compute_shared_vpc_service_project" "service_project_c" {
    host_project    = google_compute_shared_vpc_host_project.host_project.project
    service_project = module.service_project_c.name
    depends_on = [
    module.host_project, module.service_project_c
    ]
}
#############################################################
# service project service d
module "service_project_d" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.service_project_d}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = google_folder.default.name
    services = [
    "compute.googleapis.com"
    ]
}

resource "google_compute_shared_vpc_service_project" "service_project_d" {
    host_project    = google_compute_shared_vpc_host_project.host_project.project
    service_project = module.service_project_d.name
    depends_on = [
    module.host_project, module.service_project_d
    ]
}
###############################################################
# service project service f
module "service_project_f" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.service_project_f}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = google_folder.default.name
    services = [
    "compute.googleapis.com"
    ]
}

resource "google_compute_shared_vpc_service_project" "service_project_f" {
    host_project    = google_compute_shared_vpc_host_project.host_project.project
    service_project = module.service_project_f.name
    depends_on = [
    module.host_project, module.service_project_f
    ]
}
#################################################################
# service project service g
module "service_project_g" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.service_project_g}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = google_folder.default.name
    services = [
    "compute.googleapis.com"
    ]
}

resource "google_compute_shared_vpc_service_project" "service_project_g" {
    host_project    = google_compute_shared_vpc_host_project.host_project.project
    service_project = module.service_project_g.name
    depends_on = [
    module.host_project, module.service_project_g
    ]
}
################################################################
# service project service i
module "service_project_i" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.service_project_i}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = google_folder.default.name
    services = [
    "compute.googleapis.com"
    ]
}

resource "google_compute_shared_vpc_service_project" "service_project_i" {
    host_project    = google_compute_shared_vpc_host_project.host_project.project
    service_project = module.service_project_i.name
    depends_on = [
    module.host_project, module.service_project_i
    ]
}
###############################################################
# service project service j
module "service_project_j" {
    source              = "github.com/GoogleCloudPlatform/cloud-foundation-fabric//modules/project?ref=v13.0.0"
    name                =  "${var.service_project_j}-${var.timestamp}"
    billing_account     = var.billing_account
    parent              = google_folder.default.name
    services = [
    "compute.googleapis.com"
    ]
}
resource "google_compute_shared_vpc_service_project" "service_project_j" {
    host_project    = google_compute_shared_vpc_host_project.host_project.project
    service_project = module.service_project_j.name
    depends_on = [
    module.host_project, module.service_project_j
    ]
}

output "tld_folder" {
    value = google_folder.default
}