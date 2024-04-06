build:
	sudo docker build -f evilnovnc.Dockerfile -t evilnovnc .
	sudo docker build -f nginx.Dockerfile -t evilnginx .
	sudo mkdir -p Downloads && sudo chown -R 103 Downloads > /dev/null
clean:
	sudo docker rmi evilnovnc
	sudo docker rmi evilnginx