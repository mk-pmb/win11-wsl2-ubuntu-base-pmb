#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function disable_microsoft_store_exe_stubs () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  cd /mnt/c || return $?$(
    echo E: $FUNCNAME: 'Failed to chdir to Windows drive!' >&2)
  local APP_DATA="$(cmd.exe /c 'echo %LocalAppData%')"
  APP_DATA="${APP_DATA//$'\r'/}"
  [ -n "$APP_DATA" ] || return $?$(
    echo E: $FUNCNAME: 'Failed to detect LocalAppData path!' >&2)
  APP_DATA="$(wslpath -u -- "$APP_DATA")"
  [ -d "$APP_DATA" ] || return $?$(
    echo E: $FUNCNAME: 'Failed to convert LocalAppData path!' >&2)
  local STUBS_DIR="$APP_DATA"/Microsoft/WindowsApps
  [ -d "$STUBS_DIR" ] || return $?$(
    echo E: $FUNCNAME: 'Cannot find stubs dir path!' >&2)
  cd -- "$STUBS_DIR" || return $?$(
    echo E: $FUNCNAME: 'Cannot chdir to the stubs dir path!' >&2)

  local PREFIXES=(
    bash
    node
    perl
    pip
    python
    ubuntu
    winget
    wsl
    )
  local PRFX= EXE= BUF=
  local STUB_FILES=()
  for PRFX in "${PREFIXES[@]}"; do
    for EXE in "$PRFX"{,[0-9]*}.exe; do
      [ -f "$EXE" ] || continue
      BUF="$(head --bytes=16 -- "$EXE" | tr -c A-Z _)"
      case "$BUF" in
        MZ ) STUB_FILES+=( "$EXE" );;
      esac

    done
  done

  local N_STUBS="${#STUB_FILES[@]}"
  echo D: "Found $N_STUBS stub file(s) in $PWD."
  [ "$N_STUBS" -ge 1 ] || return 0

  # The stubs only have 2 visible bytes ("MZ") in the main data stream,
  # but writing the "MZ" as a regular file does not trigger the alias
  # mechanism. We can thus assume that tie App ID for the store is
  # contained in other meta data or data channel(s) that we cannot easily
  # recreate. Thus we should not delete those magic files, just move them
  # out of the PATH.
  local BAK_DIR='stubs_disabled_by_wub/'
  mkdir --parents -- "$BAK_DIR" || true
  mv --no-clobber --verbose --target-directory="$BAK_DIR" \
    -- "${STUB_FILES[@]}" || return $?
}










disable_microsoft_store_exe_stubs "$@"; exit $?
