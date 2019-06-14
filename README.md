# Aftermath Blame Assigner

The Aftermath Blame Assigner (_aftermath_blame_assigner.py_) is a simple script for logging resource intensive processes on Linux servers, written in Python3. Although it _can_ run on any Unix-like OS with python3 (and it's other dependencies) installed, some features may not work; for example, the disk I/O and most intensive processes fail to log on macOS (and presumably on any OS using \*BSD style commands).

#### Install and configure the script
* Ensure all the dependencies for the script are installed
    * **Ubuntu, Debian, etc.** → `sudo apt-get -y install gcc git python3 python3-dev python3-pip sysstat && sudo pip3 install psutil`
    * **Arch, Manjaro, etc.** → `sudo pacman -S --noconfirm gcc git python python-pip sysstat  && sudo pip3 install psutil`
    * **CentOS, RHEL, etc.** → `sudo yum -y install epel-release gcc git && sudo yum -y install python36 python36-devel && sudo curl https://bootstrap.pypa.io/get-pip.py | sudo python3 && sudo /usr/local/bin/pip3 install psutil`
* Install “Aftermath Blame Assigner” on the server in `/opt/AftermathBlameAssigner`
    * Install the script by running → `cd /opt && sudo git clone https://github.com/cblanke2/AftermathBlameAssigner.git`
    * Update the script by running →  `cd /opt/AftermathBlameAssigner && sudo git pull`
* Set the script to run at reboot
    * Install and enable the systemd service file _(If you're running a Linux distro with systemd, use this)_
        * `sudo cp ./aftermath_blame_assigner.service /etc/systemd/system/ && sudo chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && sudo systemctl daemon-reload && sudo systemctl enable aftermath_blame_assigner.service`
    * Or add an entry into crontab to run the script on reboot _(If your distro doesn't have systemd, or you're running a non-Linux Unix-like OS, use this)_
        * Run → `sudo crontab -e`
        * Add this to the end of the file →  `@reboot /usr/bin/python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py & `
* Change any of the script’s variables
    * user_count → how many users to log (default is 5)
    * ps_count → how many processes to log (default is 15)
    * cpu_max → max cpu utilization percent (default is 90)
    * ram_max → max ram utilization percent (default is 90)
    * swap_max → max swap utilization percent (default is 90)
    * log_time → how many seconds to wait between logging high load events (default is 1)
* Manually start the script (or reboot the server)
    * `sudo python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py &`


#### Check the log
* The log is located at `/var/log/aftermath_blame_assigner.log`
* The time and date of each reboot will be logged
* When CPU, RAM, or Swap utilization hits 90% (by default) these things will be logged each second (by default):
    * The time and date
    * The current load of the CPU, RAM, and Swap
    * The current disk usage, as well as the current disk I/O in kB/s
    * The 5 users running the most processes
    * The 15 most intensive processes
* This information should point you in the direction of what account and/or process is causing most of the problems. No automatic log removal exists (as of yet), so logs may pile up.
