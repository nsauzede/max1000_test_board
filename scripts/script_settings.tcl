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
# -- $Date: 2020/01/28 | $Author: Dück, Thomas
# -- - add proc init_qversion for lite edition and pro edition support
# -- - reintialise source files path depending on board revision
# ------------------------------------------
# -- $Date: 2020/04/09 | $Author: Dück, Thomas
# -- - add proc init_thread_variables
# ------------------------------------------
# -- $Date: 2021/06/10 | $Author: Dück, Thomas
# -- - changed get_project_names function for multiple SDK projects support
# ------------------------------------------
# -- $Date: 2022/01/24 | $Author: Dück, Thomas
# -- - add os/yocto variables
# ------------------------------------------
# -- $Date: 2022/03/17 | $Author: Dück, Thomas
# -- - add QUART_PROG
# ------------------------------------------
# -- $Date: 2022/08/10 | $Author: Dück, Thomas
# -- - add PGM_FLASH_XML variable
# ------------------------------------------
# -- $Date: 2022/09/16 | $Author: Dück, Thomas
# -- - add variables for serial console
# -- - add 'silent' option to proc init_board
# -- - add new namespace PROD
# -- - add new function proc init_prod_tcl
# ------------------------------------------
# -- $Date: 2023/06/02 | $Author: Dück, Thomas
# -- - bugfixes in proc get_project_names {}
# ------------------------------------------
# -- $Date: 2023/09/08 | $Author: Dück, Thomas
# -- - add variables for niosv and cpu parameter
# --------------------------------------------------------------------
# --------------------------------------------------------------------
namespace eval ::TE {

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # TE variable declaration
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  # names
  variable QPROJ_NAME
  variable QPROJ_SRC_NAME
  variable QSYS_NAME
  variable QSYS_SRC_NAME
  variable QSYS_SOPC_FILE_NAME
  variable SDK_NAME
  variable SDK_SRC_NAME "no_project"
  variable YOCTO_BSP_LAYER_NAME "NA"
  variable YOCTO_SRC_BSP_LAYER_NAME "NA"
  variable ZIP_IGNORE_LIST [list]

  # project path
  variable BASEFOLDER 
  variable QPROJ_PATH   
  variable BOARDDEF_PATH
  variable SOURCE_PATH
  variable OS_PATH
  variable YOCTO_PATH
  variable YOCTO_SOURCE_PATH
  variable QPROJ_SOURCE_PATH
  variable SDK_SOURCE_PATH
  variable SDK_PATH
  variable LOG_PATH   
  variable BACKUP_PATH
  variable SET_PATH
  variable EMBEDDED_COMMAND_SHELL_PATH
  variable NIOS2_COMMAND_SHELL_PATH
  variable NIOSV_BIN_PATH
  variable PREBUILT_PATH
  variable QROOTDIR
  
  # board files
  variable ID           "NA"
  variable LAST_ID      "NA"
  variable PRODID       "NA"
  variable FAMILY       "NA"
  variable DEVICE       "NA"
  variable SHORTNAME    "NA"
  variable FLASHTYP     "NA"
  variable FLASH_SIZE   "NA"
  variable DDR_DEV      "NA"
  variable DDR_SIZE     "NA"
  variable PCB_REV      "NA"
  variable NOTES        "NA"
  variable GENERAL_INFO "NA"


  # board files csv data
  variable BOARD_DEFINITION "NA"
  variable DEV_CSV_FILE_DIR ""
  
  # lists
  variable MOD_LIST           [list]  
  variable BOARDDEF_SRC_LIST  [list]  
  variable QPROJ_SRC_LIST     [list]  
  
  # OS selection- filetypes 
  variable WIN_EXE ""
  
  # version
  variable SCRIPTVER      "22.0"
  variable BOARDDEF_CSV   "1.1"
  variable ZIP_IGNORE_CSV "1.2"
  variable ZIPINFO_CSV    "1.0"
  variable MODLIST_CSV    "1.3"
  variable APPSLIST_CSV   "1.1"
  variable PGM_FLASH_XML  "2"
  variable PROD_CFG_CSV   "1.1"
  variable QVERSION       "NA"
  variable QEDITION       "NA"
  variable SUPPORTED_VER  "NA"
  variable SUPPORTED_EDI  "NA"
  
  variable WSL_EN     0
  variable QUART_PROG 0
  
  # thread 
  variable MAINTHREAD         [thread::id]
  variable ::TE::THREAD_TK_ID "tid0"
  
  # serial
  variable DESIGN_UART_COM    NA
  variable DESIGN_UART_SPEED  115200
  variable SERIAL_PATH
  variable COM_PATH 
  variable COM_IGNORE_LIST    [list]
  
  # qsys cpu 
  variable QSYS_CPU_NAME
  variable QSYS_CPU_VARIANT
  variable QSYS_CPU_RESETSLAVE_BASEADDR
  variable QSYS_CPU_RESETSLAVE_ENDADDR
  variable QSYS_CPU_RESETADDR
  variable QSYS_CPU_RESETSLAVE

  # -----------------------------------
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished TE variables declaration
  # -----------------------------------------------------------------------------------------------------------------------------------------
    
  # -----------------------------------------------------------------------------------------------------------------------------------------
 namespace eval INIT {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # initial functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------  
  #-- init_env:  
  proc init_env {} {
    # check quartus version
    regexp -nocase -line {(\w+)\.(\w+).(\w+)} $::quartus(version) ::TE::QVERSION    
    regexp -nocase {(\w+) Edition} $::quartus(version) matched ::TE::QEDITION
    
    # check used platform
    if {$::tcl_platform(platform) eq "windows"} {
      set ::TE::WIN_EXE ".exe"
    } else {
      set ::TE::WIN_EXE ""
    }
    ::TE::UTILS::te_msg -type info -id TE_INIT-17 -msg "Used platform: $::tcl_platform(platform)"
    
    # check if wsl is installed
    if {$::tcl_platform(platform) eq "windows"} {
      set command exec 
      lappend command wsl 
      lappend command -l
      lappend command -v
      catch {eval $command} result
      set encresult [split [encoding convertfrom unicode $result] "\n"]
      
      if {[string match -nocase "*no such file or directory*" $result]} {
        set ::TE::WSL_EN 0
        ::TE::UTILS::report -msg "Critical Warning: $result" -command $command -msgid TE_INIT-18
      } elseif {[string match -nocase "*distribution*" $encresult]} {
        set ::TE::WSL_EN 1
        ::TE::UTILS::report -msg "Critical Warning: [lindex $encresult 0]" -command $command -msgid TE_INIT-19
      } else {
        set ::TE::WSL_EN 2  
        ::TE::UTILS::te_msg -type info -id TE_INIT-20 -msg "Used linux distribution for WSL:\n     [lindex $encresult 0]\n     [lindex $encresult 2]"  
      }
    }
  } 
  
  #--------------------------------  
  #-- init_pathvar:  
  proc init_pathvar {} {
    set tmppath [pwd]
    if {[file tail [pwd]]=="quartus"} {
      cd ..
    }  
    # set path
    set ::TE::BASEFOLDER        [pwd]
    set ::TE::BACKUP_PATH       [pwd]/backup
    set ::TE::BOARDDEF_PATH     [pwd]/board_files
    set ::TE::OS_PATH           [pwd]/os
    set ::TE::YOCTO_PATH        [pwd]/os/yocto
    set ::TE::LOG_PATH          [pwd]/log
    set ::TE::PREBUILT_PATH     [pwd]/prebuilt
    set ::TE::QPROJ_PATH        [pwd]/quartus
    set ::TE::SOURCE_PATH       [pwd]/source_files
    set ::TE::YOCTO_SOURCE_PATH [pwd]/source_files/os/yocto
    set ::TE::QPROJ_SOURCE_PATH [pwd]/source_files/quartus
    set ::TE::SDK_SOURCE_PATH   [pwd]/source_files/software
    set ::TE::SET_PATH          [pwd]/settings
    set ::TE::SDK_PATH          [pwd]/software
    set ::TE::QROOTPATH         $::quartus(quartus_rootpath)
    set ::TE::NIOSV_BIN_PATH    $::quartus(quartus_rootpath)../niosv/bin
    if {$::tcl_platform(platform) eq "windows"} {
      set ::TE::NIOS2_COMMAND_SHELL_PATH wsl 
      lappend ::TE::NIOS2_COMMAND_SHELL_PATH bash 
      lappend ::TE::NIOS2_COMMAND_SHELL_PATH "\[exec wsl wslpath ${::TE::QROOTPATH}../nios2eds/\]nios2_command_shell.sh"
      
      set ::TE::EMBEDDED_COMMAND_SHELL_PATH wsl 
      lappend ::TE::EMBEDDED_COMMAND_SHELL_PATH bash 
      lappend ::TE::EMBEDDED_COMMAND_SHELL_PATH "\[exec wsl wslpath ${::TE::QROOTPATH}../embedded/\]embedded_command_shell.sh"

    } else {
      set ::TE::NIOS2_COMMAND_SHELL_PATH "${::TE::QROOTPATH}../nios2eds/nios2_command_shell.sh"
      set ::TE::EMBEDDED_COMMAND_SHELL_PATH "${::TE::QROOTPATH}../embedded/embedded_command_shell.sh"
    }
    #set ::TE::QUARTUS_INSTALLATION_PATH
    regsub "quartus/" ${::TE::QROOTPATH} "" ::TE::QUARTUS_INSTALLATION_PATH
    
    if {[string match "*/qprogrammer/quartus/" ${::TE::QROOTPATH}]} {
      set ::TE::QUART_PROG 1
    } else {
      set ::TE::QUART_PROG 0
    }
    # serial
    if {[catch {set ::TE::SERIAL_PATH  ${::env(TE_SERIAL_PS)}}]} {
      set TE::SERIAL_PATH "../../../../../articlebyserial"
    } 
    if {[file exists $::TE::SERIAL_PATH]} {
      ::TE::UTILS::te_msg -type Info -id TE_INIT-29 -msg "Serial PS Scripts is available on $::TE::SERIAL_PATH"
    }

    # putty
    if {[catch {set TE::COM_PATH  ${::env(TE_COM)}}]} {
      set ::TE::COM_PATH "../../../../../putty"
    }
    set ::TE::COM_IGNORE_LIST [list] 
    append ::TE::COM_IGNORE_LIST "COM1"
    if { [file exists ${::TE::COM_PATH}/com_ignore_list.csv] } {
      set fp [open "${::TE::COM_PATH}/com_ignore_list.csv" r]
      set file_data [read $fp]
      close $fp
      set data [split $file_data "\n"]
      foreach line $data {
        lappend ::TE::COM_IGNORE_LIST $line
      }
    }
    
    set ::TE::BOARDDEF_SRC_LIST [glob -nocomplain -types d -tails -dir ${::TE::BOARDDEF_PATH} *] 
    set ::TE::QPROJ_SRC_LIST [glob -nocomplain -types d -tails -dir ${::TE::SOURCE_PATH} *]
    
    cd $::TE::BASEFOLDER

    ::TE::UTILS::te_msg -type info -id TE_INIT-01 -msg "Initial project directories:"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::BASEFOLDER:"                  ] ${::TE::BASEFOLDER}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::QPROJ_PATH:"                  ] ${::TE::QPROJ_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::BOARDDEF_PATH:"               ] ${::TE::BOARDDEF_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::PREBUILT_PATH:"               ] ${::TE::PREBUILT_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::SOURCE_PATH:"                 ] ${::TE::SOURCE_PATH}\n"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::OS_PATH:"                     ] ${::TE::OS_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::YOCTO_PATH:"                  ] ${::TE::YOCTO_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::YOCTO_SOURCE_PATH:"           ] ${::TE::YOCTO_SOURCE_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::QPROJ_SOURCE_PATH:"           ] ${::TE::QPROJ_SOURCE_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::SDK_SOURCE_PATH:"             ] ${::TE::SDK_SOURCE_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::LOG_PATH:"                    ] ${::TE::LOG_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::SDK_PATH:"                    ] ${::TE::SDK_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::BACKUP_PATH:"                 ] ${::TE::BACKUP_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::SET_PATH:"                    ] ${::TE::SET_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::NIOS2_COMMAND_SHELL_PATH:"    ] ${::TE::NIOS2_COMMAND_SHELL_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::NIOSV_BIN_PATH:"              ] ${::TE::NIOSV_BIN_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::EMBEDDED_COMMAND_SHELL_PATH:" ] ${::TE::EMBEDDED_COMMAND_SHELL_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::QUARTUS_INSTALLATION_PATH:"   ] ${::TE::QUARTUS_INSTALLATION_PATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::QROOTPATH:"                   ] ${::TE::QROOTPATH}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "::TE::QUART_PROG:"                  ] ${::TE::QUART_PROG}"
    ::TE::UTILS::te_msg -type info -msg " [format "%-11s %-35s" "" "------"                             ]"
  } 
  
  #--------------------------------
  #-- get qsys file name, project name
  proc get_project_names {} {
    #set source names
    set ::TE::QPROJ_SRC_NAME [list]
    set ::TE::QSYS_SRC_NAME [list]
    set qsys_allsystem [list]
    set qsys_allsubsystem [list]
    set ::TE::NIOS_SRC_SOPC_FILE_LIST [list]
    set all_tclfiles [glob -nocomplain -tails -directory ${::TE::QPROJ_SOURCE_PATH}/ *.tcl]
    if {$all_tclfiles ne ""} {
      foreach file $all_tclfiles {
        set fp [open "${::TE::QPROJ_SOURCE_PATH}/${file}" r]
        set file_data [read $fp]
        close $fp
        set file_data [split $file_data "\n"]
        set src_filename [file rootname [file tail $file]]
        set cpu_name ""
        foreach data_line $file_data {
          if {[string match -nocase "*Tcl File for Project*" $data_line]} {
            lappend ::TE::QPROJ_SRC_NAME $src_filename
          } elseif {[string match -nocase "*add_instance*" $data_line] || [string match -nocase "*add_component*" $data_line]} {
            foreach name $all_tclfiles {
              set name [file rootname $name]
              if {[string match -nocase "* $name *" $data_line] && ![string match -nocase "$name" ${::TE::QPROJ_SRC_NAME}]} { lappend qsys_allsubsystem $name }
            }
          } elseif {[string match -nocase "*package require -exact qsys*" $data_line]} {
            lappend qsys_allsystem $src_filename
          }
          
          # search for cpu name
          if {[string match "* altera_nios2*" $data_line] || [string match "* intel_niosv*" $data_line]} {
            set cpu_name [lindex [split $data_line " "] 1]
          }
          # add cpu name and parameter to sopc file list
          if { $cpu_name ne "" } {
            lappend ::TE::NIOS_SRC_SOPC_FILE_LIST "${src_filename}.sopcinfo"
            set cpu_name ""
          }
        }
      }
      if {$qsys_allsubsystem ne ""} { 
        foreach qsyssubsystem $qsys_allsubsystem {
          lappend ::TE::QSYS_SRC_NAME $qsyssubsystem 
        }
      }
      foreach qsyssystem $qsys_allsystem {
        if {[lsearch ${::TE::QSYS_SRC_NAME} $qsyssystem] eq -1} {
          lappend ::TE::QSYS_SRC_NAME $qsyssystem
        }
      }
    } else {
      set ::TE::QPROJ_SRC_NAME [file tail ${::TE::BASEFOLDER}]
    }
    #set project names
    set ::TE::QSYS_NAME [list]
    set ::TE::QPROJ_NAME [list]
    if {[glob -nocomplain -directory ${::TE::QPROJ_PATH}/ *.qpf *.qsys] ne ""} {
      foreach file [glob -nocomplain -directory ${::TE::QPROJ_PATH}/ *.qpf *.qsys] {
        if {[string match -nocase "*.qpf*" $file]} {
          lappend ::TE::QPROJ_NAME [file rootname [file tail $file]]
        } elseif {[string match -nocase "*.qsys*" $file] && ![string match -nocase "*.BAK.qsys*" $file]} {
          lappend ::TE::QSYS_NAME [file rootname [file tail $file]]
        }
      }
    }
    
    #get/set yocto bsp layer names
    set src_metalayer [glob -nocomplain -tail -directory ${::TE::YOCTO_SOURCE_PATH}/ meta-*]
    if { ${src_metalayer} ne "" } { set ::TE::YOCTO_SRC_BSP_LAYER_NAME "${src_metalayer}" }
    
    set metalayer [glob -nocomplain -tail -directory ${::TE::YOCTO_PATH}/ meta-*]
    if { ${metalayer} ne "" } { set ::TE::YOCTO_BSP_LAYER_NAME "${metalayer}" }
    
    
    tsv::set ::TE::YOCTO_BSP_LAYER_NAME     ::TK "$::TE::YOCTO_BSP_LAYER_NAME"
    tsv::set ::TE::YOCTO_SRC_BSP_LAYER_NAME ::TK "$::TE::YOCTO_SRC_BSP_LAYER_NAME"
    tsv::set ::TE::QPROJ_NAME               ::TK "$::TE::QPROJ_NAME"
    tsv::set ::TE::QPROJ_SRC_NAME           ::TK "$::TE::QPROJ_SRC_NAME"
    tsv::set ::TE::NIOS_SRC_SOPC_FILE_LIST  ::TK "$::TE::NIOS_SRC_SOPC_FILE_LIST"
  }
  
  #--------------------------------
  #-- check_qproj_version: 
  proc check_qproj_version {} { 
    if {[file exists ${::TE::QPROJ_SOURCE_PATH}/${::TE::QPROJ_SRC_NAME}.tcl]} {
      set fpr [open "${::TE::QPROJ_SOURCE_PATH}/${::TE::QPROJ_SRC_NAME}.tcl" r]
      set filedata [read $fpr]
      close $fpr
      regexp -line {(.*)LAST_QUARTUS_VERSION "((\w+).(\w+).(\w+))(.*)"} $filedata matched sub1 ::TE::SUPPORTED_VER
      regexp -line {(.*)LAST_QUARTUS_VERSION "(.*) (\w+) Edition"} $filedata matched sub1 sub2 ::TE::SUPPORTED_EDI

      if {"${::TE::QVERSION} ${::TE::QEDITION}" ne "${::TE::SUPPORTED_VER} ${::TE::SUPPORTED_EDI}" && "${::TE::SUPPORTED_VER}" ne "NA"  && "${::TE::SUPPORTED_EDI}" ne "NA"} {
        ::TE::UTILS::te_msg -type critical_warning -id TE_INIT-30 -msg "Design was created for Quartus Prime ${::TE::SUPPORTED_VER} ${::TE::SUPPORTED_EDI}. Selected Version: Quartus Prime ${::TE::QVERSION} ${::TE::QEDITION}. To change to supported Version, change Quartus installation path and Quartus Version in \"<project folder>/settings/design_basic_settings.tcl\" file."
      } else {
        ::TE::UTILS::te_msg -type info -id TE_INIT-15 -msg "Supported quartus version: $::TE::SUPPORTED_VER ${::TE::SUPPORTED_EDI}. Used quartus version: $::TE::QVERSION $::TE::QEDITION."
      }
    } else {
      ::TE::UTILS::te_msg -type critical_warning -id TE_INIT-31 -msg "Project source files not found (Path: ${::TE::QPROJ_SOURCE_PATH})."
    }

  }  
  
  #--------------------------------
  #-- init_boardlist: 
  proc init_boardlist {} {
    set ::TE::BOARD_DEFINITION [list]
    if { [catch {set ::TE::DEV_CSV_FILE_DIR [ glob ${::TE::BOARDDEF_PATH}/*_devices_mod.csv ] }] } {
      if { [catch {set ::TE::DEV_CSV_FILE_DIR [ glob ${::TE::BOARDDEF_PATH}/*_devices.csv ] }] } {
        ::TE::UTILS::te_msg -type error -id TE_INIT-02 -msg "No board part definition list found (::TE::INIT::init_boardlist - Path: ${::TE::BOARDDEF_PATH})."
        error "Error on ::TE::INIT::init_boardlist -> Path: ${::TE::BOARDDEF_PATH}"
      }  
    } else {
      ::TE::UTILS::te_msg -type warning -id TE_INIT-03 -msg "Modified board part definition list found (File: ${::TE::DEV_CSV_FILE_DIR})."
    }
    if {$::TE::DEV_CSV_FILE_DIR ne ""} {
      #puts "Read board part definition list (File ${::TE::DEV_CSV_FILE_DIR})."
      set fp [open "${::TE::DEV_CSV_FILE_DIR}" r]
      set file_data [read $fp]
      close $fp

      set data [split $file_data "\n"]
      foreach line $data {
        #  check file version ignore comments and empty lines
        if {![string match *#* $line] && [string match *CSV_VERSION* $line] } {
          # in case somebody has save csv with other programm add comma can be add
          set linetmp [lindex $[split $line ","] 0]
          #remove spaces
          set linetmp [string map {" " ""} $linetmp]
          #remove tabs
          set linetmp [string map {"\t" ""} $linetmp]
          #check version
          set tmp [split $linetmp "="]
          if {[string match [lindex $tmp 1] ${::TE::BOARDDEF_CSV}] != 1} {
            ::TE::UTILS::te_msg -type error -id TE_INIT-04 -msg "Wrong board part definition CSV version (${TE::BOARDDEF_PATH}/*_devices.csv) get [lindex $tmp 1] expected ${TE::BOARDDEF_CSV}."
            return -code error 
          }
        } elseif {![string match *#* $line] && [string match *GENERAL_INFO* $line] } {
          set line [split $line "="]
          set tmp [lindex $line 1]
          set tmp [string map {"\t" ""} $tmp]
          set tmp [split $tmp ","]
          set ::TE::GENERAL_INFO $tmp
        } elseif {![string match *#* $line] && [string length $line] > 0 } {
          #remove spaces
          # set line [string map {" " ""} $line]
          #remove tabs
          set line [string map {"\t" ""} $line]
          #split and append
          set tmp [split $line ","]
          for {set index 0 } {$index < [llength $tmp]} {incr index} {
            set tempvalue [lindex $tmp $index]
            if {[string match *\"* $tempvalue] == 1} {
              set tempvalue2 [split $tempvalue "\""]
              if { [llength $tempvalue2] > 2 } {
                set tempvalue [lindex $tempvalue2 1]
                set tmp [lreplace $tmp $index $index $tempvalue]
              }
            } else {
            #remove spaces
            set tempvalue [string map {" " ""} $tempvalue]
            set tmp [lreplace $tmp $index $index $tempvalue]
            }  
          }
          lappend ::TE::BOARD_DEFINITION $tmp
        }
      }
    }
  }
  
  #--------------------------------
  #-- init_zip_ignore_list: 
  proc init_zip_ignore_list {} {
    set ::TE::ZIP_IGNORE_LIST [list]
    if {[file exists  ${TE::SET_PATH}/zip_ignore_list.csv]} { 
      ::TE::UTILS::te_msg -type info -id TE_INIT-05 -msg "Read ZIP ignore list (File: ${TE::SET_PATH}/zip_ignore_list.csv)."
      set fp [open "${TE::SET_PATH}/zip_ignore_list.csv" r]
      set file_data [read $fp]
      close $fp
      set data [split $file_data "\n"]
      foreach line $data {
        #  check file version ignore comments and empty lines
        if {[string match *#* $line] != 1 && [string match *CSV_VERSION* $line] } {
          #remove spaces
          set line [string map {" " ""} $line]
          #remove tabs
          set line [string map {"\t" ""} $line]
          #check version
          set tmp [split $line "="]
          if {[string match [lindex $tmp 1] ${::TE::ZIP_IGNORE_CSV}] != 1} {
            ::TE::UTILS::te_msg -type error -id TE_INIT-06 -msg "Wrong Zip ignore definition CSV Version (${::TE::SET_PATH}/zip_ignore_list.csv) get [lindex $tmp 1] expected ${::TE::ZIP_IGNORE_CSV}."
            return -code error 
          }
        } elseif {[string match *#* $line] != 1 && [string length $line] > 0} {
          #remove spaces
          set line [string map {" " ""} $line]
          #remove tabs
          set line [string map {"\t" ""} $line]
          #split and append
          set tmp [split $line ","]
          lappend ::TE::ZIP_IGNORE_LIST $tmp
        }
      }
    } else {
      ::TE::UTILS::te_msg -type warning -id TE_INIT-07 -msg "No Zip ignore list used."
    }
  }
  
  #--------------------------------
  #-- init_board:  
  proc init_board {{ID "NA"} {silent false}} {
    if {$ID ne "NA"} {
      set ::TE::ID            $ID
      set ::TE::PRODID      [lindex ${::TE::BOARD_DEFINITION} $ID 1]
      set ::TE::FAMILY      [lindex ${::TE::BOARD_DEFINITION} $ID 2]
      set ::TE::DEVICE      [lindex ${::TE::BOARD_DEFINITION} $ID 3]
      set ::TE::SHORTNAME   [lindex ${::TE::BOARD_DEFINITION} $ID 4]
      set ::TE::FLASHTYP    [lindex ${::TE::BOARD_DEFINITION} $ID 5]
      set ::TE::FLASH_SIZE  [lindex ${::TE::BOARD_DEFINITION} $ID 6]
      set ::TE::DDR_DEV     [lindex ${::TE::BOARD_DEFINITION} $ID 7]
      set ::TE::DDR_SIZE    [lindex ${::TE::BOARD_DEFINITION} $ID 8]
      set ::TE::PCB_REV     [lindex ${::TE::BOARD_DEFINITION} $ID 9]
      set ::TE::NOTES       [lindex ${::TE::BOARD_DEFINITION} $ID 10]
    } else {    
      set ::TE::ID          $ID
      set ::TE::PRODID      $ID
      set ::TE::FAMILY      $ID
      set ::TE::DEVICE      $ID
      set ::TE::SHORTNAME   $ID
      set ::TE::FLASHTYP    $ID
      set ::TE::FLASH_SIZE  $ID
      set ::TE::DDR_DEV     $ID
      set ::TE::DDR_SIZE    $ID
      set ::TE::PCB_REV     $ID
      set ::TE::NOTES       $ID

      ::TE::UTILS::te_msg -type warning -id TE_INIT-08 -msg "::TE::BDEF::init_board: ID $ID not found in device_list.csv."
    }
    if {!$silent} {
      ::TE::UTILS::te_msg -type info -id TE_INIT-09 -msg "Board Part definition:"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::ID:"         ] ${::TE::ID}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::PRODID:"     ] ${::TE::PRODID}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::FAMILY:"     ] ${::TE::FAMILY}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::DEVICE:"     ] ${::TE::DEVICE}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::SHORTNAME:"  ] ${::TE::SHORTNAME}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::FLASHTYP:"   ] ${::TE::FLASHTYP}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::FLASH_SIZE:" ] ${::TE::FLASH_SIZE}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::DDR_DEV:"    ] ${::TE::DDR_DEV}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::DDR_SIZE:"   ] ${::TE::DDR_SIZE}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::PCB_REV:"    ] ${::TE::PCB_REV}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "::TE::NOTES:"      ] ${::TE::NOTES}"
      ::TE::UTILS::te_msg -type info -msg "[format "%-12s %-20s" "" "------"            ]"
    }
    
    # reintialise source files path depending on board revision
    set tmp_qproj_src ""
    foreach qproj_src $::TE::QPROJ_SRC_LIST {
      if { [string match *$qproj_src ${::TE::SHORTNAME}] && [string length $qproj_src] > [string length $tmp_qproj_src]} {
        set tmp_qproj_src $qproj_src
      }
    }
    if {[file exists ${::TE::SOURCE_PATH}/$tmp_qproj_src/quartus]} {
      set ::TE::QPROJ_SOURCE_PATH "${::TE::BASEFOLDER}/source_files/$tmp_qproj_src/quartus"
    } else {
      set ::TE::QPROJ_SOURCE_PATH "${::TE::SOURCE_PATH}/quartus"
    }
    if {!$silent} { ::TE::UTILS::te_msg -type info -id TE_INIT-13 -msg "Quartus source files: ${::TE::QPROJ_SOURCE_PATH}" }
    
    if {[file exists ${::TE::SOURCE_PATH}/$tmp_qproj_src/software]} {
      set ::TE::SDK_SOURCE_PATH "${::TE::BASEFOLDER}/source_files/$tmp_qproj_src/software"
    } else {
      set ::TE::SDK_SOURCE_PATH "${::TE::SOURCE_PATH}/software"
    } 
    if {[file exists ${::TE::SDK_SOURCE_PATH}]} {
      if {!$silent} { ::TE::UTILS::te_msg -type info -id TE_INIT-14 -msg "Software source files:${::TE::SDK_SOURCE_PATH}" }
    } else {
      if {!$silent} { ::TE::UTILS::te_msg -type info -id TE_INIT-16 -msg "Software source files not available." }
    }
    # rerun get_project_names for current source files paths
    if {[catch {eval ::TE::INIT::get_project_names} result]} {::TE::UTILS::te_msg -type error -id TE_INIT-22 -msg "Script (TE::INIT::get_project_names) failed: $result"}
    # reintialise source path for thread variables
    tsv::set ::TE::QPROJ_SOURCE_PATH  ::TK "$::TE::QPROJ_SOURCE_PATH"
    tsv::set ::TE::SDK_SOURCE_PATH    ::TK "$::TE::SDK_SOURCE_PATH"
    if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::init_board_done 1 } }
  }
      
  #--------------------------------
  #-- init_mod_list: 
  proc init_mod_list {} {
    if {[file exists  ${TE::SET_PATH}/mod_list.csv]} {
      set ::TE::MOD_LIST [list]
      ::TE::UTILS::te_msg -type info -id TE_INIT-10 -msg "Read qsys modify list (File: ${TE::SET_PATH}/mod_list.csv)."
      set fp [open "${TE::SET_PATH}/mod_list.csv" r]
      set file_data [read $fp]
      close $fp
      set data [split $file_data "\n"]
      foreach line $data {
        #ignore comments and empty lines
        if {![string match #* $line] && [string length $line] > 0} {
          #  check file version
          if {[string match *CSV_VERSION* $line] } {
            #remove tabs
            set line [string map {"\t" ""} $line]
            #check version
            set tmp [split $line "="]
            if {[string match [lindex $tmp 1] $::TE::MODLIST_CSV] != 1} {
              TE::UTILS::te_msg -type error -id TE_INIT-11 -msg "Wrong TCL Modify CSV Version (${TE::SET_PATH}/mod_list.csv) get [lindex $tmp 1] expected ${TE::MODLIST_CSV}."
              return -code error 
            }
          } else {
            #split line
            set temp [split $line ","]
            if {[llength $temp] <3} {
              TE::UTILS::te_msg -type warning -id TE_INIT-12 -msg "Not enough elements on line ($line). Line ignored."
            } else {
              #get line prodid +remove spaces and tabs
              #sort
                #table header
                #remove tabs
              set line [string map {"\t" ""} $line]
              set temp [split $line ","]
              if {[string match *read* $line]} {
                set tmpfilenames [list]
                if { [string match *qsys_tcl_all* $line] } {
                  foreach file $::TE::QSYS_NAME  {
                    lappend tmpfilenames "${file}__filetype__tcl"
                  }
                } elseif { [string match *project_tcl* $line] } {
                  foreach file $::TE::QPROJ_NAME {
                    lappend tmpfilenames "${file}__filetype__tcl"
                  }
                } else { 
                  foreach file [lindex $temp 1] { 
                    lappend tmpfilenames  "[string map -nocase {"." "__filetype__"} $file]" 
                  } 
                }
                foreach tmpfiler $tmpfilenames {
                  lappend ${tmpfiler} "read [string map -nocase {"__filetype__" "."} $tmpfiler]" 
                }
              } elseif {[string match *write* $line]} {
                foreach tmpfilew $tmpfilenames { 
                  lappend ${tmpfilew} "write [string map -nocase {"__filetype__" "."} ${tmpfilew}]"
                  foreach modline [subst "$$tmpfilew"] { lappend ::TE::MOD_LIST $modline }
                }
              } else { 
                foreach tmpfilea $tmpfilenames { lappend ${tmpfilea} $temp } 
              }
            }
          }
        }
      }
    }
  }
  
  #--------------------------------
  #-- set variables for sharing with other threads
  proc init_thread_variables {} {
    # names
    tsv::set ::TE::QPROJ_NAME                   ::TK "$::TE::QPROJ_NAME"
    tsv::set ::TE::QPROJ_SRC_NAME               ::TK "$::TE::QPROJ_SRC_NAME"
    # lists
    tsv::set ::TE::BOARDDEF_SRC_LIST            ::TK "$::TE::BOARDDEF_SRC_LIST"
    tsv::set ::TE::QPROJ_SRC_LIST               ::TK "$::TE::QPROJ_SRC_LIST"
    # path
    tsv::set ::TE::BACKUP_PATH                  ::TK "$::TE::BACKUP_PATH"
    tsv::set ::TE::BASEFOLDER                   ::TK "$::TE::BASEFOLDER"
    tsv::set ::TE::BOARDDEF_PATH                ::TK "$::TE::BOARDDEF_PATH"
    tsv::set ::TE::LOG_PATH                     ::TK "$::TE::LOG_PATH"
    tsv::set ::TE::QPROJ_PATH                   ::TK "$::TE::QPROJ_PATH"
    tsv::set ::TE::SOURCE_PATH                  ::TK "$::TE::SOURCE_PATH"
    tsv::set ::TE::OS_PATH                      ::TK "$::TE::OS_PATH"
    tsv::set ::TE::YOCTO_PATH                   ::TK "$::TE::YOCTO_PATH"
    tsv::set ::TE::YOCTO_SOURCE_PATH            ::TK "$::TE::YOCTO_SOURCE_PATH"
    tsv::set ::TE::QPROJ_SOURCE_PATH            ::TK "$::TE::QPROJ_SOURCE_PATH"
    tsv::set ::TE::SDK_SOURCE_PATH              ::TK "$::TE::SDK_SOURCE_PATH"
    tsv::set ::TE::SDK_PATH                     ::TK "$::TE::SDK_PATH"
    tsv::set ::TE::SET_PATH                     ::TK "$::TE::SET_PATH"
    tsv::set ::TE::EMBEDDED_COMMAND_SHELL_PATH  ::TK "$::TE::EMBEDDED_COMMAND_SHELL_PATH"
    tsv::set ::TE::NIOS2_COMMAND_SHELL_PATH     ::TK "$::TE::NIOS2_COMMAND_SHELL_PATH"
    tsv::set ::TE::PREBUILT_PATH                ::TK "$::TE::PREBUILT_PATH"
    tsv::set ::TE::QROOTPATH                    ::TK "$::TE::QROOTPATH"
    tsv::set ::TE::QUARTUS_INSTALLATION_PATH    ::TK "$::TE::QUARTUS_INSTALLATION_PATH"
    # board files
    tsv::set ::TE::BOARD_DEFINITION             ::TK "$::TE::BOARD_DEFINITION"
    tsv::set ::TE::BOARDDEF_CSV                 ::TK "$::TE::BOARDDEF_CSV"
    tsv::set ::TE::DEV_CSV_FILE_DIR             ::TK "$::TE::DEV_CSV_FILE_DIR" ;#only for 'Development Tools'
    tsv::set ::TE::GENERAL_INFO                 ::TK "$::TE::GENERAL_INFO"
    # thread
    tsv::set ::TE::MAINTHREAD                   ::TK "$::TE::MAINTHREAD"
    tsv::set ::cancel_process                   ::TK 0
    # OS selection
    tsv::set ::TE::WIN_EXE                      ::TK "$::TE::WIN_EXE"
    # version
    tsv::set ::TE::APPSLIST_CSV                 ::TK "$::TE::APPSLIST_CSV"
    tsv::set ::TE::QVERSION                     ::TK "$::TE::QVERSION"
    tsv::set ::TE::QEDITION                     ::TK "$::TE::QEDITION"
    tsv::set ::TE::SUPPORTED_VER                ::TK "$::TE::SUPPORTED_VER"
    tsv::set ::TE::SUPPORTED_EDI                ::TK "$::TE::SUPPORTED_EDI"
    
    tsv::set ::TE::WSL_EN                       ::TK "$::TE::WSL_EN"
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished initial functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
   
  # -----------------------------------------------------------------------------------------------------------------------------------------
 }
  
 namespace eval BDEF {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # board part definition functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- get_id: Name--> search name, POS: Table position ID....
  proc get_id {NAME} {
    set ::TE::LAST_ID 0
    foreach sublist $::TE::BOARD_DEFINITION {
      foreach data $sublist {
        if { [string match -nocase $NAME $data] } {
          return [lindex $sublist 0]
        }
      }
      if {${::TE::LAST_ID} < [lindex $sublist 0] && [lindex $sublist 0] ne "ID"} {
        set ::TE::LAST_ID [lindex $sublist 0]
      }  
    }
    if {$NAME eq "LAST_ID"} {
      #return the the highest id from the list
      return ${::TE::LAST_ID}
    }
    #default
    ::TE::UTILS::te_msg -type info -id TE_BDEF-01 -msg "ID not found for $NAME, return default: NA"
    return "NA"
  }     

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished board part definition functions
  # ----------------------------------------------------------------------------------------------------------------------------------------- 
 }
  
 namespace eval PROD {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # internal usage only
  # -----------------------------------------------------------------------------------------------------------------------------------------
  variable PROD_CFG [list] 
  variable PROD_TCL_FILE "NA"
  set DESIGN_NAME 0
  set TYPE        1
  set PRODID      2
  set SEARCH_PATH 3
  set TD_PRODID   4
  set TD_SERIAL   5
  
  #--------------------------------
  #-- get_prod_tcl:
  proc init_prod_tcl {} {
    set version_check false
    set series_tcl NA
    set prodid_tcl NA
    set tmp_series NA
    #--read only file location, content will be set with extentions
    if { [file exists  ${::TE::BASEFOLDER}/../prod_cfg_list.csv] } {
      ::TE::UTILS::te_msg -type info -id TE_INIT-23 -msg "Read Prod list (File: ${::TE::BASEFOLDER}/../prod_cfg_list.csv)."
      set tmp_series [lindex [split [ ::TE::INIT::init_board [::TE::BDEF::get_id "LAST_ID"] ] "-"] 0]
      set fp [open "${::TE::BASEFOLDER}/../prod_cfg_list.csv" r]
      set file_data [read $fp]
      close $fp
      set data [split $file_data "\n"]
      foreach line $data {
        #  check file version ignore comments and empty lines
        if {[string match *#* $line] != 1 && [string match *CSV_VERSION* $line] } {
          # in case somebody has save csv with other programm add comma can be add
          set linetmp [lindex $[split $line ";"] 0]
          #remove spaces
          set linetmp [string map {" " ""} $linetmp]
          #remove tabs
          set linetmp [string map {"\t" ""} $linetmp]
          #check version
          set tmp [split $linetmp "="]
          if {[string match [lindex $tmp 1] $::TE::PROD_CFG_CSV] != 1} {
            ::TE::UTILS::te_msg -type error -id TE_INIT-24 -msg "Wrong Prod Definition CSV Version (${::TE::BASEFOLDER}/../prod_cfg_list.csv get [lindex $tmp 1] expected ${::TE::PROD_CFG_CSV}."
            return -code error "Wrong Prod Definition CSV Version (${::TE::BASEFOLDER}/../prod_cfg_list.csv get [lindex $tmp 1] expected $::TE::PROD_CFG_CSV"
          } else {
            set version_check true
            ::TE::UTILS::te_msg -type info -id TE_INIT-25 -msg "Software Definition CSV version passed"
          }
        } elseif {[string match *#* $line] != 1 && [string length $line] > 0 } {
          #add only entries for this design
          if {$version_check eq false} {
            ::TE::UTILS::te_msg -type error -id TE_INIT-26 -msg "Prod Definition CSV Version check was not done."
            return -code error "Prod CFG Definition CSV Version check was not done. (${::TE::BASEFOLDER}/../prod_cfg_list.csv. CSV_VERSION=$::TE::PROD_CFG_CSV missing"
          } else {
            set tmp [split $line ","]
            for {set index 0 } {$index < [llength $tmp]} {incr index} {
              set tempvalue [lindex $tmp $index]
              if {[string match *\"* $tempvalue] == 1} {
                set tempvalue2 [split $tempvalue "\""]
                if { [llength $tempvalue2] > 2 } {
                  set tempvalue [lindex $tempvalue2 1]
                  set tmp [lreplace $tmp $index $index $tempvalue]
                }
              } else {
                #remove spaces
                set tempvalue [string map {" " ""} $tempvalue]
                #remove tabs
                set tempvalue [string map {"\t" ""} $tempvalue]
                #replace
                set tmp [lreplace $tmp $index $index $tempvalue]
              }  
            }
            #use only entries for this project and header
            if {[string match "${::TE::QPROJ_SRC_NAME}" [lindex $tmp $::TE::PROD::DESIGN_NAME]] || [string match "DESIGN_NAME" [lindex $tmp 0]]} {
              lappend ::TE::PROD::PROD_CFG $tmp
              if {( [string match "2" [lindex $tmp $::TE::PROD::TYPE]] ||  [string match "3" [lindex $tmp $::TE::PROD::TYPE]]) && ![string match "def" [lindex $tmp $::TE::PROD::SEARCH_PATH]]} {
                if {[string match "${tmp_series}*" [lindex $tmp $::TE::PROD::PRODID]] || [string match "${tmp_series}*" [lindex $tmp $::TE::PROD::TD_PRODID]]} {
                  set series_tcl [lindex $tmp $::TE::PROD::SEARCH_PATH]
                }
                if {[string match "${::TE::PRODID}" [lindex $tmp $::TE::PROD::PRODID]] || [string match "${::TE::PRODID}" [lindex $tmp $::TE::PROD::TD_PRODID]]} {
                  set prodid_tcl [lindex $tmp $::TE::PROD::SEARCH_PATH]
                  #Attention --> curently init only at beginning of main TCL initialisation and only series will be used
                }
              }
            }
          }
        }
      }
      if {![string match "NA" $prodid_tcl]} {
        ::TE::UTILS::te_msg -type info -id TE_INIT-27 -msg "Prod Definition CSV Individual TCL is used ${::TE::BASEFOLDER}/$prodid_tcl."
        set ::TE::PROD::PROD_TCL_FILE $prodid_tcl
      } else {
        ::TE::UTILS::te_msg -type info -id TE_INIT-28 -msg "Prod Definition CSV Series TCL is used ${::TE::BASEFOLDER}/$series_tcl."
        set ::TE::PROD::PROD_TCL_FILE $series_tcl
      }
    }
  }  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # internal usage only
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
 }
  
  ::TE::UTILS::te_msg -type info -msg "(TE) Load Settings Script finished"
}