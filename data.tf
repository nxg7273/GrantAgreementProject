data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# If you need to fetch an existing Secrets Manager secret or S3 info:
# data "aws_secretsmanager_secret" "db" {
#   arn = var.db_secret_arn
# }
