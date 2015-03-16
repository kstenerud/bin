#!/bin/bash

# For all known sound files in the source directory and subdirs, create an m4a
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
	echoAndRun avconv -i "$1" -vn -c:a libfdk_aac -vbr 3 -nostats -loglevel error "$2"
}

convertFilesWithExtension "$1" "$2" flac m4a convert
