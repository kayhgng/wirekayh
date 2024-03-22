#!/bin/bash
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
	echo "The current architecture is $(uname -m), which is not supported yet"
	exit
	;;
esac
[ ! -f /tmp/pkgupdate ] && $(type -P yum || type -P apt) update && touch /tmp/pkgupdate 2> /dev/null >/dev/null
$(type -P yum || type -P apt) install -y qrencode 2> /dev/null | grep -v "already installed" >/dev/null
rmrf(){
rm -rf wgcf-account.toml wgcf-profile.conf warpgo.conf sbwarp.json warp-go warp.conf wgcf warp-api-wg.txt warpapi
}

#echo "The current Sing-box outbound configuration file is as follows" && sleep 1
#echo "$(cat /usr/local/bin/sbwarp.json | python3 -mjson.tool)"

acwarpapi(){
    echo "Download the warp api registration program..."
    curl -L -o warpapi -# --retry 2 https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/cpu1/$cpu
    chmod +x warpapi
    output=$(./warpapi)
    if ./warpapi 2>&1 | grep -q "connection refused"; then
        echo "申请warp api普通账户失败，请尝试使用warp-go方式进行注册" && exit
    fi
    private_key=$(echo "$output" | awk -F'=' '/^PrivateKey/ {print $2}')
    v6=$(echo "$output" | awk -F'= ' '/^v6/ {print $2}')
    res=$(echo "$output" | awk -F'= ' '/^reserved/ {print $2}' | tr -d '[:space:]')
    cat > warp-api-wg.txt <<EOF
    [Interface]
    PrivateKey = $private_key
    Address = 172.16.0.2/32, $v6/128
    DNS = 1.1.1.1
    MTU = 1280
    [Peer]
    PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
    AllowedIPs = 0.0.0.0/0, ::/0
    Endpoint = 162.159.193.10:2408
    EOF
    clear
    echo
    echo "Warp account Ba Movafaghiat Sakhte shod!" && sleep 3
    echo
    echo "reserved value：$res" && sleep 2
    echo
    echo "warp-wireguard (api) Account shoma be in sorat ast" && sleep 2
    cat warp-api-wg.txt
    echo
    sleep 2
    qrencode -t ansiutf8 < warp-api-wg.txt 2>/dev/null
    echo
    note
    rmrf
}
wgcfreg(){
echo "Download the warp-wgcf registration program..."
curl -L -o wgcf -# --retry 2 https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/wgcf_2.2.17_$cpu
chmod +x wgcf
echo | ./wgcf register 2> /dev/null
if echo | ./wgcf register 2>&1 | grep -q "connection refused"; then
echo "Failed to apply for a warp-wgcf common account, please try to register using warp-go" && exit
fi
until [[ -e wgcf-account.toml ]]
do
echo "Apply for warp-wgcf general account, please wait" && sleep 1
echo | ./wgcf register
done
echo | ./wgcf generate
sed -i "s/engage.cloudflareclient.com:2408/162.159.193.10:2408/g" wgcf-profile.conf
}
wgcfup(){
if [[ ! -e wgcf-account.toml ]]; then
wgcfreg
fi
read -p "Copy license key (26 characters):" ID
if [[ -z $ID ]]; then
echo "Nothing entered" && exit
fi
sed -i "s/license_key.*/license_key = \"$ID\"/g" wgcf-account.toml
echo | ./wgcf update
echo "If 400 Bad Request is displayed, it will be automatically restored to the WARP ordinary account"
echo | ./wgcf generate
sed -i "s/engage.cloudflareclient.com:2408/162.159.193.10:2408/g" wgcf-profile.conf
}
wgcfteams(){
wgcfreg
echo "Teams Token acquisition address: https://web--public--warp-team-api--coia-mfs4.code.run/"
read -p " Please enter the team account Token: " TEAM_TOKEN
WG_API=$(curl -sSL https://wg.cloudflare.now.cc)
PRIVATEKEY=$(expr "$WG_API" | awk 'NR==2 {print $2}')
PUBLICKEY=$(expr "$WG_API" | awk 'NR==1 {print $2}')
INSTALL_ID=$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 22)
FCM_TOKEN="${INSTALL_ID}:APA91b$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c 134)"
ERROR_TIMES=0
while [ "$ERROR_TIMES" -le 3 ]; do
(( ERROR_TIMES++ ))
if [[ "$TEAMS" =~ 'token is expired' ]]; then
read -p " Please refresh the token and copy again " TEAM_TOKEN
elif [[ "$TEAMS" =~ 'error' ]]; then
read -p " Please refresh the token and copy again " TEAM_TOKEN
elif [[ "$TEAMS" =~ 'organization' ]]; then
break
fi
TEAMS=$(curl --silent --location --tlsv1.3 --request POST 'https://api.cloudflareclient.com/v0a2158/reg' \
--header 'User-Agent: okhttp/3.12.1' \
--header 'CF-Client-Version: a-6.10-2158' \
--header 'Content-Type: application/json' \
--header "Cf-Access-Jwt-Assertion: ${TEAM_TOKEN}" \
--data '{"key":"'${PUBLICKEY}'","install_id":"'${INSTALL_ID}'","fcm_token":"'${FCM_TOKEN}'","tos":"'$(date +"%Y-%m-%dT%H:%M:%S.%3NZ")'","model":"Linux","serial_number":"'${INSTALL_ID}'","locale":"zh_CN"}')
ADDRESS6=$(expr "$TEAMS" : '.*"v6":[ ]*"\([^"]*\).*')
done
sed -i "s#PrivateKey.*#PrivateKey = $PRIVATEKEY#g;s#Address.*128#Address = $ADDRESS6/128#g" wgcf-profile.conf
}
wgcfshow(){
clear
echo
echo "Warp account Ba Movafaghiat Sakhte shod!" && sleep 2
echo
echo "warp-wireguard (wgcf) Account shoma be in sorat ast" && sleep 2
cat wgcf-profile.conf
echo
sleep 2
qrencode -t ansiutf8 < wgcf-profile.conf 2>/dev/null
echo
note
rmrf
}
warpgoac(){
echo "Download the warp-go registration program"
curl -L -o warp-go -# --retry 2 https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/warp-go_1.0.8_linux_${cpu}
chmod +x warp-go
curl -L -o warp.conf --retry 2 https://proxy.freecdn.ml?url=https://api.zeroteam.top/warp?format=warp-go
if [[ ! -s warp.conf ]]; then
curl -L -o warpapi -# --retry 2 https://raw.githubusercontent.com/MiSaturo/WarpScanner/main/point/cpu1/$cpu
chmod +x warpapi
output=$(./warpapi)
private_key=$(echo "$output" | awk -F ': ' '/private_key/{print $2}')
device_id=$(echo "$output" | awk -F ': ' '/device_id/{print $2}')
warp_token=$(echo "$output" | awk -F ': ' '/token/{print $2}')
rm -rf warpapi
cat > warp.conf <<EOF
[Account]
Device = $device_id
PrivateKey = $private_key
Token = $warp_token
Type = free
Name = WARP
MTU  = 1280
[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
Endpoint = 162.159.193.10:1701
# AllowedIPs = 0.0.0.0/0
# AllowedIPs = ::/0
KeepAlive = 30
EOF
fi
}
warpgoplus(){
warpgoac
echo "Please copy the button license key or network sharing key (26 characters) in the WARP+ state of the mobile WARP client, and enter it at will to have a chance to obtain a 1G traffic WARP+ account"
read -p "Please enter the upgrade WARP+ key:" ID
if [[ -z $ID ]]; then
echo "Nothing entered" && exit
fi
if ./warp-go --update --config=warp.conf --license=$ID --device-name=warp+$(date +%s%N |md5sum | cut -c 1-3) 2>&1 | grep -q "connection refused"; then
echo "The network connection is busy, the upgrade failed"
else
./warp-go --update --config=warp.conf --license=$ID --device-name=warp+$(date +%s%N |md5sum | cut -c 1-3)
fi
}
warpgoteams(){
warpgoac
echo "Teams Token acquisition address: https://web--public--warp-team-api--coia-mfs4.code.run/"
read -p "Please enter the team account Token:" ID
if ./warp-go --update --config=warp.conf --team-config=$ID --device-name=warp+teams+$(date +%s%N |md5sum | cut -c 1-3) 2>&1 | grep -q "connection refused"; then
echo "The network connection is busy, the upgrade failed"
else
./warp-go --update --config=warp.conf --team-config=$ID --device-name=warp+teams+$(date +%s%N |md5sum | cut -c 1-3)
fi
}
warpgoconfig(){
if ./warp-go --config=warp.conf --export-wireguard=warpgo.conf 2>&1 | grep -q "connection refused"; then
echo "Network connection is busy, only generating WARP-IPV4 configuration" && sleep 1
output=$(cat warp.conf)
private_key=$(sed -n 's/PrivateKey = \(.*\)/\1/p' warp.conf)
cat > warpgo.conf <<EOF
[Interface]
PrivateKey = $private_key
Address = 172.16.0.2/32
DNS = 1.1.1.1
MTU = 1280
[Peer]
PublicKey = bmXOC+F1FxEMF9dyiK2H5/1SUtzH0JuVo51h2wPfgyo=
AllowedIPs = 0.0.0.0/0
Endpoint = 162.159.193.10:2408
EOF
else
./warp-go --config=warp.conf --export-wireguard=warpgo.conf
./warp-go --config=warp.conf --export-singbox=sbwarp.json
fi
sed -i "s/engage.cloudflareclient.com:2408/162.159.193.10:2408/g" warpgo.conf
}
warpgoshow(){
clear
echo
echo "Warp account Ba Movafaghiat Sakhte shod!" && sleep 3
echo
reserved=$(grep -o '"reserved":\[[^]]*\]' sbwarp.json 2> /dev/null)
if [[ -n $reserved ]]; then
echo "reserved：$reserved" && sleep 2
fi
echo
echo "warp-wireguard (warp-go) Account shoma be in sorat ast" && sleep 2
cat warpgo.conf
echo
sleep 2
qrencode -t ansiutf8 < warpgo.conf 2>/dev/null
echo
rmrf
}
acwgcf(){
echo
echo "1.Ye Account Wiregaurd Warp Besaz"
read -p "Please select: " menu
if [ "$menu" == "1" ];then
wgcfreg && wgcfshow
elif [ "$menu" == "2" ];then
wgcfup && wgcfshow
elif [ "$menu" == "3" ];then
wgcfteams && wgcfshow
else 
exit
fi
}
acwarpgo(){
    echo
    echo "1.Ye Account Wiregaurd Warp Besaz"
    read -p "Please select: " menu
    if [ "$menu" == "1" ]; then
        warpgoac
        warpgoconfig
        warpgoshow
    elif [ "$menu" == "2" ]; then
        warpgoplus
        warpgoconfig
        warpgoshow
    elif [ "$menu" == "3" ]; then
        warpgoteams
        warpgoconfig
        warpgoshow
    else
        exit
    fi
}
echo "------------------------------------------------ ------"
echo "Yongge Github project: github.com/yonggekkk"
echo "KayH GNG Github : github.com/kayhgng"
echo "------------------------------------------------ ------"
echo "1. Yek Account Warp-go baram besaz"
echo "0. exit"
read -p "Please select: " menu
if [ "$menu" == "1" ]; then
    acwarpgo
elif [ "$menu" == "3" ]; then
    acwarpapi
elif [ "$menu" == "2" ]; then
    acwgcf
else
    exit
fi
