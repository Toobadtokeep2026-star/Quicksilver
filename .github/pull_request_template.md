## Summary

<!-- What does this PR change and why? -->

## Type of change

- [ ] Bug fix
- [ ] Feature / vertical slice
- [ ] Refactor / hardening
- [ ] CI / tooling
- [ ] Documentation

## Architecture checklist

- [ ] No reverse dependencies (UI does not own business rules; Core stays Foundation-only)
- [ ] Nexus remains persona-agnostic (tone applied only at presentation)
- [ ] New code has a clear module home (Core / Nexus / Memory / Personas / Services / UI / Intents)
- [ ] Public Apple APIs only — no private APIs

## Testing

- [ ] `swift test` passes locally or via CI
- [ ] iOS Simulator build passes via CI
- [ ] Manual device validation notes (if applicable):

## Risk notes

<!-- Anything that could break SideStore installs, Keychain, or privacy posture? -->
