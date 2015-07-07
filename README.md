# debian-home-folder
My home folder, mainly for the Dell XPS 13 2015.

## installation steps

### Debian

Netinstall, make USB install disk with unetbootin. Deselect desktop environment.

	su
	aptitude update
	aptitude install sudo
	adduser alj sudo
	exit

### Update kernel (for MST support)

	sudo nano /etc/apt/sources.list
	# copy main deb and change to "sid"
	sudo aptitude update
	apt-get search linux-image
	# find newest kernel version and install, along with headers
	# must be done before installing wireless
	# comment out the added rep again
	sudo aptitude update
	reboot

### Wireless

	sudo nano /etc/apt/sources.list
	# add "contrib" and "non-free" to main rep
	sudo aptitude install broadocom-sta-dkms
	reboot

### settings

	sudo aptitude install git
	git clone https://github.com/alexlangberg/debian-home-folder.git
	# install ubuntu font from .deb folder

### i3

	sudo aptitude install xorg i3 i3status dmenu suckless-tools dunst
	sudo update-alternatives --config dmenu
	# select XFT font support

### utilities
	
	sudo aptitude install wicd-curses terminus transmission xdotool lxappearance redshift pavucontrol thunar thunar-volman thunar-archive-plugin xfce4-screenshooter xfce4-taskmanager

### bluetooth (might cause screen flicker?)
	
	# install binary driver?
	sudo aptitude install blueman

### spotify

Install libcrypt11 from .deb folder, then:

	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt-get update
	sudo apt-get install spotify-client
