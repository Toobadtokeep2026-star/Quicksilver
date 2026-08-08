# AGENTS.md — Quicksilver / Mercury

## Project
Native iOS intelligence platform. Primary target: iPhone 14 / iOS 27. CI floor: iOS 18.0.

## Non-negotiable Architecture
- Sense (Nexus) → Think (MercuryBrain + Memory + AI) → Express (Personas + UI)
- Core owns all protocols and shared models (SanctumChamber, MemoryItem, etc.)
- MercuryBrain is the only intelligence surface. UI and Intents must prefer the Brain.
- Nexus is persona-agnostic. PersonaID is a tag only.
- DependencyContainer is the composition root.
- Public Apple APIs only. SideStore-first. No private APIs.

## Coding Rules
- Prefer Observation, @Observable, actors, structured concurrency, async/await.
- SWIFT_STRICT_CONCURRENCY: complete
- Keep modules small and directional. No upward dependencies into UI or App.
- PersonaTheme drives visual language. Do not hard-code colors per view.
- Every new realm (Forge, Eternal) must route actions through MercuryBrain / NexusCoordinator.

## Vertical Slice Preference
Work one realm at a time. Prefer small, reviewable PRs.
Current priority order: CI green (CHR-6) → Forge (CHR-10) → Eternal (CHR-11) → Quality gate (CHR-12).

## Testing & CI
- SPM unit tests must stay green.
- Simulator Build must pass before merge.
- Archive IPA workflow is the SideStore path.

## Output Discipline
- Complete, paste-ready files preferred.
- Respect existing naming and file layout.
- Do not introduce new Core protocols unless strictly required.
- Humans own the merge decision.
