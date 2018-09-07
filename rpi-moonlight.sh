#!/bin/bash

function install_moonlight {
    echo -e "\nPHASE ONE: Add Moonlight to Sources List"
	echo -e "****************************************\n"
		
		if [ "$(lsb_release -cs)" = "stretch" ]; then
			if grep -q "deb http://archive.itimmer.nl/raspbian/moonlight stretch main" /etc/apt/sources.list; then
				echo -e "NOTE: Moonlight Source Exists - Skipping"
			else
				echo -e "Adding Moonlight to Sources List"
				echo "deb http://archive.itimmer.nl/raspbian/moonlight stretch main" >> /etc/apt/sources.list
		fi
		
		elif [ "$(lsb_release -cs)" = "jessie" ]; then
			if grep -q "deb http://archive.itimmer.nl/raspbian/moonlight jessie main" /etc/apt/sources.list; then
				echo -e "NOTE: Moonlight Source Exists - Skipping"
			else
				echo -e "Adding Moonlight to Sources List"
				echo "deb http://archive.itimmer.nl/raspbian/moonlight jessie main" >> /etc/apt/sources.list
			fi
		
		else
			echo -e "Distribution is unsupported"
			sleep 10
			exit 0
		
		fi
		
	echo -e "\n**** PHASE ONE Complete!!!! ****"
	sleep 5

	echo -e "\nPHASE TWO: Fetch and install the GPG key"
	echo -e "****************************************\n"
		
		if [ -f /home/pi/itimmer.gpg ]
		then	
			echo -e "NOTE: GPG Key Exists - Skipping"
		else		
			wget -O http://archive.itimmer.nl/itimmer.gpg /home/pi/itimmer.gpg 
			apt-key add /home/pi/itimmer.gpg	
		fi

	echo -e "\n**** PHASE TWO Complete!!!! ****"
	sleep 5

	echo -e "\nPHASE THREE: Update System & Install Moonlight"
	echo -e "**************************\n"
		apt-get update -y
		apt-get install moonlight-embedded -y
	echo -e "\n**** PHASE THREE Complete!!!! ****"
	sleep 5
		
	echo -e "\nPHASE FOUR: Pair Moonlight with PC"
	echo -e "**********************************\n"
		echo -e "Once you have input your STEAM PC's IP Address below, you will be given a PIN"
		echo -e "Input this on the STEAM PC to pair with Moonlight. \n"
		read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
			sudo -u pi moonlight pair $ip
	echo -e "\n**** PHASE FOUR Complete!!!! ****"
	sleep 5
		
	echo -e "\nPHASE FIVE: Create STEAM Menu for RetroPie"
	echo -e "*****************************************\n"
		
		if [ ! -f /home/pi/.emulationstation/es_systems.cfg ]
		then	
			echo -e "Copying Systems Config File"
			cp /etc/emulationstation/es_systems.cfg /home/pi/.emulationstation/es_systems.cfg
		fi
			
		if grep -q "<platform>steam</platform>" /home/pi/.emulationstation/es_systems.cfg; then
			echo -e "NOTE: Steam Entry Exists - Skipping"
		else
			echo -e "Adding Steam to Systems"
			sudo sed -i -e 's|</systemList>|  <system>\n    <name>steam</name>\n    <fullname>Steam</fullname>\n    <path>~/RetroPie/roms/moonlight</path>\n    <extension>.sh .SH</extension>\n    <command>bash %ROM%</command>\n    <platform>steam</platform>\n    <theme>steam</theme>\n  </system>\n</systemList>|g' /home/pi/.emulationstation/es_systems.cfg
			echo -e "Steam added successfully"
		fi
	echo -e "\n**** PHASE FIVE Complete!!!! ****"
	sleep 5

	echo -e "\nPHASE SIX: Create 1080p & 720p Launch Scripts for RetroPie"
	echo -e "**********************************************************\n"
		
		echo -e "Create Script Folder"
		mkdir -p /home/pi/RetroPie/roms/moonlight
		cd /home/pi/RetroPie/roms/moonlight
		
		echo -e "Create Scripts"
		if [ -f /home/pi/RetroPie/roms/moonlight/720p30fps.sh ]; then
			echo -e "NOTE: 720p30fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 720p30fps.sh
			echo "moonlight stream -720 -fps 30 "$ip"" >> 720p30fps.sh
		fi
		
		if [ -f /home/pi/RetroPie/roms/moonlight/720p60fps.sh ]; then
			echo -e "NOTE: 720p60fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 720p60fps.sh
			echo "moonlight stream -720 -fps 60 "$ip"" >> 720p60fps.sh
		fi
		
		if [ -f /home/pi/RetroPie/roms/moonlight/1080p30fps.sh ]; then
			echo -e "NOTE: 1080p30fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 1080p30fps.sh
			echo "moonlight stream -1080 -fps 30 "$ip"" >> 1080p30fps.sh
		fi
		
		if [ -f /home/pi/RetroPie/roms/moonlight/1080p60fps.sh ]; then
			echo -e "NOTE: 1080p60fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 1080p60fps.sh
			echo "moonlight stream -1080 -fps 60 "$ip"" >> 1080p60fps.sh
		fi
		
		echo -e "Make Scripts Executable"
		chmod +x 720p30fps.sh
		chmod +x 720p60fps.sh
		chmod +x 1080p30fps.sh
		chmod +x 1080p60fps.sh
	echo -e "\n**** PHASE SIX Complete!!!! ****"
	sleep 5

	echo -e "\nPHASE SEVEN: Making Everything PI Again :)"
	echo -e "******************************************\n"
		
		echo -e "Changing File Permissions"
		chown -R pi:pi /home/pi/RetroPie/roms/moonlight/
		chown pi:pi /home/pi/.emulationstation/es_systems.cfg

	echo -e "\n**** PHASE SEVEN Complete!!!! ****\n"
	sleep 5
	clear
		
	echo -e "Everything should now be installed and setup correctly."
	echo -e "To be safe, it's recommended that you perform a reboot now."
	echo -e "\nIf you don't want to reboot now, press N\n"
		
		read -p "Reboot Now (y/n)?" choice
		case "$choice" in 
		  y|Y ) shutdown -r now;;
		  n|N ) echo -e "\nPlease Reboot before using Moonlight Streaming";;
		  * ) echo "Invalid Option";;
		esac
		sleep 5
	clear
}

function 1080p720p_add_launch {
	clear
    echo -e "\nCreate 1080p + 720p Launch Scripts for RetroPie"
	echo -e "***********************************************\n"
		
		if [ ! -d /home/pi/RetroPie/roms/moonlight ]; then
			echo -e "Create Script Folder"
			mkdir -p /home/pi/RetroPie/roms/moonlight
			cd /home/pi/RetroPie/roms/moonlight
		fi
		
		if [ -z $ip ]; then
			read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
		fi
		
		echo -e "Create Scripts"
		if [ -f /home/pi/RetroPie/roms/moonlight/720p30fps.sh ]; then
			echo -e "NOTE: 720p30fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 720p30fps.sh
			echo "moonlight stream -720 -fps 30 "$ip"" >> 720p30fps.sh
		fi
		
		if [ -f /home/pi/RetroPie/roms/moonlight/720p60fps.sh ]; then
			echo -e "NOTE: 720p60fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 720p60fps.sh
			echo "moonlight stream -720 -fps 60 "$ip"" >> 720p60fps.sh
		fi
		
		if [ -f /home/pi/RetroPie/roms/moonlight/1080p30fps.sh ]; then
			echo -e "NOTE: 1080p30fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 1080p30fps.sh
			echo "moonlight stream -1080 -fps 30 "$ip"" >> 1080p30fps.sh
		fi
		
		if [ -f /home/pi/RetroPie/roms/moonlight/1080p60fps.sh ]; then
			echo -e "NOTE: 1080p60fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 1080p60fps.sh
			echo "moonlight stream -1080 -fps 60 "$ip"" >> 1080p60fps.sh
		fi
		
		echo -e "Make Scripts Executable"
		chmod +x 720p30fps.sh
		chmod +x 720p60fps.sh
		chmod +x 1080p30fps.sh
		chmod +x 1080p60fps.sh
		
	echo -e "\n**** 1080p + 720p Launch Scripts Creation Complete!!!! ****"
	sleep 5
}

function 4k_add_launch {
	clear
	echo -e "\nCreate 4k Launch Scripts for RetroPie"
	echo -e "*******************************************\n"
		
		if [ ! -d /home/pi/RetroPie/roms/moonlight ]; then
			echo -e "Create Script Folder"
			mkdir -p /home/pi/RetroPie/roms/moonlight
			cd /home/pi/RetroPie/roms/moonlight
		fi
		
		if [ -z $ip ]; then
			read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
		fi
		
		echo -e "Create 4k Scripts"
		
		if [ -f /home/pi/RetroPie/roms/moonlight/4k30fps.sh ]; then
			echo -e "NOTE: 4k30fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 4k30fps.sh
			echo "moonlight stream -4k -fps 30 "$ip"" >>  4k30fps.sh
		fi
				
		if [ -f /home/pi/RetroPie/roms/moonlight/4k60fps.sh ]; then
			echo -e "NOTE: 4k60fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 4k60fps.sh
			echo "moonlight stream -4k -fps 60 "$ip"" >>  4k60fps.sh
		fi
		
		echo -e "Make 4k Scripts Executable"
		chmod +x 4k30fps.sh
		chmod +x 4k60fps.sh
		
	echo -e "\n**** 4k Launch Scripts Creation Complete!!!!"
	sleep 5
	clear
}

function 480p_add_launch {
	clear
	echo -e "\nCreate 480p Launch Scripts for RetroPie"
	echo -e "*******************************************\n"
		
		if [ ! -d /home/pi/RetroPie/roms/moonlight ]; then
			echo -e "Create Script Folder"
			mkdir -p /home/pi/RetroPie/roms/moonlight
			cd /home/pi/RetroPie/roms/moonlight
		fi
		
		if [ -z $ip ]; then
			read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
		fi
		
		echo -e "Create 480p Scripts"
		
		if [ -f /home/pi/RetroPie/roms/moonlight/480p30fps.sh ]; then
			echo -e "NOTE: 480p30fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 480p30fps.sh
			echo "moonlight stream -width 640 -height 480 -fps 30 "$ip"" >>  480p30fps.sh
		fi
				
		if [ -f /home/pi/RetroPie/roms/moonlight/480p60fps.sh ]; then
			echo -e "NOTE: 480p60fps Exists - Skipping"
		else
			echo "#!/bin/bash" > 480p60fps.sh
			echo "moonlight stream -width 640 -height 480 -fps 60 "$ip"" >>  480p60fps.sh
		fi
		
		echo -e "Make 480p Scripts Executable"
		chmod +x 480p30fps.sh
		chmod +x 480p60fps.sh
		
	echo -e "\n**** 480p Launch Scripts Creation Complete!!!!"
	sleep 5
	clear
}

function remove_launch {
	clear
    echo -e "\nRemove All Steam Launch Scripts"
	echo -e "***********************************\n"
		cd /home/pi/RetroPie/roms/moonlight
		rm *
		
	echo -e "\n**** Launch Script Removal Complete!!! ****"
	sleep 5
	clear
}

function moonlight_pair {
	clear
    echo -e "\nRe-Pair Moonlight with another PC"
	echo -e "*********************************\n"
		
		echo -e "Once you have input your STEAM PC's IP Address below, you will be given a PIN"
		echo -e "Input this on the STEAM PC to pair with Moonlight. \n"
		read -p "Input STEAM PC's IP Address here :`echo $'\n> '`" ip
		sudo -u pi moonlight pair $ip
		
	echo -e "\n**** Re-Pair Process Complete!!!! ****"
	sleep 5
	clear
}

function refresh_config {
	clear
    echo -e "\nRefresh RetroPie Systems File"
	echo -e "*****************************\n"
		
		if [ ! -f /home/pi/.emulationstation/es_systems.cfg ]
		then	
			echo -e "Copying Systems Config File"
			cp /etc/emulationstation/es_systems.cfg /home/pi/.emulationstation/es_systems.cfg
		fi
			
		if grep -q "<platform>steam</platform>" /home/pi/.emulationstation/es_systems.cfg; then
			echo -e "NOTE: Steam Entry Exists - Skipping"
		else
			echo -e "Adding Steam to Systems"
			sudo sed -i -e 's|</systemList>|  <system>\n    <name>steam</name>\n    <fullname>Steam</fullname>\n    <path>~/RetroPie/roms/moonlight</path>\n    <extension>.sh .SH</extension>\n    <command>bash %ROM%</command>\n    <platform>steam</platform>\n    <theme>steam</theme>\n  </system>\n</systemList>|g' /home/pi/.emulationstation/es_systems.cfg
			echo -e "Steam added successfully"
		fi
		
	echo -e "\n**** Refreshing Retropie Systems File Complete!!!! ****"
	sleep 5
	clear
}

function update_script {
	clear
    echo -e "\nUpdate This Script"
	echo -e "*****************************\n"
		
		if [ -f $ScriptLoc ]
		then	
			echo -e "Removing Script"
			rm $ScriptLoc
		fi
		wget https://techwiztime.com/moonlight.sh --no-check
		chown pi:pi $ScriptLoc
		chmod +x $ScriptLoc
		exec $ScriptLoc
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

ScriptLoc=$(readlink -f "$0")
all_done=0
clear
while (( !all_done )); do
    options=("Install Moonlight,Pair,Install Scripts,Install Menus" "Install 1080p & 720p Launch Scripts" "Add 4k Launch Scripts" "Add 480p Launch Scripts" "Remove Launch Scripts" "Re Pair Moonlight with PC" "Refresh SYSTEMS Config File" "Update This Script" "..." "Exit")

    echo "Choose an option: "
    select opt in "${options[@]}"; do
        case $REPLY in
            1) install_moonlight; break ;;
            2) 1080p720p_add_launch; break ;;
			3) 4k_add_launch; break ;;
			4) 480p_add_launch; break ;;
			5) remove_launch; break ;;
			6) moonlight_pair; break ;;
			7) refresh_config; break ;;
			8) update_script; break ;;
			9) break ;;
            10) all_done=1; break ;;
            *) echo "What's that?" ;;
        esac
    done
done

echo "Bye bye!"