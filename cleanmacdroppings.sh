#!/bin/sh

# Clean out all of the dotfile crap that Mac OS insists on creating.

set -e -u

SRCDIR="$1"

find "$SRCDIR" \( -name "*.DS_Store" -or -name ".AppleDouble" -or -name "._*" -or -name "Thumbs.db" \) -delete
