export DISPLAY=:0
mkdir /home/user/noVNC/$FOLDER && cp -r /home/user/noVNC/* /home/user/noVNC/$FOLDER/
TITLE=$(wget -qO- $WEBPAGE | grep -o '<title>.*</title>' | sed "s/<[^>]*>//g")
sed -i "124d" /home/user/noVNC/vnc_lite.html &&  sed  "131 i let path=\"$FOLDER/websockify\"" /home/user/noVNC/vnc_lite.html > /home/user/noVNC/index.html 
echo $TITLE > title.txt && sed -i "4s/.*/$(cat title.txt)/g" noVNC/index.html
sudo chmod a-rwx /usr/bin/xfce4-panel && sudo chmod a-rwx /usr/bin/thunar
sudo mkdir Downloads 2> /dev/null && sudo chmod 777 -R Downloads && sudo chmod 777 kiosk.zip
sudo mkdir -p /var/run/dbus && sudo dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address
unzip kiosk.zip && sleep 3 && /usr/bin/chromium-browser --load-extension=/home/user/kiosk/  --kiosk $WEBPAGE  --fast ---fast-start --user-agent="${USERAGENT//\"}" --accept-lang=${LANG//\"} &