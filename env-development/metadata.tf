# Add metadata to Consul
data "template_file" "terraform_version" {
  template = "${file(".terraform-version")}"
}

# The "rk" prefix in the path could be interpolated from something
# for example var.service_id if it exits.
resource "consul_key_prefix" "terraform" {
  path_prefix = "${local.service_name}/api/tf/"

  subkeys = {
    "version"   = "${trimspace(data.template_file.terraform_version.rendered)}"
    "last-run"  = "${timestamp()}"
    "terraform" = "true"
  }
}
