#!/usr/bin/env bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

[[ -f .env ]] || { echo "No .env"; exit 1; }
set -a
source .env 2>/dev/null || true
set +a

project_name="${PROJECT_NAME:-project}"
project_safe=$(echo "$project_name" | tr '[:upper:]' '[:lower:]' | tr ' -' '__' | tr -dc 'a-z0-9_')
project_safe="${project_safe:-project}"

# Default user: WP_ADMIN_USER from .env (set by wp-install) or normalized PROJECT_NAME
username="${1:-${WP_ADMIN_USER:-$project_safe}}"

if [[ -z "$username" ]]; then
  echo "Set PROJECT_NAME in .env or run: $0 <wordpress_username>"
  exit 1
fi

if [[ ! -d wordpress ]]; then
  echo "No wordpress folder. Run option 1 first."
  exit 1
fi

rm -f wordpress/autologin-*.php

token=$(openssl rand -hex 12)
filepath="wordpress/autologin-${project_safe}-${token}.php"

# Escape for use inside PHP single quotes (only ' needs escaping)
username_escaped="${username//\'/\\\\\'}"

cat > "$filepath" << PHP
<?php
require_once('wp-load.php');

if (!is_user_logged_in()) {
    \$user = get_user_by('login', '${username_escaped}');
    if (\$user) {
        wp_set_current_user(\$user->ID);
        wp_set_auth_cookie(\$user->ID, true);
        do_action('wp_login', \$user->user_login, \$user);
        wp_redirect(admin_url());
        exit;
    } else {
        echo '<div style="margin:40px auto;max-width:500px;padding:24px 32px;background:#fff3cd;border:1px solid #ffeeba;border-radius:8px;color:#856404;font-family:sans-serif;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.07);">';
        echo '<h2 style="margin-top:0;margin-bottom:12px;font-size:24px;">⚠️ Account Not Found</h2>';
        echo '<p style="margin:0;font-size:16px;line-height:1.5;">User "'.'${username_escaped}'.'" not found.</p>';
        echo '</div>';
    }
} else {
    wp_redirect(admin_url());
    exit;
}
PHP

echo "$filepath"
