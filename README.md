<p align="center"><img width=600 alt="EvilnoVNC" src="https://github.com/JoelGMSec/EvilnoVNC/blob/main/EvilnoVNC.png"></p>

# EvilnoVNC
**EvilnoVNC** is a Ready to go Phishing Platform. 

Unlike other phishing techniques, EvilnoVNC allows 2FA bypassing by using a real browser over a noVNC connection.

In addition, this tool allows us to see in real time all of the victim's actions, access to their downloaded files and the entire browser profile, including cookies, saved passwords, browsing history and much more.


# Requirements
- Docker
- Chromium


# Download
It's recommended to clone the complete repository or download the zip file.\
Additionally, it's necessary to build Docker manually. You can do this by running the following commands:
```
git clone https://github.com/JoelGMSec/EvilnoVNC
cd EvilnoVNC ; sudo chown -R 103 Downloads
sudo docker build -f evilnovnc.Dockerfile -t evilnovnc .
sudo docker build -f nginx.Dockerfile -t evilnginx .
```


# Usage (Now not work)
```
./start.sh -h
                                                     
  _____       _ _          __     ___   _  ____ 
 | ____|_   _(_) |_ __   __\ \   / / \ | |/ ___|
 |  _| \ \ / / | | '_ \ / _ \ \ / /|  \| | |    
 | |___ \ V /| | | | | | (_) \ V / | |\  | |___ 
 |_____| \_/ |_|_|_| |_|\___/ \_/  |_| \_|\____| 

  ---------------- by @JoelGMSec --------------

Usage: ./start.sh $resolution $url

Examples:
        1280x720  16bits: ./start.sh 1280x720x16 http://example.com
        1280x720  24bits: ./start.sh 1280x720x24 http://example.com
        1920x1080 16bits: ./start.sh 1920x1080x16 http://example.com
        1920x1080 24bits: ./start.sh 1920x1080x24 http://example.com

```

### The detailed guide of use can be found at the following link:

https://darkbyte.net/robando-sesiones-y-bypasseando-2fa-con-evilnovnc

# Usage MultiServer

```bash
./start_auto.sh $url
```

If you want to make it more credible, modify the index.html by adapting the js code.

You will find the cookies and the keylogger output inside the Downloads folder in its corresponding id.


# Features & To Do
- [X] Export Evil-Chromium profile to host
- [X] Save download files on host
- [X] Disable parameters in URL (like password)
- [X] Disable key combinations (like Alt+1 or Ctrl+S)
- [X] Disable access to Thunar
- [X] Decrypt cookies in real time
- [X] Expand cookie life to 99999999999999999
- [X] Dynamic title from original website
- [X] Dynamic resolution from preload page
- [X] Multiple users
- [ ] Replicate real user-agent and other stuff
- [X] Basic keylogger



# License
This project is licensed under the GNU 3.0 license - see the LICENSE file for more details.


# Credits and Acknowledgments
Original idea by [@mrd0x](https://twitter.com/mrd0x): https://mrd0x.com/bypass-2fa-using-novnc \
This tool has been created and designed from scratch by Joel Gámez Molina // @JoelGMSec


# Contact
This software does not offer any kind of guarantee. Its use is exclusive for educational environments and / or security audits with the corresponding consent of the client. I am not responsible for its misuse or for any possible damage caused by it.

For more information, you can find me on Twitter as [@JoelGMSec](https://twitter.com/JoelGMSec) and on my blog [darkbyte.net](https://darkbyte.net).


# Support
You can support my work buying me a coffee:

[<img width=250 alt="buymeacoffe" src="https://cdn.buymeacoffee.com/buttons/v2/default-blue.png">](https://www.buymeacoffee.com/joelgmsec)
