# Aftermath Blame Assigner

The Aftermath Blame Assigner (_aftermath_blame_assigner.py_) is a simple script for logging resource intensive processes on Linux servers, written in Python3. Although it _can_ run on any Unix-like OS with python3 (and it's other dependencies) installed, some features may not work; for example, the disk I/O and most intensive processes fail to log on \*BSD-based OSs (such as FreeBSD and macOS).

#### Automatic Installlation
The installation of Aftermath Blame Assigner on **CentOS 7x+**, **Ubuntu 18x+**, and **Manjaro 18x+** can be automated using the _aba_install.sh_ bash script. There should be no issues running the install script on (up to date) distros closely related to **CentOS**, **Ubuntu**, and **Manjaro** (such as as **RHEL**, **Debian**, and **Arch** respectively), but this has not been extensively tested. However, installing Aftermath Blame Assigner on Fedora will have to be done manually, because of incompatibility with RHEL packages and version numbering. Installation on any other UNIX-like OS, such as \*BSD or macOS will have to be done manually as well, but because of the limited functionality of the script on these OSs installation is not recommended.

#### Manual Installlation
* Ensure all the dependencies for the script are installed
    * **Install with your OSs package manager** → `gcc git python3 python3-dev python3-pip sysstat`
    * **Install with pip3** → `psutil`
* Install “Aftermath Blame Assigner” on the server in `/opt/AftermathBlameAssigner`
    * Install the script by running → `cd /opt && sudo git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner`
      * This repo is mirrored on GitLab at `https://gitlab.com/cblanke2/AftermathBlameAssigner`
    * Update the script by running →  `cd /opt/AftermathBlameAssigner && sudo git pull`
    * Some OSs don't have an `/opt` dir, so just adjust the service file or crontab entry according to where you install it.
* Set the script to run at reboot
    * Be sure to check where python3 is installed before doing this with `which python3`. Most of the time it's `/usr/bin/python3`, but sometimes it's `/usr/local/bin/python3` (which may or may not be linked to `/usr/bin/python3`). Just double check and adjust the service file or crontab entry accordingly. 
    * Install and enable the systemd service file _(This will work on any Linux distro with systemd)_
        * `sudo cp ./aftermath_blame_assigner.service /etc/systemd/system/ && sudo chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && sudo systemctl daemon-reload && sudo systemctl enable aftermath_blame_assigner.service`
    * Or add an entry into crontab to run the script on reboot _(This will work on most any UNIX-like OS, but not CentOS)_
        * Run → `sudo crontab -e`
        * Add this to the end of the file →  `@reboot /usr/bin/python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py & `
* Manually start the script (or reboot the server)
    * If you used systemd → `sudo systemctl restart aftermath_blame_assigner.service`
    * If you used cron → `sudo python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py &`


#### Configure the scripts variables
* user_count → how many users to log (default is 5)
* ps_count → how many processes to log (default is 15)
* cpu_max → max cpu utilization percent (default is 90)
* ram_max → max ram utilization percent (default is 90)
* swap_max → max swap utilization percent (default is 90)
* log_time → how many seconds to wait between logging high load events (default is 1)

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
