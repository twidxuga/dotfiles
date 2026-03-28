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
