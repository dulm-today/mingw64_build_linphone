#!/bin/bash

DEPS_C_CPLUS="base-devel gcc gdb crt-git libc++ libwinpthread-git winpthreads-git"
DEPS_C_CPLUS+=" libcurl libiconv zlib"

_source_dir_="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "${_source_dir_}/_mingw.sh" ];then
    . "${_source_dir_}/_mingw.sh" || exit 1
else
    . _mingw.sh || exit 1
fi

if [ -n "$(echo $ARCH | grep i686)" ];then
	DEPS_C_CPLUS+=" mingw-w64-i686-toolchain"
elif [ -n "$(echo $ARCH | grep x86_64)" ];then
	DEPS_C_CPLUS+=" mingw-w64-x86_64-toolchain"
elif [ -n "$(echo $ARCH | grep cross)" ];then
	DEPS_C_CPLUS+=" mingw-w64-cross-toolchain"
fi

install_deps "$DEPS_C_CPLUS" "$ARCH" "$MINGW_USE_MSYS2" "$MINGW_CONFIRM"