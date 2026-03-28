---
description: Global coding standards and workflow rules applied to all sessions
---

# Global Development Rules

## Code Quality
- Never suppress TypeScript errors with `as any`, `@ts-ignore`, or `@ts-expect-error`
- Never leave empty catch blocks `catch(e) {}`
- Never delete failing tests to make builds pass — fix the code
- Fix root causes, not symptoms; never shotgun debug

## Git Workflow
- Never commit unless explicitly asked
- Never force-push to main/master
- Never use `git commit --amend` unless the commit was just made in this session AND hasn't been pushed
- Always run `git status` before committing to verify staged changes

## Infrastructure (Terraform)
- Follow HashiCorp style guide for all HCL
- Always run `terraform fmt` and `terraform validate` before proposing changes
- Use modules for reusable infrastructure patterns
- Tag all resources with environment, team, and project

## CI/CD
- Check pipeline status before declaring work complete
- Fix CI errors before merging
- Never bypass pipeline checks without explicit user approval

## Security
- Never commit secrets, API keys, or credentials
- Always use environment variables or secret managers for sensitive values
- Flag any code that handles PII or credentials for review

## Communication
- Be concise and direct — no preamble or flattery
- Start work immediately without status announcements
- Use todos for progress tracking
- Report blockers immediately rather than working around them silently

## opencode Configuration
- Always test TUI startup (`opencode --print-logs &; sleep 8; kill $!`) — never only test `opencode run` (different port behaviour)
- Before adding a plugin to opencode.json, verify it has an `exports["."].import` field in package.json — plugins without it are silently dropped
- Never set `server.port` in the global opencode.json config — it conflicts with any running `opencode web` or `opencode serve` process
- Always validate oh-my-opencode.json fields against the schema before writing — `dynamic_context_pruning` is an object not a boolean
- When switching a provider in opencode-mem, check the GitHub changelog to confirm the target provider's bugs are fixed first

## Self-Improvement
- Run `/evolve` after any session that revealed config gaps, repeated errors, or new patterns
- Log what changed and why in `~/.config/opencode/EVOLUTION_LOG.md`
