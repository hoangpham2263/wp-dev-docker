#!/usr/bin/env bash
# Mỗi lần build: ghi WORDPRESS_PORT, MYSQL_PORT, PHPMYADMIN_PORT vào .env với giá trị random.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ENV_PATH="$PROJECT_ROOT/.env"

[[ -f "$ENV_PATH" ]] || { echo "No .env found"; exit 1; }

# Random port 5 chữ số, phải <= 65535 (giới hạn TCP). Tránh trùng khi chạy nhiều project.
WORDPRESS_PORT=$(( 10000 + RANDOM % 20000 ))   # 10000-29999
MYSQL_PORT=$(( 30000 + RANDOM % 20000 ))      # 30000-49999
PHPMYADMIN_PORT=$(( 50000 + RANDOM % 15536 )) # 50000-65535

set_port() {
  local key=$1 val=$2
  if grep -q "^${key}=" "$ENV_PATH" 2>/dev/null; then
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s|^${key}=.*|${key}=${val}|" "$ENV_PATH"
    else
      sed -i "s|^${key}=.*|${key}=${val}|" "$ENV_PATH"
    fi
  else
    # Chỉ thêm newline trước dòng mới nếu file chưa kết thúc bằng newline (tránh dính chữ / tránh dòng trống thừa)
    [[ $(tail -c1 "$ENV_PATH" 2>/dev/null) != $'\n' ]] && printf '\n' >> "$ENV_PATH"
    printf '%s=%s\n' "$key" "$val" >> "$ENV_PATH"
  fi
}

set_port "WORDPRESS_PORT" "$WORDPRESS_PORT"
set_port "MYSQL_PORT" "$MYSQL_PORT"
set_port "PHPMYADMIN_PORT" "$PHPMYADMIN_PORT"

# Xóa mọi dòng trống trong .env (chỉ giữ từng dòng một biến)
grep -v '^[[:space:]]*$' "$ENV_PATH" > "${ENV_PATH}.tmp" && mv "${ENV_PATH}.tmp" "$ENV_PATH"

echo "Ports in .env: WORDPRESS_PORT=$WORDPRESS_PORT, MYSQL_PORT=$MYSQL_PORT, PHPMYADMIN_PORT=$PHPMYADMIN_PORT"
