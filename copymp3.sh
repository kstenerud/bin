#!/bin/bash

# Copy all mp3 files from src to dst, preserving directory structure.
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

function copy_mp3 {
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
		echo cp "$src_path" "$dst_path"
		cp "$src_path" "$dst_path" >>/dev/null
	fi
}

forEachFileWithExtension "$SRCDIR" flac copy_mp3 "$DSTDIR"
