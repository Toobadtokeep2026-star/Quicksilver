# Quicksilver

Native iOS intelligence framework built around modular architecture, adaptive personas, diagnostics (Nexus), and automation.

## Day One Foundation (Complete)

This branch establishes the clean native SwiftUI skeleton:

- Modular source layout (`App`, `Core`, `Personas`, `Nexus`, `UI`, `Models`, `Services`, `Resources`, `Tests`)
- Application entry point + dependency injection container
- Configuration system + typed errors + OSLog facade
- Persona protocol + three initial personas (Forge, Quicksilver, Eternal)
- Nexus coordinator with SystemMonitor, NetworkMonitor (Network.framework), AutomationManager placeholders
- Basic SwiftUI shell that surfaces active persona and Nexus status
- XCTest foundation for personas, configuration, and Nexus lifecycle
- SwiftLint configuration
- GitHub Actions structure check
- Updated architecture documentation

### What is intentionally missing

- Full `.xcodeproj` / `project.pbxproj` (generate with Xcode or xcodegen on a Mac)
- Real Asset Catalog and color assets
- App Intents / Shortcuts implementation
- AI provider services
- Persistence layer
- Background modes and entitlements

These are deferred so Day One remains a stable, reviewable skeleton.

## Getting Started (Mac required for now)

1. Create a new iOS App project in Xcode (SwiftUI, iOS 17.0+).
2. Delete the default files.
3. Drag the folders (`App`, `Core`, `Personas`, `Nexus`, `UI`, etc.) into the project, ensuring "Create groups" and correct target membership.
4. Set the `@main` entry to `QuicksilverApp`.
5. Add the test files to a Unit Testing Bundle target.
6. Build & run on iPhone 14 simulator or device.

Alternatively, once an `xcodegen` or Tuist spec is added, regenerate the project from the source tree.

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
| Eternal     | Continuity, memory, long-horizon thinking |

## Nexus

Monitoring and automation hub. Currently:

- `NexusCoordinator` — lifecycle owner
- `SystemMonitor` — placeholder for ProcessInfo / MetricKit
- `NetworkMonitor` — live `NWPathMonitor`
- `AutomationManager` — App Intents / Shortcuts ready surface (throws until implemented)

## License

Private / All rights reserved until otherwise stated.
