locals {
  env     = "apps"
  name    = "dpenton-${local.env}"
  profile = "${local.name}-sso-terraform"
}
