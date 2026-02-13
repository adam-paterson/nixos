---
# Trigger - when should this workflow run?
on:
  schedule: hourly      # Runs every hour with scattered minute
  workflow_dispatch:    # Manual trigger

# Permissions - what can this workflow access?
permissions:
  contents: read
  issues: write
  pull-requests: read

# AI Engine - using OpenAI Codex
engine: codex

# Outputs - what APIs and tools can the AI use?
safe-outputs:
  create-issue:          # Creates issues with cleanup recommendations
    max: 5               # Maximum 5 issues per run
    labels: [cleanup, refactoring, automated]
    title-prefix: "[Cleanup] "

---

# Repository Cleanup Recommendations

Automatically scan the repository every hour to identify areas for consolidation and cleanup.

## Instructions

Scan the repository for areas that could be consolidated and cleaned up:

1. **Analyze the codebase structure** - Look at the directory structure, file organization, and module boundaries

2. **Identify duplication** - Find:
   - Duplicate code blocks or functions
   - Similar utility functions across different files
   - Repeated configuration patterns
   - Copy-pasted logic

3. **Find consolidation opportunities** - Look for:
   - Files that could be merged
   - Modules with overlapping functionality
   - Configuration that could be centralized
   - Shared code that could be extracted to common utilities

4. **Check for dead code** - Identify:
   - Unused functions or variables
   - Unreferenced files
   - Outdated comments
   - Deprecated patterns

5. **Review dependencies** - Check for:
   - Unused dependencies
   - Dependencies that could be replaced with built-ins
   - Multiple dependencies serving the same purpose

## Output Format

For each significant issue found, create a GitHub issue with:
- **Title**: Clear description of the cleanup opportunity
- **Body**: 
  - Location (file paths, line numbers)
  - Current state (what's wrong/suboptimal)
  - Recommended action (specific steps to consolidate/clean)
  - Estimated impact (effort vs. benefit)
  - Optional: Code snippets showing before/after

Be specific and actionable. Prioritize high-impact, low-effort cleanups first.

## Notes

- Run `gh aw compile` to generate the GitHub Actions workflow
- Run `gh aw secrets set OPENAI_API_KEY --value "your-api-key"` to configure Codex
- See https://github.github.com/gh-aw/ for complete configuration options and tools documentation
