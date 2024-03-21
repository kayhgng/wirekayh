#!/usr/bin/env python

# colors
red = '\033[0;31m'
green = '\033[0;32m'
yellow = '\033[0;33m'
blue = '\033[0;34m'
purple = '\033[0;35m'
cyan = '\033[0;36m'
white = '\033[0;37m'
rest = '\033[0m'

import platform
import subprocess
import random
import os

def get_cpu_architecture():
    architecture = platform.machine()
    if architecture in ['x86_64', 'x64', 'amd64']:
        return 'amd64'
    elif architecture in ['i386', 'i686']:
        return '386'
    elif architecture in ['armv8', 'armv8l', 'arm64', 'aarch64']:
        return 'arm64'
    elif architecture == 'armv7l':
        return 'arm'
    else:
        print(f"The current architecture is {architecture}, not supported")
        exit()

def cfwarpIP():
    if not os.path.isfile("warpendpoint"):
        print("Download warp preferred program")
        cpu = get_cpu_architecture()
        if cpu:
            subprocess.run(["curl", "-L", "-o", "warpendpoint", "-#", "--retry", "2", f"https://raw.githubusercontent.com/Ptechgithub/warp/main/endip/{cpu}"])

def endipv4():
    n = 0
    iplist = 100
    temp = []
    while True:
        temp.append(f"162.159.192.{random.randint(0, 255)}")
        n += 1
        if n >= iplist:
            break
        temp.append(f"162.159.193.{random.randint(0, 255)}")
        n += 1
        if n >= iplist:
            break
        temp.append(f"162.159.195.{random.randint(0, 255)}")
        n += 1
        if n >= iplist:
            break
        temp.append(f"188.114.96.{random.randint(0, 255)}")
        n += 1
        if n >= iplist:
            break
        temp.append(f"188.114.97.{random.randint(0, 255)}")
        n += 1
        if n >= iplist:
            break
        temp.append(f"188.114.98.{random.randint(0, 255)}")
        n += 1
        if n >= iplist:
            break
        temp.append(f"188.114.99.{random.randint(0, 255)}")
        n += 1
        if n >= iplist:
            break

    while True:
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"162.159.192.{random.randint(0, 255)}")
            n += 1
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"162.159.193.{random.randint(0, 255)}")
            n += 1
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"162.159.195.{random.randint(0, 255)}")
            n += 1
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"188.114.96.{random.randint(0, 255)}")
            n += 1
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"188.114.97.{random.randint(0, 255)}")
            n += 1
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"188.114.98.{random.randint(0, 255)}")
            n += 1
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"188.114.99.{random.randint(0, 255)}")
            n += 1
        if len(set(temp)) >= iplist:
            break

def endipv6():
    n = 0
    iplist = 100
    temp = []
    while True:
        temp.append(f"[2606:4700:d0::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]")
        n += 1
        if n >= iplist:
            break
        temp.append(f"[2606:4700:d1::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]")
        n += 1
        if n >= iplist:
            break

    while True:
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"[2606:4700:d0::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]")
            n += 1
        if len(set(temp)) >= iplist:
            break
        else:
            temp.append(f"[2606:4700:d1::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]")
            n += 1
        if len(set(temp)) >= iplist:
            break

def endipresult():
    with open("ip.txt", "w") as file:
        file.write("\n".join(set(temp)))
    subprocess.run(["ulimit", "-n", "102400"])
    subprocess.run(["chmod", "+x", "warpendpoint"])
    subprocess.run(["./warpendpoint"])
    subprocess.run(["clear"])
    subprocess.run(["awk", "-F,", "'$3!=\"timeout ms\" {print}'", "result.csv", "|", "sort", "-t,", "-nk2", "-nk3", "|", "uniq", "|", "head", "-11", "|", "awk", "-F,", "'{print \"Endpoint \"$1\" Packet Loss Rate \"$2\" Average Delay \"$3}'"])
    Endip_v4 = subprocess.run(["grep", "-oE", "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+:[0-9]+", "result.csv", "|", "head", "-n", "1"], capture_output=True).stdout.decode().strip()
    Endip_v6 = subprocess.run(["grep", "-oE", "\[.*\]:[0-9]+", "result.csv", "|", "head", "-n", "1"], capture_output=True).stdout.decode().strip()
    print("")
    print(f"{green}Results Saved in result.csv{rest}")
    print("")
    print(f"{yellow}------------------------------------------{rest}")
    if Endip_v4:
        print(f"{yellow} Best IPv4:Port ---> {purple}{Endip_v4} {rest}")
    elif Endip_v6:
        print(f"{yellow} Best IPv6:Port ---> {purple}{Endip_v6} {rest}")
    else:
        print(f"{red} No valid IP addresses found.{rest}")
    print(f"{yellow}------------------------------------------{rest}")
    subprocess.run(["rm", "warpendpoint"])
    subprocess.run(["rm", "-rf", "ip.txt"])
    exit()

def main():
    print("--------------------------------------------")
    print("KayH GNG Github Project : github.com/kayhgng")
    print(f"{yellow}By --> KayH GNG * Github.com/kayhgng *{rest}")
    print("--------------------------------------------")
    print("")
    print(f"{purple}1.{green}IPV4 preferred peer IP{rest}")
    print(f"{purple}2.{green}IPV6 preferred peer IP{rest}")
    print(f"{purple}0.{green}Exit{rest}")
    menu = input("please choose: ")
    if menu == "1":
        cfwarpIP()
        endipv4()
        endipresult()
    elif menu == "2":
        cfwarpIP()
        endipv6()
        endipresult()
    else:
        exit()

if __name__ == "__main__":
    main()
