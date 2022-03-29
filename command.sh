#!/bin/bash
mypid=$$
wspid=`cat websocketd.pid`
whitelst=white.lst

ctrl_c() {
	echo "Trapped CTRL-C" > /dev/tty
	rm -f $pipefile
	exit
}
trap ctrl_c INT

if [ -z "$wspid" ]; then
	echo "No websocket Running"
	exit 1
fi

echo "The wspid is $wspid" > /dev/tty
export DISPLAY=:0
echo "你好, 骚年"

pipefile="/tmp/${mypid}_fifo"
echo "Pipe:$pipefile" > /dev/tty

rm  -f $pipefile
mkfifo $pipefile
bash < $pipefile  2>&1 &
exec 3> $pipefile

while [ 1 ]
	do
		while read -t 1 line; do
		echo $line
		echo "command: $line" > /dev/tty
		num=$(grep -w "$line" $whitelst | wc -l)
		if [ "$num" != "0" ]; then
			echo 'echo "开始执行 - `date '\''+%Y/%m/%d %H:%M:%S'\''`"' >&3
			echo "$line" >&3
			echo 'echo "执行结束 - `date '\''+%Y/%m/%d %H:%M:%S'\''`"' >&3
		else
			echo "此命令禁止执行,参看以下列表"
			cat $whitelst
		fi
	done < /dev/stdin

	if [ ! -e /proc/$wspid ] ; then
		echo -e "websocket not available, quitting"
		exec 3>&-
		rm /tmp/$pipefile
		kill -9 $mypid
		exit
	fi
done
