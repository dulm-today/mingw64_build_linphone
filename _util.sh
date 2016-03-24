#!/bin/bash

# $1 dir_name
assert_dir_exist()
{
	if [ ! -d "$1" ];then
        echo_color "red" "none" "[ERR ] dir %1 not exist"
		exit 1
	fi
}

assert_ok()
{
	if [ ! $1 -eq 0 ];then
        echo_color "red" "none" "[FAIL] $2 assert fail"
        exit 1
	fi
}

# $1 file or path
real_path()
{
    local _file="$1"
    local _dir
   
    while [ -h "$_file" ]; 
    do # resolve $_file until the file is no longer a symlink
        _dir="$( cd -P "$( dirname "$_file" )" && pwd )"
        _file="$(readlink "$_file")"
        # if $_file was a relative symlink, we need to resolve it relative to the path where the symlink file was located
        [[ $_file != /* ]] && _file="$_dir/$_file" 
    done
    echo "$_file"
}


_color_code()
{
    local _code
    local _base
    
    case "$1" in
        "black")
            _code=0 ;;
        "red" )
            _code=1 ;;
        "green" )
            _code=2 ;;
        "yellow" )
            _code=3 ;;
        "blue" )
            _code=4 ;;
        "purple" )
            _code=5 ;;
        "dark green" )
            _code=6 ;;
        "white" )
            _code=7 ;;
        "none" | *)
            _code=-1 ;;
    esac
    
    if [ $_code -lt 0 ];then
        echo "1"
        return
    fi
    
    if [ "$2" != "front" ];then
        _base="4"
    else
        _base="3"
    fi
    
    echo "${_base}${_code}" 
}

# $1 front
# $2 background
# $* words
echo_color()
{
    local _color_front=$(_color_code "$1" "front")
    local _color_back=$(_color_code "$2" "back")
    
    shift && shift
    
    echo -e "\e[${_color_front};${_color_back}m${*}\e[0m"
}

