# Quicksilver

Native iOS intelligence framework: modular architecture, adaptive personas, Nexus diagnostics, Memory, and AI.

```
SENSE (Nexus) → THINK (Core + AI + Memory) → EXPRESS (Personas + UI)
```

## Current surfaces

| Screen | Role |
|--------|------|
| **Home** | Persona switcher, Nexus health summary |
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
