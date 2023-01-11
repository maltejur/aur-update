#!/usr/bin/bash
set -e
cd "$(dirname "$0")"
rm -rf /tmp/aur_update_log
source _utils/echo_helpers.sh
source _utils/docker.sh

run_docker() {
  docker run --rm -v $(readlink -f .):/home/user/aur_update maltejur/aur_update "$@"
}

for file in */_version.sh; do
  if [[ $file == _* ]]; then
    continue
  fi
  name=$(echo $file | cut -d/ -f1)
  echo -e "\n\033[1m$name:\033[0m"
  echo -e "\n$name:" >>/tmp/aur_update_log
  if [[ -f "$name/_broken" ]]; then
    echo_action "Skipping because marked as broken"
    continue
  fi
  echo_action_start "Checking for updates"
  old_version=$(cat $name/_version 2>/dev/null || echo 0)
  export version=$(sh $file)
  # if dpkg --compare-versions "$(echo $version | sed 's/^v//')" gt "$(echo $old_version | sed 's/^v//')"; then
  if [ ! "$(echo $version | sed 's/^v//')" == "$(echo $old_version | sed 's/^v//')" ]; then
    echo_action_end "Is outdated ($old_version >>> $version)"
    if ! (source aur_test.sh $name); then
      failed=true
      continue
    fi

    echo_action_start "Committing changes"
    if ! (cd $name && git add . && git commit -m "Update to $version" >>/tmp/aur_update_log); then
      echo_action_fail "Failed to commit changes"
      continue
    fi
    echo_action_end "Commited changes"

    echo_action_start "Pushing changes"
    if ! (cd $name && git push 1>>/tmp/aur_update_log 2>>/tmp/aur_update_log); then
      echo_action_fail "Failed to push changes"
      continue
    fi
    echo_action_end "Pushed changes"

    echo_action_start "Saving version"
    echo $version >$name/_version
    echo_action_end "Saved new version"
  else
    echo_action_end "Is up to date ($old_version >>> $version)"
  fi
done
echo

if [[ $failed == "true" ]]; then
  echo_action_start "Sending notification about failed build via email"
  smtp-cli --from pushnotify@shorsh.de --to maltejur@dismail.de --subject "aur_update.sh error" --body-html "<p>Greetings,</p><p>there were errors in the <code>aur_update.sh</code> script. Here is the build log: </p><pre>$(cat /tmp/aur_update_log)</pre><p>Have a great day,<br/>The Pushnotify Delivery Service</p>" >/dev/null || true
  echo_action_end "Sent notification about failed build via email"
fi
