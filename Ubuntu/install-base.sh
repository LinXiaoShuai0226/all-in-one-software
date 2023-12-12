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
echo -e "${BLUE}${BOLD}=> ${WHITE}Install Basic Tool${CLEAR}"

# Activate sudo permission
echo -e "\n${BLUE}${BOLD}=> ${WHITE}Check for sudo permission${CLEAR}"
sudo -v

do-system-upgrade() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Update software list${CLEAR}"
    sudo -E apt -y update

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Upgrade system softwares${CLEAR}"
    sudo -E apt -y upgrade
}

install-basic-tools() {
    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Git & GPG${CLEAR}"
    sudo -E apt -y install git gpg

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Curl & Wget${CLEAR}"
    sudo -E apt -y install curl wget
    
    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Vim${CLEAR}"
    sudo -E apt -y install vim

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Htop${CLEAR}"
    sudo -E apt -y install htop

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Z-Shell${CLEAR}"
    sudo -E apt -y install zsh

    echo -e "\n${YELLOW}${BOLD}SOFTWARE ${BLUE}=> ${WHITE}Neofetch${CLEAR}"
    sudo -E apt -y install neofetch
}

setup-basic-config() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Git user config${CLEAR}"
    git config --global user.email "a09700700@gmail.com"
    git config --global user.name "Kim"

    # echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Setup GPG Sign${CLEAR}"
    # if [ -f "a09700700.private.gpg" ]; then
    #     echo -e "${CYAN}${BOLD}CHECK ${BLUE}=> ${GREEN}GPG file exists!${CLEAR}"

    #     echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Import GPG key${CLEAR}"
    #     gpg --import a09700700.private.gpg

    #     echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Change trust level${CLEAR}"
    #     keyid=$(gpg --quiet --import-options import-show --import a09700700.private.gpg | sed -e '2!d' -e 's/^[ \t]*//') &&  echo "${keyid}:6:" | gpg --import-ownertrust

    #     echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Test gpg signing${CLEAR}"
    #     echo "test" | gpg --clearsign

    #     echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Enable git signing${CLEAR}"
    #     git config --global user.signingkey "2FCCF05F156BEE05"
    #     git config --global commit.gpgsign true
    # else
    #     echo -e "${CYAN}${BOLD}CHECK ${BLUE}=> ${YELLOW}GPG file not exist, GPG setup skipped!${CLEAR}"
    # fi

    # echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Change git editor${CLEAR}"
    # git config --global core.editor "vim"

    # echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Set default branch${CLEAR}"
    # git config --global init.defaultBranch main

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Setup ssh${CLEAR}"
    if [ -f "id_ed25519" ]; then
        echo -e "${CYAN}${BOLD}CHECK ${BLUE}=> ${GREEN}SSH private key exists!${CLEAR}"

        echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Make .ssh directory${CLEAR}"
        mkdir -p ~/.ssh

        echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Import SSH private key${CLEAR}"
        cp id_ed25519 ~/.ssh
        chmod 600 ~/.ssh/id_ed25519

        if [ -f "id_ed25519" ]; then
            echo -e "${CYAN}${BOLD}CHECK ${BLUE}=> ${GREEN}Paired SSH public key exists!${CLEAR}"

            echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Import SSH public key${CLEAR}"
            cp id_ed25519.pub ~/.ssh
            chmod 644 ~/.ssh/id_ed25519.pub
        fi
    else
        echo -e "${CYAN}${BOLD}CHECK ${BLUE}=> ${YELLOW}SSH private key not exist!${CLEAR}"

        echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Make .ssh directory${CLEAR}"
        mkdir -p ~/.ssh

        echo -e "\n${CYAN}${BOLD}STEP ${BLUE}=> ${WHITE}Generate a new ed25519 key pair${CLEAR}"
        ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -N ""
    fi
}

setup-zsh() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install oh-my-zsh${CLEAR}"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Set Z-Shell to default shell${CLEAR}"
    sudo chsh -s $(which zsh) $(whoami)

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Setup oh-my-zsh${CLEAR}"

    echo -e "${CYAN}${BOLD}THEME ${BLUE}=> ${WHITE}powerlevel10k${CLEAR}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    sed -i 's/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"powerlevel10k\/powerlevel10k\"/' ~/.zshrc

    echo -e "${CYAN}${BOLD}PLUGIN ${BLUE}=> ${WHITE}zsh-completions${CLEAR}"
    git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
    sed -i 's/source $ZSH\/oh-my-zsh.sh/fpath\+=\${ZSH_CUSTOM\:-\${ZSH\:-~\/.oh-my-zsh}\/custom}\/plugins\/zsh-completions\/src\nsource $ZSH\/oh-my-zsh.sh/' ~/.zshrc
    
    echo -e "${CYAN}${BOLD}PLUGIN ${BLUE}=> ${WHITE}zsh-syntax-highlighting${CLEAR}"
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    sed -i 's/plugins=(git/plugins=(git zsh-syntax-highlighting/' ~/.zshrc
}

install-node() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install nvm${CLEAR}"
    export NVM_DIR="$HOME/.nvm" && (
        git clone https://github.com/nvm-sh/nvm.git "$NVM_DIR"
        cd "$NVM_DIR"
        git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    ) && \. "$NVM_DIR/nvm.sh"

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install latest lts version${CLEAR}"
    nvm install --lts

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Enable corepack for yarn and pnpm${CLEAR}"
    corepack enable

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install zsh-nvm plugin for oh-my-zsh${CLEAR}"
    git clone https://github.com/lukechilds/zsh-nvm ~/.oh-my-zsh/custom/plugins/zsh-nvm
    sed -i 's/plugins=(git/plugins=(git zsh-nvm/' ~/.zshrc

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install default node npm nvm yarn plugin for oh-my-zsh${CLEAR}"
    sed -i 's/plugins=(git/plugins=(git node npm nvm yarn/' ~/.zshrc
}

install-docker() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install dependcies${CLEAR}"
    sudo -E apt -y install ca-certificates curl gnupg lsb-release

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Add repository${CLEAR}"
    sudo mkdir -p /etc/apt/trusted.gpg.d
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/trusted.gpg.d/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Update apt source list${CLEAR}"
    sudo -E apt update

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install docker${CLEAR}"
    sudo -E apt -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Enable docker permission${CLEAR}"
    sudo gpasswd -a $(whoami) docker
}

install-python() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install pip for python3${CLEAR}"
    sudo -E apt -y install python3-pip

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install venv for python3${CLEAR}"
    sudo -E apt -y install python3-venv
}

install-php() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install php-cli and all requirements for laravel${CLEAR}"
    sudo -E apt -y install php-cli openssl php-common php-curl php-json php-mbstring php-mysql php-xml php-zip

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install composer${CLEAR}"
    EXPECTED_CHECKSUM="$(php -r 'copy("https://composer.github.io/installer.sig", "php://stdout");')"
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_CHECKSUM="$(php -r "echo hash_file('sha384', 'composer-setup.php');")"

    if [ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]
    then
        echo -e "${CYAN}${BOLD}CHECK ${BLUE}=> ${YELLOW}Installer checksum failed! Composer installation skipped!${CLEAR}"
    else
        php composer-setup.php
    fi

    rm composer-setup.php
    sudo mv composer.phar /usr/local/bin/composer

    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Install default composer and laravel plugin for oh-my-zsh${CLEAR}"
    sed -i '' 's/plugins=(git/plugins=(git composer laravel laravel5/' ~/.zshrc
}

clean-up() {
    echo -e "\n${YELLOW}${BOLD}STEP ${BLUE}=> ${WHITE}Clean up apt packages${CLEAR}"
    sudo -E apt -y --purge autoremove
    sudo -E apt clean
    sudo -E apt autoclean
}

install-all() {
    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Update the system${CLEAR}"
    do-system-upgrade

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install basic tools${CLEAR}"
    install-basic-tools

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Setup basic config${CLEAR}"
    setup-basic-config

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Setup Z-Shell${CLEAR}"
    setup-zsh

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install Node.js${CLEAR}"
    install-node

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install Docker${CLEAR}"
    install-docker

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install Python${CLEAR}"
    install-python

    echo -e "\n${GREEN}${BOLD}SETUP ${BLUE}=> ${CYAN}Install php${CLEAR}"
    install-php

    echo -e "\n${GREEN}${BOLD}POST SETUP ${BLUE}=> ${CYAN}Clean-Up${CLEAR}"
    clean-up
}

install-all

echo -e "\n${BLUE}${BOLD}=> ${WHITE}Basic Tool Install Complete!${CLEAR}\n"

if [ "$1" != "--called-from-another" ]; then
    echo -e "\n${BLUE}${BOLD}=> ${WHITE}Install Complete! Restart your computer to continue!${CLEAR}"
fi
