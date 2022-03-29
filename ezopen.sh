#!/bin/sh

script_path="$(dirname "`readlink -f "$0"`")"

if [ ! -f "$script_path/ezopen_common.sh" ]; then
	echo "缺少文件 - ezopen_common.sh"
	exit 3
fi

if ! flock -o -n "$script_path/ezopen.lock" sh "$script_path/ezopen_common.sh" $*; then
	echo "正在进行操作或被锁定, 请稍后再试"
fi
