#!/bin/bash

# ====== Colors ======
GREEN=$(tput setaf 2)   # Success messages
YELLOW=$(tput setaf 3)  # Warnings
BLUE=$(tput setaf 4)    # Info
CYAN=$(tput setaf 6)    # Highlights
RED=$(tput setaf 1)     # Errors
RESET=$(tput sgr0)

# ====== Fetch API Values ======
get_values() {
    local api_output=$(curl -sL "https://api.zeroteam.top/warp?format=sing-box")
    
    local ipv6=$(echo "$api_output" | grep -oE '"2606:4700:[0-9a-f:]+/128"' | sed 's/"//g')
    local private_key=$(echo "$api_output" | grep -oE '"private_key":"[0-9a-zA-Z\/+]+=+"' | sed 's/"private_key":"//; s/"//')
    local public_key=$(echo "$api_output" | grep -oE '"peer_public_key":"[0-9a-zA-Z\/+]+=+"' | sed 's/"peer_public_key":"//; s/"//')
    local reserved=$(echo "$api_output" | grep -oE '"reserved":\[[0-9]+(,[0-9]+){2}\]' | sed 's/"reserved"://; s/\[//; s/\]//')
    
    echo "$ipv6@$private_key@$public_key@$reserved"
}

# ====== Detect Architecture ======
case "$(uname -m)" in
    x86_64 | x64 | amd64 ) cpu=amd64 ;;
    i386 | i686 ) cpu=386 ;;
    armv8 | armv8l | arm64 | aarch64 ) cpu=arm64 ;;
    armv7l ) cpu=arm ;;
    * )
        echo "${RED}The current architecture $(uname -m) is not supported${RESET}"
        exit
    ;;
esac

# ====== Download Warp Endpoint ======
cfwarpIP(){
    echo "${BLUE}Downloading warp endpoint for your CPU architecture...${RESET}"
    [[ -n $cpu ]] && curl -L -o warpendpoint -# --retry 2 "https://raw.githubusercontent.com/azavaxhuman/Quick_Warp_on_Warp/main/cpu/$cpu"
}

# ====== Generate Random IPv4 List ======
endipv4(){
    n=0; iplist=100
    while true; do
        temp[$n]=$(echo 162.159.192.$(($RANDOM%256))); n=$((n+1))
        temp[$n]=$(echo 162.159.193.$(($RANDOM%256))); n=$((n+1))
        temp[$n]=$(echo 162.159.195.$(($RANDOM%256))); n=$((n+1))
        temp[$n]=$(echo 188.114.96.$(($RANDOM%256))); n=$((n+1))
        temp[$n]=$(echo 188.114.97.$(($RANDOM%256))); n=$((n+1))
        temp[$n]=$(echo 188.114.98.$(($RANDOM%256))); n=$((n+1))
        temp[$n]=$(echo 188.114.99.$(($RANDOM%256))); n=$((n+1))
        [[ $n -ge $iplist ]] && break
    done
}

# ====== Process CSV & Generate JSON ======
process_result_csv() {
    count_conf=$1
    values=$(get_values)
    w_ip=$(echo "$values" | cut -d'@' -f1)
    w_pv=$(echo "$values" | cut -d'@' -f2)
    w_pb=$(echo "$values" | cut -d'@' -f3)
    w_res=$(echo "$values" | cut -d'@' -f4)

    num_lines=$(wc -l < ./result.csv)
    [[ "$count_conf" -lt "$num_lines" ]] && num_lines=$count_conf

    temp_json=""
    for ((i=2; i<=$num_lines; i++)); do
        line=$(sed -n "${i}p" ./result.csv)
        ip=$(echo "$line" | awk -F',' '{print $1}' | awk -F':' '{print $1}')
        port=$(echo "$line" | awk -F',' '{print $1}' | awk -F':' '{print $2}')

        temp_json+="{\"type\":\"wireguard\",\"tag\":\"Warp-$i\",\"server\":\"$ip\",\"server_port\":$port,\"local_address\":[\"172.16.0.2/32\",\"$w_ip\"],\"private_key\":\"$w_pv\",\"peer_public_key\":\"$w_pb\",\"reserved\":[$w_res]},"
    done

    full_json="{\"outbounds\":[${temp_json%,}]}"
    echo "$full_json" > output.json
    echo "${GREEN}JSON created successfully!${RESET}"
}

# ====== Menu ======
menu(){
    clear
    echo "${CYAN}----- DDS-WOW (Warp on Warp) -----${RESET}"
    echo "1. Automatic scanning and execution (Android/Linux)"
    echo "2. Import custom IPs with result.csv"
    read -rp "Choose an option: " option

    case "$option" in
        1)
            read -rp "Number of required configurations: " number_of_configs
            cfwarpIP
            endipv4
            process_result_csv $number_of_configs
        ;;
        2)
            read -rp "Number of required configurations: " number_of_configs
            process_result_csv $number_of_configs
        ;;
        *)
            echo "${RED}Invalid option!${RESET}"
        ;;
    esac
}

menu
