#!/usr/bin/env bash
set -euo pipefail

# Alternative installer using npx. Requires Node.js/npm to be installed.
if ! command -v npx >/dev/null 2>&1; then
  echo "npx not found. Install Node.js / npm first: https://nodejs.org/"
  exit 1
fi

npx opencode-mobile install
