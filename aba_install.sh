#!/bin/bash
#
# Written by: Chris Blankenship <chrisb@reclaimhosting.com>
#

manual_instal (){
	echo "Your distro was not tested with this script, but you may be able to install the Aftermath Blame Assigner manually"
	echo ""
	echo "Install these packages with your package manager: 'gcc git python3 python3-pip sysstat'"
	echo ""
	echo "Install this package with (sudo) pip3: 'psutil'"
	echo ""
	echo "Clone the repo using: 'cd /opt && sudo git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner'"
	echo "or if you prefer GitLab: 'cd /opt && sudo git clone https://gitlab.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner'"
	echo ""
	echo "Set the script to run at reboot, using either cron or systemd"
	echo "\tFor systemd, run this: 'sudo cp ./aftermath_blame_assigner.service /etc/systemd/system/ && sudo chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && sudo systemctl daemon-reload && sudo systemctl enable aftermath_blame_assigner.service'"
	echo "\tFor cron, run 'sudo crontab -e' and add this line to the end: '@reboot /usr/bin/python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py &'"
	echo ""
	echo "Then manually start the script"
	echo "\tsystemd: 'sudo systemctl restart aftermath_blame_assigner.service'"
	echo "\tcron: 'sudo python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py &'"
	exit 1
}

linux_distro (){
	#
	# Install dependencies...
	DISTRO_FAMILY=$(echo $(source /etc/os-release && echo $ID_LIKE))
	DISTRO_BRANCH=$(echo $(source /etc/os-release && echo $ID))
	#
	# For fedora-like distros
	if [[ $DISTRO_FAMILY == *"fedora"* || $DISTRO_BRANCH == "fedora" ]]; then
		# Fedora
		if [[ $DISTRO_BRANCH == "fedora" ]]; then
			sudo dnf -y install gcc git python3 python3-devel python3-pip sysstat && sudo pip3 install psutil
		# CentOS/RHEL
		elif [[ $DISTRO_BRANCH == "centos" || $DISTRO_BRANCH == "rhel" ]]; then
			RHEL_VERSION=$(echo $(source /etc/os-release && echo $VERSION_ID))
			if [[ $RHEL_VERSION -le 6 ]]; then
				echo "This script is not compatible with CentOS/RHEL 6x and below"
				exit 1
			elif [[ $RHEL_VERSION -eq 7 ]]; then
				sudo yum -y install epel-release gcc git sysstat && sudo yum -y install python36 python36-devel && sudo curl https://bootstrap.pypa.io/get-pip.py | sudo python3 && sudo /usr/local/bin/pip3 install psutil
			elif [[ $RHEL_VERSION -ge 8 ]]; then
				sudo dnf -y install gcc git python3 python3-devel python3-pip sysstat && sudo pip3 install psutil
			fi
		else
			sudo yum -y install gcc git python3 python3-devel python3-pip sysstat && sudo pip3 install psutil
		fi
	#
	# For debian-like distros
	elif [[ $DISTRO_FAMILY == *"debian"* || $DISTRO_FAMILY == "ubuntu" || $DISTRO_BRANCH == "debian" ]]; then
		sudo apt-get -y install gcc git python3 python3-dev python3-pip sysstat && sudo pip3 install psutil
	#
	# For arch-like distros
	elif [[ $DISTRO_FAMILY == "arch" || $DISTRO_FAMILY == "archlinux" || $DISTRO_BRANCH == "arch" ]]; then
		sudo pacman -S --noconfirm gcc git python python-pip sysstat && sudo pip3 install psutil
	else
		manual_install
	fi
	#
	# Clone the repo from GitHub into /opt/AftermathBlameAssigner
	cd /opt && sudo git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner
	#
	# Clone the repo from GitLab into /opt/AftermathBlameAssigner
	# cd /opt && sudo git clone https://gitlab.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner
	#
	# Install the sytstemd service file
	sudo cp /opt/AftermathBlameAssigner/aftermath_blame_assigner.service /etc/systemd/system/ && sudo chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && sudo systemctl daemon-reload && sudo systemctl enable aftermath_blame_assigner.service
	#
	# Start the script
	sudo systemctl restart aftermath_blame_assigner.service
}

get_os () {
	OS_TYPE=$(echo $(uname -s))
	#
	if [[ $OS_TYPE == *"Linux"* ]]; then
		linux_distro
	elif [[ $OS_TYPE == "Darwin" || $OS_TYPE == *"BSD"* ]]; then
		echo "This script will, in theory, install on your OS. However, because it was written"
		echo "with Linux in mind many features will not work. Feel free to edit the script to"
		echo "make it work, but you will need to install it manually."
	else
		echo "This script was not tested on your OS, and it may not run at all."
	fi
	#
	exit 0
}

get_os
