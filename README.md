# Quicksilver

Native iOS intelligence framework: modular architecture, adaptive personas, Nexus diagnostics, Memory, and AI.

**Primary device target:** iPhone 14 / **iOS 27**  
**Build floor (CI / SideStore IPA):** iOS 18.0 — intentional so current GitHub runners can still produce installable binaries that run on iOS 27.

```
SENSE (Nexus) → THINK (Core + AI + Memory) → EXPRESS (Personas + UI)
```

## Cloud development (no local Mac required)

Every push and pull request to `main` runs on **GitHub-hosted macOS runners**:

| Job | What it does |
|-----|----------------|
| **Structure & Contracts** | Verifies modular layout, Core protocols, and Privacy Manifest |
| **SPM Unit Tests** | `swift test` for Core / Memory / Personas / Nexus / AI |
| **iOS Simulator Build** | XcodeGen → `xcodebuild` for iPhone Simulator (no signing) |

**Manual runs from your phone:** GitHub → Actions → *Quicksilver CI* → *Run workflow*.

**IPA for SideStore:** Actions → *Archive IPA* → *Run workflow*.  
Produces an unsigned IPA by default (SideStore re-signs). Optional signed path available when certificate secrets are present. Post-build checks verify app bundle, persona prompts, and IPA structure.

Artifacts (logs + IPA) are downloadable from the workflow run page on your iPhone.

## Releasing

Releases are tag-driven. Push a `v*.*.*` tag to `main` and the **Release** workflow runs:

1. Unit tests with code coverage on an iPhone 16 simulator.
2. If App Store Connect secrets are present → Fastlane `beta` lane archives and uploads to **TestFlight**.
3. If secrets are absent → builds an **unsigned IPA** for SideStore.
4. Creates a GitHub Release with auto-generated Conventional Commits notes and attaches the IPA.

```bash
git tag v0.1.0
git push origin v0.1.0
```

Fastlane lanes (`fastlane/Fastfile`): `build`, `test`, `beta`.

## Status

SideStore hardening pass complete (Privacy Manifest, monitor isolation, Archive verification, DependencyContainer error handling). Release workflow + Fastlane lanes added. Primary validation device is iOS 27. See [Documentation/HARDENING.md](Documentation/HARDENING.md).

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
# or: fastlane test
```

Requires Xcode with an iOS SDK. CI currently uses the iOS 18 SDK; the resulting binary runs on iOS 27.

## On-device (iPhone 14 / iOS 27) — SideStore path

Full instructions: **[Documentation/SIDESTORE.md](Documentation/SIDESTORE.md)**

1. Trigger **Actions → Archive IPA → Run workflow** (Release).
2. Download the **Quicksilver-unsigned-IPA** artifact from the finished run.
3. Install the IPA in SideStore (LocalDevVPN connected).
4. Settings → paste xAI key → enable AI Service.
5. Validate Home → Diagnostics → Memory → Ask → persona switch.

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
