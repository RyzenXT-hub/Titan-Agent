# Auto Install Titan Agent - Galileo Testnet - Titan Network

## Minimum Hardware Requirements:

| CPU     | Memory | Storage Space | Upstream Bandwidth | NAT          |
|---------|--------|---------------|--------------------|--------------|
| CPU 2v  | RAM 2G | SSD 50G+      | 10Mbps+             | TCP1,2,3 UDP1,2,3 |

**Recommended:**

*   **CPU:** 4 cores or more
*   **Memory:** 6 GB RAM or more

## How to use bash shell

* Install : 
```
curl -O https://raw.githubusercontent.com/RyzenXT-hub/Titan-Agent/main/titan-agent.sh && chmod u+x titan-agent.sh && ./titan-agent.sh
```
* Uninstall : 
```
curl -O https://raw.githubusercontent.com/RyzenXT-hub/Titan-Agent/main/uninstall-agent.sh && chmod u+x uninstall-agent.sh && ./uninstall-agent.sh
```

## One-Time Installation Script for Titan Agent with Multipass on Linux:

This script automates the installation of the Titan Agent and Multipass on Linux. It supports various Linux distributions (Ubuntu/Debian, Fedora, CentOS/RHEL) by detecting the OS and running the necessary commands.

**Features:**
*  OS Detection: Automatically detects the Linux distribution and installs Snap and Multipass.
*  Titan Agent Setup: Downloads, extracts, and sets up the Titan Agent Automatically.
*  User Interaction: Prompts the user to input their Titan key with interactive text.
*  Systemd Service: Automatically creates and enables a systemd service for Titan Agent, ensuring it runs on reboot.
*  Easy to Use: Single script with all-in-one setup.
