---
description: Run the arch-decision skill — a 7-stage structured loop for any architecture, vendor, infra, or build-vs-buy decision. Produces a scored decision memo with a binary verifier verdict.
---

Load and run the `arch-decision` skill on the user's question.

If the user hasn't provided a question yet, ask: "What's the decision you want to think through?"

Then follow the skill exactly: Stages 1–3 run automatically, Stage 4 stops for human weight confirmation, Stages 5–7 complete the memo and run the verifier.
