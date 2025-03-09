# AWS Fargate Architecture – Terraform Code

This repository contains a **modular Terraform project** for an AWS-based solution that includes:

*   **Amazon API Gateway (HTTP API + JWT Authz)**
*   **ECS Fargate** running containerized workloads (Auto Scaling)
*   **Secrets Manager** for DB credentials
*   **ECR** for container images
*   **S3** for static PDF template storage
*   **CloudWatch** for logs/metrics
*   **Optional EC2** examples illustrating domain joining and PatchGroup tagging
*   **Automated code checks** (lint/security) via TFLint and Checkov
*   **Azure DevOps** pipeline configuration

It also demonstrates **mandatory corporate tagging** (e.g., `costcentre`, `businessunit`, `environment`, `map-migrated`, etc.) with integrated validation logic.

* * *

## 1\. Project Overview

1.  **Infrastructure as Code** – The entire infrastructure is provisioned via Terraform, ensuring repeatable, consistent deployments across different environments (dev, nonprod, prod, etc.).
2.  **AWS Best Practices** – Fargate-based microservices behind an API Gateway. Secrets are stored in AWS Secrets Manager. PDFs in S3. Logging/monitoring in CloudWatch.
3.  **Tag Enforcement** – The code enforces mandatory tags via:
    *   **TFLint**: ensures the presence of certain keys.
    *   **Checkov**: custom policy definitions ensure correct patterns/allowed values for each tag key.
4.  **Extensible** – Additional AWS resources (e.g., RDS, Lambda, ALB) can be integrated using the same pattern, applying the same tagging standards.

* * *

## 2\. Repository Structure

graphql

Copy

`. ├── .checkov.policy.yaml       # Custom Checkov rules for mandatory tags ├── .gitignore                 # Ignore local Terraform state/cache files ├── .tflint.hcl                # TFLint config: enforces required tag keys ├── azure-pipelines.yml        # Azure DevOps pipeline for CI/CD ├── backend.tf                 # Remote state backend config (S3 + DynamoDB) ├── data.tf                    # Example data lookups (e.g., caller identity) ├── locals.tf                  # Local variables for naming or shared logic ├── main.tf                    # High-level resources: Fargate, S3, ECR, etc. ├── modules │   └── module-foundational-ecs │       ├── main.tf           # ECS cluster, task definition, service │       ├── variables.tf      # Inputs for ECS module │       ├── outputs.tf        # ECS module outputs │       └── README.md         # Documentation for ECS module usage ├── outputs.tf                 # Outputs from this root project ├── provider.tf                # AWS provider config + default_tags ├── versions.tf                # Terraform + providers version constraints ├── variables.tf               # Root-level input variables └── environments     ├── dev     │   ├── main.tf           # Environment-specific overrides for dev     │   └── terraform.tfvars  # Dev-specific variable values     └── nonprod         ├── main.tf           # Environment-specific overrides for nonprod         └── terraform.tfvars  # Nonprod-specific variable values`

* * *

## 3\. Prerequisites

1.  **AWS Account** with permissions to create the following resources:
    *   ECS, API Gateway, ECR, S3, Secrets Manager, CloudWatch, optional EC2
2.  **S3 Bucket & DynamoDB Table** for remote Terraform state & locking (named in `backend.tf` or passed via `-backend-config`).
3.  **Terraform CLI** (v1.3+ recommended).
4.  **TFLint** and **Checkov** (if you plan to run lint/security scans locally).
    *   They are automatically installed in the Azure DevOps pipeline, so local installation is optional.

* * *

## 4\. How to Use Locally

### 4.1 Clone or Download

bash

Copy

`git clone https://your-repo-url.com/your-terraform-project.git cd your-terraform-project`

### 4.2 Initialize Terraform

bash

Copy

`terraform init`

This reads the backend config (`backend.tf`), downloads providers, and sets up any required modules.

> If you need to override the backend settings, use:
> 
> bash
> 
> Copy
> 
> `terraform init \   -backend-config="bucket=<yourBucket>" \   -backend-config="region=eu-west-2" \   -backend-config="dynamodb_table=<yourDynamoDBTable>"`

### 4.3 Plan & Apply

**Choose an environment** (e.g., `dev` or `nonprod`):

bash

Copy

`# For dev environment: terraform plan -var-file=environments/dev/terraform.tfvars  # If the plan looks good: terraform apply -var-file=environments/dev/terraform.tfvars`

> This will create/update the resources in your AWS account, storing state in the specified S3 bucket + DynamoDB table for locking.

* * *

## 5\. CI/CD Pipeline in Azure DevOps

*   **File**: `azure-pipelines.yml`
*   On **push** to `main` (or your chosen branch), the pipeline:
    1.  Checks out the code.
    2.  Installs Terraform, TFLint, Checkov.
    3.  Runs `terraform fmt`, `terraform validate`, `tflint`, and `checkov --external-checks-dir .`.
    4.  Performs a `terraform plan` (storing it in a file called `tfplan`).
    5.  Waits for manual approval before apply.
    6.  Finally, runs `terraform apply tfplan` to deploy infrastructure.

### 5.1 Customizing the Pipeline

*   **Backend Configuration**: Store `backendBucket`, `backendDDBTable`, etc., in Azure DevOps Pipeline Library variables or pass them at runtime.
*   **Branching**: Adjust the `trigger:` line in `azure-pipelines.yml` for your branching strategy (e.g., `feature/*` or `pull_request`).

* * *

## 6\. Tagging Requirements & Policy Enforcement

### 6.1 Mandatory Tags

From the organization’s policy, **these tags** must be on all resources:

1.  **costcentre** (e.g., `cc0123`)
2.  **businessunit** (e.g., `group`)
3.  **environment** (e.g., `dev`, `nonprod`, `prd`)
4.  **map-migrated** (fixed: `mig1PLHE0ZI9T`)
5.  **tier** (`public`, `private`, or `data`)
6.  **product** (e.g., `compendia`, `xanite`)
7.  **role** (e.g., `applicationserver`, `sqlserver`)
8.  **customer** (e.g., `eq`, `shell`, `multi`)
9.  **support** (an equiniti.com email address)

In addition, some resources (like EC2) require **domain** and **PatchGroup** tags. If `role=sqlserver`, then `sqlenv`, `sqlversion`, etc. may also be required.

### 6.2 TFLint

*   **Config**: `.tflint.hcl`
*   **Purpose**: Ensures each resource has at least the mandatory tag **keys**.
*   **Running**:
    
    bash
    
    Copy
    
    `tflint --config .tflint.hcl`
    
*   Fails if any resource is missing a required tag key.

### 6.3 Checkov

*   **Config**: `.checkov.policy.yaml`
*   **Purpose**: Enforces **patterns** and **lists** for each tag. For example, `costcentre` must start with `"cc0"`; `businessunit` must be one of a known set; `map-migrated` must be exactly `"mig1PLHE0ZI9T"`, etc.
*   **Running**:
    
    bash
    
    Copy
    
    `checkov --directory . --external-checks-dir . --framework terraform`
    
*   Fails if a tag’s value does not conform (e.g., `costcentre = "cc999"` is OK, but `"mycenter"` is not).

> In the **Azure DevOps** pipeline, these steps run automatically.

* * *

## 7\. Detailed Components Overview

### 7.1 ECS Fargate

*   Defined in `modules/module-foundational-ecs`.
*   Creates an ECS cluster (`aws_ecs_cluster`), a Fargate task definition, and a service that references your container image (pulled from ECR) and DB credentials (from Secrets Manager).

### 7.2 API Gateway

*   `aws_apigatewayv2_api` in `main.tf`.
*   An HTTP API that can route requests to your ECS service (possibly via a private link, or via a Lambda integration, or direct integration if using VPC Link).
*   Tagging ensures it follows the same corporate standards.

### 7.3 Secrets Manager

*   The code references `db_secret_arn` as an input variable. You can store DB credentials, tokens, etc., in Secrets Manager.
*   The ECS container can read these secrets at runtime (or you can retrieve them in your code if using a custom approach).

### 7.4 ECR

*   Example resource `aws_ecr_repository.app_repo` in `main.tf` to store your container images.
*   Tagging enforced as well.

### 7.5 S3 (PDF Templates)

*   `aws_s3_bucket.pdf_templates` for storing static PDF templates.
*   By default, uses a name from `pdf_template_bucket_name`.
*   Must be properly tagged to comply with the policies.

### 7.6 EC2 (Optional Example)

*   Demonstrates how to handle domain, PatchGroup, or SQL-related tags if you choose to run a Windows or Linux instance requiring them.
*   If you don’t need any EC2 instances, you can remove that section.

* * *

## 8\. Environments

We include **two example environment folders**: `environments/dev` and `environments/nonprod`. Each has:

*   A `main.tf` (optionally referencing the top-level modules and overriding if needed).
*   A `terraform.tfvars` with environment-specific values (like region, cost centre, S3 bucket name, etc.).

This approach allows you to:

*   Keep environment-specific config in separate files.
*   Potentially use **Terraform workspaces** in parallel if needed.

* * *

## 9\. Extending the Architecture

Feel free to add:

*   **Load Balancer**: If your ECS Fargate service needs an ALB or NLB, create `aws_lb` + `aws_lb_target_group` resources, then attach them to `aws_ecs_service`.
*   **VPC / Subnets**: If you need to create your own VPC, subnets, and route tables, you could modularize them as well.
*   **RDS**: For a database layer, add a module or direct resources for `aws_db_instance` or `aws_rds_cluster`.
*   **Further Tag Validation**: Expand `.checkov.policy.yaml` for additional tags or advanced logic.

* * *

## 10\. Common Commands & Troubleshooting

1.  **Formatting**:
    
    bash
    
    Copy
    
    `terraform fmt -recursive`
    
    Auto-formats your code (2-space indentation).
    
2.  **Validation**:
    
    bash
    
    Copy
    
    `terraform validate`
    
    Checks whether your Terraform config is syntactically valid.
    
3.  **Destroy**:
    
    bash
    
    Copy
    
    `terraform destroy -var-file=environments/dev/terraform.tfvars`
    
    Removes the resources from AWS. Use with caution.
    
4.  **Missing or Invalid AWS Credentials**
    
    *   Ensure your AWS credentials or role assumptions are correct.
    *   In Azure DevOps, use service connections or environment variables (AWS\_ACCESS\_KEY\_ID, AWS\_SECRET\_ACCESS\_KEY, etc.) or OIDC-based IAM roles.
5.  **Tag Pattern Failures**
    
    *   Check TFLint or Checkov output. They usually tell you which resource is missing or has invalid tags.
    *   Adjust the tags in your `.tf` resources or override them with input variables.

* * *

## 11\. Next Steps & Customizations

*   **Customize the Pipeline**: Add environment-based pipeline stages, approvals, or integration tests.
*   **Refine Tag Lists**: If some tags are only mandatory for certain resource types, you can refine `.tflint.hcl` or `.checkov.policy.yaml`.
*   **Add Usage Documentation**: For your specific microservice (API endpoints, JWT usage, etc.).
*   **Security Groups / VPC**: Make sure the ECS tasks have the right inbound/outbound rules for your use case.
*   **Monitoring & Alarms**: Add CloudWatch alarms, dashboards, or usage of AWS Observability for ECS.

* * *

## 12\. How to Get Support

*   If you have questions about this Terraform project, contact your **Cloud / DevOps** team or the repository maintainers.
*   For AWS-specific issues (IAM privileges, resource limits), consult the AWS console or open a support case if you have an AWS Business/Enterprise Support plan.
*   For corporate tagging policies or environment naming conventions, refer to the internal wiki or your organization’s guidelines.

* * *

## 13\. License / Ownership

*   Owned by **Equiniti Cloud Team** (or relevant team).
*   Internal usage only; do not distribute publicly.
*   For any updates or major changes, create a branch and submit a pull request for code review.

* * *

**That’s it!**

By following this structure and instructions, you’ll have a consistent, **policy-compliant** Terraform setup that deploys an AWS Fargate-based solution and includes advanced tag validation via TFLint and Checkov.