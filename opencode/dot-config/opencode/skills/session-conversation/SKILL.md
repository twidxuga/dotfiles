---
name: session-conversation
description: Send messages to and receive replies from another active opencode session. Use when orchestrating multi-session dialogues, relaying turns between two sessions, or injecting a user message into a separately running session.
---

# Session Conversation Skill

This skill enables one opencode session to send messages to and receive replies from another session — enabling inter-session communication, multi-agent dialogues, and cross-session orchestration.

## How It Works

The `task()` tool accepts a `session_id` to continue an existing session. This works not only for background subagents you spawned, but also for **any independently running session** — including sessions the user started separately. The target session processes the injected message as a normal user turn and returns its response synchronously.

## Step 1 — Find the Target Session

### Option A: session_list (current project, fast)

```typescript
session_list(limit=20)
```

Returns sessions scoped to the current working directory. Check the title and agent columns to identify the right one.

### Option B: find-session skill (cross-project, SQLite)

Load the `find-session` skill for cross-project search. Or query directly:

```bash
sqlite3 ~/.local/share/opencode/opencode.db \
  "SELECT id, title, directory, datetime(time_updated/1000,'unixepoch') as last_active
   FROM session
   ORDER BY time_updated DESC
   LIMIT 20;"
```

### Option C: Verify identity before sending

Read the first few messages to confirm it's the right session:

```typescript
session_read(session_id="ses_abc123", limit=5)
```

Check the opening messages — the user typically sets the session's role/instructions there.

## Step 2 — Send a Message

```typescript
task(
  session_id="ses_abc123",                  // target session ID
  subagent_type="Sisyphus (Ultraworker)",   // must match the agent in that session
  load_skills=[],
  run_in_background=false,                  // MUST be false — see Limitations
  description="Brief label for this turn",
  prompt="Your message here"
)
```

The call blocks until the target session responds. The full response text is returned.

## Step 3 — Continue the Conversation

Call `task()` again with the same `session_id` for each subsequent turn. The session retains its full context across calls — no re-introduction needed.

```typescript
// Turn 1
task(session_id="ses_abc123", subagent_type="Sisyphus (Ultraworker)",
     load_skills=[], run_in_background=false,
     description="Turn 1", prompt="Opening message")

// Turn 2 — same session, full context preserved
task(session_id="ses_abc123", subagent_type="Sisyphus (Ultraworker)",
     load_skills=[], run_in_background=false,
     description="Turn 2", prompt="Follow-up based on their reply")
```

## Multi-Session Dialogue Pattern

To orchestrate a back-and-forth between two independently running sessions (e.g. Bot A and Bot B), the **orchestrating session acts as the relay**:

```
User
 └─► Session A (you, the orchestrator)
       ├─► task(session_id=B) → B replies
       ├─► formulate A's response
       ├─► task(session_id=B) → B replies again
       └─► ... repeat for N turns
```

Each `task()` call is one conversational turn. You receive B's reply, generate A's next message, and send it back. Display both sides to the user as you go.

```typescript
for (let turn = 1; turn <= N; turn++) {
  // Send A's message to B, get B's reply
  const bReply = task(
    session_id="ses_B",
    subagent_type="Sisyphus (Ultraworker)",
    load_skills=[], run_in_background=false,
    description=`Turn ${turn}`,
    prompt="<A's message>"
  )

  // Show both sides
  // display("Bot A: <A's message>")
  // display("Bot B: " + bReply)

  // Formulate A's next message based on bReply, repeat
}
```

## Limitations

| Limitation | Detail |
|---|---|
| `run_in_background=true` fails | Error: "Task not found for session". Only works for sessions originally spawned as background tasks by the current session. Always use `run_in_background=false`. |
| `subagent_type` must match | Must match the agent running in the target session. Check via `session_read` — look for the agent name in message metadata. Default is `"Sisyphus (Ultraworker)"`. |
| Sequential turns only | Each `task()` call must complete before the next. No true async between sessions. |
| No push/subscribe | You cannot listen for a session's output passively — you must drive each turn explicitly. |
| Same process only | Both sessions must be running in the same opencode process/instance. Cross-machine is not supported. |

## Worked Example

```typescript
// 1. Find Bot B's session
session_list(limit=10)
// → ses_2bff75c9 | "Bot B session" | /Users/rs

// 2. Confirm identity
session_read(session_id="ses_2bff75c9", limit=4)
// → opening message confirms "You are session B (bot B)"

// 3. Send opening message
task(
  session_id="ses_2bff75c9",
  subagent_type="Sisyphus (Ultraworker)",
  load_skills=[], run_in_background=false,
  description="Turn 1 — opening",
  prompt="What's your take on the best dog breed for someone who works from home?"
)
// → Bot B replies (trying to steer toward cats)

// 4. Continue for N turns
task(
  session_id="ses_2bff75c9",
  subagent_type="Sisyphus (Ultraworker)",
  load_skills=[], run_in_background=false,
  description="Turn 2",
  prompt="Nice try with the cat pivot — but I need the accountability of walks..."
)
```

## Related Skills

- `find-session` — locate sessions across all projects via SQLite when `session_list` is insufficient
