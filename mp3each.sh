#!/bin/bash

# For all known sound files in the source directory and subdirs, create an mp3
# version in the destination directory. Subdirs will be created in order to
# preserve the source directory structure.
# @param SRCDIR (string) - The directory to search in.
# @param DSTDIR (string) - The directory to create files in.

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
	echoAndRun sox "$1" -C 4.01 "$2" >>/dev/null
}

convertFilesWithExtension "$1" "$2" flac mp3 convert
