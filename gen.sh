#!/bin/sh

if [ $# != 1 ]; then
	echo "arg err"
	exit
fi

hostlst="$1/host.lst"
cmdlst="$1/command.lst"

genhtml()
{
	path=$1
	serveraddr=$2
	servername=$3
	htmlfile="${path}/www/index.html"
	whitelist="${path}/white.lst"
	cat head.html > "${htmlfile}"
	while read line; do
		caption=`echo ${line} | awk -F':' '{print $1}'`
		cmd=`echo ${line} | awk -F':' '{print $2}'`
		echo ${cmd} >> "${whitelist}"
		acmd=`echo ${cmd} | sed 's/[ ][ ]*/:/g' | sed 's/\+/\&#43;/g'`
		wline="    <button type=\"button\" onclick=send(\""${acmd}"\")>"${caption}"</button>"
		echo "$wline" >> ${htmlfile}
	done < ${cmdlst}
	sed 's/\${serveraddr}/'${serveraddr}'/g' body.html | \
	sed 's/\${servername}/'${servername}'/g' >> ${htmlfile}
	echo "" >> "${whitelist}"
}

while read line; do
	echo ${line}
	name=`echo ${line} | awk -F':' '{print $1}'`
	ip=`echo ${line} | awk -F':' '{print $2}'`
	port=`echo ${line} | awk -F':' '{print $3}'`
	workdir=`echo ${line} | awk -F':' '{print $4}'`
	libdir=`echo ${line} | awk -F':' '{print $5}'`

	#backup pid
	if [ -f "${name}/websocketd.pid" ]; then
		pid="`cat ${name}/websocketd.pid`"
	else
		pid=
	fi

	if [ -d ${name} ]; then
		rm -rf ${name}
	fi
	serveraddr=${ip}:${port}
	mkdir -p "${name}/www"

	genhtml "${name}" ${serveraddr} "${name}"
	# restore pid
	if [ ! -z ${pid} ]; then
		echo ${pid} > ${name}/websocketd.pid
	fi

	cp -f websocketd ${name}
	cp -fv ezopen.sh ${name}
	cp -fv ezopen_common.sh ${name}
	sed 's:\${workdir}:"'"${workdir}"'":g' "$1/ezopen.functions" | \
	sed 's:\${libdir}:"'"${libdir}"'":g' > "${name}/ezopen.functions"
	sed 's/\${port}/'${port}'/g' "command.sh" > "${name}/command.sh"

	# run_websocketd.sh
	echo '#!/bin/sh
"./websocketd" --port='"${port}"' --staticdir="www" --passenv=HOME,GOROOT,PATH,GOPATH,LD_LIBRARY_PATH "./command.sh" 1>>/dev/null 2>&1 &
echo $! > websocketd.pid
' >"${name}/run_websocketd.sh"

	# stop_websocketd.sh
	echo '#!/bin/sh
[ -f websocketd.pid ] && pid=`cat websocketd.pid` && [ -e /proc/$pid ] && kill $pid && rm websocketd.pid
' >"${name}/stop_websocketd.sh"

	# shuld not run from another user
	chmod 0744 "${name}/command.sh"
	chmod 0744 "${name}/websocketd"
	chmod 0744 "${name}/ezopen.sh"
	chmod 0744 "${name}/run_websocketd.sh"
	chmod 0744 "${name}/stop_websocketd.sh"

done < ${hostlst}
