#!/bin/bash

# ==============================
#   COLOR SYSTEM
# ==============================
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
MAGENTA=$(tput setaf 5)
CYAN=$(tput setaf 6)
RESET=$(tput sgr0)
BOLD=$(tput bold)

# ==============================
#   CPU ARCHITECTURE CHECK
# ==============================
case "$(uname -m)" in
    x86_64 | x64 | amd64 )
        cpu=amd64
        ;;
    i386 | i686 )
        cpu=386
        ;;
    armv8 | armv8l | arm64 | aarch64 )
        cpu=arm64
        ;;
    armv7l )
        cpu=arm
        ;;
    * )
        echo "${RED}The current architecture is $(uname -m), which is NOT supported.${RESET}"
        exit
        ;;
esac

# ==============================
#   REGISTER FUNCTION
# ==============================
cfwarpreg(){
    echo "${CYAN}→ Registering warp wireguard profile...${RESET}"
    curl -sSL https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/acwarp.sh \
        -o acwarp.sh && chmod +x acwarp.sh && ./acwarp.sh
}

# ==============================
#   IPV4 / IPV6 SCAN MENU
# ==============================
warpendipv4v6(){
    echo "${MAGENTA}"
    echo "1) IPv4 preferred peer IP"
    echo "2) IPv6 preferred peer IP"
    echo "0) Quit"
    echo "${RESET}"
    read -p "Choose an option: " menu

    case $menu in
        1)  cfwarpIP && endipv4 && endipresult ;;
        2)  cfwarpIP && endipv6 && endipresult ;;
        0)  exit ;;
        *)  echo "${RED}Invalid option${RESET}" ;;
    esac
}

# ==============================
#   DOWNLOAD SCANNER
# ==============================
cfwarpIP(){
    echo "${YELLOW}→ Downloading warp optimization program...${RESET}"
    curl -L -o warpendpoint -# --retry 2 \
        https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/$cpu
}

# ==============================
#   IPV4 GENERATOR
# ==============================
endipv4(){
    n=0
    iplist=500

    blocks=(
        "162.159.192"
        "162.159.193"
        "162.159.195"
        "188.114.96"
        "188.114.97"
        "188.114.98"
        "188.114.99"
    )

    while [ $n -lt $iplist ]; do
        for b in "${blocks[@]}"; do
            temp[$n]="$b.$((RANDOM % 256))"
            n=$((n + 1))
            [ $n -ge $iplist ] && break
        done
    done
}

# ==============================
#   IPV6 GENERATOR
# ==============================
endipv6(){
    n=0
    iplist=500

    while [ $n -lt $iplist ]; do
        r1=$(printf '%x\n' $((RANDOM*2 + RANDOM%2)))
        r2=$(printf '%x\n' $((RANDOM*2 + RANDOM%2)))
        r3=$(printf '%x\n' $((RANDOM*2 + RANDOM%2)))
        r4=$(printf '%x\n' $((RANDOM*2 + RANDOM%2)))

        temp[$n]="[2606:4700:d0::$r1:$r2:$r3:$r4]"
        n=$((n + 1))
        [ $n -ge $iplist ] && break

        temp[$n]="[2606:4700:d1::$r1:$r2:$r3:$r4]"
        n=$((n + 1))
    done
}

# ==============================
#   RESULT HANDLER
# ==============================
endipresult(){
    echo "${BLUE}→ Processing IP results...${RESET}"

    echo "${temp[@]}" | sed -e 's/ /\n/g' | sort -u > ip.txt

    ulimit -n 102400
    chmod +x warpendpoint
    ./warpendpoint

    clear
    echo "${GREEN}Top 100 best results:${RESET}"
    cat result.csv | awk -F, '$3!="timeout ms" {print}' \
    | sort -t, -nk2 -nk3 | uniq | head -100 \
    | awk -F, '{print "Endpoint: "$1"   Loss: "$2"   Avg latency: "$3}'

    rm -rf ip.txt warpendpoint
    exit
}

# ==============================
#   MAIN MENU UI
# ==============================
clear
echo "${CYAN}${BOLD}"
echo "======================================================"
echo "      WARP Preferred IP Scanner — Clean PRO Edition    "
echo "======================================================"
echo "${RESET}"

echo "${YELLOW}Github : github.com/yonggekkk"
echo "Blog   : ygkkk.blogspot.com"
echo "YouTube: youtube.com/@ygkkk${RESET}"
echo ""
echo "${GREEN}Thanks to CF community developers${RESET}"
echo ""
echo "${MAGENTA}1) WARP IPv4/IPv6 Preferred IP Scanner"
echo "2) Register & generate WARP Wireguard config (QR)"
echo "0) Exit${RESET}"
echo ""

read -p "Choose an option: " menu

case $menu in
    1)  warpendipv4v6 ;;
    2)  cfwarpreg ;;
    0)  exit ;;
    *)  echo "${RED}Invalid option${RESET}" ;;
esac
