#!/bin/sh

set -e

CraneDigest() {
	local IMAGE=$1
	crane digest "$IMAGE" 2>/dev/null || true
}

CraneCopy() {
	local SOURCE=$1
	local TARGET=$2
	crane copy --jobs 1 $ARGS "$SOURCE" "$TARGET" 2>/dev/null || true
}
