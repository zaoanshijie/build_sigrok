#!/bin/sh
NM="${TOOLCHAIN_PATH}/bin/x86_64-w64-mingw32-nm"
OUT="$1"
shift
{
    echo "EXPORTS"
    $NM "$@" 2>/dev/null | grep ' [TDRB] ' | sed 's/.* //' | grep -v '^\.' | sort -u
} > "$OUT"
