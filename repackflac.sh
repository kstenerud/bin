#!/bin/bash

# Repack, replaygain, and sanitize metadata for all flac files.
# Subdirs will be created in order to preserve the source directory structure.
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

function containsTag {
	tag="${1%=*}"
	for element in "${@:2}"
	do
		[[ "$element" == "$tag" ]] && return 0
	done
	return 1
}

function printValidTags {
	filename="$1"
	valid_tags=("artist" "title" "date" "genre")
	metaflac --export-tags-to=- "$filename" | while read line
	do
		if containsTag "${line,,}" "${valid_tags[@]}"
		then
			echo $line
		fi
	done
}


TMPDIR=$(makeTempDir)

function convert {
	src_path="$1"
	dst_path="$2"
	tmp_path="$(addPath "$TMPDIR" "$(basename "$dst_path")")"
	cp "$src_path" "$tmp_path"
	id3v2 -D "$tmp_path" >>/dev/null
	metaflac --remove-all "$tmp_path"
	printValidTags "$src_path" | metaflac --import-tags-from=- "$tmp_path"
	echoAndRun flac -s --replay-gain --best "$tmp_path" --force
	metaflac --add-seekpoint=5s "$tmp_path"
	mv "$tmp_path" "$dst_path"
}

convertFilesWithExtension "$1" "$2" flac flac convert

rm -rf "$TMPDIR"
