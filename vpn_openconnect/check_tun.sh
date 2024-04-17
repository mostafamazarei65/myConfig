#!/bin/bash

IP_ADDRESS=152.89.47.95

if [[ $(ip a | grep "tun0:" | wc -l) -eq 0 ]]; then
	curl -X POST --data-urlencode "payload={\"channel\": \"#uptime\", \"username\": \"Monitoring BOT\", \"text\": \"Tunnel is down!\nIP: $IP_ADDRESS\n<@U04942J46NP> <@U0494319FM1>\", \"icon_emoji\": \":warning:\"}" https://hooks.slack.com/services/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
else 
	echo "Everything is OK!"
fi

