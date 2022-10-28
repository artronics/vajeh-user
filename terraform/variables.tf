locals {
  project = "vajeh"
  tier    = "service"
}

locals {
  environment = terraform.workspace
  service = "user"
  name_prefix = "${local.project}-${local.service}-${local.environment}"
}

locals {
  root_domain_name = "vajeh.artronics.me.uk"
  domain_name = "${local.environment}.${local.service}.${local.root_domain_name}"
}

