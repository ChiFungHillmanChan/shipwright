# Shipwright

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Plugin-blueviolet)](https://docs.anthropic.com/en/docs/claude-code)

Production-tested Claude Code skills for the three things every developer does daily: **ship code, squash bugs, and review PRs.**

[`/ship-it`](#ship-it) | [`/debugmode`](#debugmode) | [`/code-review`](#code-review) | [Install](#install)

<p align="center">
  <img src="assets/demo.gif" alt="Shipwright demo — install and run skills" width="800">
</p>

## Skills

| Skill | Description | Use Case |
|-------|-------------|----------|
| [`/ship-it`](skills/ship-it/SKILL.md) | Full ship workflow — commit to merged PR | Done coding, want to ship |
| [`/debugmode`](skills/debugmode/SKILL.md) | Hypothesis-driven debugging with runtime evidence | Hit a bug, need systematic approach |
| [`/code-review`](skills/code-review/SKILL.md) | 5-agent parallel code review | Pre-PR quality check |

---

### `/ship-it`

Automates the entire path from local changes to merged PR. Commit, push, create PR, watch CI, auto-fix failures, merge, and cleanup — all in one command.

```
Check status → Commit + Push → Create PR → Watch CI → CI passed? → Merge + Cleanup
                                                         ↓ no
                                                    Diagnose + Fix → retry (max 3x)
```

- Never merges when CI shows "no checks reported"
- Never force pushes or uses destructive git commands
- Escalates to you after 3 failed fix attempts

---

### `/debugmode`

A systematic debugging workflow that collects runtime evidence before proposing fixes. No more guessing — instrument, observe, then fix.

```
Safety (branch + stash) → Hypothesize (3-5 theories) → Reproduce (commit test)
    → Instrument (tagged debug logs) → Observe (background agent analysis)
    → git restore . (clean) → Fix → Red-to-green verify
    → Live Monitor (agent runs server + watches logs) → User tests at localhost
```

- Commits reproduction test before instrumenting, enabling safe cleanup via `git restore .`
- Background agents analyze debug output and classify hypotheses
- Live monitoring agent launches dev server and watches for errors in real-time
- Supports TypeScript/JS, Python, Go, Ruby, PHP

---

### `/code-review`

Dispatches 5 specialist agents in parallel for a deep, evidence-based code review. Auto-detects your tech stack and adapts accordingly. Every finding cites real file paths and line numbers.

| Agent | Focus |
|-------|-------|
| Database & Data Layer | N+1 queries, missing indexes, transactions, caching |
| API & Service Reliability | Error handling, input validation, rate limiting, timeouts |
| Security Auditor | Auth bypass, injection vulnerabilities, secret management, CORS |
| Test Quality Inspector | Coverage gaps, mock fidelity, test isolation, flakiness risk |
| Performance & Reliability | Memory management, concurrency, resource exhaustion, async patterns |

Findings are synthesized into a single report organized by severity (Critical > Warning > Info).

---

## Install

### Option 1: Plugin Marketplace

```
/install ChiFungHillmanChan/shipwright
```

### Option 2: Global Install

```bash
git clone https://github.com/ChiFungHillmanChan/shipwright.git
cp -r shipwright/skills/* ~/.claude/skills/
```

### Option 3: Project-Level Install

```bash
mkdir -p .claude/skills
cp -r /path/to/shipwright/skills/* .claude/skills/
```

### Verify

Start a new Claude Code session and type `/ship-it`, `/debugmode`, or `/code-review`. If the skill appears in autocomplete, it's installed.

## Contributing

1. Fork this repo
2. Add or modify skills in `skills/<skill-name>/SKILL.md`
3. Submit a PR

## License

MIT
