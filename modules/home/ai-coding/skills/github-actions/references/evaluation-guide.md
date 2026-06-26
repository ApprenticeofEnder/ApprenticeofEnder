# Workflow Evaluation Guide

Framework for evaluating GitHub Actions workflows for security, performance, and best practices.

## Evaluation Framework

Use this systematic approach to evaluate workflows:

1. **Security Analysis** (Critical) - Identify security vulnerabilities
2. **Performance Review** (Important) - Find optimization opportunities
3. **Best Practices Audit** (Recommended) - Check against standards
4. **Maintainability Assessment** (Nice to have) - Evaluate code quality

## Security Analysis

### Critical Security Issues (Must Fix)

**1. GITHUB_TOKEN Permissions**

❌ **FAIL:**

```yaml
# No permissions specified - defaults to permissive
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
```

✅ **PASS:**

```yaml
permissions:
  contents: read # Minimum required

jobs:
  test:
    runs-on: ubuntu-latest
```

**2. Hardcoded Secrets**

❌ **FAIL:**

```yaml
env:
  API_KEY: sk_live_abc123
  DATABASE_URL: postgres://user:password@host/db
```

✅ **PASS:**

```yaml
env:
  API_KEY: ${{ secrets.API_KEY }}
  DATABASE_URL: ${{ secrets.DATABASE_URL }}
```

**3. Unpinned Actions**

❌ **FAIL:**

```yaml
- uses: actions/checkout@main
- uses: some-org/action@latest
- uses: actions/setup-node@v4
```

✅ **PASS:**

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd  # v6.0.2
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
```

**4. Dangerous pull_request_target Usage**

❌ **FAIL:**

```yaml
on: pull_request_target

jobs:
  build:
    steps:
      - uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
        with:
          ref: ${{ github.event.pull_request.head.sha }}
      - run: ./scripts/install-deps.sh && ./scripts/build.sh # Runs untrusted code with secrets!
```

✅ **PASS:**

```yaml
# Use pull_request instead for untrusted code
on: pull_request

# OR only use pull_request_target for trusted actions (no code execution)
on: pull_request_target
jobs:
  label:
    steps:
      # Pinned commit SHA only — no tags or branches
      - uses: actions/labeler@f27b608878404679385c85cfa523b85ccb86e213  # v6.1.0
```

**5. Script Injection**

❌ **FAIL:**

```yaml
- run: echo "Title: ${{ github.event.issue.title }}"
# Vulnerable to command injection
```

✅ **PASS:**

```yaml
- env:
    TITLE: ${{ github.event.issue.title }}
  run: echo "Title: $TITLE"
```

### Important Security Issues (Should Fix)

**1. Long-lived Credentials vs OIDC**

⚠️ **NEEDS IMPROVEMENT:**

```yaml
- uses: aws-actions/configure-aws-credentials@5579c002bb4778aa43395ef1df492868a9a1c83f  # v4.0.2
  with:
    aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
    aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
```

✅ **BETTER:**

```yaml
permissions:
  id-token: write

- uses: aws-actions/configure-aws-credentials@5579c002bb4778aa43395ef1df492868a9a1c83f  # v4.0.2
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActions
    aws-region: us-east-1
```

**2. Environment Protection**

⚠️ **NEEDS IMPROVEMENT:**

```yaml
jobs:
  deploy:
    steps:
      - run: ./deploy-to-production.sh
        env:
          PROD_API_KEY: ${{ secrets.PROD_API_KEY }}
```

✅ **BETTER:**

```yaml
jobs:
  deploy:
    environment: production # Requires manual approval
    steps:
      - run: ./deploy-to-production.sh
        env:
          PROD_API_KEY: ${{ secrets.PROD_API_KEY }}
```

**3. Third-Party Actions**

⚠️ **REVIEW REQUIRED:**

```yaml
- uses: random-user/unknown-action@a1b2c3d4e5f6789012345678901234567890abcd  # v1.0.0
```

**Evaluation checklist:**

- [ ] Verified creator badge?
- [ ] Recent maintenance activity?
- [ ] Source code reviewed?
- [ ] Many stars/users?
- [ ] Known security issues?

### Security Score Calculation (Optional Supplement)

Use this scorecard **only after** [validation-tooling.md](validation-tooling.md) gates pass (actionlint and zizmor report no errors at your configured `--min-severity`). It supplements automated findings with qualitative review — it does not replace tool validation.

| Category                       | Weight | Score     |
| ------------------------------ | ------ | --------- |
| No hardcoded secrets           | 25%    | \_\_\_/25 |
| GITHUB_TOKEN read-only default | 25%    | \_\_\_/25 |
| Actions pinned to full SHA     | 20%    | \_\_\_/20 |
| No dangerous triggers          | 15%    | \_\_\_/15 |
| Input validation               | 10%    | \_\_\_/10 |
| OIDC usage                     | 5%     | \_\_\_/5  |

**Total Security Score: \_\_\_/100**

- **90-100:** Excellent security posture
- **75-89:** Good, minor improvements needed
- **60-74:** Moderate, address important issues
- **<60:** Poor, critical issues must be fixed

## Performance Review

### Performance Metrics

Target execution times:

- **Lint/format:** <2 minutes
- **Unit tests:** <5 minutes
- **Integration tests:** <10 minutes
- **Full CI pipeline:** <15 minutes
- **Deployment:** <10 minutes

### Performance Checklist

**1. Dependency Caching**

❌ **SLOW:**

```yaml
- run: ./install-dependencies.sh  # Downloads every time
```

✅ **FAST:**

```yaml
- uses: actions/cache@1bd1e32a3bdc45362d1e726936510720a7c30a57  # v4.2.0
  with:
    path: ~/.cache/my-tool
    key: ${{ runner.os }}-deps-${{ hashFiles('**/lockfile') }}

- run: ./install-dependencies.sh
```

**Impact:** Can reduce build time significantly when cache hits

**2. Parallelization**

❌ **SLOW:**

```yaml
jobs:
  ci:
    steps:
      - run: ./lint.sh
      - run: ./typecheck.sh
      - run: ./test.sh
      - run: ./build.sh
```

✅ **FAST:**

```yaml
jobs:
  lint:
    steps:
      - run: ./lint.sh

  typecheck:
    steps:
      - run: ./typecheck.sh

  test:
    steps:
      - run: ./test.sh

  build:
    steps:
      - run: ./build.sh

# All jobs run in parallel
```

**3. Selective Triggers**

❌ **WASTEFUL:**

```yaml
on: [push] # Runs on every commit, even doc changes
```

✅ **EFFICIENT:**

```yaml
on:
  push:
    paths:
      - "src/**"
      - "package.json"
    paths-ignore:
      - "**.md"
      - "docs/**"
```

**4. Concurrency Control**

❌ **WASTEFUL:**

```yaml
on: pull_request
# Multiple commits = multiple full runs
```

✅ **EFFICIENT:**

```yaml
on: pull_request

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true # Cancel older runs
```

**5. Shallow Checkout**

❌ **SLOW:**

```yaml
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11  # v4.1.1
  with:
    fetch-depth: 0  # Full history — only needed for specific cases
```

✅ **FAST:**

```yaml
- uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd  # v6.0.2
  # fetch-depth: 1 is default — only latest commit
```

### Performance Score Calculation

| Optimization                     | Implemented? | Impact | Points    |
| -------------------------------- | ------------ | ------ | --------- |
| Dependency caching               | Yes/No       | High   | \_\_\_/30 |
| Job parallelization              | Yes/No       | High   | \_\_\_/25 |
| Selective triggers               | Yes/No       | Medium | \_\_\_/15 |
| Concurrency control              | Yes/No       | Medium | \_\_\_/15 |
| Matrix builds (when appropriate) | Yes/No       | Medium | \_\_\_/10 |
| Timeouts set                     | Yes/No       | Low    | \_\_\_/5  |

**Total Performance Score: \_\_\_/100**

**Cache Hit Rate:** \_\_\_% (Target: >80%)

## Best Practices Audit

### Workflow Structure

**1. Naming**

❌ **POOR:**

```yaml
name: CI
```

✅ **GOOD:**

```yaml
name: Application CI
```

**2. Documentation**

❌ **POOR:**

```yaml
- run: |
    npm ci
    npm run build
    npm test
```

✅ **GOOD:**

```yaml
- name: Install dependencies
  run: npm ci

- name: Build application
  run: npm run build

- name: Run test suite
  run: npm test
```

**3. Error Handling**

❌ **POOR:**

```yaml
- run: ./deploy.sh # Fails silently if script has issues
```

✅ **GOOD:**

```yaml
- name: Deploy application
  run: |
    set -euo pipefail  # Fail on errors
    ./deploy.sh
  timeout-minutes: 10
```

### Code Quality Patterns

**1. DRY Principle - Use Reusable Workflows**

❌ **REPETITIVE:**

```yaml
# .github/workflows/test-v1.yml
jobs:
  test:
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - run: ./scripts/test.sh 1.0

# .github/workflows/test-v2.yml
jobs:
  test:
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - run: ./scripts/test.sh 2.0
```

✅ **DRY:**

```yaml
# .github/workflows/reusable-test.yml
on:
  workflow_call:
    inputs:
      tool-version:
        required: true
        type: string

permissions:
  contents: read

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd # v6.0.2
      - run: ./scripts/test.sh ${{ inputs.tool-version }}

# .github/workflows/ci.yml
jobs:
  test-v1:
    uses: ./.github/workflows/reusable-test.yml
    with:
      tool-version: "1.0"

  test-v2:
    uses: ./.github/workflows/reusable-test.yml
    with:
      tool-version: "2.0"
```

**2. Conditional Logic**

❌ **COMPLEX:**

```yaml
- if: github.ref == 'refs/heads/main' && github.event_name == 'push' && !contains(github.event.head_commit.message, '[skip ci]')
  run: ./deploy.sh
```

✅ **READABLE:**

```yaml
- name: Check deployment conditions
  id: should-deploy
  run: |
    if [[ "${{ github.ref }}" == "refs/heads/main" ]] && \
       [[ "${{ github.event_name }}" == "push" ]] && \
       ! echo "${{ github.event.head_commit.message }}" | grep -q "\[skip ci\]"; then
      echo "deploy=true" >> $GITHUB_OUTPUT
    fi

- name: Deploy to production
  if: steps.should-deploy.outputs.deploy == 'true'
  run: ./deploy.sh
```

### Best Practices Score

| Practice                         | Status | Points    |
| -------------------------------- | ------ | --------- |
| Descriptive workflow names       | **\_** | \_\_\_/10 |
| Step names provided              | **\_** | \_\_\_/10 |
| Timeouts configured              | **\_** | \_\_\_/10 |
| Error handling (set -e)          | **\_** | \_\_\_/10 |
| DRY - reusable workflows         | **\_** | \_\_\_/15 |
| Appropriate conditionals         | **\_** | \_\_\_/10 |
| Artifacts uploaded/used properly | **\_** | \_\_\_/10 |
| Environment variables organized  | **\_** | \_\_\_/10 |
| Services health checks           | **\_** | \_\_\_/10 |
| Comments for complex logic       | **\_** | \_\_\_/5  |

**Total Best Practices Score: \_\_\_/100**

## Maintainability Assessment

### Code Smells

**1. Magic Numbers/Strings**

❌ **POOR:**

```yaml
- run: sleep 30 # Why 30?
- run: curl https://api.example.com/v1/deploy
```

✅ **GOOD:**

```yaml
env:
  STARTUP_DELAY: 30  # Wait for services to be ready
  API_ENDPOINT: https://api.example.com/v1

- run: sleep $STARTUP_DELAY
- run: curl $API_ENDPOINT/deploy
```

**2. Complex Shell Scripts**

❌ **POOR:**

```yaml
- run: |
    # 50 lines of bash script
    for file in $(find . -name "*.rb"); do
      # complex logic
    done
    # more complex logic
```

✅ **GOOD:**

```yaml
# Move to script file: scripts/process-files.sh
- run: ./scripts/process-files.sh
```

**3. Duplicate Configuration**

❌ **POOR:**

```yaml
jobs:
  test-1:
    env:
      RUBY_VERSION: "3.2"
      RAILS_ENV: test
      DATABASE_URL: postgres://localhost/test

  test-2:
    env:
      RUBY_VERSION: "3.2"
      RAILS_ENV: test
      DATABASE_URL: postgres://localhost/test
```

✅ **GOOD:**

```yaml
env:
  RUBY_VERSION: "3.2"
  RAILS_ENV: test
  DATABASE_URL: postgres://localhost/test

jobs:
  test-1:
    # Inherits workflow-level env
  test-2:
    # Inherits workflow-level env
```

## Evaluation Report Template

```markdown
# Workflow Evaluation Report

**Workflow:** `.github/workflows/[name].yml`
**Evaluated by:** [Name]
**Date:** [Date]

## Executive Summary

Overall Status: ✅ PASS / ⚠️ NEEDS IMPROVEMENT / ❌ FAIL

**Tool Gates:** actionlint ✅/❌ | zizmor ✅/❌

- Security Score (optional): \_\_\_/100
- Performance Score: \_\_\_/100
- Best Practices Score: \_\_\_/100
- Maintainability: \_\_\_/100

**Overall Score: \_\_\_/100**

## Critical Issues (Must Fix)

1. [Issue 1]
   - **Severity:** Critical
   - **Location:** Line X
   - **Current:** [Code snippet]
   - **Fix:** [Solution]
   - **Impact:** [Security/Performance/Reliability]

## Important Issues (Should Fix)

1. [Issue 1]
   - **Severity:** Important
   - **Location:** Line X
   - **Recommendation:** [Solution]
   - **Benefit:** [Expected improvement]

## Recommended Improvements

1. [Improvement 1]
   - **Current:** [Description]
   - **Proposed:** [Solution]
   - **Expected benefit:** [Time savings, better security, etc.]

## Positive Findings

- ✅ [Good practice 1]
- ✅ [Good practice 2]

## Action Items

Priority order:

1. [ ] Fix critical security issues
2. [ ] Implement important improvements
3. [ ] Apply recommended optimizations
4. [ ] Update documentation

## Metrics

| Metric                  | Current | Target  | Status |
| ----------------------- | ------- | ------- | ------ |
| Workflow execution time | X min   | <15 min | ✅/❌  |
| Cache hit rate          | X%      | >80%    | ✅/❌  |
| Security score (optional) | X/100   | >90/100 | ✅/❌  |
| actionlint                | pass    | pass    | ✅/❌  |
| zizmor                    | pass    | pass    | ✅/❌  |

## Recommendations Summary

**Immediate Actions:**

- [Action 1]
- [Action 2]

**Medium-term Improvements:**

- [Improvement 1]
- [Improvement 2]

**Long-term Considerations:**

- [Consideration 1]
- [Consideration 2]
```

## Automated Evaluation Tools

Run the validation pipeline documented in [validation-tooling.md](validation-tooling.md):

1. **actionlint** — syntax, schema, and expression validation
2. **zizmor --offline** — security static analysis (unpinned refs, template injection, excessive permissions)

```bash
# Local evaluation (see validation-tooling.md for full workflow)
actionlint .github/workflows/*.yml
zizmor --offline --min-severity=medium .github/workflows/
```

Both tools must exit cleanly before proceeding to manual review or the optional security scorecard.

## Evaluation Workflow

1. **Tool Gates (required)**
   - Run actionlint — must exit 0
   - Run zizmor --offline (with configured `--min-severity`) — must exit 0
   - See [validation-tooling.md](validation-tooling.md) for CI integration

2. **Initial Review**
   - Review workflow trigger configuration
   - Check for obvious structural issues

3. **Security Analysis**
   - Complete [security-checklist.md](security-checklist.md) manual items
   - Optionally calculate security score (supplement only)

4. **Performance Review**
   - Measure current execution time
   - Identify optimization opportunities
   - Calculate performance score

5. **Best Practices Audit**
   - Check naming and documentation
   - Review code organization
   - Calculate best practices score

6. **Generate Report**
   - Document findings
   - Prioritize action items
   - Set follow-up timeline

7. **Follow-up**
   - Verify fixes implemented
   - Re-run actionlint and zizmor
   - Measure improvement

## Pass/Fail Criteria

### FAIL Criteria (automatic)

Workflow **fails** evaluation if either tool reports errors:

- **actionlint** exits non-zero (syntax, schema, or expression errors)
- **zizmor** exits non-zero at configured `--min-severity` (default: report all; CI typically uses `--min-severity=medium`)

Critical manual findings (hardcoded secrets, unpinned actions, dangerous `pull_request_target`) also constitute FAIL regardless of score.

### PASS Criteria

Workflow passes evaluation if:

- actionlint and zizmor both exit 0
- No critical security issues in manual review
- Performance score ≥ 70/100 (when measured)
- Execution time meets targets
- Best practices score ≥ 75/100 (when measured)

### NEEDS IMPROVEMENT Criteria

Workflow needs improvement if:

- Tool gates pass but important security issues remain (OIDC not used, missing environment protection)
- Performance score 60-69/100
- Execution time 1.5x target
- Best practices score 60-74/100

## Resources

- [Validation Tooling](validation-tooling.md) — actionlint and zizmor workflow
- [Security Checklist](security-checklist.md) — manual review after tool gates
- [GitHub Actions Security Hardening](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions)
- [actionlint](https://github.com/rhysd/actionlint)
- [zizmor](https://docs.zizmor.sh/)
- [Awesome Actions Security](https://github.com/step-security/supply-chain-goat)
