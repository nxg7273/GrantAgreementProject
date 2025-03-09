terraform {
  # Optionally override or re-init for nonprod environment
}

module "fargate_service_nonprod" {
  source            = "../../modules/module-foundational-ecs"
  environment       = var.environment
  cluster_name      = "${var.environment}-ecs-cluster"
  service_name      = "${var.environment}-pdf-service"
  container_image   = var.ecs_service_image
  db_secret_arn     = var.db_secret_arn
  subnets           = ["subnet-xyz123"]
  security_groups   = ["sg-xyz123"]
  assign_public_ip  = false
  additional_tags   = {}
}
