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
	# add "contrib" and "non-free" to main rep
	# copy main deb and change to "sid"
	sudo aptitude update
	apt-get search linux-image
	# find newest kernel version and install, along with headers and install them
	# now install wireless
	sudo aptitude install broadcom-sta-dkms
	# comment out the added rep again
	sudo aptitude update
	sudo reboot

### wicd-curses
	sudo aptitude install wicd-curses
	# find wireless adapter, e.g. wlan0
	sudo iwconfig
	# turn on wireless adapter
	sudo ifconfig wlan0 up
	# start wicd-curses, go to settings and set wlan0 as the wireless adapter

### i3

	sudo aptitude install xorg i3 i3status dmenu suckless-tools dunst
	sudo update-alternatives --config dmenu
	# select XFT font support
	
### settings

	sudo aptitude install git
	git clone https://github.com/alexlangberg/debian-home-folder.git
	# install ubuntu font from .deb folder

### bluetooth (might cause screen flicker?)
	
	# copy BCM20702A0-0a5c-216f.hcd to /lib/firmware/brcm/
	sudo reboot
	sudo aptitude install blueman

### utilities
	
	sudo aptitude install terminus transmission xdotool lxappearance redshift pavucontrol thunar thunar-volman thunar-archive-plugin xfce4-screenshooter xfce4-taskmanager

### spotify

Install libcrypt11 from .deb folder, then:

	sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys D2C19886
	echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt-get update
	sudo apt-get install spotify-client
