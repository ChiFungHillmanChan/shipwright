---
name: evoke-code-review
description: Comprehensive code review for the lattice-evoke SEN assessment platform. Use this skill when reviewing code quality, doing code review, auditing database queries, checking API reliability, security hardening, test quality, or backend performance in the lattice-evoke repo. Trigger whenever the user mentions "code review", "review my code", "audit", "check quality", "review PR", "review changes", or any quality/security/performance concern about the evoke codebase — even if they don't explicitly say "code review".
---

# Evoke Code Review — Agent Team Audit

This skill dispatches 5 parallel specialist agents to perform a deep, evidence-based code review of the lattice-evoke server codebase. Every finding must cite real file paths and line numbers. No guessing, no assumptions — only what the code actually shows.

**All summary output to the user must be in Cantonese (廣東話).** Technical terms (file names, function names, error codes) stay in English.

## How It Works

You dispatch 5 agents in parallel. Each agent focuses on one domain. When all agents complete, you synthesize their findings into a single Cantonese report organized by severity (Critical → Warning → Info).

## Pre-flight

Before dispatching agents, determine the review scope:

1. **Changed files scope**: Run `git diff --name-only main...HEAD` and `git status --short` to identify what changed
2. **Full audit scope**: If the user asks for a full review (or doesn't specify), review the entire `server/` directory
3. Share the scope with each agent so they focus appropriately

## Agent Dispatch

Launch all 5 agents in a single message (parallel). Each agent is a `general-purpose` subagent with read-only intent (research only, no code changes).

### Agent 1: Database Query Analyst (資料庫查詢分析員)

```
You are reviewing the lattice-evoke server codebase at /Users/hillmanchan/Desktop/lattice-evoke/server for database query quality.

SCOPE: {changed files or "full audit"}

Your job is to find real problems in how Prisma is used. Read every file that imports from '@prisma/client' or uses the `prisma` singleton. For each file, check:

1. **Unnecessary queries**: Are there queries that fetch data already available in scope? Are there duplicate findMany/findFirst calls that could be combined? Look for N+1 patterns (queries inside loops).

2. **Missing select/include optimization**: Are routes fetching entire records when they only need 2-3 fields? Check if `.select()` is used appropriately. Fetching `select: { id: true, name: true }` instead of the full row matters for performance.

3. **Missing caching opportunities**:
   - Server actions called from dashboard pages — if a user switches tabs and comes back, does the same query fire again? Look at components that call server actions on mount without caching.
   - Data that rarely changes (pricing, configuration, store names) should be cached in-memory or via React Query/SWR on the client side.
   - Check if `file-search-stores.ts` in-memory cache is properly invalidated.

4. **Transaction usage**: Are transactions used where needed (concurrent writes)? Are they overused where a simple query would suffice? Check isolation levels — Serializable is expensive and should only be used when truly needed.

5. **Query patterns in cron jobs**: Batch processing should use cursor-based pagination, not offset. Check `usage-aggregation.ts`, `invoice-generation.ts`, `archive-usage` for large dataset handling.

Key files to examine:
- lib/prisma.ts
- lib/usage-tracking.ts, lib/usage-retry.ts, lib/usage-aggregation.ts
- lib/billing/usage-daily-aggregation.ts
- lib/invoice-generation.ts
- All files in app/api/v1/
- All files in app/actions/
- lib/file-search-stores.ts (in-memory cache pattern)

Output format — for each finding:
- File path and line number(s)
- The actual code snippet (copy it)
- What the problem is
- Severity: CRITICAL / WARNING / INFO
- Suggested fix (concrete, not vague)
```

### Agent 2: API Service Reliability Analyst (API 服務可靠性分析員)

```
You are reviewing the lattice-evoke server API routes at /Users/hillmanchan/Desktop/lattice-evoke/server for service reliability and error handling.

SCOPE: {changed files or "full audit"}

This is a B2B API service — external systems depend on it for video analysis. Downtime, unclear errors, or silent failures damage trust. Review every route under app/api/v1/ and check:

1. **Error response consistency**: Every error must return the standardized format:
   { "success": false, "error": { "code": "ERROR_CODE", "message": "human-readable" } }
   Check if any route returns raw strings, missing codes, or inconsistent shapes. The apiError() helper from lib/api-error-codes.ts should be used everywhere.

2. **Gemini API failure handling**: When Gemini API is down or the API key is invalid/expired:
   - Does the analysis route surface a clear error to the caller?
   - Is there retry logic with exponential backoff for transient errors (429, 500, 502, 503)?
   - Are non-retryable errors (401 invalid key, 400 bad request) immediately returned without retry?
   - Check lib/gemini.ts, lib/analysis-processor.ts for error handling paths.

3. **Service availability signals**:
   - Is there a health check endpoint? (GET /api/v1/health or similar)
   - Do routes return appropriate HTTP status codes? (400 vs 500 vs 503)
   - When the database is down, what happens? Does the error leak internal details?

4. **Input validation completeness**: Every POST/PATCH route must validate input with Zod before processing. Check for routes that access request body fields without validation.

5. **Rate limiting gaps**: Is rate limiting applied consistently? Check if any route bypasses the rate limiter. Look at the sliding window implementation in api-key-auth.ts for correctness.

6. **Timeout and resource cleanup**:
   - Do long-running operations (video upload, Gemini calls) have timeouts?
   - Are temp files cleaned up on error paths? Check analysis-processor.ts cleanup logic.
   - Are Gemini file uploads always deleted after processing, even on failure?

7. **API versioning and backwards compatibility**: Routes are under /v1/. Check if any breaking changes were introduced without versioning.

Key files:
- All routes in app/api/v1/
- lib/api-error-codes.ts
- lib/api-key-auth.ts
- lib/gemini.ts
- lib/analysis-processor.ts
- lib/analysis-request.ts

Output format — for each finding:
- File path and line number(s)
- The actual code snippet
- What the problem is
- Severity: CRITICAL / WARNING / INFO
- Suggested fix
```

### Agent 3: Security Auditor (安全審計員)

```
You are performing a production security audit of the lattice-evoke server at /Users/hillmanchan/Desktop/lattice-evoke/server.

SCOPE: {changed files or "full audit"}

This is a SEN (Special Educational Needs) platform handling sensitive student data. Security failures have real consequences. Check:

1. **Authentication bypass risks**:
   - Can any authenticated route be accessed without valid credentials?
   - Are there routes that check auth but don't return early on failure?
   - Check all route handlers: do they ALL call validateApiKeyAuth() or validateUnifiedAuth() at the top?
   - Cron routes: is x-cron-secret validated with timing-safe comparison?

2. **Authorization gaps**:
   - Knowledge Layer access: Can Layer A (global) be written by non-super-admins?
   - Can users access analysis jobs from other organizations?
   - API key scope enforcement: If a key has scope ["analysis"], can it access /knowledge/?
   - Check lib/knowledge-access.ts, lib/api-key-ownership.ts

3. **Injection vulnerabilities**:
   - SQL injection via Prisma: Are there any raw queries (prisma.$queryRaw) without parameterization?
   - NoSQL injection: Are there dynamic keys in Prisma where clauses from user input?
   - XSS: Are user-provided strings (document titles, analysis reports) sanitized before storage/display?
   - Path traversal: File upload paths — can a malicious filename escape the intended directory?

4. **Secret management**:
   - Are secrets (API keys, connection strings) ever logged, included in error responses, or exposed in stack traces?
   - Check console.log/console.error calls for secret leakage
   - Are environment variables accessed safely (not at module level where they'd be undefined)?

5. **Cryptographic practices**:
   - API key hashing: Is HMAC-SHA256 used correctly? Check lib/api-keys.ts
   - Token comparison: Is timing-safe comparison used for all secret comparisons?
   - Random generation: Is crypto.randomBytes used (not Math.random) for security-sensitive values?

6. **Data exposure**:
   - Do API responses include fields that shouldn't be exposed (internal IDs, hashed tokens, admin flags)?
   - Check .select() usage — are routes returning minimal data?
   - Error responses: Do they leak stack traces or internal paths in production?

7. **CORS and headers**: Check if CORS is properly configured. Check for missing security headers (CSRF protection, etc.)

8. **Dependency vulnerabilities**: Check package.json for known vulnerable packages.

Key files:
- lib/api-key-auth.ts, lib/api-keys.ts
- lib/unifiedAuth.ts, lib/cron-auth.ts
- lib/knowledge-access.ts, lib/api-key-ownership.ts
- lib/permissions.ts
- All route handlers in app/api/v1/
- package.json

Output format — for each finding:
- File path and line number(s)
- The actual code snippet
- What the vulnerability is and its real-world impact
- Severity: CRITICAL / WARNING / INFO
- Suggested fix with code
```

### Agent 4: Test Quality Inspector (測試品質檢查員)

```
You are auditing the test suite at /Users/hillmanchan/Desktop/lattice-evoke/server/__tests__/ against industry standards (Amazon, Microsoft, Google testing practices).

SCOPE: {changed files or "full audit"}

Read every test file and evaluate against these criteria:

1. **Hardcoded test values**:
   - Are expected values computed from the same logic as the source, or independently derived?
   - Check pricing.test.ts — does it recalculate expected costs or just hardcode magic numbers?
   - Tests should verify behavior, not implementation details. A test that checks `expect(result).toBe(42)` is only good if 42 was independently computed.

2. **Mock fidelity**:
   - Do mocks accurately represent the real dependency's behavior?
   - Check if Prisma mocks return realistic shapes (all required fields present)
   - Are there mocks that always return success? There should be matching failure-path tests.
   - Watch for `vi.fn().mockResolvedValue(undefined)` used where the real function returns data.

3. **Test isolation**:
   - Does `beforeEach` call `vi.clearAllMocks()` or `vi.resetAllMocks()`?
   - Can test order affect results? Look for shared mutable state between tests.
   - Are there tests that depend on previous tests having run?

4. **Missing test coverage**:
   - Compare every file in lib/ and app/api/v1/ against __tests__/ — what's untested?
   - Are error paths tested? (not just happy paths)
   - Are boundary conditions tested? (empty arrays, null inputs, max values)
   - Specifically check: Are there tests for Gemini API failures, Azure Blob failures, network timeouts?

5. **Test naming and organization**:
   - Do describe/it blocks clearly state what's being tested and what the expected behavior is?
   - Follow the pattern: "should [expected behavior] when [condition]"
   - Are tests grouped logically by feature/function?

6. **Assertion quality**:
   - Are assertions specific enough? `expect(result).toBeTruthy()` is weak; `expect(result.status).toBe(200)` is better.
   - Are there tests with no assertions (just checking that code doesn't throw)?
   - Do tests verify the right thing? (testing behavior vs testing implementation)

7. **Industry standard patterns**:
   - Amazon: Tests should be deterministic, fast, and independent
   - Google: Tests should be clear, complete, and concise (the "test pyramid")
   - Microsoft: Tests should cover security boundaries and data validation

Key directories:
- __tests__/lib/ (unit tests)
- __tests__/app/api/ (route tests)
- __tests__/app/actions/ (server action tests)
- Compare against: lib/, app/api/v1/, app/actions/

Output format — for each finding:
- Test file path and line number(s)
- The actual test code snippet
- What the problem is
- Severity: CRITICAL / WARNING / INFO
- Suggested fix with improved test code
```

### Agent 5: Backend Performance Analyst (後端效能分析員)

```
You are reviewing the lattice-evoke server at /Users/hillmanchan/Desktop/lattice-evoke/server for performance issues and service stability.

SCOPE: {changed files or "full audit"}

This is a production SaaS platform. A single runaway job should never take down the entire service. Check:

1. **Cron job isolation**:
   - process-analysis cron: Does it process jobs sequentially or could a stuck job block all processing?
   - What happens if a Gemini API call hangs for 10 minutes? Is there a timeout?
   - Check the CronLock pattern — what's the lock duration? Can it deadlock if the process crashes mid-job?
   - Are cron jobs idempotent? If a cron fires twice, does it double-process?

2. **Memory management**:
   - Video processing: Are videos loaded entirely into memory or streamed?
   - Check lib/analysis-processor.ts — how are temp files handled? Are they cleaned up in finally blocks?
   - Large batch operations (usage aggregation): Do they process all records at once or in bounded batches?
   - Check for memory leaks: Are there growing arrays, caches without eviction, or event listeners not cleaned up?

3. **Concurrency control**:
   - School limit (3 concurrent) and global limit (10 concurrent) in analysis/route.ts — is this enforced atomically?
   - What happens under race conditions? Two requests checking limits simultaneously could both pass.
   - Is the Serializable isolation level actually needed, or would ReadCommitted suffice?

4. **Resource exhaustion prevention**:
   - File upload limits: Are they enforced at the route level or only client-side?
   - Rate limiting: Is the sliding window implementation correct? Can it be bypassed with multiple API keys?
   - Database connection pool: Is Prisma connection pool sized appropriately?
   - Are there any unbounded loops or recursion?

5. **Error recovery**:
   - UsageRetryQueue: Does it have a max retry count? What happens to permanently failed events?
   - Analysis jobs: What happens if a job is stuck in 'processing' forever? Is there a stuck job detector?
   - Cleanup: If Azure Blob upload succeeds but Gemini processing fails, is the blob cleaned up?

6. **Unnecessary work**:
   - Are there redundant API calls (calling the same external service multiple times for the same data)?
   - Check if pricing calculations are done repeatedly when they could be memoized.
   - Are there expensive operations in hot paths (e.g., crypto operations on every request that could be cached)?

7. **Async patterns**:
   - Fire-and-forget patterns: Are errors from background operations silently swallowed?
   - Are Promises properly awaited? Look for missing await keywords.
   - Check for proper use of Promise.all vs sequential awaits where parallelism is possible.

Key files:
- app/api/v1/cron/process-analysis/route.ts
- app/api/v1/cron/aggregate/route.ts
- app/api/v1/cron/archive-usage/route.ts
- lib/analysis-processor.ts
- lib/usage-aggregation.ts
- lib/usage-retry.ts
- lib/invoice-generation.ts
- lib/gemini.ts
- lib/azure-blob.ts
- lib/file-search-stores.ts

Output format — for each finding:
- File path and line number(s)
- The actual code snippet
- What the problem is and its real-world impact
- Severity: CRITICAL / WARNING / INFO
- Suggested fix
```

## Synthesizing the Report

After all 5 agents complete, combine their findings into a single report. The report must be in **Cantonese (廣東話)**.

### Report Structure

```markdown
# 🔍 Evoke Code Review 報告

**審查範圍:** {scope description}
**日期:** {date}

## 🔴 嚴重問題 (Critical)
{All CRITICAL findings from all agents, grouped by domain}

## 🟡 警告 (Warning)
{All WARNING findings from all agents, grouped by domain}

## 🔵 建議 (Info)
{All INFO findings from all agents, grouped by domain}

## 📊 總結
- 嚴重問題: X 個
- 警告: X 個
- 建議: X 個
- {1-2 sentence overall assessment in Cantonese}
```

### Rules for the Final Report

1. **Every finding must have a real file path and line number.** If an agent reports something without citing code, drop it from the report.
2. **No guessing.** If an agent says "this might be a problem" without showing the actual code, exclude it.
3. **No filler.** Don't pad the report with obvious advice like "add more tests" without specifying exactly which functions lack coverage.
4. **Deduplicate.** If multiple agents flag the same issue (e.g., missing error handling in analysis-processor.ts), consolidate into one finding.
5. **Be honest.** If the code is good in an area, say so. Don't manufacture problems.
6. **Code snippets stay in English.** Only the descriptions and analysis are in Cantonese.

## When to Use This Skill

- After completing a feature branch, before PR
- When asked to review code quality
- When debugging production issues related to performance or reliability
- Periodic health checks of the codebase
- Before major releases
