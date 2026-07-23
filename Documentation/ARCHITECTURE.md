# Quicksilver Architecture

## Vision

Quicksilver is the intelligence core of the Mercury ecosystem: a modular native iOS assistant focused on personality, automation, diagnostics, and user control.

## Module Map (Day Two — Core Intelligence Layer)

```
Quicksilver/
├── App/                      # @main + DependencyContainer (composition root)
├── Core/                     # Environment, FeatureFlags, LoggerService, EventBus, Config, Errors
├── Personas/                 # PersonaConfiguration, PersonaState, PersonaManager + concrete personas
├── Memory/                   # MemoryItem, MemoryStore protocol, MemoryManager (local-first)
├── Services/
│   └── AI/                   # AIProvider protocol, AIRequest/Response, AIService + MockAIProvider
├── Nexus/                    # Monitoring + automation (unchanged from Day One)
├── UI/                       # SwiftUI only
├── Models/                   # Shared domain models
├── Resources/
└── Tests/
```

## Core Intelligence Layer

### Dependency Management
- `DependencyContainer` remains the single composition root (lives in App/).
- All long-lived services are created here and injected.
- No hidden singletons except intentional shared configuration.

### FeatureFlags
- Simple, UserDefaults-backed, observable.
- Controls AI enablement, detailed metrics, experimental features.
- Ready for remote config later without API changes.

### EventBus
- Actor-based, in-process pub/sub.
- Decouples PersonaManager, MemoryManager, AIService, and future modules.
- Events are strongly typed.

### LoggerService
- Injectable wrapper around OSLog.
- Categories: General, Nexus, Persona, Memory, AI, UI.
- Replaces pure static logger for testability.

## Persona Engine

- **PersonaConfiguration** — pure data (Codable, Sendable). Traits, temperature hints, system prompts live here.
- **PersonaState** — runtime session state (interaction count, switch timestamps).
- **PersonaManager** — owns switching, publishes events, records interactions.
- Concrete Day One persona structs kept for UI compatibility; new code should prefer the Manager + Configuration path.
- Personas remain interchangeable and free of UI or network code.

## Memory Foundation

- Local-first, privacy-first.
- `MemoryStore` protocol → currently `UserDefaultsMemoryStore`.
- Categories: preference, conversation, project, system, temporary.
- Ready to swap the store for SwiftData or file-based persistence later without changing callers.
- No cloud, no network.

## AI Service Abstraction

- `AIProvider` protocol is the only contract a backend must satisfy.
- `AIService` is the facade used by the rest of the app.
- `MockAIProvider` ships for offline development and unit tests.
- Feature flag `aiServiceEnabled` gates real providers.
- Temperature / maxTokens hints come from the active PersonaConfiguration.

## Dependency Direction (updated)

```
UI → DependencyContainer
       ├── PersonaManager → EventBus, Logger
       ├── MemoryManager  → MemoryStore, EventBus, Logger
       ├── AIService      → AIProvider, EventBus, Logger, FeatureFlags
       ├── NexusCoordinator
       └── FeatureFlags, LoggerService, EventBus, AppConfiguration
```

No cycles. UI never reaches into MemoryStore or AIProvider directly.

## Testing Strategy (expanded)

- Persona switching (success + unknown ID)
- Memory set / load / delete
- AI mock completion
- DependencyContainer wiring

## Trade-offs (Day Two)

| Decision                        | Benefit                              | Cost / Limitation                     |
|---------------------------------|--------------------------------------|---------------------------------------|
| UserDefaults for memory         | Zero setup, private, fast            | Not ideal for large conversation history |
| Actor EventBus                  | Thread-safe, simple                  | Not as rich as Combine for UI binding |
| MockAIProvider always available | Offline development & tests          | Real providers still behind flag      |
| Keep old Persona protocol       | Day One UI continues to work         | Temporary dual path                   |

## Future (explicit)

- Swap MemoryStore → SwiftData
- Real AI providers (local + cloud) behind the same protocol
- PersonaManager can load custom configurations from disk
- EventBus can gain typed subscribers / filtering
- FeatureFlags can sync from a remote source

## Engineering Rules Applied

Analyze before coding • Production quality • Critical review • Modular boundaries • Focused commits • Clear documentation of changes and why.
