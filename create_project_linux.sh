#!/bin/bash

# # --------------------------------------------------------------------
# # --   *****************************
# # --   *   Trenz Electronic GmbH   *
# # --   *   Beendorfer Straße 23    *
# # --   *   32609 Hüllhorst         *
# # --   *   Germany                 *
# # --   *****************************
# # --------------------------------------------------------------------
# # --$Autor: Dück, Thomas $
# # --$Email: t.dueck@trenz-electronic.de $
# # --$Create Date: 2020/02/07 $
# # --$Modify Date: 2020/03/31 $
# # --$Version: 1.1 $
# #		-- check quartus installation path and version
# #		-- modify design_basic_settings.tcl
# # --$Version: 1.0 $
# #		-- initial release
# # --------------------------------------------------------------------
# # --------------------------------------------------------------------
echo "----------------------- Set design paths ---------------------------"
# get paths
bashfile_name=${0##*/}
bashfile_path=`dirname $0`
cd $bashfile_path
	
echo "-- Run Design with: ${bashfile_name}"
echo "-- Use Design Path: ${bashfile_path}"
echo "--------------------------------------------------------------------"

echo "--------------------- Load basic design settings --------------------"
# remove carriage return from file
sed $'s/\r//' -i ./settings/design_basic_settings.tcl
# read and export variables from file
while read -r val
do
	eval $val
done < <(grep -v '^#' ./settings/design_basic_settings.tcl)
check_new_path=$QUARTUS_PATH_LINUX

# init
function pause(){
	read -p "$*"
}

function te_env(){
	echo "------------------- Check quartus environment ----------------------"
	# check quartus intallation path
	while !  [ -e "$check_new_path" ]
	do
		echo "'$check_new_path' does not exist."
		specifiy_basic_settings_path
	done

	# check quartus version
	while !  [ -e "$check_new_path/$QUARTUS_VERSION" ]
	do
		ask_basic_settings_path
	done
	
	# write new_path to design_basig_settings.tcl
	if [ "$check_new_path" != "$QUARTUS_PATH_LINUX" ] 
	then
		write_basic_settings
		eval QUARTUS_PATH_LINUX=$new_path
	fi
	
	echo "-- Use Quartus installation from '$QUARTUS_PATH_LINUX' --"
	echo "-- Use Quartus Version: $QUARTUS_VERSION $QUARTUS_EDITION --"
	quartus_run
	echo "--------------------------------------------------------------------"
}

function specifiy_basic_settings_path(){
	# spedify quartus installation path
	echo "Please specifiy your Quartus installation folder path (e.g. ~/intelFPGA_pro):"                                      
	read new_path	
	eval check_new_path=$new_path
}

function ask_basic_settings_path(){
	echo "Quartus Version '$QUARTUS_VERSION $QUARTUS_EDITION' not found in quartus installation path '$check_new_path'."
	echo "Wrong specified quartus installation path? (y/n)"                                      
	read answer
	if [ $answer == y ] || [ $answer == Y ]
	then
		specifiy_basic_settings_path
		while !  [ -e "$check_new_path" ]
		do
			echo "'$check_new_path' does not exist."
			specifiy_basic_settings_path
		done
	else
		echo "Install Quartus Prime $QUARTUS_VERSION $QUARTUS_EDITION in Quartus installation path '$check_new_path'."
		echo "For manual configuration of design basic settings go to https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices#ProjectDelivery-Inteldevices-Reference-Design:GettingStarted ."
		te_last
	fi
}

function write_basic_settings(){
	# write new_path to file
	while read -r line
	do	
		if [[ $line = QUARTUS_PATH_LINUX=* ]]
		then 
			echo "QUARTUS_PATH_LINUX=$new_path" >> ./settings/temp.tcl
		else
			echo "$line" >> ./settings/temp.tcl
		fi	
	done < ./settings/design_basic_settings.tcl
	rm ./settings/design_basic_settings.tcl
	mv ./settings/temp.tcl ./settings/design_basic_settings.tcl
}

function quartus_run(){
	echo "----------------------- Create log folder --------------------------"
	# log folder
	log_folder=$bashfile_path/log
	echo "${log_folder}"
	if [ ! -f "$log_folder" ]; then
		mkdir $log_folder 
	fi
	echo "--------------------------------------------------------------------"
	echo "------------------------ Start Quartus scripts ---------------------"
	# search path for perl lib is missing in quartus 19.1 for linux
	if [ $QUARTUS_VERSION == 19.1 ]; then
		echo "export PERL5LIB=$QUARTUS_PATH_LINUX/$QUARTUS_VERSION/quartus/linux64/perl/lib/5.28.1"
		export PERL5LIB=$QUARTUS_PATH_LINUX/$QUARTUS_VERSION/quartus/linux64/perl/lib/5.28.1
	fi
	
	$QUARTUS_PATH_LINUX/$QUARTUS_VERSION/quartus/bin/quartus_sh -t $bashfile_path/scripts/script_main.tcl --run_tk_gui
	
	echo "------------------------ Scripts finished --------------------------"
	echo "--------------------------------------------------------------------"
	echo "------------------- Change to design folder ------------------------"
	cd ..
	echo "----------------------- Design finished ----------------------------"
	exit
}
  
function te_last(){
	echo "--------------------------------------------------------------------"
	pause 'Press [Enter] key to continue ...'
	exit 1
}

te_env
