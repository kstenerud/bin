#!/bin/bash

set -eu

#RESIZED_X=1920
#RESIZED_Y=1080
RESIZED_X=1280
RESIZED_Y=720
QUALITY=92

declare -A NORESIZE_DIRS
NORESIZE_DIRS[passocorto]=true

convert_image() {
	local srcfile=$1
	local dstdir=$2

	local filename="$(basename "$srcfile")"
	local base="${filename%.*}"
	local ext="$(echo "${filename##*.}" | tr '[:upper:]' '[:lower:]')"

	local img_w="$(gm identify -format "%w %h %Q" "$srcfile")"
	local img_q="$(echo $img_w | cut -d' ' -f3)"
	local img_h="$(echo $img_w | cut -d' ' -f2)"
	local img_w="$(echo $img_w | cut -d' ' -f1)"
	local wanted_w=$RESIZED_X
	local wanted_h=$RESIZED_Y
	if (( $img_h > $img_w )); then
		wanted_w=$RESIZED_Y
		wanted_h=$RESIZED_X
	fi

	local should_convert=false

	local quality_arg=""
	if (( $img_q > $QUALITY )); then
		quality_arg="-quality $QUALITY"
		should_convert=true
	fi

	local resize_arg=""
	if (( $img_w > $wanted_w )) || (( $img_h > $wanted_h )); then
		resize_arg="-resize ${wanted_w}x${wanted_h}"
		should_convert=true
	fi

	if [ "$ext" != "jpg" ] && [ "$ext" != "jpeg" ]; then
		should_convert=true
	fi

	if [ $should_convert == true ]; then
		gm convert "$srcfile" $quality_arg $resize_arg "$dstdir/$base.$ext"
	else
		cp "$srcfile" "$dstdir/$base.$ext"
	fi
}

convert_dir() {
	local srcdir=$1
	local dstdir=$2

	if ! [ -d "$dstdir" ]; then
		mkdir -p "$dstdir"
	fi

	find "$srcdir" -type f -print0 | while IFS= read -r -d '' file; do
		convert_image "$file" "$dstdir"
	done
}

make_cbz() {
	local srcdir="$1"
	local dstfile="$2"

	pushd "$srcdir" >/dev/null
	zip -q -0 -r "$dstfile" *
	popd >/dev/null
}

process_dir() {
	local basedir="$1"
	local dstdir="$2"

	if ! [ -d "$dstdir" ]; then
		mkdir -p "$dstdir"
	fi

	for name in $(ls $basedir); do
		local srcdir="$basedir/$name"
		echo "Processing $name"
		dstfile="$(readlink -f "$dstdir/$name.cbz")"
		if [ ${NORESIZE_DIRS[$name]+_} ]; then
			make_cbz "$srcdir" "$dstfile"
		else
			local tmpdir=$(mktemp -d -t cbz-XXXXXXXXXX)
			convert_dir "$srcdir" "$tmpdir"
			make_cbz "$tmpdir" "$dstfile"
			rm -r "$tmpdir"
		fi
	done
}

if [ "$#" -ne 2 ]; then
	echo "Usage: $0 <pics dir> <dst dir>"
	exit 1
fi

SRCPATH="$1"
DSTPATH="$2"

process_dir "$SRCPATH" "$DSTPATH"
