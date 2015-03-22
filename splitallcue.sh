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

function getDataFilename {
	basefile="$(removeExtension "$1")"
	datafile="$basefile.flac"
	if [ ! -f "$datafile" ]; then
		datafile="$basefile.ape"
	fi
	if [ ! -f "$datafile" ]; then
		basefile="$(removeExtension "$basefile")"
		datafile="$basefile.flac"
	fi
	if [ ! -f "$datafile" ]; then
		datafile="$basefile.ape"
	fi
	if [ -f "$datafile" ]; then
		echo "$datafile"
	fi
}

function convert {
	cuefile="$1"
	dst_dir=$(dirname "$2")

	datafile="$(getDataFilename "$cuefile")"
	if [ -f "$datafile" ]; then
		pushd "$dst_dir" >>/dev/null
		echoAndRun shnsplit -f "$cuefile" -t "%n %p - %t" -O never -o "flac flac -s --replay-gain --best -o %f -" "$datafile"
		popd >>/dev/null
	else
		echo "Could not find data file for $cuefile"
	fi
}

convertFilesWithExtension "$1" "$2" cue cue convert
