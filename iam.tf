#  Remove organization policy constraints
resource "google_project_organization_policy" "ip_forward_policy" {
  project    = module.host_project.name
  constraint = "compute.vmCanIpForward"
  list_policy {
    allow {
      all = true
    }
  }
  depends_on = [
    module.host_project.id
  ]
}
data "google_client_openid_userinfo" "ehc" {}

resource "google_os_login_ssh_public_key" "cache" {
  user = data.google_client_openid_userinfo.ehc.email
  key  = file(var.ssh_public_key_file)
}

resource "google_project_iam_member" "project" {
  project = module.host_project.name
  role    = "roles/compute.osAdminLogin"
  member  = "user:${data.google_client_openid_userinfo.ehc.email}"
}
