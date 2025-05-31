# Packer AWS AMI Builder

This project builds custom Amazon Machine Images (AMIs) using Packer and Terraform.

## Features

- All AMIs enforce **IMDSv2** for enhanced security
- AMI names are **dynamically timestamped** at build time
- AMIs are **tagged with name and date** to support easy identification and lifecycle management
- AMIs are intended to be **shared across multiple AWS accounts** using a **KMS Customer Managed Key (CMK)**

## Prerequisites

- You must **create the KMS key using Terraform** before running Packer.
- If the KMS key is not created, the AMI will only be usable within the same AWS account.
  - In that case, **remove** the following line from `image.pkr.hcl`:
    ```hcl
    kms_key_id = "alias/ami_kms_key"
    ```

## Setup Steps

1. **Update `terraform/variables.tf`:**
   - Replace the `organization_id` variable with your actual organization ID

2. **Update `terraform/providers.tf`:**
   - Replace the remote backend configuration (state file location) with your preferred backend (e.g., Terraform Cloud)
   - The current configuration points to a personal project

3. **Update `share_ami_to_these_accounts` in `terraform/variables.tf` for each image:**
   - List the AWS account IDs you want to share the AMIs with

## Pipeline Deployment

- An **OpenID Connect (OIDC) provider**
- An IAM **role** with permissions to deploy all necessary resources

See: [Use IAM Roles to Connect GitHub Actions to AWS](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)

Create GitHub Repository Variables/Secrets:
- `AWS_REGION`
  - e.g. `ap-southeast-2`
- `IAM_ROLE`
  - This is the arn of the IAM Role that will be assumed to run the Pipeline.
  - e.g. `arn:aws:iam::123456789012:role/ExampleRole`

- Trigger a build by running the appropriate **workflow** in GitHub Actions
