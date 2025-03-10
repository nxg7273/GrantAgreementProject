region                = "eu-west-2"
environment           = "nonprod"
default_costcentre    = "cc0456"
default_businessunit  = "group"
default_tier          = "private"
default_product       = "compendia"
default_role          = "applicationserver"
default_customer      = "eq"
default_support       = "support.team@equiniti.com"
pdf_template_bucket_name = "my-pdf-templates-nonprod"
db_secret_arn         = "arn:aws:secretsmanager:eu-west-2:123456789012:secret:nonprod/db-credentials"
ecs_service_image     = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/myfargateapp:nonprod"
