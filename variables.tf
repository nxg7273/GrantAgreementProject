variable "region" {
  description = "AWS region."
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name (e.g. dev, nonprod, prod)."
  type        = string
  default     = "dev"
}

# Default tag values, which you can override if needed
variable "default_costcentre" {
  description = "Cost Centre (must match pattern cc0...)"
  type        = string
  default     = "cc0123"
}

variable "default_businessunit" {
  description = "Business unit."
  type        = string
  default     = "group"
}

variable "default_tier" {
  description = "Tier classification (public, private, data)."
  type        = string
  default     = "private"
}

variable "default_product" {
  description = "Product name."
  type        = string
  default     = "compendia"
}

variable "default_role" {
  description = "Role or function of the resource."
  type        = string
  default     = "applicationserver"
}

variable "default_customer" {
  description = "Customer of the application."
  type        = string
  default     = "eq"
}

variable "default_support" {
  description = "Support contact email."
  type        = string
  default     = "support.team@equiniti.com"
}

# Additional placeholders
variable "pdf_template_bucket_name" {
  description = "S3 Bucket name for PDF templates."
  type        = string
  default     = "my-pdf-templates"
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret for DB credentials."
  type        = string
  default     = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:db-credentials"
}

variable "ecs_service_image" {
  description = "ECR image for the container."
  type        = string
  default     = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/myfargateapp:latest"
}
