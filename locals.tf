locals {
  account_id     = data.aws_caller_identity.current.account_id
  current_region = data.aws_region.current.name
  # Build a name prefix for resources
  name_prefix    = "${var.environment}-fargate-arch"
}
