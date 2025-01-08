#!/bin/bash

# Check if the script is being run as root
if [ "$EUID" -ne 0 ]; then
    echo -e "\e[33mPlease run this script as root or use sudo.\e[0m"
    exit 1
fi

remove_titan_agent() {
    echo -e "\e[33mStopping Titan Agent service...\e[0m"
    sudo systemctl stop titan-agent.service

    echo -e "\e[33mDisabling Titan Agent service...\e[0m"
    sudo systemctl disable titan-agent.service

    echo -e "\e[33mRemoving Titan Agent service file...\e[0m"
    sudo rm /etc/systemd/system/titan-agent.service

    echo -e "\e[33mReloading systemd daemon...\e[0m"
    sudo systemctl daemon-reload

    echo -e "\e[33mRemoving Titan Agent files...\e[0m"
    sudo rm -rf /root/opt/
    sudo rm /usr/local/bin/agent

    echo -e "\e[33mTitan Agent has been successfully removed.\e[0m"
}

remove_multipass() {
    echo -e "\e[33mRemoving Multipass...\e[0m"
    sudo snap remove multipass
    echo -e "\e[33mMultipass has been successfully removed.\e[0m"
}

remove_snapd() {
    echo -e "\e[33mRemoving Snapd...\e[0m"
    case "$OS" in
        ubuntu|debian)
            sudo apt purge -y snapd
            ;;
        fedora)
            sudo dnf remove -y snapd
            ;;
        centos|rhel)
            sudo yum remove -y snapd
            ;;
        *)
            echo -e "\e[33mUnsupported distribution: $OS\e[0m"
            exit 1
            ;;
    esac
    echo -e "\e[33mSnapd has been successfully removed.\e[0m"
}

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

echo -e "\e[33mStarting removal process...\e[0m"
detect_os
remove_titan_agent
remove_multipass
remove_snapd
echo -e "\e[33mAll related components have been successfully removed.\e[0m"
