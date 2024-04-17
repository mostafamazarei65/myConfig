#!/bin/bash

OCPASSWD_PATH=/etc/ocserv/ocpasswd
USER_PATH=/etc/ocserv/users
ACCOUNTING_PATH=/etc/ocserv/accounting
BASE_URL=srv01.pardiscloud.net

touch $USER_PATH
touch $ACCOUNTING_PATH

GENERATE_USERNAME () {
	USERNAME_CHARS=1234567890
	for i in {1..6} ; do
		USERNAME_RANDOM_POSTFIX+="${USERNAME_CHARS:RANDOM%${#USERNAME_CHARS}:1}"
	done
}

GENERATE_PASSWORD () {
	PASSWORD_CHARS=1234567890
	for i in {1..8} ; do
		PASSWORD_RANDOM+="${PASSWORD_CHARS:RANDOM%${#PASSWORD_CHARS}:1}"
	done
}

while true;
do
	echo "Welcome to ocserv user management"
	echo ""
	echo "1) Add User"
	echo "2) Change Password"
	echo "3) Delete User"
	echo "4) Lock User"
	echo "5) Unlock User"
	echo "6) User Information"
	echo "0) Exit"
	echo ""
	echo "Enter a number:"
	read choice 
	if [[ $choice -eq 1 ]]; then
	        echo "Expiration Plan?"
		echo "1) 1 Month"
		echo "2) 3 Months"
		echo "3) 6 Months"
		echo "4) 12 Months"
	        read EXPIRATION_PLAN
		EXPIRATION_DAYS=""
		BUDGET=""
		if [[ $EXPIRATION_PLAN -eq 1 ]]; then
			EXPIRATION_DAYS+=30
			BUDGET+=59000
		elif [[ $EXPIRATION_PLAN -eq 2 ]]; then
                        EXPIRATION_DAYS+=90
			BUDGET+=159000
		elif [[ $EXPIRATION_PLAN -eq 3 ]]; then
                        EXPIRATION_DAYS+=180
			BUDGET+=299000
		elif [[ $EXPIRATION_PLAN -eq 4 ]]; then
                        EXPIRATION_DAYS+=365
			BUDGET+=569000
		fi
	        EXPIRATION_DURATION=$(( 86400 * $EXPIRATION_DAYS ))
	        EXPIRATION_DATE=$(( $EXPIRATION_DURATION + $(date +%s) ))

		echo "How do you want to set password?"
		echo ""
		echo "1) Automatically"
		echo "2) Manual"
		read PASSWORD_TYPE
		PASSWORD_RANDOM=""
		PASSWORD_STRING=""
		if [[ $PASSWORD_TYPE -eq 1 ]]; then
			GENERATE_PASSWORD
			PASSWORD_STRING+=$PASSWORD_RANDOM
		elif [[ $PASSWORD_TYPE -eq 2 ]]; then
			echo ""
			echo "Enter Password:"
			read PASSWORD_INPUT
			PASSWORD_STRING+=$PASSWORD_INPUT
		fi

		echo ""
		echo "Select edition:"
		echo ""
		echo "1) Enterprise"
		echo "2) Free"
		read EDITION

		USERNAME_RANDOM_POSTFIX=""
		GENERATE_USERNAME
		EU_PREFIX="pardisvpn"
		FU_PREFIX="pardisvpnfree"
		USERNAME=""
		if [[ $EDITION -eq 1 ]]; then
			USERNAME+="$EU_PREFIX$USERNAME_RANDOM_POSTFIX"
		elif [[ $EDITION -eq 2 ]]; then
			USERNAME+="$FU_PREFIX$USERNAME_RANDOM_POSTFIX"
		fi

	        EXIST_USER=$(cat $OCPASSWD_PATH | grep $USERNAME: | wc -l)
	        if [[ $EXIST_USER -eq 1 ]]; then
	        	echo "User exist!"
	        	exit 1
	        elif [[ $EXIST_USER -eq 0 ]]; then
	        	echo -e "$PASSWORD_STRING\n$PASSWORD_STRING" | ocpasswd -c $OCPASSWD_PATH $USERNAME
	        	chmod 644 $OCPASSWD_PATH
	        	echo "$USERNAME:$EXPIRATION_DATE" >> $USER_PATH
			echo "$USERNAME:$(date +%s):$BUDGET" >> $ACCOUNTING_PATH
			echo "User information:"
			echo ""
			echo "username: $USERNAME"
			echo "password: $PASSWORD_STRING"
			curl -X POST --data-urlencode "payload={\"channel\": \"#vpn-users\", \"username\": \"USERS BOT\", \"text\": \"address: $BASE_URL\nusername: $USERNAME\npassword: $PASSWORD_STRING\", \"icon_emoji\": \":money_mouth_face:\"}" https://hooks.slack.com/services/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
			exit 1
	        fi
	elif [[ $choice -eq 2 ]]; then
		echo ""
		echo "Enter username:"
		read USERNAME
		EXIST_USER=$(cat $OCPASSWD_PATH | grep $USERNAME: | wc -l)
		if [[ $EXIST_USER -eq 1 ]]; then
			ocpasswd -c $OCPASSWD_PATH $USERNAME
			chmod 644 $OCPASSWD_PATH
		elif [[ $EXIST_USER -eq 0 ]]; then
			echo "User does not exist!"
			exit 1
		fi
	elif [[ $choice -eq 3 ]]; then
		echo ""
		echo "Enter username:"
		read USERNAME
		EXIST_USER=$(cat $OCPASSWD_PATH | grep $USERNAME: | wc -l)
		if [[ $EXIST_USER -eq 1 ]]; then
			ocpasswd -c $OCPASSWD_PATH -d $USERNAME
			chmod 644 $OCPASSWD_PATH
			sed -i "/$USERNAME:/d" $USER_PATH
			sed -i '/^$/d' $USER_PATH
		elif [[ $EXIST_USER -eq 0 ]]; then
			echo "User does not exist!"
			exit 1
		fi
	elif [[ $choice -eq 4 ]]; then
		echo ""
		echo "Enter username:"
		read USERNAME
		EXIST_USER=$(cat $OCPASSWD_PATH | grep $USERNAME: | wc -l)
		if [[ $EXIST_USER -eq 1 ]]; then
			ocpasswd -c $OCPASSWD_PATH -l $USERNAME
			chmod 644 $OCPASSWD_PATH
		elif [[ $EXIST_USER -eq 0 ]]; then
			echo "User does not exist!"
			exit 1
		fi
	elif [[ $choice -eq 5 ]]; then
		echo ""
		echo "Enter username:"
		read USERNAME
		EXIST_USER=$(cat $OCPASSWD_PATH | grep $USERNAME: | wc -l)
		if [[ $EXIST_USER -eq 1 ]]; then
			ocpasswd -c $OCPASSWD_PATH -u $USERNAME
			chmod 644 $OCPASSWD_PATH
		elif [[ $EXIST_USER -eq 0 ]]; then
			echo "User does not exist!"
			exit 1
		fi
	elif [[ $choice -eq 6 ]]; then
		echo ""
		echo "Enter username:"
		read USERNAME
		EXIST_USER=$(cat $OCPASSWD_PATH | grep $USERNAME: | wc -l)
		if [[ $EXIST_USER -eq 1 ]]; then
			EXPIRATION_IN_EPOCH=$(cat $USER_PATH | grep $USERNAME: | cut -d ':' -f 2 )
			EXPIRATION_TILL=$(( $(( $EXPIRATION_IN_EPOCH - $(date +%s) )) / 86400 ))
			if [[ $EXPIRATION_TILL -ge 1 ]]; then
				echo "Expired       : false"
				echo "Expiration day: $EXPIRATION_TILL"
			elif [[ $EXPIRATION_TILL -eq 0 ]]; then
                                echo "Expired       : true"
                                echo "Expiration day: $EXPIRATION_TILL"
			fi
			echo "Do you want to extend expiration?"
			echo "(Y)es/(N)o :"
			read EXTEND
			if [[ $EXTEND == "Y" ]]; then
				echo "Expiration date (in day):"
				read EXPIRATION_DAYS
				if [[ $EXPIRATION_TILL -ge 1 ]]; then
					EXPIRATION_DURATION=$(( 86400 * $(( $EXPIRATION_DAYS + $EXPIRATION_TILL )) ))
					EXPIRATION_DATE=$(( $EXPIRATION_DURATION + $(date +%s) ))
					sed -i "s/$EXPIRATION_IN_EPOCH/$EXPIRATION_DATE/g" $USER_PATH
				elif [[ $EXPIRATION_TILL -eq 0 ]]; then
					EXPIRATION_DURATION=$(( 86400 * $EXPIRATION_DAYS ))
					EXPIRATION_DATE=$(( $EXPIRATION_DURATION + $(date +%s) ))
					sed -i "s/$EXPIRATION_IN_EPOCH/$EXPIRATION_DATE/g" $USER_PATH
				fi
		        elif [[ $EXTEND == "N" ]]; then
				exit 1
			fi
		elif [[ $EXIST_USER -eq 0 ]]; then
			echo "User does not exist!"
			exit 1
		fi
	elif [[ $choice -eq 0 ]]; then
		echo "Bye"
		exit 1
	fi
done
