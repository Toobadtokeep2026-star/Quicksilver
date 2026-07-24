# Nexus Intelligence Pipeline

Strict layered flow. No layer skips another.

```
Sensors (DiagnosticProvider)
        ↓
Normalizer (SignalProcessor)
        ↓
Ingress / Rate-limit (SignalPipeline)
        ↓
Analyzer + State (NexusCoordinator)
        ↓
Insight Engine (persona-agnostic)
        ↓
Persona Interpretation (presentation only)
```

## Layer responsibilities

| Layer | Owns | Does not own |
|-------|------|--------------|
| **Sensors** | Raw observations via public Apple APIs | Interpretation, UI, AI |
| **Normalizer** | Conversion to unified `Signal` | Decisions, persona voice |
| **Pipeline** | Deduplication, EventBus publication | Insights, persona |
| **Coordinator** | Lifecycle, state accumulation | Prompt creation, UI |
| **Insight Engine** | Meaningful pattern → Insight | Persona tone |
| **Persona layer** | Voice / framing at presentation | Signal processing |

## Privacy boundaries

- Public APIs only
- No continuous location
- No private sysctl / kernel metrics
- No data leaves the device through Nexus

## Adding a new sensor

1. Conform to `DiagnosticProvider` (and a specific monitoring protocol if needed)
2. Produce raw values only
3. Add a Normalizer method on `SignalProcessor`
4. Wire into `NexusCoordinator.start()`
5. Optionally extend `InsightEngine` for new insight rules
