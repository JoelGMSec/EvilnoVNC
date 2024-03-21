export DISPLAY=:0
URL=$(head -1 php.ini | cut -d "=" -f 2)
cp /home/user/noVNC/vnc_lite.html /home/user/noVNC/index.html
TITLE=$(curl -sk $URL | grep "<title>" | grep "</title>" | sed "s/<[^>]*>//g")
echo $TITLE > title.txt && sed -i "4s/.*/$(head -1 title.txt)/g" noVNC/index.html
sudo mkdir Downloads 2> /dev/null && sudo chmod 777 -R Downloads && sudo chmod 777 kiosk.zip
sudo mkdir -p /var/run/dbus && sudo dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address

# get USERAGENT and CLIENT_LANG
while read -rd $'' line; do export "$line" ; done < <(jq -r <<<"$values" 'to_entries|map("\(.key)=\"\(.value)\"\u0000")[]' /tmp/client_info.txt)
unzip -n kiosk.zip && sleep 6 && /usr/bin/chromium-browser --load-extension=/home/user/kiosk/ --kiosk $URL --fast ---fast-start --user-agent="${USERAGENT//\"}" --accept-lang=${CLIENT_LANG//\"}
