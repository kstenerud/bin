#!/bin/bash

# For each file in the source directory and subdirs, create a 7-zip archive
# in the destination directory. Subdirs will be created in order to preserve
# the source directory structure.
# @param SRCDIR (string) - The directory to search in.
# @param DSTDIR (string) - The directory to create archives in.

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

function file_7zip {
	rel_path="$1"
	dst_dir="$2"

	rel_dir=$(dirname "$rel_path")
	strip_dir=$(stripPath "$rel_dir")
	file=$(basename "$rel_path")
	basefile=$(removeExtension "$file")

	src_path="$PWD/$rel_path"
	dst_dir="$dst_dir/$strip_dir"
	dst_path="$dst_dir/$basefile.7z"

	if [ ! -f "$dst_path" ]; then
		mkdir -p "$dst_dir"
		echo 7z a -bd "$dst_path" "$src_path"
		7z a -bd "$dst_path" "$src_path" >>/dev/null
	fi
}

forEachFile "$SRCDIR" file_7zip "$DSTDIR"
