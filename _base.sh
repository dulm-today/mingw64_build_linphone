#!/bin/bash

# base
DEPS_BASE="pkg-config zip unzip tar wget git curl"

# auto build
DEPS_BASE+=" intltool automake autoconf libtool"

# text tools
DEPS_BASE+=" sed awk grep gawk gettext less"

_source_dir_="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -x "${_source_dir_}/_mingw.sh" ];then
    . "${_source_dir_}/_mingw.sh" || exit 1
else
    . _mingw.sh || exit 1
fi

install_deps "$DEPS_BASE" "$ARCH" "$MINGW_USE_MSYS2" "$MINGW_CONFIRM"