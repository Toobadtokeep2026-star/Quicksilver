# Quicksilver Architecture

## Vision
Quicksilver is the intelligence core of the Mercury ecosystem: a modular native iOS assistant focused on personality, automation, diagnostics, and user control.

## Current Status (Stabilization Pass)

The foundation, Core Intelligence Layer, and Nexus perception layer are in place and have been stabilized for:

- Correct NotificationCenter observer lifecycle
- Cleaner health scoring
- PersonaRegistry as single source of truth
- Expanded unit tests
- Improved CI structure validation

## Module Map

```
Quicksilver/
├── App/                  # @main + DependencyContainer
├── Core/                 # AppConfiguration, AppError, FeatureFlags, LoggerService, EventBus
├── Personas/             # PersonaConfiguration, PersonaRegistry, PersonaManager, State
├── Memory/               # Local-first MemoryItem / Store / Manager
├── Services/AI/          # Provider abstraction + Mock
├── Nexus/                # Perception layer (Signals → Insights)
├── UI/
└── Tests/
```

## Nexus Philosophy

Nexus is Quicksilver’s **perception layer**. It observes only public signals, normalizes them, interprets patterns into insights, and applies persona voice only at presentation time.

### Fixed Issues (this pass)

| Issue | Fix |
|-------|-----|
| DeviceMetricsMonitor block observers leaked | Tokens stored and correctly removed in `stop()` |
| Health score only used network + battery | Extracted `HealthScoreCalculator` with network / power / storage / device |
| Persona identity scattered | `PersonaRegistry` is now the single lookup source |
| Missing observer cleanup on deinit | Both Battery and Device monitors call `stop()` in `deinit` |

### Privacy & Capability Boundaries

**Available:** Network path, Battery (explicit), Storage (FileManager), Thermal + Low Power Mode (ProcessInfo)

**Not available / not implemented:** Private APIs, continuous background location, other apps’ processes, high-frequency sampling, any data leaving the device.

### Health Scoring

`HealthScoreCalculator` is pure and testable. Weights: Network 35 %, Power 35 %, Storage 15 %, Device 15 %.

### Persona Architecture

- `PersonaConfiguration` remains the data model.
- `PersonaRegistry` owns lookup and validation.
- `PersonaManager` consumes the registry.
- Concrete `ForgePersona` / `QuicksilverPersona` / `EternalPersona` kept only for temporary UI bridge compatibility.

## Known Limitations

- No `.xcodeproj` yet → full `xcodebuild` and device tests cannot run in CI.
- Storage sampling is polled (FileManager has no change notification).
- Battery level is –1 when monitoring is unavailable.
- AutomationBridge still throws until real App Intents are registered.
- Long-term signal history is in-memory and bounded.

## Engineering Rules Applied
Analyze first • Public APIs only • Battery & privacy first • Modular boundaries • Focused commits • Clear documentation of limitations and fixes.
