#!/bin/bash

. _util.sh

: ${MINGW_ONLY_ARCH:="yes"}
: ${MINGW_USE_MSYS2:="yes"}
: ${MINGW_CONFIRM:="no"}

ARCH="i686"

if [ "$(getconf LONG_BIT)" == "64" ];then
	ARCH="x86_64"
fi

_regex_deal()
{
    echo "${1//+/\\+}"
}

# $1 packages
# $2 confirm
_package_install()
{
	local pkg
	local ret
	
	for pkg in $1
	do
		if [ "$2" == "yes" ];then
			pacman -S --needed "pkg"
			ret=$?
		else
			pacman -S --needed --noconfirm "$pkg"
			ret=$?
		fi
		
		if [ $ret -eq 0 ];then
            echo_color "green" "none" "install package[ OK ] $pkg"
		else
            echo_color "red"   "none" "install package[FAIL] $pkg"
		fi
	done
}

# $1 group name
# $2 confirm
_group_install()
{
	local ret
	
	if [ "$2" == "yes" ];then
		pacman -S --needed "$1"
		ret=$?
	else
		pacman -S --needed --noconfirm "$1"
		ret=$?
	fi
	
	if [ $ret -eq 0 ];then
        echo_color "green" "none" "install group [ OK ] $1"
	else
        echo_color "red"   "none" "install group [FAIL] ${1}"
	fi
}

## $1 list
## $2 only_arch, yes: install current arch; no: install i686 && x86_64
## $3 install_msys2, yes: install msys program while no arch_program; no: not install; true: allways install
## $4 confirm, yes: --confirm; no: --noconfirm
install_deps()
{
	local _package
	local _package_msys
	local _search
	local _search_ret
	local _search_i
	local _arch
	local _each
    local _guess
	
	for _each in $1
	do
		_package=""
		_package_msys=""
		
		echo "installing $_each ..."
		
		# whether it is a group
		pacman -Qg "$_each" &> /dev/null
		if [ $? -eq 0 ];then
			_group_install "$_each" "$4"
			continue
		fi
		
		# whether not begin with mingw
		if [ "$(echo \"$_each\" | awk -F \- '{print $1}')" == "mingw" ];then
			# mingw-xx-arch-name
			_package+=" $_each"
		else
            _eash_regex=$(_regex_deal "$_each")
			_search="$(pacman -Ssq ^${_eash_regex}$)\n "		# gcc
			_search+="$(pacman -Ssq ^mingw-w[0-9]+-[^-]+-${_eash_regex}$)"	# mingw-w64-i686-gcc
			_search_ret=$(echo -e "$_search" | grep ${_each})
			if [ -z "$_search_ret" ];then
				# not exist
                echo_color "red"   "none" "install package[FAIL] not exist: $_each"
				continue
			fi
			
			for _search_i in $_search_ret
			do
				_arch="$(echo \"$_search_i\" | awk -F \- '{print $3}')"
                _guess="mingw-w64-${_arch}-${_each}"
				if [ "$ARCH" == "$_arch" -a "$_guess" == "$_search_i" ];then
					# ARCH == _arch
					_package+=" $_search_i"
				elif [ "$_arch" == "i686" -a "$ARCH" == "x86_64" \
                        -a "$_guess" == "$_search_i" -a "$2" != "yes" ];then
					# x86_64 install i686
					_package+=" $_search_i"
				elif [ -z "$_arch" ];then
					# install msys
					_package_msys+=" $_search_i"
				elif [ -n "$_arch" ];then
					# ARCH i686, _arch x86_64
                    echo_color "blue"   "none" "install package[IGNO] $_search_i"
				else
                    echo_color "yellow" "none" "install package[WARN] unknow arch: $_search_i"
				fi
			done
		fi
		
		if [ -z "$_package" -a "$3" == "yes" -o "$3" == "true" ];then
			_package+=" $_package_msys"
		fi
		
		if [ -n "$_package" ];then
			_package_install "$_package" "$4"
		else
            echo_color "yellow" "none" "install package[WARN] package empty: $_each"
		fi
	done
}

upgrade_db()
{
    pacman -Sy
}

upgrade_all()
{
    pacman -Syu
}

upgrade_msys2()
{
	pacman -Sy
	pacman -S --needed filesystem msys2-runtime bash \
		libreadline libiconv libarchive libgpgme libcurl pacman ncurses libintl
	
	echo ""
    
    echo_color "green" "none" " 1. Close all msys shell"
    echo_color "green" "none" " 2. Run autorebase.bat by Double Click it "
    echo_color "green" "none" " 3. \$pacman -Syu "
}
