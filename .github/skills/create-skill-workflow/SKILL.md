---
name: create-skill-workflow
description: 'Create a reusable SKILL.md from conversation patterns. Use for extracting repeatable workflows, decision branches, and quality checks into an on-demand skill.'
argument-hint: 'What workflow should this skill produce?'
user-invocable: true
disable-model-invocation: false
---

# Create Skill Workflow

## Outcome
Produce a complete `SKILL.md` that turns a repeatable process into a reusable, discoverable skill.

## When to Use
- User asks to create a new skill
- A repeated process appears in conversation and should be standardized
- A checklist needs to become a structured multi-step workflow

## Procedure
1. Extract workflow from conversation history.
2. Identify decision points and branch logic.
3. Capture quality and completion checks.
4. Draft and save `SKILL.md` in a valid skill folder.
5. Review for weak or ambiguous instructions.
6. Ask focused follow-up questions.
7. Finalize and provide usage examples.

## Step-by-Step

### 1) Extract Workflow
- Read the recent conversation and summarize:
  - Inputs and desired outcome
  - Ordered steps
  - Repeated heuristics used by the user
- If no reliable workflow appears, move to Clarification.

### 2) Define Branching Logic
- Add explicit branching where choices change behavior.
- Include defaults for missing input.
- Prefer deterministic choices over vague guidance.

### 3) Add Quality Criteria
Define completion checks such as:
- Correct file location and naming
- Valid YAML frontmatter
- Trigger-rich description for discovery
- Concrete procedure with testable steps

### 4) Draft the Skill
- Create a folder where folder name equals frontmatter `name`.
- Save `SKILL.md` with required frontmatter fields.
- Keep body concise and operational.

### 5) Clarify Ambiguities
Ask targeted questions only for unresolved gaps:
- What exact outcome should this skill produce?
- Should scope be workspace or personal?
- Should format be quick checklist or full workflow?

### 6) Finalize
- Integrate answers and tighten wording.
- Ensure steps are executable without extra context.
- Add practical example prompts.

## Completion Checklist
- `name` matches folder name
- `description` includes concrete trigger keywords
- Workflow includes branching and quality checks
- Questions cover unresolved ambiguity only
- Final output includes example prompts and next customization ideas

## Example Prompts
- /create-skill-workflow Build a skill that standardizes bug triage for Rails regressions.
- /create-skill-workflow Turn our release checklist into a reusable deployment skill.
- /create-skill-workflow Create a skill for review-first refactoring with tests.
