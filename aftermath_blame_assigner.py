#!/usr/bin/python3
# 
# aftermath_blame_assigner.py
# 	logger of resource intensive processes 
#
# Written by: Chris Blankenship <chrisb@reclaimhosting.com>
#

user_count = 5 # The X users running the most processes
ps_count = 15 # Top X intensive processes (by both CPU and RAM usage)
cpu_max = 95 # Percent of CPU utilization to be considered "high"
ram_max = 95 # Percent of RAM utilization to be considered "high"
swap_max = 95 # Percent of Swap utilization to be considered "high"
log_time = 5 # Seconds to wait between logging

import psutil, socket, subprocess, time, urllib.request

def user_log():
	#
	# Logs the users running the most processes
	user_count_echo = 'echo THE ' + str(user_count) + ' USERS RUNNING THE MOST PROCESSES >> /var/log/aftermath_blame_assigner.log'
	subprocess.call(user_count_echo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	subprocess.call('echo "---------------------------------------------------------------------------" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	user_count_log = 'ps hax -o user | sort | uniq -c | sort -gr | head -n ' + str(user_count) + ' >> /var/log/aftermath_blame_assigner.log'
	subprocess.call(user_count_log, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	return 0

def cpu_log():
	#
	# Logs the most memory intensive processes
	cpu_count_echo = 'echo THE ' + str(ps_count) + ' MOST CPU INTENSIVE PROCESSES >> /var/log/aftermath_blame_assigner.log'
	subprocess.call(cpu_count_echo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	subprocess.call('echo "---------------------------------------------------------------------------" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	cpu_count_log = 'ps -eo user,uid,pid,pcpu,pmem,start,time,comm,args=PATH --sort=-pcpu | head -n ' + str(ps_count + 1) + ' >> /var/log/aftermath_blame_assigner.log'
	subprocess.call(cpu_count_log, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	return 0

def mem_log():
	#
	# Logs the most memory intensive processes
	mem_count_echo = 'echo THE ' + str(ps_count) + ' MOST MEMORY INTENSIVE PROCESSES >> /var/log/aftermath_blame_assigner.log'
	subprocess.call(mem_count_echo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	subprocess.call('echo "---------------------------------------------------------------------------" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	mem_count_log = 'ps -eo user,uid,pid,pcpu,pmem,start,time,comm,args=PATH --sort=-pmem | head -n ' + str(ps_count + 1) + ' >> /var/log/aftermath_blame_assigner.log'
	subprocess.call(mem_count_log, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	#
	return 0

def monitor():
	while True:
		cpu_load_list = psutil.cpu_percent(interval=1, percpu=True)
		cpu_load = int(sum(cpu_load_list) / len(cpu_load_list))
		ram_load = int(dict(psutil.virtual_memory()._asdict())['percent'])
		swap_load = int(psutil.swap_memory().percent)
		#
		if (cpu_load >= cpu_max) or (ram_load >= ram_max) or (swap_load >= swap_max):
			#
			# If CPU, RAM, or Swap max has been hit then. . .
			subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			subprocess.call('echo "============ HIGH LOAD DETECTED - `date` ============" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			#
			# Prints CPU load
			cpu_load_echo = 'echo "CPU Load: ' + str(cpu_load) + '% " >> /var/log/aftermath_blame_assigner.log'
			subprocess.call(cpu_load_echo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			#
			# Prints RAM load
			ram_load_echo = 'echo "RAM Load: ' + str(ram_load) + '% " >> /var/log/aftermath_blame_assigner.log'
			subprocess.call(ram_load_echo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			#
			# Prints Swap load
			swap_load_echo = 'echo "Swap Load: ' + str(swap_load) + '% " >> /var/log/aftermath_blame_assigner.log'
			subprocess.call(swap_load_echo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			#
			subprocess.call('echo "----" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			#
			# Prints current usage of disk mounted at root
			disk_usage_echo = 'echo current disk usage: ' + str(psutil.disk_usage('/').percent) + '%  >> /var/log/aftermath_blame_assigner.log'
			subprocess.call(disk_usage_echo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			#
			# Prints current Disk I/O in kB/s
			subprocess.call("echo kB/s read from disk: `iostat -d | tail -n +4 | head -n -1 | awk '{s+=$3} END {print s}'` >> /var/log/aftermath_blame_assigner.log", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			subprocess.call("echo kB/s written to disk: `iostat -d | tail -n +4 | head -n -1 | awk '{s+=$4} END {print s}'` >> /var/log/aftermath_blame_assigner.log", stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			#
			# Calls the functions that log users and processes
			subprocess.call('echo "---------------------------------------------------------------------------" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			user_log()
			subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			cpu_log()
			subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			mem_log()
			subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			subprocess.call('echo "===========================================================================" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
			subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
		time.sleep(log_time)
	return 0

def main():
	try:
		server_ip = str(urllib.request.urlopen('http://icanhazip.com/').read().decode('utf8')[:-1])
	except:
		server_ip = "127.0.0.1"
	sysinfo = 'echo "' + str(socket.gethostname()) + ' (' + server_ip + ') - SCRIPT RESTARTED" >> /var/log/aftermath_blame_assigner.log'
	#
	subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	subprocess.call('echo "===========================================================================" >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	subprocess.call(sysinfo, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	subprocess.call('date >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	subprocess.call('who -b >> /var/log/aftermath_blame_assigner.log', stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	subprocess.call('echo "===========================================================================" >> /var/log/aftermath_blame_assigner.log',stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	subprocess.call('echo "" >> /var/log/aftermath_blame_assigner.log',stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, shell = True)
	monitor()

main()
