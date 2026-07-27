# Quicksilver → SideStore (iPhone-only path)

**Target:** iPhone 14 (iOS 17 or later, including iOS 27 beta)  
**Minimum deployment target:** iOS 17.0  
**Goal:** Install Quicksilver via SideStore with zero Mac required.

## Prerequisites

1. SideStore (or SideStore + LiveContainer) already installed and working on the device.  
   If not yet installed, follow the pure on-device bootstrap (SideInstaller → SideStore).  
2. LocalDevVPN installed from the App Store and connected whenever you refresh or install.  
3. Free or paid Apple ID signed into SideStore.  
4. GitHub account that can trigger Actions on this repository.
5. Device running **iOS 17.0 or later**.

## Produce the IPA (cloud) — Unsigned path (no secrets needed)

1. On your iPhone, open the repository:  
   https://github.com/Toobadtokeep2026-star/Quicksilver
2. Go to **Actions** → **Archive IPA** → **Run workflow**.
3. Choose configuration (`Release` recommended).
4. Wait for the job to finish (usually 4–8 minutes on macos-15 runners).
5. Download the artifact named **Quicksilver-unsigned-IPA**.

The workflow always builds for generic iOS device with code signing disabled and packages a proper unsigned IPA (`Payload/Quicksilver.app`). SideStore will re-sign it with your Apple ID when you install.

Post-build checks now verify:
- `Quicksilver.app` exists
- Persona prompt files are present (or warn if missing)
- PrivacyInfo.xcprivacy is present (or warn)
- IPA contains `Payload/Quicksilver.app`

### Optional: Signed IPA (better reliability)

If you later add these repository secrets (Settings → Secrets and variables → Actions), the same workflow will also produce a development-signed IPA:

| Secret | Purpose |
|--------|---------|
| `BUILD_CERTIFICATE_BASE64` | Base64 of your .p12 development certificate |
| `P12_PASSWORD` | Password for the .p12 |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 of the matching .mobileprovision |
| `TEAM_ID` | (optional) Your Apple Team ID |
| `KEYCHAIN_PASSWORD` | (optional) Temporary keychain password |

When secrets are present you get both artifacts: unsigned + signed.

## Install on device

1. Download the IPA artifact from the finished workflow run (on your iPhone).
2. Open SideStore (LocalDevVPN must be connected).
3. Use **+** / **Install IPA** (or the equivalent import flow) and select the downloaded Quicksilver IPA.
4. Trust the new developer profile if prompted (Settings → General → VPN & Device Management).
5. Launch Quicksilver.

## First-run checklist

1. Settings → paste your xAI API key → enable AI Service.
2. Home → confirm persona switcher and Nexus health.
3. Diagnostics → live signals appear.
4. Memory → add a note, swipe delete, Clear All, Export.
5. Ask → send a message with the active persona.
6. Background the app 5–10 minutes, then return — state should survive.

## Refresh / reinstall

- SideStore certificates last 7 days on free Apple IDs.
- Keep LocalDevVPN connected and refresh Quicksilver from within SideStore before expiry.
- To update: trigger a new Archive IPA run, download the new IPA, install over the existing app in SideStore.

## Notes specific to this project

- Bundle ID: `com.quicksilver.app`
- Display name: Quicksilver
- Version: 0.1.0 (build 2+)
- No private APIs, no special entitlements required.
- Persona prompt files ship inside the IPA from `Resources/Personas/`.
- Privacy Manifest (`PrivacyInfo.xcprivacy`) is embedded.
- **Minimum deployment target is iOS 17.0** — the real API floor of this codebase (Observation, SwiftData, SwiftUI `.onChange(of:_:)`). A low floor maximises SideStore install compatibility and lets CI build with the shipping Xcode SDKs.
- Built with Swift 6 strict concurrency.

## Failure modes

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| Workflow fails to find .app | XcodeGen or build error | Check build-logs artifact |
| SideStore rejects unsigned IPA | Rare packaging issue | Re-run workflow or try signed path |
| App crashes on launch | Signing / trust issue | Trust the profile again, reboot |
| Keychain / AI fails | First-run permission or key missing | Re-enter key in Settings |
| Install fails with OS version error | Device below iOS 17 | Update to iOS 17 or later |
| Missing persona personality | Prompt file not embedded | Check Archive logs for resource warnings; fallback prompts still work |

No Mac, no USB, no AltServer required after SideStore itself is installed.
