# Quicksilver Architecture

## Vision

Quicksilver is the intelligence core of the Mercury ecosystem: a modular native iOS assistant focused on personality, automation, diagnostics, and user control.

## Day One Module Map

```
Quicksilver/
├── App/                  # @main entry, DependencyContainer
├── Core/                 # Configuration, errors, logging
├── Models/               # Shared domain models (empty Day One)
├── Services/             # AI providers, networking, integrations (empty Day One)
├── Personas/             # Identity layer (protocol + concrete personas)
├── Nexus/                # Monitoring + automation hub
├── UI/                   # SwiftUI views only
├── Resources/            # Assets, plists (empty Day One)
└── Tests/                # XCTest targets
```

## Responsibility Boundaries

| Module     | Owns                                      | Must Not Own                  |
|------------|-------------------------------------------|-------------------------------|
| App        | Lifecycle, DI root                        | Business logic                |
| Core       | Config, errors, logging primitives        | UI, networking                |
| Personas   | Identity, prompts, behavioral intent      | Views, network calls          |
| Nexus      | System/network health, automation surface | Persona switching, UI         |
| Services   | External I/O, AI adapters                 | UI state, persona definitions |
| UI         | Presentation                              | Business rules, persistence   |
| Models     | Pure data structures                      | Side effects                  |

## Dependency Direction

```
UI → App/DependencyContainer → (Personas | Nexus | Core)
Services → Core
Nexus → Core
Personas → (none)
```

No cycles. UI never imports Nexus or Personas directly beyond what the container exposes.

## Key Design Decisions (Day One)

1. **Personas are pure value types conforming to a protocol.**  
   No `@ObservedObject` or UI coupling. System prompts live here for future LLM integration.

2. **DependencyContainer is the single composition root.**  
   Created once at app launch, injected via `@EnvironmentObject`. Easy to replace in tests.

3. **Nexus uses only public Apple APIs.**  
   `NWPathMonitor` is live. SystemMonitor and AutomationManager are explicit placeholders with comments naming the future public APIs (ProcessInfo, MetricKit, App Intents).

4. **No third-party dependencies.**  
   SwiftUI + Foundation + Network + OSLog only.

5. **Target baseline: iOS 17.0.**  
   Compatible with iPhone 14 and forward (including iOS 27 beta). Uses modern concurrency annotations (`@MainActor`, `Sendable`).

6. **Error surface is typed (`AppError`).**  
   Prevents stringly-typed failures and enables future localized user messaging.

## Future Expansion Points (explicitly marked)

- App Intents + App Shortcuts for AutomationManager
- MetricKit / ProcessInfo sampling in SystemMonitor
- Real AI provider in Services/ (with privacy boundaries)
- Color assets matching `accentColorName` on each persona
- Persistence (SwiftData or Core Data) behind a protocol in Services or Core
- Background tasks only after entitlement justification

## Testing Strategy

- Unit tests for pure logic (personas, configuration, Nexus lifecycle)
- UI tests deferred until the shell stabilizes
- Prefer protocol-based fakes over heavy mocking

## Engineering Rules Applied

All changes follow the Quicksilver Engineering Rules: analyze before coding, production quality, critical review of designs, modular boundaries, focused commits, and clear documentation of what changed and why.
