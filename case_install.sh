#!/usr/bin/env bash

mkdir n64ORA_tmp && cd n64ORA_tmp

sudo apt update && sudo apt install -y fbset ffmpeg mali-fbdev &&

if ! `grep -q 'spi_s3c64xx'  "/etc/modules"`; then
	sudo sed -i '5i spi_s3c64xx' /etc/modules 
fi

if ! `grep -q 'spidev'  "/etc/modules"`; then
	sudo sed -i '5i spidev' /etc/modules 
fi

if ! `grep -q 'fbtft_device'  "/etc/modules"`; then
	sudo sed -i '7i fbtft_device' /etc/modules
fi

sudo modprobe -r spidev 

sudo modprobe spi_s3c64xx force32b=1 && sudo modprobe fbtft_device name=hktft9340 busnum=1 rotate=270 &&

svn checkout https://github.com/Kegg1701/tobeonnottobe.git && sudo cp -R tobeonnottobe.git/trunk/ora-logo /usr/local/share/ &&

sudo mplayer -nolirc -nosound -vo fbdev2:/dev/fb1 -vf scale=320:240 /usr/local/share/ora-logo/N64_logo.gif &> /dev/null

## Only uncomment and run script again if on latest Kernel and full dist upgrade. ###

#if [[ `uname -r` != "3.10.105-141" ]]; then
	#if [ ! -f "/etc/modprobe.d/fbtft.conf" ]; then
	#	sudo touch /etc/modprobe.d/fbtft.conf && sudo chown pigaming:pigaming /etc/modprobe.d/fbtft.conf
	#	sudo echo "options spi_s3c64xx force32b=1" > /etc/modprobe.d/fbtft.conf
	#	sudo echo "options fbtft_device name=hktft9340 busnum=1 rotate=270 force32b=1" >> /etc/modprobe.d/fbtft.conf
	#fi
#fi

cd tobeonnottobe.git/trunk/

## install/update n64case scripts

CONFALL="/opt/retropie/configs/all"
sudo cp n64* $CONFALL && sudo chmod +x $CONFALL/n64case_* #onend.sh && sudo chmod +x $CONFALL/n64case_onstart.sh
echo -e "\e[92mcase scripts installed"

## patch the runcommand-onend.sh

R_ONEND="/opt/retropie/configs/all/n64case_onend.sh &"

if ! `grep -q "$R_ONEND"  "/opt/retropie/configs/all/runcommand-onend.sh"`; then
	sudo echo -e "\n\nsleep 1\n$R_ONEND" >> /opt/retropie/configs/all/runcommand-onend.sh
	echo -e "\e[93mruncommand-onend patched"
fi

## Patch both default and used runcommand.sh

RUNCM="/opt/retropie/supplementary/runcommand"
DEF_RUNCM="/home/pigaming/RetroPie-Setup/scriptmodules/supplementary/runcommand"

if ! `grep -q 'user_script "n64case_onstart.sh" &'  "$RUNCM/runcommand.sh"`; then
	sudo mv -f $RUNCM/runcommand.sh $RUNCM/runcommand.bak && sudo tac $RUNCM/runcommand.bak | awk '!p && /local ret/{print "    user_script \"n64case_onstart.sh\" &"; p=1} 1' | tac > $RUNCM/runcommand.sh
	sudo chmod +x "$RUNCM/runcommand.sh" && sudo chown pigaming:root "$RUNCM/runcommand.sh"
	echo -e "\e[93mruncommand.sh patched"
fi

if ! `grep -q 'user_script "n64case_onstart.sh" &'  "$DEF_RUNCM/runcommand.sh"`; then
	mv -f $DEF_RUNCM/runcommand.sh $DEF_RUNCM/runcommand.bak && tac $DEF_RUNCM/runcommand.bak | awk '!p && /local ret/{print "    user_script \"n64case_onstart.sh\" &"; p=1} 1' | tac > $DEF_RUNCM/runcommand.sh
	sudo chmod +x "$DEF_RUNCM/runcommand.sh" && sudo chown pigaming:pigaming "$DEF_RUNCM/runcommand.sh"
	echo -e "\e[93mdef runcommand.sh patched"
fi

## Patch rc.local

if ! `grep -q 'modprobe spi_s3c64xx force32b=1'  "/etc/rc.local"`; then
	sudo sed -i -e '$i \\nmodprobe spi_s3c64xx force32b=1\nmodprobe fbtft_device name=hktft9340 busnum=1 rotate=270\nmplayer -nolirc -vo fbdev2:/dev/fb1 /usr/local/share/ora-logo/N64_logo.gif -x 320 -y 240 -zoom\n' /etc/rc.local
	echo -e "\e[93mrc.local patched"
fi

## Patch autostart for no HDMI cable
if ! `grep -q 'no_hdmi.png' "/opt/retropie/configs/all/autostart.sh"`; then
	sudo sed -i -e 's/^emulationstation.*/\n\nif \[ -e \/dev\/fb1 \];  then\n    emulationstation #auto\nelif \[ -e \/dev\/fb0 \] \&\& \[\[ `cat \/sys\/class\/graphics\/fb0\/name` != fb_ili9340 \]\]; then\n    emulationstation #auto\nelse\n    sudo fbi -d \/dev\/fb0 -T 1 -noverbose -a \/usr\/local\/share\/ora-logo\/no_hdmi.png\nfi/g' /opt/retropie/configs/all/autostart.sh
	sudo chown pigaming:pigaming /opt/retropie/configs/all/autostart.sh
	echo -e "\e[93mautostart.sh patched"
fi

cd ~/ && rm -rf n64ORA_tmp

echo -e "\e[92mall done... enjoy"

exit 0
