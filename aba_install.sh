#!/bin/bash
#
# aba_install.sh
#	installation script for Aftermath Blame Assigner
#
# Written by: Chris Blankenship <chrisb@reclaimhosting.com>
#

manual_install (){
	echo "Your OS was not tested with this script, but you should be able to install the Aftermath Blame Assigner manually"
	echo ""
	echo "Ensure all the dependencies for the script are installed"
	echo "Install bash, git, python3, and syssat if they aren't already installed"
	echo "If python3-psutil is not in your OS repos, install gcc python3-dev python3-pip and install it through pip3"
	echo ""
	echo "Install “Aftermath Blame Assigner” on the server in /opt/AftermathBlameAssigner"
	echo "Some OSs don't have an /opt dir, so adjust these instructions where neded."
	echo "Install the script by running → cd /opt && git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner"
	echo "This repo is hosted on GitLab at https://gitlab.com/cblanke2/AftermathBlameAssigner"
	echo "And mirrored on GitHub at https://github.com/cblanke2/AftermathBlameAssigner"
	echo "Update the script by running →  cd /opt/AftermathBlameAssigner && git pull"
	echo ""
	echo "Set the script to run at reboot"
	echo "Be sure to check where python3 is installed before doing this with which python3. Most of the time it's /usr/bin/python3, but sometimes it's /usr/local/bin/python3 (which may or may not be linked to /usr/bin/python3). Just double check and adjust the service file or crontab entry accordingly."
	echo "Install and enable the systemd service file (This will work on any Linux distro with systemd)"
	echo "cp ./aftermath_blame_assigner.service /etc/systemd/system/ && chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && systemctl daemon-reload && systemctl enable aftermath_blame_assigner.service"
	echo ""
	echo "Or add an entry into crontab to run the script on reboot (This will work on most any UNIX-like OS, but not CentOS)"
	echo "Run → crontab -e"
	echo "Add this to the end of the file →  @reboot /usr/bin/python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py &"
	echo ""
	echo "Manually start the script (or reboot the server)"
	echo "If you used systemd → systemctl restart aftermath_blame_assigner.service"
	echo "If you used cron → python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py &"
	exit 1
}

linux_install (){
	#
	# Install dependencies...
	DISTRO_FAMILY=$(echo $(source /etc/os-release && echo $ID_LIKE))
	DISTRO_BRANCH=$(echo $(source /etc/os-release && echo $ID))
	SYSTEMD_EXISTS=$(pidof systemd && echo "" || echo "false")
	#
	# For fedora-like distros
	if [[ $DISTRO_FAMILY == *"fedora"* || $DISTRO_BRANCH == "fedora" ]]; then
		RHEL_VERSION=$(echo $(source /etc/os-release && echo $VERSION_ID))
		# Fedora
		if [[ $DISTRO_BRANCH == "fedora" ]]; then
			if [[ $RHEL_VERSION -ge 18 ]]; then
				dnf -y install git python3 python3-psutil sysstat
			else
				echo "This script is not compatible with Fedora 17x and below"
				exit 1
			fi
		# CentOS/RHEL, CloudLinux, etc
		elif [[ $DISTRO_BRANCH == "centos" || $DISTRO_BRANCH == "rhel" || $DISTRO_BRANCH == "cloudlinux" ]]; then
			if [[ $RHEL_VERSION -le 6 || $RHEL_VERSION == [1-6]"."* ]]; then
				echo "This script is not compatible with CentOS/RHEL 6x and below"
				exit 1
			elif [[ $RHEL_VERSION -eq 7 || $RHEL_VERSION == "7."* ]]; then
				yum -y install epel-release git sysstat && yum -y install python36 python36-psutil
			elif [[ $RHEL_VERSION -ge 8 || $RHEL_VERSION == "8."* ]]; then
				dnf -y install gcc git python3 python36-devel sysstat && pip3 install psutil
			fi
		else
			yum -y install gcc git python3 python3-devel python3-pip sysstat && pip3 install psutil
		fi
	#
	# For debian-like distros
	elif [[ $DISTRO_FAMILY == *"debian"* || $DISTRO_FAMILY == "ubuntu" || $DISTRO_BRANCH == "debian" ]]; then
		if [[ $SYSTEMD_EXISTS == "false" ]]; then
			manual_install
		else
			apt-get -y install git python3 python3-psutil sysstat
		fi
	#
	# For arch-like distros
	elif [[ $DISTRO_FAMILY == "arch" || $DISTRO_FAMILY == "archlinux" || $DISTRO_BRANCH == "arch" ]]; then
		if [[ $SYSTEMD_EXISTS == "false" ]]; then
			manual_install
		else
			pacman -S --noconfirm git python python-psutil sysstat
		fi
	else
		manual_install
	fi
	#
	# Clone the repo from GitHub into /opt/AftermathBlameAssigner
	# cd /opt && git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner
	#
	# Clone the repo from GitLab into /opt/AftermathBlameAssigner
	cd /opt && git clone https://gitlab.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner
	#
	# Install the sytstemd service file
	cp /opt/AftermathBlameAssigner/aftermath_blame_assigner.service /etc/systemd/system/ && chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && systemctl daemon-reload && systemctl enable aftermath_blame_assigner.service
	#
	# Start the script
	systemctl restart aftermath_blame_assigner.service
}

bsd_install () {
    #
    # Install dependencies
    pkg install -y python3 git
    python3 -m ensurepip
    pip3 install psutil
    #
    # Clone the repo from GitHub into ~/AftermathBlameAssigner
    # cd ~ && git clone https://github.com/cblanke2/AftermathBlameAssigner.git
    #
    # Clone the repo from GitLab into ~/AftermathBlameAssigner
    cd ~ && git clone https://gitlab.com/cblanke2/AftermathBlameAssigner.git
    #
    # Create a cronjob
    echo $(crontab -l ; echo "@reboot `which python3` `echo $HOME`/AftermathBlameAssigner/aftermath_blame_assigner.py & ") | crontab -
    #
    # Start the script
    python3 ~/AftermathBlameAssigner/aftermath_blame_assigner.py &
}

get_os () {
	OS_TYPE=$(echo $(uname -s))
	#
	if [[ $OS_TYPE == *"Linux"* ]]; then
		linux_install
	elif [[ $OS_TYPE == "Darwin" || $OS_TYPE == *"SunOS"* ]]; then
		manual_install
	elif [[ $OS_TYPE == *"BSD"* ]]; then
	    bsd_install
	else
		echo "This script was not tested on your OS, and it may not run at all."
	fi
	#
	exit 0
}

get_os