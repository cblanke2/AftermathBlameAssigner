#!/bin/bash
# 
# aba_remote.sh
# 	script to remotely install, reinstall, uninstall, and update Aftermath Blame Assigner
#
# Written by: Chris Blankenship <chrisb@reclaimhosting.com>
#


update_script () {
	echo 'systemctl stop aftermath_blame_assigner.service
	systemctl disable aftermath_blame_assigner.service
	rm /etc/systemd/system/aftermath_blame_assigner.service
	systemctl daemon-reload
	systemctl reset-failed
	cd /opt/AftermathBlameAssigner
	git pull
	cp /opt/AftermathBlameAssigner/aftermath_blame_assigner.service /etc/systemd/system/
	chmod 664 /etc/systemd/system/aftermath_blame_assigner.service
	systemctl daemon-reload
	systemctl enable aftermath_blame_assigner.service
	systemctl restart aftermath_blame_assigner.service' | ssh $1
}

uninstall_script () {
	curl https://gitlab.com/cblanke2/AftermathBlameAssigner/raw/master/aba_uninstall.sh | ssh $1
}

install_script () {
	curl https://gitlab.com/cblanke2/AftermathBlameAssigner/raw/master/aba_install.sh | ssh $1
}


arg_parse () {
	if [[ $1 == "install" ]]; then
		install_script $2
	elif [[ $1 == "reinstall" ]]; then
		uninstall_script $2
		install_script $2
	elif [[ $1 == "uninstall" ]]; then
		uninstall_script $2
	elif [[ $1 == "update" ]]; then
		update_script $2
	else
		echo "
		bash aba_remote.sh [OPTION] <USER>@<SERVER>
			A script to remotely install, reinstall, uninstall, and update Aftermath Blame Assigner.
			This script is written with root access over ssh in mind, but as long as your account has
			proper privileges, you should run into no issues.
		
		OPTIONS:
			install - Installs Aftermath Blame Assigner (Linux or BSD)
			reinstall - Reinstalls Aftermath Blame Assigner (Linux or BSD)
			uninstall - Uninstalls Aftermath Blame Assigner (Linux or BSD)	
			update - Updates the installation of Aftermath Blame Assigner  (Linux only)
			"
	fi
}

arg_parse $1 $2
