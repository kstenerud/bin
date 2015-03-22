#!/bin/sh

set -e -u

SRCDIR="$1"

chown -R nobody:nogroup "$SRCDIR"
find "$SRCDIR" -type f -exec chmod 644 "{}" \;
find "$SRCDIR" -type d -exec chmod 755 "{}" \;
