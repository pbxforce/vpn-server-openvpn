# openvpn-Install
A fully configuered pbxforce OpenVPN server with SSL Encryption for almost all major distros. Check the list of supported distributions:

****Ubuntu, CentOS, Alpine, Redhat (RHEL), Linux Mint, PopOS, Rocky, Kali, Arch Linux, OpenSUSE (leap, tumbleweed, sles), Fedora, Amazon Linux.****
            
Almost all Debian and fedora distros are supported. New distros are being added constantly.

*** RUNNING THIS SCRIPT ON CLEAN INSTALL IS ADVISED. ROOT PRIVILEGES ARE NECESSARY FOR SUCCESSFULLY RUNNING THE SCRIPT ***

Security and Privacy is Crucial nowdays. Keeping that in mind, this script is written in BASH with much more transparency of what is being installed or changed in the system while installing the server.

Use this script to setup your own secure VPN Server where traffic will be encrypted with PKI using bidirectional authentication. From system update to all the required packages, everything will be done automatically.

Simply run the bash script and follow the instructions:

    bash install-vpn.sh

For transparency and better understanding, list of all the required packages and necessary changings will be displayed on screen. Read the instructions carefully. Diffie-Hellman 2048-bit key process might take some time. 

* After Installing the VPN Server, by default only one client file is generated. But if require, another client can be added and the client file can be generated using 'client.sh' script. 

Run the command and follow the instructions:

    bash client.sh

After completing the installation process, client VPN file will be saved in the current directory under the extension of '.ovpn'. Use that file to connect to the server.

Additional script file 'append.sh' is used to combine the ecnryption key files and vpn client file together and generate a single file that is used to connect to the VPN Server. Primarily, You don't have to run this file as it's already sourced into 'install-vpn.sh'.

* However, if you want to merge your certificate/key files with your client VPN file and generate a single .ovpn client file, use 'append.sh' script under these parameters:
    
        bash append.sh <set-file-name> <ca.crt> <YourCertFileName.crt> <YourKeyFileName.key>

Make sure to run the script from the same directory where your key and certificate files are. A new file will be generated in the same directory.
    
