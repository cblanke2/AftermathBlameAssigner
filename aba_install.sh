#!/bin/bash

manual_linux_install (){
	echo "Your OS has not been tested with this script, so you will have to manually install it"
	echo "Install these packages with your package manager: gcc git python3 python3-pip sysstat"
	echo "Then run 'sudo pip3 install psutil'"
	echo ""
	echo "Clone the repo using: 'cd /opt && sudo git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner'"
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

find_linux (){
	OS_NAME=$(echo $(cat /etc/os-release | grep -e 'ID_LIKE=' | cut -d= -f2- | cut -d\" -f2- | cut -d\" -f1))

	# If CentOS/RHEL (WILL NOT WORK ON FEDORA)
	if [ "$OS_NAME" = "rhel fedora" ]; then
		CENTOS_VERSION=$(echo $(cat /etc/os-release | grep -e 'VERSION_ID=' | cut -d= -f2- | cut -d\" -f2- | cut -d\" -f1))
		# CentOS/RHEL 7
		if [ "$CENTOS_VERSION" = "7" ]; then
        		sudo yum -y install epel-release gcc git sysstat && sudo yum -y install python36 python36-devel && sudo curl https://bootstrap.pypa.io/get-pip.py | sudo python3 && sudo /usr/local/bin/pip3 install psutil
		# CentOS/RHEL 8
		elif [ "$CENTOS_VERSION" = "8" ]; then
			sudo yum -y install gcc git python3 python3-devel pip3 sysstat && sudo pip3 install psutil
		else
			echo "This script will not work on CentOS/RHEL 6x and below"
			exit 1
		fi
	# If Ubuntu/Debian
	elif [ "$OS_NAME" = "debian" ]; then
        	sudo apt-get -y install gcc git python3 python3-dev python3-pip sysstat && sudo pip3 install psutil
	# If Arch/Manjaro
	elif [ "$OS_NAME" = "arch" ]; then
        	sudo pacman -S --noconfirm gcc git python python-pip sysstat && sudo pip3 install psutil
	else
		manual_linux_install
	fi

	# Clone the repo
	cd /opt && sudo git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner

	# Set the script to run at reboot using systemd
	sudo cp /opt/AftermathBlameAssigner/aftermath_blame_assigner.service /etc/systemd/system/ && sudo chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && sudo systemctl daemon-reload && sudo systemctl enable aftermath_blame_assigner.service

	# restart the script
	sudo systemctl restart aftermath_blame_assigner.service

}

find_os (){
	OS_TYPE=$(echo $(uname))
	
	if [ "$OS_TYPE" = "Linux" ]; then
		find_linux
	elif [ "$OS_TYPE" = "Darwin" ] || [ "$OS_TYPE" = "FreeBSD" ]; then
		echo "This script has been tested on your OS, but it was written with Linux in mind so many features DO NOT WORK."
		echo "The script will still run, but it is limitedly functional, and requires more care to manually install. "
		echo "If you want to install it (which is NOT RECOMMENDED), please consult your SysAdmin."
	else
		echo "This script was not tested on your OS, and will probably not install/work at all."
		echo "If you want to install it (which is NOT RECOMMENDED), please consult your SysAdmin."
	fi
	exit 0
}

find_os
