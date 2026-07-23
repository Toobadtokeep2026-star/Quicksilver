# Quicksilver Architecture

## Vision
Quicksilver is the intelligence core of the Mercury ecosystem: a modular native iOS assistant focused on personality, automation, diagnostics, and user control.

## Module Map (Current)

```
Quicksilver/
├── App/                  # @main + DependencyContainer
├── Core/                 # Environment, FeatureFlags, LoggerService, EventBus, Config, Errors
├── Personas/             # PersonaConfiguration, PersonaState, PersonaManager + concrete personas
├── Memory/               # MemoryItem, MemoryStore, MemoryManager (local-first)
├── Services/AI/          # AIProvider protocol, Request/Response, AIService + Mock
├── Nexus/                # Monitoring + automation
├── UI/                   # SwiftUI only
├── Models/ / Resources/ / Tests/
```

## Core Intelligence Layer

- **DependencyContainer** — single composition root
- **FeatureFlags** — UserDefaults-backed, observable
- **EventBus** — actor-based typed pub/sub
- **LoggerService** — injectable OSLog

## Persona Engine
- Data-driven `PersonaConfiguration` (Codable, traits, temperature hints)
- `PersonaManager` owns switching and publishes events
- Original Persona protocol retained for UI compatibility

## Memory Foundation
- Local-first, privacy-first
- Protocol-based store (UserDefaults today → SwiftData later)
- Categories: preference, conversation, project, system, temporary

## AI Abstraction
- `AIProvider` protocol only
- `MockAIProvider` for offline/dev/tests
- Real providers gated by feature flag

## Trade-offs
| Decision | Benefit | Limitation |
|----------|---------|------------|
| UserDefaults memory | Zero deps, private | Not for large history |
| Actor EventBus | Simple, safe | Less rich than Combine |
| Mock always available | Unblocked development | Real AI behind flag |
| Dual persona path | Day One UI works | Temporary bridge |

## Engineering Rules Applied
Analyze first • Production quality • Modular boundaries • Focused commits • Clear documentation.
