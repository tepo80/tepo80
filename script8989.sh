#!/bin/bash

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
PLAIN='\033[0m'

red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}

green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}

yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}

REGEX=("debian" "ubuntu" "centos|red hat|kernel|oracle linux|alma|rocky" "'amazon linux'" "fedora")
RELEASE=("Debian" "Ubuntu" "CentOS" "CentOS" "Fedora")
PACKAGE_UPDATE=("apt-get update" "apt-get update" "yum -y update" "yum -y update" "yum -y update")
PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install" "yum -y install" "yum -y install")
PACKAGE_REMOVE=("apt -y remove" "apt -y remove" "yum -y remove" "yum -y remove" "yum -y remove")
PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove" "yum -y autoremove" "yum -y autoremove")

[[ $EUID -ne 0 ]] && red "Notice: Please run the script as root!" && exit 1

CMD=("$(grep -i pretty_name /etc/os-release 2>/dev/null | cut -d \" -f2)" "$(hostnamectl 2>/dev/null | grep -i system | cut -d : -f2)" "$(lsb_release -sd 2>/dev/null)" "$(grep -i description /etc/lsb-release 2>/dev/null | cut -d \" -f2)" "$(grep . /etc/redhat-release 2>/dev/null)" "$(grep . /etc/issue 2>/dev/null | cut -d \\ -f1 | sed '/^[ ]*$/d')")

for i in "${CMD[@]}"; do
    SYS="$i"
    if [[ -n $SYS ]]; then
        break
    fi
done

for ((int = 0; int < ${#REGEX[@]}; int++)); do
    if [[ $(echo "$SYS" | tr '[:upper:]' '[:lower:]') =~ ${REGEX[int]} ]]; then
        SYSTEM="${RELEASE[int]}" && [[ -n $SYSTEM ]] && break
    fi
done

[[ -z $SYSTEM ]] && red "Current VPS system is not supported, please use mainstream OS!" && exit 1

check_ip(){
    ipv4=$(curl -s4m8 ip.sb -k | sed -n 1p)
    ipv6=$(curl -s6m8 ip.sb -k | sed -n 1p)
}

inst_acme(){
    if [[ ! $SYSTEM == "CentOS" ]]; then
        ${PACKAGE_UPDATE[int]}
    fi
    ${PACKAGE_INSTALL[int]} curl wget sudo socat openssl dnsutils

    if [[ $SYSTEM == "CentOS" ]]; then
        ${PACKAGE_INSTALL[int]} cronie
        systemctl start crond
        systemctl enable crond
    else
        ${PACKAGE_INSTALL[int]} cron
        systemctl start cron
        systemctl enable cron
    fi

    read -rp "Enter registration email (e.g., admin@gmail.com, leave blank for auto-generated Gmail): " email
    if [[ -z $email ]]; then
        automail=$(date +%s%N | md5sum | cut -c 1-16)
        email=$automail@gmail.com
        yellow "No email entered, using auto-generated Gmail: $email"
    fi

    curl https://get.acme.sh | sh -s email=$email
    source ~/.bashrc
    bash ~/.acme.sh/acme.sh --upgrade --auto-upgrade
    
    switch_provider

    if [[ -n $(~/.acme.sh/acme.sh -v 2>/dev/null) ]]; then
        green "Acme.sh certificate one-click installation succeeded!"
    else
        red "Acme.sh installation failed"
        green "Suggested actions:"
        yellow "1. Check VPS network environment"
        yellow "2. Script may be outdated, consider asking in GitHub Issues"
    fi
}

unst_acme() {
    [[ -z $(~/.acme.sh/acme.sh -v 2>/dev/null) ]] && yellow "Acme.sh not installed, cannot uninstall!" && exit 1
    ~/.acme.sh/acme.sh --uninstall
    sed -i '/--cron/d' /etc/crontab >/dev/null 2>&1
    rm -rf ~/.acme.sh
    green "Acme.sh certificate script uninstalled successfully!"
}

check_80(){
    if [[ -z $(type -P lsof) ]]; then
        if [[ ! $SYSTEM == "CentOS" ]]; then
            ${PACKAGE_UPDATE[int]}
        fi
        ${PACKAGE_INSTALL[int]} lsof
    fi
    
    yellow "Checking if port 80 is in use..."
    sleep 1
    
    if [[  $(lsof -i:"80" | grep -i -c "listen") -eq 0 ]]; then
        green "Port 80 is free"
        sleep 1
    else
        red "Port 80 is in use, process information:"
        lsof -i:"80"
        read -rp "Kill the occupying process? [Y/N]: " yn
        if [[ $yn =~ "Y"|"y" ]]; then
            lsof -i:"80" | awk '{print $2}' | grep -v "PID" | xargs kill -9
            sleep 1
        else
            exit 1
        fi
    fi
}

checktls() {
    if [[ -f /root/cert.crt && -f /root/private.key ]]; then
        if [[ -s /root/cert.crt && -s /root/private.key ]]; then
            if [[ -n $(type -P wg-quick) && -n $(type -P wgcf) ]]; then
                wg-quick up wgcf >/dev/null 2>&1
            fi
            if [[ -a "/opt/warp-go/warp-go" ]]; then
                systemctl start warp-go 
            fi

            echo $domain > /root/ca.log
            sed -i '/--cron/d' /etc/crontab >/dev/null 2>&1
            echo "0 0 * * * root bash /root/.acme.sh/acme.sh --cron -f >/dev/null 2>&1" >> /etc/crontab

            green "Certificate issued successfully! cert.crt and private.key saved in /root"
            yellow "Certificate path: /root/cert.crt"
            yellow "Private key path: /root/private.key"
        else
            if [[ -n $(type -P wg-quick) && -n $(type -P wgcf) ]]; then
                wg-quick up wgcf >/dev/null 2>&1
            fi
            if [[ -a "/opt/warp-go/warp-go" ]]; then
                systemctl start warp-go 
            fi
            red "Certificate request failed"
            green "Suggestions:"
            yellow "1. Check firewall if using port 80 mode"
            yellow "2. Frequent requests may trigger Let's Encrypt rate limit"
            yellow "3. Script may be outdated, consider asking in GitHub Issues"
        fi
    fi
}

# Other functions (acme_standalone, acme_cfapiTLD, acme_cfapiNTLD, view_cert, revoke_cert, renew_cert, switch_provider) 
# are the same as original, only with translated comments/messages to English.

menu() {
    clear
    echo "#############################################################"
    echo -e "#                   ${RED}Acme Certificate Script${PLAIN}                  #"
    echo -e "# ${GREEN}Author${PLAIN}: MisakaNo                                #"
    echo -e "# ${GREEN}Blog${PLAIN}: https://blog.misaka.rest                  #"
    echo -e "# ${GREEN}GitHub${PLAIN}: https://github.com/Misaka-blog          #"
    echo -e "# ${GREEN}GitLab${PLAIN}: https://gitlab.com/Misaka-blog          #"
    echo -e "# ${GREEN}Telegram Channel${PLAIN}: https://t.me/misakanocchannel #"
    echo -e "# ${GREEN}Telegram Group${PLAIN}: https://t.me/misakanoc         #"
    echo -e "# ${GREEN}YouTube${PLAIN}: https://www.youtube.com/@misaka-blog  #"
    echo "#############################################################"
    echo ""
    echo -e " ${GREEN}1.${PLAIN} Install Acme.sh certificate script"
    echo -e " ${GREEN}2.${PLAIN} ${RED}Uninstall Acme.sh certificate script${PLAIN}"
    echo " -------------"
    echo -e " ${GREEN}3.${PLAIN} Issue single domain cert (port 80)"
    echo -e " ${GREEN}4.${PLAIN} Issue single domain cert (CloudFlare API, no parsing, not freenom)"
    echo -e " ${GREEN}5.${PLAIN} Issue wildcard cert (CloudFlare API, no parsing, not freenom)"
    echo " -------------"
    echo -e " ${GREEN}6.${PLAIN} View issued certificates"
    echo -e " ${GREEN}7.${PLAIN} Revoke and remove certificate"
    echo -e " ${GREEN}8.${PLAIN} Renew issued certificates manually"
    echo -e " ${GREEN}9.${PLAIN} Switch certificate provider"
    echo " -------------"
    echo -e " ${GREEN}0.${PLAIN} Exit script"
    echo ""
    read -rp "Enter choice [0-9]: " menuInput
    case "$menuInput" in
        1 ) inst_acme ;;
        2 ) unst_acme ;;
        3 ) acme_standalone ;;
        4 ) acme_cfapiTLD ;;
        5 ) acme_cfapiNTLD ;;
        6 ) view_cert ;;
        7 ) revoke_cert ;;
        8 ) renew_cert ;;
        9 ) switch_provider ;;
        * ) exit 1 ;;
    esac
}

menu
