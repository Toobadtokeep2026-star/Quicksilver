# Quicksilver

Native iOS intelligence framework built around modular architecture, adaptive personas, diagnostics (Nexus), and automation.

## Day One Foundation (Complete)

This establishes the clean native SwiftUI skeleton:

- Modular source layout (`App`, `Core`, `Personas`, `Nexus`, `UI`, `Models`, `Services`, `Resources`, `Tests`)
- Application entry point + dependency injection container
- Configuration system + typed errors + OSLog facade
- Persona **configuration** surface (data-driven) + three initial personas (Forge, Quicksilver, Eternal)
- Nexus coordinator with SystemMonitor, NetworkMonitor (Network.framework), AutomationManager placeholders
- Basic SwiftUI shell that surfaces active persona and Nexus status
- Real Grok / xAI AIProvider (Keychain-backed, feature-flagged, Mock by default)
- XCTest foundation for personas, configuration, and Nexus lifecycle
- SwiftLint configuration (advisory in CI)
- GitHub Actions structure check + **macOS `swift test` for core modules**
- Updated architecture documentation
- **Package.swift** exposing non-UI targets as `QuicksilverCore` library (Core / Memory / Personas / ServicesAI / Nexus)
- **project.yml** for one-command Xcode project generation via xcodegen

### What is intentionally missing / deferred

- Full generated `.xcodeproj` (run `xcodegen` on a Mac — see below)
- Real Asset Catalog and color assets
- Persistence layer beyond UserDefaultsMemoryStore
- Background modes and entitlements

These remain deferred so the foundation stays stable and reviewable.

## Getting Started

### Core logic & tests (no local Mac required)

```bash
swift test
```

Runs against the Package.swift targets on any machine with Swift 5.9+ (or via the macOS CI job).

### Full app (Mac + Xcode)

**Preferred (xcodegen):**

```bash
brew install xcodegen
xcodegen generate
open Quicksilver.xcodeproj
```

**Manual fallback:**

1. Create a new iOS App project in Xcode (SwiftUI, iOS 17.0+).
2. Delete the default files.
3. Drag the folders (`App`, `Core`, `Personas`, `Nexus`, `UI`, etc.) into the project, ensuring "Create groups" and correct target membership.
4. Set the `@main` entry to `QuicksilverApp`.
5. Add the test files to a Unit Testing Bundle target.
6. Build & run on iPhone 14 simulator or device.

## Enabling the real AI provider

```swift
// Once you have a key from the xAI console
container.aiService.configureAPIKey("xai-...")
container.featureFlags.set("aiServiceEnabled", enabled: true)
```

Default remains Mock + flag off — zero network, zero risk.

## Development Principles

- Privacy first
- Modular design with clear boundaries
- Test-driven changes
- Clean Git history
- Minimal dependencies
- Production-quality Swift (concurrency safety, Sendable where appropriate)

## Architecture Overview

See [Documentation/ARCHITECTURE.md](Documentation/ARCHITECTURE.md).

## Personas

| Persona     | Role                                      |
|-------------|-------------------------------------------|
| Quicksilver | Primary adaptive intelligence             |
| Forge       | Disciplined builder & structural focus    |
| Eternal     | Continuity, memory, long-term coherence   |

## Nexus

Monitoring and automation hub. Currently:

- `NexusCoordinator` — lifecycle owner
- `SystemMonitor` / `DeviceMetricsMonitor` — thermal / low-power
- `NetworkMonitor` — live `NWPathMonitor`
- `BatteryMonitor` / `StorageMonitor`
- `AutomationManager` — App Intents / Shortcuts ready surface
- `InsightEngine` — persona-styled insights from signals

## License

Private / All rights reserved until otherwise stated.
