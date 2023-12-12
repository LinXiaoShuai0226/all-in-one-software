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

# Startup
echo -e "${BLUE}${BOLD}=> ${WHITE}Extra config for Multi System${CLEAR}"

install-grub-customize() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install grub customizer${CLEAR}"
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Add PPA${CLEAR}"
    sudo add-apt-repository -y ppa:danielrichter2007/grub-customizer
    echo -e "${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Install${CLEAR}"
    sudo -E apt -y install grub-customizer

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install grub theme${CLEAR}"
    git clone https://github.com/vinceliuice/grub2-themes.git ~/grub2-themes
    sudo ~/grub2-themes/install.sh -t vimix
}

install-all() {
    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Grub cutomization${CLEAR}"
    install-grub-customize
}

install-all

echo -e "\n${BLUE}${BOLD}=> ${WHITE}Extra config for Multi System Install Complete!${CLEAR}\n"
