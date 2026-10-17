#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

mkdir -p wordpress

if [ ! -f wordpress/wp-includes/version.php ]; then
  echo "Copy latest WordPress to ./wordpress..."
  docker run --rm -v "$PROJECT_ROOT/wordpress:/var/www/html" wordpress:latest sh -c 'cp -a /usr/src/wordpress/. /var/www/html/'
  echo "Done. ./wordpress has latest WordPress."
else
  echo "./wordpress already has WordPress. Skip."
fi
