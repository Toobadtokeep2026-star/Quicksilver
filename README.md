# Quicksilver

Native iOS intelligence framework: modular architecture, adaptive personas, Nexus diagnostics, Memory, and AI.

```
SENSE (Nexus) → THINK (Core + AI + Memory) → EXPRESS (Personas + UI)
```

## Current status (2026-07-24)

All four simultaneous work items landed:

1. **ViewModel ↔ DependencyContainer wiring** — Home / Diagnostics / Ask / Memory / Settings all receive the shared container and pull live NexusState + active persona on refresh. Container remains single source of truth.
2. **Live signal → Insight → persona presentation path** — Expanded `NexusIntelligenceTests` with full path coverage (signal creation → InsightEngine → state append → personaStyle tagging). Engine stays persona-agnostic by design.
3. **AutomationBridge + App Intents** — Bridge now reports real network / battery / health from NexusState. `CaptureMemoryIntent` actually writes to MemoryManager (persona-scoped, importance-tagged). Shortcuts surface is live.
4. **Device validation path** — Ready for iPhone 14 on iOS 27 beta. See below.

## Current surfaces

| Screen | Role |
|--------|------|
| **Home** | Persona switcher, Nexus health summary, latest insight |
| **Ask** | Persona-aware chat with Memory-backed history |
| **Memory** | Policy-filtered notes + importance |
| **Diagnostics** | Insights + recent signals |
| **Settings** | xAI API key (Keychain) + AI feature flag |

## Architecture

Strict dependency direction is documented in [Documentation/ARCHITECTURE.md](Documentation/ARCHITECTURE.md).

Core owns contracts (`AIProvider`, `MemoryStore`, `DiagnosticProvider`, `PersonaEngine`, `AutomationProvider`). Modules implement; UI only presents.

## Getting started

### Package tests (any Swift 5.9+ host)

```bash
swift test
```

### Full iOS app (Mac + Xcode)

```bash
brew install xcodegen
xcodegen generate
open Quicksilver.xcodeproj
```

Select your Team for Automatic signing, then run on **iPhone 14** (or Simulator).

### On-device only (iPhone 14 / iOS 27 beta — no Mac)

Quicksilver is structured for SideStore / TrollStore-style sideloading:

1. Generate the Xcode project on any Mac (or CI) with `xcodegen generate`.
2. Archive + export an IPA (or use an existing SideStore-compatible build pipeline).
3. Install via SideStore on the target iPhone 14.
4. First launch: open **Settings** → paste xAI key → enable AI Service.
5. Validate:
   - Home shows live Nexus health + persona switcher
   - Diagnostics shows signals + insights after a few seconds
   - Ask uses the active persona + Memory context
   - Siri / Shortcuts: “What’s the context in Quicksilver”, “Remember this in Quicksilver”, “Ask Nexus”

No private APIs. All monitors use public Apple frameworks only.

### Enable real Grok

1. Run the app on device/simulator
2. Open **Settings**
3. Paste your xAI API key → **Save Key** (stored in Keychain only)
4. Enable **AI Service**
5. Use **Ask** — provider shows as Grok when flag + key are present

Default remains Mock + flag off (no network).

## Personas

| Persona | Role |
|---------|------|
| Quicksilver | Adaptive daily intelligence |
| Forge | Disciplined builder / engineering |
| Eternal | Continuity and long-term coherence |

Each has a `MemoryPolicy` (retention threshold, scoped view, write importance hint).

## Memory backends

- **SwiftData** preferred at launch
- **UserDefaults** automatic fallback
- **InMemory** for unit tests

All behind `MemoryStore`.

## Development principles

- Privacy first, on-device by default
- Modular boundaries non-negotiable
- Focused commits, working vertical slices
- No autonomous agent loops, no cloud dependency for core function

## License

Private / All rights reserved until otherwise stated.
