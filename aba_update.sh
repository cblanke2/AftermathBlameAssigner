linux_update () {
	#
	# Stop and remove the systemd service
	systemctl stop aftermath_blame_assigner.service
	systemctl disable aftermath_blame_assigner.service
	rm /etc/systemd/system/aftermath_blame_assigner.service
	systemctl daemon-reload
	systemctl reset-failed
	#
	# Update the repo
	cd /opt/AftermathBlameAssigner
	git pull
	#
	# Enable and restart the new systemd service
	cp /opt/AftermathBlameAssigner/aftermath_blame_assigner.service /etc/systemd/system/
	chmod 664 /etc/systemd/system/aftermath_blame_assigner.service
	systemctl daemon-reload
	systemctl enable aftermath_blame_assigner.service
	systemctl restart aftermath_blame_assigner.service
}

bsd_update () {
	#
	# Stop the script
	kill `ps hax | grep AftermathBlameAssigner | grep python3 | awk ' {print $1} '`
	#
	# Update the repo
	cd `echo $HOME`/AftermathBlameAssigner
	git pull
	#
	# Restart the script
	python3 `echo $HOME`/AftermathBlameAssigner/aftermath_blame_assigner.py &	
}

get_os () {
	OS_TYPE=$(echo $(uname -s))
	#
	if [[ $OS_TYPE == *"Linux"* ]]; then
		linux_update
	elif [[ $OS_TYPE == "Darwin" || $OS_TYPE == *"SunOS"* ]]; then
		echo "You will have to manually update this script."
	elif [[ $OS_TYPE == *"BSD"* ]]; then
	    bsd_update
	else
		echo "This script was not tested on your OS."
	fi
	#
	exit 0
}

get_os