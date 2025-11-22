#!/usr/bin/env python3
import os

# رنگ‌ها
GREEN = "\033[1;32m"
CYAN = "\033[1;36m"
YELLOW = "\033[1;33m"
RED = "\033[1;31m"
BLUE = "\033[1;34m"
RESET = "\033[0m"

# منو
print(f"{GREEN}Select a VPN protocol for subscription:{RESET}")
print(f"{CYAN}1. {YELLOW}all{RESET}")
print(f"{CYAN}2. {YELLOW}VLESS{RESET}")
print(f"{CYAN}3. {YELLOW}VMESS{RESET}")
print(f"{CYAN}4. {YELLOW}SHADOWSOCKS{RESET}")
print(f"{CYAN}5. {YELLOW}TROJAN{RESET}")
print(f"{CYAN}6. {YELLOW}Hysteria2{RESET}")
print(f"{CYAN}7. {YELLOW}Reality{RESET}")
print(f"{CYAN}8. {YELLOW}Tuic{RESET}")
print(f"{CYAN}9. {YELLOW}Warp{RESET}")
print(f"{CYAN}10. {YELLOW}Light{RESET}")
print(f"{CYAN}11. {YELLOW}Juicity{RESET}")
print(f"{CYAN}0. {YELLOW}Exit{RESET}")

choice = input(f"{GREEN}Enter your choice: {RESET}").strip()

subscription = None
if choice == "0":
    print(f"{YELLOW}Exiting...{RESET}")
    exit(0)
elif choice == "1":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/config.txt"
elif choice == "2":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/vless.txt"
elif choice == "3":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/vmess.txt"
elif choice == "4":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/ss.txt"
elif choice == "5":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/trojan.txt"
elif choice == "6":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/refs/heads/main/hysteria.txt"
elif choice == "7":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/reality.txt"
elif choice == "8":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/tuic.txt"
elif choice == "9":
    subscription = "https://raw.githubusercontent.com/ircfspace/warpsub/main/export/warp"
elif choice == "10":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/config_lite.txt"
elif choice == "11":
    subscription = "https://raw.githubusercontent.com/Kolandone/v2raycollector/main/juicity.txt"
else:
    print(f"{RED}Invalid input.{RESET}")
    exit(1)

# باز کردن لینک در مرورگر اندروید با دستور Termux
if subscription:
    print(f"{GREEN}Opening subscription link in browser...{RESET}")
    os.system(f'am start -a android.intent.action.VIEW -d "{subscription}" >/dev/null 2>&1')
