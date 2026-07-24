# Quicksilver Architecture

## Vision

Quicksilver is a modular native iOS intelligence framework.

Sense → Think → Express

- **Nexus** senses the device and environment
- **Core + AI** reason over signals and context
- **Personas + UI** express the result with appropriate voice and behavior

## Strict Dependency Direction

```
                 Quicksilver App
                       |
              DependencyContainer
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
| **UI** | Everything via DependencyContainer | Direct business logic |

Core owns the shared contracts and foundational models. All other modules depend on Core, never the reverse.

## Core Contracts (`Core/Protocols/`)

| Protocol | Purpose | Implemented by |
|----------|---------|----------------|
| `AIProvider` | Language-model backends | MockAIProvider, GrokAIProvider |
| `MemoryStore` | Persistent memory | UserDefaultsMemoryStore (SwiftData later) |
| `DiagnosticProvider` | Device / environment sensors | NetworkMonitor, BatteryMonitor, … |
| `PersonaEngine` | Persona selection & influence | PersonaManager |
| `AutomationProvider` | App Intents / Shortcuts surface | AutomationManager |

Everything communicates through these protocols. Managers and coordinators must not become god objects.

## Module Responsibilities

**Core**  
Foundational models (`AIRequest`, `AIResponse`, `MemoryItem`, `AppError`, …), protocols, logging, feature flags, EventBus, configuration. Independent.

**Personas**  
Identity, reasoning style, tone, priorities, memory policy, decision policy. Does not own networking, storage, or UI.

**Nexus**  
Diagnostics, sensors, device signals, insight generation. Does not decide personality responses.

**Memory**  
Persistent context and user continuity. Storage backends are replaceable behind `MemoryStore`.

**Services/AI**  
Model communication, prompt/context assembly, response handling. Does not own application state.

**UI**  
Presentation only. Uses Observation + dependency injection. Never creates prompts or owns business logic.

## Nexus Philosophy

Nexus is a privacy-first perception layer:

1. Observes only public Apple APIs
2. Normalizes into a unified `Signal`
3. Produces persona-agnostic `Insight`s
4. Persona voice is applied only at presentation time

No continuous location, no private sysctl, no data leaving the device.

## Engineering Rules

- Analyze first. Public APIs only. Battery & privacy first.
- Modular boundaries are non-negotiable.
- Focused commits. Clear documentation of limitations.
- Prefer working vertical slices over speculative complexity.
- Every new feature must have a clear architectural home.

## Explicitly Deferred

- Autonomous agent loops
- Complex AI memory retrieval / RAG
- Cloud dependency for core function
- Plugin marketplace
- Excessive animation or dashboard chrome

The goal is a stable intelligence framework, not a collection of disconnected features.
