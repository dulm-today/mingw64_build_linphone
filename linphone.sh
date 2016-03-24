#!/bin/bash
#
#
# Path:
#   curdir:
#      _deps_
#      linphone_src
#      belle-sip_src
#      ...
#

DEPS_LINPHONE="gcc gtk2 yasm sqlite3 libxml2 gnutls libsoup libtheora libogg"
DEPS_LINPHONE+="zip unzip wget intltool git pkg-config automake libtool"

CURDIR=`pwd`
SOURCE=$(real_path "${BASH_SOURCE[0]}")
SOURCE_DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# need add the file _util.sh to the PATH
if [ -x "./_util.sh" ];then
    . ./_util.sh || exit 1
else
    . _util.sh || exit 1
fi

DEPS_PATH="${CURDIR}/_deps_"
DEPS_BIN_PATH=""
DEPS_C_INCLUDE_PATH=""
DEPS_CPLUS_INCLUDE_PATH=""
DEPS_LD_LIBRARY_PATH=""
DEPS_LIBRARY_PATH=""

### deps
DEPS_LIST="polarssl srtp ffmpeg x264  
   libspeex 
 libgsm"
DEPS_LIST_PACMAN="sqlite3 libxml2 gnutls libsoup libtheora libogg"

# polarssl
PLUGIN_POLARSSL_PATH="git://git.linphone.org/polarssl.git"
PLUGIN_POLARSSL_CMD="make lib SHARED=1 WINDOWS=1
#make install DESTDIR="

# srtp - libsrtp
PLUGIN_SRTP_PATH="git://git.linphone.org/srtp.git"
PLUGIN_SRTP_CMD="autoconf
#./configure --prefix=
#make libsrtp.a
#make install DESTDIR="

# sqlite3 
PLUGIN_SQLITE3_PATH="http://www.sqlite.org/2016/sqlite-autoconf-3110100.tar.gz"
PLUGIN_SQLITE3_CMD="./configure
#make
#make install DESTDIR="


# ffmpeg
PLUGIN_FFMPEG_PATH="http://ffmpeg.org/releases/ffmpeg-snapshot-git.tar.bz2"
PLUGIN_FFMPEG_CMD="./configure --enable-shared --disable-static --enable-memalign-hack \
--extra-cflags=\"-fno-common\" --enable-gpl
#make
#make install DESTDIR="

# libxml2
PLUGIN_FFMPEG_PATH="ftp://xmlsoft.org/libxml2/libxml2-git-snapshot.tar.gz"
PLUGIN_FFMPEG_CMD="./configure --enable-shared --disable-static
#make
#make install DESTDIR="

# x264
PLUGIN_X264_PATH="http://git.videolan.org/git/x264.git"
PLUGIN_X264_CMD="./configure --enable-pic
#make
#make install DESTDIR="

# libspeex

# libspeexdsp

# libgsm

###### linphone
PLUGIN_LINPHONE="linphone"
PLUGIN_LINPHONE_PATH="git://git.linphone.org/linphone.git --recursive"
PLUGIN_LINPHONE_CMD="./autogen.sh
#./configure --prefix= --enable-shared --disable-static --enable-tunnel
#make
#make zip
#make setup.exe"



### plugin for all
PLUGINS="belle-sip antlr3c bcg729 bctoolbox belcard belr bzrtp msamr msopenh264 mssilk mswasapi mswebrtc msx264 
externals/bv16-floatingpoint externals/libmatroska-c externals/mbedtls"

PLUGIN_PATH="git://git.linphone.org/xxxxx.git"
PLUGIN_CMD="./autogen.sh
#./configure --prefix= --enable-shared --disable-static
#make zip"


build_env()
{
    install_deps "$DEPS_LINPHONE" "$MINGW_ONLY_ARCH" "$MINGW_USE_MSYS2" "$MINGW_CONFIRM"

    mkdir -p /opt/perl/bin
    cp -f /bin/perl /opt/perl/bin/.

    # linphone-deps-win32
    ## self compile install

    # gtk2
    ## already installed

    # gtk2 Outcrop theme
    ## TODO

    # remove libintl.a libintl.la libintl.dll.a from C:/MinGW/lib
    ## maybe not need do this

    # install "Inno Setup Compiler"
    ## TODO

    # msys-git
    ## already installed

    # cd source dir
    ## resume CURDIR
}
 
# pkg-config
export PKG_CONFIG_PATH=/usr/lib/pkgconfig;/mingw32/lib/pkgconfig;/mingw64/lib/pkgconfig

# $1 name
# $2 path
_pull_source()
{
    local _filename
    local _filepath
    local scheme=$(echo "$2" | awk -F : '{print $1}')
    
    if [ "$scheme" == "git" ];then
        git clone $2 
        cd "$1"
    else
        wget --tries=10 $2
        
        _filename=$(echo "$2" | awk '{print $1}')
        _filename=$(basename "$_filename")
        _filepath=$(echo $_filename | awk -F . '{print $1}')
        
        tar -xf $_filename
        touch ./$_filepath.version
        mv $_filepath $1
        cd $1
    fi
}

#### 
# $1 name
# $2 git path
# $3 cmd
build_plugin_do()
{
    local _curdir=`pwd`
	local _name="$1"
    local _path="$2"
    local _cmd
    local _ifs
    
	set -e
	if [! -d "$_name" ];then
		if [ "$_path" != "null" ];then
			_pull_source "$_name" "$_path"
		else
			assert_ok 1 "$_name 's path is null"
		fi
	fi
	
    # run the cmd
    shift && shift
    
    _ifs="$IFS"
    IFS="#"
    
    for _cmd in $3
    do
        echo "run cmd: $_cmd"
        eval "$_cmd"
    done
    IFS="$_ifs"
	
	cd "$_curdir"
	set +e
}

# $1 name
# $2 path
# $3 cmd
build()
{
    local _cmd="$3"
    
    # CMD deal, --prefix=$DEPS_PATH, DESTDIR=$DEPS_PATH
    _cmd="${_cmd//--prefix=/--prefix=$DEPS_PATH}"
    _cmd="${_cmd//DESTDIR=/DESTDIR=$DEPS_PATH}"
    
    build_plugin_do "$1" "$2" "$_cmd"
}


build_select()
{

}


# belle-sip
if [ ! -d "belle-sip" ];then
	git clone git://git.linphone.org/belle-sip.git
fi

assert_dir_exist "./belle-sip"
cd "belle-sip"

./autogen.sh && ./configure --prefix=/usr --enable-shared --disable-static \
&& make && make install

assert_ok $? "build belle-sip"
cd "$CURDIR"

# linphone
if [ ! -d "linphone" ];then
	git clone git://git.linphone.org/linphone.git --recursive
fi

assert_dir_exist "./linphone"
cd "linphone"

./autogen.sh && ./configure --prefix=/usr --enable-shared --disable-static \
&& make && make install

assert_ok $? "build linphone"

make zip
assert_ok $? "make zip for linphone"





