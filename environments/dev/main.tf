terraform {
  # Optionally override or re-init
  # Provide environment-specific partial backend config if needed
}

module "fargate_service_dev" {
  source            = "../../modules/module-foundational-ecs"
  environment       = var.environment
  cluster_name      = "${var.environment}-ecs-cluster"
  service_name      = "${var.environment}-pdf-service"
  container_image   = var.ecs_service_image
  db_secret_arn     = var.db_secret_arn
  subnets           = ["subnet-abc123"]
  security_groups   = ["sg-123abc"]
  assign_public_ip  = false
  additional_tags   = {}
}
