# Quicksilver Hardening Report & Roadmap

Date: 2026-07-24 (updated after full sprint implementation)

## Completed Hardening + Sprint

### P0 — Correctness & Safety
- BatteryMonitor: token-based NotificationCenter observers, explicit cleanup
- GrokAIProvider: Task cancellation, 45 s timeout, no secret leakage in errors
- LoggerService: redaction helper for API keys / long tokens
- SystemMonitor & AutomationManager: marked deprecated

### P1 — Architecture & Maintainability
- Persona prompts externalized to `Resources/Personas/*.txt`
- PromptManager loads external prompts with embedded fallback
- MemoryManager: `clearAll()` + `exportJSON()`

### P2 — Experience
- PersonaEntity for typed Shortcuts / Siri selection
- Memory lifecycle tests

### Sprint (this pass)
- **Memory UI ownership**: swipe-to-delete, Clear All confirmation, Export share sheet
- **Importance decay**: deterministic time-based decay in `MemoryScorer.decayedImportance`
- **InsightPresenter**: persona-aware tone applied only at presentation time
- Home + Diagnostics now use InsightPresenter
- Home refreshes on foreground
- Diagnostics keeps conservative live refresh while visible
- Expanded MemoryScorer tests

### Architecture invariants preserved
- Sense → Think → Express
- Core owns contracts only
- Nexus remains persona-agnostic
- UI stays presentation-only
- DependencyContainer is the composition root

---

## Development Roadmap Status

### Milestone 1 — Foundation Stability → Done
### Milestone 2 — Device Intelligence → Done
### Milestone 3 — Memory System → Done (UI + decay + export)
### Milestone 4 — AI Integration → Largely done (cancellation, prompts, Mock path)
### Milestone 5 — Polished UI / Personality → In progress (InsightPresenter landed)

Remaining optional polish:
- Stronger pure Observation (further reduce any remaining timers)
- Visual refinement within HIG
- Optional MetricKit (public APIs only)

---

## Device Validation Checklist (iPhone 14 / iOS 27 beta)

1. `xcodegen generate` → Archive → IPA
2. Install via SideStore / TrollStore
3. Launch → Home shows persona + Nexus health
4. Settings → paste xAI key → enable AI Service
5. Diagnostics → live signals + persona-toned insights
6. Memory → add note, swipe delete, Clear All, Export
7. Ask → persona-aware response
8. Shortcuts: status, remember, ask, report
9. Background 5–10 min → no excessive drain
10. Force-quit + relaunch → state intact

No private APIs. Keychain for secrets only.
