#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[33mPlease run this script as root or use sudo.\e[0m"
    exit 1
fi

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo -e "\e[33mUnable to detect the operating system. Exiting.\e[0m"
        exit 1
    fi
}

install_required_apps() {
    echo -e "\e[33mInstalling required applications...\e[0m"
    case "$OS" in
        ubuntu|debian)
            sudo apt update
            sudo apt install -y snapd wget unzip zip
            ;;
        fedora)
            sudo dnf install -y snapd wget unzip zip
            ;;
        centos|rhel)
            sudo yum install -y snapd wget unzip zip
            ;;
        *)
            echo -e "\e[33mUnsupported distribution: $OS\e[0m"
            exit 1
            ;;
    esac
}

install_snap() {
    echo -e "\e[33mSnap has been successfully installed.\e[0m"
    sudo systemctl enable --now snapd.socket
}

install_multipass() {
    echo -e "\e[33mInstalling Multipass...\e[0m"
    sudo snap install multipass
    if multipass --version &> /dev/null; then
        echo -e "\e[33mMultipass installed successfully.\e[0m"
    else
        echo -e "\e[33mFailed to install Multipass.\e[0m"
        exit 1
    fi
}

install_titan_agent() {
    echo -e "\e[33mDownloading Titan Agent...\e[0m"
    wget https://pcdn.titannet.io/test4/bin/agent-linux.zip -O /tmp/agent-linux.zip

    echo -e "\e[33mCreating installation directory...\e[0m"
    sudo mkdir -p /opt/titanagent

    echo -e "\e[33mExtracting files...\e[0m"
    sudo unzip /tmp/agent-linux.zip -d /opt/titanagent

    sudo cp /opt/titanagent/agent /usr/local/bin/
    rm /tmp/agent-linux.zip

    echo -e "\e[33mPlease visit https://test4.titannet.io/ to obtain your Titan key.\e[0m"
    read -p "$(echo -e '\e[33mEnter your Titan key: \e[0m')" titan_key

    # Ensure the Titan key is set in an environment variable
    echo -e "\e[33mSetting up systemd service for Titan Agent...\e[0m"
    sudo bash -c 'cat > /etc/systemd/system/titan-agent.service <<EOF
[Unit]
Description=Titan Agent Service
After=network.target

[Service]
Environment="TITAN_KEY=$titan_key"
ExecStart=/usr/local/bin/agent --working-dir=/opt/titanagent --server-url=https://test4-api.titannet.io --key=$TITAN_KEY
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF'

    sudo systemctl daemon-reload
    sudo systemctl enable titan-agent.service
    sudo systemctl start titan-agent.service

    echo -e "\e[33mVerifying Titan Agent status...\e[0m"
    sudo systemctl status titan-agent.service

    echo -e "\e[33mInstallation complete. Titan Agent is set to run automatically on reboot.\e[0m"
}

# Execute the functions
detect_os
install_required_apps
install_snap
install_multipass
install_titan_agent
