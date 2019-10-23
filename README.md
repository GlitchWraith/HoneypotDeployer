# HoneypotDeployer

## Installation

Git clone this repo

````bash
git clone https://github.com/RealmOfTibbles/HoneypotDeployer.git
````

Install ansible 2.7 or newer older versions may work but are untested

````bash
sudo dnf install ansible

sudo apt install ansible

sudo yum install ansible

pip install ansible
````

## Use

In the directory you cloned the repo to you can run `./HoneypotDeployer.sh`
Honeypot Deployer takes up to three flags any more flags are ignored currently flag three doesnt affect anytheing

| Flag 1 | Flag 2 | Flag 3| Comments |
|--------|--------|-------|----------|
| --help |        |       |          |
| --info |        |       |          |
| --LogCollect |    |    | See Info |
| --Log-Pull |     |       | See Info |
| --Build-Docker-Host|   |     |     |
| --hosts |  |  | Will provision all Honeypots |
| --hosts | Honeypot Name|   |   |
| --KVM | Host Name |   | Only needed to build a VM for docker containers |
| --DockerHost | Host Name | | Needed for Simple LogPull |
| Host name | Honeypot Name | | One Time Honeypot Provison |


The program will add a group called `Honeypot-Group` all the files will be accessable for users in this group. Users will have to be added manually to this group.
## Honeypots

* Cowrie-SSH
* Cowrie-Telnet
* Cowrie-SSH-Telnet
* TelNetLogger
* FTP
* HoneySMB

## Info

### Hosts
With *--hosts* flag you can set multyple hosts to deploy to at once for a selected honeypot or all.
For this to work the *ansible/hosts* file will need to be editied adding the pattens:
* [HoneySMB] 
* [Cowrie-SSH]
* [Cowrie-Telnet]
* [Cowrie-SSH-Telnet]
* [TelnetLogger]
* [pythonftp]

Followed by the hostname/ip address

````
[Cowrie-SSH]
10.0.0.1
10.0.1.20

[TelnetLogger]
10.0.0.4
10.0.0.5

[HoneySMB]
10.0.0.4
````

### LogCollect
LogCollect in its defult state requires:
1. The local user and remote user have the same username and uses the ssh key ~/.ssh/id_rsa or specified key in ~/.ssh/config
2. The User has declared the host with **--DockerHost**

If both of these requirements can not be met you will need to modify the *PULL()* function

### Log-Pull
Log-Pull is a full ansible implentation to bring the log files from the container to the host it requires no config changes 

### Log-Pull Vs LogCollect

Log-Pull is entirly ansible based it needs no configuration but uses the ansible fetch module to transfer each file one at a time.
LogCollect uses ansible to pull the logs from the containers then uses rsync to fetch the files to the host.



### HoneySMB

The Honeypots SMB share can be configured with the .conf files in HoneySMB folder.
The SMB Shares files will be copyied from HoneySMB/Drive to match the containers /home/smb/smbDrive

### Cowrie SSH/Telnet/SSH Telnet
Each of Cowries Configuration files can be found in the subsequent mode of operation folder these are copyed over on each provision. Modify them as nessary to utilise the advanced features.
If you want to add in specific files to the honeypot to make it blend into your enviroment put them in the honeyfs folder with the full path they would have from `/`

### Build Docker Host
In order to use Build a vm to host Docker containers you first need to specify the host to install KVM on with `--KVM  hostname` then rerun with `--Build-Docker-Host` to install the requirements this will take some time as both ansible needs to install kvm/QEMU and vagrant onto the host it will need to download the base box as well. By defult the base box is ubuntu 18.04LTS but the tool also surports fedora cloud 29 which will be a smaller download to switch you need to change the directory name in `ansible/Build-Docker-Host.yml` changing the comented out line shown below
````yaml
- name: Copying Files
      copy:
        src: ../Vagrant-Docker-Host/
#        src: ../Vagrant-Fedora-Cloud/
        dest: /opt/Honeypot-Vagrant-Docker-Host/
        mode: 0775
        group: Honeypot-Group
        force: yes
````

````yaml
- name: Copying Files
      copy:
#        src: ../Vagrant-Docker-Host/
        src: ../Vagrant-Fedora-Cloud/
        dest: /opt/Honeypot-Vagrant-Docker-Host/
        mode: 0775
        group: Honeypot-Group
        force: yes
````
When this operation has been compleated the private key need to ssh into vagrants user account will appear `ssh-key/[Hostname]/private_key` The username for console login is `vagrant:THISNEEDSTOBECHANGED` which will need to be changed on login. You will also need with a program like Virtual Machine Manager change the network settings to be bridged to the wider network rather than just NAT so that the honeypots are directly interactale.

## Ansible Setup

### Ansible SSH Requirements

Ansible needs its ssh access to be keybased this you will need to generate ssh keys with `ssh-keygen` and copy them to the required host with `ssh-copy-id` to make setup smoother installing python2 on the remote hosts would be sensible.
If your remote users have a separate username this needs to be changed in the ansible.cfg along with specifiing a ssh key if its not called .ssh/id_rsa 

### Ansibles Defult hosts file
````bash
#
# It should live in /etc/ansible/hosts
#
#   - Comments begin with the '#' character
#   - Blank lines are ignored
#   - Groups of hosts are delimited by [header] elements
#   - You can enter hostnames or ip addresses
#   - A hostname/ip can be a member of multiple groups

# Ex 1: Ungrouped hosts, specify before any group headers.

## green.example.com
## blue.example.com
## 192.168.100.1
## 192.168.100.10

# Ex 2: A collection of hosts belonging to the 'webservers' group

## [webservers]
## alpha.example.org
## beta.example.org
## 192.168.1.100
## 192.168.1.110

# If you have multiple hosts following a pattern you can specify
# them like this:

## www[001:006].example.com

# Ex 3: A collection of database servers in the 'dbservers' group

## [dbservers]
## 
## db01.intranet.mydomain.net
## db02.intranet.mydomain.net
## 10.25.1.56
## 10.25.1.57

# Here's another example of host ranges, this time there are no
# leading 0s:

## db-[99:101]-node.example.com
````

## Directory Structure

````
├── ansible
│   ├── Build-Docker-Host.yml
│   ├── Container-Status.yml
│   ├── CowrieSSH-Telnet.yml
│   ├── CowrieTelnet.yml
│   ├── Cowrie.yml
│   ├── Docker-Host
│   ├── HoneySmb.yml
│   ├── hosts
│   ├── KVM-Host
│   ├── KVM-Host.yml
│   ├── LogPull.yml
│   ├── pythonftp.yml
│   ├── roles
│   │   ├── Ansible
│   │   │   └── roles
│   │   │       └── main.yml
│   │   ├── Basic
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── Cowrie-SSH
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── Cowrie-SSH-Telnet
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── Cowrie-Telnet
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── Docker
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── Git
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── HoneySMB
│   │   │   ├── main.yml
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── KVM
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── Python-FTP
│   │   │   └── roles
│   │   │       └── main.yml
│   │   ├── RAW-telnetlogger
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── seLinux
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   ├── telnetlogger
│   │   │   └── tasks
│   │   │       └── main.yml
│   │   └── Vagrant
│   │       └── tasks
│   │           └── main.yml
│   └── telnetlogger.yml
├── ansible.cfg
├── Cowrie-SSH
│   ├── cowrie.cfg.dist
│   └── honeyfs
├── Cowrie-SSH-Telnet
│   ├── cowrie.cfg.dist
│   └── honeyfs
├── Cowrie-Telnet
│   ├── cowrie.cfg.dist
│   └── honeyfs
├── HoneypotDeployer.sh
├── HoneySMB
│   ├── Drive
│   │   └── tokens
│   ├── shares.conf
│   └── smb.conf
├── Vagrant-Docker-Host
│   ├── UbuntuDocker.yml
│   └── Vagrantfile
├── Vagrant-Fedora-Cloud
│   ├── FedoraDocker.yml
│   └── Vagrantfile
└── Vagrent-Log-Box
    └── Vagrantfile
````
