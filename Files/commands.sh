sudo docker run --name nginx  -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/usr/share/nginx/html --network nginx-evil -p 8080:8080 -d nginx
csudo docker exec nginx nginx -t
sudo docker exec nginx nginx -s reload
# Apache
apt update && apt install apache2 php7.4 vim sudo -y
sed -i 's/80/8080/g' /etc/nginx/conf.d/default.conf && nginx -s reload
a2enmod php7.4
service apache2 start
chmod 777 /etc/nginx/conf.d/default.conf
#Docker
curl -fsSL https://get.docker.com | sh
echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers