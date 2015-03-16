#!/bin/bash

# For all known archives in the source directory and subdirs, create a 7-zip
# archive in the destination directory. Subdirs will be created in order to
# preserve the source directory structure.
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

function rezip_archive {
	rel_path="$1"
	shift
	dst_dir="$1"
	shift
	tmp_dir="$1"
	shift
	unzip_cmd="$@"

	rel_dir=$(dirname "$rel_path")
	strip_dir=$(stripPath "$rel_dir")
	file=$(basename "$rel_path")
	basefile=$(removeExtension "$file")

	src_path="$PWD/$rel_path"
	dst_dir="$dst_dir/$strip_dir"
	dst_path="$dst_dir/$basefile.7z"

	if [ ! -f "$dst_path" ]; then
		mkdir -p "$dst_dir"
		pushd "$tmp_dir" >>/dev/null
		echo $unzip_cmd "$src_path"
		$unzip_cmd "$src_path" >>/dev/null
		echo 7z a -bd "$dst_path" *
		7z a -bd "$dst_path" * >>/dev/null
		popd >>/dev/null
		rm -rf $tmp_dir/*
	fi
}

TMPDIR=$(makeTempDir)
forEachFileWithExtension "$SRCDIR" zip rezip_archive "$DSTDIR" "$TMPDIR" unzip -qo
forEachFileWithExtension "$SRCDIR" rar rezip_archive "$DSTDIR" "$TMPDIR" unrar x
rm -rf "$TMPDIR"
