sudo /bin/bash -c "php -q -S 0.0.0.0:80 &" > /dev/null 2>&1
echo "URL=$WEBPAGE" > php.ini ; URL=$(head -1 php.ini | cut -d "=" -f 2)
while [ ! -f /tmp/client_info.txt ]; do
sleep 1 ; done
while read -rd $'' line; do export "$line" ; done < <(jq -r <<<"$values" 'to_entries|map("\(.key)=\"\(.value)\"\u0000")[]' /tmp/client_info.txt)
sudo pkill -9 php ; sudo socat TCP-LISTEN:80,reuseaddr,fork TCP:localhost:5980 &
echo 'starting with'$RESOLUTION
sudo /bin/bash -c /home/user/startVNC.sh $RESOLUTION
