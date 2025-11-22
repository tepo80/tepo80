#!/usr/bin/env python3
import os

# رنگ‌ها
GREEN = "\033[1;32m"
CYAN = "\033[1;36m"
YELLOW = "\033[1;33m"
RED = "\033[1;31m"
RESET = "\033[0m"

# منو
options = [
    ("arista", "https://tepo98.ahsan-tepo20.workers.dev/api/arista-panel-v2ray"),
    ("hestrya", "https://raw.githubusercontent.com/arshiacomplus/v2rayExtractor/main/hy2.html"),
    ("panel chini", "https://chine-panel.ahsan-tepo98.workers.dev/c808ce19-f298-4087-9bf1-27a5649fc307/sub"),
    ("DoKtor 1", "https://raw.githubusercontent.com/parvinxs/Fssociety/refs/heads/main/Fssociety.sub"),
    ("DOKtor", "https://raw.githubusercontent.com/parvinxs/Submahsanetxsparvin/refs/heads/main/Sub.mahsa.xsparvin"),
    ("tepo90_h2", "https://raw.githubusercontent.com/tepo18/tepo90/main/final2.txt"),
    ("hp", "https://raw.githubusercontent.com/tepo80/Trojan/refs/heads/main/hp.txt"),
    ("sab chini 2", "https://almasi-1990.almasi-ali98.workers.dev/522e8484-53de-41a1-a5ba-92e2ec3b7b26/ty"),
    ("shah", "https://raw.githubusercontent.com/tepo98/kv98/refs/heads/main/shah.html"),
    ("sshmax", "https://raw.githubusercontent.com/tepo18/online-sshmax98/main/final.txt"),
    ("vmess", "https://raw.githubusercontent.com/hamedp-71/v2go_NEW/main/Splitted-By-Protocol/vmess.txt"),
    ("ss", "https://raw.githubusercontent.com/hamedp-71/v2go_NEW/main/Splitted-By-Protocol/ss.txt"),
    ("trojan", "https://raw.githubusercontent.com/hamedp-71/v2go_NEW/main/Splitted-By-Protocol/trojan.txt"),
    ("vless", "https://raw.githubusercontent.com/hamedp-71/v2go_NEW/main/Splitted-By-Protocol/vless.txt"),
    ("reality", "https://raw.githubusercontent.com/coldwater-10/V2Hub/main/Split/Base64/reality"),
    ("hamed", "https://zaya.link/Arista_HP_Final#xsfilternet"),
    ("hamed_1", "https://zaya.link/V2GO_everyday"),
    ("sab-vip10", "https://raw.githubusercontent.com/tepo18/sab-vip10/main/final20.txt"),
    ("panel-man", "https://panel-akbar.ahsan-tepo1383online.workers.dev/txt"),
    ("almasi", "https://raw.githubusercontent.com/tepo80/sab-vip90/main/almasi.txt"),
]

# نمایش منو
print(f"{GREEN}Select a VPN protocol for subscription:{RESET}")
for idx, (name, _) in enumerate(options, 1):
    print(f"{CYAN}{idx}. {YELLOW}{name}{RESET}")
print(f"{CYAN}0. {YELLOW}Exit{RESET}")

choice = input(f"{GREEN}Enter your choice: {RESET}").strip()

# خروج در صورت انتخاب 0
if choice == "0":
    print(f"{YELLOW}Exiting...{RESET}")
    exit(0)

# بررسی انتخاب و باز کردن لینک
try:
    idx = int(choice) - 1
    if 0 <= idx < len(options):
        subscription = options[idx][1]
        print(f"{GREEN}Opening subscription link in browser...{RESET}")
        os.system(f'am start -a android.intent.action.VIEW -d "{subscription}" >/dev/null 2>&1')
    else:
        print(f"{RED}Invalid input.{RESET}")
        exit(1)
except ValueError:
    print(f"{RED}Invalid input.{RESET}")
    exit(1)
