#!/bin/bash
# 
# aba_uninstall.sh
# 	script to uninstall Aftermath Blame Assigner
#
# Written by: Chris Blankenship <chrisb@reclaimhosting.com>
#

uninstall_centos () {
	if [[ -f /usr/local/bin/pip3 ]]; then
		[[ $(echo $( /usr/local/bin/pip3 list --not-required)) == *" psutil "* ]] && /usr/local/bin/pip3 uninstall -y psutil
		[[ $(echo $( /usr/local/bin/pip3 list --not-required)) == *" setuptools "* ]] &&  /usr/local/bin/pip3 uninstall -y setuptools
		[[ $(echo $( /usr/local/bin/pip3 list --not-required)) == *" wheel "* ]] &&  /usr/local/bin/pip3 uninstall -y wheel
		[[ $(echo $( /usr/local/bin/pip3 list --not-required)) == *" pip "* ]] && /usr/local/bin/pip3 uninstall -y pip
		if [[ $(echo $(source /etc/os-release && echo $VERSION_ID)) -eq 7 || $(echo $(source /etc/os-release && echo $VERSION_ID)) == "7."* ]]; then
			rpm -e python36-devel python36-libs python36 epel-release
		elif [[ $(echo $(source /etc/os-release && echo $VERSION_ID)) -ge 8 || $(echo $(source /etc/os-release && echo $VERSION_ID)) == "8."* ]]; then
			rpm -e python3 python36-devel python3-libs
		fi
	else
		if [[ $(echo $(source /etc/os-release && echo $VERSION_ID)) -eq 7 || $(echo $(source /etc/os-release && echo $VERSION_ID)) == "7."* ]]; then
			rpm -q python36-psutil && rpm -e python36 python36-libs python36-psutil epel-release
		elif [[ $(echo $(source /etc/os-release && echo $VERSION_ID)) -ge 8 || $(echo $(source /etc/os-release && echo $VERSION_ID)) == "8."* ]]; then
			rpm -e python3 python36-devel python3-libs
	fi
	yum history sync
	yum clean all
	yum -y autoremove
}

uninstall_general () {
	systemctl stop aftermath_blame_assigner.service
	systemctl disable aftermath_blame_assigner.service
	rm /etc/systemd/system/aftermath_blame_assigner.service
	systemctl daemon-reload
	systemctl reset-failed
	rm -rf /opt/AftermathBlameAssigner
	rm /var/log/aftermath_blame_assigner.log
	
	if [[ $(echo $(source /etc/os-release && echo $ID)) == "centos" || $(echo $(source /etc/os-release && echo $ID)) == "rhel" ]]; then
		if [[ $(echo $(source /etc/os-release && echo $VERSION_ID)) -ge 7 || $(echo $(source /etc/os-release && echo $VERSION_ID)) == [7-8]"."* ]]; then
			uninstall_centos
		fi
	fi

	hash -r
}

uninstall_general
