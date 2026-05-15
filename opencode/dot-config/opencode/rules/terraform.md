---
description: Terraform-specific rules applied when working with .tf files
globs:
  - "**/*.tf"
  - "**/*.tfvars"
  - "**/*.tftest.hcl"
---

# Terraform Rules

## Style
- Use 2-space indentation
- Align `=` signs in attribute blocks
- Order: `terraform` → `required_providers` → `provider` → `data` → `resource` → `output`
- Use `_` not `-` in resource names

## Modules
- Always use versioned module sources (never `?ref=main`)
- Document all variables with `description` and `type`
- Provide `default` values only for optional variables

## State
- Never manually edit state files
- Always use remote state (S3 + DynamoDB or Terraform Cloud)
- Use `terraform state` commands for state manipulation

## Testing
- Write `.tftest.hcl` tests for all new modules
- Mock external providers in unit tests
- Run `terraform test` before marking module work complete

## Generic AWS Patterns
- Before creating S3, IAM, or other AWS resources, check the org's Service Control Policies (SCPs) for relevant restrictions — org SCPs can deny actions that would otherwise succeed
- Account-level S3 public access blocks (enforced by security baselines) typically cover all buckets — adding bucket-level `aws_s3_bucket_public_access_block` may be redundant or blocked
- Verify Bedrock model ARN versions against the actual app code defaults before hardcoding in IAM policies — version mismatch causes `AccessDeniedException`

## Private (Company-Specific) Rules
- Company-specific Terraform rules (org SCP details, IRSA conventions, K8s namespace names, bundling specifics for the internal monorepo, PR references) live in `~/Documents/QuickAccess/kb/ai-agents/rules-terraform.md`
- Read that file before making Terraform changes in the internal infrastructure repo
