# debian-home-folder
My home folder, mainly for the Dell XPS 13 2015

## installation steps

### Debian

Netinstall, make USB install disk with unetbootin. Deselect desktop environment.

	su
	aptitude update
	aptitude install sudo
	adduser alj sudo
	exit

### settings

	sudo aptitude install git
	git clone https://github.com/alexlangberg/debian-home-folder.git

### i3

	sudo aptitude install i3 i3status dmenu suckless-tools

### spotify

Install libcrypt11 from .deb folder, then:

	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt-get update
	sudo apt-get install spotify-client

### ubuntu font

Install from .deb folder.
