Output assets/demo.gif

Set FontSize 16
Set Width 900
Set Height 500
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 40ms

# Title
Type "# Shipwright — Claude Code Skills"
Enter
Sleep 800ms
Type ""
Enter

# Install
Type "git clone https://github.com/ChiFungHillmanChan/shipwright.git"
Enter
Sleep 600ms
Type "Cloning into 'shipwright'..."
Enter
Sleep 300ms
Type "done."
Enter
Sleep 400ms

Type "cp -r shipwright/skills/* ~/.claude/skills/"
Enter
Sleep 600ms
Type "✓ Installed: ship-it, debugmode, code-review"
Enter
Sleep 1s

Enter
Type "# Now available as slash commands in Claude Code:"
Enter
Sleep 600ms

Enter
Type "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Enter
Type "# /ship-it     → Commit, PR, watch CI, merge"
Enter
Sleep 400ms
Type "# /debugmode    → Hypothesis-driven debugging"
Enter
Sleep 400ms
Type "# /code-review  → 5-agent parallel code review"
Enter
Type "# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
Enter
Sleep 1.5s

Enter
Type "# Example: /ship-it"
Enter
Sleep 500ms
Type "$ claude"
Enter
Sleep 400ms
Type "> /ship-it"
Enter
Sleep 800ms
Type "◐ Staging changes..."
Enter
Sleep 400ms
Type "◐ Creating PR #42: 'fix: resolve auth timeout on login'"
Enter
Sleep 500ms
Type "◐ Watching CI... waiting for checks to appear"
Enter
Sleep 400ms
Type "◐ CI check: lint ✓  typecheck ✓  tests ✓  build ✓"
Enter
Sleep 400ms
Type "◐ All checks passed — squash merging..."
Enter
Sleep 300ms
Type "✓ Merged PR #42, deleted branch, on main"
Enter
Sleep 1.5s

Enter
Type "# Example: /debugmode"
Enter
Sleep 500ms
Type "> /debugmode the login page returns 500 after deploy"
Enter
Sleep 800ms
Type "◐ Safety: created branch debug/login-500, stashed work"
Enter
Sleep 400ms
Type "◐ Scanning project... Next.js + Prisma + PostgreSQL"
Enter
Sleep 400ms
Type "◐ Hypotheses:"
Enter
Sleep 200ms
Type "  H1 (HIGH): Missing env var in production build"
Enter
Sleep 200ms
Type "  H2 (MED):  Prisma client not regenerated after migration"
Enter
Sleep 200ms
Type "  H3 (LOW):  Auth middleware timeout misconfigured"
Enter
Sleep 500ms
Type "◐ Committed reproduction test"
Enter
Sleep 300ms
Type "◐ Instrumenting code with [DEBUG-MODE] tags..."
Enter
Sleep 400ms
Type "◐ Background agent analyzing evidence..."
Enter
Sleep 500ms
Type "◐ H1 CONFIRMED: DATABASE_URL missing in .env.production"
Enter
Sleep 300ms
Type "◐ git restore . → applying fix → red-to-green ✓"
Enter
Sleep 500ms
Type "◐ Starting live monitoring at http://localhost:3000"
Enter
Sleep 300ms
Type "◐ Agent watching server logs... please test the fix"
Enter
Sleep 400ms
Type "✓ No errors detected. User confirmed fix works."
Enter
Sleep 2s

Enter
Type "# Example: /code-review"
Enter
Sleep 500ms
Type "> /code-review"
Enter
Sleep 800ms
Type "◐ Detected: TypeScript + Prisma + Next.js API routes"
Enter
Sleep 400ms
Type "◐ Launching 5 review agents in parallel..."
Enter
Sleep 200ms
Type "  ▸ Database & Data Layer Analyst"
Enter
Sleep 150ms
Type "  ▸ API & Service Reliability Analyst"
Enter
Sleep 150ms
Type "  ▸ Security Auditor"
Enter
Sleep 150ms
Type "  ▸ Test Quality Inspector"
Enter
Sleep 150ms
Type "  ▸ Performance & Reliability Analyst"
Enter
Sleep 800ms
Type "◐ All agents complete. Synthesizing report..."
Enter
Sleep 500ms
Type "  🔴 Critical: 2  🟡 Warning: 5  🔵 Info: 3"
Enter
Sleep 400ms
Type "✓ Code review report generated with file paths + line numbers"
Enter
Sleep 2s

Enter
Type "# github.com/ChiFungHillmanChan/shipwright"
Enter
Sleep 2s
