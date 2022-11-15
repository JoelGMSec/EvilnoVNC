FROM nginx:1.23.2

LABEL maintainer="Wanetty - https://wanetty.github.io"

RUN apt update && apt install apache2 php7.4 sudo -y
RUN curl -fsSL https://get.docker.com | sh
RUN echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
RUN a2enmod php7.4


