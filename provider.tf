provider "aws" {
  region = var.region

  default_tags {
    tags = {
      # You can override these in your resource blocks if needed
      costcentre   = var.default_costcentre
      businessunit = var.default_businessunit
      environment  = var.environment
      "map-migrated" = "mig1PLHE0ZI9T"
      tier         = var.default_tier
      product      = var.default_product
      role         = var.default_role
      customer     = var.default_customer
      support      = var.default_support
    }
  }
  ignore_tags {
    key_prefixes = ["ams"]
  }
}
