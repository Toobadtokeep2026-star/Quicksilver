# Quicksilver Architecture

## Vision
Quicksilver is the intelligence core of the Mercury ecosystem: a modular native iOS assistant focused on personality, automation, diagnostics, and user control.

## Module Map (Current)

```
Quicksilver/
├── App/                  # @main + DependencyContainer
├── Core/                 # Environment, FeatureFlags, LoggerService, EventBus, Config, Errors
├── Personas/             # Configuration, State, Manager + concrete personas
├── Memory/               # Local-first MemoryItem / Store / Manager
├── Services/AI/          # Provider abstraction + Mock
├── Nexus/                # Awareness / perception layer
├── UI/
├── Models/ / Resources/ / Tests/
```

## Nexus Philosophy

Nexus is **not** a traditional monitoring dashboard.  
It is Quicksilver’s **perception layer** — a privacy-first awareness system that:

1. Observes only signals available through public Apple APIs.
2. Normalizes them into a unified `Signal` model.
3. Interprets patterns into human-readable `Insight`s.
4. Applies persona voice at presentation time only.
5. Never collects data without a clear purpose.

### Signal Architecture

```
Monitor → raw observation
    ↓
SignalProcessor → normalized Signal
    ↓
NexusCoordinator → appends to NexusState + asks InsightEngine
    ↓
Insight (persona-styled) → stored in NexusState for UI / future AI
```

### Privacy & Capability Boundaries

**Available (public APIs only):**
- Network path (Network.framework)
- Battery level & state (UIDevice, monitoring enabled explicitly)
- Free / total storage (FileManager)
- Thermal state & Low Power Mode (ProcessInfo)

**Explicitly unavailable / not implemented:**
- Continuous background location
- Private sysctl / kernel metrics
- Other apps’ process lists
- Always-on high-frequency sampling
- Any data that leaves the device

MetricKit is prepared for a later milestone but is not required for current insights.

### Insight Pipeline
- Insights are generated only when a signal is meaningful.
- Persona styling (Forge / Quicksilver / Eternal) is applied as a final presentation step.
- The data layer remains persona-agnostic.

### EventBus Discipline
- EventBus is used sparingly and only for meaningful cross-module state changes.
- Nexus prefers direct method calls for its internal pipeline.
- No universal “dumping ground” events.

### AutomationBridge
- Explicit surface for future App Intents and Shortcuts.
- No unsupported background work is claimed or implemented.

## Trade-offs

| Decision                    | Benefit                          | Cost                              |
|----------------------------|----------------------------------|-----------------------------------|
| Low-frequency storage poll | Battery friendly                 | Slightly delayed storage insights |
| Persona styling at end     | Clean data layer                 | Slight duplication of body text   |
| No MetricKit yet           | Zero extra entitlement surface   | Fewer performance signals         |
| Bounded history            | Memory safe                      | Limited long-term pattern analysis|

## Future Expansion
- Richer PersonaProfile (Identity, Traits, Capabilities, MemoryPermissions, AIBehavior)
- MetricKit subscribers
- App Intents for user-triggered diagnostics
- SwiftData-backed signal history
- On-device model for deeper pattern recognition

## Engineering Rules Applied
Analyze first • Public APIs only • Battery & privacy first • Modular boundaries • Focused commits • Clear documentation of limitations.
