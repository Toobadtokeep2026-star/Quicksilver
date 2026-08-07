#!/usr/bin/env bash
set -euo pipefail

# Push the current branch to origin.
# Usage: ./scripts/push.sh [--force] [remote]
# Defaults: remote=origin, no force.

REMOTE="${2:-origin}"
FORCE=false

if [[ "${1:-}" == "--force" ]]; then
  FORCE=true
  REMOTE="${2:-origin}"
elif [[ -n "${1:-}" && "${1:-}" != "--force" ]]; then
  REMOTE="$1"
fi

# Ensure we are inside a git repo
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: not a git repository" >&2
  exit 1
fi

BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$BRANCH" == "HEAD" ]]; then
  echo "error: detached HEAD — checkout a branch first" >&2
  exit 1
fi

# Show status
echo "→ Branch:  $BRANCH"
echo "→ Remote:  $REMOTE"
echo "→ Ahead:   $(git rev-list --count @{u}..HEAD 2>/dev/null || echo '?') commit(s)"
echo

if [[ "$FORCE" == true ]]; then
  echo "Force-pushing $BRANCH → $REMOTE ..."
  git push --force-with-lease "$REMOTE" "$BRANCH"
else
  echo "Pushing $BRANCH → $REMOTE ..."
  git push "$REMOTE" "$BRANCH"
fi

echo "Done."
