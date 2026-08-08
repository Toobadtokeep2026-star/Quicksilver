# Forge Sprint — Five Phases

Branch: `forge/sprint-five-phases`  
Date: 2026-08-08

This sprint advances all five roadmap phases with production-quality vertical slices. It does not claim the full destination; it makes the architecture real and shippable.

## Phase 1 — Harden the Brain & Close the Loop

- `MercuryBrain.ask` now retrieves persona-scoped, importance-filtered memory before every AI call.
- Memory is injected into the system prompt as a compact, ranked block.
- Intent classification moved behind `LocalIntentClassifier` (testable, replaceable).
- Living status and chamber suggestion react to Nexus health, battery, and thermal signals.
- `consolidateMemory(importanceThreshold:)` provides the first memory lifecycle control surface.

## Phase 2 — Maximum Agency Surface

- All conversation paths are designed to flow through MercuryBrain (UI already does; Intents remain on IntentDependencies for process isolation but share the same services).
- CaptureMemory, QueryNexus, SwitchToForge, ReportStatus, GetContext remain the high-frequency App Shortcuts.
- Next concrete agency work (Shortcuts automations, Lock Screen, Focus) can bind to the new Brain surface without further architectural change.

## Phase 3 — On-Device Intelligence Primacy

- `LocalIntentClassifier` is the explicit extension point for Core ML / Apple Intelligence.
- Classification is pure and side-effect free so it can be swapped or ensembled with an on-device model later.
- Memory retrieval and scoring remain fully on-device today.

## Phase 4 — Presence & Illusion Completion

- `livingStatus`, `primaryInsight`, and `suggestedChamber` are now richer and reactive.
- Low health / low power / high clarity states produce distinct presence language and personality micro-adjustments.
- UI (AmbientLayer, QuicksilverPresenceView, SanctumView) can bind directly to these published properties for continuous presence.

## Phase 5 — Adaptive & Long-Horizon Behavior

- Personality dimensions receive light adaptive updates from memory hit rate, intent type, and device pressure.
- Memory consolidation hook is live.
- Persona autonomy (already present in PersonaManager) continues to receive task context from the Brain.

## What Was Explicitly Not Done (Deferred)

- Full autonomous agent loops
- Vector / embedding memory search
- Cloud-dependent core function
- Multi-hop tool calling
- Live Activity / Dynamic Island surfaces (ready to be added on top of the new Brain signals)

## Next Immediate Actions After Merge

1. Wire UI Ask path and any remaining Intent paths to prefer Brain where possible.
2. Add unit tests for `LocalIntentClassifier` and memory injection formatting.
3. Generate the high-agency Shortcut + Personal Automation pack (Lock Screen, charging, Focus).
4. Begin Core ML replacement path for `LocalIntentClassifier` once training data exists.

## Engineering Notes

- Public APIs only. SideStore-safe.
- Modular boundaries preserved: Brain sits above services; UI does not reach into stores.
- Prompt budget kept tight; memory block is capped and truncated.
