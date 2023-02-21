#!/bin/bash

#Defining variables and functions.
#
openvpn_dir='/usr/share/doc/openvpn'
#rsa_default_dir='/usr/share/easy-rsa'
vpnconf_dir='/etc/openvpn'
sampleconf_dir='/etc/openvpn/sample-config-files'
rsaconf_dir='/etc/openvpn/easy-rsa'
rsapki_dir='/etc/openvpn/easy-rsa/pki'
pvtkey_dir='/etc/openvpn/easy-rsa/pki/private'
crt_dir='/etc/openvpn/easy-rsa/pki/issued'
dest_client='/etc/openvpn/client'
PWD=$(pwd)
#
#To pervent errors if this script runs second time.
systemctl stop openvpn@server 2>/dev/null >/dev/null
#Function that creates loading using some operators in loop. Function takes two arguments, first argument is message displaying before and after the process and second argument is
#time that it will hold before ending loop. Except system update and package installation, which is another loop, this function doesn't run on actual running process based, it just
#sleeps for time that we specify in second argument.
loading() {
    echo "$1"
    tput civis       
    t_start=$(date +%s)
    while true
    do
        t_current=$(date +%s)
        t_running=$((t_current - t_start))
        if [ $t_running -gt $2 ]
        then
            printf "\033[1A"
            echo "$1.....DONE"
            tput cvvis             
            break
        else
            for i in '/' '-' '\' '|'
            do   
                echo -n $i
                sleep 0.1
                echo -ne "\r"
            done
        fi
    done
}
#
#Unless function 'loading', This function produce realtime loading loop that actually based on the time of running process. As soon as the process finish, loop with break.
#this function takes two argument, first argument is process name and second argument is message showed before and after the process is done.
proc_loading () {
    echo $2
    tput civis
    while true
    do
        job=$(ps -ef | grep $1 | grep -v grep)
        if [ -z "$job" ]
        then
            printf "\033[1A"
            echo "$2......DONE"
            tput cvvis           
            break
        else
            for i in '/' '-' '\' '|';
            do
                echo -n $i
                sleep 0.1
                echo -ne "\r"
            done
        fi
    done
}
#
#Verifying System Support
ubuntu="ubuntu"
redhat="rhel"
centos="centos"
mint="linuxmint"
popos="pop"
suse_leap="opensuse-leap"
suse_tw="opensuse-tumbleweed"
suse_aws="sles"
debian="debian"
fedora="fedora"
aws_linux="amzn"
kali="kali"
rocky="rocky"
arch="arch"
alpine="alpine"
#Classifying distros for easy management of configurations.
#
#ArchLinux is nor Fedora neither debian as it works on it's own architecture. but vpn can be configuered on Arch in both ways as debian & fedora. using fedora configuration to configure vpn on arch linux. 
#Alpine is also independent distro like arch. using debian configurations to configure vpn on alpine linux.
#
debian_dis=("$ubuntu" "$mint" "$popos" "$debian" "$kali")
fedora_dis=("$centos" "$redhat" "$fedora" "$aws_linux" "$rocky")
suse_dis=("$suse_leap" "$suse_aws" "$suse_tw")
#Creating list of supported distros. This list is mainly used while installing packages and updating system.
spt_sys=("$ubuntu" "$redhat" "$centos" "$mint" "$popos" "$suse_leap" "$suse_tw" "$suse_aws" "$debian" "$fedora" "$aws_linux" "$kali" "$rocky" "$arch" "$alpine")
sys_chk=$(cat /etc/os-release | grep ^"ID=" | cut -c4- | sed 's/"//g')
os=""
for i in "${spt_sys[@]}"
do
    if [[ "$sys_chk" == $i ]]
    then
        os="y"
        break
    else
        os="n"
    fi
done
if [[ $os == "y" ]]
then
    echo 
    echo "******************** Initilazing VPN Configuration for $i ************************"
    echo " "
else
    echo
    echo "Distro is not supported yet. Stay tuned on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    exit
fi
#
#
#---------------------Server Configuration----------------------------
#
#
#Updating system along with installing required packages.
if [[ " ${debian_dis[*]} " == *" $sys_chk "* ]]
then
    apt -y purge openvpn 2>/dev/null >/dev/null
    yes|ufw reset 2>/dev/null >/dev/null
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    apt -y update 2>/dev/null >/dev/null &&
    apt reinstall -y openvpn git net-tools ufw 2>/dev/null >/dev/null &
    proc_loading 'apt' 'Updating System and Installing required packages'
elif [[ "$sys_chk" == "$arch" ]]
then
    yes|pacman -R openvpn 2>/dev/null >/dev/null
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    echo " "
    pacman -Sy 2>/dev/null >/dev/null
    proc_loading 'pacman' 'Checking system repositories'
    yes|pacman -S openvpn git net-tools firewalld 2>/dev/null >/dev/null &
    echo " "
    proc_loading 'pacman' 'Installing required packages'
elif [[ "$sys_chk" == "$centos" ]]
then
    yum -y remove openvpn 2>/dev/null >/dev/null &&
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    yum -y install epel-release 2>/dev/null >/dev/null &
    proc_loading 'yum' 'Updating repositories'
    yum -y install openvpn policycoreutils-python-utils git net-tools firewalld 2>/dev/null >/dev/null &
    echo " "
    proc_loading 'yum' 'Installing required packages'
elif [[ "$sys_chk" == "$alpine" ]]
then
    apk del openvpn 2>/dev/null >/dev/null
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    apk update 2>/dev/null >/dev/null &&
    apk add ncurses 2>/dev/null >/dev/null
    proc_loading 'apk' 'Updating System'
    apk add openvpn git net-tools ufw openssl 2>/dev/null >/dev/null &
    proc_loading 'apk' 'Installing required packages'
elif [[ "$sys_chk" == "$rocky" ]]
then
    yum -y remove openvpn 2>/dev/null >/dev/null &&
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    yum -y install epel-release 2>/dev/null >/dev/null &&
    yum -y install openvpn policycoreutils-python-utils git net-tools firewalld 2>/dev/null >/dev/null &
    proc_loading 'yum' 'Updating System and Installing required packages'
elif [[ "$sys_chk" == "$fedora" ]]
then
    yum -y remove openvpn 2>/dev/null >/dev/null &&
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    yum -y install openvpn policycoreutils-python-utils git openssl net-tools firewalld 2>/dev/null >/dev/null &
    proc_loading 'yum' 'Updating System and Installing required packages'
elif [[ "$sys_chk" == "$aws_linux" ]]
then
    yum remove -y openvpn 2>/dev/null >/dev/null &&
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    amazon-linux-extras install -y epel 2>/dev/null >/dev/null
    proc_loading 'amazon-linux-extras' 'Enabling Amazon Linux Extra Repositories'
    yum install -y openvpn policycoreutils-python git openssl net-tools firewalld 2>/dev/null >/dev/null &
    echo " "
    proc_loading 'yum' 'Updating System and Installing required packages'
elif [[ "$sys_chk" == "$redhat" ]]
then
    yum remove -y openvpn 2>/dev/null >/dev/null && rm -rf /etc/openvpn 2>/dev/null >/dev/null
    yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm 2>/dev/null >/dev/null &
    proc_loading 'yum' 'Checking repositories for required packages'
    yum install -y openvpn git net-tools firewalld 2>/dev/null >/dev/null &
    echo " "
    proc_loading 'yum' 'Updating System and Installing required packages'
elif [[ " ${suse_dis[*]} " == *" $sys_chk "* ]]
then
    zypper remove -y openvpn 2>/dev/null >/dev/null &&
    rm -rf /etc/openvpn 2>/dev/null >/dev/null
    zypper install --force -y openvpn 2>/dev/null >/dev/null &&
    zypper install -y git net-tools firewalld 2>/dev/null >/dev/null &
    proc_loading 'zypper' 'Updating System and Installing required packages'
fi
#OpenVPN verification process is mapped with string "OpenVPN" in 'openvpn --version' command
sleep 1
if [[ `openvpn --version | head -1 | awk '{print$1}'` = "OpenVPN" ]]
then
    echo " "
    echo "OpenVPN Version: $(openvpn --version | head -1 | awk '{print$1,$2}') ....VERIFIED"
else
    echo -e "OpenVPN is not installed correctly. It could be a missing file or something.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    exit
fi
#
#Git verification process is mapped with checking /bin OR /sbin directory for 'git' command file.
# sleep 1
# if [[ -n $(ls /bin|grep git) ]] || [[ -n $(ls /sbin|grep git) ]]
# then
#     echo
#     echo "$(git --version) ....VERFIED"
# else
#     echo
#     echo -e "Git is not installed correctly. It could be a missing file or something.\naise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
# fi
echo " "
#
#
#Copying both openvpn and easy-rsa package files in the most conveinent directory for ease of use.
#Default/Sample configuration files are missing sometimes while install openvpn package.
#It would be better if we update and get latest configuration files from OpenVPN GitHub repository.
#Cloing requierd files OpenVPN GitHub Repository.
git clone https://github.com/OpenVPN/openvpn.git 2>/dev/null >/dev/null &
git clone https://github.com/OpenVPN/easy-rsa.git 2>/dev/null >/dev/null &
proc_loading 'git' 'Cloning Files From OpenVPN GitHub Repository'
echo " "
loading 'Checking Required Files and Directories' 5
sample="$(find $(pwd) -name 'sample-config-files')"
easyrsa=$(find $(pwd) -name 'easyrsa?')
cp -r $sample $vpnconf_dir
mkdir -p $vpnconf_dir/easy-rsa && cp -r $easyrsa/* $rsaconf_dir
#OpenVPN GitHub package verfication method is mapped with checking 'sample-config-files' directory
#in vpn configuration directory.
sleep 1
if [[ -z $(ls $vpnconf_dir|grep 'sample-config-files') ]]
then
    echo -e "OpenVPN GitHub Package directory not found in the system. It could be Git Cloning failed or something.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    sleep 2
    exit
else
    echo " "
    echo "OpenVPN GitHub Package is Present. ....VERIFIED"
fi
#
#Easy-rsa verification process is mapped with checking 'easy-rsa' directory in /usr/share path.
sleep 1
if [[ -z $(ls $vpnconf_dir|grep 'easy-rsa') ]]
then
    echo
    echo -e "Easy-rsa is not installed correctly. It could be a missing file or something.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    exit
else
    rsa_version="$($rsaconf_dir/./easyrsa | sed -n 2p | awk '{print$1,$2}')"
    echo
    echo "$rsa_version ....VERIFIED"
fi
#Copying server configuration file in main configuration directory.
echo " "
loading "Generating Server Configuration file" 2
cp -rf $sampleconf_dir/server.conf $vpnconf_dir
#
#Editing the conf file and doing required changes
echo " "
#
echo "Starting Server Configuration..."
sleep 2
clear
#
echo "**********************Configuring OpenVPN Server and Client****************************"
echo
echo "OpenVPN recommends UDP protocol but you can use TCP if require"
while true
do
    echo
    read -p "Select Protocol (TCP/UDP): " pbx_proto
    if [[ $pbx_proto == "tcp" ]] || [[ $pbx_proto == "TCP" ]]
    then
        sed -i 's/;proto tcp/proto tcp4/' $vpnconf_dir/server.conf
        sed -i 's/proto udp/;proto udp/' $vpnconf_dir/server.conf
        sed -i 's/explicit-exit-notify 1/;explicit-exit-notify 1/' $vpnconf_dir/server.conf
        echo
        pbx_proto='TCP'
        echo "Protocol is set to: $pbx_proto "
        pbx_proto='tcp'
        break
    elif [[ $pbx_proto == "udp" ]] || [[ $pbx_proto == "UDP" ]]
    then
        echo
        sed -i 's/proto udp/proto udp4/' $vpnconf_dir/server.conf
        pbx_proto='UDP'
        echo "Protocol is set to: $pbx_proto "
        pbx_proto='udp'
        break
    elif [[ $pbx_proto == "" ]]
    then
        echo
        sed -i 's/proto udp/proto udp4/' $vpnconf_dir/server.conf
        echo "Protocol is set to: UDP"
        pbx_proto='udp'
        break
    else
        echo
        echo "Unable to use $pbx_proto as Protocol. Try again with TCP/UDP only."
    fi
done
#
#
echo
while true
do
    read -p "Specify Port (Press ENTER to use OpenVPN default 1194 port): " pbx_port
    if [[ $pbx_port == "" ]]
    then
        echo " "
        echo "Port is set to: 1194"
        pbx_port='1194'
        break
    elif [ $pbx_port -gt 65535 ]
    then
        echo " "
        echo "$pbx_port is out of port range. Select port between 1-65535."
        sleep 1
    elif [[ $pbx_port =~ ^[+-]?[0-9]+$ ]]
    then
        sed -i "s/port 1194/port $pbx_port/" $vpnconf_dir/server.conf
        echo " "
        echo "Port is set to: $pbx_port"
        break
    else
        echo
        echo -e "Looks like your input is either a string or out of port range.\nSelect port from 1-65535 range."
    fi
done
#
#
#Enabling default network gateway redirect and dhcp bypassing
sed -i 's/;push "redirect-gateway def1 bypass-dhcp"/push "redirect-gateway def1 bypass-dhcp"/' $vpnconf_dir/server.conf
#loading "Enabling Default Network Gateway and bypssing DHCP" 3
#
#Configuring DNS servers
while true
do
    echo " "
    read -p "Enter your Primary DNS address (Press ENTER to use OpenVPN DNS Servers): " pbx_dns0
    if [[ $pbx_dns0 == "" ]]
    then
        sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.222"/' $vpnconf_dir/server.conf
        sed -i 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 208.67.220.220"/' $vpnconf_dir/server.conf
        echo " "
        loading "Configuring OpenVPN default DNS Servers" 2
        break
    elif  [[ $pbx_dns0 =~ ^[+-]?[0-9]+\.?[0-9]+.?[0-9]+.?[0-9]*$ ]]
    then
        echo " "
        read -p "Enter your Secondary DNS address: " pbx_dns1
        if [[ $pbx_dns1 =~ ^[+-]?[0-9]+\.?[0-9]+.?[0-9]+.?[0-9]*$ ]]
        then
            sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.222"/' $vpnconf_dir/server.conf
            sed -i "s/208.67.222.222/$pbx_dns0/" $vpnconf_dir/server.conf
            sed -i 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 208.67.220.220"/' $vpnconf_dir/server.conf
            sed -i "s/208.67.220.220/$pbx_dns1/" $vpnconf_dir/server.conf
            echo " "
            loading "Configuring [$pbx_dns0 & $pbx_dns1] as DNS Servers" 2
            break
        elif [[ $pbx_dns1 == "" ]]
        then
            pbx_dns1='208.67.220.220'
            sed -i 's/;push "dhcp-option DNS 208.67.222.222"/push "dhcp-option DNS 208.67.222.222"/' $vpnconf_dir/server.conf
            sed -i "s/208.67.222.222/$pbx_dns0/" $vpnconf_dir/server.conf
            sed -i 's/;push "dhcp-option DNS 208.67.220.220"/push "dhcp-option DNS 208.67.220.220"/' $vpnconf_dir/server.conf
            echo " "
            loading "Configuring [$pbx_dns0 & $pbx_dns1] as DNS Servers" 2
            break
        else
            echo " "
            echo -e "Entered DNS is either not of valid range or not of valid format.\nEnter in x.x.x.x format and use only numbers."
            sleep 2
        fi
    else
        echo " "
        echo -e "Entered DNS is either not of valid range or not of valid format.\nEnter in x.x.x.x format and use only numbers."
        sleep 2
    fi
done
#
#Disabling (FOR NOW) additional HMAC SSL/TSL security. It's a good option to include in
#the authentication for better security.
sed -i 's/tls-auth ta.key 0/;tls-auth ta.key 0/' $vpnconf_dir/server.conf
#
#Running server in least privileges mode by modifying user/group to nobody/nogroup.
usr_chk=`cat $vpnconf_dir/server.conf | grep "user * "`
if [[ $usr_chk = ";user openvpn" ]]
then
    sed -i 's/;user openvpn/user nobody/' $vpnconf_dir/server.conf
elif [[ $usr_chk = ";user nobody" ]]
then
    sed -i 's/;user nobody/user nobody/' $vpnconf_dir/server.conf
fi
#
#Fedora distros have group 'nobody' and debian have group 'nogroup'. changing respectively
grp_chk=`cat $vpnconf_dir/server.conf | grep "group * "`
if [[ " ${fedora_dis[*]} " == *" $sys_chk "* ]] || [[ " ${suse_dis[*]} " == *" $sys_chk "* ]] || [[ $sys_chk == $arch ]]
then
    if [[ $grp_chk = ";group openvpn" ]]
    then
        sed -i 's/;group openvpn/group nobody/' $vpnconf_dir/server.conf
    elif [[ $grp_chk = ";group nobody" ]]
    then
        sed -i 's/;group nobody/group nobody/' $vpnconf_dir/server.conf
    fi
elif [[ " ${debian_dis[*]} " == *" $sys_chk "* ]]
then
    if [[ $grp_chk = ";group openvpn" ]]
    then
        sed -i 's/;group openvpn/group nogroup/' $vpnconf_dir/server.conf
    elif [[ $grp_chk = ";group nobody" ]]
    then
        sed -i 's/;group nobody/group nogroup/' $vpnconf_dir/server.conf
    fi
fi
#
#Checking if user/group is mapped correctly tough it's not essential for the configuration.
usr_chk=`cat $vpnconf_dir/server.conf | grep "user * "`
grp_chk=`cat $vpnconf_dir/server.conf | grep "group * "`
if [[ " ${debian_dis[*]} " == *" $sys_chk "* ]]
then
    if [[ $usr_chk != "user nobody" ]] && [[ $grp_chk != "group nogroup" ]]
    then
        echo " "
        echo "User or Group is not mapped properly...SKIPPING ANYWAY..."
    fi
elif [[ " ${fedora_dis[*]} " == *" $sys_chk "* ]] || [[ " ${suse_dis[*]} " == *" $sys_chk "* ]] || [[ $sys_chk == $arch ]]
then
    if [[ $usr_chk != "user nobody" ]] && [[ $grp_chk != "group nobody" ]]
    then
        echo " "
        echo "User or Group is not mapped properly...SKIPPING ANYWAY..."
    fi
fi
#Enabling ip-forward in real-time. 
sysctl -w net.ipv4.ip_forward=1 2>/dev/null >/dev/null
#
#Enabling ip-forward in system control configurations for persistent changes.
if [[ " ${debian_dis[*]} " == *" $sys_chk "* ]]
then
    ip_fwd0=$(cat /etc/sysctl.conf | grep net.ipv4.ip_forward=0)
    ip_fwd1=$(cat /etc/sysctl.conf | grep net.ipv4.ip_forward=1)    
    if [[ $ip_fwd0 == "#net.ipv4.ip_forward=0" ]]
    then
        sed -i 's/#net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    elif [[ $ip_fwd0 = "net.ipv4.ip_forward=0" ]]
    then
        sed -i 's/net.ipv4.ip_forward=0/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    elif [[ $ip_fwd1 = "#net.ipv4.ip_forward=1" ]]
    then    
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
    elif [[ $ip_fwd1 = "net.ipv4.ip_forward=1" ]]
    then
        echo " "
        echo "IP-Forwarding is Enabled"
        sleep 2
    else
        echo " "
        echo -e "Unable to find net.ipv4.ip_forward in /etc/sysctl.conf. Do it manually by going in /etc/sysctl.conf file\nand change the net.ipv4.ip_forward value from 0 to 1. Make sure it's uncommented"
        sleep 2
        exit
    fi
fi
#
#Process of enabling IP-Forwarding in Redhat and CentOS is different that debian destro.
#I had to create a new 90-sysctl.conf file in /etc/sysctl.d to override the default setting. 
if [[ " ${fedora_dis[*]} " == *" $sys_chk "* ]] || [[ " ${suse_dis[*]} " == *" $sys_chk "* ]] || [[ $sys_chk == $arch ]] || [[ $sys_chk == $alpine ]]
then
    echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/90-sysctl.conf
fi
#
echo " "
loading "Managing IP Forwarding Policies" 3
#
#Enabling NAT and IP Masquerade. This rule is required to forward packets from
#private NAT to Interface that have attached public ip.
#Identifying NIC
pbx_nic="$(ls /sys/class/net | head -1)"
echo " "
loading "Identifying NIC" 2
sleep 1
#
#Allowing nat masquerading
if [[ " ${debian_dis[*]} " == *" $sys_chk "* ]] || [[ $sys_chk == $alpine ]]
then
    cat << EOF >> /etc/ufw/before.rules
*nat
:POSTROUTING ACCEPT [0.0]
-A POSTROUTING -s 10.8.0.0/24 -o $pbx_nic -j MASQUERADE
COMMIT
EOF
fi
#
if [[ " ${fedora_dis[*]} " == *" $sys_chk "* ]] || [[ " ${suse_dis[*]} " == *" $sys_chk "* ]] || [[ $sys_chk == $arch ]]
then
    systemctl start firewalld
    firewall-cmd --set-default-zone=external 2>/dev/null >/dev/null
    firewall-cmd --add-port="$pbx_port"/"$pbx_proto" --permanent 2>/dev/null >/dev/null
    firewall-cmd --permanent --change-interface="$pbx_nic" 2>/dev/null >/dev/null
    firewall-cmd --reload 2>/dev/null >/dev/null    
fi
#
#Changing SELinux Policy to allow port usage other than default port
if [[ " ${fedora_dis[*]} " == *" $sys_chk "* ]]
then
    sel_stat=$(getenforce)
    if [[ $sel_stat == "Enforcing" ]]
    then
        semanage port -a -t openvpn_port_t -p $pbx_proto $pbx_port 2>/dev/null >/dev/null
    fi
fi
#loading "Adding NAT Masquerading rule" 2
#
#Enabling packet forwarding policy by firewall which by default is on DROP mode
#changing it to ACCEPT. Only for debian destros. CentOS/Redhat have policy ACCEPT by default.
if [[ " ${debian_dis[*]} " == *" $sys_chk "* ]] || [[ $sys_chk == $alpine ]]
then
    fwd_policy=$(cat /etc/default/ufw | grep -i "default_forward_policy")
    if [[ $fwd_policy = 'DEFAULT_FORWARD_POLICY="DROP"' ]]
    then
        sed -i 's/DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
    elif [[ $fwd_policy = '#DEFAULT_FORWARD_POLICY="DROP"' ]]
    then
        sed -i 's/#DEFAULT_FORWARD_POLICY="DROP"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
    elif [[ $fwd_policy = '#DEFAULT_FORWARD_POLICY="ACCEPT"' ]]
    then
        sed -i 's/#DEFAULT_FORWARD_POLICY="ACCEPT"/DEFAULT_FORWARD_POLICY="ACCEPT"/' /etc/default/ufw
    elif [[ $fwd_policy = 'DEFAULT_FORWARD_POLICY="ACCEPT"' ]]
    then
        echo " "
        echo "Default forward policy is already activated and on ACCEPT mode."
        sleep 1
    else
        echo " "
        echo -e "Unable to detect DEFEAULT_FORWARD_POLICY in /etc/default/ufw.\nGo to this file and change DEFAULT_FORWARD_POLICY from DROP to ACCEPT, then start process again."
        sleep 2
        exit
    fi
fi
#Adding firewall rules for SSH and OpenVPN server port wether it's  TCP or UDP.
if [[ " ${debian_dis[*]} " == *" $sys_chk "* ]] || [[ $sys_chk == $alpine ]]
then
    ufw allow $pbx_port/$pbx_proto 2>/dev/null >/dev/null && ufw allow 22/tcp 2>/dev/null >/dev/null && echo 'y'|ufw enable 2>/dev/null >/dev/null && ufw reload 2>/dev/null >/dev/null &
fi
echo " "
loading "Managing Firewall Rules" 3
sleep 1
#
#Generating CA and RSA certificates-keys for server. Easyrsa dorectory is copied in
#/etc/openvpn/ directory and a new directory named pki will be created which will
#contain all the certificates-keys.
cp -f $rsaconf_dir/vars.example $rsaconf_dir/vars
echo " "
clear
echo "*********************Generating SSL Certtificates and Keys**************************"
sleep 1
vars_cfg=$(cat $rsaconf_dir/vars | grep -i "set_var easyrsa_pki" | awk '{print$2}')
if [[ $vars_cfg = "EASYRSA_PKI" ]]
then
    echo 'set_var EASYRSA_PKI "/etc/openvpn/easy-rsa/pki"' >> $rsaconf_dir/vars
else
    echo
    echo -e 'Easyrsa Global Vars initilization failed. Make sure there is file named vars in easy-rsa directory.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git'
    sleep 2
    exit
fi
#Generating PKI directory
yes yes | $rsaconf_dir/./easyrsa init-pki 2>/dev/null >/dev/null &
ln -s $PWD/pki $rsaconf_dir
echo " "
loading 'Creating PKI Directory for Cert. and Keys' 3
#Verifying wether the directory is created or not
pki_verify=$(ls $rsaconf_dir|grep 'pki')
if [[ $pki_verify != "pki" ]]
then
    echo
    echo -e 'Could not create PKI directory to save cert. and key files.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git'
    sleep 2
    exit
fi
sleep 1
#Generating Diffie-Hellman key of 2048 bit
echo 'yes'|$rsaconf_dir/./easyrsa gen-dh 2>/dev/null >/dev/null &
echo " "
proc_loading 'easyrsa' 'Generating 2048-bit Encryption key'
#Verifying wether the dh.pem key is generated or not
dh_verify=$(ls $rsapki_dir | grep dh.pem)
if [[ $dh_verify != "dh.pem" ]]
then
    echo
    echo -e 'Could not generate Diffie-Hellman 2048 bit encryption key.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git'
    sleep 2
    exit
fi
sleep 1 
#Generating CA
echo 'pbxforceVPN' | $rsaconf_dir/./easyrsa build-ca nopass 2>/dev/null >/dev/null &
echo " "
proc_loading 'easyrsa' 'Setting up Certificate Authority'
#Verifying wether the CA is generated or not
ca_verify=$(ls $rsapki_dir | grep ca.crt)
if [[ $ca_verify != "ca.crt" ]]
then
    echo
    echo -e 'Could not generate CA Utility.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git'
    sleep 2
    exit
fi
sleep 1
#Generating server certificate and key
yes yes|$rsaconf_dir/./easyrsa build-server-full server nopass 2>/dev/null >/dev/null &
echo " "
proc_loading 'easyrsa' 'Generating Certificate and Key for Server'
skc_verify=$(ls $rsapki_dir/private | grep server.key)
#Verifying wether the server cert. and key is generated or not
if [[ $skc_verify != "server.key" ]]
then
    echo
    echo -e 'Could not Generate Server key or Certificate.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git'
    sleep 2
    exit
fi
#Copying CA Cert./Server certs. and key files in respective directories.
f_list=("$rsapki_dir/ca.crt" "$rsapki_dir/dh.pem" "$rsapki_dir/private/server.key" "$rsapki_dir/issued/server.crt")
for i in ${f_list[@]}
do
    cp $i $vpnconf_dir
done
mv $vpnconf_dir/dh.pem $vpnconf_dir/dh2048.pem
echo " "
echo "Initiating Process to Generate Client Key and Certificate....."
sleep 3
clear
#loading "Managing CA/Server Certificates and Keys" 2
#
#************************Generating Client Certificate and Private Key**********************
echo "-------------------------Generating Client Certificate and Private Key------------------------------"
echo
while true
do
    read -p 'Choose your VPN Client name: ' client_name
    if [[ -z $client_name ]]
    then
        echo
        echo 'At-least one input needed'
        sleep 1
        echo
    elif echo $client_name | grep -q "\."
    then
        echo
        echo "Float is not allowd."
        sleep 1
        echo
    else
        break
    fi
done
yes yes|$rsaconf_dir/./easyrsa build-client-full $client_name client nopass 2>/dev/null >/dev/null &
#
#openSUSE openvpn package does not have client and server directories. Manually creating directories for openSUSE.
if [[ -z $(ls $vpnconf_dir|grep 'client') ]]
then
    mkdir -p $vpnconf_dir/client 2>/dev/null >/dev/null
    mkdir -p $vpnconf_dir/server 2>/dev/null >/dev/null
fi
echo " "
loading 'Generating Client Certificate and Private key' 3
#Copying CA Cert./Client certs. and key files in respective directories.
f_list=("$rsapki_dir/ca.crt" "$rsapki_dir/private/$client_name.key" "$rsapki_dir/issued/$client_name.crt" "$sampleconf_dir/client.conf")
for i in ${f_list[@]}
do
    cp $i $dest_client
done
#Managing Protocol for the client
echo " "
#loading 'Generating Master Client file' 2
#cp $dest_client/client.conf $dest_client/$client_name.conf
if [[ $pbx_proto = 'tcp' ]]
then
    sed -i 's/;proto tcp/proto tcp4/' $dest_client/client.conf
    sed -i 's/proto udp/;proto udp/' $dest_client/client.conf
elif [[ $pbx_proto = 'udp' ]]
then
    sed -i 's/proto udp/proto udp4/' $dest_client/client.conf
fi
#Editing Client Configuration file for server ip address
while true
do
    read -p "Enter Your Server's Publis IP-Address: " server_ip
    if [[ $server_ip =~ ^[+-]?[0-9]+\.?[0-9]+.?[0-9]+.?[0-9]*$ ]]
    then
        sed -i "s/remote my-server-1/remote $server_ip/" $dest_client/client.conf
        echo
        loading "Using $server_ip for the Server" 2
        break
    else
        echo
        echo 'Server IP is not of valid format. Try again with x.x.x.x ip format.'
        echo " "
        sleep 2
    fi
done
#Editing client port
sed -i "s/1194/$pbx_port/" $dest_client/client.conf

#Commenting out cert and key attributes
sed -i 's/ca ca.crt/;ca ca.crt/' $dest_client/client.conf
sed -i 's/cert client.crt/;cert client.crt/' $dest_client/client.conf
sed -i 's/key client.key/;key client.key/' $dest_client/client.conf

#Commenting out tls authenticating
sed -i 's/tls-auth ta.key 1/;tls-auth ta.key 1/' $dest_client/client.conf
#
#Merging cert and key in client vpn file
echo " "
loading "Generating $client_name Client VPN file" 2
source $PWD/append.sh "$client_name" 'ca.crt' "$client_name.crt" "$client_name.key"
#Redhat does not create openvpn service file. Creating file manually if not present
if [[ $sys_chk != $alpine ]]
then
    openvpn_service_chk=$(ls /usr/lib/systemd/system | grep 'openvpn@.service')
    if [[ -z $openvpn_service_chk ]]
    then
        touch /usr/lib/systemd/system/openvpn@.service
        cat << EOF >> /usr/lib/systemd/system/openvpn@.service
[Unit]
Description=OpenVPN Robust And Highly Flexible Tunneling Application On %I
After=network.target

[Service]
Type=notify
PrivateTmp=true
ExecStart=/usr/sbin/openvpn --cd /etc/openvpn/ --config %i.conf

[Install]
WantedBy=multi-user.target
EOF
    fi
elif [[ $sys_chk == $alpine ]]
then
    mv $vpnconf_dir/server.conf $vpnconf_dir/openvpn.conf
fi
#
#Activating server
if [[ $sys_chk != $alpine ]]
then
    systemctl daemon-reload
    systemctl enable openvpn@server --now 2>/dev/null >/dev/null
    if [[ $(systemctl is-active openvpn@server) = "active" ]]
    then
        echo " "
        echo '******* OpenVPN Server is ACTIVE and RUNNING ********'
    else    
        echo
        echo -e 'An error occurred in the final step.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git' 
        sleep 2
        exit
    fi
elif [[ $sys_chk == $alpine ]]
then
    rc-service openvpn start 2>/dev/null >/dev/null
    echo " "
    echo '******* OpenVPN Server is ACTIVE and RUNNING ********'
else    
    echo
    echo -e "Could not start $sys_chk\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    sleep 2
    exit

fi
#PROCESS DONE
#
echo " "
echo "************************************************************************************"
echo "****************                                              **********************"
echo "**************** OpenVPN Configuration Successfully Completed **********************" 
echo "****** Unable to connect to server or no internet after connecting to server? ******"
echo "************ You may need to REBOOT the system, REBOOT (NOT RESTART) ***************"
echo "*****                                                                          *****"
echo "************************************************************************************"
echo "************************************************************************************"
echo
echo "Your Client VPN file is generated in /root directory."
echo
echo "************************************************************************************"
echo
echo "Copy this .ovpn file into your local machine and use it to connect to the server."
echo
echo "************************************************************************************"
echo
echo -e "For Linux users: If you are using GUI mode, both GNOME and KDE have built-in VPN\nClient feature that you can use to connect to vpn simply by importing your .ovpn file.\nIf you are using CLI, then you should install 'openvpn' packege and\nthen use command: openvpn <client-file-path>"
echo
echo "************************************************************************************"
echo
echo -e "For Windows users: Download OpenVPN GUI application from OpenVPN website and import\nthe .ovpn file to connect to the server."
echo
echo "************************************************************************************"
echo
echo "OpenVPN files can be located on /etc/openvpn. Feel free to tune & tweak anything."
echo
echo "Any Issues ?? Let me know: https://github.com/pbxforce/openvpn-Install.git"
echo "-------------------------------------------------------------------------------------"