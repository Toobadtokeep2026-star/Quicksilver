# Quicksilver Hardening Report & Roadmap

Date: 2026-08-02 (Slice A — persona experience + CI/SideStore polish)

## Device / OS policy

| Layer | Value | Reason |
|-------|-------|--------|
| Primary validation device | iPhone 14 / **iOS 27** | User device |
| `IPHONEOS_DEPLOYMENT_TARGET` | **18.0** | CI runners (Xcode 16) only ship iOS 18 SDK |
| `AppConfiguration.minimumOSVersion` | 18.0 | Matches build floor |
| `AppConfiguration.primaryDeviceOSVersion` | 27.0 | Honest about where we test |

Raising the minimum to 27.0 before CI has an iOS 27 SDK would break every Archive job and stop SideStore IPA production. Keep the floor at 18 until the runner SDK catches up; binaries built that way install and run correctly on iOS 27.

## Last SideStore drop

| Field | Value |
|-------|-------|
| Version | **0.1.0 (build 6)** |
| Branch | `feature/persona-experience-slice-a` (merge to main after CI green) |
| Focus | Persona-driven UI tone, accent, density, memory policy visibility |
| Path | Actions → Archive IPA → Quicksilver-unsigned-IPA |

## Completed Hardening + Sprint

### P0 — Correctness & Safety
- BatteryMonitor / NetworkMonitor / StorageMonitor / DeviceMetricsMonitor: main-queue delivery, token-based observers, explicit lifecycle
- GrokAIProvider: Task cancellation, 45 s timeout, no secret leakage in errors
- LoggerService: redaction helper for API keys / long tokens
- **PrivacyInfo.xcprivacy** added and embedded in the app target
- DependencyContainer: structured persona switch with error logging

### P1 — Architecture & Maintainability
- Persona prompts externalized to `Resources/Personas/*.txt`
- PromptManager loads external prompts with embedded fallback
- MemoryManager: `clearAll()` + `exportJSON()`
- **Redirect stubs removed** (`Services/AI/AIRequest`, `AIResponse`, `PromptManager`; `Memory/MemoryItem`)
- **Deprecated placeholders removed** (`SystemMonitor`, `AutomationManager`)
- InsightEngine: personaID is an optional traceability tag only; generation is persona-agnostic
- AppConfiguration documents both build floor (18) and primary device (27)

### P2 — Experience (Slice A)
- **PersonaTheme**: accent colors, density, card radius, bubble style per persona
- **InsightPresenter**: distinct tone + action labels (Forge / Eternal / Quicksilver)
- Home: persona accent stroke + live density
- Ask: persona-colored bubbles + send button
- Memory: explicit policy summary in section header
- PersonaEntity for typed Shortcuts / Siri selection
- Memory lifecycle tests + expanded MemoryScorer + NexusIntelligence coverage

### CI / SideStore path
- Archive IPA workflow prints version/build banner + GitHub notice
- Verifies `.app` existence, persona prompt presence, and IPA structure
- Structure job requires PrivacyInfo.xcprivacy
- Build number at **6**

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
### Milestone 5 — Polished UI / Personality → **Slice A landed** (PersonaTheme + InsightPresenter + surface polish)
### Milestone 6 — SideStore production hardening → Largely done
### Cleanup / refine / polish → Ongoing

Remaining optional polish:
- Stronger pure Observation (further reduce any remaining timers)
- Optional MetricKit (public APIs only)
- Full removal of `@unchecked Sendable` once Apple frameworks become Sendable or we wrap them in actors
- CodeQL / secret-scanning workflow
- Make SwiftLint blocking once the codebase is fully clean under the current ruleset
- Raise deployment target to 27.0 the day CI gains an iOS 27 SDK
- On-device AI provider (Slice B)
- Richer automation surface (Slice C)

---

## Device Validation Checklist (iPhone 14 / iOS 27)

1. Trigger **Actions → Archive IPA → Run workflow** (Release)
2. Download **Quicksilver-unsigned-IPA** artifact
3. Install via SideStore (LocalDevVPN connected)
4. Launch → Home shows persona + Nexus health + accent stroke
5. Switch personas — confirm accent, density, insight tone change
6. Settings → paste xAI key → enable AI Service
7. Diagnostics → live signals + persona-toned insights
8. Memory → policy label visible; add note, swipe delete, Clear All, Export
9. Ask → persona-colored bubbles + response
10. Shortcuts: status, remember, ask, report
11. Background 5–10 min → no excessive drain
12. Force-quit + relaunch → state intact
13. Confirm PrivacyInfo.xcprivacy is present inside the installed app (optional advanced check)

No private APIs. Keychain for secrets only.
