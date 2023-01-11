#!/bin/sh
set -e
cd "$(dirname "$0")"

if [ ! -f ./_gh_token ]; then
  echo "Error: GitHub Token was not found. Place your GitHub token in _utils/_gh_token" >&2
  exit 1
fi
if [ $# -ne 1 ]; then
  echo "Usage: $0 <GH_USER>/<GH_REPO>" >&2
  exit 1
fi

curl -s --header "Authorization: token $(cat ./_gh_token)" \
  https://api.github.com/repos/$1/releases |
  jq -r '.[0].tag_name' |
  sed 's/^v//' |
  cat
