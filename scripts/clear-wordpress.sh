#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

if [ ! -d wordpress ]; then
  echo "No wordpress folder. Done."
  exit 0
fi

echo "Clear ./wordpress (next start will copy latest WP)..."
rm -rf wordpress
mkdir -p wordpress
echo "Done. Run ./start 1 to get latest WordPress."
