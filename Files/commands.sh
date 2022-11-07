sudo docker run --name nginx -v $(pwd):/usr/share/nginx/html --network nginx-evil -p 8080:8080 -d nginx
sudo docker exec nginx nginx -t
sudo docker exec nginx nginx -s reload
apt update && apt install apache2 php7.4 vim -y
sed -i 's/80/8080/g' /etc/nginx/conf.d/default.conf && nginx -s reload

a2enmod php7.4
service apache2 start
