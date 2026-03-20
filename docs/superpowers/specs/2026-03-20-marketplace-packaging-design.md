# Shipwright: Marketplace Packaging Design

## Goal

Restructure the Shipwright repo from loose skill files into a properly packaged Claude Code plugin, following the Superpowers plugin structure as the reference model. Clean up the README to be user-facing only.

## Scope

Four file changes total:
1. **Add** `.claude-plugin/plugin.json` — plugin descriptor (required for Claude Code to identify the plugin)
2. **Add** `.claude-plugin/marketplace.json` — marketplace listing metadata
3. **Add** `package.json` — minimal package descriptor
4. **Rewrite** `README.md` — user-facing only

No changes to skills, assets, LICENSE, or .gitignore. No `commands/` directory needed (Superpowers has one but it's deprecated stubs).

## Reference Model

Superpowers plugin at `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.5/` uses this structure:

```
superpowers/
├── .claude-plugin/
│   ├── plugin.json
│   └── marketplace.json
├── skills/
│   └── <skill-name>/SKILL.md
├── package.json
└── README.md
```

Shipwright will mirror this exactly.

## 1. `.claude-plugin/plugin.json`

Plugin descriptor — required for Claude Code to identify and load the plugin.

```json
{
  "name": "shipwright",
  "description": "Ship code, squash bugs, and review PRs — production-tested skills for daily dev workflows"
}
```

## 2. `.claude-plugin/marketplace.json`

Create the marketplace listing file. Single plugin entry (bundled model — all skills in one install).

```json
{
  "name": "shipwright",
  "description": "Ship code, squash bugs, and review PRs — production-tested skills for daily dev workflows",
  "owner": {
    "name": "Hillman Chan",
    "email": "hillmanchan709@gmail.com"
  },
  "plugins": [
    {
      "name": "shipwright",
      "description": "Ship code, squash bugs, and review PRs — production-tested skills for daily dev workflows",
      "version": "1.0.0",
      "source": "./",
      "author": {
        "name": "Hillman Chan",
        "email": "hillmanchan709@gmail.com"
      }
    }
  ]
}
```

## 3. `package.json`

Minimal package descriptor. No `"main"` field needed — Shipwright is skills-only with no executable JS entry point (Superpowers has one for OpenCode support, which we don't need).

```json
{
  "name": "shipwright",
  "version": "1.0.0",
  "type": "module"
}
```

## 4. README Rewrite

### Content to KEEP (condensed)
- Plugin name + tagline + badges
- Demo GIF
- Skills overview table
- Skill descriptions (ship-it, debugmode, code-review) — shortened from current verbose versions
- Installation instructions (global, per-project, marketplace)
- Verify installation section
- Contributing section (condensed)
- License

### Sections to REMOVE
- "Publishing to the Marketplace" — how to build plugins, not user-facing
- "Get Listed on Awesome Lists" — promotional
- "Skills vs Other Approaches" — comparison table, educational not user-facing
- "Related Resources" — link dump
- "What are skills?" block quote after demo GIF — users don't need this
- "Customization" — plugin-building guidance
- "How Claude Skills Work" — plugin-building guidance

### Target structure
```
# Shipwright
[badges]
[tagline]
[nav links]
[demo GIF]

## Skills (table + concise descriptions)
## Install (3 methods + verify)
## Contributing (2-3 lines)
## License
```

Target: ~100-150 lines.

## Final Directory Structure

```
shipwright/
├── .claude-plugin/
│   ├── plugin.json               # NEW
│   └── marketplace.json          # NEW
├── assets/
│   ├── demo.gif
│   └── install-demo.mp4
├── skills/
│   ├── ship-it/
│   │   └── SKILL.md              # unchanged
│   ├── debugmode/
│   │   └── SKILL.md              # unchanged
│   └── code-review/
│       └── SKILL.md              # unchanged
├── .gitignore                    # unchanged
├── LICENSE                       # unchanged
├── package.json                  # NEW
└── README.md                     # REWRITTEN
```

## Out of Scope

- `commands/` directory — Superpowers has one but contents are deprecated stubs redirecting to skills
- `hooks/` directory — no session-start hook needed for Shipwright
- `.opencode/`, `.codex/`, `.cursor-plugin/` — cross-platform support not needed for v1
- GitHub repo rename — the repo is `ChiFungHillmanChan/shipwright.git`, already correct

## Success Criteria

- Plugin can be installed via `claude plugin add` from the GitHub repo
- Both `plugin.json` and `marketplace.json` follow the same schema as Superpowers
- README accurately describes what the plugin does without teaching plugin development
- No promotional or self-referential content in README
- All three skills remain functional and unchanged
- Validate by running `claude plugin add` against the repo after pushing
