#!/bin/sh

set -e

cranecopy() {
	SOURCE=$1
	TARGET=$2
	shift 2
	ARGS="$@"
	GODEBUG=http2client=0 crane copy --jobs 1 $ARGS "$SOURCE" "$TARGET"
}
