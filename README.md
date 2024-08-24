# telegram_nofit-ipchange-myst

# Telegram IP Change Monitor Script

This script monitors IP address changes on a list of network interfaces and sends a notification via Telegram whenever an IP change is detected.

## Script Overview

The script performs the following tasks:
1. **Initialize**: Stores the current IP addresses of the specified interfaces.
2. **Monitoring Loop**: Continuously checks for IP address changes on the specified interfaces.
3. **Notification**: Sends a Telegram message if an IP change is detected.

## Prerequisites

Before running the script, make sure you have the following:
- A Telegram bot token.
- A chat ID where the bot will send messages.

## Script

```bash
#!/bin/bash

# Telegram bot details
BOT_TOKEN="your_bot_token_here"
CHAT_ID="your_chat_id_here"

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
```

# IP Monitor Service Setup using systemd

This guide walks you through setting up the bash script as a service using `systemd`.

## Step 1: Create the Python Script

```bash
sudo nano /usr/local/bin/ip_monitor.sh
```

## Step 2: Paste in the script

## Step 3: Change script permissions

```bash
sudo chmod +x /usr/local/bin/ip_monitor.sh
```

## Step 4: 




