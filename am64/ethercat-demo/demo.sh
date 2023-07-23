#!/bin/sh

logfile=/opt/acontis/demo.log
test -f $logfile && mv $logfile ${logfile}.old

log() {
	while read line; do
		echo $(date '+%Y-%m-%d %H:%M'): $line
		echo $(date '+%Y-%m-%d %H:%M'): $line >> $logfile
	done
}

# Enable interface(s)
ifconfig eth1 up # must be up as workaround for pru timeouts
ifconfig eth2 up # ethercat interface

running=1
pid=
cleanup() {
	running=0
	kill -s TERM $pid
}
trap cleanup INT TERM

while [ $running -ne 0 ]; do
	# wait for link-up
	echo Waiting for Link ... | log
	s=1
	while [ $s -ne 0 ]; do
		sleep 1
		ethtool eth2 | grep "Link detected: yes" | log
		s=$?
	done

	# start ethercat stack
	cd /opt/acontis/Bin/Linux/aarch64
	if [ -f /opt/acontis/motion.txt ]; then
		# run motion demo
		echo "Starting Motion Demo ..." | log
		./EcMasterDemoMotion -log ../../../master-motion -sockraw eth2 -b 1000 -sp 0.0.0.0 -t 0 -f eni.xml -cfg DemoConfig.xml 2>&1 &
	else
		# no motion demo configuration, run standard demo
		echo "Starting Demo ..." | log
		./EcMasterDemo -log ../../../master -sockraw eth2 -b 1000 -sp 0.0.0.0 -t 0 &
	fi
	pid=$!
	wait
	s=$?
done

exit $s
