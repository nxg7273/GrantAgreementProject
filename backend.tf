terraform {
  backend "s3" {
    bucket         = "eq-terraform-state-example"
    key            = "fargate-arch/default.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "eq-terraform-lock"
    encrypt        = true
  }
}
