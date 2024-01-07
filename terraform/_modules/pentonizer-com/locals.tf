locals {
  root     = "pentonizer.com"
  www-root = "www.${local.root}"
  api-root = "api.${local.root}"

  buckets = {
    root = local.root
    www  = local.www-root
  }
}
