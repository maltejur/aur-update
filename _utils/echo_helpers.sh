#!/bin/bash
set -e

echo_action() {
  echo "-> $1"
  echo "-> $1" >>/tmp/aur_update_log
}

echo_action_start() {
  echo -n "-> $1..."
  echo "-> $1..." >>/tmp/aur_update_log
}

echo_action_end() {
  echo -e "\r\033[K-> $1"
  echo "-> $1" >>/tmp/aur_update_log
}

echo_action_fail() {
  echo
  echo -e "\033[5m\033[31m!!! $1 !!!\033[0m (See the error in /tmp/aur_update_log)"
  echo >>/tmp/aur_update_log
  echo "!!! $1 !!!" >>/tmp/aur_update_log
  touch $name/_broken
  failed=true
}
