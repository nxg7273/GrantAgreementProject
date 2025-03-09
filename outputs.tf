output "fargate_service_arn" {
  description = "ARN of the ECS Service"
  value       = module.fargate_service.service_arn
}

output "fargate_task_definition" {
  description = "ARN of the ECS Task Definition"
  value       = module.fargate_service.task_definition_arn
}

output "s3_pdf_bucket_name" {
  description = "Name of the S3 bucket for PDF templates"
  value       = aws_s3_bucket.pdf_templates.id
}
