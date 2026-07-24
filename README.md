# Quicksilver

Native iOS intelligence framework: modular architecture, adaptive personas, Nexus diagnostics, Memory, and AI.

```
SENSE (Nexus) → THINK (Core + AI + Memory) → EXPRESS (Personas + UI)
```

## Status (2026-07-24) — Production Hardening Complete

Full engineering pass landed. See [Documentation/HARDENING.md](Documentation/HARDENING.md) for the detailed report and roadmap.

**Highlights**
- BatteryMonitor lifecycle hardened (token-based observers)
- GrokAIProvider: cancellation, timeout, no secret leakage
- Logger redaction for API keys
- Persona prompts externalized to `Resources/Personas/`
- Memory: `clearAll()` + `exportJSON()`
- PersonaEntity for typed Shortcuts
- Deprecated placeholders clearly marked

## Surfaces

| Screen | Role |
|--------|------|
| **Home** | Persona switcher, Nexus health, latest insight |
| **Ask** | Persona-aware chat with Memory history |
| **Memory** | Policy-filtered notes + importance |
| **Diagnostics** | Live insights + signals (auto-refresh while visible) |
| **Settings** | xAI key (Keychain) + AI feature flag |

## Architecture

Strict dependency direction: [Documentation/ARCHITECTURE.md](Documentation/ARCHITECTURE.md)

Core owns contracts. Modules implement. UI only presents. Nexus stays persona-agnostic.

## Getting started

### Package tests
```bash
swift test
```

### Full iOS app (Mac + Xcode)
```bash
brew install xcodegen
xcodegen generate
open Quicksilver.xcodeproj
```

Select Team → run on **iPhone 14** (or Simulator).

### On-device (iPhone 14 / iOS 27 beta)

SideStore / TrollStore compatible:

1. `xcodegen generate` → Archive → IPA
2. Install via SideStore
3. Settings → paste xAI key → enable AI Service
4. Validate Home / Diagnostics / Ask / Shortcuts

No private APIs. Public Apple frameworks only.

### Enable real Grok
1. Settings → paste key → Save (Keychain only)
2. Enable AI Service
3. Ask — provider shows as Grok

Default is Mock (no network).

## Personas

| Persona | Role |
|---------|------|
| Quicksilver | Adaptive daily intelligence |
| Forge | Disciplined builder |
| Eternal | Continuity & long-term coherence |

Prompts live in `Resources/Personas/*.txt` (with embedded fallback).

## Memory

- SwiftData preferred, UserDefaults fallback, InMemory for tests
- Policy filtering + importance scoring
- `clearAll()` and `exportJSON()` available

## Principles

- Privacy first, on-device by default
- Modular boundaries non-negotiable
- Focused commits, working vertical slices
- No autonomous agent loops

## License

Private / All rights reserved until otherwise stated.
