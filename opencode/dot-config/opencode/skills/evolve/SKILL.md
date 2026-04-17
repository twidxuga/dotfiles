---
name: evolve
description: Self-improvement loop for opencode configuration. Analyzes session history, identifies patterns and friction, and proposes targeted improvements to AGENTS.md, rules, skills, and agent definitions. Use when you want the agent setup to learn from accumulated experience.
---

# Evolve Skill — Configuration Self-Improvement

You are running the **evolve loop**: a structured process to improve the opencode agent configuration based on real session data. You have full access to session history, memories, and all config files.

## What You Are Improving

| File | Purpose | When to update |
|------|---------|----------------|
| `~/.config/opencode/AGENTS.md` | Global system prompt injected every session | New stack context, workflow preferences, recurring patterns |
| `~/.config/opencode/rules/global.md` | Always-active coding rules | New anti-patterns discovered, rules that were violated |
| `~/.config/opencode/rules/terraform.md` | Terraform-specific rules | New HCL patterns, module conventions |
| `~/.config/opencode/oh-my-openagent.json` | Agent framework config | Tuning concurrency, timeouts, experimental features |
| `~/.config/opencode/opencode-mem.jsonc` | Memory system config | Memory quality issues, injection tuning |
| `~/.config/opencode/commands/*.json` | Slash commands | New reusable workflows discovered |
| `~/.config/opencode/skills/*/SKILL.md` | Agent skills | Skill gaps, outdated instructions |
| `~/.config/opencode/agent/*.md` | Agent definitions | Missing specialists, outdated prompts |

## Phase 1 — Session Analysis

### 1a. Gather Recent Sessions
```
session_list(limit=20, from_date="<2 weeks ago>")
```
For each session with >4 messages, read it:
```
session_read(session_id="...", include_todos=true)
```

### 1b. Search for Patterns
Run these searches across all sessions:
```
session_search(query="error", limit=30)
session_search(query="don't", limit=20)          # corrections
session_search(query="no, ", limit=20)            # corrections  
session_search(query="remember", limit=20)        # explicit learnings
session_search(query="always", limit=20)          # rules being stated
session_search(query="never", limit=20)           # anti-patterns
session_search(query="wrong", limit=20)           # mistakes
session_search(query="instead", limit=20)         # corrections
session_search(query="actually", limit=20)        # course corrections
```

### 1c. Check opencode-mem Memories
Read the memory database for the current project:
```bash
sqlite3 ~/.opencode-mem/data/projects/*/shard_*.db \
  "SELECT content, created_at FROM memories ORDER BY created_at DESC LIMIT 50;"
```

### 1d. Check Recent Todos
Look for recurring todo patterns — tasks that keep appearing suggest missing automation or skills.

## Phase 2 — Pattern Classification

Classify each finding into one of:

| Category | Signal | Action |
|----------|--------|--------|
| **Correction** | User said "no", "don't", "wrong", "actually" | Add to rules |
| **Friction** | Same task done manually 3+ times | Create command or skill |
| **Missing context** | Agent asked for info that should be in AGENTS.md | Update AGENTS.md |
| **Config bug** | Something broke due to config | Fix config + add rule |
| **Missing agent** | Task needed specialist that doesn't exist | Create agent definition |
| **Outdated rule** | Rule contradicts actual practice | Update rule |
| **Skill gap** | Skill instructions were wrong or incomplete | Update skill |
| **Pattern** | Recurring workflow that could be a command | Create command |

## Phase 3 — Scoring and Prioritisation

Score each proposed change:
- **Impact** (1-5): How much does this improve future sessions?
- **Confidence** (1-5): How certain are you this is the right change?
- **Risk** (1-5): How likely is this to break something?

Only apply changes where: `(Impact × Confidence) / Risk > 3`

## Phase 4 — Apply Changes

### Rules for Applying

1. **Read the file first** before editing
2. **Show the diff** (old vs new) before applying
3. **Be additive** — prefer adding new rules over rewriting existing ones
4. **Be specific** — vague rules are ignored; concrete rules are followed
5. **Never remove** rules without strong evidence they're wrong
6. **Log every change** in `~/.config/opencode/EVOLUTION_LOG.md`

### AGENTS.md Updates
Add to the relevant section. New stack components go under "Infrastructure Context". New workflow preferences go under "Workflow Preferences". Do NOT rewrite existing content — append or refine.

### Rules Updates
Add new rules as bullet points under the most relevant section. If no section fits, create a new one. Rules must be:
- Actionable (starts with a verb)
- Specific (not "be careful", but "always run X before Y")
- Testable (you can verify if it was followed)

### Command Creation
New commands go in `~/.config/opencode/commands/<name>.json`:
```json
{
  "template": "ulw <detailed prompt with $ARGUMENTS>",
  "description": "<one line description>",
  "agent": "Sisyphus"
}
```

### Skill Updates
Edit the relevant `SKILL.md`. Add new sections for discovered patterns. Update outdated instructions. Never remove working sections.

## Phase 5 — Log Changes

Append to `~/.config/opencode/EVOLUTION_LOG.md`:
```markdown
## YYYY-MM-DD — Evolution Run

### Sessions Analysed
- N sessions from <date range>
- Key patterns found: <summary>

### Changes Applied
- `rules/global.md`: Added rule about X (from session <id>)
- `AGENTS.md`: Updated infrastructure context with Y
- `commands/foo.json`: Created new command for Z

### Skipped (low confidence)
- Potential rule about X — only seen once, monitoring

### Next Evolution Focus
- Watch for: <patterns to monitor>
```

## Safety Constraints

- **Never commit** changes to git (user does that explicitly)
- **Never delete** existing rules without explicit user approval
- **Never modify** `opencode-mem.jsonc` or `oh-my-openagent.json` without showing full diff
- **Always** read the file before editing
- **Always** log what was changed and why
- **Stop and ask** if you find a contradiction between sessions (different users want different things)

## Arguments Handling

If `$ARGUMENTS` contains:
- `--dry-run` — show proposals only, do not apply
- `--focus=rules` — only update rules files
- `--focus=agents` — only update AGENTS.md and agent definitions
- `--focus=skills` — only update skills
- `--focus=commands` — only create/update commands
- `--since=YYYY-MM-DD` — only analyse sessions after this date
- `--session=<id>` — analyse a specific session only
