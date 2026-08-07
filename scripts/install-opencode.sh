#!/usr/bin/env bash
set -euo pipefail

# WARNING: piping a remote installer directly into bash is a security risk.
# This file intentionally runs the installer exactly as requested.
# Run in a trusted environment.

curl -fsSL https://opencode.ai/install | bash
