#!/usr/bin/env bash
set -e
ENV_FILE="${1:-.env}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_PATH="$PROJECT_ROOT/.env"

[[ -f "$ENV_PATH" ]] || { echo "No .env found"; exit 1; }

value=$(grep -E '^PROJECT_NAME=' "$ENV_PATH" | cut -d= -f2- | sed 's/^[" ]*//;s/[" ]*$//')
[[ -n "$value" ]] || { echo "PROJECT_NAME is empty in .env"; exit 1; }

normalized=$(echo "$value" | tr '[:upper:]' '[:lower:]' | tr ' -' '__' | tr -dc 'a-z0-9_')
[[ -n "$normalized" ]] || { echo "PROJECT_NAME is empty after normalize"; exit 1; }

if [[ "$(uname)" == "Darwin" ]]; then
  sed -i '' "s|^PROJECT_NAME=.*|PROJECT_NAME=$normalized|" "$ENV_PATH"
else
  sed -i "s|^PROJECT_NAME=.*|PROJECT_NAME=$normalized|" "$ENV_PATH"
fi

echo "PROJECT_NAME normalized: \"$value\" → $normalized"
