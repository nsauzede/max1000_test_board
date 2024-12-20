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
# ------------------------------------------
# -- $Date: 2019/10/25 | $Author: Dück, Thomas
# -- - initial release
# ------------------------------------------
# -- $Date: 2020/02/12 | $Author: Dück, Thomas
# -- - add option -- run_tk_gui
# -- - add option -- run_dev_gui
# ------------------------------------------
# -- $Date: 2022/01/24 | $Author: Dück, Thomas
# -- - add script_os.tcl
# ------------------------------------------
# -- $Date: 2022/08/10 | $Author: Dück, Thomas
# -- - add run copy_pgm_flash_template function
# ------------------------------------------
# -- $Date: 2022/10/25 | $Author: Dück, Thomas
# -- - add use_teprocedure
# --------------------------------------------------------------------
# --------------------------------------------------------------------
puts "-----------------------------------------------------------------------"
package require Thread

global quartus

if {[file tail [pwd]]=="quartus"} {
  cd ../
}

#load source scripts
source ./scripts/script_utils.tcl
source ./scripts/script_settings.tcl
source ./scripts/script_quartus.tcl
source ./scripts/script_sdk.tcl
source ./scripts/script_designs.tcl
source ./scripts/script_export.tcl
source ./scripts/script_os.tcl
if {[catch {eval source $::quartus(quartus_rootpath)/common/tcl/internal/sys_pjc.tcl} result]} {
  ::TE::UTILS::te_msg -type warning -id TE_MAIN-01 -msg "$result"
} else {::TE::UTILS::te_msg -type info -id TE_MAIN-02 -msg "(TE) Load sys_pjc script finished"}
::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"

namespace eval ::TE {
 namespace eval INIT {
  variable my_script $argv0

  proc return_option {option} {
    global argc
    global argv
      
    if { $argc <= [expr $option + 1]} { 
      ::TE::UTILS::te_msg -type error -id TE_MAIN-03 -msg "(TE) Read Parameter failed"
      show_help_batchfile_commands
      exit;
    } else {  
      # ::TE::UTILS::te_msg -type info -id TE_MAIN-05 -msg "(TE) Parameter Option Value: [lindex $argv [expr $option + 1]]"
      return [lindex $argv [expr $option + 1]]
    }
    }

    proc show_help_batchfile_commands {} {
    variable my_script
    puts "(TE) Batch-File TCL-Script start options:"
    puts "write: quartus_sh${::TE::WIN_EXE} -t ./scripts/script_main.tcl <Options>\n"
    puts "Options:"
    puts "Create/Run Quartus project:"
    puts "--run_tk_gui :  open 'Create Project' gui\n"
    puts "--run_dev_gui : open 'Development Tools' gui\n"
    puts "--run :         run option:           \
                    0 -reserved\n                                       \
                    1 -create selected boardpart project\n                                       \
                    2 -create all boardpart project (prebuilt)\n"
    puts "--boardpart :   Trenz Board ID from TEIXXXX_devices.csv  (you can use ID,PRODID or SHORTNAME from TEIxxxx_devices.csv list)\n"
    puts "--clean :       clean project option:  \
                    0 -no(default)\n                                       \
                    1 -quartus project\n                                       \
                    2 -software project\n                                       \
                    3 -quartus and software workspace\n                                       \
                    4 -all and prebuilt (quartus and software workspace and prebuilt)\n"
    puts "--backup :      backup project option: \
                    0 -backup with prebuilt (files from zip_ignore_list.csv excluded)\n                                       \
                    1 -backup without prebuilt (files from zip_ignore_list.csv excluded)\n                                       \
                    2 -save all (including files from zip_ignore_list.csv)\n                                       \
                    3 -generate quartus source files from current project\n                                       \
                    4 -generate software source files from current project\n                                       \
                    5 -generate all source files from current project\n"
    puts "--backup_filename :   \<filename\> Specify backup filename. Use only use with --backup option.\n"
    puts "--help :      display this help and exit"
    puts ""
    puts "Example: quartus_sh${::TE::WIN_EXE} -t ./scripts/script_main.tcl --run_tk_gui\n\n"
    puts "Press \[Enter\] to continue ..."
    gets stdin in
    }
  
  #--------------------------------
  #-- initialize environment
  proc initialize_environment {} {
    if {[catch {eval ::TE::INIT::init_pathvar} result]}             {::TE::UTILS::te_msg -type error -id TE_MAIN-12 -msg "Script (::TE::INIT::init_pathvar) failed: $result"}
    if {[catch {eval ::TE::INIT::get_project_names} result]}        {::TE::UTILS::te_msg -type error -id TE_MAIN-13 -msg "Script (::TE::INIT::get_project_names) failed: $result"; return -code error}
    if {[catch {eval ::TE::INIT::init_env} result]}                 {::TE::UTILS::te_msg -type error -id TE_MAIN-14 -msg "Script (::TE::INIT::init_env) failed: $result"}
    if {[catch {eval ::TE::INIT::init_boardlist} result]}           {::TE::UTILS::te_msg -type error -id TE_MAIN-15 -msg "Script (::TE::INIT::init_boardlist) failed: $result"}
    if {[catch {eval ::TE::INIT::init_zip_ignore_list} result]}     {::TE::UTILS::te_msg -type error -id TE_MAIN-16 -msg "Script (::TE::INIT::init_zip_ignore_list) failed: $result"}
    if {[catch {eval ::TE::INIT::init_thread_variables} result]}    {::TE::UTILS::te_msg -type error -id TE_MAIN-17 -msg "Script (::TE::INIT::init_thread_variables) failed: $result"}
    if {[catch {eval ::TE::UTILS::copy_pgm_flash_template} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-19 -msg "Script (::TE::UTILS::copy_pgm_flash_template) failed: $result"}
  }

    proc main {} {
    global argc
    global argv
    #
    set use_board_selection false
    set use_board "NA"
    set use_run 0
    set use_clean 0
    set use_backup "NA"
    set use_backup_filename "NA"
    set ::use_tk_gui false
    set ::use_dev_gui false
    set use_teprocedure "NA"
    
    # ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
    #
    if {$argc == 0} {
      ::TE::UTILS::te_msg -msg ""
      ::TE::UTILS::te_msg -type info -id TE_MAIN-04 -msg "(TE) Default configuration will be used." 
      ::TE::UTILS::te_msg -msg ""
    } else {
      for {set option 0} {$option < $argc} {incr option} {
        switch [lindex $argv $option] {
          "--run_board_selection" {set use_board_selection  true}  
          "--run_tk_gui"          {set ::use_tk_gui         true}
          "--run_dev_gui"         {set ::use_dev_gui        true}
          "--run"                 {set use_run              [return_option $option]; incr option}
          "--boardpart"           {set use_board            [return_option $option]; incr option}
          "--clean"               {set use_clean            [return_option $option]; incr option}
          "--backup"              {set use_backup           [return_option $option]; incr option}
          "--backup_filename"     {set use_backup_filename  [return_option $option]; incr option}
          "--run_te_procedure"    { set use_teprocedure     [return_option $option]; incr option}
          "--help"                {show_help_batchfile_commands; return 0}
          ""                      { }
          default                 {::TE::UTILS::te_msg -type info -id TE_MAIN-05 -msg "(TE) unrecognised option: [lindex $argv $option]"; show_help_batchfile_commands }
        }
      }
    }
    
    # ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
    #--------------------------------
    # initialize environment
    if {[catch {eval initialize_environment} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-18 -msg "Script (TE::initialize_environment) failed: $result"}
    
    #::TE::UTILS::te_msg -msg "init_pathvar done"
    #
    
    set starttime [clock seconds]

    # ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
    if {$use_board_selection} { 
       if {[catch {::TE::DES::run_board_selection} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-06 -msg "ERROR:(TE) Script (TE::DES::run_board_selection) failed: $result."; return 0}
    } elseif {$use_backup ne "NA"} {
      if {[catch {::TE::DES::backup_project $use_backup $use_backup_filename} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-07 -msg "ERROR:(TE) Script (::TE::DES::backup_project) failed: $result."}  
    } elseif {$::use_tk_gui} {
      if {[catch {::TE::DES::create_project_gui} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-10 -msg "ERROR:(TE) Script (::TE::DES::create_project_gui) failed: $result."; return -code error}
    } elseif {$::use_dev_gui} {
      if {[catch {::TE::DES::development_tools_gui} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-11 -msg "ERROR:(TE) Script (::TE::DES::development_tools_gui) failed: $result."; return -code error}
    } elseif {$use_teprocedure ne "NA"} {
      if {[catch {eval $use_teprocedure} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-19 -msg "ERROR:(TE) Script ($use_teprocedure) failed: $result."; return -code error}
    } else {
      if {[catch {::TE::DES::run_project $use_board $use_run $use_clean} result]} {::TE::UTILS::te_msg -type error -id TE_MAIN-08 -msg "ERROR:(TE) Script (TE::DES::run_project) failed: $result."; return -code error}
    }

    #---------------------------------------------
    set stoptime [clock seconds]
    set timeelapsed [expr $stoptime -$starttime]
    ::TE::UTILS::write_log_file "Time elapsed: $timeelapsed seconds ...\n"
    #---------------------------------------------
    
    ::TE::UTILS::write_log_file "${::TE::cntscriptinfo} infos, ${::TE::cntscriptwarning} warnings, ${::TE::cntscriptcriticalwarning} critical warnings, ${::TE::cntscripterror} errors\n"
  }

  
  
    if {[catch {main} result]} {
    ::TE::UTILS::te_msg -type error -id TE_MAIN-09 -msg "(TE) Script (TE::main) failed: $result."
    return error;
    }
  return ok;
 }
  ::TE::UTILS::te_msg -type info -msg "(TE) Load main script finished"
}