# IP Monitor Script

This script monitors IP address changes on a list of network interfaces (myst0 to myst20) and sends a notification via Telegram whenever an IP change is detected. The script is designed to run as a systemd service, ensuring continuous monitoring.

## Features

- **IP Monitoring**: Tracks IP changes on specified network interfaces.
- **Telegram Notifications**: Sends a notification to a specified Telegram chat when an IP change is detected.
- **Easy Setup**: The script can be easily installed and set up using a single command.

## Prerequisites

Before running the script, ensure you have:
- A Telegram bot token.
- A chat ID where the bot will send messages.

## Installation

You can install and set up the IP Monitor script using either `curl` or `wget`.

### Using `curl`

```bash
curl -s https://github.com/vinn-chege/telegram_nofit-ipchange-myst/blob/main/script.sh | bash
```

### Using `bash`

```bash
wget -qO- https://github.com/vinn-chege/telegram_nofit-ipchange-myst/blob/main/script.sh | bash
```
