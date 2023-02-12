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
#pbx_port=$(lsof -i -P -n | grep openvpn | awk '{print$9}'| cut -c3-)
#
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
#
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
$rsaconf_dir/./easyrsa build-client-full $client_name client nopass 2>/dev/null >/dev/null &
echo " "
loading 'Generating Client Certificate and Private key' 3
#Copying CA Cert./Client certs. and key files in respective directories.
f_list=("$rsapki_dir/private/$client_name.key" "$rsapki_dir/issued/$client_name.crt")
for i in ${f_list[@]}
do
    cp $i $dest_client
done
#Merging cert and key in client vpn file
echo " "
loading "Generating $client_name Client VPN file" 2
source $PWD/append.sh "$client_name" 'ca.crt' "$client_name.crt" "$client_name.key"
echo
echo "$client_name VPN Client file generated on /root."
sleep 1
#
#PROCESS DONE
#
echo
echo "************************************************************************************"
echo
echo "Any Issues ?? Let me know: https://github.com/pbxforce/openvpn-Install.git"
echo
echo "************************************************************************************"
