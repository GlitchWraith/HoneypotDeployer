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
| --LogPull |     |       | See Info Message |
| --Build-Docker-Host|   |     |     |
| --hosts |  |  | Will provision all Honeypots |
| --hosts | Honeypot Name|   |   |
| --KVM | Host name |   | Only needed to build a VM for docker containers |
| --DockerHost | Host name | | Needed for Simple LogPull |
| Host name | Honeypot | | One Time Honeypot Provison |

## Info

### LogPull
LogPull in its defult state requires:
1. The local user and remote user have the same username and uses the ssh key ~/.ssh/id_rsa
2. The User has declared the host with **--DockerHost**

If ether of these requirements can not be met you will need to modify the *PULL()* function

### HoneySMB

The Honeypots SMB share can be configured with the .conf files in HoneySMB folder.
The SMB Shares files will be copyied from HoneySMB/Drive to match the containers /home/smb/smbDrive

### Cowrie SSH/Telnet/SSH Telnet
Each of Cowries Configuration files can be found in the subsequent mode of operation folder
these are copyed over on each provision. Modyfi them as nessary to utilise the advanced features.
