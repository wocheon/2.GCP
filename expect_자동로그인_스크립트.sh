#!/bin/bash

IP=$(hostname -i | gawk -F "." '{print $4}')

expect -c " spawn su - root \
-c " expect -re "Password:"" \
-c " sleep 1" \
-c " send test@${IP}" \
-c " interact"
