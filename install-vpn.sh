#!/bin/bash

#Defining variables and functions.
#
openvpn_dir='/usr/share/doc/openvpn'
rsa_default_dir='/usr/share/easy-rsa'
vpnconf_dir='/etc/openvpn'
sampleconf_dir='/etc/openvpn/openvpn-github-package/sample/sample-config-files'
rsaconf_dir='/etc/openvpn/easy-rsa'
rsapki_dir='/etc/openvpn/easy-rsa/pki'
pvtkey_dir='/etc/openvpn/easy-rsa/pki/private'
crt_dir='/etc/openvpn/easy-rsa/pki/issued'
dest_client='/etc/openvpn/client'
PWD=$(pwd)
#
#Function that creates loading using some operators in loop. Function takes two arguments,
#first argument is message displaying before and after the process and second argument is
#time that it will hold before ending loop. Except system update and package installation,
#which is another loop, this function doesn't run on actual running process based, it just
#sleeps for time that we specify in second argument.
loading() {
    echo "$1"
    t_start=$(date +%s)
    while true
    do
        t_current=$(date +%s)
        t_running=$((t_current - t_start))
        if [ $t_running -gt $2 ]
        then
            printf "\033[1A"
            echo "$1.....DONE"
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
#Unless function 'loading', This function produce realtime loading loop that actually
#based on the time of running process. As soon as the process finish, loop with break.
#this function takes two argument, first argument is process name and second argument
#is message showed before and after the process is done.
proc_loading () {
    echo $2
    while true
    do
        job=$(ps -ef | grep $1 | grep -v grep)
        if [ -z "$job" ]
        then
            printf "\033[1A"
            echo "$2......DONE"
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
#---------------------Server Configuration----------------------------
#
#
#Updating system along with installing required packages silently.
apt -y update 2>/dev/null >/dev/null && apt install -y openvpn easy-rsa git nano net-tools ufw 2>/dev/null >/dev/null &
echo "Updating System and Installing required packages"
while true
do
    job=$(ps -ef | grep apt | grep -v grep)
    if [ -z "$job" ]
    then
        printf "\033[1A"
        echo "Updating System and Installing required packages......DONE"
        echo " "
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
#OpenVPN verification process is mapped with string "OpenVPN" in 'openvpn --version' command
sleep 1
if [[ `openvpn --version | head -1 | awk '{print$1}'` = "OpenVPN" ]]
then
    echo "OpenVPN Version: $(openvpn --version | head -1 | awk '{print$1,$2}') ....VERIFIED"
else
    echo -e "OpenVPN is not installed correctly. It could be a missing file or something.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    exit
fi
#
#Git verification process is mapped with checking /bin OR /sbin directory for 'git' command file.
sleep 1
if [[ -n $(ls /bin|grep git) ]] || [[ -n $(ls /sbin|grep git) ]]
then
    echo
    echo "$(git --version) ....VERFIED"
else
    echo
    echo -e "Git is not installed correctly. It could be a missing file or something.\naise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
fi
#
#Easy-rsa verification process is mapped with checking 'easy-rsa' directory in /usr/share path.
sleep 1
if [[ -z `ls /usr/share|grep easy-rs` ]]
then
    echo
    echo -e "Easy-rsa is not installed correctly. It could be a missing file or something.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    exit
else
    rsa_version="$(/usr/share/easy-rsa/./easyrsa | sed -n 2p | awk '{print$1,$2}')"
    echo
    echo "$rsa_version ....VERIFIED"
fi
#
echo " "
loading 'Checking Required Files and Directories' 5
#Copying both openvpn and easy-rsa package files in the most conveinent
#directory for ease of use.
cp -r $rsa_default_dir $vpnconf_dir
#
#Default/Sample configuration files are missing sometimes while install openvpn package.
#It would be better if we update and get latest configuration files from OpenVPN GitHub repository.
#
#Cloing requierd files OpenVPN GitHub Repository.
git clone https://github.com/OpenVPN/openvpn.git $vpnconf_dir/openvpn-github-package 2>/dev/null >/dev/null&
echo " "
proc_loading 'git' 'Cloning Files From OpenVPN GitHub Repository'
#OpenVPN GitHub package verfication method is mapped with checking 'openvpn-gurhub-package' directory
#in vpn configuration directory.
sleep 1
if [[ -z `ls /etc/openvpn|grep openvpn-github-package` ]]
then
    echo -e "OpenVPN GitHub Package directory not found in the system. It could be Git Cloning failed or something.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git"
    sleep 2
    exit
else
    echo " "
    echo "OpenVPN GitHub Package is Present. ....VERIFIED"
fi
#
#Copying server configuration file in main configuration directory.
echo " "
loading "Generating Server Configuration file" 3
cp -r $sampleconf_dir/server.conf $vpnconf_dir
#
#Editing the conf file and doing required changes
echo " "
#
echo "Starting Server Configuration..."
sleep 2
clear
#
echo "**********************Configuring OpenVPN Server and Client****************************"
echo "******************************Enter Details Carefully**********************************"
#
echo
echo "OpenVPN recommends UDP protocol but you can use TCP if require"
while true
do
    echo
    read -p "Select Protocol (TCP/UDP): " pbx_proto
    if [[ $pbx_proto == "tcp" ]] || [[ $pbx_proto == "TCP" ]]
    then
        sed -i 's/;proto tcp/proto tcp/' $vpnconf_dir/server.conf
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
        pbx_proto='UDP'
        echo "Protocol is set to: $pbx_proto "
        pbx_proto='udp'
        break
    elif [[ $pbx_proto == "" ]]
    then
        echo
        echo "Protocol is set to: UDP"
        pbx_proto='udp'
        break
    else
        echo
        echo "Unable to use $pbx_proto as Protocol. Try again with TCP/UDP only."
    fi
done
#
sleep 1
#
echo
echo -e "OpenVPN uses PORT 1194 but you can use any available port. Make sure it's not already In-use"
while true
do
    echo
    read -p "Specify Port (Press ENTER to use OpenVPN default port): " pbx_port
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
sleep 1
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
grp_chk=`cat $vpnconf_dir/server.conf | grep "group * "`
if [[ $grp_chk = ";group openvpn" ]]
then
    sed -i 's/;group openvpn/group nogroup/' $vpnconf_dir/server.conf
elif [[ $grp_chk = ";group nobody" ]]
then
    sed -i 's/;group nobody/group nogroup/' $vpnconf_dir/server.conf
fi
#
#loading "Configuring user & group to run server in least privilege mode" 3
usr_chk=`cat $vpnconf_dir/server.conf | grep "user * "`
grp_chk=`cat $vpnconf_dir/server.conf | grep "group * "`
if [[ $usr_chk != "user nobody" ]] && [[ $grp_chk != "group nogroup" ]]
then
    echo " "
    echo "User or Group is not mapped properly...SKIPPING ANYWAY..."
fi
#Allowing ip-forward. It will enable ip-forward in real-time. But sometimes reboot is needed.
#
sysctl -w net.ipv4.ip_forward=0 2>/dev/null >/dev/null
#
#Enabling ip-forward in system control configurations for persistent change
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
    echo "IP-Forwarding is Enabled"
    sleep 2
else
    echo " "
    echo -e "Unable to find net.ipv4.ip_forward in /etc/sysctl.conf. Do it manually by going in /etc/sysctl.conf file\nand change the net.ipv4.ip_forward value from 0 to 1. Make sure it's uncommented"
    sleep 2
    exit
fi
#
echo " "
loading "Managing IP/Port Forwarding Policies" 5
#
#Enabling NAT and IP Masquerade. This rule is required to forward packets from
#private NAT to Interface that have attached public ip.
#Identifying NIC
pbx_nic=$(ls /sys/class/net | head -1)
echo " "
loading "Identifying NIC" 2
echo " "
echo "Using $pbx_nic"
sleep 1
#
#Adding nat masquerading rule
cat << EOF >> /etc/ufw/before.rules
*nat
:POSTROUTING ACCEPT [0.0]
-A POSTROUTING -s 10.8.0.0/24 -o $pbx_nic -j MASQUERADE
COMMIT
EOF
#loading "Adding NAT Masquerading rule" 2
#
#Enabling packet forwarding policy by firewall which by default is on DROP mode
#changing it to ACCEPT.
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
    echo "DEFAULT_FORWARD_POLICY is already activated and on ACCEPT mode."
    sleep 1
else
    echo " "
    echo -e "Unable to detect DEFEAULT_FORWARD_POLICY in /etc/default/ufw.\nGo to this file and change DEFAULT_FORWARD_POLICY from DROP to ACCEPT, then start process again."
    sleep 2
    exit
fi
#Adding firewall rules for SSH and OpenVPN server port wether it's  TCP or UDP.
ufw allow $pbx_port/$pbx_proto 2>/dev/null >/dev/null && ufw allow 22/tcp 2>/dev/null >/dev/null && echo 'y'|ufw enable 2>/dev/null >/dev/null && ufw reload 2>/dev/null >/dev/null &
echo " "
loading "Managing Firewall Rules" 3
#
#Generating CA and RSA certificates-keys for server. Easyrsa dorectory is copied in
#/etc/openvpn/ directory and a new directory named pki will be created which will
#contain all the certificates-keys.
cp $rsaconf_dir/vars.example $rsaconf_dir/vars
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
echo 'yes' | $rsaconf_dir/./easyrsa init-pki 2>/dev/null >/dev/null &
echo " "
loading 'Creating PKI Directory for Cert. and Keys' 2
#Verifying wether the directory is created or not
pki_verify=$(echo 'yes'|$rsaconf_dir/./easyrsa init-pki | tail -3|awk '{print$7}'|head -1)
if [[ $pki_verify != "$rsapki_dir" ]]
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
proc_loading 'easyrsa' 'Generating Diffie-Hellman 2048 bit Encryption key'
#Verifying wether the dh.pem key is generated or not
dh_verify=$(ls $rsapki_dir | grep dh.pem)
if [[ $dh_verify != "dh.pem" ]]
then
    echo
    echo -e 'Could not generate Diffie-Hellman 2048 bit SSL key.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git'
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
$rsaconf_dir/./easyrsa build-server-full server nopass 2>/dev/null >/dev/null &
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
$rsaconf_dir/./easyrsa build-client-full client nopass 2>/dev/null >/dev/null &
echo " "
loading 'Generating Client Certificate and Private key' 3
#Copying CA Cert./Client certs. and key files in respective directories.
f_list=("$rsapki_dir/ca.crt" "$rsapki_dir/private/client.key" "$rsapki_dir/issued/client.crt" "$sampleconf_dir/client.conf")
for i in ${f_list[@]}
do
    cp $i $dest_client
done
#Managing Protocol for the client
echo " "
#loading 'Generating Master Client file' 2
cp $dest_client/client.conf $dest_client/$client_name.conf
if [[ $pbx_proto = 'tcp' ]]
then
    sed -i 's/;proto tcp/proto tcp/' $dest_client/$client_name.conf
    sed -i 's/proto udp/;proto udp/' $dest_client/$client_name.conf
fi
#Editing Client Configuration file for server ip address
while true
do
    read -p "Enter Your Server's Publis IP-Address: " server_ip
    if [[ $server_ip =~ ^[+-]?[0-9]+\.?[0-9]+.?[0-9]+.?[0-9]*$ ]]
    then
        sed -i "s/remote my-server-1/remote $server_ip/" $dest_client/$client_name.conf
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
sed -i "s/1194/$pbx_port/" $dest_client/$client_name.conf

#Commenting out cert and key attributes
sed -i 's/ca ca.crt/;ca ca.crt/' $dest_client/$client_name.conf
sed -i 's/cert client.crt/;cert client.crt/' $dest_client/$client_name.conf
sed -i 's/key client.key/;key client.key/' $dest_client/$client_name.conf

#Commenting out tls authenticating
sed -i 's/tls-auth ta.key 1/;tls-auth ta.key 1/' $dest_client/$client_name.conf

#Merging cert and key in client vpn file
echo " "
loading "Generating $client_name Client VPN file" 2
source $PWD/append.sh "$client_name" 'ca.crt' 'client.crt' 'client.key'
#Activating server
systemctl start openvpn@server
if [[ $(systemctl is-active openvpn@server) = "active" ]]
then
    echo " "
    loading 'Activating OpenVPN Server' 3
else    
    echo
    echo -e 'An error occuered in the final step.\nRaise this issue to me on GitHub: https://github.com/pbxforce/openvpn-Install.git' 
    sleep 2
    exit
fi
#
#PROCESS DONE
#
echo " "
echo "************************************************************************************"
echo "****************                                              **********************"
echo "**************** OpenVPN Configuration Successfully Completed **********************" 
echo "****** Unable to connect to server or no internet after connecting to server? ******"
echo "****** You need to REBOOT the system, REBOOT (NOT RESTART for the sake of IP) ******"
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