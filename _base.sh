#!/bin/bash

# base
DEPS_BASE="pkg-config zip unzip tar wget git curl"

# auto build
DEPS_BASE+=" intltool automake autoconf libtool"

# text tools
DEPS_BASE+=" sed awk grep gawk gettext less"


if [ -x "./_util.sh" ];then
    . ./_util.sh || exit 1
else
    . _util.sh || exit 1
fi

install_deps "$DEPS_BASE" "$MINGW_ONLY_ARCH" "$MINGW_USE_MSYS2" "$MINGW_CONFIRM"