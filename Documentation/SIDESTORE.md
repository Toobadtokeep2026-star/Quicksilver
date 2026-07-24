# Quicksilver → SideStore (iPhone-only path)

**Target:** iPhone 14 / iOS 27 beta  
**Goal:** Install Quicksilver via SideStore with zero Mac required.

## Prerequisites

1. SideStore (or SideStore + LiveContainer) already installed and working on the device.  
   If not yet installed, follow the pure on-device bootstrap (SideInstaller → SideStore).  
2. LocalDevVPN installed from the App Store and connected whenever you refresh or install.  
3. Free or paid Apple ID signed into SideStore.  
4. GitHub account that can trigger Actions on this repository.

## Produce the IPA (cloud)

1. On your iPhone, open the repository in Safari or the GitHub app:  
   https://github.com/Toobadtokeep2026-star/Quicksilver
2. Go to **Actions** → **Archive IPA** → **Run workflow**.
3. Choose configuration (`Release` recommended).
4. Wait for the job to finish (usually 4–8 minutes on macos-15 runners).

### Signing secrets (required for a real installable IPA)

Add these repository secrets (Settings → Secrets and variables → Actions):

| Secret | Purpose |
|--------|---------|
| `BUILD_CERTIFICATE_BASE64` | Base64 of your .p12 development certificate |
| `P12_PASSWORD` | Password for the .p12 |
| `BUILD_PROVISION_PROFILE_BASE64` | Base64 of the matching .mobileprovision |
| `TEAM_ID` | (optional) Your Apple Team ID |
| `KEYCHAIN_PASSWORD` | (optional) Temporary keychain password |

Without the three core secrets the workflow still compiles for device and uploads logs, but does **not** produce an IPA.

When secrets are present the job:

- Generates the Xcode project with XcodeGen
- Archives for generic iOS device
- Exports a development IPA
- Uploads the `.ipa` as a workflow artifact

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
- No private APIs, no special entitlements required.
- Persona prompt files ship inside the IPA from `Resources/Personas/`.
- Minimum deployment target is iOS 17.0 (compatible with iOS 27).

## Failure modes

| Symptom | Likely cause | Action |
|---------|--------------|--------|
| Workflow produces no IPA | Missing signing secrets | Add the three required secrets |
| SideStore rejects IPA | Wrong certificate / team mismatch | Re-export with matching development profile |
| App crashes on launch | Signing / trust issue | Trust the profile again, reboot |
| Keychain / AI fails | First-run permission or key missing | Re-enter key in Settings |

No Mac, no USB, no AltServer required after SideStore itself is installed.
