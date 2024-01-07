terraform {
  source = "..//_modules/pentonizer-com"
}

include "root" {
  path = find_in_parent_folders()
}
