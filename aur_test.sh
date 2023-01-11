#!/usr/bin/bash
set -e
cd "$(dirname "$0")"
if [ ! -v name ]; then
  rm -rf /tmp/aur_update_log
fi
source _utils/echo_helpers.sh
source _utils/docker.sh

if [ $# -ne 1 ]; then
  echo "Usage: $0 <package_name>"
  exit 1
fi

export name=$1
export version=$(sh $name/_version.sh)
if [ -z "$version" ]; then
  exit 1
fi

echo_action "Testing $name $version, see /tmp/aur_update_log for live log"

echo_action_start "Calculating checksum"
envsubst '${version}' <$name/PKGBUILD.template >$name/PKGBUILD
source $name/PKGBUILD
export tarball_url="${source##*::}"
tmpfile=$(mktemp)
curl -Lo $tmpfile $tarball_url 1>>/tmp/aur_update_log 2>>/tmp/aur_update_log
export sha256=$(sha256sum $tmpfile | cut -d' ' -f1)
echo_action_end "Has checksum $sha256"

echo_action_start "Generating PKGBUILD and .SRCINFO"
envsubst '${version} ${sha256}' <$name/PKGBUILD.template >$name/PKGBUILD
echo "[debug] START OF PKGBUILD --------------------" >>/tmp/aur_update_log
cat $name/PKGBUILD >>/tmp/aur_update_log
echo "[debug] END OF PKGBUILD ----------------------" >>/tmp/aur_update_log
run_docker bash -c "cd aur_update/$name && makepkg --printsrcinfo >.SRCINFO"
echo "[debug] START OF .SRCINFO --------------------" >>/tmp/aur_update_log
cat $name/.SRCINFO >>/tmp/aur_update_log
echo "[debug] END OF .SRCINFO ----------------------" >>/tmp/aur_update_log
source $name/PKGBUILD
echo_action_end "Generated PKGBUILD and .SRCINFO"

for template in $(find $name/*.desktop.template 2>/dev/null); do
  file=${template%".template"}
  echo_action_start "Generating $file"
  envsubst '${version} ${sha256}' <$template >$file
  echo "[debug] START OF $file --------------------" >>/tmp/aur_update_log
  cat $file >>/tmp/aur_update_log
  echo "[debug] END OF $file ----------------------" >>/tmp/aur_update_log
  echo_action_end "Generated $file file"
done

echo_action_start "Testing PKGBUILD"
if ! run_docker bash -c "export tmpdir=\$(mktemp -d) && cp aur_update/$name/* \$tmpdir && cd \$tmpdir && paru --noconfirm -Syu $(echo ${depends[@]}) $(echo ${makedepends[@]}) && makepkg -s" 1>>/tmp/aur_update_log 2>>/tmp/aur_update_log; then
  echo_action_fail "Failed to build PKGBUILD"
  exit 1
fi
echo_action_end "PKGBUILD is valid"
