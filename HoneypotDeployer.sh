#!/bin/bash
# Functions

# Honeypot Launchers
HoneySMB(){    
	echo "[!] HoneySMB Deployment"
    echo "[+] Low Interaction SMB Honeypot"
    echo -e "[+] Uses Docker"
    ansible-playbook ansible/HoneySmb.yml --list-hosts
    
	ansible-playbook ansible/HoneySmb.yml 
    
    echo "[!] Honeypot Deployment Finished"
    
}

Cowrie-SSH(){    
	echo "[!] Cowrie Deployment For SSH"
    echo "[+] High Interaction SSH Honeypot"
    echo -e "[+] Uses Docker"
    ansible-playbook ansible/Cowrie.yml --list-hosts
    
	ansible-playbook ansible/Cowrie.yml 
    
    echo "[!] Honeypot Deployment Finished"
    
}

Cowrie-Telnet(){    
	echo "[!] Cowrie Deployment For Telnet"
    echo "[+] High Interaction Telnet Honeypot"
    echo -e "[+] Uses Docker"
    ansible-playbook ansible/CowrieTelnet.yml --list-hosts
    
	ansible-playbook ansible/CowrieTelnet.yml 
    
    echo "[!] Honeypot Deployment Finished"
    
}

Cowrie-SSH-Telnet(){    
	echo "[!] Cowrie Deployment SSH and Telnet Modes"
    echo "[+] High Interaction SSH + Telnet Honeypot"
    echo -e "[+] Uses Docker"
    ansible-playbook ansible/CowrieSSH-Telnet.yml --list-hosts
    
	ansible-playbook ansible/CowrieSSH-Telnet.yml 
    
    echo "[!] Honeypot Deployment Finished"
    
}

TelNetLogger(){    
	echo "[!] TelnetLogger Deployment "
    echo "[+] Low Interaction Telnet Honeypot"
    echo -e "[+] Uses Docker"
    ansible-playbook ansible/telnetlogger.yml --list-hosts
    
	ansible-playbook ansible/telnetlogger.yml
    
    echo "[!] Honeypot Deployment Finished"
    
}

ftp(){    
	echo "[!] python ftp honeypot Deployment "
    echo "[+] Low Interaction ftp Honeypot"
    echo -e "[+] Uses Docker"
    ansible-playbook ansible/pythonftp.yml --list-hosts
    
	ansible-playbook ansible/pythonftp.yml
    
    echo "[!] Honeypot Deployment Finished"
    
}
# Log pull

PULL(){
    ansible-playbook ansible/LogPull.yml
    rsync -avzru `cat ansible/Docker-Host`:/opt/Honeypot-Logs /opt/Honeypot-Logs/`cat ansible/Docker-Host`
    exit
}

STATUS(){
    ansible-playbook ansible/Container-Status.yml
}

# User Messages
helpmsg(){
    echo -e "\tHoneypot Deployer\n    This Program uses ansable to deploy some preconfigured honeypots\n    As Such please configure ssh keys to accounts with sudo or root\n    Use --KVM ip to define a server to set up as a vm host\n    Use --DockerHost ip to define a server as a docker host\n    Use --Build-Docker-Host to build a vm to host docker containers\n    Use --hosts to not modify the hosts file\n    Currently Surported Honeypots Are:\n\t SMB \t-> HoneySMB\n\t SSH \t-> Cowrie\n\t Telnet\t-> Cowrie\n\t\t-> telnetlogger\n\t FTP \t-> Python-ftp\n    Logs are gathered with --LogPull Ansible moves logs to /opt/Honeypot-Logs on the Declared DockerHost\n    rsync Is used to bring them to the host the script expects that the current user can log into the host\n    With the key stored ~/.ssh/id_rsa In other cases modify the PULL function as requred"
    exit
}

infomsg(){
    case "$1" in
        HoneySMB)
            echo -e "[!] For Best Results run on a Ubuntu Host\n    HoneySMB is a SMB based honeypot \n    To interact Directly with the honypot ssh to the host and run\n\t\"sudo docker exec -t -i Honeypot-SMB /bin/bash\"" 
            exit
            ;;
        SMB)
            echo -e "[!] For Best Results run on a Ubuntu Host\n    HoneySMB is a SMB based honeypot \n    To interact Directly with the honypot ssh to the host and run\n\t\"sudo docker exec -t -i Honeypot-SMB /bin/bash\"" 
            exit
            ;;
        SSH)
            echo -e "[!] For Best Results run on a Ubuntu Host\n    Cowrie is a SSH based honeypot \n    To interact Directly with the honypot ssh to the host and run\n\t\"sudo docker exec -t -i Honeypot-SSH-Cowrie /bin/bash\"" 
            exit
            ;;
        Cowrie)
            echo -e "    Cowrie is a SSH or Telnet based honeypot \n    To interact Directly with the honypot ssh to the host and run\n\t\"sudo docker exec -t -i Honeypot-[Mode]-Cowrie /bin/bash\"" 
            exit
            ;;
        TelnetLogger)
            echo -e "    TelNetLogger is a  Telnet based honeypot \n    To interact Directly with the honypot ssh to the host and run\n\t\"sudo docker exec -t -i Honeypot-Telnet-telnetLogger /bin/bash\"" 
            exit
            ;;
        Python-ftp)
            echo -e "    Cowrie is a SSH or Telnet based honeypot \n    To interact Directly with the honypot ssh to the host and run\n\t\"sudo docker exec -t -i Honeypot-FTP-Python-FTP /bin/bash\"" 
            exit
            ;;
        *)
            echo -e "[!] Sorry no Info on that heres the help message"
            helpmsg
            ;;
    esac
}

# Internal Use only
Declare_KVM_Host(){
    echo "[KVM_Host]" > ansible/KVM-Host
    echo $1 >> ansible/KVM-Host
    echo "    KVM Host: "
    echo "    " + $1
}

Add_KVM_Host(){
    cat ansible/KVM-Host >> ansible/hosts
}

Declare_Docker_Host(){    
    echo $1 > ansible/Docker-Host
    echo "    Docker Host: "
    echo "    " + $1
}

Add_Docker_Host(){
    echo "[DockerHost]" >> ansible/Docker-Host
    cat ansible/Docker-Host >> ansible/hosts
}

Backup_hosts(){
    cat ansible/hosts > `date | sed 's/ //g' | cut -c 9- | sed -r 's/:/-/g'`.notrack
}

# Deciding Code for flags for General Deployment

# For one Flag
if [ $# == 1 ] ; then 

    case "$1" in
        --LogPull)
            PULL
            ;;
        --help)            
            helpmsg
            ;;
        --hosts)
            HoneySMB
            Cowrie-SSH
            Cowrie-Telnet
            Cowrie-SSH-Telnet
            TelnetLogger
            ftp
            ;;         
        -h)            
           helpmsg            
            ;;
        --Build-Docker-Host)
            Backup_hosts
            echo "" > ansible/hosts
            Add_KVM_Host
            cat ansible/hosts
            ansible-playbook ansible/Build-Docker-Host.yml
            exit
            ;;
        -s)
            STATUS
            ;;

         
    esac

fi


# For Two flags
# Ip / Host , Service
if [ $# == 2 ] ; then 

    if [ "$1" == --hosts ]; then
        case "$2" in
            SMB)                     
                HoneySMB
                exit
            ;;         
            HoneySMB)  
                HoneySMB
                exit
            ;;
            SSH)                     
                Cowrie-SSH
                exit
            ;;         
            Cowrie)  
                Cowrie-SSH
                exit
            ;;
            Cowrie-SSH)  
                Cowrie-SSH
                exit
            ;;
            Cowrie-Telnet)  
                Cowrie-Telnet
                exit
            ;;
            Cowrie-SSH-Telnet)  
                Cowrie-SSH-Telnet
                exit
            ;;
            FTP)
                ftp
                exit
            ;;
            Python-ftp)
                ftp
                exit
            ;;
            TelNetLogger)
                TelNetLogger
                exit
            ;;

        esac
    fi

    if [ "$1" == --info ]; then
        infomsg $2
    fi

    if [ "$1" == -i ] ; then
        infomsg $2
    fi

    case "$2" in
        SMB)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            HoneySMB
            exit
            ;;
         
        HoneySMB)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            HoneySMB
            exit            
            ;;

        SSH)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            Cowrie-SSH
            exit
            ;;
         
        Cowrie)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            Cowrie-SSH
            exit            
            ;;

        Cowrie-SSH)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            Cowrie-SSH
            exit            
            ;;

        Cowrie-Telnet)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            Cowrie-Telnet
            exit            
            ;;

        Cowrie-SSH-Telnet)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            Cowrie-SSH-Telnet
            exit            
            ;;

        TelNetLogger)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            TelNetLogger
            exit            
            ;;
        Telnet)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts            
            TelNetLogger
            exit            
            ;;

        FTP)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts
            ftp
            exit
            ;;

        Python-ftp)
            Backup_hosts
            echo "[DockerHost]" > ansible/hosts
            echo $1 >> ansible/hosts
            ftp
            exit
            ;;
            
        *)

            case "$1" in 

                --KVM)
                    Declare_KVM_Host $2
                    exit
                    ;;
                --DockerHost)
                    Declare_Docker_Host $2
                    exit
                    ;;        
                *)
                    helpmsg
                    ;;
         
                esac

            ;;
    esac  

fi
# For three Flags 3rd flag currently unused.
# Host to Deploy , Service, IptoBindto
# Deciding code
if [ $# == 3 ] ; then 

    if [ "$1" == --hosts ]; then
        case "$2" in
            SMB)                     
                HoneySMB
                exit
            ;;         
            HoneySMB)  
                HoneySMB
                exit
            ;;
            SSH)                     
                Cowrie-SSH
                exit
            ;;         
            Cowrie)  
                Cowrie-SSH
                exit
            ;;
            Cowrie-SSH)  
                Cowrie-SSH
                exit
            ;;
            Cowrie-Telnet)  
                Cowrie-Telnet
                exit
            ;;
            Cowrie-SSH-Telnet)  
                Cowrie-SSH-Telnet
                exit
            ;;
            FTP)
                ftp
                exit
            ;;
            Python-ftp)
                ftp
                exit
            ;;
            TelNetLogger)
                TelNetLogger
                exit
            ;;
        esac
    fi
        case "$2" in
            SMB)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                HoneySMB
                exit
            ;;
         
            HoneySMB)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                HoneySMB
                exit            
            ;;

            SSH)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                Cowrie-SSH
                exit
            ;;
         
            Cowrie)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                Cowrie-SSH
                exit            
            ;;
            Cowrie-SSH)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                Cowrie-SSH
                exit            
            ;;

            Cowrie-Telnet)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                Cowrie-Telnet
                exit            
            ;;
            Cowrie-SSH-Telnet)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                Cowrie-SSH-Telnet
                exit            
            ;;
            FTP)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts
                ftp
                exit
                ;;
            Python-ftp)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts
                ftp
                exit
                ;;
            TelNetLogger)
                Backup_hosts
                echo "[DockerHost]" > ansible/hosts
                echo $1 >> ansible/hosts            
                TelNetLogger
                exit            
                ;;
        esac
fi