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
# -- $Date: 2020/01/28 | $Author: Dück, Thomas
# -- $Version: 1.0 $
# -- - initial release 19.4
# ------------------------------------------
# -- $Date: 2020/04/09 | $Author: Dück, Thomas
# -- $Version: 1.1 $
# -- - run gui in thread 
# -- - add thread functions
# -- - add menubar
# ------------------------------------------
# -- $Date: 2021/06/10 | $Author: Dück, Thomas
# -- $Version: 2.0 $
# -- - release 20.4
# -- - added functions to generate multiple SDK projects
# -- - bugfixes
# ------------------------------------------
# -- $Date: 2022/01/24 | $Author: Dück, Thomas
# -- $Version: 2.1 $
# -- - add to function generate_source_files: delete yocto source files
# ------------------------------------------
# -- $Date: 2022/03/17 | $Author: Dück, Thomas
# -- $Version: 2.2 $
# -- - add zip teinfo request to "Backup" section and "generate_backup"
# ------------------------------------------
# -- $Date: 2022/06/26 | $Author: Dück, Thomas
# -- $Version: 2.2 $
# -- - bugfixes in proc check_sdk_sources
# --------------------------------------------------------------------
# --------------------------------------------------------------------
package require Tcl
package require Tk
package require Thread


namespace eval ::TE {
 namespace eval DEV {
  # get global variables
  # names
  tsv::get ::TE::QPROJ_NAME               ::TK ::TE::QPROJ_NAME
  tsv::get ::TE::QPROJ_SRC_NAME           ::TK ::TE::QPROJ_SRC_NAME
  tsv::get ::TE::NIOS_SRC_SOPC_FILE_LIST  ::TK ::TE::NIOS_SRC_SOPC_FILE_LIST
  # path
  tsv::get ::TE::BASEFOLDER               ::TK ::TE::BASEFOLDER
  tsv::get ::TE::QPROJ_PATH               ::TK ::TE::QPROJ_PATH
  tsv::get ::TE::BOARDDEF_PATH            ::TK ::TE::BOARDDEF_PATH
  tsv::get ::TE::SOURCE_PATH              ::TK ::TE::SOURCE_PATH
  tsv::get ::TE::QPROJ_SOURCE_PATH        ::TK ::TE::QPROJ_SOURCE_PATH
  tsv::get ::TE::SDK_SOURCE_PATH          ::TK ::TE::SDK_SOURCE_PATH
  tsv::get ::TE::SDK_PATH                 ::TK ::TE::SDK_PATH
  tsv::get ::TE::YOCTO_SOURCE_PATH        ::TK ::TE::YOCTO_SOURCE_PATH
  tsv::get ::TE::LOG_PATH                 ::TK ::TE::LOG_PATH
  tsv::get ::TE::BACKUP_PATH              ::TK ::TE::BACKUP_PATH
  tsv::get ::TE::SET_PATH                 ::TK ::TE::SET_PATH
  tsv::get ::TE::NIOS2_COMMAND_SHELL_PATH ::TK ::TE::NIOS2_COMMAND_SHELL_PATH
  tsv::get ::TE::PREBUILT_PATH            ::TK ::TE::PREBUILT_PATH
  tsv::get ::TE::QROOTPATH                ::TK ::TE::QROOTPATH
  # board files
  tsv::get ::TE::BOARD_DEFINITION         ::TK ::TE::BOARD_DEFINITION
  tsv::get ::TE::BOARDDEF_CSV             ::TK ::TE::BOARDDEF_CSV
  tsv::get ::TE::DEV_CSV_FILE_DIR         ::TK ::TE::DEV_CSV_FILE_DIR
  # thread
  tsv::get ::TE::MAINTHREAD               ::TK ::TE::MAINTHREAD
  # OS selection
  tsv::get ::TE::WIN_EXE                  ::TK ::TE::WIN_EXE
  # version
  tsv::get ::TE::APPSLIST_CSV             ::TK ::TE::APPSLIST_CSV
  tsv::get ::TE::QVERSION                 ::TK ::TE::QVERSION
  tsv::get ::TE::QEDITION                 ::TK ::TE::QEDITION
  tsv::get ::TE::SUPPORTED_VER            ::TK ::TE::SUPPORTED_VER
  tsv::get ::TE::SUPPORTED_EDI            ::TK ::TE::SUPPORTED_EDI
  
  tsv::get ::TE::WSL_EN                   ::TK ::TE::WSL_EN
  
  variable ::dev_VERSION 2.2
    
  # variables for zip-file name -> generate backup
  set ::own_name ""
  
  # running process variables
  set ::writing_to_file         0
  set ::generating_source_files 0
  set ::generating_backup       0
  set ::generating_prebuilt     0
  
  set ::dev_csv_filedir     ""
  set ::dev_csv_mod_filedir "NA"
  set ::dev_csv_data        ""
  
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # create gui
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- run development tools gui
  proc run_development_tools_tk {} {
    thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_DEV-01 -msg "Development Tools GUI. Change to GUI." }
    
    # load theme
    ttk::style theme use clam
    source ./scripts/script_ownTheme.tcl
    
    #--------------------------------
    # set width of wm components relative to size of default font
    set ::defaultwidth  [font measure ownfont 0]
    set ::buttonwidth   [expr 3*$::defaultwidth]
    set ::comboboxwidth [expr 5*$::defaultwidth]
    set ::tvwidth       [expr 21*$::defaultwidth]
    set ::docwidth      [expr 13*$::defaultwidth]
    set ::messagewidth  [expr 15*$::defaultwidth]  
    set ::entrywidth    [expr 10*$::defaultwidth]  
    
    #-- init open_extern 
    if {$::tcl_platform(platform) eq "windows"} {
      set ::open_extern "eval exec \[auto_execok start\]"
    } else {
      set ::open_extern "exec xdg-open"
    }
    
    # set color of wm  background
    grid  [ttk::label .background]  -sticky nesw -rowspan 10 -columnspan 10
  
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- menubar   
    menu .mb
    . configure -menu .mb

    menu .mb.file -tearoff 0
    .mb add cascade -menu .mb.file -label File -underline 0
    # .mb.file add cascade -label "New ..." -menu .mb.file.new  
    # .mb.file add separator
    .mb.file add command -label Exit  -command {::TE::DEV::exit_tk}
   #  menu .mb.file.new -tearoff 0
    # .mb.file.new add command -label "Quartus project"   -command { ::TE::DEV::create_new_project_window_tk }
    # .mb.file.new add command -label "Software project"  -command { }
  
    menu .mb.project -tearoff 0
    .mb add cascade -menu .mb.project -label Project -underline 0
    .mb.project add command -label "Write to file"          -command {.fr_dev.btn_csv_ow invoke}
    .mb.project add command -label "Generate source files"  -command {.fr_src.btn_gen_src invoke}
    .mb.project add command -label "Generate backup"        -command {.fr_backup.btn_gen_bckup invoke}
    .mb.project add command -label "Generate prebuilt"      -command {.fr_preb.btn_gen_preb invoke}
    .mb.project add command -label "Open project"           -command {::TE::DEV::thread_open_project}

    menu .mb.tools -tearoff 0
    .mb add cascade -menu .mb.tools -label Tools -underline 0
    .mb.tools add command -label "Quartus Prime ${::TE::QEDITION} ${::TE::QVERSION}"  -command {::TE::DEV::thread_open_quartus}
    .mb.tools add command -label "Quartus Programmer"                                 -command {::TE::DEV::thread_open_programmer_gui}
    .mb.tools add separator
    .mb.tools add command -label "NIOS II Software Build Tools for Eclipse"           -command {::TE::DEV::thread_open_eclipse_ide}
    .mb.tools add command -label "NIOS II Command Shell"                              -command {::TE::DEV::thread_open_command_shell}

    menu .mb.q -tearoff 0
    .mb add cascade -menu .mb.q -label ? -underline 0
    .mb.q add command -label "Help"                         -command "$::open_extern https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices#ProjectDelivery-Inteldevices-CommandFiles "
    .mb.q add command -label "Create Project - Quick Start" -command "$::open_extern https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices#ProjectDelivery-Inteldevices-QuickStart "
    .mb.q add separator
    .mb.q add command -label "Trenz Electronic - Web"       -command "$::open_extern https://www.trenz-electronic.de/ "
    .mb.q add command -label "Trenz Electronic - Wiki"      -command "$::open_extern https://wiki.trenz-electronic.de/ "
    .mb.q add command -label "Trenz Electronic - Forum"     -command "$::open_extern https://forum.trenz-electronic.de/ "
    .mb.q add command -label "Trenz Electronic - Download"  -command "$::open_extern https://shop.trenz-electronic.de/en/Download/?path=Trenz_Electronic/ "
    .mb.q add separator
    .mb.q add command -label "Contact Support"              -command "$::open_extern mailto:support@trenz-electronic.de?subject=Create_Project-[lindex [split [lindex ${::TE::BOARD_DEFINITION} 1 1] "-"] 0]_${::TE::QPROJ_SRC_NAME}--"
    .mb.q add separator
    .mb.q add command -label "About - Development Tools"    -command {::TE::DEV::about_window_tk}  

  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- device list csv content  
    grid  [ttk::labelframe .fr_dev -text "Device list" ] -row 0 -column 0 -columnspan 4 -padx 10 -pady 3  -sticky nesw    
  
    grid  [text           .fr_dev.tx100   -tabs 1c -wrap none -xscrollcommand {.fr_dev.sbX100 set} -yscrollcommand {.fr_dev.sbY100 set}             -height 15    -width 135] -row 0 -column 0  -columnspan 4 -sticky nesw
    grid  [ttk::scrollbar .fr_dev.sbY100  -orient vertical                                                            -command {.fr_dev.tx100 yview}                        ] -row 0 -column 4                -sticky nws
    grid  [ttk::scrollbar .fr_dev.sbX100  -orient horizontal                                                          -command {.fr_dev.tx100 xview}                        ] -row 1            -columnspan 4 -sticky ew
      
    grid  [ttk::label     .fr_dev.lb102   -text "Module (e.g. TEI0001):"                                                                                          -width 20 ] -row 2 -column 0                -sticky w
    grid  [ttk::entry     .fr_dev.en100   -textvariable ::moduleseries    -validate focus -validatecommand { ::TE::DEV::set_module }                                        ] -row 2 -column 1  -columnspan 3 -sticky ew 
    grid  [ttk::label     .fr_dev.lb103   -text "Category (e.g.  Modules_and_Module_Carriers/2.5x6.15 -> needed for generating correct weblink for schematics):"  -width 90 ] -row 3 -column 0                -sticky w
    grid  [ttk::entry     .fr_dev.en101   -textvariable ::category        -validate focus -validatecommand { ::TE::DEV::set_category }                                      ] -row 3 -column 1  -columnspan 3 -sticky ew 
    grid  [ttk::button    .fr_dev.btn_csv_ok -text "Create file"                                                      -command {::TE::DEV::create_dev_csv}        -width 30 ] -row 4 -column 2  -columnspan 2 -sticky e
    
    grid  [ttk::label     .fr_dev.lb101   -text "Current file:  <base_directory>/board_files/"                                                                    -width 39 ] -row 5 -column 0                -sticky w
    set  ::rb_devlist devlist
    grid  [ttk::radiobutton .fr_dev.rb100 -text "<Module>_devices.csv"      -variable ::rb_devlist -value devlist     -command {::TE::DEV::load_device_list}                ] -row 5 -column 1                -sticky nw
    grid  [ttk::radiobutton .fr_dev.rb101 -text "<Module>_devices_mod.csv"  -variable ::rb_devlist -value devmodlist  -command {::TE::DEV::load_device_list}                ] -row 6 -column 1                -sticky nw
    
    grid  [ttk::button    .fr_dev.btn_csv_ow  -text "Write to file"                                                   -command {::TE::DEV::write_file}            -width 30 ] -row 6 -column 2  -columnspan 2 -sticky e
    
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- generate source files   
    grid  [ttk::labelframe .fr_src -text "Source files"] -row 1 -column 0 -columnspan 3   -padx 10 -pady 3 -sticky nesw
    set ::cb_qsrc 1
    set ::cb_ssrc 1
  
    ttk::style configure cb200.TCheckbutton -foreground grey
    ttk::style configure cb201.TCheckbutton -foreground grey
  
    grid  [ttk::checkbutton .fr_src.cb200  -text "quartus source path:"  -style cb200.TCheckbutton   -variable ::cb_qsrc -command ::TE::DEV::check_src_cb         ] -row 0 -column 0          -sticky w
    grid  [text             .fr_src.tx200  -height 1                     -width 91                   -wrap none                                                   ] -row 0 -column 1  -padx 5  
    grid  [ttk::label       .fr_src.lb200  -text "Quartus project not found. Can't generate quartus source files."       -foreground $::colors(-blue)             ] -row 1 -column 1          -sticky w
    grid remove .fr_src.lb200
    
    grid  [ttk::checkbutton .fr_src.cb201  -text "software source path:" -style cb201.TCheckbutton -variable ::cb_ssrc   -command {::TE::DEV::check_src_cb}       ] -row 2 -column 0          -sticky w 
    grid  [text             .fr_src.tx201  -height 1                     -width 91                 -wrap none                                                     ] -row 2 -column 1  -padx 5
    grid  [ttk::label       .fr_src.lb201  -text "Software project not found. Can't generate software source files"      -foreground $::colors(-blue)             ] -row 3 -column 1          -sticky w
    grid remove .fr_src.lb201
  
    grid  [ttk::button      .fr_src.btn_gen_src  -text "Generate source files"                     -width 30             -command ::TE::DEV::generate_source_files] -row 2 -column 2          -sticky e
  
  
    .fr_src.tx200 insert end "./source_files/quartus"
    .fr_src.tx201 insert end "./source_files/software"
    
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- generate prebuilt files
    grid  [ttk::labelframe .fr_preb -text "Prebuilt"] -row 2 -column 0 -columnspan 3   -padx 10 -pady 3 -sticky nesw
    set ::rb_preb "preball"
    grid  [ttk::radiobutton .fr_preb.rb400      -text "All shortnames"          -variable ::rb_preb  -value "preball" -command ::TE::DEV::check_prebuilt_rb                             ] -row 0 -column 0                              -sticky nw
    grid  [ttk::radiobutton .fr_preb.rb401      -text "Select shortnames:"      -variable ::rb_preb  -value "prebsel" -command {::TE::DEV::check_prebuilt_rb; ::TE::DEV::set_shortlist} ] -row 1 -column 0                              -sticky nw
    grid  [listbox          .fr_preb.lbox402    -listvariable  ::shortnamelist  -width 35 -height 7 -yscrollcommand {.fr_preb.sbY set} -selectmode multiple                             ] -row 0 -column 2 -rowspan 10  -padx 5 -pady 3 -sticky w
    grid  [ttk::scrollbar   .fr_preb.sbY        -orient vertical                                                      -command {.fr_preb.lbox402 yview}                                 ] -row 0 -column 2 -rowspan 10                  -sticky nes
    grid  [ttk::label       .fr_preb.lb403      -text ""                        -width 75           -foreground $::colors(-blue)                                                        ] -row 9 -column 3
    grid  [ttk::button      .fr_preb.btn_gen_preb -text "Generate prebuilt"     -width 30                             -command {::TE::DEV::generate_prebuilt}                           ] -row 9 -column 4                              -sticky es

  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- generate backup  files
    grid  [ttk::labelframe .fr_backup -text "Backup"] -row 3 -column 0 -columnspan 3   -padx 10 -pady 3 -sticky nesw
    set ::cb_b_preb 0
    set ::cb_b_name 0
    set ::zipteinfo_initials  ""
    set ::zipteinfo_dest      ""
    set ::zipteinfo_ttyp      ""
    set ::zipteinfo_btyp      ""
    set ::zipteinfo_pext      ""
  
    ttk::style configure cb300.TCheckbutton -foreground grey
    ttk::style configure cb301.TCheckbutton -foreground grey
    
    grid  [ttk::label       .fr_backup.lb300  -text "               Prebuilt files not found."          -foreground $::colors(-blue)                                    ] -row 0 -column 1                -sticky w
    grid  [ttk::checkbutton .fr_backup.cb300  -text "include prebuilt files"  -style cb300.TCheckbutton -variable ::cb_b_preb  -command {::TE::DEV::check_backup_cbpreb}] -row 0 -column 0 -columnspan 2  -sticky w
    
    grid  [ttk::checkbutton .fr_backup.cb301  -text "zip-file name:"          -style cb301.TCheckbutton -variable ::cb_b_name  -command {::TE::DEV::check_backup_cbname}] -row 1 -column 0                -sticky w 
    grid  [text             .fr_backup.tx301  -height 1                       -width 97                 -wrap none                                                      ] -row 1 -column 1 -columnspan 4  -padx 5
  
    # zip_teinfo settings
    grid  [ttk::frame       .fr_backup.fr_zip_teinfo ] -row 2 -column 0 -sticky nesw
    grid  [ttk::label       .fr_backup.fr_zip_teinfo.lb302 -text "zip-teinfo:" -font ownfont_bold ]  -row 2 -column 0 -sticky w
    # zip_teinfo initals
    grid  [ttk::frame       .fr_backup.fr_initials ] -row 2 -column 1 -sticky nesw
    grid  [ttk::label       .fr_backup.fr_initials.lb320 -text "Initials"          -font ownfont_bold  ]  -row 2 -column 1 -sticky w
    grid  [ttk::entry       .fr_backup.fr_initials.en321 -textvariable ::zipteinfo_initials -width 15      ]  -row 3 -column 1 -sticky w 
    # zip_teinfo destination
    grid  [ttk::frame       .fr_backup.fr_dest ] -row 2 -column 2 -sticky nesw
    grid  [ttk::label       .fr_backup.fr_dest.lb330 -text "Destination"              -font ownfont_bold ] -row 0 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_dest.rb331 -text "PublicDoc"                -variable ::zipteinfo_dest -value "PublicDoc"   -command {::TE::DEV::check_backup_rb_zipteinfo} ] -row 1 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_dest.rb332 -text "Production"               -variable ::zipteinfo_dest -value "Production"  -command {::TE::DEV::check_backup_rb_zipteinfo} ] -row 2 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_dest.rb333 -text "Development"              -variable ::zipteinfo_dest -value "Development" -command {::TE::DEV::check_backup_rb_zipteinfo} ] -row 3 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_dest.rb334 -text "Preliminary"              -variable ::zipteinfo_dest -value "Preliminary" -command {::TE::DEV::check_backup_rb_zipteinfo} ] -row 4 -sticky w
    # zip_teinfo test type
    grid  [ttk::frame       .fr_backup.fr_ttyp ] -row 2 -column 3 -sticky nesw  
    grid  [ttk::label       .fr_backup.fr_ttyp.lb340 -text "Test Type"                -font ownfont_bold ] -row 0 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_ttyp.rb341 -text "Manual Test"              -variable ::zipteinfo_ttyp -value "MT"        ] -row 1 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_ttyp.rb342 -text "Halfautomatic Test"       -variable ::zipteinfo_ttyp -value "HT"        ] -row 2 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_ttyp.rb343 -text "Automatic Test System"    -variable ::zipteinfo_ttyp -value "ATS"       ] -row 3 -sticky w
    grid  [ttk::radiobutton  .fr_backup.fr_ttyp.rb344 -text "Others"                  -variable ::zipteinfo_ttyp -value "NA"        ] -row 4 -sticky w
    # zip_teinfo board type
    grid  [ttk::frame       .fr_backup.fr_btyp ] -row 2 -column 4 -sticky nesw
    grid  [ttk::label       .fr_backup.fr_btyp.lb350 -text "Board Type"               -font ownfont_bold ] -row 0 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_btyp.rb351 -text "Module Test Export"       -variable ::zipteinfo_btyp -value "Module"      ] -row 1 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_btyp.rb352 -text "Carrier Test Export"      -variable ::zipteinfo_btyp -value "Carrier"     ] -row 2 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_btyp.rb353 -text "Motherboard Test Export"  -variable ::zipteinfo_btyp -value "Motherboard" ] -row 3 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_btyp.rb354 -text "FMC-Card Test Export"     -variable ::zipteinfo_btyp -value "FMC-Card"    ] -row 4 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_btyp.rb355 -text "PCIe-Card Test Export"    -variable ::zipteinfo_btyp -value "PCIe-Card"   ] -row 5 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_btyp.rb356 -text "Others"                   -variable ::zipteinfo_btyp -value "NA"          ] -row 6 -sticky w
    # zip_teinfo init.sh extension
    grid  [ttk::frame       .fr_backup.fr_pext ] -row 2 -column 5 -sticky nesw
    grid  [ttk::label       .fr_backup.fr_pext.lb360 -text "init.sh extention"        -font ownfont_bold ] -row 0 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_pext.rb361 -text "with extentions"          -variable ::zipteinfo_pext -value "yes"         ] -row 1 -sticky w
    grid  [ttk::radiobutton .fr_backup.fr_pext.rb362 -text "without extentions"       -variable ::zipteinfo_pext -value "NA"          ] -row 2 -sticky w
    # start generate backup files - button  
    grid  [ttk::button      .fr_backup.btn_gen_bckup -text "Generate backup" -width 30 -command {::TE::DEV::generate_backup}          ] -row 9 -column 5 -sticky e
    grid  [ttk::label       .fr_backup.lb390         -foreground $::colors(-red)                                                      ] -row 9 -column 0 -columnspan 5 -padx 3 -sticky w
  

  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- messages box
    grid  [ttk::labelframe  .fr_msg     -text "Messages"] -row 5 -column 0 -columnspan 3 -padx 10 -pady 3 -sticky nesw
    grid  [text             .fr_msg.tx  -height 15        -width 135  -wrap word  -yscrollcommand {.fr_msg.sbY set} ] -row 0 -column 0 -columnspan 3  -sticky nesw
    grid  [ttk::scrollbar   .fr_msg.sbY -orient vertical                          -command {.fr_msg.tx yview}       ] -row 0 -column 3                -sticky ns
    .fr_msg.tx insert end "-------------------------------------------------------------------------------------------------------------------------\
                         \nDevelopment Utilities:\
                         \n  -> generate source files\
                         \n  -> create prebuilt files from all devices\
                         \n  -> backup project with prebuilt files\
                         \n  -> backup project without prebuilt files\
                         \n-------------------------------------------------------------------------------------------------------------------------\n"                       
    .fr_msg.tx configure -state disabled
    .fr_msg.tx see end
    .fr_msg.tx tag configure error_msg            -foreground $::colors(-red)
    .fr_msg.tx tag configure critical_warning_msg -foreground $::colors(-magenta)
    .fr_msg.tx tag configure warning_msg          -foreground $::colors(-blue)
    .fr_msg.tx tag configure info_msg             -foreground $::colors(-green)
  
#  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#    #--------------------------------
#    #-- buttons to start process  
#    grid  [ttk::frame .fr_bottom          -padding {3 3 3 3}] -row 6 -column 0 -columnspan 4 -pady 3 -sticky e
#    grid  [ttk::button .fr_bottom.btn_exit    -text "Exit" -width 28 -command {::TE::DEV::exit_tk}]  -row 0 -column 4 -padx 4  -pady 10 -sticky e
#
#  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- progressbar  
    grid [ttk::frame .fr_status       -padding {0 0 3 3}          ] -row 6                    -sticky w
    grid [ttk::label .fr_status.lb600 -foreground $::colors(-blue)] -row 0 -column 0 -padx 3  -sticky w
  
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- enable output for processing messages
    tsv::set ::TE::TK_MSG_EN ::TK 1  
    
    #--------------------------------
    # check if wsl is installed
    if {$::tcl_platform(platform) eq "windows"} {
      set need_cmd [list]
      if {${::TE::WSL_EN} eq 0} {
        thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-02 -msg "Windows Subsystem for Linux (WSL) is not installed. The software project can't be created. For more information and installation instructions, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
      } elseif {${::TE::WSL_EN} eq 1} {
        thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-03 -msg "No Linux distribution installed for WSL. The software project can't be created. For more information and installation instructions, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
      } elseif {${::TE::WSL_EN} eq 2} {
        set command exec 
        lappend command wsl
        lappend command wsl
        catch {eval $command} result
        if {[string match "*command not found*" $result]} {
          thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-04 -msg "Command 'wsl' not found.  Please install with: sudo apt install wsl" }
          lappend need_cmd wsl
        }
        set command exec 
        lappend command wsl 
        lappend command make
        lappend command -q
        catch {eval $command} result
        if {[string match "*command not found*" $result]} {
          thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-05 -msg "Command 'make' not found.  Please install with: sudo apt install make" }
          lappend need_cmd make
        }
        set command exec 
        lappend command wsl 
        lappend command dos2unix
        lappend command --version
        catch {eval $command} result
        if {[string match "*command not found*" $result]} {
          thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-06 -msg "Command 'dos2unix' not found.  Please install with: sudo apt install dos2unix" }
          lappend need_cmd dos2unix
        }
        if {$need_cmd ne ""} {
          thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-07 -msg \"Please install missing commands in the linux distribution. Can't create software project without commands ($need_cmd). For more information see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html\" "
          tsv::set need_cmd ::TK "$need_cmd"
        } else {
          set ::TE::WSL_EN 3
          tsv::set ::TE::WSL_EN ::TK 3
        }
      }
    }

    #--------------------------------
    # create and center create project window
    wm withdraw .    
    update
    set x [expr {([winfo screenwidth .]-[winfo width .])/3}]
    set y [expr {([winfo screenheight .]-[winfo height .])/4}]
    wm geometry . +$x+$y
    wm iconphoto . -default [image create photo -file ./scripts/logo.gif]
    wm title . "Development Tools"
    wm resizable . 0 0
    wm protocol . WM_DELETE_WINDOW {::TE::DEV::exit_tk}
    wm deiconify .
    
    #--------------------------------
    #-- init gui    
    ::TE::DEV::load_device_list
    ::TE::DEV::check_src_cb
    ::TE::DEV::check_backup_cbpreb
    ::TE::DEV::check_backup_cbname
    ::TE::DEV::check_backup_rb_zipteinfo
    ::TE::DEV::check_prebuilt_rb
    
    tkwait window .
  }
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished create gui
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
 #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- checkbutton control generate source files  
  proc check_src_cb {} {
    if {$::cb_qsrc eq 1 && [glob -nocomplain ${::TE::QPROJ_PATH}/*.qpf] ne ""} {
      .fr_src.tx200 configure -state normal   -foreground black
      ttk::style configure cb200.TCheckbutton -foreground black
      grid remove .fr_src.lb200  
    } else {  
      .fr_src.tx200 configure -state disabled -foreground grey
      ttk::style configure cb200.TCheckbutton -foreground grey  
      if {[glob -nocomplain ${::TE::QPROJ_PATH}/*.qpf] eq ""} { grid .fr_src.lb200 }
      set ::cb_qsrc 0
    }
    
    if {$::cb_ssrc eq 1 && [file exists ${::TE::SDK_PATH}]} {
      .fr_src.tx201 configure -state normal   -foreground black
      ttk::style configure cb201.TCheckbutton -foreground black
      grid remove .fr_src.lb201
    } else {
      .fr_src.tx201 configure -state disabled -foreground grey
      ttk::style configure cb201.TCheckbutton -foreground grey
      if {![file exists ${::TE::SDK_PATH}]} { grid .fr_src.lb201 }
      set ::cb_ssrc 0
    }
    
    if {$::cb_qsrc eq 0 && $::cb_ssrc eq 0} {
      .fr_src.btn_gen_src configure -state disabled
    } else {
      .fr_src.btn_gen_src configure -state normal
    }
  }
  
  #--------------------------------
  #-- checkbutton control generate source files with or without prebuilt files  
  proc check_backup_cbpreb {} {
    if {[glob -nocomplain ${::TE::PREBUILT_PATH}/*] eq ""} {
      .fr_backup.cb300 configure -state disabled
      grid .fr_backup.lb300
      set ::cb_b_preb 0
    } else {
      grid remove .fr_backup.lb300
    }
    
    if {$::cb_b_preb eq 1} {
      ttk::style configure cb300.TCheckbutton -foreground black
    } else {
      ttk::style configure cb300.TCheckbutton -foreground grey    
    }
  }
  
  #--------------------------------
  #-- checkbutton control generate source files with own name or with auto-generated name
  proc check_backup_cbname {} {
    if {$::cb_b_name eq 1} {
      .fr_backup.tx301 configure -state normal    -foreground black
      .fr_backup.tx301 delete 1.0 end
      .fr_backup.tx301 insert end $::own_name
      ttk::style configure cb301.TCheckbutton     -foreground black
    } else {
      set ::own_name "[string map {"\n" ""} [.fr_backup.tx301 get 1.0 end]]"
      .fr_backup.tx301 delete 1.0 end
      .fr_backup.tx301 insert end "auto-generated"
      .fr_backup.tx301 configure -state disabled  -foreground grey
      ttk::style configure cb301.TCheckbutton     -foreground grey    
    }
  }
  
  #--------------------------------
  #-- radiobutton control: backup - zip-teinfo 
  proc check_backup_rb_zipteinfo {} {
    if {$::zipteinfo_dest eq "Production"} {
      # ttyp - test type selection
      grid .fr_backup.fr_ttyp.lb340 -row 0 -sticky w
      grid .fr_backup.fr_ttyp.rb341 -row 1 -sticky w
      grid .fr_backup.fr_ttyp.rb342 -row 2 -sticky w
      grid .fr_backup.fr_ttyp.rb343 -row 3 -sticky w
      grid .fr_backup.fr_ttyp.rb344 -row 4 -sticky w
      # btyp - board type selection
      grid .fr_backup.fr_btyp.lb350 -row 0 -sticky w
      grid .fr_backup.fr_btyp.rb351 -row 1 -sticky w
      grid .fr_backup.fr_btyp.rb352 -row 2 -sticky w
      grid .fr_backup.fr_btyp.rb353 -row 3 -sticky w
      grid .fr_backup.fr_btyp.rb354 -row 4 -sticky w
      grid .fr_backup.fr_btyp.rb355 -row 5 -sticky w
      grid .fr_backup.fr_btyp.rb356 -row 6 -sticky w
      # pext - init.sh extension selection
      grid .fr_backup.fr_pext.lb360 -row 0 -sticky w
      grid .fr_backup.fr_pext.rb361 -row 1 -sticky w
      grid .fr_backup.fr_pext.rb362 -row 2 -sticky w
      set ::zipteinfo_ttyp ""
      set ::zipteinfo_btyp ""
      set ::zipteinfo_pext ""
      # include prebuilt files
      set ::cb_b_preb 1
      ::TE::DEV::check_backup_cbpreb
    } else {
      # ttyp - test type selection
      grid forget .fr_backup.fr_ttyp.lb340
      grid forget .fr_backup.fr_ttyp.rb341
      grid forget .fr_backup.fr_ttyp.rb342
      grid forget .fr_backup.fr_ttyp.rb343
      grid forget .fr_backup.fr_ttyp.rb344
      # btyp - board type selection
      grid forget .fr_backup.fr_btyp.lb350
      grid forget .fr_backup.fr_btyp.rb351
      grid forget .fr_backup.fr_btyp.rb352
      grid forget .fr_backup.fr_btyp.rb353
      grid forget .fr_backup.fr_btyp.rb354
      grid forget .fr_backup.fr_btyp.rb355
      grid forget .fr_backup.fr_btyp.rb356
      # pext - init.sh extension selection
      grid forget .fr_backup.fr_pext.lb360
      grid forget .fr_backup.fr_pext.rb361
      grid forget .fr_backup.fr_pext.rb362
      # radiobutton variables
      set ::zipteinfo_ttyp "NA"
      set ::zipteinfo_btyp "NA"
      set ::zipteinfo_pext "NA"
    }
  }
  
  #--------------------------------
  #-- checkbutton cb_preb_all control generate prebuilt files
  proc check_prebuilt_rb {} {
    if {$::rb_preb eq "preball"} {
      .fr_preb.lbox402 configure  -state disabled
    } else {
      .fr_preb.lbox402 configure  -state normal
    }
  }
  
  #--------------------------------
  #-- check if shortnames and source files are available
  proc check_proj_sources {} {
    tsv::get ::TE::QPROJ_SRC_NAME ::TK ::TE::QPROJ_SRC_NAME
    if {$::shortnamelist eq "" || $::shortnamelist eq "Shortnames not found." || [llength ${::TE::QPROJ_SRC_NAME}] ne 1} {
      if {$::shortnamelist eq "" || $::shortnamelist eq "Shortnames not found."} {
        set ::shortnamelist "\"Shortnames not found.\""
        .fr_preb.lbox402 configure -state disabled
      }
      if {![file exist ${::TE::SOURCE_PATH}/[lindex $::shortnamelist 0]/${::TE::QPROJ_SRC_NAME}.tcl]} {  
        if {[llength ${::TE::QPROJ_SRC_NAME}] > 1} {
          .fr_preb.lb403 configure -text "Found Project source files for more than one project.\nProject names: ${::TE::QPROJ_SRC_NAME}"
        } else {
          .fr_preb.lb403 configure -text "Quartus source files not found."
        }
      }
      .fr_preb.btn_gen_preb configure -state disabled
      return 0
    }
    .fr_preb.btn_gen_preb configure -state normal
    .fr_preb.lb403 configure -text ""
  }
  
  #--------------------------------
  #-- check software project sources
  proc check_sdk_sources {nios_sopcfile_list} {
    set ::nios_sopcfile_list $nios_sopcfile_list
    set ::cancel_sdk_window 0
    if {[file exists ${::TE::SOURCE_PATH}/${::selected_shortname}/software]} { set ::TE::SDK_SOURCE_PATH ${::TE::SOURCE_PATH}/${::selected_shortname}/software }
    # search for software projects in SDK_SOURCE_PATH
    set ::sdk_src_tmp_list [glob -nocomplain -tail -types d -directory ${::TE::SDK_SOURCE_PATH}/ *]
    # search for apps_list.csv file
    if { [file exist ${::TE::SDK_SOURCE_PATH}/apps_list.csv] } {
      set ::TE::SDK_SRC_LIST [list]
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type info -id TE_DEV-37 -msg \"Read sdk apps list (File: ${::TE::SDK_SOURCE_PATH}/apps_list.csv).\" "
      #read apps_list.csv file
      set fp [open "${::TE::SDK_SOURCE_PATH}/apps_list.csv" r]
      set file_data [read $fp]
      close $fp
      set data [split $file_data "\n"]
      foreach line $data {
        if { [string match #* $line] != 1 } {
          #remove spaces and tabs
          set line [string map {" " ""} $line]
          set line [string map {"\t" ""} $line]
          #check version
          if { [string match CSV_VERSION* $line] } {
            set tmp [split $line "="]
            if { [string match [lindex $tmp 1] ${::TE::APPSLIST_CSV}] != 1 } {
              ::TE::UTILS::te_msg -type error -id TE_DEV-38 -msg "Wrong apps list CSV Version (${::TE::SDK_SOURCE_PATH}/apps_list.csv) get [lindex $tmp 1] expected ${::TE::APPSLIST_CSV}."
              return -code error
            } 
          } elseif { [string length $line] > 0 } {
            set tmp [split $line ","]
            if { [string match */[lindex $tmp 0]/* ${::TE::QPROJ_SOURCE_PATH}] } {
              lappend ::TE::SDK_SRC_LIST "[lindex $tmp 1]"
            } elseif { [string match *[lindex $tmp 0]* "default"] && ${::TE::SDK_SRC_LIST} eq ""} {
              lappend ::TE::SDK_SRC_LIST "[lindex $tmp 1]"
            }
          }
        }
      }
      if { [llength ${::TE::SDK_SRC_LIST}] ne 0 } {
        tsv::set ::TE::SDK_SRC_LIST ::TK "$::TE::SDK_SRC_LIST"
        return 0
      }
    }
    
    if { [llength ${::sdk_src_tmp_list}] > 1 || [llength ${::nios_sopcfile_list}] > 1 } {
      # create dialog window to select software project
      # set toplevel
      toplevel .selectsdk -class Dialog
    
      grid [ttk::frame .selectsdk.background                      ] -sticky nesw -rowspan 10 -columnspan 10 
      grid [ttk::frame .selectsdk.fr_info -padding {10 10 10 10}  ] -sticky nesw -row 0
      
      if { [llength ${::nios_sopcfile_list}] eq 1 } {
        grid [ttk::label .selectsdk.fr_info.lb700 -text "Found more than one software project in source files.\nPlease select one project:" -padding {0 0 10 0} ] -row 0 -column 0 -padx 2 -pady 2 -sticky nw
      } elseif { [llength ${::sdk_src_tmp_list}] eq 1 } {
        grid [ttk::label .selectsdk.fr_info.lb700 -text "Found more than one implemented nios2 processor in the project.\nPlease select correct *.sopcinfo file for the project:" -padding {0 0 10 0} ] -row 0 -column 0 -padx 2 -pady 2 -sticky nw
      } else {
        grid [ttk::label .selectsdk.fr_info.lb700 -text "Found more than one implemented nios2 processor and multiple software projects.\nPlease select max. [llength ${::nios_sopcfile_list}] projects with correct *.sopcinfo file:" -padding {0 0 10 0} ] -row 0 -column 0 -padx 2 -pady 2 -sticky nw
      }
      grid [ttk::frame .selectsdk.fr_select -padding {10 10 10 10} ] -sticky nesw -row 1  
      set ::selected_sdk_list [list]
      set ::sdk_select0 1
      grid [ttk::checkbutton  .selectsdk.fr_select.cb700 -text "No Project" -variable ::sdk_select0 -command { ::TE::DEV::cb_select_sdk_project [llength ${::nios_sopcfile_list}] } ] -row 0 -sticky w
      set i 1
      # create checkbutton for each software prject
      foreach project ${::sdk_src_tmp_list} {
        grid [ttk::checkbutton  .selectsdk.fr_select.cb70$project -text "$project" -variable ::sdk_select$project -command { ::TE::DEV::cb_select_sdk_project [llength ${::nios_sopcfile_list}] }] -row $i -column 0 -sticky w
        set ::sdk_select$project 0
        # if there is more than one sopcinfo file, create combobox for sopcinfo files
        if { [llength ${::nios_sopcfile_list}] > 1 } {
          set ::selected_sopcinfo$project "<*.sopcinfo>"
          grid [ttk::combobox  .selectsdk.fr_select.cb_sopcinfo70$project -state disabled -values ${::nios_sopcfile_list} -textvariable ::selected_sopcinfo$project -width $::comboboxwidth ] -row $i -column 2 -sticky w             
        } else {
          set ::selected_sopcinfo$project ${::nios_sopcfile_list}
        }
        # search for software project description
        grid [ttk::label    .selectsdk.fr_select.lb70$i  -text "" ] -row $i -column 1 -sticky w
        if {[file exists ${::TE::SDK_SOURCE_PATH}/$project/template.xml]} {
          set fp [open "${::TE::SDK_SOURCE_PATH}/$project/template.xml" r]
          set file_data [read $fp]
          close $fp
          set descr "no description found"
          regexp -line {(.*)description=\"(.*)\"} $file_data matched sub1 descr
          .selectsdk.fr_select.lb70$i configure -text " - $descr"
        } else {
          .selectsdk.fr_select.cb70$i configure -state disabled
          .selectsdk.fr_select.lb70$i configure -text " - template.xml file not found" -state disabled
        }
        set i [expr $i+1]
      }

      if { [llength ${::sdk_src_tmp_list}] eq 1 } {
        set ::sdk_select0 0
        set ::sdk_select${::sdk_src_tmp_list} 1
      }
      
      grid [ttk::separator .selectsdk.s700 -orient horizontal   ] -row 2 -sticky ew
      
      grid [ttk::frame .selectsdk.fr_btn -padding {10 10 10 10} ] -row 3 -sticky es
      grid [ttk::button .selectsdk.fr_btn.ok_btn    -text "OK"     -width [expr $::buttonwidth/2] -command { ::TE::DEV::check_selected_sdk_project [llength ${nios_sopcfile_list}]} ] -row 0 -padx 4 -sticky e
      grid [ttk::button .selectsdk.fr_btn.cancel_btn   -text "Cancel"   -width [expr $::buttonwidth/2] -command {set ::cancel_sdk_window 1; destroy .selectsdk; thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_DEV-39 -msg "Process canceled." };} ] -row 0 -column 1 -padx 4 -sticky e
    
      # create and center create new project window
      wm withdraw .selectsdk
      update    
      set x_selectsdk [expr {([winfo screenwidth .]-[winfo width .selectsdk])/3}]
      set y_selectsdk [expr {([winfo screenheight .]-[winfo height .selectsdk])/4}]
      wm geometry .selectsdk +$x_selectsdk+$y_selectsdk
      wm title .selectsdk "Select software project"
      wm resizable .selectsdk 0 0
      wm protocol .selectsdk WM_DELETE_WINDOW {set ::cancel_sdk_window 1; destroy .selectsdk}
      wm deiconify .selectsdk
    
      tk::SetFocusGrab .selectsdk
      tkwait window .selectsdk
    } elseif { [llength ${::sdk_src_tmp_list}] eq 1 && [llength ${::nios_sopcfile_list}] eq 1 } {
      tsv::set ::TE::SDK_SRC_LIST ::TK "${::sdk_src_tmp_list}|${::nios_sopcfile_list}"
    } elseif {[llength ${::sdk_src_tmp_list}] eq 0 || [llength ${::nios_sopcfile_list}] eq 0 } {
      # set ::TE::SDK_SRC_LIST "no_project"
      tsv::set ::TE::SDK_SRC_LIST ::TK "no_project"
    }
  }
  
  #--------------------------------
  #-- check selected software project  
  proc check_selected_sdk_project {length_nios_sopcinfo_list} {
    set ::TE::SDK_SRC_LIST [list]
    foreach sdk $::selected_sdk_list {
      # check if sopcinfo for each marked SW project is selected
      if { [subst \$::selected_sopcinfo$sdk] eq "<*.sopcinfo>" } {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-35 -msg \"No *.sopcinfo file selected for '$sdk'.\" "
        return 0
      # warning for selected same sopcinfo file for min 2 SW projects
      } elseif {[string match "*|[subst \$::selected_sopcinfo$sdk]*" ${::TE::SDK_SRC_LIST}]} {
        set sdkanswer [tk_messageBox  -title "Error" -message "You has selected the same *.sopcinfo file for min. 2 projects.\n\nPlease select different *.sopcinfo files." -icon error -type ok]
        return 0
      } else {
        lappend ::TE::SDK_SRC_LIST "$sdk|[subst \$::selected_sopcinfo$sdk]"
      }
    }
    # save settings in apps_list.csv
    # if { ${length_nios_sopcinfo_list} > 1 } {
      set sdkanswer [tk_messageBox  -title "Save SDK settings" -message "Should the settings made for this project be saved?" -icon question -type yesno -default no]
      if { $sdkanswer eq "yes" } { 
        if {![file exist ${::TE::SDK_SOURCE_PATH}/apps_list.csv]} {
          set fp [open ${::TE::SDK_SOURCE_PATH}/apps_list.csv w]
          puts $fp "#CSV_VERSION=$::TE::APPSLIST_CSV
                  \n# ####################################################################\
                  \n# #\
                  \n# # apps_list.csv\
                  \n# #\
                  \n# # Comment: auto-generated file - do not change matrix position use!\
                  \n# #\
                  \n# ####################################################################\
                  \n# #\
                  \n# source_files_quartus,software_name|sopcfilename\
                  \n# #"
        } else {
          set fp [open ${::TE::SDK_SOURCE_PATH}/apps_list.csv a]
        }
      
        regsub "${::TE::BASEFOLDER}" ${::TE::QPROJ_SOURCE_PATH} {} tmp_qproj_source_path
      
        foreach line ${::TE::SDK_SRC_LIST} {
          puts $fp "${tmp_qproj_source_path},$line"
        }
      
        close $fp
      }
    # }
    # close window selectsdk
    destroy .selectsdk
    tsv::set ::TE::SDK_SRC_LIST ::TK "$::TE::SDK_SRC_LIST"
  }
  
  #--------------------------------
  #-- select software project
  proc cb_select_sdk_project {length_nios_sopcinfo_list} {
    set tmp_sdk "[[winfo containing [winfo pointerx .selectsdk] [winfo pointery .selectsdk]] cget -text]"
    if { $tmp_sdk ne "No Project" && [llength ${::selected_sdk_list}] <= $length_nios_sopcinfo_list } {
      set ::sdk_select0 0
      # if there is only one sopcinfo file, older sw project selection will deselected automatically
      if { ${length_nios_sopcinfo_list} eq 1 && $tmp_sdk ne ${::selected_sdk_list} } { 
        set ::sdk_select${::selected_sdk_list} 0
        set ::selected_sdk_list [list]
      }
      # check if maximum number of allowed SW porjects is selected
      if { $tmp_sdk ne "No Project" && [llength ${::selected_sdk_list}] eq $length_nios_sopcinfo_list && [subst \$::sdk_select$tmp_sdk] eq 1 } {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_DEV-36 -msg \"The maximum number of sdk projects are already selected.\" "
        set ::sdk_select$tmp_sdk 0
        return 0
      }
      # check if SW project was deselected, if yes: remove project from list - else add SW project to list
      if { [lsearch $::selected_sdk_list $tmp_sdk] ne -1 } {
        if { $length_nios_sopcinfo_list > 1 } { .selectsdk.fr_select.cb_sopcinfo70$tmp_sdk configure -state disabled }
        set ::selected_sopcinfo$tmp_sdk "<*.sopcinfo>"
        set idx [lsearch $::selected_sdk_list "$tmp_sdk"]
        set ::selected_sdk_list [lreplace $::selected_sdk_list $idx $idx]
      } else {
        if { $length_nios_sopcinfo_list > 1 } { .selectsdk.fr_select.cb_sopcinfo70$tmp_sdk configure -state readonly }
        lappend ::selected_sdk_list "$tmp_sdk"
      }
      if {[llength $::selected_sdk_list] eq 0 } { set ::sdk_select0 1 } 
    # if "No Project" is selected, deselect and remove all SW projects
    } elseif { $tmp_sdk eq "No Project" } {
      set ::sdk_select0 1
      foreach sel $::selected_sdk_list {
        set ::sdk_select$sel 0
        set ::selected_sopcinfo$sel "<*.sopcinfo>"
        if { $length_nios_sopcinfo_list > 1 } { .selectsdk.fr_select.cb_sopcinfo70$sel configure -state disabled }
      }
      set ::selected_sdk_list [list]
    }
  }
  
  #--------------------------------
  #-- read shortnames from device list file for prebuilt
  proc set_shortlist {} {
    set ::shortnamelist [list]
    foreach line $::dev_csv_data {
      if {![string match *SHORTNAME* $line] && ![string match *GENERAL_INFO* $line] && ![string match *#* $line] && ![string match *CSV_VERSION* $line]} {  
        set data [string map {" " ""} $line]
        set data [split $data ","]
        if {[lsearch -exact $::shortnamelist [lindex $data 4]] eq -1} {
          lappend ::shortnamelist [lindex $data 4]
        }
      }
    }
    ::TE::DEV::check_proj_sources
  }

  #--------------------------------
  #-- load device list csv
  proc load_device_list {} {
  
    if {$::rb_devlist eq "devlist"} {
      if { ![catch {set ::dev_csv_filedir [ glob ${::TE::BOARDDEF_PATH}/*_devices.csv ] }] } {
        set ::csvname [lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices.csv
        grid remove .fr_dev.lb102
        grid remove .fr_dev.en100
        grid remove .fr_dev.lb103
        grid remove .fr_dev.en101
        grid remove .fr_dev.btn_csv_ok
        .fr_dev.rb101 configure -state normal
        set fp [open "${::dev_csv_filedir}" r]
        set ::dev_csv_data [read $fp]
        close $fp
        set ::dev_csv_data [split $::dev_csv_data "\n"]
        .fr_dev.rb100 configure -text "[lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices.csv"
        .fr_dev.rb101 configure -text "[lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices_mod.csv"
        .fr_dev.tx100 delete 1.0 end
        foreach line $::dev_csv_data {
          .fr_dev.tx100 insert end "$line\n"
        }
      } else {
        thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-10 -msg "<module>_devices.csv doesn't exist. Enter Module and Category." }
        grid .fr_dev.lb102
        grid .fr_dev.en100
        grid .fr_dev.lb103
        grid .fr_dev.en101
        grid .fr_dev.btn_csv_ok
        set ::moduleseries "<Enter module series>"
        .fr_dev.en100 configure -foreground #9e9e9e
        set ::category "<Enter category>"
        .fr_dev.en101 configure -foreground #9e9e9e
        .fr_dev.rb100 configure -text "<Module>_devices.csv"
        .fr_dev.rb101 configure -text "<Module>_devices_mod.csv"
        focus .fr_dev.en100
        .fr_dev.rb101 configure -state disabled
        .fr_dev.tx100 delete 1.0 end
        .fr_dev.tx100 insert end "<module>_devices.csv doesn't exist. Enter Module and Category."
        .fr_dev.tx100 configure -state disabled
        .fr_dev.btn_csv_ow configure -state disabled
      }
    } 
    if {$::rb_devlist eq "devmodlist"} {
      if { ![catch {set ::dev_csv_mod_filedir [ glob ${::TE::BOARDDEF_PATH}/*_devices_mod.csv ] }] && ![catch {set ::dev_csv_filedir [ glob ${::TE::BOARDDEF_PATH}/*_devices.csv ] }] } {
        set ::csvname [lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices_mod.csv
        set fp [open "${::dev_csv_mod_filedir}" r]
        set ::dev_csv_data [read $fp]
        close $fp
        set ::dev_csv_data [split $::dev_csv_data "\n"]
        .fr_dev.rb100 configure -text "[lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices.csv"
        .fr_dev.rb101 configure -text "[lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices_mod.csv"
        .fr_dev.tx100 delete 1.0 end
        foreach line $::dev_csv_data {
          .fr_dev.tx100 insert end "$line\n"
        }
      } 
    }
    if { [catch {set ::dev_csv_mod_filedir [ glob ${::TE::BOARDDEF_PATH}/*_devices_mod.csv ] }] && ![catch {set ::dev_csv_filedir [ glob ${::TE::BOARDDEF_PATH}/*_devices.csv ] }] } {
      .fr_dev.rb101 configure -text "[lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices_mod.csv   -> file doesn't exist."
      if {$::rb_devlist eq "devmodlist"} {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_DEV-11 -msg \"[lindex [split [file tail $::dev_csv_filedir] "_"] 0]_devices_mod.csv doesn't exist. 'Write to file' command will generate new file.\" "
      }
    }
    
    ::TE::DEV::set_shortlist
  }
  
  #--------------------------------
  #-- set module series for generating <module>_devices.csv
  proc set_module {} {
    if { $::moduleseries == "<Enter module series>" }  {
      set ::moduleseries ""
      .fr_dev.en100 configure -foreground $::colors(-black)
    } elseif { [string map {" " ""} $::moduleseries] == "" } {
      set ::moduleseries "<Enter module series>"
      .fr_dev.en100 configure -foreground #9e9e9e
    }
    return 0
  }
  
  #--------------------------------
  #-- set category for generating <module>_devices.csv
  proc set_category {} {
    if { $::category == "<Enter category>" }  {
      set ::category ""
      .fr_dev.en101 configure -foreground $::colors(-black)
    } elseif { [string map {" " ""} $::category] == "" } {
      set ::category "<Enter category>"
      .fr_dev.en101 configure -foreground #9e9e9e
    }
    return 0
  }
  
  #--------------------------------
  #-- insert template for generating <module>_devices.csv
  proc create_dev_csv {} {
    if { $::moduleseries == "<Enter module series>" }  {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-12 -msg \"Module: Empty string. Enter Module.\" "
      focus .fr_dev.en100
      return 0
    } elseif { $::category == "<Enter category>" }  {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-13 -msg \"Category: Empty string. Enter Category.\" "
      focus .fr_dev.en101
      return 0
    }
    .fr_dev.tx100 configure -state normal
    .fr_dev.tx100 delete 1.0 end
    set ::template "CSV_VERSION=$::TE::BOARDDEF_CSV \
                  \nGENERAL_INFO=Category $::category, \
                  \n#Comment:-do not change matrix position or remove CSV_VERSION or GENERAL_INFO: \
                  \nID  ,PRODID                 ,FAMILY             ,DEVICE             ,SHORTNAME         ,FLASHTYP       ,FLASH_SIZE     ,DDR_DEV                                ,DDR_SIZE       ,PCB_REV     ,NOTES"
    
    set file "${::TE::BOARDDEF_PATH}/${::moduleseries}_devices.csv"
    set fp_w [open ${file} "w"]
    puts $fp_w $::template
    close $fp_w
    
    ::TE::DEV::load_device_list
    .fr_dev.btn_csv_ow configure -state normal
    thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type info -id TE_DEV-14 -msg \"$file created.\" "
  }
  
  #--------------------------------
  #-- overwrite device list csv
  proc write_file {} {
    if {$::writing_to_file eq 1 || $::generating_source_files eq 1 || $::generating_backup eq 1 || $::generating_prebuilt eq 1} {
      .fr_status.lb600 configure -text "Process is running. Please wait until the process finished."
      after 5000 {.fr_status.lb600 configure -text ""}
      return 0
    }
    
    set ::writing_to_file 1
    set ::textcontent [.fr_dev.tx100 get 1.0 end]
    if {![file exists ${::TE::BOARDDEF_PATH}/$::csvname]} {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_DEV-15 -msg \"${::TE::BOARDDEF_PATH}/$::csvname] not exist. Create new file.\" "
    }
    set file "${::TE::BOARDDEF_PATH}/$::csvname"
    set fp_w [open ${file} "w"]
    puts $fp_w $::textcontent
    close $fp_w
    thread::send -async $::TE::MAINTHREAD { ::TE::INIT::init_boardlist }
    .fr_dev.tx100 delete 1.0 end
    ::TE::DEV::load_device_list
    set ::writing_to_file 0
  }

  #--------------------------------
  #-- generate prebuilt files
  proc generate_prebuilt {} {
    if {$::writing_to_file eq 1 || $::generating_source_files eq 1 || $::generating_backup eq 1 || $::generating_prebuilt eq 1} {
      .fr_status.lb600 configure -text "Process is running. Please wait until the process finished."
      after 5000 {.fr_status.lb600 configure -text ""}
      return 0
    }
    # start generating prebuilt files
    set ::generate_list [list]  
    if {$::rb_preb eq "preball"} {
      set ::generate_list $::shortnamelist
    } elseif {$::rb_preb eq "prebsel" && [.fr_preb.lbox402 curselection] ne ""} {
      foreach line [.fr_preb.lbox402 curselection] {
        lappend ::generate_list [lindex $::shortnamelist $line]        
      }
    } else {
      thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type error -id TE_DEV-16 -msg "Generate prebuilt: No shortname selected." }
      set ::generating_prebuilt 0
      return 0
    }
    
    
    
    
    #set global variables to correct device variant from device_list
    if {$::generate_list eq "all"} {
      thread::send -async $::TE::MAINTHREAD { if {[catch {eval ::TE::UTILS::clean_prebuilt "all"} result]} {::TE::UTILS::te_msg -type error -id TE_DEV-40 -msg "Error on ::TE::UTILS::clean_prebuilt:\n$result"} }
    }
    set short_list_done [list]
    foreach line ${::TE::BOARD_DEFINITION} {
      if {[lsearch -exact $short_list_done [lindex $line 4]] eq -1 && ![string match *SHORTNAME* $line] && $::generate_list eq "all"} {      
        set ::generating_prebuilt 1
        lappend short_list_done [lindex $line 4]
        set ::selected_shortname [lindex $line 4]
        set ::selected_id [lindex $line 0]
        # initialize selected board for project generation
        set ::init_board_done 0
        thread::send -async $::TE::MAINTHREAD " if {\[catch {::TE::INIT::init_board \[::TE::BDEF::get_id $::selected_id\]} result\]} {::TE::UTILS::te_msg -type error -id TE_DEV-42 -msg \"Script (TE::INIT::init_board) failed: \$result.\"; return -code error} "                
        vwait ::init_board_done
        tsv::get ::TE::QPROJ_SOURCE_PATH     ::TK ::TE::QPROJ_SOURCE_PATH
        tsv::get ::TE::SDK_SOURCE_PATH       ::TK ::TE::SDK_SOURCE_PATH
        tsv::get ::TE::NIOS_SRC_SOPC_FILE_LIST  ::TK ::TE::NIOS_SRC_SOPC_FILE_LIST
        # check if more than one software project exists
        ::TE::DEV::check_sdk_sources ${::TE::NIOS_SRC_SOPC_FILE_LIST}
        if { $::cancel_sdk_window eq 1 } { return 0 }
        thread::send -async $::TE::MAINTHREAD " ;\
                        if {\[catch {::TE::DES::export_project_preb $::selected_id} result]} {::TE::UTILS::te_msg -type error -id TE_DEV-17 -msg \"(TE) Script (TE::DES::export_project_preb $::selected_id) failed: \$result.\"} ;\
                        thread::send -async [thread::id] {::TE::DEV::check_backup_cbpreb; set ::generating_prebuilt 0} ;\
                      "
        vwait ::generating_prebuilt
      } elseif {$::generate_list ne "all"} {
        foreach shortname $::generate_list {
          if {[lsearch -exact $short_list_done [lindex $line 4]] eq -1 && ![string match *SHORTNAME* $line] && [string match *[lindex $line 4]* $shortname]} {    
            set ::generating_prebuilt 1
            lappend short_list_done [lindex $line 4]
            set ::selected_shortname [lindex $line 4]
            set ::selected_id [lindex $line 0]
            thread::send -async $::TE::MAINTHREAD " if {\[catch {eval ::TE::UTILS::clean_prebuilt [lindex $line 4]} result\]} {::TE::UTILS::te_msg -type error -id TE_DEV-41 -msg \"Error on ::TE::UTILS::clean_prebuilt [lindex $line 4]:\n\$result\"} "
            # initialize selected board for project generation
            set ::init_board_done 0
            thread::send -async $::TE::MAINTHREAD " if {\[catch {::TE::INIT::init_board \[::TE::BDEF::get_id $::selected_id\]} result\]} {::TE::UTILS::te_msg -type error -id TE_DEV-43 -msg \"Script (TE::INIT::init_board) failed: \$result.\"; return -code error} "                
            vwait ::init_board_done
            tsv::get ::TE::QPROJ_SOURCE_PATH     ::TK ::TE::QPROJ_SOURCE_PATH
            tsv::get ::TE::SDK_SOURCE_PATH       ::TK ::TE::SDK_SOURCE_PATH
            tsv::get ::TE::NIOS_SRC_SOPC_FILE_LIST  ::TK ::TE::NIOS_SRC_SOPC_FILE_LIST  
            # check if more than one software project exists
            ::TE::DEV::check_sdk_sources ${::TE::NIOS_SRC_SOPC_FILE_LIST}
            if { $::cancel_sdk_window eq 1 } { return 0 }
            thread::send -async $::TE::MAINTHREAD " ;\
                        if {\[catch {::TE::DES::export_project_preb {$::selected_id}} result]} {::TE::UTILS::te_msg -type error -id TE_DEV-17 -msg \"(TE) Script (TE::DES::export_project_preb) failed: \$result.\"} ;\
                        thread::send -async [thread::id] {::TE::DEV::check_backup_cbpreb; set ::generating_prebuilt 0} ;\
                      "
            vwait ::generating_prebuilt
          }
        }
      }
    }
  }

  #--------------------------------
  #-- check if directory exists and generate source files  
  proc generate_source_files {} {
    if {$::writing_to_file eq 1 || $::generating_source_files eq 1 || $::generating_backup eq 1 || $::generating_prebuilt eq 1} {
      .fr_status.lb600 configure -text "Process is running. Please wait until the process finished."
      after 5000 {.fr_status.lb600 configure -text ""}
      return 0
    }
      
    set qsrcdir [string map {"\n" ""} [.fr_src.tx200 get 1.0 end]]
    set ssrcdir [string map {"\n" ""} [.fr_src.tx201 get 1.0 end]]
    set qanswer ""
    set sanswer ""
    
    if {[file exists $qsrcdir] && $::cb_qsrc eq 1} {
      if {${::TE::QPROJ_NAME} ne ${::TE::QPROJ_SRC_NAME}} {
        set  qanswer [tk_messageBox  -title "Existing source files" -message "Found existing quartus source files with different project names:\nCurrent project: ${::TE::QPROJ_NAME}\n Source files: ${::TE::QPROJ_SRC_NAME}\n\nGenerate new quartus source files will delete older quartus source files.\n Are you sure to continue?" -icon warning -type yesno -default no]
      } else {
        set  qanswer [tk_messageBox  -title "Existing source files" -message "Found existing quartus source files: $qsrcdir.\nGenerate new quartus source files will delete older quartus source files.\n\nAre you sure to continue?" -icon warning -type yesno -default no]
      }
      if {$qanswer eq yes} {
        if {[catch {file delete -force $qsrcdir} result]} {
          thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-18 -msg \"Error on delete $qsrcdir: $result\" "
          return 0
        }
        if {[catch {file delete -force ${::TE::YOCTO_SOURCE_PATH}} result]} {
          thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-18 -msg \"Error on delete${::TE::YOCTO_SOURCE_PATH}: $result\" "
          return 0
        }
      }
    }
    set current_sdk_proj [glob -nocomplain -tail -directory ${::TE::SDK_PATH}/ *]
    set source_sdk_proj [glob -nocomplain -tail -directory ${ssrcdir}/ *]
    set generate_sdk [list]
    if {$::cb_ssrc eq 1} {
      foreach proj $current_sdk_proj {
        if {[string match "* *" $proj]} {
          thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-33 -msg \"Found spaces in software projectname: '$proj'. Can't generate source files.\" "
        } else {
          if { [lsearch $source_sdk_proj $proj] ne -1  && ![string match "*_bsp" $proj] && ![string match "bsp" $proj] } {
            set sanswer [tk_messageBox  -title "Existing source files" -message "Software project '$proj' already exists in '$ssrcdir'.\n\nDo you want to overwrite the existing project?" -icon question -type yesno -default no]
            if {$sanswer eq yes} {
              if {[catch {file delete -force $ssrcdir/$proj} result]} {
                thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-31 -msg \"Error on delete $ssrcdir/$proj: $result\" "
              } else {
                thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type info -id TE_DEV-32 -msg \" - $ssrcdir/$proj deleted.\" "
                lappend generate_sdk $proj 
              }
            } 
          } elseif { [glob -nocomplain ${::TE::SDK_PATH}/$proj/*.bsp] eq "" && ![string match "*_bsp" $proj] && ![string match "bsp" $proj]  && ![string match ".metadata" $proj] && ![string match "RemoteSystemsTempFiles" $proj] } {
            lappend generate_sdk $proj
          }
        }
      }
    }
    
    if {$::cb_qsrc eq 1 && $qanswer ne no} {
      file mkdir $qsrcdir
      set ::TE::QPROJ_SOURCE_PATH $qsrcdir
      tsv::set ::TE::QPROJ_SOURCE_PATH ::TK $qsrcdir
      set ::generating_source_files 1
      thread::send -async $::TE::MAINTHREAD " ;\
                          if {\[catch {::TE::DES::generate_quar_source_files} result\]} {::TE::UTILS::te_msg -type error -id TE_DEV-19 -msg \"(TE) Script (TE::DES::generate_quar_source_files) failed: \$result.\"} ;\
                          if {\[catch {::TE::INIT::get_project_names} result\]} {::TE::UTILS::te_msg -type error -id TE_DEV-20 -msg \"(TE) Script (TE::INIT::get_project_names) failed: \$result.\"} ;\
                          thread::send -async [thread::id] { ::TE::DEV::check_proj_sources; set ::generating_source_files 0 } ;\
                        "
    }
    if {$::cb_ssrc eq 1 && $generate_sdk ne ""} {
      file mkdir $ssrcdir
      set ::TE::SDK_SOURCE_PATH $ssrcdir
      tsv::set ::TE::SDK_SOURCE_PATH ::TK $ssrcdir
      set ::generating_source_files 1
      thread::send -async $::TE::MAINTHREAD " ;\
                          if {\[catch {::TE::DES::generate_sdk_source_files \"$generate_sdk\"} result\]} {::TE::UTILS::te_msg -type error -id TE_DEV-21 -msg \"(TE) Script (TE::DES::generate_sdk_source_files) failed: \$result.\"} ;\
                          thread::send -async [thread::id] { set ::generating_source_files 0 } ;\
                        "
    }
  }
  
  #--------------------------------
  #-- generate backup files from project
  proc generate_backup {} {
    if {$::writing_to_file eq 1 || $::generating_source_files eq 1 || $::generating_backup eq 1 || $::generating_prebuilt eq 1} {
      .fr_status.lb600 configure -text "Process is running. Please wait until the process finished."
      after 5000 {.fr_status.lb600 configure -text ""}
      return 0
    }
    if {![file exists ${::TE::QPROJ_SOURCE_PATH}]} {
      thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type error -id TE_DEV-26 -msg "Can't generate backup, project source files not found (Path: ${::TE::QPROJ_SOURCE_PATH}. Please generate source files first." }
      return 0
    }
    set ::cnt_sdksrcproj [glob -tails -nocomplain -directory ${::TE::SDK_SOURCE_PATH}/ *]
    if {[llength $::cnt_sdksrcproj] > 1 && [lsearch $::cnt_sdksrcproj "apps_list.csv"] eq -1} {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_DEV-34 -msg \"Found more than one software project in software source files: ${::cnt_sdksrcproj}.\" "
    }
    
    # read zip file name
    if {$::cb_b_name eq 1} {
      set zipname "[string map {" " "_"} [string map {"\n" ""} [.fr_backup.tx301 get 1.0 end]]]"
    } else {
      set zipname "NA"
    }
    
    if { ${::zipteinfo_initials} eq "" } {
      focus .fr_backup.fr_initials.en321
      .fr_backup.lb390 configure -text "Please enter Initials"
      after 1500 {.fr_backup.lb390 configure -text ""}
    } elseif { ${::zipteinfo_dest} eq "" } {
      .fr_backup.lb390 configure -text "Please select Destination"
      after 1500 {.fr_backup.lb390 configure -text ""}
    } elseif { ${::zipteinfo_dest} eq "Production" &&  ${::zipteinfo_ttyp} eq "" } {
      .fr_backup.lb390 configure -text "Please select Test Type"
      after 1500 {.fr_backup.lb390 configure -text ""}
    } elseif { ${::zipteinfo_dest} eq "Production" &&  ${::zipteinfo_btyp} eq "" } {
      .fr_backup.lb390 configure -text "Please select Board Type"
      after 1500 {.fr_backup.lb390 configure -text ""}
    } elseif { ${::zipteinfo_dest} eq "Production" &&  ${::zipteinfo_pext} eq "" } {
      .fr_backup.lb390 configure -text "Please select init.sh extention"
      after 1500 {.fr_backup.lb390 configure -text ""}
    } else {
      if {$::cb_b_preb eq 0} {
        set backup 1
      } else {
        set backup 0
      }
      set ::generating_backup 1
      
      thread::send -async $::TE::MAINTHREAD " ;\
                        if {\[catch {::TE::DES::backup_project ${backup} ${zipname} ${::zipteinfo_initials} ${::zipteinfo_dest} ${::zipteinfo_ttyp} ${::zipteinfo_btyp} ${::zipteinfo_pext} } result\]} {::TE::UTILS::te_msg -type error -id TE_DEV-22 -msg \"(TE) Script (TE::DES::backup_project  ${backup} ${zipname} ${::zipteinfo_initials} ${::zipteinfo_dest} ${::zipteinfo_ttyp} ${::zipteinfo_btyp} ${::zipteinfo_pext}) failed: \$result.\"} ;\
                        thread::send -async [thread::id] { set ::generating_backup 0 } ;\
                      "
    }
  }
  
 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # thread functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- open quartus programmer gui in thread
  proc thread_open_programmer_gui {} {
    set ::programmer_tid [thread::create -preserved]
    thread::send -async $::programmer_tid " ;\
                        exec quartus_pgmw${::TE::WIN_EXE} ;\
                        thread::release $::programmer_tid ;\
                      "
  }
  
  #--------------------------------
  #-- open quartus prime gui in thread
  proc thread_open_quartus {} {
    set ::quartus_tid [thread::create -preserved]
    thread::send -async $::quartus_tid "exec quartus${::TE::WIN_EXE}"
    thread::release $::quartus_tid
  }
  
  #--------------------------------
    #-- open project in quartus gui thread
  proc thread_open_project {} {
    
    if {[glob -nocomplain ${::TE::QPROJ_PATH}/*.qpf] ne ""} {
      set ::project_tid [thread::create -preserved]
      thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_DEV-23 -msg "Open project. Please change to GUI." }
      thread::send -async $::project_tid " ;\
                        exec quartus${::TE::WIN_EXE} [glob -nocomplain ${::TE::QPROJ_PATH}/*.qpf] ;\
                        thread::release $::project_tid ;\
                      "    
    } else {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-24 -msg \"Can't open Project. Project not found in ${::TE::QPROJ_PATH}. Please create project.\" "
    }
  }

  #--------------------------------
  #-- open 'NIOS II Software Build Tools for Eclipse IDE' in thread
  proc thread_open_eclipse_ide {} {
    if {[file isdirectory ${::TE::QROOTPATH}../nios2eds/bin/eclipse_nios2]} {
      set ::eclipse_tid [thread::create -preserved]
      thread::send -async $::eclipse_tid " if {\[catch {eval exec ${::TE::QROOTPATH}../nios2eds/bin/eclipse-nios2${::TE::WIN_EXE}} result\]} {puts \"\$result\"} "
      thread::release $::eclipse_tid
    } else {
      regexp -nocase -line {(\w+)\.(\w+)} ${::TE::QVERSION} ::qvers
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type critical_warning -id TE_DEV-27 -msg \"Eclipse IDE not found. See '<quartus_installation_path>/$::qvers/nios2eds/bin/README' for installation instructions.\" "
    }
  }

  #--------------------------------
  #-- open 'NIOS II Command Shell' in thread
  proc thread_open_command_shell {} {
    set ::shell_tid [thread::create -preserved {thread::wait}]    
    if {$::tcl_platform(platform) eq "windows"} {
      switch ${::TE::WSL_EN} {
        0 { thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type error -id TE_DEV-28 -msg "Windows Subsystem for Linux (WSL) is not installed. WSL is needed to open Nios II Command Shell. The software project can't be created. For more information and how to install WSL, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
          return 0
        }
        1 { thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type error -id TE_DEV-29 -msg "No Linux distribution installed for WSL. A Linux distribution is needed to open Nios II Command Shell. For more information and installation instructions, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
          return 0
        }
        2 { thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_DEV-30 -msg \"Please install missing commands (\[tsv::get need_cmd ::TK\]) in the linux distribution. Can't open Nios II Command Shell without this commands. For more information see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html\" "
          return 0
        }
        3 { thread::send -async $::shell_tid "$::open_extern ${::TE::NIOS2_COMMAND_SHELL_PATH}" }
      }
    } else {
      if {[string match -nocase *gnome* $::env(XDG_CURRENT_DESKTOP)]} {
        thread::send -async $::shell_tid "exec gnome-terminal -e ${::TE::NIOS2_COMMAND_SHELL_PATH}"
      } elseif {[string match -nocase *kde* $::env(XDG_CURRENT_DESKTOP)]} {
        thread::send -async $::shell_tid "exec konsole -e ${::TE::NIOS2_COMMAND_SHELL_PATH}"
      } else {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_DEV-25 -msg \"Current desktop environment: $::env(XDG_CURRENT_DESKTOP). This scripts only support GNOME and KDE.\" "
      }
    }
    thread::release $::shell_tid
  }
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished thread functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # additional functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- menubar -> ? -> About
  proc about_window_tk {} {
    toplevel .about -class Dialog
    wm title .about "About - Development Tools"
    wm geometry .about +575+450
    wm resizable .about 0 0
    tk::SetFocusGrab .about
    
    # set color of wm .about background
    ttk::style configure .about.TFrame    -background $::colors(-white)
    ttk::style configure .fr_info.TLabel  -background $::colors(-white)
    ttk::style configure .lb500.TLabel    -weight bold
    
    grid  [ttk::frame .about.background ] -sticky nesw -rowspan 10 -columnspan 10 

    grid  [ttk::label .about.lb500 -text "\nDevelopment Tools - Version $::dev_VERSION\n" -justify center -anchor center -font ownfont_12bold] -row 0
    
    grid  [ttk::frame .about.fr_info -style .about.TFrame -padding {0 0 11 0}]  -sticky nesw -row 1
    grid  [ttk::label .about.fr_info.lb501 -image [image create photo -file ${::TE::BASEFOLDER}/scripts/logo.gif] -compound center              -style .fr_info.TLabel] -row 1 -column 0 -rowspan 3   -padx 2 -pady 5
    grid  [ttk::label .about.fr_info.lb502 -text "Address:"                                                                -padding {0 9 0 0}   -style .fr_info.TLabel] -row 1 -column 1              -padx 2 -pady 2 -sticky nw
    grid  [ttk::label .about.fr_info.lb503 -text "Trenz Electronic GmbH\nBeendorfer Strasse 23\n32609 Huellhorst\nGermany" -padding {0 10 0 0}  -style .fr_info.TLabel] -row 1 -column 2              -padx 2 -pady 2 -sticky nw
    grid  [ttk::label .about.fr_info.lb504 -text "Email:"                                                                                       -style .fr_info.TLabel] -row 2 -column 1              -padx 2 -pady 2 -sticky nw
    grid  [ttk::label .about.fr_info.lb505 -text "info@trenz-electronic.de"                                                                     -style .fr_info.TLabel] -row 2 -column 2              -padx 2 -pady 2 -sticky nw
    grid  [ttk::label .about.fr_info.lb506 -text "Website:"                                                                                     -style .fr_info.TLabel] -row 3 -column 1              -padx 2 -pady 2 -sticky nw
    grid  [ttk::label .about.fr_info.lb507 -text "https://www.trenz-electronic.de/"                                                             -style .fr_info.TLabel] -row 3 -column 2              -padx 2 -pady 2 -sticky nw
    
    grid  [ttk::button .about.fr_info.ok_btn -text "OK"  -width 15 -command {destroy .about}] -row 4 -columnspan 3 -padx 4 -pady 10 -sticky e
  
    bind .about.fr_info.lb505 <1> "$::open_extern mailto:info@trenz-electronic.de"
    bind .about.fr_info.lb507 <1> "$::open_extern https://www.trenz-electronic.de"
    
    ::TE::DEV::bind_link_label {.about.fr_info.lb507 .about.fr_info.lb505}
    
    tkwait window .about
  }
  
  #--------------------------------
  #-- run, when exit Create Project GUI
  proc bind_link_label {tags} {
    set bold "-foreground $::colors(-blue) -relief raised -borderwidth 1"
    set normal "-foreground {} -relief flat"
  
    foreach tag $tags {
      bind $tag <Any-Enter> "$tag configure $bold"
      bind $tag <Any-Leave> "$tag configure $normal"
    }
  }
  
  #--------------------------------
  #-- run, when exit Development Tools GUI
  proc exit_tk {} {
    if {$::writing_to_file eq 1 || $::generating_source_files eq 1 || $::generating_backup eq 1 || $::generating_prebuilt eq 1} {
      .fr_status.lb600 configure -text "Process is running. Please wait until the process finished."
      after 5000 {.fr_status.lb600 configure -text ""}
      return 0
    }
    
    tsv::set ::TE::TK_MSG_EN ::TK 0
    destroy .
    thread::send -async $::TE::MAINTHREAD { set ::wait_tk_thread 0 }
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished additional functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------

 }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # message functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------  
  #--------------------------------
  #-- show message in labelframe "Messages"
  proc show_msg_tk {type message} {
    .fr_msg.tx configure -state normal
    switch -nocase $type {
      "error" {.fr_msg.tx insert end "Error: $message\n" error_msg}
      "critical_warning" {.fr_msg.tx insert end "Critical warning: $message\n" critical_warning_msg}
      "warning" {.fr_msg.tx insert end "Warning: $message\n" warning_msg}
      "info" {.fr_msg.tx insert end "Info: $message\n" info_msg}
      default {.fr_msg.tx insert end "$message\n"}
    }
    .fr_msg.tx configure -state disabled
    .fr_msg.tx see end
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished message functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -msg "(TE) Load dev tk script finished" }
}