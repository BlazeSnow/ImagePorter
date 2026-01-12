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

TEMP_TAR="/app/temp.tar"

CraneAdvancedCopy() {
	local SOURCE=$1
	local TARGET=$2
	crane pull "$SOURCE" "$TEMP_TAR" -v
	crane push "$TEMP_TAR" "$TARGET" -v
	rm -f "$TEMP_TAR"
}

CraneLegacyCopy() {
	local SOURCE=$1
	local TARGET=$2
	crane pull "$SOURCE" "$TEMP_TAR" --format=legacy -v
	crane push "$TEMP_TAR" "$TARGET" --format=legacy -v
	rm -f "$TEMP_TAR"
}
