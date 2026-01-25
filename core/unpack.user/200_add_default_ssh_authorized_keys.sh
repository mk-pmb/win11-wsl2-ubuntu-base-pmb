#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
echo D: 'Ensuring default SSH keys:'
CFG_AK="$HOME"/.config/ssh
mkdir --parents -- "$CFG_AK" || true
[ -L "$HOME"/.ssh ] || ln --symbolic --no-target-directory \
  -- .config/ssh "$HOME"/.ssh || exit $?$(
  echo E: 'Failed to create ~/.ssh symlink!' >&2)
CFG_AK+='/authorized_keys'
>>"$CFG_AK" || exit $?$(echo E: 'Failed to touch $CFG_AK!' >&2)
( LANG=C sed -re 's~^\xEF\xBB\xBF~~;s~\r~~' -- \
  cfg.@.defaults/ssh_authorized_keys.txt \
  cfg.@"$HOSTNAME"/ssh_authorized_keys.txt \
  2>/dev/null | grep -Pe '^\w' | grep -vFf "$CFG_AK" || true
) >>"$CFG_AK" || exit $?$(echo E: 'Failed to update $CFG_AK!' >&2)
