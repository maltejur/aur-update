#!/bin/sh
set -e

if [ ! -f ./_gh_token ]; then
  echo "Error: GitHub Token was not found. Place your GitHub token in _utils/_gh_token"
  exit 1
fi
if [ $# -lt 1 ]; then
  echo "Usage: $0 <gh_user>/<gh_repo> <?branch>"
  exit 1
fi

if [ $# -eq 1 ]; then
  curl -s --header "Authorization: token $(cat ./_gh_token)" \
    "https://api.github.com/repos/$1/branches" |
    jq -r '.[0].commit.sha'
else
  curl -s --header "Authorization: token $(cat ./_gh_token)" \
    "https://api.github.com/repos/$1/branches" |
    jq -r '.[] | select(.name=="'$2'") | .commit.sha'
fi
