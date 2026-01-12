#!/bin/sh

set -e

CraneDigest() {
	local IMAGE=$1
	crane digest "$IMAGE" 2>/dev/null || true
}

CraneCopy() {
	local SOURCE=$1
	local TARGET=$2
	crane copy --jobs 1 "$SOURCE" "$TARGET"
}

CraneAdvancedCopy() {
	local SOURCE=$1
	local TARGET=$2
	local TEMPTAR=/app/temp.tar
	crane pull "$SOURCE" "$TEMPTAR"
	crane push "$TEMPTAR" "$TARGET"
	rm -f "$TEMPTAR"
}

CraneDebugCopy() {
	local SOURCE=$1
	local TARGET=$2
	crane copy --debug --jobs 1 "$SOURCE" "$TARGET"
}
