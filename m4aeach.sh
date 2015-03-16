#!/bin/bash

# For all known sound files in the source directory and subdirs, create an m4a
# version in the destination directory. Subdirs will be created in order to
# preserve the source directory structure.
# @param SRCDIR (string) - The directory to search in.
# @param DSTDIR (string) - The directory to create files in.

# -- Find util.sh ------------------------------------------------------------
set -e -u
SCRIPTNAME=$0
if [ ! -e "$SCRIPTNAME" ]; then
  case $SCRIPTNAME in
    (*/*) exit 1;;
    (*) SCRIPTNAME=$(command -v -- "$SCRIPTNAME") || exit;;
  esac
fi
SCRIPTPATH=$(cd -P -- "$(dirname -- "$SCRIPTNAME")" && pwd -P) || exit
source "$SCRIPTPATH/util.sh"
# ----------------------------------------------------------------------------

SRCDIR=$(stripPath "$1")
DSTDIR=$(getAbsolutePath "$2")

function convert_m4a {
	rel_path="$1"
	dst_dir="$2"

	rel_dir=$(dirname "$rel_path")
	strip_dir=$(stripPath "$rel_dir")
	file=$(basename "$rel_path")
	basefile=$(removeExtension "$file")

	src_path="$PWD/$rel_path"
	dst_dir="$dst_dir/$strip_dir"
	dst_path="$dst_dir/$basefile.m4a"

	if [ ! -f "$dst_path" ]; then
		mkdir -p "$dst_dir"
		echo avconv -i "$src_path" -vn -c:a libfdk_aac -vbr 3 -nostats -loglevel error "$dst_path"
		avconv -i "$src_path" -vn -c:a libfdk_aac -vbr 3 -nostats -loglevel error "$dst_path"
	fi
}

forEachFileWithExtension "$SRCDIR" flac convert_m4a "$DSTDIR"
