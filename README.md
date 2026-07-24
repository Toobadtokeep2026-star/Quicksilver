# Quicksilver

Native iOS intelligence framework: modular architecture, adaptive personas, Nexus diagnostics, Memory, and AI.

```
SENSE (Nexus) → THINK (Core + AI + Memory) → EXPRESS (Personas + UI)
```

## Cloud development (no local Mac required)

Every push and pull request to `main` runs on **GitHub-hosted macOS runners**:

| Job | What it does |
|-----|----------------|
| **Structure & Contracts** | Verifies modular layout and Core protocols |
| **SPM Unit Tests** | `swift test` for Core / Memory / Personas / Nexus / AI |
| **iOS Simulator Build** | XcodeGen → `xcodebuild` for iPhone Simulator (no signing) |

**Manual runs from your phone:** GitHub → Actions → *Quicksilver CI* → *Run workflow*.

**IPA for SideStore:** Actions → *Archive IPA* → *Run workflow*.  
Requires repository secrets (`BUILD_CERTIFICATE_BASE64`, `P12_PASSWORD`, `BUILD_PROVISION_PROFILE_BASE64`, optional `TEAM_ID` / `KEYCHAIN_PASSWORD`). Without secrets the job still compiles for device and explains what is missing.

Artifacts (logs, and IPA when signing is configured) are downloadable from the workflow run page on your iPhone.

## Status

Production hardening complete. See [Documentation/HARDENING.md](Documentation/HARDENING.md).

## Surfaces

| Screen | Role |
|--------|------|
| **Home** | Persona switcher, Nexus health, latest insight |
| **Ask** | Persona-aware chat with Memory history |
| **Memory** | Policy-filtered notes, delete / clear / export |
| **Diagnostics** | Live insights + signals |
| **Settings** | xAI key (Keychain) + AI feature flag |

## Architecture

[Documentation/ARCHITECTURE.md](Documentation/ARCHITECTURE.md)

Core owns contracts. Modules implement. UI only presents. Nexus stays persona-agnostic.

## Local Mac workflow (optional)

```bash
brew install xcodegen
xcodegen generate
open Quicksilver.xcodeproj
# or: swift test
```

## On-device (iPhone 14 / iOS 27 beta) — SideStore path

Full instructions: **[Documentation/SIDESTORE.md](Documentation/SIDESTORE.md)**

1. Trigger **Actions → Archive IPA → Run workflow** (Release).
2. Download the IPA artifact from the finished run.
3. Install the IPA in SideStore (LocalDevVPN connected).
4. Settings → paste xAI key → enable AI Service.
5. Validate Home → Diagnostics → Memory → Ask → persona switch.

Requires repository secrets for a signed IPA. Without them the job still compiles for device and uploads diagnostics.

No private APIs. Public Apple frameworks only. Compatible with free Apple ID + 7-day refresh cycle.

## Personas

| Persona | Role |
|---------|------|
| Quicksilver | Adaptive daily intelligence |
| Forge | Disciplined builder |
| Eternal | Continuity & long-term coherence |

Prompts: `Resources/Personas/*.txt` (embedded fallback if missing).

## Principles

- Privacy first, on-device by default
- Modular boundaries non-negotiable
- Focused commits, working vertical slices
- No autonomous agent loops

## License

Private / All rights reserved until otherwise stated.
