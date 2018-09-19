################################################################################################
####### Background process that monitors core/emulator for its start and termination ###########
#######          Image on TFT is displayed only once the core has started            ###########
#######	         and shuts the screen off on process termination to stop             ###########
#######	         possible conflict with EmuStation and BGM resuming.                 ###########
################################################################################################

LOGO_PATH="/usr/local/share/ora-logo"
LOGO_FILE="system/system-$1.png"

	        sudo rmmod fbtft_device

		if [ ! -f "$LOGO_PATH/$LOGO_FILE" ]; then
			LOGO_FILE="emu_logo.png"
		fi
			
		if [[ $2 == reicast* ]]; then
	        	EMU_PROC="reicast"
			elif [[ $2 == ppsspp ]]; then
	        	EMU_PROC="PPSSPPSDL"
	        elif [[ $2 == mupen64plus-* ]]; then
	        	EMU_PROC="mupen64plus"
	        elif [[ $2 == daphne ]]; then
	        	EMU_PROC="daphne.bin"
	        elif [[ $1 == c64 ]]; then
	        	EMU_PROC="x64"
	        elif [[ $1 == vic20 ]]; then
	        	EMU_PROC="xvic"
		elif [[ $2 == yabause* ]]; then
	        	EMU_PROC="yabasanshiro"
		elif [[ $2 == quasi88 ]]; then
	        	EMU_PROC="quasi88.sdl"
	        elif [[ $2 == lr* ]]; then
	        	EMU_PROC="retroarch"
	        elif [[ $2 == openfodder ]]; then
	        	EMU_PROC="OpenFodder"
	        elif [[ $2 == sdlpop ]]; then
	        	EMU_PROC="prince"
	        elif [[ $2 == solarus ]]; then
	        	EMU_PROC="solarus_run"
	    	else
	    		EMU_PROC="$2"
	        fi

	        until pids=$(pidof $EMU_PROC)
	        do
	        	sleep 1
	        done

	        for pid in $pids; do

	        	sleep 1
	        	#### fixes to screen start up timings for certain ports and standalone emulators #####
				if [[ $2 == cannonball ]] && [ `ls -1q /home/pigaming/RetroPie/roms/ports/cannonball | wc -l` -eq 1 ]; then
					sudo modprobe fbtft_device name=hktft9340 busnum=1 rotate=270
					exit 0
				elif [[ $2 == cdogs-sdl ]]; then 
					sleep 1
				elif [[ $2 == alephone ]]; then
					sleep 2
				fi

        		sudo modprobe fbtft_device name=hktft9340 busnum=1 rotate=270 && mplayer -quiet -nolirc -nosound -vo fbdev2:/dev/fb1 -vf scale=320:240 "$LOGO_PATH/$LOGO_FILE" &> /dev/null

	        done


	        while kill -0 "$pids" >/dev/null 2>&1; do
	        	sleep 1
	        done

	        sudo rmmod fbtft_device

	        sleep 1

	        exit 0
