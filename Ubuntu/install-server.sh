#!/usr/bin/env bash
export NEEDRESTART_MODE=a

# Text Color Variables
GREEN='\033[32m'  # Green
YELLOW='\033[33m' # YELLOW
BLUE='\033[34m' # BLUE
CYAN='\033[36m' # CYAN
WHITE='\033[37m' # WHITE
BOLD='\033[1m' # BOLD
CLEAR='\033[0m'   # Clear color and formatting

# Install base first
sh -c "./install-base.sh --called-from-another"
# Startup
echo -e "${BLUE}${BOLD}=> ${WHITE}Install Prod Server Tool${CLEAR}"

install-basic-tools() {
    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Tmux${CLEAR}"
    sudo -E apt -y install tmux

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Zerotier${CLEAR}"
    echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Add repository${CLEAR}"
    sudo mkdir -p /etc/apt/trusted.gpg.d
    curl -fsSL https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/zerotier.gpg
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/zerotier.gpg] https://download.zerotier.com/debian/$(lsb_release -cs) $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/zerotier.list > /dev/null
    echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Update apt source list${CLEAR}"
    sudo -E apt update
    echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Install${CLEAR}"
    sudo -E apt -y install zerotier-one
}

install-portainer() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Create volume${CLEAR}"
    sudo docker volume create portainer_data

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Startup${CLEAR}"
    sudo docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
}

install-pm2() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Load NVM${CLEAR}"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install pm2${CLEAR}"
    npm i -g pm2@latest

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Set PM2 to Startup${CLEAR}"
    sudo env PATH=$PATH:$NVM_BIN $NVM_BIN/pm2 startup systemd -u $(whoami) --hp $HOME
}

remove-snap() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Remove all package from snap${CLEAR}"
    sudo snap remove $(snap list | awk '!/^Name|^core|^snapd/ {print $1}')
    sudo snap remove $(snap list | awk '!/^Name|^snapd/ {print $1}')
    sudo snap remove snapd

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Remove snap${CLEAR}"
    sudo -E apt -y remove --purge --autoremove snapd 

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Set up apt to block snap${CLEAR}"
    echo "# To prevent repository packages from triggering the installation of snap," | sudo tee /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "# this file forbids snapd from being installed by APT." | sudo tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "" | sudo tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "Package: snapd" | sudo tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "Pin: release a=*" | sudo tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null
    echo "Pin-Priority: -10" | sudo tee -a /etc/apt/preferences.d/nosnap.pref > /dev/null

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Update software list${CLEAR}"
    sudo -E apt update
}

clean-up() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Clean up apt packages${CLEAR}"
    sudo -E apt -y --purge autoremove
    sudo -E apt clean
    sudo -E apt autoclean
}

install-all() {
    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install basic tools${CLEAR}"
    install-basic-tools
    
    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install portainer (docker manage tool)${CLEAR}"
    install-portainer

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install pm2${CLEAR}"
    install-pm2

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Remove snap${CLEAR}"
    remove-snap

    echo -e "\n${GREEN}${BOLD}POST SETUP ${BLUE}=> ${CYAN}Clean-Up${CLEAR}"
    clean-up
}

install-all

echo -e "\n${BLUE}${BOLD}=> ${WHITE}Prod Server Tool Install Complete!${CLEAR}\n"

if [ "$1" != "--called-from-another" ]; then
    echo -e "\n${BLUE}${BOLD}=> ${WHITE}Install Complete! Restart your computer to continue!${CLEAR}"
fi