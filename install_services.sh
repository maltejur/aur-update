#!/usr/bin/bash
set -e
cd "$(dirname "$0")"

if [ $(whoami) == "root" ]; then
  echo "This script should be run by the user account, not root."
  exit 1
fi
if ! command -v create_timer.sh &>/dev/null; then
  echo "create_timer.sh was not found. Clone the 'scripts' repo first and add it to PATH."
  exit 1
fi

create_timer.sh aur_update "Build aur_update image" "$(pwd)/aur_update.sh" 3d "" "$USER" -q
create_timer.sh aur_update aur_update "$(pwd)/aur_update.sh" 6h "" "$USER" -q
