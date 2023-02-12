# openvpn-Install
A fully configuered pbxforce OpenVPN server with SSL Encryption for Ubuntu and other Debian based distros.
This Script is written in BASH and tested on Ubuntu. Other Distros are being tested, script will be available as soon as finished.

*** RUNNING THIS SCRIPT ON CLEAN INSTALL IS ADVISED ***

Use this script to setup your own secure VPN Server where traffic will be encrypted with PKI using bidirectional authentication. From system update to all the required packages, everything will be done automatically. Just make suer you run the script as root.

Simply run the bash script and follow the instructions.

    bash install-vpn.sh

For transparency and better understanding, list of all the required packages and necessary changings will be displayed on screen. Read the instructions carefully.

* Diffie-Hellman 2048-bit key process might take some time. 

After completing the installation process, client VPN file will be saved in the '/root' directory under the extension of '.ovpn'. Use that file to connect to the server.

Additional script file 'append.sh' is used to combine the ecnryption key files and vpn client file together and generate a single file that is used to connect to the VPN Server. Primarily, You don't have to run this file as it's already sourced into 'install-vpn.sh'.

However, if you want to merge your certificate/key files with your client VPN file and generate a single .ovpn client file, use 'append.sh' script under these parameters
    
    bash append.sh <set-file-name> <ca.crt> <YourCertFileName.crt> <YourKeyFileName.key>

Make sure to run the script from the same directory where your key and certificate files are. A new file will be generated in the same folder.

After Installing the VPN Server, by default only one client file is generated. But if require, another client can be added and the client file will be generated using 'client.sh' script. 

Run the command and follow the instructions.

    bash client.sh
    
If there is any issue with the VPN Server, client connection or the script itself, let me know.
