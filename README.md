# Claude Skills

A collection of production-tested skills for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) — Anthropic's official CLI for Claude. These skills extend Claude's capabilities with structured workflows for shipping code, debugging, code review, and payment integration.

## Skills

### `/ship-it` — Full Ship Workflow

Automates the entire path from local changes to merged PR. Commit, push, create PR, watch CI, auto-fix failures, merge, and cleanup — all in one command.

**When to use:**
- You've finished a feature and want to get it merged without babysitting CI
- You want Claude to handle the commit-push-PR-merge cycle end-to-end
- CI fails and you want Claude to automatically diagnose and fix it

**What it does:**
1. Stages and commits changes with a descriptive message
2. Pushes and creates a PR (or uses an existing one)
3. Watches CI — waits for checks to appear and pass (never merges blindly)
4. On CI failure: reads logs, diagnoses the error, fixes code, and retries (up to 3 attempts)
5. Squash-merges on green CI, deletes the branch, and checks out main

---

### `/debugmode` — Hypothesis-Driven Debugging

A systematic debugging workflow that collects runtime evidence before proposing fixes. No more guessing — instrument, observe, then fix.

**When to use:**
- Encountering a bug you can't figure out from reading code alone
- Tests pass but production behavior is wrong
- Race conditions, flaky tests, or intermittent failures
- You want a structured approach instead of trial-and-error

**What it does:**
1. **Safety first** — creates a debug branch and stashes uncommitted work
2. **Hypothesizes** — generates 3-5 ranked theories about the root cause
3. **Reproduces** — writes and commits a reproduction test/script
4. **Instruments** — adds tagged debug logs (`[DEBUG-MODE][H1:slug]`) to the working tree
5. **Observes** — runs reproduction, collects logs, uses background agents to analyze evidence
6. **Cleans up** — `git restore .` removes all instrumentation (safe because repro test was committed)
7. **Fixes** — applies a targeted fix based on evidence, then verifies red-to-green

**Core principle:** Never propose a fix without runtime evidence.

---

### `/code-review` — Parallel Agent Code Review

Dispatches 5 specialist agents in parallel to perform a deep, evidence-based code review. Every finding must cite real file paths and line numbers — no guessing.

**When to use:**
- Before creating a PR
- Periodic codebase health checks
- Auditing database queries, API reliability, security, test quality, or performance
- Before major releases

**What it does:**

Launches 5 parallel review agents:

| Agent | Focus Area |
|-------|-----------|
| Database Query Analyst | N+1 queries, missing select optimization, caching opportunities, transaction usage |
| API Reliability Analyst | Error response consistency, retry logic, input validation, rate limiting, timeouts |
| Security Auditor | Auth bypass, authorization gaps, injection vulnerabilities, secret management, CORS |
| Test Quality Inspector | Hardcoded values, mock fidelity, test isolation, coverage gaps, assertion quality |
| Performance Analyst | Cron job isolation, memory management, concurrency control, resource exhaustion |

Findings are synthesized into a single report organized by severity (Critical > Warning > Info).

> **Note:** This skill was built for a specific codebase (lattice-evoke). To use it for your own project, update the file paths and project-specific details in the SKILL.md.

---

### `/stripe-integration` — Stripe Payment Processing

A comprehensive reference for implementing Stripe payments — checkout sessions, subscriptions, webhooks, refunds, and customer management.

**When to use:**
- Integrating Stripe payments into a web or mobile app
- Setting up subscription billing
- Implementing webhook handlers
- Processing refunds and disputes
- Building marketplace flows with Stripe Connect

**What it covers:**
- Hosted Checkout vs Custom Payment Intents vs Setup Intents
- Subscription lifecycle (create, update, cancel)
- Webhook security and idempotent event handling
- Customer and payment method management
- Refund and dispute handling
- Test card numbers and testing strategies
- PCI compliance best practices

---

## Installation

### Quick Install (copy to Claude global skills)

```bash
# Clone this repo
git clone https://github.com/ChiFungHillmanChan/claude-skills.git

# Copy a specific skill to your Claude global skills directory
cp -r claude-skills/skills/ship-it ~/.claude/skills/
cp -r claude-skills/skills/debugmode ~/.claude/skills/
cp -r claude-skills/skills/stripe-integration ~/.claude/skills/

# Or copy all skills at once
cp -r claude-skills/skills/* ~/.claude/skills/
```

### Project-Level Install

To add a skill to a specific project instead of globally:

```bash
# From your project root
mkdir -p .claude/skills
cp -r /path/to/claude-skills/skills/ship-it .claude/skills/
```

### Verify Installation

After copying, start a new Claude Code session and the skills should be available. You can verify by typing the skill name as a slash command:

```
/ship-it
/debugmode
```

## Customization

Each skill is a single `SKILL.md` file with YAML frontmatter (`name`, `description`) and markdown content. To customize:

1. **Edit the description** — this controls when Claude auto-triggers the skill
2. **Edit the workflow** — modify steps, add project-specific paths, change conventions
3. **Fork a skill** — copy a skill directory, rename it, and adapt it to your needs

### Example: Adapting Code Review for Your Project

The `code-review` skill references specific file paths for the lattice-evoke project. To adapt it:

1. Copy the skill: `cp -r ~/.claude/skills/code-review ~/.claude/skills/my-review`
2. Edit `~/.claude/skills/my-review/SKILL.md`
3. Replace file paths and project-specific details with your own
4. Update the `description` field so Claude triggers it for your project

## How Claude Skills Work

Skills are markdown files that teach Claude structured workflows. When you invoke a skill (e.g., `/ship-it`), Claude reads the SKILL.md and follows the workflow defined in it.

**Key concepts:**
- **Global skills** (`~/.claude/skills/`) — available in all projects
- **Project skills** (`.claude/skills/`) — available only in that project
- **Frontmatter** — the `name` and `description` fields control how Claude discovers and triggers the skill
- **Rigid vs flexible** — some skills (like debugmode) define strict step-by-step workflows; others (like stripe-integration) provide reference patterns to adapt

## License

MIT
