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
# -- $Date: 2019/10/25 | $Author: Dück, Thomas
# -- - initial release
# ------------------------------------------
# -- $Date: 2020/01/29 | $Author: Dück, Thomas
# -- - added required commands for quartus pro
# -- - added attached device detection
# ------------------------------------------
# -- $Date: 2020/06/29 | $Author: Dück, Thomas
# -- - changed create_empty_project process - add default pin assignments possible
# ------------------------------------------
# -- $Date: 2021/06/10 | $Author: Dück, Thomas
# -- - added support for muliple SDK porjects to create_qsys and generate_jic_file function
# ------------------------------------------
# -- $Date: 2022/03/17 | $Author: Dück, Thomas
# -- - added ::TE::UTILS::write_board_select to create_empty_project
# ------------------------------------------
# -- $Date: 2022/08/10 | $Author: Dück, Thomas
# -- - add variables for cof file in generate_jic_file function
# ------------------------------------------
# -- $Date: 2022/10/16 | $Author: Dück, Thomas
# -- - add optional arguments to proc detect_devices
# -- - add optional arguments to proc program_dev
# -- - add quartus_hps programmming to proc program_dev
# ------------------------------------------
# -- $Date: 2024/02/05 | $Author: Dück, Thomas
# -- - add option for programming .bin file to program_devv
# --------------------------------------------------------------------
# --------------------------------------------------------------------
namespace eval ::TE {
 namespace eval QUART {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #quartus functions
  # -----------------------------------------------------------------------------------------------------------------------------------------  
  #--------------------------------
  #-- create qsys
  proc create_qsys {qsysname} {  
    ::TE::UTILS::te_msg -type info -id TE_QUART-01 -msg "Create ${qsysname}.qsys. It can take a few minutes, please wait ..."
    # look for correct software project
    tsv::get ::TE::SDK_SRC_LIST ::TK ::TE::SDK_SRC_LIST
    set tmp_sdk_src_name ""
    foreach sdk_src ${::TE::SDK_SRC_LIST} {
      if {[string match *${qsysname}* ${sdk_src}]} { 
        set tmp_sdk_src_name [lindex [split ${sdk_src} "|"] 0] 
      } elseif { ${sdk_src} eq "no_project" } {
        set tmp_sdk_src_name "${sdk_src}"
      }
    }
    set args [string map {" " "\\ "} "${::TE::DEVICE}|${::TE::FAMILY}|${::TE::DDR_DEV}|${tmp_sdk_src_name}"] 
    set command exec 
    lappend command ${::TE::QROOTPATH}sopc_builder/bin/qsys-script${::TE::WIN_EXE}
    lappend command --cmd=set\ ::args\ ${args}
    lappend command --script=${::TE::QPROJ_PATH}/${qsysname}.tcl  
    lappend command --search-path=${::TE::QPROJ_PATH}/ip/**/*,${::TE::SET_PATH}/*,$
    if {${::TE::QEDITION} == "Pro"} {
      lappend command --quartus-project=${::TE::QPROJ_SRC_NAME}
    }
    catch {eval $command} result
    if {[::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-02] == 1} {
      return -code error
    }  
    ::TE::UTILS::te_msg -type info -id TE_QUART-03 -msg "Create ${qsysname}.qsys -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }  
  
  #--------------------------------
  #-- generate qsys
  proc generate_qsys {qsysname} {    
    ::TE::UTILS::te_msg -type info -id TE_QUART-04 -msg "Generate ${qsysname}.qsys. It can take a few minutes, please wait ..."
    set command exec
    lappend command  ${::TE::QROOTPATH}sopc_builder/bin/qsys-generate${::TE::WIN_EXE}
    lappend command ${::TE::QPROJ_PATH}/${qsysname}.qsys
    lappend command --synthesis=verilog
    lappend command -bsf
    lappend command --search-path=${::TE::QPROJ_PATH}/**/*,${::TE::SET_PATH}/*,$
    if {${::TE::QEDITION} == "Pro"} {
      lappend command --quartus-project=${::TE::QPROJ_SRC_NAME}
    }
    catch {eval $command} result
    if {[::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-05] == 1} {
      return -code error
    }
    ::TE::UTILS::te_msg -type info -id TE_QUART-06 -msg "Generate ${qsysname}.qsys -> done"    
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- regenerate IP Cores
  proc regenerate_ip {} {  
    ::TE::UTILS::te_msg -type info -id TE_QUART-07 -msg "Regenerate IP Cores. Please wait ..."
    set command exec
    lappend command mw-regenerate${::TE::WIN_EXE}
    lappend command --project_directory=${::TE::QPROJ_PATH}
    catch {eval $command} result
    if {[::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-08] == 1} {      
      return -code error
    }
    ::TE::UTILS::te_msg -type info -id TE_QUART-09 -msg "Regenerate IP Cores -> done"    
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- generate block symbol file
  proc generate_bsf {} {
    ::TE::UTILS::te_msg -type info -id TE_QUART-10 -msg "Generate block symbol files. Please wait ..."
    set tmppath [pwd]      
    set dir [glob -nocomplain -directory ${::TE::QPROJ_PATH}/ *.vhd *.v *.sv hdl/*.vhd  hdl/*.v hdl/*.sv]
    foreach filedir $dir {
      set path $filedir
      regsub "[file tail $path]" $path "" path
      cd $path
      set command exec
      lappend command quartus_map
      lappend command --generate_symbol=$filedir
      catch {eval $command} result
      if {[::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-11] == 1} {      
        return -code error
      }
    }
    cd $tmppath
    ::TE::UTILS::te_msg -type info -id TE_QUART-12 -msg "Generate block symbol files -> done"    
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- create empty project
  proc create_empty_project {project_name} {
    ::TE::UTILS::te_msg -type info -id TE_QUART-13 -msg "Create empty project. Please wait ..."
    set command "project_new -family \{${::TE::FAMILY}\} -part ${::TE::DEVICE} ${project_name}"
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-36
      cd ../
      return -code error
    }
    if { [ file exists [glob -nocomplain ./*pin_assignments.tcl] ] } {
      source [glob -nocomplain ./*pin_assignments.tcl]
      file delete -force [glob -nocomplain ./*pin_assignments.tcl]
    } else {
      ::TE::UTILS::te_msg -type info -id TE_QUART-41 -msg "Create project without predefined pin assignments."
    }
    project_close 

    if {[catch {eval ::TE::INIT::get_project_names} result]} {::TE::UTILS::te_msg -type error -id TE_QUART-42 -msg "Script (TE::INIT::get_project_names) failed: $result"}
    if {[catch {eval ::TE::UTILS::write_board_select -dir [pwd]} result]} {::TE::UTILS::te_msg -type critical_warning -id TE_QUART-43 -msg "Script (::TE::UTILS::write_board_select) failed: $result"}
    
    ::TE::UTILS::te_msg -type info -id TE_QUART-14 -msg "Create empty project -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- execute <project>.tcl
  proc execute_project_tcl {} {
    ::TE::UTILS::te_msg -type info -id TE_QUART-15 -msg "Execute ${::TE::QPROJ_SRC_NAME}.tcl. It can take a few minutes, please wait ..."
    set command exec
    lappend command quartus_sh${::TE::WIN_EXE}
    lappend command -t
    lappend command ${::TE::QPROJ_PATH}/${::TE::QPROJ_SRC_NAME}.tcl
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-16
      return -code error
    }  
    ::TE::UTILS::te_msg -type info -id TE_QUART-17 -msg "Execute ${::TE::QPROJ_SRC_NAME}.tcl -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }      

  #--------------------------------
  #-- compile project  
  proc compile_project {} {  
    ::TE::UTILS::te_msg -type info -id TE_QUART-18 -msg "Compile project. It can take a few minutes, please wait ..."
    set command exec
    lappend command quartus_sh${::TE::WIN_EXE}
    lappend command --flow
    lappend command compile ${::TE::QPROJ_PATH}/${::TE::QPROJ_SRC_NAME}
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-19
    }  
    ::TE::UTILS::te_msg -type info -id TE_QUART-20 -msg "Compile project -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }    

  #--------------------------------
  #-- generate *.jic file with conversion_setup.cof file
  proc generate_jic_file {} {
    ::TE::UTILS::te_msg -type info -id TE_QUART-25 -msg "Generate ${::TE::QPROJ_SRC_NAME}.jic file. Please wait ..."

    set fpr [open "${::TE::QPROJ_PATH}/conv_setup.cof" r]
    set filedata [read $fpr]
    set file_data [split $filedata "\n"]
    close $fpr
    set fpw [open "${::TE::QPROJ_PATH}/conv_setup.cof" w]
    foreach line $file_data {
      # set software name in cof file
      regsub -all "SDK_NAME" $line "${::TE::SDK_SRC_NAME}" line
      # set project name in cof file
      regsub -all "PROJ_NAME" $line "${::TE::QPROJ_SRC_NAME}" line 
      # set flash type in cof file
      if { ${::TE::FLASHTYP} eq "W25Q64JV" } {
        regsub -all "FLASHTYP" $line "EPCQ64A" line
      } else {
        regsub -all "FLASHTYP" $line "${::TE::FLASHTYP}" line
      }
      # set fpga device in cof file
      regsub -all "DEVICE" $line "${::TE::DEVICE}" line    
      puts $fpw $line    
    }
    close $fpw
    
    set command exec
    lappend command quartus_cpf${::TE::WIN_EXE}
    lappend command -c
    lappend command ${::TE::QPROJ_PATH}/conv_setup.cof
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-26
    }    
    ::TE::UTILS::te_msg -type info -id TE_QUART-27 -msg "Generate ${::TE::QPROJ_SRC_NAME}.jic file. -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- open quartus programmer
  proc start_programmer_gui {} {
    ::TE::UTILS::te_msg -type info -id TE_QUART-28 -msg "Start Programmer GUI. Please wait ..."
    set command exec
    lappend command quartus_pgmw${::TE::WIN_EXE}
    ::TE::UTILS::te_msg -type info -id TE_QUART-29 -msg "Programmer GUI opened. Please change to GUI."
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-30
    }
    ::TE::UTILS::te_msg -type info -id TE_QUART-31 -msg "Programmer GUI closed."
    ::TE::UTILS::te_msg -msg "------------------------------"
  }

  #--------------------------------
  #-- detect attached devices
  proc detect_devices {{args ""}} {
    set SILENT ""
    set tmpsilent ""
    set num [llength $args]
    for {set option 0} {$option < $num} {incr option} {
      switch [lindex $args $option] {
        "-silent" { set SILENT "-silent" }
        ""        {}
        default   { ::TE::UTILS::te_msg -type error -id TE_QUART-37 -msg "Unrecognised argument: detect_devices [lindex $args $option]."
                    ::TE::UTILS::te_msg -msg "Expected arguments: detect_devices \[options\]"
                    ::TE::UTILS::te_msg -msg "     Options:"
                    ::TE::UTILS::te_msg -msg "          -silent"
                    return
                  }
      }
    }
  
    set command exec
    lappend command quartus_pgm${::TE::WIN_EXE}
    lappend command --auto
    [catch {eval $command} result]
    if {[::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-38 -silent]} {
      return "error"
    }
    
    set devinfo [list]
    foreach line [split $result "\n"] {
      if {![string match -nocase *info* $line]} {
        if {[string match -nocase *Arrow-USB-Blaster* $line]} {
          regexp -nocase {(.*)\) Arrow-USB-Blaster(.*)} $line matched devnum
        } else {
          #regexp -nocase {(\w+)(.*)(\w+)(.*)} $line match deviceid device
          set tmplist [split $line " "]
          foreach tmpline $tmplist {
            if {![string match "" $tmpline]} {
              lappend devinfo $tmpline
            }
          }
        }
        ::TE::UTILS::te_msg -type info -msg "     $line" $SILENT
      }      
    }
    if {$devnum > 1} {
      ::TE::UTILS::te_msg -type error -id TE_QUART-39 -msg "Detected more than one device. Connect only one device via USB."
      return "error"
    } else {
      return "[lindex $devinfo 0]|[lindex $devinfo 1]"
    }
  }
  
  #--------------------------------
  #-- progam device with *.sof, *.pof or *.jic file
  proc program_dev {{args ""}} {
    set FILEDIR "NA"
    set ERASE false
    set tmpmsg "Program"
    set SILENT ""
    set num [llength $args]
    
    for {set option 0} {$option < $num} {incr option} {
      switch [lindex $args $option] {
        "-filedir"  { set FILEDIR   [lindex $args $option+1]; incr option; }  
        "-erase"    { set ERASE   true; set tmpmsg "Erase";  }
        "-silent"   { set SILENT   "-silent"           }
        ""          {}
        default     { ::TE::UTILS::te_msg -type error -id TE_QUART-44 -msg "Unrecognised argument: program_dev [lindex $args $option]."
                      ::TE::UTILS::te_msg -msg "Expected arguments: program_dev -filedir \"<path/to/programming/file>\" \[options\]"
                      ::TE::UTILS::te_msg -msg "     Options:"
                      ::TE::UTILS::te_msg -msg "          -erase"
                      ::TE::UTILS::te_msg -msg "          -silent"
                      return
                    }
      }
    }
    
    [catch {eval ::TE::QUART::detect_devices $SILENT} result]
    if { $result eq "error" } {
      return -code error "$tmpmsg device failed."
    } else {
      set linetmp [split $result "|"]
      set devid [lindex $linetmp 0]
      set dev [lindex $linetmp 1]
    }
    
    # search for sdk bin file in prebuilt or _binaries_ folder
    set pgm_flash_bin ""
    if {[string match */prebuilt/* $FILEDIR]} { 
      set pgm_flash_bin [ ::TE::UTILS::findFiles [file dirname [file dirname $FILEDIR]]/software/ "*.bin" ]
    } elseif {[string match *_binaries_* $FILEDIR]} {
      set pgm_flash_bin [ ::TE::UTILS::findFiles [file dirname $FILEDIR] "*.bin" ]
    }
    if {$pgm_flash_bin ne ""} { ::TE::SDK::write_flash_memory $pgm_flash_bin $ERASE $SILENT }
    
    ::TE::UTILS::te_msg -type info -id TE_QUART-32 -msg "$tmpmsg device ([file tail $FILEDIR]). Please wait ..."
    
    if {[string match *.jic $FILEDIR]} {
      if { $ERASE } { set operation "ri" } else { set operation "pvi" }
    } elseif {[string match *.pof $FILEDIR]} {
      if { $ERASE } { set operation "r" } else { set operation "pvb" }
    } elseif {[string match *.sof $FILEDIR]} {
      if { $ERASE } {
        #TODO: Fehlermeldung ausgeben
      } else { set operation "p" }
    } elseif {[string match *.sfp $FILEDIR]} {
      if { $ERASE } { set operation "e" } else { set operation "p" }
    }
    
    set command exec
    if {[string match *HPS $dev]} {
      lappend command quartus_hps${::TE::WIN_EXE}
      lappend command --cable=Arrow-USB-Blaster
      lappend command --addr=0x0
      lappend command --operation=$operation
      lappend command $FILEDIR
    } else {
      lappend command quartus_pgm${::TE::WIN_EXE}
      lappend command --cable Arrow-USB-Blaster
      lappend command --mode jtag
      lappend command --operation "$operation;$FILEDIR"
    }
    
    [catch {eval $command} result]
    if {[::TE::UTILS::report -msg $result -command $command -msgid TE_QUART-33 $SILENT]} {
      return -code error "$tmpmsg device failed."
    }
    ::TE::UTILS::te_msg -type info -id TE_QUART-40 -msg "$tmpmsg device finished"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
 }  
  ::TE::UTILS::te_msg -type info -msg "(TE) Load Quartus script finished"
}