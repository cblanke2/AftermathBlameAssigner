# Aftermath Blame Assigner

The Aftermath Blame Assigner (_aftermath_blame_assigner.py_) is a simple script for logging resource intensive processes on Linux servers, written in Python3. Although it _can_ run on any Unix-like OS with python3 (and it's other dependencies) installed, some features may not work; for example, the disk I/O and most intensive processes fail to log on \*BSD-based OSs (such as FreeBSD and macOS).

#### Automatic Installlation
The installation of Aftermath Blame Assigner on **CentOS 7x+**, **Ubuntu 18x+**, and **Manjaro 18x+** can be automated using the _aba_install.sh_ bash script. There should be no issues running the install script on (up to date) distros closely related to **CentOS**, **Ubuntu**, and **Manjaro** (such as as **RHEL**, **Debian**, and **Arch** respectively), but this has not been extensively tested.

To install Aftermath Blame Assigner on these distros, run the installer script using `wget https://gitlab.com/cblanke2/AftermathBlameAssigner/raw/master/aba_install.sh && sudo bash aba_install.sh` (GitLab) or `wget https://raw.githubusercontent.com/cblanke2/AftermathBlameAssigner/master/aba_install.sh && sudo bash aba_install.sh` (GitHub). If _wget_ is not installed, you can use `curl https://gitlab.com/cblanke2/AftermathBlameAssigner/raw/master/aba_install.sh > aba_install.sh && sudo bash aba_install.sh` (GitLab) or `curl https://raw.githubusercontent.com/cblanke2/AftermathBlameAssigner/master/aba_install.sh > aba_install.sh && sudo bash aba_install.sh` (GitHub). On any other distro, please follow the manual install instructions below. Installation on any other UNIX-like OS, such as \*BSD or macOS will have to be done manually as well, but because of the limited functionality of the script on these OSs, installation is not recommended.

The _aba_remote.sh_ script can handle installation, reinstallation, uninstallation, and updating of Aftermath Blame Assigner on any remote Linux server supported by the installer script. Just run `bash aba_remote.sh [install/reinstall/uninstall/update] <USER>@<SERVER>`. It's written with root access over ssh in mind (which is VERY insecure), but as long as your user account has proper privileges, you should run into no issues.

#### Manual Installlation
* Ensure all the dependencies for the script are installed
    * **Install these packages** → `git python3 python3-psutil sysstat`
    * If _psutil_ is not in your OS repos, install `gcc python3-dev python3-pip` and install it through pip3
* Install “Aftermath Blame Assigner” on the server in `/opt/AftermathBlameAssigner`
    * Install the script by running → `cd /opt && git clone https://github.com/cblanke2/AftermathBlameAssigner.git && cd /opt/AftermathBlameAssigner`
      * This repo is hosted on GitLab at `https://gitlab.com/cblanke2/AftermathBlameAssigner`
      * And mirrored on GitHub at `https://github.com/cblanke2/AftermathBlameAssigner`
    * Update the script by running →  `cd /opt/AftermathBlameAssigner && git pull`
    * Some OSs don't have an `/opt` dir, so just adjust the service file or crontab entry according to where you install it.
* Set the script to run at reboot
    * Be sure to check where python3 is installed before doing this with `which python3`. Most of the time it's `/usr/bin/python3`, but sometimes it's `/usr/local/bin/python3` (which may or may not be linked to `/usr/bin/python3`). Just double check and adjust the service file or crontab entry accordingly. 
    * Install and enable the systemd service file _(This will work on any Linux distro with systemd)_
        * `cp ./aftermath_blame_assigner.service /etc/systemd/system/ && chmod 664 /etc/systemd/system/aftermath_blame_assigner.service && systemctl daemon-reload && systemctl enable aftermath_blame_assigner.service`
    * Or add an entry into crontab to run the script on reboot _(This will work on most any UNIX-like OS, but not CentOS)_
        * Run → `crontab -e`
        * Add this to the end of the file →  `@reboot /usr/bin/python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py & `
* Manually start the script (or reboot the server)
    * If you used systemd → `systemctl restart aftermath_blame_assigner.service`
    * If you used cron → `python3 /opt/AftermathBlameAssigner/aftermath_blame_assigner.py &`


#### Configure the scripts variables
* user_count → how many users to log (default is 5)
* ps_count → how many processes to log (default is 15)
* cpu_max → max cpu utilization percent (default is 95)
* ram_max → max ram utilization percent (default is 95)
* swap_max → max swap utilization percent (default is 95)
* log_time → how many seconds to wait between logging high load events (default is 5)

#### Check the log
* The log is located at `/var/log/aftermath_blame_assigner.log`
* The timestamps of the last server reboot and script restart will be logged
* When CPU, RAM, or Swap utilization hits 95% (by default) these things will be logged every 5 seconds (by default):
    * The time and date
    * The current load of the CPU, RAM, and Swap
    * The current disk usage, as well as the current disk I/O in kB/s
    * The 5 (by default) users running the most processes
    * The 15 (by default) most intensive processes (sorted by CPU usage, then RAM usage)
* This information should point you in the direction of what account and/or process is causing most of the problems. No automatic log removal exists (as of yet), so logs may pile up.

#### Uninstalling

To uninstall Aftermath Blame Assigner after installing it with _aba_install.sh_, either run  _aba_uninstall.sh_ or follow these instructions.
* Uninstall the systemd service → `sudo systemctl stop aftermath_blame_assigner.service && sudo systemctl disable aftermath_blame_assigner.service && sudo rm /etc/systemd/system/aftermath_blame_assigner.service && sudo systemctl daemon-reload && sudo systemctl reset-failed`
* Remove the installation → `sudo rm -rf /opt/AftermathBlameAssigner`
* Remove the log if desired → `sudo rm /var/log/aftermath_blame_assigner.log`
* Remove any unneeded dependencies (this varies by OS) if you want