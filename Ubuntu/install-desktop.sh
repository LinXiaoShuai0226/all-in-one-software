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

# Provide options for extra scripts.
# Credit: https://serverfault.com/questions/144939/multi-select-menu-in-bash-script
options=($(ls extras))

menu() {
    echo -e "${BLUE}${BOLD}==${WHITE}Select extra script to run after base installation${BLUE}==${CLEAR}\n"
    echo -e "${WHITE}Avaliable scripts:"
    for i in ${!options[@]}; do 
        printf "${YELLOW}%3d${GREEN}%s${WHITE}) ${CLEAR}%s\n" $((i+1)) "${choices[i]:- }" "${options[i]}"
    done
    if [[ "$msg" ]]; then echo -e "\n${YELLOW}$msg${CLEAR}"; else echo -e ""; fi
}

prompt="Check an option (again to uncheck, ENTER when done): "
while menu && read -rp "$prompt" num && [[ "$num" ]]; do
    [[ "$num" != *[![:digit:]]* ]] &&
    (( num > 0 && num <= ${#options[@]} )) ||
    { msg="Invalid option: $num"; continue; }
    ((num--)); msg="${options[num]} was ${choices[num]:+un}checked"
    [[ "${choices[num]}" ]] && choices[num]="" || choices[num]="+"
done

# Install base first
sh -c "./install-base.sh --called-from-another"
# Startup
echo -e "${BLUE}${BOLD}=> ${WHITE}Install Desktop Tool${CLEAR}"

install-basic-tools() {

}

install-dev-tools() {

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Visual Studio Code${CLEAR}"
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Download deb file${CLEAR}"
    curl -SL https://code.visualstudio.com/sha/download\?build\=stable\&os\=linux-deb-x64 --output code.deb
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Install${CLEAR}"
    cp code.deb /tmp
    sudo -E apt -y install /tmp/code.deb


    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}MySQL Workbench${CLEAR}"
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Download deb file${CLEAR}"
    curl -SL https://dev.mysql.com/get/Downloads/MySQLGUITools/mysql-workbench-community_8.0.31-1ubuntu22.04_amd64.deb --output mysql-workbench.deb
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Install${CLEAR}"
    cp mysql-workbench.deb /tmp
    sudo -E apt -y install /tmp/mysql-workbench.deb

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}MQTTX${CLEAR}"
    sudo snap install mqttx

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}NVM for desktop${CLEAR}"
    echo "export NVM_DIR=\"\$([ -z \"\${XDG_CONFIG_HOME-}\" ] && printf %s \"\${HOME}/.nvm\" || printf %s \"\${XDG_CONFIG_HOME}/nvm\")" >> ~/.zprofile
    echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\" # This loads nvm" >> ~/.zprofile
    echo "" >> ~/.zprofile
}

install-personalize() {

}

install-communtiy() {
    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Telegram Desktop${CLEAR}"
    sudo snap install telegram-desktop

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Discord Canary${CLEAR}"
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Download deb file${CLEAR}"
    curl -SL https://discord.com/api/download/canary\?platform\=linux\&format=deb --output discord-canary.deb
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Install${CLEAR}"
    cp discord-canary.deb /tmp
    sudo -E apt -y install /tmp/discord-canary.deb

    wget https://obs-sg.line-apps.com/desktop/linux/Line.x86_64.rpm
    sudo rpm -i Line.x86_64.rpm

}

# 字體
install-portainer() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Create volume${CLEAR}"
    sudo docker volume create portainer_data

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Startup${CLEAR}"
    sudo docker run -d -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest
}

clean-up() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Clean up deb files${CLEAR}"
    rm /tmp/*.deb
    rm ./*.deb

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Clean up font files${CLEAR}"
    rm -r /tmp/fonts
    rm ./*.zip

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Clean up apt packages${CLEAR}"
    sudo -E apt -y --purge autoremove
    sudo -E apt clean
    sudo -E apt autoclean

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Clean up snap caches${CLEAR}"
    sudo sh -c 'rm -rf /var/lib/snapd/cache/*'
}

install-all() {
    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install basic tools${CLEAR}"
    install-basic-tools
    
    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install dev tools${CLEAR}"
    install-dev-tools

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install personalizations${CLEAR}"
    install-personalize
    
    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install community tools${CLEAR}"
    install-communtiy

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install portainer (docker manage tool)${CLEAR}"
    install-portainer

    echo -e "\n${GREEN}${BOLD}POST SETUP ${BLUE}=> ${CYAN}Clean-Up${CLEAR}"
    clean-up
}

install-all

echo -e "\n${BLUE}${BOLD}=> ${WHITE}Desktop Tool Install Complete!${CLEAR}\n"

for i in ${!options[@]}; do 
    [[ "${choices[i]}" ]] && sh -c "./extras/${options[i]}"
done

echo -e "\n${BLUE}${BOLD}=> ${WHITE}Install Complete! Restart your computer to continue!${CLEAR}"
