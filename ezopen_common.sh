#!/bin/sh

script_path="$(dirname "`readlink -f "$0"`")"

if [ ! -f "$script_path/ezopen.functions" ]; then
	echo "缺少文件 - ezopen.functions"
	exit 3
fi

# include "ezopen.functions"
. "$script_path/ezopen.functions"

if [ ! -d "$workdir" ]; then
	echo "脚本配置不正确!请联系zkj!"
	exit 3
fi

printUsage(){
	echo "see Usage:"
	echo "(+)top:	see linux top of useage."
}

echo "[`date '+%Y/%m/%d %H:%M:%S'`] $0 $*" >> "$script_path/ezopen.log"

case "$1" in
	top)
		top
		;;
	-h|-?|h|help)
		printUsage
		printSelfUsage
		;;
	*)
		onUnknownCommand $*
		;;
esac

exit 0
