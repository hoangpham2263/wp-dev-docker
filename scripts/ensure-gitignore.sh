#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

cat > .gitignore << 'EOF'
wordpress/
.env
.DS_Store
*.log
EOF

echo ".gitignore"
