#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import yaml
import requests
import socket
import time
import os
from concurrent.futures import ThreadPoolExecutor, as_completed

# ---------------- منابع YAML ----------------
LINKS_PATH = [
    "https://raw.githubusercontent.com/tepo80/tepo80/refs/heads/main/shah.yaml",
    # هر تعداد لینک YAML دیگر اضافه کنید
]

# ---------------- فایل‌های خروجی ----------------
TEXT_NORMAL = "normal.yaml"
TEXT_FINAL = "final.yaml"

MAX_THREADS = 20        # تعداد thread برای پینگ موازی
MAX_PING_MS = 1200      # حداکثر زمان پاسخ (ms)

# ---------------- دانلود YAML ها ----------------
def download_yaml(url):
    try:
        r = requests.get(url, timeout=15)
        if r.status_code == 200:
            return yaml.safe_load(r.text)
    except:
        pass
    return None

# ---------------- استخراج همه پروکسی‌ها ----------------
def gather_proxies():
    all_proxies = []
    all_groups = []
    for url in LINKS_PATH:
        data = download_yaml(url)
        if data:
            all_proxies.extend(data.get("proxies", []))
            all_groups.extend(data.get("proxy-groups", []))
    return all_proxies, all_groups

# ---------------- پینگ TCP ----------------
def tcp_ping(host, port, timeout=2.0):
    try:
        start = time.monotonic()
        sock = socket.create_connection((host, port), timeout)
        sock.close()
        return int((time.monotonic() - start) * 1000)
    except:
        return None

# ---------------- تست پینگ پروکسی‌ها ----------------
def ping_check(proxies):
    results = []

    def worker(proxy):
        host = proxy.get("server")
        port = proxy.get("port")
        if host and port:
            lat = tcp_ping(host, port, timeout=2.0)
            if lat is not None and lat <= MAX_PING_MS:
                proxy["ping"] = lat
                proxy["status"] = "ok"
                return proxy
        return None

    with ThreadPoolExecutor(max_workers=MAX_THREADS) as executor:
        futures = {executor.submit(worker, p): p for p in proxies}
        for fut in as_completed(futures):
            res = fut.result()
            if res:
                results.append(res)

    # مرتب‌سازی بر اساس کمترین پینگ
    results.sort(key=lambda x: x.get("ping", 99999))
    return results

# ---------------- ذخیره YAML ----------------
def save_yaml(path, proxies, groups):
    data = {"proxies": proxies, "proxy-groups": groups, "rules": ["MATCH,📌🌐 بهترین پینگ🌐📌"]}
    with open(path, "w", encoding="utf-8") as f:
        yaml.safe_dump(data, f, allow_unicode=True, sort_keys=False)

# ---------------- اجرای اصلی ----------------
def main():
    # پاک‌سازی فایل‌های قبلی
    for path in [TEXT_NORMAL, TEXT_FINAL]:
        if os.path.exists(path):
            os.remove(path)

    print("[*] Downloading proxies from YAML sources...")
    proxies, groups = gather_proxies()
    print(f"[*] Total proxies fetched: {len(proxies)}")

    print("[*] Stage 1: Normal ping check...")
    normal = ping_check(proxies)
    print(f"[INFO] {len(normal)} proxies passed first ping check")
    save_yaml(TEXT_NORMAL, normal, groups)

    print("[*] Stage 2: Final ping check...")
    final = ping_check(normal)
    print(f"[INFO] {len(final)} proxies passed final ping check")
    save_yaml(TEXT_FINAL, final, groups)

    print("[✅] All done. Normal and Final YAML updated.")

if __name__ == "__main__":
    main()
