#!/bin/bash

# =======================[ GRAPHIC UI PACK ]=======================
RED="\033[1;31m"
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
BLUE="\033[1;36m"
MAGENTA="\033[1;35m"
CYAN="\033[1;96m"
WHITE="\033[1;97m"
RESET="\033[0m"

LINE_BLUE="${BLUE}────────────────────────────────────────────${RESET}"
LINE_CYAN="${CYAN}════════════════════════════════════════════${RESET}"

banner() {
    echo -e "$LINE_CYAN"
    echo -e "${MAGENTA}            ✦ ${CYAN}$1${MAGENTA} ✦${RESET}"
    echo -e "$LINE_CYAN"
}

menu_item() {
    echo -e "${YELLOW}[$1]${RESET} ${WHITE}$2${RESET}"
}

ok(){ echo -e "${GREEN}✔ $1${RESET}"; }
err(){ echo -e "${RED}✘ $1${RESET}"; }
info(){ echo -e "${BLUE}ℹ $1${RESET}"; }

box(){
    echo -e "$LINE_BLUE"
    echo -e "${CYAN}$1${RESET}"
    echo -e "$LINE_BLUE"
}
# ==================================================================

# ------------------------ ARCH CHECK ------------------------
banner "CPU Architecture Check"

case "$(uname -m)" in
    x86_64|amd64 ) cpu=amd64 ; ok "Detected: AMD64" ;;
    i386|i686 )    cpu=386   ; ok "Detected: 386" ;;
    arm64|aarch64 ) cpu=arm64 ; ok "Detected: ARM64" ;;
    armv7l )       cpu=arm    ; ok "Detected: ARMv7" ;;
    * ) err "Unsupported CPU: $(uname -m)" ; exit ;;
esac


# ------------------------ FUNCTIONS ------------------------
cfwarpreg(){
    banner "Registering WARP"
    info "Downloading registration tool..."
    curl -sSL https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/acwarp.sh -o acwarp.sh
    chmod +x acwarp.sh
    ./acwarp.sh
}

warpendipv4v6(){
    banner "WARP Preferred IP Scanner"
    menu_item 1 "IPv4 preferred peer"
    menu_item 2 "IPv6 preferred peer"
    menu_item 0 "Quit"
    echo -ne "${YELLOW}Choose:${RESET} "
    read menu

    [[ "$menu" == "1" ]] && cfwarpIP && endipv4 && endipresult
    [[ "$menu" == "2" ]] && cfwarpIP && endipv6 && endipresult
    exit
}

cfwarpIP(){
    info "Downloading scanner..."
    curl -sSL -o warpendpoint "https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/$cpu"
    chmod +x warpendpoint
}

# ------------------------ IPV4 GEN ------------------------
endipv4(){
    banner "Generating 500 IPv4 endpoints..."
    temp=()
    while [ ${#temp[@]} -lt 500 ]; do
        for base in 162.159.192 162.159.193 162.159.195 188.114.96 188.114.97 188.114.98 188.114.99; do
            temp+=("$base.$((RANDOM % 256))")
            [[ ${#temp[@]} -ge 500 ]] && break
        done
    done
}

# ------------------------ IPV6 GEN — FIXED (NO ERRORS) ------------------------
endipv6(){
    banner "Generating 500 IPv6 endpoints..."
    temp=()
    while [ ${#temp[@]} -lt 500 ]; do
        for block in d0 d1; do
            hex1=$(printf "%x" $((RANDOM % 65535)))
            hex2=$(printf "%x" $((RANDOM % 65535)))
            hex3=$(printf "%x" $((RANDOM % 65535)))
            hex4=$(printf "%x" $((RANDOM % 65535)))

            temp+=("2606:4700:${block}::${hex1}:${hex2}:${hex3}:${hex4}")
            [[ ${#temp[@]} -ge 500 ]] && break
        done
    done
}

# ------------------------ RESULT ------------------------
endipresult(){
    banner "Scanning Endpoints… Please Wait"
    echo "${temp[@]}" | tr ' ' '\n' | sort -u > ip.txt

    info "Running speed test..."
    ./warpendpoint

    clear
    box "TOP 100 FASTEST ENDPOINTS"

    cat result.csv \
    | awk -F, '$3!="timeout ms" {print}' \
    | sort -t, -nk2 -nk3 \
    | head -100 \
    | awk -F, '{print "Endpoint " $1 "   Loss: " $2 "   Avg Latency: " $3}'

    rm -f ip.txt warpendpoint
    exit
}

# ------------------------ MAIN MENU ------------------------
banner "YONGGE WARP TOOL"

echo -e "${CYAN}Github:${RESET} github.com/yonggekkk"
echo -e "${CYAN}Blog:${RESET} ygkkk.blogspot.com"
echo -e "${CYAN}YouTube:${RESET} youtube.com/@ygkkk"
echo

menu_item 1 "WARP V4/V6 Preferred Peer IP"
menu_item 2 "Register & Generate WARP-WG Config"
menu_item 0 "Exit"
echo -ne "${YELLOW}Choose:${RESET} "
read menu

[[ "$menu" == "1" ]] && warpendipv4v6
[[ "$menu" == "2" ]] && cfwarpreg
exit
