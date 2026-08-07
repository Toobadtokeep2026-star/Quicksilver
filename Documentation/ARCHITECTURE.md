# Mercury: Quicksilver Architecture

## Vision

Mercury is a personal AI operating companion for iPhone.

It is not a chatbot. It is not an AI wrapper. It is an intelligent entity with memory, personality, reasoning, and awareness living inside iOS.

Sense → Think → Express → Act

- **Nexus** senses the device and environment
- **Mercury Brain** reasons, plans, and decides
- **Personality Engine** shapes expression and behavior
- **Memory** provides continuity
- **Personas + UI** express the result with presence

## Strict Dependency Direction

```
                 Quicksilver App (Mercury)
                       |
              DependencyContainer
                       |
                   MercuryBrain
                       |
 ------------------------------------------------
 |              |              |                |
Core        Personas        Nexus          Services
 |              |              |                |
 ---------------- Memory ---------------- AI Provider
```

### Rules

| Module | May depend on | Must not depend on |
|--------|---------------|--------------------|
| **Core** | Foundation only | UI, AI, Nexus, Personas, Memory implementations |
| **Personas** | Core | Networking, storage backends, UI |
| **Nexus** | Core | Personas, UI, AI providers |
| **Memory** | Core | UI, AI, Nexus |
| **Services/AI** | Core | UI, Nexus, Personas |
| **UI** | Everything via DependencyContainer / Brain | Direct business logic |

Core owns the shared contracts and foundational models. All other modules depend on Core, never the reverse.

## Mercury Brain

Central intelligence coordinator (`App/MercuryBrain.swift`).

Responsibilities:
- Understand intent
- Retrieve context (memory + Nexus + persona)
- Decide when to use tools / AI
- Plan actions and validate results
- Maintain and influence `PersonalityState`
- Produce living status and primary insights

UI and Intents should prefer the Brain for complex flows.

## Personality Engine

`PersonalityState` (Personas module) is a live behavioral system, not static prompt text.

Dimensions:
- Confidence, Curiosity, Humor, Mischief
- Focus, Initiative, Skepticism, Patience, Loyalty

These fluctuate with context and strongly bias the active persona.

## Core Contracts (`Core/Protocols/`)

| Protocol | Purpose | Implemented by |
|----------|---------|----------------|
| `AIProvider` | Language-model backends | `MockAIProvider`, `GrokAIProvider` |
| `MemoryStore` | Persistent memory | `SwiftDataMemoryStore` (preferred), `UserDefaultsMemoryStore` (fallback) |
| `DiagnosticProvider` | Device / environment sensors | `NetworkMonitor`, `BatteryMonitor`, `StorageMonitor`, `DeviceMetricsMonitor` |
| `PersonaEngine` | Persona selection & influence | `PersonaManager` |
| `AutomationProvider` | App Intents / Shortcuts surface | `AutomationBridge` (Nexus) + `QuicksilverIntents` |

## Module Responsibilities

**Core**  
Foundational models, protocols, logging, feature flags, EventBus, configuration.

**Personas**  
Identity, reasoning style, tone, `PersonalityState`, memory policy, decision policy.

**Nexus**  
Diagnostics, sensors, device signals, insight generation. Persona-agnostic.

**Memory**  
Persistent context and user continuity. Layered memory is evolving.

**Services/AI**  
Model communication, prompt/context assembly, response handling.

**UI**  
Presentation only. Uses Observation + Brain / DependencyContainer.

## Visual Identity

Cosmic black · deep violet · mercury silver · emerald · subtle gold · glass · liquid metal.

Persona accents still shift for identity. Motion has meaning (thinking, insight, error).

## Engineering Rules

- Analyze first. Public APIs only. Battery & privacy first.
- Modular boundaries are non-negotiable.
- Focused commits. Clear documentation of limitations.
- Prefer working vertical slices over speculative complexity.
- Every new feature must have a clear architectural home.
- Depth over quantity. Personality over generic functionality.

## Explicitly Deferred (for now)

- Full autonomous agent loops
- Complex multi-hop RAG
- Cloud dependency for core function
- Plugin marketplace

The goal is a stable, present intelligence — not a collection of disconnected features.
