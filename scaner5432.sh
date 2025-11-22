#!/bin/bash

GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

get_values() {
    api_output=$(curl -sL "https://api.zeroteam.top/warp?format=sing-box")

    ipv6=$(echo "$api_output" | grep -oE '"2606:4700:[0-9a-f:]+/128"' | sed 's/"//g')
    private_key=$(echo "$api_output" | grep -oE '"private_key":"[0-9a-zA-Z\/+]+=+"' | sed 's/"private_key":"//; s/"//')
    public_key=$(echo "$api_output" | grep -oE '"peer_public_key":"[0-9a-zA-Z\/+]+=+"' | sed 's/"peer_public_key":"//; s/"//')
    reserved=$(echo "$api_output" | grep -oE '"reserved":\[[0-9]+(,[0-9]+){2}\]' | sed 's/"reserved"://; s/\[//; s/\]//')

    echo "$ipv6@$private_key@$public_key@$reserved"
}

case "$(uname -m)" in
	x86_64 | x64 | amd64 ) cpu=amd64 ;;
	i386 | i686 ) cpu=386 ;;
	armv8 | armv8l | arm64 | aarch64 ) cpu=arm64 ;;
	armv7l ) cpu=arm ;;
	*) echo "The current architecture is $(uname -m), temporarily not supported"; exit ;;
esac

cfwarpIP(){
echo "download warp endpoint file base on your CPU architecture"
[[ -n $cpu ]] && curl -L -o warpendpoint -# --retry 2 \
"https://raw.githubusercontent.com/azavaxhuman/Quick_Warp_on_Warp/main/cpu/$cpu"
}

endipv4(){
	n=0
	iplist=100
	while true; do
		for block in "162.159.192" "162.159.193" "162.159.195" "188.114.96" "188.114.97" "188.114.98" "188.114.99"
		do
			temp[$n]="$block.$(($RANDOM%256))"
			((n++))
			[[ $n -ge $iplist ]] && break 2
		done
	done
	echo "${temp[@]}" | tr ' ' '\n' | sort -u > ip.txt
}

endipresult(){
	local temp_var=$1
	clear
	echo "${GREEN}successfully generated ipv4 endip list${RESET}"
	echo "${GREEN}successfully create result.csv file${RESET}"
	echo "${CYAN}Now we're going to process result.csv${RESET}"
	process_result_csv $temp_var
	rm -rf ip.txt warpendpoint result.csv
	exit
}

process_result_csv() {

count_conf=$1
temp_json=""

values=$(get_values)
w_ip=$(echo "$values" | cut -d'@' -f1)
w_pv=$(echo "$values" | cut -d'@' -f2)
w_pb=$(echo "$values" | cut -d'@' -f3)
w_res=$(echo "$values" | cut -d'@' -f4)

i_values=$(get_values)
i_w_ip=$(echo "$i_values" | cut -d'@' -f1)
i_w_pv=$(echo "$i_values" | cut -d'@' -f2)
i_w_pb=$(echo "$i_values" | cut -d'@' -f3)
i_w_res=$(echo "$i_values" | cut -d'@' -f4)

num_lines=$(wc -l < ./result.csv)
echo ""
echo "We have considered the number of ${num_lines} IPs."
echo ""

[[ $count_conf -lt $num_lines ]] && num_lines=$count_conf

for ((i=2; i<=$num_lines; i++)); do
	line=$(sed -n "${i}p" ./result.csv)
	endpoint=$(echo "$line" | awk -F',' '{print $1}')
	ip=$(echo "$endpoint" | cut -d: -f1)
	port=$(echo "$endpoint" | cut -d: -f2)

	new_json='{
      "type": "wireguard",
      "tag": "Warp-IR'"$i"'",
      "server": "'"$ip"'",
      "server_port": '"$port"',
      "local_address": ["172.16.0.2/32","'"$w_ip"'"],
      "private_key": "'"$w_pv"'",
      "peer_public_key": "'"$w_pb"'",
      "reserved": ['$w_res'],
      "mtu": 1280
    },
    {
      "type": "wireguard",
      "tag": "Warp-Main'"$i"'",
      "detour": "Warp-IR'"$i"'",
      "server": "'"$ip"'",
      "server_port": '"$port"',
      "local_address": ["172.16.0.2/32","'"$i_w_ip"'"],
      "private_key": "'"$i_w_pv"'",
      "peer_public_key": "'"$i_w_pb"'",
      "reserved": ['$i_w_res'],
      "mtu": 1120
    }'

	temp_json+="$new_json"
	(( i < num_lines )) && temp_json+=","
done

full_json='{ "outbounds": ['"$temp_json"'] }'

echo "$full_json" > output.json

echo ""
echo "${GREEN}Upload Files to Get Link${RESET}"
echo "------------------------------------------------------------"
echo ""
echo "Your link:"

# ---- FIXED UPLOAD (NO MORE TLS ERRORS) ----
if curl --max-time 5 -s https://transfer.sh >/dev/null; then
    curl -s --upload-file output.json https://transfer.sh/output.json
elif curl --max-time 5 -s https://file.io >/dev/null; then
    curl -s -F "file=@output.json" https://file.io | jq -r '.link'
else
    curl -s https://bashupload.com/ -T output.json
fi

echo "------------------------------------------------------------"

mv output.json output_$(date +"%Y%m%d_%H%M%S").json
}

menu(){
clear
echo ""
echo "--------------- DDS-WOW -----------------------------"
echo ""
echo "1.Automatic scanning and execution"
echo "2.Import custom IPs with result.csv"
read -r -p "Please choose an option: " option

if [[ "$option" = "1" ]]; then
	read -r -p "Number of required configurations: " number_of_configs
	cfwarpIP
	endipv4
	endipresult $number_of_configs

elif [[ "$option" = "2" ]]; then
	read -r -p "Number of required configurations: " number_of_configs
	process_result_csv $number_of_configs
else
	echo "Invalid option"
fi
}

menu
