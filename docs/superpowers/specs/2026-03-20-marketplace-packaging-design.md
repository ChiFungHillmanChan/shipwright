# Shipwright: Marketplace Packaging Design

## Goal

Restructure the Shipwright repo from loose skill files into a properly packaged Claude Code plugin, following the Superpowers plugin structure as the reference model. Clean up the README to be user-facing only.

## Scope

Three file changes total:
1. **Add** `.claude-plugin/marketplace.json`
2. **Add** `package.json`
3. **Rewrite** `README.md`

No changes to skills, assets, LICENSE, or .gitignore.

## Reference Model

Superpowers plugin at `~/.claude/plugins/cache/claude-plugins-official/superpowers/5.0.5/` uses this structure:

```
superpowers/
├── .claude-plugin/
│   └── marketplace.json
├── skills/
│   └── <skill-name>/SKILL.md
├── package.json
└── README.md
```

Shipwright will mirror this exactly.

## 1. `.claude-plugin/marketplace.json`

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

## 2. `package.json`

Minimal package descriptor matching the Superpowers pattern:

```json
{
  "name": "shipwright",
  "version": "1.0.0",
  "type": "module"
}
```

## 3. README Rewrite

### Content to KEEP (condensed)
- Plugin name + tagline + badges
- Demo GIF
- Skills overview table
- Skill descriptions (ship-it, debugmode, code-review) — shortened from current verbose versions
- Installation instructions (global, per-project, marketplace)
- Verify installation section
- Contributing section (condensed)
- License

### Content to REMOVE
- Lines 209-303: "Publishing to the Marketplace" section (how to build plugins — not user-facing)
- Lines 305-319: "Get Listed on Awesome Lists" section (promotional)
- Lines 321-331: "Skills vs Other Approaches" comparison table (educational, not user-facing)
- Lines 339-347: "Related Resources" section (link dump)
- Lines 15: "What are skills?" explainer block quote (users don't need this)
- Lines 178-206: "Customization" and "How Claude Skills Work" sections (plugin-building guidance)

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

## Success Criteria

- Plugin can be installed via `claude plugin add` from the GitHub repo
- `marketplace.json` follows the same schema as Superpowers
- README accurately describes what the plugin does without teaching plugin development
- No promotional or self-referential content in README
- All three skills remain functional and unchanged
