# openvpn-Install
A fully configuered pbxforce OpenVPN server with SSL Encryption for almost all major distros. Check the list of supported distributions:

****Ubuntu, CentOS, Alpine, Redhat (RHEL), Linux Mint, PopOS, Rocky, Kali, Arch Linux, OpenSUSE (leap, tumbleweed, sles), Fedora, Amazon Linux.****
            
Almost all Debian and Fedora distros are supported. New distros are being added constantly.

** RUNNING THIS SCRIPT ON CLEAN INSTALL IS ADVISED. ROOT PRIVILEGES ARE NECESSARY TO INSTALL SERVER WITHUOT ERRORS **

Simply run the bash script and follow the instructions: 

            sudo bash install-vpn.sh

* Use this script to setup your own secure VPN Server where traffic will be encrypted with PKI using bidirectional authentication. Everything will be done automatically. Automatic system update is excluded because sometimes it takes too much time and it might not even necessary for the task. But you can update the system manually before running the script. It will reduce the script running time. If you get error in the inital packages installing phase, you should definatly perform system update and run the script again.

****For RHEL users:**** RHEL users needs Redhat subscriptions to install packages from repository. Get the RHEL subscription and register the system before running the script. To register system, use command:

            subscription-manager register

****For Alpine users:**** Alpine comes with 'sh' or 'ash'. There is higher probability of getting error while running this bash script using 'sh' or 'ash'. Users need to instaLl bash before running the script. Use command below to install bash:

            apk add bash
            
Security and Privacy is Crucial nowdays. Keeping that in mind, this script is written in BASH with much more transparency of what is being installed or changed in the system while installing the server.

For transparency and better understanding, list of all the required packages and necessary changings will be displayed on screen. Read the instructions carefully. Diffie-Hellman 2048-bit key process might take some time. 

* After Installing the VPN Server, by default only one client file is generated. But if require, another client can be added and the client file can be generated using 'client.sh' script. 

Run the command and follow the instructions:

           sudo bash client.sh

After completing the installation process, client VPN file will be saved in the current directory under the extension of '.ovpn'. Use that file to connect to the server.

Additional script file 'append.sh' is used to combine the encryption key files and vpn client file together and generate a single file that is used to connect to the VPN Server. Primarily, You don't have to run this file as it's already sourced into 'install-vpn.sh'.

* However, if you have some certificates/keys that you want to merge with your client VPN file and generate a single .ovpn client file, use 'append.sh' script under these parameters:
    
            sudo bash append.sh <set-file-name> <ca.crt> <YourCertFileName.crt> <YourKeyFileName.key>

Make sure to run the script from the same directory where your key and certificate files are. A new file will be generated in the same directory.
    
