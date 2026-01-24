#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e
[ -d "$WUB_REPO_DIR" ] || exit 2$(
  echo E: "WUB_REPO_DIR is not a directory: $WUB_REPO_DIR" >&2)
ln --symbolic --force --no-target-directory \
  -- "$WUB_REPO_DIR"/wub.sh /usr/local/bin/wub
ln --symbolic --force --no-target-directory \
  -- "$WUB_REPO_DIR"/core/wubCmdReexecInCmdExe.sh \
  /usr/local/bin/wub.cmd
