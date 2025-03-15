#!/bin/bash

COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_RESET='\033[0m'

# -------------------------------------------------------------------
# Function to display header
# -------------------------------------------------------------------
header_info() {
    clear
    printf "${COLOR_RED}"
    cat <<"EOF"
███████╗███╗   ██╗ █████╗ ██████╗ ██╗     ███████╗    ██████╗ ███████╗██████╗     ███████╗███████╗██╗  ██╗
██╔════╝████╗  ██║██╔══██╗██╔══██╗██║     ██╔════╝    ██╔══██╗██╔════╝██╔══██╗    ██╔════╝██╔════╝██║  ██║
█████╗  ██╔██╗ ██║███████║██████╔╝██║     █████╗      ██████╔╝█████╗  ██║  ██║    ███████╗███████╗███████║
██╔══╝  ██║╚██╗██║██╔══██║██╔══██╗██║     ██╔══╝      ██╔══██╗██╔══╝  ██║  ██║    ╚════██║╚════██║██╔══██║
███████╗██║ ╚████║██║  ██║██████╔╝███████╗███████╗    ██║  ██║███████╗██████╔╝    ███████║███████║██║  ██║
╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝    ╚═╝  ╚═╝╚══════╝╚═════╝     ╚══════╝╚══════╝╚═╝  ╚═╝               
EOF
    printf "${COLOR_RESET}\n"
}

# -------------------------------------------------------------------
# Function to handle command results
# -------------------------------------------------------------------
handle_result() {
    if [ "$1" -ne 0 ]; then
        printf "${COLOR_RED}[!] Error during step: %s${COLOR_RESET}\n" "$2" >&2
        exit 1
    else
        printf "${COLOR_GREEN}[+] %s: Success${COLOR_RESET}\n" "$2"
    fi
}

# Display header
header_info

# Check if the script is run as root
if [ "$(id -u)" != "0" ]; then
    printf "${COLOR_RED}[!] This script must be run as root.${COLOR_RESET}\n" >&2
    exit 1
fi

SSH_CONFIG_FILE='/etc/ssh/sshd_config'

# Disable password authentication
sed -i 's/#\?PasswordAuthentication yes/PasswordAuthentication no/g' $SSH_CONFIG_FILE
handle_result $? "Disable PasswordAuthentication"

sed -i 's/#\?PermitRootLogin yes/PermitRootLogin prohibit-password/g' $SSH_CONFIG_FILE
handle_result $? "Set PermitRootLogin to prohibit-password"

# Restart SSH service
systemctl restart sshd
handle_result $? "Restart SSH service"

echo -e "${COLOR_GREEN}Password authentication has been disabled for SSH.${COLOR_RESET}"

# Change PS1 shell prompt
echo "PS1='\[\e[1;31m\]\u@\h\[\e[0m\]:\[\e[1;34m\]\w\[\e[0m\]\$ '" >> ~/.bashrc
handle_result $? "Update shell prompt"

# Prompt user to add public key
echo -e "${COLOR_GREEN}Please ensure to add the public key to the following locations:${COLOR_RESET}"
echo "  1. /root/.ssh/authorized_keys - for the root user"
echo "  2. ~/.ssh/authorized_keys - for the user: $LOGNAME"
echo -e "${COLOR_GREEN}This ensures key-based authentication works properly.${COLOR_RESET}"