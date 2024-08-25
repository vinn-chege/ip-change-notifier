#!/bin/bash

# Prompt for Telegram bot details
read -p "Enter your Telegram bot token: " BOT_TOKEN
read -p "Enter your Telegram chat ID: " CHAT_ID

# Check if BOT_TOKEN or CHAT_ID is empty
if [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]]; then
    echo "Error: Both Telegram bot token and chat ID must be provided."
    exit 1
fi

# Define the IP monitor script content
IP_MONITOR_SCRIPT=$(cat <<EOF
#!/bin/bash

BOT_TOKEN="$BOT_TOKEN"
CHAT_ID="$CHAT_ID"

# Function to send a message via Telegram bot
send_telegram_message() {
    local message=\$1
    curl -s -X POST "https://api.telegram.org/bot\${BOT_TOKEN}/sendMessage" \
         -d "chat_id=\${CHAT_ID}" \
         -d "text=\${message}" > /dev/null
}

# Function to get the IP address of an interface
get_ip_address() {
    local iface=\$1
    ip addr show "\$iface" | grep "inet " | awk '{print \$2}'
}

# Initialize previous IPs array
declare -A previous_ips

# List of interfaces to monitor (myst0 to myst20)
interfaces=\$(seq 0 20)

# Populate initial IPs
for i in \$interfaces; do
    iface="myst\$i"
    previous_ips[\$iface]=\$(get_ip_address "\$iface")
done

# Monitoring loop
while true; do
    for i in \$interfaces; do
        iface="myst\$i"
        current_ip=\$(get_ip_address "\$iface")
        previous_ip=\${previous_ips[\$iface]}

        if [[ "\$current_ip" != "\$previous_ip" ]]; then
            send_telegram_message "\${iface} IP changed from \${previous_ip:-"none"} to \${current_ip:-"none"}"
            previous_ips[\$iface]=\$current_ip
        fi
    done
    sleep 60
done
EOF
)

# Create the IP monitor script
echo "$IP_MONITOR_SCRIPT" > /usr/local/bin/ip_monitor.sh

# Make the script executable
sudo chmod +x /usr/local/bin/ip_monitor.sh

# Define the systemd service content
SERVICE_CONTENT=$(cat <<'EOF'
[Unit]
Description=IP Monitor Service
After=network.target

[Service]
ExecStart=/usr/local/bin/ip_monitor.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
)

# Create the systemd service file
echo "$SERVICE_CONTENT" | sudo tee /etc/systemd/system/ip_monitor.service > /dev/null

# Reload systemd to apply the new service
sudo systemctl daemon-reload

# Enable and start the service
sudo systemctl enable ip_monitor.service
sudo systemctl start ip_monitor.service

echo "IP Monitor service has been set up and started."
