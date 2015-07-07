# debian-home-folder
My home folder, mainly for the Dell XPS 13 2015

## installation steps

### spotify

Install libcrypt11 from .deb folder

	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt-get update
	sudo apt-get install spotify-client
