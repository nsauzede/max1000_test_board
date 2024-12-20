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
# -- $Date: 2019/10/25| $Author: Dück, Thomas
# -- - initial release 
# ------------------------------------------
# -- $Date: 2020/02/12| $Author: Dück, Thomas
# -- - remove generate zip-name from proc backup_project
# ------------------------------------------
# -- $Date: 2020/04/08| $Author: Dück, Thomas
# -- - add thread for "create project" gui
# -- - add variables for progressbar and cancel process
# ------------------------------------------
# -- $Date: 2020/07/13| $Author: Dück, Thomas
# -- - changed run_project options (removed GUI option)
# ------------------------------------------
# -- $Date: 2021/06/10| $Author: Dück, Thomas
# -- - Added possibility to generate multiple SDK projects
# ------------------------------------------
# -- $Date: 2022/01/24| $Author: Dück, Thomas
# -- - Add run_yocto_project
# ------------------------------------------
# -- $Date: 2022/03/17| $Author: Dück, Thomas
# -- - add variables to backup_project for teinfo file
# -- - add console output for export prebuilt files
# ------------------------------------------
# -- $Date: 2022/07/25| $Author: Dück, Thomas
# -- - bugfixes
# -- - add function start_production_test
# ------------------------------------------
# -- $Date: 2023/09/08| $Author: Dück, Thomas
# -- - add function get_cpu_parameter
# --------------------------------------------------------------------
# --------------------------------------------------------------------
namespace eval ::TE {
  set ::cancel_process 0 ;# used for cancel create project process from tk gui
 namespace eval DES {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #cmd functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- select board gui
  proc run_board_selection {} {
    ::TE::UTILS::te_msg -msg "\nPlease enter the correct ID number from the table below:"
    TE::UTILS::print_boardlist
    ::TE::UTILS::te_msg -msg "ID: "
    gets stdin id
    
    foreach line ${::TE::BOARD_DEFINITION} {
      if {![string match *ID* $line]} {
        lappend valid "[lindex $line 0]"
      }  
    }
    
    while {![regexp -all "$id" $valid] || $id == ""} {
      post_message -type error "Invalid input! ID \"$id\" doesn't exist!"
      ::TE::UTILS::te_msg -msg "Please choose the correct ID number from the table above."
      ::TE::UTILS::te_msg -msg "ID:"
      gets stdin id
    }
    # select between 'create project' and 'export prebuilt files'
    ::TE::UTILS::te_msg -msg "\nWhat would you like to do?"
    ::TE::UTILS::te_msg -msg "   - Create Quartus project, press 1"
    ::TE::UTILS::te_msg -msg "   - Create and open delivery binary folder, press 2"
    ::TE::UTILS::te_msg -msg "Option:"
    gets stdin option
    while { ($option ne 1 || ${::TE::QUART_PROG} eq 1) && $option ne 2 } {
      if {$option eq 1 && ${::TE::QUART_PROG} eq 1} {
        ::TE::UTILS::te_msg -type warning -id TE_DES-80 -msg "You have installed Quartus Programmer $::TE::QVERSION $::TE::QEDITION. 'Create Project' functions are not available."
      } else {
        post_message -type error "Invalid input! Try again."
      }
      ::TE::UTILS::te_msg -msg "Option:"
      gets stdin option
    }
    
    if {$option eq 1 && ${::TE::QUART_PROG} eq 0} {
      if {[catch {::TE::DES::run_project $id 1 3} result]} {::TE::UTILS::te_msg -type error -id TE_DES-01 -msg "Script (::TE::DES::run_project) failed: $result."; return -code error}
    } elseif {$option eq 2} {
      if {[catch {::TE::INIT::init_board [::TE::BDEF::get_id $id]} result]} {::TE::UTILS::te_msg -type error -id TE_DES-81 -msg "Script (TE::INIT::init_board) failed: $result."; return -code error}
      if {[catch {exec {*}[auto_execok start] [ file nativename [::TE::UTILS::copy_user_export] ]} result]} { ::TE::UTILS::te_msg -type error -id TE_DES-82 -msg "(TE) Script (::TE::UTILS::copy_user_export) failed: $result."; return -code error}
    }
  }  

  #--------------------------------
  #-- run_project: quartus project
  proc run_project {BOARD RUN CLEAN} {
    ::TE::UTILS::te_msg -type info -id TE_DES-2 -msg "Run TE::INIT::run_project $BOARD $RUN $CLEAN"
    set ::TE::cntprebinfo 0
    set ::TE::cntprebwarning 0
    set ::TE::cntprebcriticalwarning 0
    set ::TE::cntpreberror 0

    switch $CLEAN {
      0 {}
      1 { # clean all -> project folder
        if {[catch {TE::UTILS::clean_project} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-03 -msg "Script (TE::UTILS::clean_project) failed: $result.";   return -code error}
      }
      2 { # clean all -> software folder
        if {[catch {TE::UTILS::clean_software} result]} {::TE::UTILS::te_msg -type error -id TE_DES-05 -msg "Script (TE::UTILS::clean_software) failed: $result.";   return -code error}
      }
      3 { # clean all -> project and software folder
        if {[catch {TE::UTILS::clean_project} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-07 -msg "Script (TE::UTILS::clean_project) failed: $result.";   return -code error}
        if {[catch {TE::UTILS::clean_software} result]} {::TE::UTILS::te_msg -type error -id TE_DES-09 -msg "Script (TE::UTILS::clean_software) failed: $result.";   return -code error}
      }
      4 { # clean all -> project, software, prebuilt folder
        if {[catch {TE::UTILS::clean_all} result]}     {::TE::UTILS::te_msg -type error -id TE_DES-11 -msg "Script (TE::UTILS::clean_all) failed: $result.";   return -code error}
      }
      default {::TE::UTILS::te_msg -type error -id TE_DES-13 -msg "Error: Design clean option $CLEAN not available, use [show_help]"; return -code error}
    }
    
    if {$RUN > 0 } {
      if {[catch {::TE::INIT::init_board [::TE::BDEF::get_id $BOARD]} result]} {::TE::UTILS::te_msg -type error -id TE_DES-15 -msg "Script (TE::INIT::init_board) failed: $result."; return -code error}
    }
    
    switch $RUN {
      0 { if { [thread::exists $::TE::THREAD_TK_ID] } { ::TE::DES::run_build_project } else { ::TE::UTILS::te_msg -type info -id TE_DES-16 -msg "No mode selected ..." } }
      1 {::TE::DES::run_build_project}
      2 {::TE::DES::export_project_preb "all"}
      default {::TE::UTILS::te_msg -type error -id TE_DES-18 -msg "Error: Design run option not available, use [show_help]"; return -code error}
    }
    ::TE::UTILS::te_msg -type info -id TE_DES-19 -msg "Run project finished with ${::TE::cntprebinfo} infos, ${::TE::cntprebwarning} warnings, ${::TE::cntprebcriticalwarning} critical warnings, ${::TE::cntpreberror} errors.\n"
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }  
  
  #--------------------------------
  #-- generate backup from project: 
  proc backup_project {BACKUP {NAME "NA"} {initials "NA"} {dest "NA"} {ttyp "NA"} {btyp "NA"} {pext "NA"}} {  
    
    set systemTime [clock seconds]
    set release [clock format $systemTime -format "%Y.%m.%d %H:%M:%S"]
    # backup filename
    if {$NAME ne "NA"} {
      set zipname $NAME 
    } else {
      #generate file name
      set date [clock format $systemTime -format %Y%m%d%H%M%S]
      foreach line ${::TE::BOARD_DEFINITION} {
        if {![string match *PRODID* $line]} {      
          set ::TE::PRODID [lindex $line 1]
          regexp {(\w+)\-(\w+)} ${::TE::PRODID} matched board
        }
      }
      if {$BACKUP eq 0} {
        set zipname "${board}-${::TE::QPROJ_SRC_NAME}-quartus_${::TE::QVERSION}-${date}"
      } else {
        set zipname "${board}-${::TE::QPROJ_SRC_NAME}_noprebuilt-quartus_${::TE::QVERSION}-${date}"
      }
    }
    
    # prepare exludelist from zip_ignore_list
    if {[llength $::TE::ZIP_IGNORE_LIST] > 0} {
          set excludelist []
          foreach entry $::TE::ZIP_IGNORE_LIST {
            if {[lindex $entry 0]==0} {
              #only id0 objects
              lappend excludelist [lindex $entry 1]
            } elseif {[lindex $entry 0]==1} {
              #only id1 objects
              set find []
              catch {set find [glob -join -dir $TE::BASEFOLDER [lindex $entry 1]]}
              foreach el $find {
                set sl_start [expr [string length $TE::BASEFOLDER]+1]
                set sl_stop [string length $el] 
                lappend excludelist [string range $el $sl_start $sl_stop]
              }
            }
          }
        }

    switch $BACKUP {
      0 {::TE::EXP::zip_project $excludelist $zipname $release $initials $dest $ttyp $btyp $pext}
      1 {lappend excludelist "prebuilt"; ::TE::EXP::zip_project $excludelist $zipname $release $initials $dest $ttyp $btyp $pext}
      2 {::TE::EXP::zip_project "NA" $zipname $release $initials $dest $ttyp $btyp $pext}
      3 {if {[catch {eval ::TE::DES::generate_quar_source_files} result]}  {::TE::UTILS::te_msg -type error -id TE_DES-53 -msg "Script (TE::DES::generate_quar_source_files) failed: $result";   return -code error}}
      4 {if {[catch {eval ::TE::DES::generate_sdk_source_files} result]}    {::TE::UTILS::te_msg -type error -id TE_DES-58 -msg "Script (TE::DES::generate_sdk_source_files) failed: $result";    return -code error}}
      5 {
        if {[catch {eval ::TE::UTILS::clean_source_files} result]}       {::TE::UTILS::te_msg -type error -id TE_DES-56 -msg "Script (TE::UTILS::clean_source_files) failed: $result";       return -code error}
        if {[catch {eval ::TE::EXP::create_source_folder} result]}       {::TE::UTILS::te_msg -type error -id TE_DES-44 -msg "Script (TE::EXP::create_source_folder) failed: $result";       return -code error}
        if {[catch {eval ::TE::DES::generate_quar_source_files} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-53 -msg "Script (TE::DES::generate_quar_source_files) failed: $result";   return -code error}
        if {[catch {eval ::TE::DES::generate_sdk_source_files} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-58 -msg "Script (TE::DES::generate_sdk_source_files) failed: $result";     return -code error}
      }
      default {::TE::UTILS::te_msg -type error -id TE_DES-24 -msg "Error: Design backup option not available, use [show_help]"; return -code error}
    }
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished cmd functions
  # -----------------------------------------------------------------------------------------------------------------------------------------

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # project design functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- build project + compile project
  proc run_build_project {} {
    if {![file exist  ${::TE::QPROJ_PATH}]} {file mkdir  ${::TE::QPROJ_PATH}}
    set tmpprojdir [pwd]
    cd ${::TE::QPROJ_PATH}
    ::TE::UTILS::te_msg -type info -id TE_DES-25 -msg "Run build project (all). Please wait ..."
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 0 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}
    if {[catch {eval ::TE::INIT::check_qproj_version} result]} {::TE::UTILS::te_msg -type error -id TE_DES-88 -msg "(::TE::INIT::check_qproj_version) failed: $result"; return -code error}
    if {[catch {eval ::TE::QUART::create_empty_project ${::TE::QPROJ_SRC_NAME}} result]} {::TE::UTILS::te_msg -type error -id TE_DES-26 -msg "Script (TE::QUART::create_empty_project ${::TE::QPROJ_SRC_NAME}) failed: $result"; return -code error}
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 5 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}
    if {[catch {eval ::TE::UTILS::copy_source_files} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-28 -msg "Script (TE::UTILS::copy_source_files) failed: $result";   return -code error}    
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 10 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}  
    if {[catch {eval ::TE::QUART::execute_project_tcl} result]} {::TE::UTILS::te_msg -type error -id TE_DES-34 -msg "Script (TE::QUART::execute_project_tcl) failed: $result";   return -code error}  
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 20 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}
    if {${::TE::QSYS_SRC_NAME} ne ""} {
      foreach qsysname ${::TE::QSYS_SRC_NAME} {
        if {[catch {eval ::TE::QUART::create_qsys ${qsysname}} result]}    {::TE::UTILS::te_msg -type error -id TE_DES-29 -msg "Script (TE::QUART::create_qsys ${qsysname}) failed: $result";    return -code error}  
        if {[tsv::get ::cancel_process ::TK]} {thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };  return 0}
        if {[catch {eval ::TE::QUART::generate_qsys ${qsysname}} result]}  {::TE::UTILS::te_msg -type error -id TE_DES-30 -msg "Script (TE::QUART::generate_qsys ${qsysname}) failed: $result";  return -code error}
      }
    }
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 40 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}
    if {[catch {eval ::TE::DES::run_sw_project} result]}     {::TE::UTILS::te_msg -type error -id TE_DES-31 -msg "Script (TE::DES::run_sw_project) failed: $result";     return -code error}    
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 70 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}
    if {${::TE::QEDITION} == "Lite"} {
      if {[file exist [glob -nocomplain -directory [pwd] *.bdf]]} {
        if {[catch {eval ::TE::QUART::generate_bsf} result]} {::TE::UTILS::te_msg -type error -id TE_DES-32 -msg "Script (TE::QUART::generate_bsf) failed: $result";     return -code error}
        if {[tsv::get ::cancel_process ::TK]}  {thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };  return 0}
      }
      if {[catch {eval ::TE::QUART::regenerate_ip} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-33 -msg "Script (TE::QUART::regenerate_ip) failed: $result";     return -code error}  
    }    
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 80 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}
    if {[catch {eval ::TE::QUART::compile_project} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-35 -msg "Script (TE::QUART::compile_project) failed: $result";     return -code error}    
    if {[thread::exists $::TE::THREAD_TK_ID]}  { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 95 } }
    if {[tsv::get ::cancel_process ::TK]}    { thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 };    return 0}
    if {[file exist ${::TE::QPROJ_PATH}/conv_setup.cof]} {
      if {[catch {eval ::TE::QUART::generate_jic_file} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-73 -msg "Script (TE::QUART::generate_jic_file) failed: $result";       return -code error}
    }
    if {${::TE::YOCTO_SRC_BSP_LAYER_NAME} ne "NA"} {
      if {[catch {eval ::TE::DES::run_yocto_project} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-75 -msg "Script (TE::DES::run_yocto_project) failed: $result";         return -code error}
    }
    if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 100 } }
    ::TE::UTILS::te_msg -type info -id TE_DES-36 -msg "Run build project (all) -> done"
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"

    cd $tmpprojdir

  }    
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished project design functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
    
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # software functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- run software project
  proc run_sw_project {} {
    tsv::get ::TE::SDK_SRC_LIST ::TK ::TE::SDK_SRC_LIST
    if {$::TE::SDK_SRC_LIST ne "no_project"} {
      foreach sdk_project $::TE::SDK_SRC_LIST {
        set tmp_sdk [split $sdk_project "|"]
        set ::TE::SDK_SRC_NAME [lindex $tmp_sdk 0]
        set ::TE::QSYS_SOPC_FILE_NAME [file rootname [lindex $tmp_sdk 1]]
        if {[catch {eval ::TE::SDK::get_cpu_parameter} result]} {::TE::UTILS::te_msg -type error -id TE_DES-89 -msg "Script (TE::SDK::get_cpu_parameter) failed: $result";   return -code error}
        ::TE::UTILS::te_msg -type info -id TE_DES-37 -msg "Create software project '${::TE::SDK_SRC_NAME}'. Please wait ..."
        if {$::tcl_platform(platform) eq "windows" && ${::TE::QSYS_CPU_VARIANT} eq "altera_nios2_gen2" } {
          switch [tsv::get ::TE::WSL_EN ::TK] {
            0 { ::TE::UTILS::te_msg -type error -id TE_DES-66 -msg "Windows Subsystem for Linux (WSL) is not installed. WSL is needed for NIOS II EDS. The software project can't be created. For more information and how to install WSL, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html"  
              return 0
            }
            1 { ::TE::UTILS::te_msg -type error -id TE_DES-67 -msg "No Linux distribution installed for WSL. The software project can't be created. For more information and installation instructions, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html"
              return 0
            }
            2 { ::TE::UTILS::te_msg -type error -id TE_DES-68 -msg "Please install missing commands ([tsv::get need_cmd ::TK]) in the linux distribution. Can't create software project without this commands. For more information see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html"
              return 0
            }
          }
        }
        if {![file exist ${::TE::SDK_PATH}]} {file mkdir ${::TE::SDK_PATH}}
        set tmpswdir [pwd]
        cd ${::TE::SDK_PATH}
        if {[catch {eval ::TE::SDK::create_software_files} result]} {::TE::UTILS::te_msg -type error -id TE_DES-38 -msg "Script (TE::SDK::create_software_files) failed: $result";   return -code error}
        if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 40 } }
        if {[tsv::get ::cancel_process ::TK]} {cd $tmpswdir; thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 }; return 0}
        if {[file exist ${::TE::SDK_SOURCE_PATH}/bsp_settings.tcl]} {file copy -force  ${::TE::SDK_SOURCE_PATH}/bsp_settings.tcl ${::TE::SDK_PATH}}  
        if {[file exist ${::TE::SDK_SOURCE_PATH}/template.xml]} {file copy -force  ${::TE::SDK_SOURCE_PATH}/template.xml ${::TE::SDK_PATH}}
        cd ./${::TE::SDK_SRC_NAME}_bsp
        if {[catch {eval ::TE::SDK::create_bsp} result]}     {::TE::UTILS::te_msg -type error -id TE_DES-39 -msg "Script (TE::SDK::create_bsp) failed: $result";     return -code error}  
        cd ../${::TE::SDK_SRC_NAME}
        if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 45 } }
        if {[tsv::get ::cancel_process ::TK]} {cd $tmpswdir; thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 }; return 0}
        if {[catch {eval ::TE::SDK::create_app} result]}     {::TE::UTILS::te_msg -type error -id TE_DES-40 -msg "Script (TE::SDK::create_app) failed: $result";     return -code error}
        if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 50 } }
        if {[tsv::get ::cancel_process ::TK]} {cd $tmpswdir; thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 }; return 0}
        # if {[catch {eval ::TE::SDK::modify_sdk_files} result]}     {::TE::UTILS::te_msg -type error -id TE_DES-64 -msg "Script (TE::SDK::modify_sdk_files) failed: $result";     return -code error}
        if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 55 } }
        if {[tsv::get ::cancel_process ::TK]} {cd $tmpswdir; thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 }; return 0}
        if {[catch {eval ::TE::SDK::app_make} result]}         {::TE::UTILS::te_msg -type error -id TE_DES-41 -msg "Script (TE::SDK::app_make) failed: $result";         return -code error}
        if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 60 } }
        if {[tsv::get ::cancel_process ::TK]} {cd $tmpswdir; thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 }; return 0}
        if {[catch {eval ::TE::SDK::generate_hex_file} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-42 -msg "Script (TE::SDK::generate_hex_file) failed: $result";     return -code error}
        if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 65 } }
        cd $tmpswdir
        if {[tsv::get ::cancel_process ::TK]} {thread::send -async $::TE::THREAD_TK_ID { set ::canceled 0 }; return 0}
        ::TE::UTILS::te_msg -type info -id TE_DES-43 -msg "Create software project '${::TE::SDK_SRC_NAME}' -> done"
      }
    } else {
      if {$::TE::SDK_SRC_NAME eq "no_project"} {
        return 0
      } elseif {![file exist ${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}]} {
        ::TE::UTILS::te_msg -type warning -id TE_DES-57 -msg "SDK sources files not available: ${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}"
      } elseif {[llength $templatefile] > 1} {
        ::TE::UTILS::te_msg -type error -id TE_DES-71 -msg "More than one template.xml file found in SDK source files: ${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}"
      } elseif {[llength $templatefile] eq 0} {
        ::TE::UTILS::te_msg -type error -id TE_DES-72 -msg "template.xml file not found in SDK source files: ${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}"
      }
      if {[thread::exists $::TE::THREAD_TK_ID]} { thread::send -async $::TE::THREAD_TK_ID { set ::pbar_val 65 } }
    }
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished software functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # os functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- run yocto project
  proc run_yocto_project {} {
    if {[catch {eval ::TE::OS::copy_yocto_bsp_layer} result]}       {::TE::UTILS::te_msg -type error -id TE_DES-75 -msg "Script (TE::OS::copy_yocto_bsp_layer) failed: $result";     return -code error}
    if {[catch {eval ::TE::OS::copy_rbf_to_yocto_bsp_layer} result]}  {::TE::UTILS::te_msg -type error -id TE_DES-76 -msg "Script (TE::OS::copy_rbf_to_yocto_bsp_layer) failed: $result"; return -code error}
    if { ${::TE::YOCTO_SRC_BSP_LAYER_NAME} ne "NA" && ${::TE::QEDITION} eq "Lite" && [file exist ${::TE::QUARTUS_INSTALLATION_PATH}/embedded/] } { 
      if {[catch {eval ::TE::OS::convert_handoff_data} result]}     {::TE::UTILS::te_msg -type error -id TE_DES-77 -msg "Script (TE::OS::convert_handoff_data) failed: $result";     return -code error}
      if {[catch {eval ::TE::OS::run_qts_filter} result]}       {::TE::UTILS::te_msg -type error -id TE_DES-78 -msg "Script (TE::OS::run_qts_filter) failed: $result";         return -code error}
    } else {
      ::TE::UTILS::te_msg -type error -id TE_DES-83 -msg "Intel SoC FPGA EDS 20.1 not found (Path: ${::TE::QUARTUS_INSTALLATION_PATH}/embedded/).Can't convert handoff files for yocto project. Install Intel Soc FPGA EDS 20.1 as described here: https://wiki.trenz-electronic.de/display/PD/Install+Intel+Development+Tools"

    }
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished os functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # export project functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- generate quartus source files
  proc generate_quar_source_files {} {
    ::TE::UTILS::te_msg -type info -id TE_DES-39 -msg "Generate quartus source files. Please wait ..."
    tsv::get ::TE::QPROJ_SOURCE_PATH ::TK ::TE::QPROJ_SOURCE_PATH
    if {[catch {eval ::TE::INIT::get_project_names} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-69 -msg "Script (TE::INIT::get_project_names) failed: $result";   return -code error}
    if {[catch {eval ::TE::EXP::generate_tcl_proj} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-45 -msg "Script (TE::EXP::generate_tcl_proj) failed: $result";     return -code error}
    if {[catch {eval ::TE::EXP::generate_tcl_qsys} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-47 -msg "Script (TE::EXP::generate_tcl_qsys) failed: $result";     return -code error}
    if {[catch {eval ::TE::EXP::export_project_files} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-49 -msg "Script (TE::EXP::export_project_files) failed: $result";   return -code error}
    if { ${::TE::YOCTO_BSP_LAYER_NAME} ne "NA" } {
      if {[catch {eval ::TE::EXP::export_yocto_files} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-79 -msg "Script (TE::EXP::export_yocto_files) failed: $result";   return -code error}
    }
    if {[catch {eval ::TE::UTILS::modify_files} result]}     {::TE::UTILS::te_msg -type error -id TE_DES-46 -msg "Script (TE::UTILS::modify_files) failed: $result";     return -code error}    
    ::TE::UTILS::te_msg -type info -id TE_DES-51 -msg "Generate quartus source files -> done"
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }
  
  #--------------------------------
  #-- generate software source files
  proc generate_sdk_source_files {projectname} {
    foreach project $projectname {
      ::TE::UTILS::te_msg -type info -id TE_DES-59 -msg "Generate software source files for '$project'. Please wait ..."
      tsv::get ::TE::SDK_SOURCE_PATH ::TK ::TE::SDK_SOURCE_PATH
      if {[catch {eval ::TE::INIT::get_project_names} result]}   {::TE::UTILS::te_msg -type error -id TE_DES-70 -msg "Script (TE::INIT::get_project_names) failed: $result";                  return -code error}
      if {[catch {eval ::TE::EXP::export_software_files \"$project\"} result]} {::TE::UTILS::te_msg -type error -id TE_DES-60 -msg "Script (TE::EXP::export_software_files \"$project\") failed: $result";   return -code error}
      ::TE::UTILS::te_msg -type info -id TE_DES-61 -msg "Generate software source files for '$project' -> done"
      ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
    }
    
  }
  
  #--------------------------------
  #-- export project with prebuilt files
  proc export_project_preb {id} {
    ::TE::UTILS::te_msg -type info -id TE_DES-52 -msg "Export project (preb) - ID: $id. Please wait ..."    
    if {[catch {eval ::TE::EXP::generate_prebuilt_files $id} result]} {::TE::UTILS::te_msg -type error -id TE_DES-54 -msg "Script (TE::EXP::generate_prebuilt_files $id) failed: $result"; return -code error}
    ::TE::UTILS::te_msg -type info -id TE_DES-55 -msg "Export project (preb) - ID: $id -> done"
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished export project functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # tk functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- open create_project gui
  proc create_project_gui {} {
    set ::wait_tk_thread 1
    
    set ::TE::THREAD_TK_ID [thread::create -preserved]  
    thread::send -async $::TE::THREAD_TK_ID {
      source ./scripts/script_tk.tcl
      ::TE::TK::run_create_project_tk
    }
    vwait ::wait_tk_thread
    thread::release $::TE::THREAD_TK_ID
    ::TE::UTILS::te_msg -type info -id TE_DES-62 -msg "'Create Project' GUI closed."
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }
  
  #--------------------------------
  #-- export project with prebuilt files
  proc development_tools_gui {} {
    set ::wait_tk_thread 1        
    set ::TE::THREAD_TK_ID [thread::create -preserved]    
    thread::send -async $::TE::THREAD_TK_ID {    
      source ./scripts/script_dev_tk.tcl
      ::TE::DEV::run_development_tools_tk  
    }
    vwait ::wait_tk_thread
    thread::release $::TE::THREAD_TK_ID
    ::TE::UTILS::te_msg -type info -id TE_DES-63 -msg "'Development Tools' GUI closed."
    ::TE::UTILS::te_msg -msg "-----------------------------------------------------------------------"
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished tk functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # internal usage only
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- start_production_test: 
  proc start_production_test {} {
    ::TE::UTILS::te_msg -type info -id TE_DES-84 -msg "Search for MT scripts."
    if { [file exists  ${::TE::BASEFOLDER}/../prod_cfg_list.csv] } {
      if {[catch {::TE::PROD::init_prod_tcl} result]} {::TE::UTILS::te_msg -type error -id TE_DES-85 -msg "Script (::TE::PROD::init_prod_tcl) failed: $result.";   return -code error}
      puts "Test: ${TE::BASEFOLDER}/${TE::PROD::PROD_TCL_FILE}"
      if { [file exists  ${TE::BASEFOLDER}/${TE::PROD::PROD_TCL_FILE}] } {
        source ${TE::BASEFOLDER}/${TE::PROD::PROD_TCL_FILE}
      } else {
        ::TE::UTILS::te_msg -type critical_warning -id TE_DES-86 -msg "MT scripts not available."
      }
    } else {
      ::TE::UTILS::te_msg -type critical_warning -id TE_DES-87 -msg "MT Test not available for this project."
    }
  } 
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # internal usage only
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
 }
  ::TE::UTILS::te_msg -type info -msg "(TE) Load designs script finished"
}