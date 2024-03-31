build:
	sudo chown -R 103 Downloads
	sudo docker build -f evilnovnc.Dockerfile -t evilnovnc .
	sudo docker build -f nginx.Dockerfile -t evilnginx .
clean:
	sudo docker rmi evilnovnc
	sudo docker rmi evilnginx