variable "region_1" {
    default = "us-central1"
}
variable "zone_1" {
    default = "us-central1-a"
}
variable parent_org {
    default = "<org_id>"
}
variable billing_account {
    default = "<billing_account>"
}
variable "timestamp" {
    default = "1669629589"
}
variable "host_project" {
    default = "host-project"
}
variable "service_project_c" {
    default = "svc-c"
}

variable "service_project_d" {
    default = "svc-d"
}

variable "service_project_f" {
    default = "svc-f"
}

variable "service_project_g" {
    default = "svc-g"
}

variable "service_project_i" {
    default = "svc-i"
}

variable "service_project_j" {
    default = "svc-j"
}

variable "ssh_public_key_file" {
    default = "./id_rsa_admin.pub"
}