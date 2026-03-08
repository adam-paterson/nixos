# Phase 2: Modular Repository Architecture - Context

**Gathered:** 2026-02-24
**Status:** Ready for planning

<domain>
## Phase Boundary

This phase defines the repository architecture for reusable modules and host composition boundaries. It delivers explicit shared vs platform module separation, thin host composition patterns, and navigation conventions so future changes are easy to locate and extend.

</domain>

<decisions>
## Implementation Decisions

### Module boundaries
- Default placement is capability-first.
- Shared module purity is pragmatic: small platform conditionals are allowed when they clearly reduce duplication.
- Secrets-related wiring stays host-local in this phase.
- User-level tooling split is mixed-by-tool rather than globally shared or globally per-platform.

### Host composition style
- Host files should be thin, with a small set of host toggles allowed.
- Host-local data may include facts and secret references.
- Host composition should use capability bundles.
- Host exceptions should first go into dedicated override modules rather than inline host file sprawl.

### Naming and directory conventions
- Organize top-level modules capability-first.
- Use verbose, explicit names for discoverability.
- Deprecations/moves use hard moves (no alias layer).
- Conventions should live in local README files per major directory.

### Architecture documentation style
- Audience is both future self and collaborators.
- Documentation depth is decision-focused.
- Use canonical templates as the primary example format.
- Treat conventions as a strong contract; deviations require explicit justification.

### Claude's Discretion
- Exact capability taxonomy and folder granularity.
- Exact wording/templates for local READMEs while preserving the decision-focused contract.
- How to stage migrations in plans while respecting hard-move policy.

</decisions>

<specifics>
## Specific Ideas

- Keep the architecture clean and inspirational as a reference model, not just functional.
- Make module boundaries obvious to reduce future drift and ad hoc host logic.

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 02-modular-repository-architecture*
*Context gathered: 2026-02-24*
