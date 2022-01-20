#!/bin/bash

# Verify user is running as root
if [ "$EUID" -ne 0 ]
then echo "Please run as root"
	exit
else	
	# Add non-free and contrib repositories
	sed -i 's/bullseye main/bullseye main contrib non-free/' /etc/apt/sources.list

	# install necessary software
	apt -y update
	apt -y install intel-microcode build-essential dkms linux-headers-$(uname -r)
	apt -y install sudo vim open-vm-tools openssh-server ufw molly-guard fail2ban dnsutils net-tools
	apt -y install gcc make check git tar gzip wget curl rsync nmon htop tmux neofetch zsh bpytop
	
	# Enable firewall
	ufw allow ssh
	ufw enable
	ufw reload
	
	# Modify SSH config
	cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
	sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i '/^#MaxSessions 10.*/a Protocol 2' /etc/ssh/sshd_config
	sed -i '/^Protocol 2.*/a AllowUsers shichi' /etc/ssh/sshd_config
	sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
	systemctl restart sshd.service
	
	# Create fail2ban config
	cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
	sed -i 's/destemail = root@localhost/destemail = shichi@localhost/g' /etc/fail2ban/jail.local
	sed -i 's/send = root@<fq-hostname>/send = root@localhost/g' /etc/fail2ban/jail.local
	cat <<EOF | tee /etc/fail2ban/jail.d/sshd.conf
[sshd]
enabled = true
port = 20
mode = aggressive
EOF
	systemctl enable fail2ban
	systemctl restart fail2ban
	
	# add shichi account to sudo users
	# export path because apparently you have to still do this sometimes
	export PATH=/usr/sbin/:$PATH/
	usermod -aG sudo shichi
fi
exit 0 ##success
exit 1 ##failure