###########################
# ECS FARGATE MODULE
###########################
module "fargate_service" {
  source            = "./modules/module-foundational-ecs"
  environment       = var.environment
  cluster_name      = "${var.environment}-ecs-cluster"
  service_name      = "${var.environment}-pdf-service"
  container_image   = var.ecs_service_image
  db_secret_arn     = var.db_secret_arn

  # Example subnets / SGs
  subnets           = ["subnet-12345678", "subnet-23456789"]
  security_groups   = ["sg-0123456789abcdef"]
  assign_public_ip  = false
  additional_tags   = {
    # You can pass extra tags specific to this module
    "owner" = "eq-cloudteam"
  }
}

###########################
# S3 BUCKET for PDF templates
###########################
resource "aws_s3_bucket" "pdf_templates" {
  bucket = var.pdf_template_bucket_name

  # Mandatory tags (some are set automatically by default_tags,
  # but we can override or specify additional).
  tags = {
    costcentre      = "cc0123"
    businessunit    = "group"
    environment     = var.environment
    "map-migrated"  = "mig1PLHE0ZI9T"
    tier            = "private"
    product         = "compendia"
    role            = "applicationserver"
    customer        = "eq"
    support         = "support.team@equiniti.com"
  }
}

###########################
# API Gateway (HTTP API)
###########################
resource "aws_apigatewayv2_api" "http_api" {
  name          = "${local.name_prefix}-api"
  protocol_type = "HTTP"

  tags = {
    costcentre      = "cc0123"
    businessunit    = "group"
    environment     = var.environment
    "map-migrated"  = "mig1PLHE0ZI9T"
    tier            = "public"
    product         = "compendia"
    role            = "applicationserver"
    customer        = "eq"
    support         = "support.team@equiniti.com"
  }
}

###########################
# Example: ECR Repository (for container images)
###########################
resource "aws_ecr_repository" "app_repo" {
  name = "myfargateapp"

  tags = {
    costcentre     = "cc0123"
    businessunit   = "group"
    environment    = var.environment
    "map-migrated" = "mig1PLHE0ZI9T"
    tier           = "private"
    product        = "compendia"
    role           = "applicationserver"
    customer       = "eq"
    support        = "support.team@equiniti.com"
  }
}

###########################
# Example: EC2 Instance (Optional)
# Demonstrates domain, PatchGroup usage
###########################
resource "aws_instance" "demo_ec2" {
  ami                  = "ami-0abcdef1234567890"
  instance_type        = "t3.micro"
  subnet_id            = "subnet-12345678"
  vpc_security_group_ids = ["sg-0123456789abcdef"]
  associate_public_ip_address = false

  tags = {
    costcentre      = "cc0123"
    businessunit    = "group"
    environment     = var.environment
    "map-migrated"  = "mig1PLHE0ZI9T"
    tier            = "private"
    product         = "compendia"
    role            = "domaincontroller"  # or "sqlserver", etc.
    customer        = "eq"
    support         = "support.team@equiniti.com"
    domain          = "none"  # or 'group' if domain-joined
    PatchGroup      = "amseqnonprodukg1"
  }
}
