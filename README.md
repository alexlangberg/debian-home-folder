# debian-home-folder
My home folder, mainly for the Dell XPS 13 2015

## installation steps

### spotify

	1. Install libcrypt11 from .deb folder
	2. sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
	3. echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	4. sudo apt-get update
	5. sudo apt-get install spotify-client
