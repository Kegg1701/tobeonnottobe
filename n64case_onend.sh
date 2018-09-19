LOGO_PATH="/usr/local/share/ora-logo"

### Quick check to see if screen is off, turn it back on and play ORA logo #######

if [[ $(/sys/class/graphics/fb1/name) != "fb_ili9340" ]]; then
	sudo modprobe fbtft_device name=hktft9340 busnum=1 rotate=270
fi

sudo mplayer -quiet -nolirc -nosound -vo fbdev2:/dev/fb1 -vf scale=320:240 "$LOGO_PATH/N64_logo.gif" &> /dev/null

	




