#!/bin/bash

cat $dest_client/client.conf > $PWD/$1.ovpn
file="$PWD/$1.ovpn"
echo "<ca>" >> $file
cat $dest_client/$2 >> $file
echo "</ca>" >> $file
echo "<cert>" >> $file
cat $dest_client/$3 >> $file
echo "</cert>" >> $file
echo "<key>" >> $file
cat $dest_client/$4 >> $file
echo "</key>" >> $file