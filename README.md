<p align="center"><img width=600 alt="EvilnoVNC" src="https://github.com/JoelGMSec/EvilnoVNC/blob/main/EvilnoVNC.png"></p>

# EvilnoVNC
**EvilnoVNC** is a Ready to go Phishing Platform. 

Unlike other phishing techniques, EvilnoVNC allows 2FA bypassing by using a real browser over a noVNC connection.

In addition, this tool allows us to see in real time all of the victim's actions, access to their downloaded files and the entire browser profile, including cookies, saved passwords, browsing history and much more.


# Requirements
- Docker


# Installation

It's recommended to clone the complete repository or download the zip file.
Additionally, it's necessary to build Docker manually. You can do this by running the following commands:

## Auto

```bash
git clone https://github.com/wanetty/EvilnoVNC
cd EvilnoVNC
make build
```
## Manual

```
git clone https://github.com/wanetty/EvilnoVNC
cd EvilnoVNC ; sudo chown -R 103 Downloads
sudo docker build -f evilnovnc.Dockerfile -t evilnovnc .
sudo docker build -f nginx.Dockerfile -t evilnginx .
```

## Cleanup

If you want to remove the automatically built docker images on your system simply run the following commands.

```bash
make clean
```

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

Features added in this project!!
- [X] Dynamic resolution from preload page
- [X] Multiple users
- [X] Basic keylogger
- [X] Replicate real user-agent and other stuff
- [ ] Blacklisting of User Agents
- [ ] Whitelisting of User Agents



# License
This project is licensed under the GNU 3.0 license - see the LICENSE file for more details.


# Credits and Acknowledgments
Original idea by [@mrd0x](https://twitter.com/mrd0x): https://mrd0x.com/bypass-2fa-using-novnc \
The base docker has been created by  Joel Gámez Molina // @JoelGMSec




# Contact
This software does not offer any kind of guarantee. Its use is exclusive for educational environments and / or security audits with the corresponding consent of the client. I am not responsible for its misuse or for any possible damage caused by it.

For more information, you can find me on Twitter as [@gm_eduard](https://twitter.com/gm_eduard/) and on @JoelGMSec blog [darkbyte.net](https://darkbyte.net).

