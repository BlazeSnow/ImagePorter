#!/bin/sh

set -e

cranecopy() {
	SOURCE=$1
	TARGET=$2
	shift 2
	ARGS="$@"
	if [ -n "$ARGS" ]; then
		ARGS="$ARGS"
	else
		ARGS=""
	fi
	GODEBUG=http2client=0 crane copy --jobs 1 $ARGS "$SOURCE" "$TARGET"
}
