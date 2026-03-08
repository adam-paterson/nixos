# Phase 4: Secrets-Safe Configuration - Context

**Gathered:** 2026-02-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Ensure both targets use encrypted-only secret handling, with decryption occurring only during apply/deploy runtime, and prevent plaintext secrets from entering repository-tracked config, Nix evaluation paths, or store artifacts.

</domain>

<decisions>
## Implementation Decisions

### Secret File Organization
- Partition secrets into shared encrypted files plus host-specific encrypted files.
- Use hybrid key naming: hierarchical/domain-prefixed where it matters, with flat concise names where appropriate.
- For keys present on both hosts, keep one logical key with host override values.
- Keep inventory documentation minimal (no strict exhaustive inventory requirement).

### Decryption Trigger Points
- Allow decryption only during apply/deploy flows (not during evaluation/build).
- Local workstation applies should handle decryption automatically within the apply command flow.
- VPS deployments should decrypt on target during deploy/activation.
- If decryption credentials are unavailable, fail hard.

### Missing Secret Behavior
- Missing required secrets should abort only the affected host target (not unrelated targets).
- Error reporting should be detailed diagnostic output.
- Required secrets must never use fallback defaults.
- On secret failure, perform a clean fail with no partial secret artifacts and require explicit retry.

### Developer Secret UX
- Provide in-repo setup via template plus checklist.
- Placeholders should use explicit dummy values (clearly non-secret markers).
- Guardrails should strictly block plaintext-secret commit patterns.
- Provide a documented safe mock/testing path without real secrets where feasible.

### Claude's Discretion
- Exact boundaries of which keys use hierarchical vs flat naming.
- Exact format/content of the onboarding checklist and templates.
- Exact diagnostic message format and verbosity structure.
- Exact scope of the safe mock path while preserving phase constraints.

</decisions>

<specifics>
## Specific Ideas

- Prefer one logical secret key model with host override values instead of duplicating per-host key names.
- Prioritize operator clarity when failures happen: diagnostics should explain cause and next action clearly.

</specifics>

<deferred>
## Deferred Ideas

None - discussion stayed within phase scope.

</deferred>

---

*Phase: 04-secrets-safe-configuration*
*Context gathered: 2026-02-25*
