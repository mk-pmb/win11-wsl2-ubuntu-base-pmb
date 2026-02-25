#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function bpp_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  set -o errexit -o pipefail
  cd /

  # Early preparations:
  pip_install pip

  # Stuff we may want for UI assistance and remote control:
  pip_install '
    comtypes
    mss         # Fast screen capture.
    pillow      # Graphics library. replaces the old PIL.
    psutil
    pyautogui   # Easy UI automation.
    pywebview
    pywin32     # Interact with host OS.
    pyyaml
    '

  # Surfing the interweb seems to be useful nowadays.
  pip_install '
    beautifulsoup4    # HTML/XML parser.
    httpx       # HTTP client similar to `requests` but async.
    requests    # Human-friendly HTTP client.
    '
}


function pip_install () {
  local INST=(
    python.exe -m pip # because the pip.exe alias may not be installed yet
    install
    --user
    --no-warn-script-location
    --disable-pip-version-check # Upgrading pip is our first task anyway.
    --upgrade
  )
  set -- $(printf -- '%s\n' "$@" | grep -oPe '^[\w\s\.\-]*')
  [ "$#" -ge 1 ] || return 0
  "${INST[@]}" "$@" || return $?$(
    echo E: "pip failed to install/upgrade {$*}, rv=$?" >&2)
}






bpp_cli_init "$@"; exit $?
