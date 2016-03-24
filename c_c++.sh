#!/bin/bash

DEPS_C_CPLUS="base-devel gcc gdb crt-git libc++ libwinpthread-git winpthreads-git"
DEPS_C_CPLUS+=" libcurl libiconv zlib"

if [ -x "./_util.sh" ];then
    . ./_util.sh || exit 1
else
    . _util.sh || exit 1
fi

install_deps "$DEPS_C_CPLUS" "$MINGW_ONLY_ARCH" "$MINGW_USE_MSYS2" "$MINGW_CONFIRM"