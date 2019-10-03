#!/bin/bash
# 
# aba_remote.sh
# 	script to remotely install, reinstall, uninstall, and update Aftermath Blame Assigner
#
# Written by: Chris Blankenship <chrisb@reclaimhosting.com>
#


update_script () {
	curl https://gitlab.com/cblanke2/AftermathBlameAssigner/raw/master/aba_update.sh | ssh $1
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
			install - Installs Aftermath Blame Assigner
			reinstall - Reinstalls Aftermath Blame Assigner
			uninstall - Uninstalls Aftermath Blame Assigner	
			update - Updates the installation of Aftermath Blame Assigner
			"
	fi
}

arg_parse $1 $2
