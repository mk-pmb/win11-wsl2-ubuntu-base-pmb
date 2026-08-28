#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
set -e

# For why we use a bogus hash instead of locking the account, see chapter
# "The problem" in https://github.com/mk-pmb/ansible-bogus-linux-pwhash .
# (Most important benefit: You can use all regular password lock mechanisms
# for locking, and later unlock them with some custom hardened ceremony.)

BOGUS_PWHASH='$6$fakesalt$::::::::::::=='
BOGUS_PWHASH="${BOGUS_PWHASH//:/==bogus}"
sudo usermod --password "$BOGUS_PWHASH" -- "$(whoami)"
