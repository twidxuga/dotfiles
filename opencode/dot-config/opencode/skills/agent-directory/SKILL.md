---
name: agent-directory
description: Discover and invoke specialist agents from the user's agent/ folder. Use before delegating any specialised task — check if a domain expert exists before falling back to generic categories.
---

# Agent Directory

You have access to a library of specialist agents beyond the standard oh-my-opencode roster. These live at `~/.config/opencode/agent/` (one `.md` file per agent).

## How to Discover Available Agents

Use the `Read` tool on the agent directory to list all available specialists:

```
Read("~/.config/opencode/agent/")
```

This returns all `.md` filenames. To find the correct `subagent_type` value, read the agent's frontmatter `name` field — that is what you pass to `task()`, NOT the filename.

To discover an agent's name and capabilities:

```
Read("~/.config/opencode/agent/<filename>.md", limit=10)  # frontmatter has name + description
```

The `name:` field in the frontmatter is the exact value to use as `subagent_type`. Matching is case-insensitive.

## How to Invoke a Specialist Agent

```typescript
task(
  subagent_type="<frontmatter name field>",  // e.g. "Senior Developer", "Backend Architect"
  load_skills=[],          // add relevant skills as usual
  run_in_background=false, // or true for parallel work
  description="Brief description",
  prompt="..."
)
```

Examples:
```typescript
// Backend work (name: "Backend Architect")
task(subagent_type="Backend Architect", load_skills=[], run_in_background=false, description="Design service", prompt="...")

// DevOps / infra (name: "DevOps Automator")
task(subagent_type="DevOps Automator", load_skills=[], run_in_background=false, description="CI pipeline", prompt="...")

// Security review (name: "Security Engineer")
task(subagent_type="Security Engineer", load_skills=[], run_in_background=false, description="Security audit", prompt="...")

// Frontend (name: "Frontend Developer")
task(subagent_type="Frontend Developer", load_skills=["frontend-ui-ux"], run_in_background=false, description="Build component", prompt="...")
```

## When to Use a Specialist vs a Category

| Situation | Use |
|---|---|
| A specialist agent's `description` closely matches your task | `subagent_type="<specialist>"` |
| No specialist fits, but a category model is better suited | `category="..."` |
| Generic work, no domain alignment | `category="unspecified-low/high"` |

**Rule**: Always scan the agent directory before defaulting to a generic category. A specialist agent has a system prompt tuned to its domain — it will outperform a generic category for matching work.

## Current Agent List (as of last discovery)

Run `Read("~/.config/opencode/agent/")` for the live list. Known specialists include:

- `Senior Developer` — Full-stack implementation, Laravel/Livewire/FluxUI, premium UI
- `Backend Architect` — Scalable system design, database architecture, API development
- `Frontend Developer` — Frontend components, UX, modern CSS
- `DevOps Automator` — CI/CD, infrastructure automation, cloud deployments
- `Security Engineer` — Security reviews, vulnerability analysis, compliance
- `Data Engineer` — Data pipelines, ETL, analytics infrastructure
- `Technical Writer` — Documentation, API docs, technical prose
- `UI Designer` / `UX Architect` / `UX Researcher` — Design and UX work
- `Mobile App Builder` — Mobile development
- `Infrastructure Maintainer` — Cloud infra, Kubernetes, IaC
- `Performance Benchmarker` — Performance profiling and optimisation
- `API Tester` — API testing and validation
- `Test Results Analyzer` — Test analysis and reporting
- `Rapid Prototyper` — Fast prototyping
- `Senior Project Manager` — Project coordination
- `Sprint Prioritizer` — Sprint planning, backlog grooming

For the full list of 68 agents, always read the directory live.
