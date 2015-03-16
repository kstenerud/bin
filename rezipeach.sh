#!/bin/bash

# For all known archives in the source directory and subdirs, create a 7-zip
# archive in the destination directory. Subdirs will be created in order to
# preserve the source directory structure.
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

SRCDIR="$1"
DSTDIR="$2"
TMPDIR=$(makeTempDir)

function convert {
	src_path="$1"
	shift
	dst_path="$1"
	shift
	extract_cmd="$@"

	pushd "$TMPDIR" >>/dev/null
	echoAndRun $extract_cmd "$src_path"
	echoAndRunQuiet 7z a -bd "$dst_path" *
	popd >>/dev/null
	rm -rf $TMPDIR/*
}

convertFilesWithExtension "$SRCDIR" "$DSTDIR" zip 7z convert unzip -qo
convertFilesWithExtension "$SRCDIR" "$DSTDIR" rar 7z convert unrar x -inul

rm -rf "$TMPDIR"
