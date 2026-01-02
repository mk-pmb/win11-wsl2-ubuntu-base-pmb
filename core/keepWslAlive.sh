#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function kwa_cli_init () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local REPO_DIR="$(readlink -m -- "$BASH_SOURCE"/../..)"
  # cd -- "$REPO_DIR" || return $?

  local WUBU_DIR='/mnt/wsl/win11-wsl2-ubuntu-base-pmb'
  mkdir --parents -- "$WUBU_DIR"

  kwa_"$@" || return $?
}


function kwa_on_startup () {
  kwa_start_basics |& tee -- "$WUBU_DIR/start_basics.latest.log"
  local KA_NAME='keep-wsl2-ubuntu-alive'
  local KA_DURA='9009009d'
  # ^-- Probably sufficient beyond host Windows' End-of-Life.
  exec -a "$KA_NAME" sleep "$KA_DURA"
}


function kwa_start_basics () {
  wub core/portfwd 513 = 22 & disown $!

  echo D: $FUNCNAME: 'Waiting for prep tasks to finish.'
  wait
  echo D: $FUNCNAME: 'All prep tasks have finished.'
}














kwa_cli_init "$@"; exit $?
