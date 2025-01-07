#!/bin/bash

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

install_snap() {
    echo -e "\e[33mDetecting Linux distribution...\e[0m"
    case "$OS" in
        ubuntu|debian)
            echo -e "\e[33mUsing Ubuntu/Debian...\e[0m"
            sudo apt update && sudo apt install -y snapd
            ;;
        fedora)
            echo -e "\e[33mUsing Fedora...\e[0m"
            sudo dnf install -y snapd
            ;;
        centos|rhel)
            echo -e "\e[33mUsing CentOS/RHEL...\e[0m"
            sudo yum install -y snapd
            ;;
        *)
            echo -e "\e[33mUnsupported distribution: $OS\e[0m"
            exit 1
            ;;
    esac
    sudo systemctl enable --now snapd.socket
    echo -e "\e[33mSnap has been successfully installed.\e[0m"
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

    read -p "$(echo -e '\e[33mEnter your Titan key: \e[0m')" titan_key

    echo -e "\e[33mSetting up systemd service for Titan Agent...\e[0m"
    sudo bash -c 'cat > /etc/systemd/system/titan-agent.service <<EOF
[Unit]
Description=Titan Agent Service
After=network.target

[Service]
ExecStart=/usr/local/bin/agent --working-dir=/opt/titanagent --server-url=https://test4-api.titannet.io --key='$titan_key'
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

detect_os
install_snap
install_multipass
install_titan_agent
