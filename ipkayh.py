import subprocess
import platform
import random
import os

def get_cpu_architecture():
    """Get the CPU architecture of the current system."""
    arch = platform.machine()
    if arch in ['x86_64', 'x64', 'amd64']:
        return 'amd64'
    elif arch in ['i386', 'i686']:
        return '386'
    elif arch in ['armv8', 'armv8l', 'arm64', 'aarch64']:
        return 'arm64'
    elif arch == 'armv7l':
        return 'arm'
    else:
        print(f"The current architecture is {arch}, which is not supported yet")
        exit()

def cfwarpreg():
    """Function to handle registration for generating WARP-Wireguard configuration files and QR codes"""
    subprocess.run(['curl', '-sSL', 'https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/acwarp.sh', '-o', 'acwarp.sh'])
    subprocess.run(['chmod', '+x', 'acwarp.sh'])
    subprocess.run(['./acwarp.sh'])

def warpendipv4v6():
    """Function to handle WARP-V4V6 preferred peer IP"""
    print("1. IPV4 preferred peer IP")
    print("2. IPV6 preferred peer IP")
    print("0. Quit")
    menu = input("Please choose: ")
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

def cfwarpIP():
    """Function to download the warp optimization program"""
    print("Downloading the warp optimization program...")
    cpu = get_cpu_architecture()
    if cpu:
        subprocess.run(['curl', '-L', '-o', 'warpendpoint', '-#', '--retry', '2', f'https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/{cpu}'])

def endipv4():
    """Function to generate IPV4 addresses"""
    iplist = 500
    temp = []
    while len(temp) < iplist:
        temp.extend([f'162.159.192.{random.randint(0, 255)}',
                     f'162.159.193.{random.randint(0, 255)}',
                     f'162.159.195.{random.randint(0, 255)}',
                     f'188.114.96.{random.randint(0, 255)}',
                     f'188.114.97.{random.randint(0, 255)}',
                     f'188.114.98.{random.randint(0, 255)}',
                     f'188.114.99.{random.randint(0, 255)}'])
    with open("ip.txt", "w") as file:
        for ip in temp:
            file.write(ip + "\n")

def endipv6():
    """Function to generate IPV6 addresses"""
    iplist = 500
    temp = []
    while len(temp) < iplist:
        temp.extend([f'[2606:4700:d0::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]',
                     f'[2606:4700:d1::{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}:{random.randint(0, 65535):x}]'])
    with open("ip.txt", "w") as file:
        for ip in temp:
            file.write(ip + "\n")

def endipresult():
    """Function to handle the final IP result"""
    subprocess.run(['ulimit', '-n', '102400'])
    subprocess.run(['chmod', '+x', 'warpendpoint'])
    subprocess.run(['./warpendpoint'])
    subprocess.run(['clear'])
    subprocess.run(['awk', '-F,', '$3!="timeout ms" {print} ', 'result.csv', '|', 'sort', '-t,', '-nk2', '-nk3', '|', 'uniq', '|', 'head', '-100', '|', 'awk', '-F,', '{print "endpoint "$1" Packet loss rate "$2" average latency "$3}'])
    os.remove("ip.txt")
    os.remove("warpendpoint")
    exit()

if __name__ == "__main__":
    print("------------------------------------------------------")
    print("Yongge Github project  ：github.com/yonggekkk")
    print("KayH GNG Github Project : github.com/kayhgng")
    print("""https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/endip.sh --> 
          Converted to python by KayH GNG -->
            https://raw.githubusercontent.com/kayhgng/ipcleanwarp/main/ipkayh.py """)
    print("The script supports WARP preferred IP and WARP configuration file generation, thanks to CF and KayH GNG  for development")
    print("------------------------------------------------------")
    print()
    print("1. WARP-V4V6 preferred peer IP")
    print("2. Register to generate WARP-Wireguard configuration files and QR codes")
    print("0. Exit")
    menu = input("Please choose: ")
    if menu == "1":
        warpendipv4v6()
    elif menu == "2":
        cfwarpreg()
    else:
        exit()
