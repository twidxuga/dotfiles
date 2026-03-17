#!/usr/bin/env bash
set -euo pipefail

SKILLS_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE="https://raw.githubusercontent.com/hashicorp/agent-skills/main"

declare -A SKILLS=(
  ["terraform-style-guide"]="terraform/code-generation/skills/terraform-style-guide"
  ["terraform-test"]="terraform/code-generation/skills/terraform-test"
  ["terraform-search-import"]="terraform/code-generation/skills/terraform-search-import"
  ["terraform-stacks"]="terraform/module-generation/skills/terraform-stacks"
  ["terraform-refactor-module"]="terraform/module-generation/skills/refactor-module"
  ["terraform-new-provider"]="terraform/provider-development/skills/new-terraform-provider"
  ["terraform-provider-resources"]="terraform/provider-development/skills/provider-resources"
  ["terraform-provider-actions"]="terraform/provider-development/skills/provider-actions"
  ["terraform-run-acceptance-tests"]="terraform/provider-development/skills/run-acceptance-tests"
)

for skill in "${!SKILLS[@]}"; do
  path="${SKILLS[$skill]}"
  mkdir -p "$SKILLS_DIR/$skill"
  curl -sLo "$SKILLS_DIR/$skill/SKILL.md" "$BASE/$path/SKILL.md"
  echo "  ✓ $skill"
done

mkdir -p "$SKILLS_DIR/terraform-new-provider/assets"
curl -sLo "$SKILLS_DIR/terraform-new-provider/assets/main.go" \
  "$BASE/terraform/provider-development/skills/new-terraform-provider/assets/main.go"
echo "  ✓ terraform-new-provider/assets/main.go"
