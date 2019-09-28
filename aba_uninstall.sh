#!/bin/bash
# 
# aba_uninstall.sh
# 	script to uninstall Aftermath Blame Assigner
#
# Written by: Chris Blankenship <chrisb@reclaimhosting.com>
#

uninstall_linux () {
	systemctl stop aftermath_blame_assigner.service
	systemctl disable aftermath_blame_assigner.service
	rm /etc/systemd/system/aftermath_blame_assigner.service
	systemctl daemon-reload
	systemctl reset-failed
	rm -rf /opt/AftermathBlameAssigner
	rm /var/log/aftermath_blame_assigner.log
	hash -r
}

uninstall_bsd () {
    kill `ps hax | grep AftermathBlameAssigner | grep python3 | awk ' {print $1} '`
    crontab -l | grep -v AftermathBlameAssigner | crontab -
    rm -rf `echo $HOME`/AftermathBlameAssigner
    rm /var/log/aftermath_blame_assigner.log
    hash -r
}

get_os () {
	OS_TYPE=$(echo $(uname -s))
	#
	if [[ $OS_TYPE == *"Linux"* ]]; then
		uninstall_linux
	elif [[ $OS_TYPE == *"BSD"* ]]; then
	    uninstall_bsd
	elif [[ $OS_TYPE == "Darwin" || $OS_TYPE == *"SunOS"* ]] then
		echo "You will have to manually uninstall this script"
	else
		echo "This script was not tested on your OS."
	fi
	#
	exit 0
}

get_os
