#!/bin/bash

OCPASSWD_PATH=/etc/ocserv/ocpasswd
USER_PATH=/etc/ocserv/users

while IFS= read -r line; do
	USERNAME=$(echo $line | cut -d ':' -f 1)
	EXPIRATION_IN_EPOCH=$(echo $line | cut -d ':' -f 2)
	NOW_IN_EPOCH=$(date +%s)
	EXPIRED=$(( $EXPIRATION_IN_EPOCH - $NOW_IN_EPOCH ))
	if [[ $EXPIRED -le 0 ]]; then
		ocpasswd -c $OCPASSWD_PATH -l $USERNAME
		chmod 644 $OCPASSWD_PATH
	elif [[ $EXPIRED -ge 1 ]]; then
		echo "not expired"
	fi
done < $USER_PATH
