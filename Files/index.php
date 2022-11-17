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





if (isset($_GET['x'])){

    $uidphp=uniqid("", true);
    $uidphp=str_replace(".","_",$uidphp);
    $filename = '/etc/nginx/conf.d/default.conf';
    $flag = '/tmp/flag.txt';
    
    $resolu = $_GET['x'];
    $check_res = explode("x",$resolu);
    if (!is_numeric($check_res[0]) || !is_numeric($check_res[1]) || count($check_res) != 2) {
        echo "error";
        exit;
    }
    $output=null;
    $retval=null;
    exec("sudo docker run -d --rm  -v download_string/".$uidphp.":/home/user/Downloads -e FOLDER=".$uidphp." -e RESOLUTION=".$resolu."x24 -e WEBPAGE=webpage --network=nginx-evil --name ".$uidphp." idimage > /dev/null", $output,$retval);

    $fp = fopen("/tmp/log_php", 'a');
    fwrite($fp, $retval." - ".$output);
    fclose($fp);

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
        if (!file_exists($flag)){
            $fp = fopen($flag, 'a');
            fwrite($fp, "check");
            fclose($fp); 
        }
        
        echo $uidphp;
        system('sudo nginx -s reload');
    }else{
        echo "error";
        exit;
    }
}else{
    echo "error";
    exit;
}

?>