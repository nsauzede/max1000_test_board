# --------------------------------------------------------------------
# --   *****************************
# --   *   Trenz Electronic GmbH   *
# --   *   Beendorfer Straße 23    *
# --   *   32609 Hüllhorst         *
# --   *   Germany                 *
# --   *****************************
# --------------------------------------------------------------------
# -- $Author: Dück, Thomas $
# -- $Email: t.dueck@trenz-electronic.de $
# --------------------------------------------------------------------
# -- Change History:
# ------------------------------------------
# -- $Date: 2022/01/20 | $Author: Dück, Thomas
# -- - initial release
# ------------------------------------------
# --------------------------------------------------------------------
# --------------------------------------------------------------------
namespace eval ::TE {
 namespace eval OS {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #quartus functions
  # -----------------------------------------------------------------------------------------------------------------------------------------  
  #--------------------------------
  #-- copy yocto bsp layer to basefolder/os/yocto
  proc copy_yocto_bsp_layer {} {
    ::TE::UTILS::te_msg -type info -id TE_OS-01 -msg "Copy ${::TE::YOCTO_SRC_BSP_LAYER_NAME} to ${::TE::YOCTO_PATH}"
    file mkdir ${::TE::YOCTO_PATH}
    if { [catch { file copy -force ${::TE::YOCTO_SOURCE_PATH}/${::TE::YOCTO_SRC_BSP_LAYER_NAME} ${::TE::YOCTO_PATH} } result] } {
      ::TE::UTILS::te_msg -type error -id TE_OS-02 -msg "Error on copying ${::TE::YOCTO_SOURCE_PATH}/${::TE::YOCTO_SRC_BSP_LAYER_NAME}: $result"
    } else {
      ::TE::UTILS::te_msg -type info -id TE_OS-03 -msg "Copy ${::TE::YOCTO_SRC_BSP_LAYER_NAME} -> done"
      ::TE::UTILS::te_msg -msg "------------------------------"
    }    
  }  
  
  #--------------------------------
  #-- copy rbf programming file to yocto bsp layer
  proc copy_rbf_to_yocto_bsp_layer {} {
    ::TE::UTILS::te_msg -type info -id TE_OS-04 -msg "Copy ${::TE::QPROJ_NAME}.rbf to ${::TE::YOCTO_SRC_BSP_LAYER_NAME}"
    # search for rbf file in quartus project
    set rbf_file [glob -nocomplain -tail -directory ${::TE::QPROJ_PATH}/output_files/ *.rbf]
    # copy rbf file
    if { [catch { file copy -force  ${::TE::QPROJ_PATH}/output_files/${rbf_file} ${::TE::YOCTO_PATH}/${::TE::YOCTO_SRC_BSP_LAYER_NAME}/recipes-bsp/rbf/files } result]} {
      ::TE::UTILS::te_msg -type error -id TE_OS-16 -msg "Error on copying ${rbf_file}: $result"
    # rename rbf file
    } elseif { [catch { file rename -force ${::TE::YOCTO_PATH}/${::TE::YOCTO_SRC_BSP_LAYER_NAME}/recipes-bsp/rbf/files/${rbf_file} ${::TE::YOCTO_PATH}/${::TE::YOCTO_SRC_BSP_LAYER_NAME}/recipes-bsp/rbf/files/soc_system.rbf } result] } {
      ::TE::UTILS::te_msg -type error -id TE_OS-05 -msg "Error on rename ${::TE::YOCTO_PATH}/${::TE::YOCTO_SRC_BSP_LAYER_NAME}/recipes-bsp/rbf/files/${rbf_file}: $result"
    } else {
      ::TE::UTILS::te_msg -type info -id TE_OS-06 -msg "Copy and rename ${::TE::QPROJ_NAME}.rbf -> done"    
      ::TE::UTILS::te_msg -msg "------------------------------"
    }
  }
  
  #--------------------------------
  #-- convert the handoff data into source code
  proc convert_handoff_data {} {
    ::TE::UTILS::te_msg -type info -id TE_OS-07 -msg "Convert handoff data into source code."
    if { [file exist ${::TE::QUARTUS_INSTALLATION_PATH}/embedded/embedded_command_shell.sh] } {
      # search for qsys handoff files path
      set handoff_path [glob -nocomplain -directory ${::TE::QPROJ_PATH}/hps_isw_handoff/ *]
      # set variable command and run bsp-create-settings
      set command "exec [subst ${::TE::EMBEDDED_COMMAND_SHELL_PATH}]"
      lappend command bsp-create-settings${::TE::WIN_EXE}
      lappend command --type spl
      lappend command --bsp-dir ${::TE::QPROJ_PATH}/bootloader
      lappend command --preloader-settings-dir ${handoff_path}
      lappend command --settings ${::TE::QPROJ_PATH}/bootloader/settings.bsp
      
      if {[catch {eval $command} result]} {
        ::TE::UTILS::te_msg -type error -id TE_OS-08 -msg "Error on command: ${command}" 
        ::TE::UTILS::report -msg $result -command $command -msgid TE_OS-09
      }
    
      ::TE::UTILS::te_msg -type info -id TE_OS-10 -msg "Convert handoff data into source code -> done"    
      ::TE::UTILS::te_msg -msg "------------------------------"
    } else {
      ::TE::UTILS::te_msg -type error -id TE_OS-11 -msg "Error on command: ${command}: ${result}\n Intel SoC FPGA Embedded Development Suite 20.1 is not installed to ${::TE::QUARTUS_INSTALLATION_PATH}"
    }
  }
  
  #--------------------------------
  #-- format converted handoff data appropriately and copy them to the U-Boot source code
  proc run_qts_filter {} {  
    ::TE::UTILS::te_msg -type info -id TE_OS-12 -msg "Run qts-filter "
    # change work directory
    set tmpdir [pwd]
    cd ${::TE::QPROJ_PATH}
    
    if { ${::TE::FAMILY} eq "Cyclone V"} {
      set tmpfamily  cyclone5
    } elseif { ${::TE::FAMILY} eq "Arria V"} {
      set tmpfamily  arria5
    }
    
    # set variable command and run qts-filter
    set command "exec bash"
    lappend command ./qts-filter.sh
    lappend command ${tmpfamily}
    lappend command ./
    lappend command ./bootloader/
    lappend command ../os/yocto/${::TE::YOCTO_SRC_BSP_LAYER_NAME}/recipes-bsp/u-boot/files/qts/
    
    if {[catch {eval $command} result]} {
      ::TE::UTILS::te_msg -type error -id TE_OS-13 -msg "Error on command: ${command}" 
      ::TE::UTILS::report -msg $result -command $command -msgid TE_OS-14
    }
    
    # chnage to old work directory
    cd ${tmpdir}
      
    ::TE::UTILS::te_msg -type info -id TE_OS-15 -msg "Run qts-filter -> done"    
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  

 }  
  ::TE::UTILS::te_msg -type info -msg "(TE) Load OS script finished"
}