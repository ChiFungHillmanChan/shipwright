# Shipwright

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)
[![Plugin Marketplace](https://img.shields.io/badge/Marketplace-Ready-green)](#publishing-to-the-marketplace)

Production-tested Claude Code skills for the three things every developer does daily: **ship code, squash bugs, and review PRs.**

> **Skills** are markdown files that teach Claude structured workflows. When you invoke a skill (e.g., `/ship-it`), Claude reads the SKILL.md and follows the workflow step by step. Unlike simple prompts, skills define multi-phase processes with decision trees, background agents, and verification steps.

## Quick Install

```bash
# One-liner: install all skills globally
git clone https://github.com/ChiFungHillmanChan/shipwright.git && cp -r shipwright/skills/* ~/.claude/skills/
```

Or install individual skills:

```bash
# Install only the ones you need
cp -r shipwright/skills/ship-it ~/.claude/skills/
cp -r shipwright/skills/debugmode ~/.claude/skills/
cp -r shipwright/skills/code-review ~/.claude/skills/
```

## Skills

| Skill | Description | Use Case |
|-------|-------------|----------|
| [`/ship-it`](skills/ship-it/SKILL.md) | Full ship workflow — commit to merged PR | Done coding, want to ship |
| [`/debugmode`](skills/debugmode/SKILL.md) | Hypothesis-driven debugging with runtime evidence | Hit a bug, need systematic approach |
| [`/code-review`](skills/code-review/SKILL.md) | 5-agent parallel code review | Pre-PR quality check |

---

### `/ship-it` — Full Ship Workflow

> **[View SKILL.md](skills/ship-it/SKILL.md)**

Automates the entire path from local changes to merged PR. Commit, push, create PR, watch CI, auto-fix failures, merge, and cleanup — all in one command.

**When to use:**
- You've finished a feature and want to get it merged without babysitting CI
- You want Claude to handle the commit-push-PR-merge cycle end-to-end
- CI fails and you want Claude to automatically diagnose and fix it

**What it does:**

```
Check status → Commit + Push → Create PR → Watch CI → CI passed? → Merge + Cleanup
                                                         ↓ no
                                                    Diagnose + Fix → retry (max 3x)
```

1. Stages and commits changes with a descriptive message
2. Pushes and creates a PR (or uses an existing one)
3. Watches CI — waits for checks to appear and pass (never merges blindly)
4. On CI failure: reads logs, diagnoses the error, fixes code, and retries (up to 3 attempts)
5. Squash-merges on green CI, deletes the branch, and checks out main

**Key safety features:**
- Never merges when CI shows "no checks reported" (checks haven't loaded yet)
- Never force pushes or uses destructive git commands
- Escalates to you after 3 failed fix attempts

---

### `/debugmode` — Hypothesis-Driven Debugging

> **[View SKILL.md](skills/debugmode/SKILL.md)**

A systematic debugging workflow that collects runtime evidence before proposing fixes. No more guessing — instrument, observe, then fix.

**When to use:**
- Encountering a bug you can't figure out from reading code alone
- Tests pass but production behavior is wrong
- Race conditions, flaky tests, or intermittent failures
- You want a structured approach instead of trial-and-error

**What it does:**

```
Safety (branch + stash) → Hypothesize (3-5 theories) → Reproduce (commit test)
    → Instrument (tagged debug logs) → Observe (background agent analysis)
    → git restore . (clean) → Fix → Red-to-green verify → Document
```

1. **Safety first** — creates a debug branch and stashes uncommitted work
2. **Hypothesizes** — generates 3-5 ranked theories about the root cause
3. **Reproduces** — writes and commits a reproduction test/script
4. **Instruments** — adds tagged debug logs (`[DEBUG-MODE][H1:slug]`) to the working tree
5. **Observes** — runs reproduction, collects logs, uses background agents to analyze evidence
6. **Cleans up** — `git restore .` removes all instrumentation (safe because repro test was committed)
7. **Fixes** — applies a targeted fix based on evidence, then verifies red-to-green

**Core principle:** Never propose a fix without runtime evidence.

**Supports:** TypeScript/JS, Python, Go, Ruby, PHP — with language-specific debug patterns for each.

---

### `/code-review` — Parallel Agent Code Review

> **[View SKILL.md](skills/code-review/SKILL.md)**

Dispatches 5 specialist agents in parallel to perform a deep, evidence-based code review of **any codebase**. Auto-detects your tech stack (language, framework, ORM, test framework) and adapts each agent's checks accordingly. Every finding must cite real file paths and line numbers — no guessing.

**When to use:**
- Before creating a PR
- Periodic codebase health checks
- Auditing database queries, API reliability, security, test quality, or performance
- Before major releases

**What it does:**

Launches 5 parallel review agents simultaneously:

| Agent | Focus Area |
|-------|-----------|
| Database & Data Layer Analyst | N+1 queries, over-fetching, missing indexes, transaction usage, connection management, caching |
| API & Service Reliability Analyst | Error consistency, external service failure handling, input validation, rate limiting, timeouts |
| Security Auditor | Auth bypass, authorization gaps, injection vulnerabilities, secret management, CORS, dependency CVEs |
| Test Quality Inspector | Coverage gaps, mock fidelity, test isolation, assertion quality, flakiness risk |
| Performance & Reliability Analyst | Memory management, concurrency control, background job isolation, resource exhaustion, async patterns |

Findings are synthesized into a single report organized by severity (Critical > Warning > Info).

**Works with any stack** — the skill auto-detects your project type from `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, etc. and tailors each agent's review accordingly.

---

## Installation

### Option 1: Global Install (all projects)

```bash
git clone https://github.com/ChiFungHillmanChan/shipwright.git
cp -r shipwright/skills/* ~/.claude/skills/
```

### Option 2: Project-Level Install (single project)

```bash
# From your project root
mkdir -p .claude/skills
cp -r /path/to/shipwright/skills/ship-it .claude/skills/
```

### Option 3: Install via Plugin Marketplace

```
/plugin marketplace add ChiFungHillmanChan/shipwright
/plugin install ship-it@shipwright
```

### Verify Installation

Start a new Claude Code session and invoke the skill:

```
/ship-it
/debugmode
/code-review
```

If the skill appears in the autocomplete list, it's installed correctly.

## Customization

Each skill is a single `SKILL.md` file with YAML frontmatter and markdown content:

```yaml
---
name: my-skill
description: When Claude should trigger this skill
---

# Workflow content here...
```

**To customize:**

1. **Edit the `description`** — controls when Claude auto-triggers the skill
2. **Edit the workflow** — modify steps, add project-specific paths, change conventions
3. **Fork a skill** — copy a directory, rename it, and adapt to your needs

## How Claude Skills Work

| Concept | Description |
|---------|-------------|
| **Global skills** (`~/.claude/skills/`) | Available in all projects |
| **Project skills** (`.claude/skills/`) | Available only in that project |
| **Frontmatter** | `name` and `description` control discovery and auto-triggering |
| **Rigid skills** | Strict step-by-step workflows (debugmode, ship-it) — follow exactly |
| **Flexible skills** | Reference patterns to adapt — use as needed |

For more details, see the official [Claude Code Skills documentation](https://docs.anthropic.com/en/docs/claude-code/skills).

## Publishing to the Marketplace

Want to distribute your skills as a Claude Code plugin marketplace? Here's how.

### Step 1: Structure as a Plugin

Each skill needs a `plugin.json` manifest:

```
shipwright/
├── .claude-plugin/
│   └── marketplace.json       # Marketplace catalog
├── plugins/
│   └── ship-it/
│       ├── .claude-plugin/
│       │   └── plugin.json    # Plugin manifest
│       └── skills/
│           └── ship-it/
│               └── SKILL.md
└── README.md
```

**`plugin.json`** for each plugin:

```json
{
  "name": "ship-it",
  "description": "Full ship workflow — commit, push, PR, watch CI, fix failures, merge",
  "version": "1.0.0"
}
```

### Step 2: Create `marketplace.json`

Place this at `.claude-plugin/marketplace.json`:

```json
{
  "name": "shipwright",
  "owner": {
    "name": "Hillman Chan"
  },
  "metadata": {
    "description": "Production-tested skills for shipping, debugging, and code review"
  },
  "plugins": [
    {
      "name": "ship-it",
      "source": "./plugins/ship-it",
      "description": "Full ship workflow from commit to merged PR",
      "version": "1.0.0",
      "keywords": ["git", "ci", "shipping", "pr", "merge"],
      "category": "development"
    },
    {
      "name": "debugmode",
      "source": "./plugins/debugmode",
      "description": "Hypothesis-driven debugging with runtime instrumentation",
      "version": "1.0.0",
      "keywords": ["debugging", "testing", "instrumentation"],
      "category": "development"
    },
    {
      "name": "code-review",
      "source": "./plugins/code-review",
      "description": "5-agent parallel code review for any codebase",
      "version": "1.0.0",
      "keywords": ["review", "security", "performance", "testing", "database"],
      "category": "development"
    }
  ]
}
```

### Step 3: Validate and Publish

```bash
# Validate your marketplace structure
claude plugin validate .

# Push to GitHub
git push origin main
```

### Step 4: Users Install Your Marketplace

```bash
# Users add your marketplace
/plugin marketplace add ChiFungHillmanChan/shipwright

# Then install individual plugins
/plugin install ship-it@shipwright
/plugin install debugmode@shipwright
/plugin install code-review@shipwright
```

### Submit to the Official Directory

To get maximum visibility, submit your plugin to [Anthropic's official plugin directory](https://github.com/anthropics/claude-plugins-official):

1. Ensure your plugin meets quality and security standards
2. Submit via the [plugin directory submission form](https://clau.de/plugin-directory-submission)
3. Approved plugins appear in the `external_plugins/` directory of the official repo

### Get Listed on Awesome Lists

Submit your skills to community-curated lists for more exposure:

- [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) — 9.3k stars, the largest curated list
- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) — skills, hooks, plugins, and tools
- [awesome-claude-plugins](https://github.com/Chat2AnyLLM/awesome-claude-plugins) — marketplace and plugin directory

## Skills vs Other Approaches

| Feature | Skills | Prompts | MCP Servers | Hooks |
|---------|--------|---------|-------------|-------|
| Multi-step workflows | Yes | No | No | No |
| Background agents | Yes | No | No | No |
| Auto-triggering | Yes (via description) | No | No | Yes (via events) |
| Reusable across projects | Yes | Partially | Yes | Yes |
| External tool access | Via Claude's tools | No | Yes | Yes |
| No code required | Yes (markdown only) | Yes | No | No |

## Contributing

1. Fork this repo
2. Add your skill in `skills/<skill-name>/SKILL.md`
3. Follow the [SKILL.md format](#customization) with frontmatter
4. Submit a PR with a description of when and why to use the skill

## Related Resources

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Code Skills Guide](https://docs.anthropic.com/en/docs/claude-code/skills)
- [Plugin Marketplace Guide](https://code.claude.com/docs/en/plugin-marketplaces)
- [Create Plugins](https://code.claude.com/docs/en/plugins)
- [Official Plugin Directory](https://github.com/anthropics/claude-plugins-official)
- [Superpowers Plugin](https://github.com/obra/superpowers) — 20+ battle-tested skills framework
- [awesome-claude-skills](https://github.com/travisvn/awesome-claude-skills) — curated list of 9.3k+ stars

## License

MIT
