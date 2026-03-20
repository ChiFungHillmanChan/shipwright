---
name: code-review
description: Comprehensive code review using 5 parallel specialist agents. Use this skill when reviewing code quality, doing code review, auditing database queries, checking API reliability, security hardening, test quality, or backend performance. Trigger whenever the user mentions "code review", "review my code", "audit", "check quality", "review PR", "review changes", or any quality/security/performance concern — even if they don't explicitly say "code review".
---

# Code Review — 5-Agent Parallel Audit

This skill dispatches 5 parallel specialist agents to perform a deep, evidence-based code review of any codebase. Every finding must cite real file paths and line numbers. No guessing, no assumptions — only what the code actually shows.

## How It Works

You dispatch 5 agents in parallel. Each agent focuses on one domain. When all agents complete, you synthesize their findings into a single report organized by severity (Critical > Warning > Info).

## Pre-flight

Before dispatching agents, determine the review scope and project context:

1. **Detect project type**: Read `package.json`, `requirements.txt`, `go.mod`, `Cargo.toml`, or equivalent to understand the tech stack (language, framework, ORM, test framework).
2. **Determine review scope**:
   - **Changed files scope**: Run `git diff --name-only main...HEAD` and `git status --short` to identify what changed.
   - **Full audit scope**: If the user asks for a full review (or doesn't specify), review the entire source directory.
3. **Identify key directories**: Find the main source directories (e.g., `src/`, `lib/`, `app/`, `server/`), test directories, and config files.
4. Share the scope, tech stack, and directory layout with each agent so they focus appropriately.

## Agent Dispatch

Launch all 5 agents in a single message (parallel). Each agent is a `general-purpose` subagent with read-only intent (research only, no code changes).

**IMPORTANT**: In each agent prompt below, replace `{PROJECT_ROOT}` with the actual project path, `{SCOPE}` with the review scope, and `{TECH_STACK}` with the detected tech stack.

### Agent 1: Database & Data Layer Analyst

```
You are reviewing the codebase at {PROJECT_ROOT} for database and data layer quality.

SCOPE: {SCOPE}
TECH STACK: {TECH_STACK}

Read every file that interacts with the database (ORM models, queries, repositories, data access layers). For each file, check:

1. **N+1 query patterns**: Queries inside loops, repeated fetches for data already available in scope. Look for lazy-loaded relationships triggered in iteration.

2. **Over-fetching**: Are queries fetching entire records when only 2-3 fields are needed? Check if field selection/projection is used appropriately.

3. **Missing indexes**: Are there queries filtering or sorting on columns that likely lack indexes? Check WHERE clauses, ORDER BY, and JOIN conditions against schema definitions.

4. **Transaction usage**: Are transactions used where needed (concurrent writes to related tables)? Are they overused where a simple query would suffice?

5. **Connection management**: Is the connection pool configured? Are connections released properly? Look for potential connection leaks in error paths.

6. **Caching opportunities**: Data that rarely changes (configuration, pricing, categories) should be cached. Check for repeated identical queries on the same request cycle.

7. **Batch operations**: Large dataset processing should use cursor-based pagination or streaming, not loading all records into memory. Check cron jobs, background workers, and migration scripts.

Output format — for each finding:
- File path and line number(s)
- The actual code snippet (copy it)
- What the problem is
- Severity: CRITICAL / WARNING / INFO
- Suggested fix (concrete, not vague)
```

### Agent 2: API & Service Reliability Analyst

```
You are reviewing the API layer at {PROJECT_ROOT} for service reliability and error handling.

SCOPE: {SCOPE}
TECH STACK: {TECH_STACK}

Review every route handler, controller, and service endpoint. Check:

1. **Error response consistency**: Do all error responses follow a consistent format? Check if any route returns raw strings, missing error codes, or inconsistent shapes. There should be a standardized error response helper used everywhere.

2. **External service failure handling**: When external APIs (AI services, payment providers, email services, etc.) are down or return errors:
   - Does the code surface clear errors to the caller?
   - Is there retry logic with exponential backoff for transient errors (429, 500, 502, 503)?
   - Are non-retryable errors (401, 400) immediately returned without retry?

3. **Input validation completeness**: Every endpoint accepting user input must validate before processing. Check for routes that access request body/query fields without validation (Zod, Joi, class-validator, or manual checks).

4. **Rate limiting**: Is rate limiting applied consistently across public endpoints? Check if any route bypasses the rate limiter.

5. **Timeout and resource cleanup**:
   - Do long-running operations have timeouts?
   - Are temp files, streams, and connections cleaned up on error paths (finally blocks)?
   - Are external API calls wrapped with timeouts?

6. **HTTP status codes**: Are routes returning appropriate codes? (400 for bad input, 401 for auth, 403 for forbidden, 404 for not found, 500 for server errors). Check for generic 500s that should be specific.

7. **Health check endpoint**: Is there a health check route for monitoring? Does it verify downstream dependencies (database, cache, external services)?

Output format — for each finding:
- File path and line number(s)
- The actual code snippet
- What the problem is
- Severity: CRITICAL / WARNING / INFO
- Suggested fix
```

### Agent 3: Security Auditor

```
You are performing a security audit of the codebase at {PROJECT_ROOT}.

SCOPE: {SCOPE}
TECH STACK: {TECH_STACK}

Check:

1. **Authentication bypass risks**:
   - Can any authenticated route be accessed without valid credentials?
   - Are there routes that check auth but don't return early on failure?
   - Do all protected route handlers enforce authentication at the top before any business logic?

2. **Authorization gaps**:
   - Can users access resources belonging to other users/organizations?
   - Are resource ownership checks performed on every CRUD operation?
   - Is role-based access control enforced consistently?

3. **Injection vulnerabilities**:
   - SQL injection: Are there raw queries without parameterization?
   - NoSQL injection: Are there dynamic keys in query filters from user input?
   - XSS: Are user-provided strings sanitized before rendering in HTML responses?
   - Command injection: Is user input ever passed to shell commands?
   - Path traversal: Can malicious filenames escape intended directories?

4. **Secret management**:
   - Are secrets (API keys, connection strings, tokens) ever logged, included in error responses, or exposed in stack traces?
   - Check all logging calls for secret leakage.
   - Are environment variables accessed safely?

5. **Cryptographic practices**:
   - Is password hashing using a strong algorithm (bcrypt, argon2, scrypt) — not MD5 or SHA-1?
   - Is timing-safe comparison used for all secret/token comparisons?
   - Is `crypto.randomBytes` (or equivalent) used for security-sensitive random values — not `Math.random`?

6. **Data exposure**:
   - Do API responses include fields that shouldn't be exposed (internal IDs, hashed tokens, admin flags, other users' data)?
   - Error responses: Do they leak stack traces or internal paths in production?

7. **CORS and security headers**: Is CORS properly configured? Check for overly permissive origins (`*`). Are security headers set (CSP, X-Frame-Options, etc.)?

8. **Dependency vulnerabilities**: Check dependency files for known vulnerable packages.

Output format — for each finding:
- File path and line number(s)
- The actual code snippet
- What the vulnerability is and its real-world impact
- Severity: CRITICAL / WARNING / INFO
- Suggested fix with code
```

### Agent 4: Test Quality Inspector

```
You are auditing the test suite at {PROJECT_ROOT} for quality and coverage gaps.

SCOPE: {SCOPE}
TECH STACK: {TECH_STACK}

Read every test file and evaluate:

1. **Coverage gaps**:
   - Compare source files against test files — what's untested?
   - Are error paths tested (not just happy paths)?
   - Are boundary conditions tested (empty arrays, null inputs, max values, zero, negative numbers)?
   - Are external service failure scenarios tested?

2. **Mock fidelity**:
   - Do mocks accurately represent real dependency behavior?
   - Are there mocks that always return success? There should be matching failure-path tests.
   - Watch for overly broad mocks that mask real behavior.

3. **Test isolation**:
   - Is state properly reset between tests (beforeEach/afterEach cleanup)?
   - Can test order affect results? Look for shared mutable state.
   - Are there tests that depend on previous tests having run?

4. **Assertion quality**:
   - Are assertions specific enough? (`toBeTruthy()` is weak; `toBe(200)` is better)
   - Are there tests with no assertions (just checking code doesn't throw)?
   - Do tests verify the right thing (behavior vs implementation details)?

5. **Hardcoded test values**:
   - Are expected values independently derived or just copied from the implementation?
   - Check for magic numbers without explanation.

6. **Test naming and organization**:
   - Do describe/it blocks clearly state what's being tested and expected behavior?
   - Pattern: "should [expected behavior] when [condition]"
   - Are tests grouped logically by feature/function?

7. **Flakiness risk**:
   - Tests depending on timing, network, or file system order
   - Non-deterministic data (random values without seeding)
   - Date/time sensitive tests without mocked clocks

Output format — for each finding:
- Test file path and line number(s)
- The actual test code snippet
- What the problem is
- Severity: CRITICAL / WARNING / INFO
- Suggested fix with improved test code
```

### Agent 5: Performance & Reliability Analyst

```
You are reviewing the codebase at {PROJECT_ROOT} for performance issues and service stability.

SCOPE: {SCOPE}
TECH STACK: {TECH_STACK}

Check:

1. **Memory management**:
   - Are large files/datasets loaded entirely into memory or streamed?
   - Are temp files cleaned up in finally blocks?
   - Large batch operations: Do they process all records at once or in bounded batches?
   - Check for memory leaks: growing arrays, caches without eviction, event listeners not cleaned up.

2. **Concurrency control**:
   - Are there race conditions where two concurrent requests could corrupt shared state?
   - Are counters/limits enforced atomically (not read-check-write patterns)?
   - Are database locks or transactions used where needed for concurrent writes?

3. **Background job isolation**:
   - Can a stuck background job block all processing?
   - Do long-running operations have timeouts?
   - Are background jobs idempotent (safe to retry if they fail mid-execution)?
   - Is there a stuck job detector or dead letter queue?

4. **Resource exhaustion prevention**:
   - File upload size limits: enforced server-side (not just client-side)?
   - Rate limiting correctness: Can it be bypassed?
   - Database connection pool: sized appropriately?
   - Are there unbounded loops, recursion, or queue growth?

5. **Unnecessary work**:
   - Redundant API calls (calling the same external service multiple times for the same data)?
   - Expensive operations in hot paths that could be memoized or cached?
   - Synchronous operations that could be async/parallel?

6. **Async patterns**:
   - Are errors from fire-and-forget operations silently swallowed?
   - Are Promises/futures properly awaited? Look for missing await keywords.
   - Check for proper use of parallel execution (Promise.all / gather) vs unnecessary sequential awaits.

7. **Logging & observability**:
   - Are errors logged with enough context to debug (request ID, user ID, input that caused failure)?
   - Are there log statements in hot loops that could flood log storage?
   - Is there structured logging or just string concatenation?

Output format — for each finding:
- File path and line number(s)
- The actual code snippet
- What the problem is and its real-world impact
- Severity: CRITICAL / WARNING / INFO
- Suggested fix
```

## Synthesizing the Report

After all 5 agents complete, combine their findings into a single report.

### Report Structure

```markdown
# Code Review Report

**Scope:** {scope description}
**Tech Stack:** {detected tech stack}
**Date:** {date}

## Critical Issues
{All CRITICAL findings from all agents, grouped by domain}

## Warnings
{All WARNING findings from all agents, grouped by domain}

## Suggestions
{All INFO findings from all agents, grouped by domain}

## Summary
- Critical: X issues
- Warnings: X issues
- Suggestions: X issues
- {1-2 sentence overall assessment}
```

### Rules for the Final Report

1. **Every finding must have a real file path and line number.** If an agent reports something without citing code, drop it from the report.
2. **No guessing.** If an agent says "this might be a problem" without showing the actual code, exclude it.
3. **No filler.** Don't pad the report with obvious advice like "add more tests" without specifying exactly which functions lack coverage.
4. **Deduplicate.** If multiple agents flag the same issue, consolidate into one finding.
5. **Be honest.** If the code is good in an area, say so. Don't manufacture problems.

## When to Use This Skill

- After completing a feature branch, before PR
- When asked to review code quality
- When debugging production issues related to performance or reliability
- Periodic health checks of the codebase
- Before major releases
