#!/bin/bash

# For each file in the source directory and subdirs, create a 7-zip archive
# in the destination directory. Subdirs will be created in order to preserve
# the source directory structure.
# @param SRCDIR (string) - The directory to search in.
# @param DSTDIR (string) - The directory to create archives in.

# -- Find util.sh ------------------------------------------------------------
set -e -u
SCRIPTNAME="$0"
if [ ! -e "$SCRIPTNAME" ]; then
  case "$SCRIPTNAME" in
    (*/*) exit 1;;
    (*) SCRIPTNAME="$(command -v -- "$SCRIPTNAME")" || exit;;
  esac
fi
SCRIPTPATH="$(cd -P -- "$(dirname -- "$SCRIPTNAME")" && pwd -P)" || exit
source "$SCRIPTPATH/util.sh"
# ----------------------------------------------------------------------------

function convert {
	echoAndRun 7z a -bd "$1" "$2" >>/dev/null
}

convertFiles "$1" "$2" 7z convert
