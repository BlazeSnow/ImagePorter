#!/bin/sh

set -e

CraneDigest() {
	IMAGE=$1
	shift
	ARGS="$@"
	return crane digest --jobs 1 $ARGS "$IMAGE" 2>/dev/null || true
}

CraneCopy() {
	SOURCE=$1
	TARGET=$2
	shift 2
	ARGS="$@"
	crane copy --jobs 1 $ARGS "$SOURCE" "$TARGET"
	return $?
}
