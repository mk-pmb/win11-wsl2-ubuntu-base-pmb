#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function setup_basic_apt_packages () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly

  echo -n D: 'Check basic apt packages to install: '
  local LIST=(
    aptitude
    fuse3 # would otherwise be uninstalled when purging snapd.
    nano
    openssh-server
    pv
    screen
    squashfs-tools # would otherwise be uninstalled when purging snapd.
    unzip
    zip
    )
  local ITEM= TODO= APT="env debian_frontend='noninteractive' apt"
  for ITEM in "${LIST[@]}"; do
    [ -f "/usr/share/doc/$ITEM/copyright" ] ||
      TODO+=" ${ITEM%%:*}"
  done
  if [ -z "$TODO" ]; then
    echo 'None missing.'
  else
    echo 'Some packages are missing.'
    echo 'D: Update apt package lists:'
    $APT update || return $?
    echo 'D: Install missing apt packages:'
    $APT install --assume-yes -- $TODO || return $?
    echo 'D: Packages have been installed.'
  fi

  echo -n D: 'Check basic apt packages to remove: '
  LIST=(
    snapd
    # nope, would uninstall sudo. -> # ubuntu-pro-client{,-l10n}
    )
  TODO=
  for ITEM in "${LIST[@]}"; do
    [ -f "/usr/share/doc/$ITEM/copyright" ] || continue
    TODO+=" $ITEM"
  done
  if [ -z "$TODO" ]; then
    echo 'Found none.'
  else
    echo 'Found some.'
    ${APT}itude purge --assume-yes -- $TODO || return $?
    echo 'D: Packages have been purged.'
  fi
}










setup_basic_apt_packages "$@"; exit $?
