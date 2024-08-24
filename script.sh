#!/bin/bash

# Telegram bot details
BOT_TOKEN="your_bot_token"
CHAT_ID="your_chat_id"

# Function to send a message via Telegram bot
send_telegram_message() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
         -d "chat_id=${CHAT_ID}" \
         -d "text=${message}" > /dev/null
}

# Function to get the IP address of an interface
get_ip_address() {
    local iface=$1
    ip addr show "$iface" | grep "inet " | awk '{print $2}'
}

# Initialize previous IPs array
declare -A previous_ips

# List of interfaces to monitor (myst0 to myst20)
interfaces=$(seq 0 20)

# Populate initial IPs
for i in $interfaces; do
    iface="myst$i"
    previous_ips[$iface]=$(get_ip_address "$iface")
done

# Monitoring loop
while true; do
    for i in $interfaces; do
        iface="myst$i"
        current_ip=$(get_ip_address "$iface")
        previous_ip=${previous_ips[$iface]}

        if [[ "$current_ip" != "$previous_ip" ]]; then
            send_telegram_message "${iface} IP changed from ${previous_ip:-"none"} to ${current_ip:-"none"}"
            previous_ips[$iface]=$current_ip
        fi
    done
    sleep 60
done
