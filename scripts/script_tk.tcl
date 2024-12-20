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
# -- $Date: 2020/04/08 | $Author: Dück, Thomas
# -- $Version: 2.0 $
# -- - add download elf file functionality, menubar, threads, progressbar
# -- - bugfixes
# ------------------------------------------
# -- $Date: 2020/06/29 | $Author: Dück, Thomas
# -- $Version: 2.1 $
# -- - add create new project window and functions
# -- - add to program device window combobox for direct board selection
# -- - bugfixes
# ------------------------------------------
# -- $Date: 2021/06/10 | $Author: Dück, Thomas
# -- $Version: 2.2 $
# -- - added check_sdk_sources, check_selected_sdk_project and cb_select_sdk_project 
# --   for sdk project selection
# ------------------------------------------
# -- $Date: 2022/03/17 | $Author: Dück, Thomas
# -- $Version: 2.3 $
# -- - add export_prebfiles  function
# -- - add "Export prebuilt files" button
# ------------------------------------------
# -- $Date: 2022/06/26 | $Author: Dück, Thomas
# -- $Version: 2.3 $
# -- - bugfixes in proc set_filter
# -- - bugfixes in proc check_sdk_sources
# ------------------------------------------
# -- $Date: 2024/02/05 | $Author: Dück, Thomas
# -- $Version: 2.4 $
# -- - add option to program flash memory with bin file
# --------------------------------------------------------------------
# --------------------------------------------------------------------
package require Tcl
package require Tk
package require Thread

namespace eval ::TE {
    
 namespace eval TK {
  # get global variables
  # names
  #tsv::get ::TE::QPROJ_NAME                ::TK ::TE::QPROJ_NAME
  tsv::get ::TE::QPROJ_SRC_NAME             ::TK ::TE::QPROJ_SRC_NAME
  tsv::get ::TE::NIOS_SRC_SOPC_FILE_LIST    ::TK ::TE::NIOS_SRC_SOPC_FILE_LIST
  tsv::get ::TE::YOCTO_SRC_BSP_LAYER_NAME   ::TK ::TE::YOCTO_SRC_BSP_LAYER_NAME
  # lists
  tsv::get ::TE::BOARDDEF_SRC_LIST          ::TK ::TE::BOARDDEF_SRC_LIST
  tsv::get ::TE::QPROJ_SRC_LIST             ::TK ::TE::QPROJ_SRC_LIST
  # path
  tsv::get ::TE::BASEFOLDER                 ::TK ::TE::BASEFOLDER
  tsv::get ::TE::QPROJ_PATH                 ::TK ::TE::QPROJ_PATH
  tsv::get ::TE::BOARDDEF_PATH              ::TK ::TE::BOARDDEF_PATH
  tsv::get ::TE::SOURCE_PATH                ::TK ::TE::SOURCE_PATH
  tsv::get ::TE::QPROJ_SOURCE_PATH          ::TK ::TE::QPROJ_SOURCE_PATH
  tsv::get ::TE::SDK_SOURCE_PATH            ::TK ::TE::SDK_SOURCE_PATH
  tsv::get ::TE::YOCTO_SOURCE_PATH          ::TK ::TE::YOCTO_SOURCE_PATH
  tsv::get ::TE::SDK_PATH                   ::TK ::TE::SDK_PATH
  tsv::get ::TE::LOG_PATH                   ::TK ::TE::LOG_PATH
  tsv::get ::TE::BACKUP_PATH                ::TK ::TE::BACKUP_PATH
  tsv::get ::TE::SET_PATH                   ::TK ::TE::SET_PATH
  tsv::get ::TE::NIOS2_COMMAND_SHELL_PATH   ::TK ::TE::NIOS2_COMMAND_SHELL_PATH
  tsv::get ::TE::PREBUILT_PATH              ::TK ::TE::PREBUILT_PATH
  tsv::get ::TE::QROOTPATH                  ::TK ::TE::QROOTPATH
  tsv::get ::TE::QUARTUS_INSTALLATION_PATH  ::TK ::TE::QUARTUS_INSTALLATION_PATH
  # board files
  tsv::get ::TE::BOARD_DEFINITION           ::TK ::TE::BOARD_DEFINITION
  tsv::get ::TE::GENERAL_INFO               ::TK ::TE::GENERAL_INFO
  
  # thread
  tsv::get ::TE::MAINTHREAD                 ::TK ::TE::MAINTHREAD
  tsv::get ::TE::TK_MSG_EN                  ::TK ::TE::TK_MSG_EN 
  # OS selection
  tsv::get ::TE::WIN_EXE                    ::TK ::TE::WIN_EXE
  # version
  tsv::get ::TE::APPSLIST_CSV               ::TK ::TE::APPSLIST_CSV
  tsv::get ::TE::QVERSION                   ::TK ::TE::QVERSION
  tsv::get ::TE::QEDITION                   ::TK ::TE::QEDITION
  tsv::get ::TE::SUPPORTED_VER              ::TK ::TE::SUPPORTED_VER
  tsv::get ::TE::SUPPORTED_EDI              ::TK ::TE::SUPPORTED_EDI
  
  tsv::get ::TE::WSL_EN                     ::TK ::TE::WSL_EN

  # filter variables
  variable ::tk_VERSION 2.4
  variable ::newproj_PRODUCTID  "none"
  variable ::prog_PRODUCTID     "none"
  variable ::tk_BOARD     "all"
  variable ::tk_FAM       "all"
  variable ::tk_DEV       "all"
  variable ::tk_SHORT     "all"
  variable ::tk_FLASHTYP  "all"
  variable ::tk_FLASHSIZE "all"
  variable ::tk_DDRDEV    "all"
  variable ::tk_DDRSIZE   "all"
  variable ::tk_REV       "all"
  variable ::tk_NOTES     "all"
  set ::productid_list    [list]
  set ::board_list        [list]
  set ::family_list       [list]
  set ::device_list       [list]
  set ::shortname_list    [list]
  set ::flashtyp_list     [list]
  set ::flashsize_list    [list]
  set ::ddrdev_list       [list]
  set ::ddrsize_list      [list]
  set ::rev_list          [list]
  set ::notes_list        [list]
  
  # prgoramming variables
  set ::otherfiledir    "------"
  set ::prebfiledir     ""
  set ::prebbinfiledir  ""
  
  # 
  set ::selected_id     "NA"
  set ::category        "NA"
  set ::newproject_name ""
  set ::newproject_dir  ""
  
  # process status variables
  set ::pbar_val 0
  set ::canceled 0
  set ::run_selected_board "NA"
  
  # running process variables
  set ::project_opened      0
  set ::programmer_opened   0
  set ::creating_project    0
  set ::programming_device  0
  

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # create gui
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- run create project gui
  proc run_create_project_tk {} {
    thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_TK-01 -msg "Start 'Create Project' GUI. Change to GUI." }
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
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
    
    #--------------------------------
    #-- init open_extern 
    if {$::tcl_platform(platform) eq "windows"} {
      set ::open_extern "eval exec \[auto_execok start\]"
    } else {
      set ::open_extern "exec xdg-open"
    }
    
    #--------------------------------
    # set color of wm  background
    grid [ttk::label .background] -sticky nesw -rowspan 10 -columnspan 10
    
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- menubar   
    menu .mb
    . configure -menu .mb

    menu .mb.file -tearoff 0
    .mb add cascade       -menu .mb.file      -label File -underline 0
    .mb.file add cascade  -menu .mb.file.new  -label "New ..." 
    .mb.file add separator
    .mb.file add command        -label Exit                 -command {::TE::TK::exit_tk}
    menu .mb.file.new -tearoff 0
    .mb.file.new add command    -label "Quartus project"    -command { ::TE::TK::create_new_project_window_tk }
    # .mb.file.new add command  -label "Software project"   -command { }
    
    menu .mb.project -tearoff 0
    .mb add cascade -menu .mb.project -label Project -underline 0
    .mb.project add command -label "Create Project"         -command {.fr_bottom.btn_create invoke}
    .mb.project add command -label "Open Project"           -command {.fr_bottom.btn_open_project invoke}
    .mb.project add command -label "Program device"         -command {.fr_bottom.btn_program invoke}
    .mb.project add command -label "Export prebuilt files"  -command {.fr_bottom.btn_exportpreb invoke}

    menu .mb.tools -tearoff 0
    .mb add cascade -menu .mb.tools -label Tools -underline 0
    .mb.tools add command -label "Quartus Prime ${::TE::QEDITION} ${::TE::QVERSION}"  -command {::TE::TK::thread_open_quartus}
    .mb.tools add command -label "Quartus Programmer"                                 -command {::TE::TK::thread_open_programmer_gui}
    .mb.tools add separator
    .mb.tools add command -label "NIOS II Software Build Tools for Eclipse"           -command {::TE::TK::thread_open_eclipse_ide}
    .mb.tools add command -label "NIOS II Command Shell"                              -command {::TE::TK::thread_open_command_shell}

    menu .mb.q -tearoff 0
    .mb add cascade   -menu .mb.q -label ? -underline 0
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
    .mb.q add command -label "About - Create Project"       -command {::TE::TK::about_window_tk}
  
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- board selection  
    grid [ttk::labelframe .fr_select -text "Board selection"] -row 1 -padx 5 -pady 5 -sticky nesw
    grid [ttk::label      .fr_select.lb100     -text "Filter:"      -anchor w                            ] -row 0 -column 0          -sticky w
    grid [ttk::button     .fr_select.btn_cfilter   -text "Clear filter"  -width $::buttonwidth  -command {::TE::TK::clear_filter}    ] -row 0 -column 3 -columnspan 2   -sticky e 
  
    grid [ttk::combobox   .fr_select.cb_board     -state readonly  -values $::board_list      -textvariable ::tk_BOARD      -width $::defaultwidth  ] -row 1 -column 0 -sticky nesw             
    grid [ttk::combobox   .fr_select.cb_fam       -state readonly  -values $::family_list     -textvariable ::tk_FAM        -width $::defaultwidth  ] -row 1 -column 1 -sticky nesw             
    grid [ttk::combobox   .fr_select.cb_dev       -state readonly  -values $::device_list     -textvariable ::tk_DEV        -width $::defaultwidth  ] -row 1 -column 2 -sticky nesw 
    grid [ttk::combobox   .fr_select.cb_short     -state readonly  -values $::shortname_list  -textvariable ::tk_SHORT      -width $::defaultwidth  ] -row 1 -column 3 -sticky nesw       
    # grid [ttk::combobox  .fr_select.cb_flashtyp   -state readonly  -values $::flashtyp_list   -textvariable ::tk_FLASHTYP   -width $::defaultwidth  ] -row 1 -column 4 -sticky nesw       
    # grid [ttk::combobox  .fr_select.cb_flashsize  -state readonly  -values $::flashsize_list  -textvariable ::tk_FLASHSIZE  -width $::defaultwidth  ] -row 1 -column 5 -sticky nesw       
    # grid [ttk::combobox  .fr_select.cb_ddrdev     -state readonly  -values $::ddrdev_list     -textvariable ::tk_DDRDEV     -width $::defaultwidth  ] -row 1 -column 6 -sticky nesw       
    # grid [ttk::combobox  .fr_select.cb_ddrsize    -state readonly  -values $::ddrsize_list    -textvariable ::tk_DDRSIZE    -width $::defaultwidth  ] -row 1 -column 7 -sticky nesw       
    grid [ttk::combobox  .fr_select.cb_rev        -state readonly  -values $::rev_list        -textvariable ::tk_REV        -width $::defaultwidth  ] -row 1 -column 4 -sticky nesw ;#using all filter cb -> set column to 8
    # grid [ttk::combobox  .fr_select.cb_notes    -state readonly  -values $::notes_list     -textvariable ::tk_NOTES    -width $::defaultwidth  ] -row 1 -column 9 -sticky nesw

    grid [ttk::treeview   .fr_select.tv -height 10 -columns {prodid family device shortname rev} -displaycolumns {prodid family device shortname rev} -selectmode browse -show headings -yscrollcommand {.fr_select.tv_sbY set}] -row 2 -column 0 -columnspan 5 -sticky nesw
    grid [ttk::scrollbar  .fr_select.tv_sbY -orient vertical -command {.fr_select.tv yview}] -row 2 -column 5 -sticky ns
    # grid [ttk::treeview   .fr_select.tv -height 10 -columns {prodid family device shortname flashtyp flashsize ddrdev ddrsize rev notes} -displaycolumns {prodid family device shortname flashtyp flashsize ddrdev ddrsize rev notes} -selectmode browse -show headings -yscrollcommand {.fr_select.tv_sbY set}] -row 2 -column 0 -columnspan 10 -sticky nesw
    # grid [ttk::scrollbar  .fr_select.tv_sbY -orient vertical -command {.fr_select.tv yview}] -row 2 -column 10 -sticky ns
    .fr_select.tv heading prodid    -text "Product ID"  -anchor w
    .fr_select.tv heading family    -text "Family"      -anchor w
    .fr_select.tv heading device    -text "Device"      -anchor w
    .fr_select.tv heading shortname -text "Shortname"   -anchor w
    # .fr_select.tv heading flashtyp  -text "Flash type"  -anchor w
    # .fr_select.tv heading flashsize -text "Flash size"  -anchor w
    # .fr_select.tv heading ddrdev    -text "DDR device"  -anchor w
    # .fr_select.tv heading ddrsize   -text "DDR size"    -anchor w
    .fr_select.tv heading rev       -text "Revision"    -anchor w
    # .fr_select.tv heading notes     -text "Notes"       -anchor w
  
    .fr_select.tv column prodid     -width $::tvwidth
    .fr_select.tv column family     -width $::tvwidth
    .fr_select.tv column device     -width $::tvwidth
    .fr_select.tv column shortname  -width $::tvwidth
    # .fr_select.tv column flashtyp   -width $::tvwidth
    # .fr_select.tv column flashsize  -width $::tvwidth
    # .fr_select.tv column ddrdev     -width $::tvwidth
    # .fr_select.tv column ddrsize    -width $::tvwidth
    .fr_select.tv column rev        -width $::tvwidth
    # .fr_select.tv column notes      -width $::tvwidth
    
    bind .fr_select.cb_board      <<ComboboxSelected>> {::TE::TK::set_filter 0}  
    bind .fr_select.cb_fam        <<ComboboxSelected>> {::TE::TK::set_filter 0}
    bind .fr_select.cb_dev        <<ComboboxSelected>> {::TE::TK::set_filter 0}
    bind .fr_select.cb_short      <<ComboboxSelected>> {::TE::TK::set_filter 0}  
    # bind .fr_select.cb_flashtyp   <<ComboboxSelected>> {::TE::TK::set_filter 0}  
    # bind .fr_select.cb_flashsize  <<ComboboxSelected>> {::TE::TK::set_filter 0}  
    # bind .fr_select.cb_ddrdev     <<ComboboxSelected>> {::TE::TK::set_filter 0}  
    # bind .fr_select.cb_ddrsize    <<ComboboxSelected>> {::TE::TK::set_filter 0}  
    bind .fr_select.cb_rev        <<ComboboxSelected>> {::TE::TK::set_filter 0}
    # bind .fr_select.cb_notes      <<ComboboxSelected>> {::TE::TK::set_filter 0}
    
    bind .fr_select.tv            <<TreeviewSelect>>   {::TE::TK::select_device}  

  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- Documentation
    set ::moduleseries [lindex [split [lindex ${::TE::BOARD_DEFINITION} 1 1] "-"] 0]
    grid [ttk::labelframe .fr_doc -text "Documentation"] -row 2 -padx 5 -pady 5 -sticky nesw
    grid [ttk::label  .fr_doc.lb300 -text "> ${::moduleseries} Resources:"                                                  -anchor nw ] -row 0 -column 0 -sticky new
    grid [ttk::label  .fr_doc.lb301 -text "     >> ${::TE::QPROJ_SRC_NAME} - Reference design description"                  -anchor nw ] -row 1 -column 0 -sticky new  
    grid [ttk::label  .fr_doc.lb302 -text "     >> TRM - Technical Reference Manual"                                        -anchor nw ] -row 2 -column 0 -sticky new
    grid [ttk::label  .fr_doc.lb303 -text "     >> <selected_board> schematics     -> select board in \"Board selection\""  -anchor nw ] -row 3 -column 0 -sticky new
    
    grid [ttk::separator .fr_doc.s300 -orient horizontal                                                                               ] -row 5 -column 0 -sticky nesw
    
    grid [ttk::label  .fr_doc.lb310 -text "> Trenz Electronic Wiki:"                                                        -anchor nw ] -row 6 -column 0 -sticky new
    grid [ttk::label  .fr_doc.lb311 -text "     >> Project Delivery - Intel devices"                                        -anchor nw ] -row 7 -column 0 -sticky new
    grid [ttk::label  .fr_doc.lb312 -text "     >> Project Delivery - Quick Start"                                          -anchor nw ] -row 8 -column 0 -sticky new

    regsub -all "_" ${::TE::QPROJ_SRC_NAME} "+" ::projectname_url
    bind .fr_doc.lb300 <1> "$::open_extern https://wiki.trenz-electronic.de/display/PD/${::moduleseries}+resources "
    bind .fr_doc.lb301 <1> "$::open_extern https://wiki.trenz-electronic.de/display/PD/${::moduleseries}+$::projectname_url "
    bind .fr_doc.lb302 <1> "$::open_extern https://wiki.trenz-electronic.de/display/PD/${::moduleseries}+TRM "
    .fr_doc.lb303 configure -state disabled
    
    bind .fr_doc.lb310 <1> "$::open_extern https://wiki.trenz-electronic.de/ "
    bind .fr_doc.lb311 <1> "$::open_extern https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices "
    bind .fr_doc.lb312 <1> "$::open_extern https://wiki.trenz-electronic.de/display/PD/Project+Delivery+-+Intel+devices#ProjectDelivery-Inteldevices-QuickStart "
    
    ::TE::TK::bind_link_label {.fr_doc.lb300 .fr_doc.lb301 .fr_doc.lb302 .fr_doc.lb310 .fr_doc.lb311 .fr_doc.lb312 }
    
    if { [string match "*tk_norefdesc*" ${::TE::GENERAL_INFO}] || ${::TE::QPROJ_SRC_NAME} eq "" || [llength ${::TE::QPROJ_SRC_NAME}] > 1} { grid forget .fr_doc.lb301 }
    if { [string match "*tk_notrm*" ${::TE::GENERAL_INFO}] } { grid forget .fr_doc.lb302 }
    foreach line $::TE::GENERAL_INFO {
      if { [string match -nocase "category*" $line] } { set ::category [lindex $line 1] } 
    }    
    if { $::category eq "NA" } { grid forget .fr_doc.lb303 }

  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- messages box
    grid [ttk::labelframe  .fr_msg    -text "Messages"] -row 3 -padx 5 -pady 5 -sticky nesw   
    grid [text        .fr_msg.tx  -height 15       -width $::messagewidth  -wrap char -yscrollcommand {.fr_msg.sbY set}] -row 0 -column 0 -columnspan 3  -sticky nesw  
    grid [ttk::scrollbar   .fr_msg.sbY  -orient vertical  -command {.fr_msg.tx yview}                      ] -row 0 -column 3          -sticky ns
    .fr_msg.tx insert end "--------------------------------------------------\
                         \n    1. Select your Board in \"Board selection\" area\
                         \n    2. Click \"Create project\" to generate the reference design from source files\
                         \n    3. To program device click \"Program device\" button:\
                         \n        -> select between prebuilt file (if available) or other file\
                         \n        -> use \"Start program device\" button to program device with selected file\
                         \n        -> or open quartus programmer GUI with \"Open quartus programmer\" button\
                         \n    4. Open project in quartus prime GUI with the button \"Open project\"\
                         \n--------------------------------------------------\n"    
    .fr_msg.tx configure                          -font ownfont
    .fr_msg.tx configure                          -state disabled
    .fr_msg.tx see end
    .fr_msg.tx tag configure error_msg            -foreground $::colors(-red)
    .fr_msg.tx tag configure critical_warning_msg -foreground $::colors(-magenta)
    .fr_msg.tx tag configure warning_msg          -foreground $::colors(-blue)
    .fr_msg.tx tag configure info_msg             -foreground $::colors(-green)
  
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- buttons to start process  
    grid [ttk::frame .fr_bottom -padding {3 10 3 0}] -row 4  
    grid [ttk::button .fr_bottom.btn_create       -text "Create project"        -width $::buttonwidth -command ::TE::TK::create_project_tk        ] -row 0 -column 0 -padx 4
    grid [ttk::button .fr_bottom.btn_open_project -text "Open project"          -width $::buttonwidth -command ::TE::TK::thread_open_project      ] -row 0 -column 1 -padx 4
    grid [ttk::button .fr_bottom.btn_program      -text "Program device"        -width $::buttonwidth -command ::TE::TK::program_device_window_tk ] -row 0 -column 2 -padx 4
    grid [ttk::button .fr_bottom.btn_exportpreb   -text "Export prebuilt files" -width $::buttonwidth -command ::TE::TK::export_prebfiles         ] -row 0 -column 3 -padx 4
    if {![file exists ${::TE::PREBUILT_PATH}]} {
      .fr_bottom.btn_exportpreb configure -state disabled
    }
  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- progressbar  
    grid [ttk::frame .fr_status -padding {0 0 3 3}] -row 5 -sticky e
    ttk::style configure fr_status.TButton  -foreground $::colors(-red)
    ttk::style map fr_status.TButton        -foreground [list disabled $::colors(-lightgrey)] -background [list disabled $::colors(-lightgrey)] -darkcolor [list disabled $::colors(-lightgrey)]  -lightcolor [list disabled $::colors(-lightgrey)] -bordercolor [list disabled $::colors(-lightgrey)]
    ttk::style configure visible.Horizontal.TProgressbar  -background $::colors(-blue)        -troughcolor $::colors(-btngrey)                  -darkcolor $::colors(-blue)                       -lightcolor $::colors(-blue)                      -bordercolor $::colors(-grey)
    ttk::style configure hidden.Horizontal.TProgressbar   -background $::colors(-lightgrey)   -troughcolor $::colors(-lightgrey)                -darkcolor $::colors(-lightgrey)                  -lightcolor $::colors(-lightgrey)                 -bordercolor $::colors(-lightgrey)
    
    grid [ttk::label .fr_status.lb600         -foreground $::colors(-blue)] -row 0 -column 0 -padx 3 -sticky e
    grid [ttk::progressbar .fr_status.pbar01  -orient horizontal  -length 100 -mode determinate   -variable ::pbar_val      -style hidden.Horizontal.TProgressbar   ] -row 0 -column 1          -sticky e
    grid [ttk::button .fr_status.btn_x        -text "x"            -width 1   -padding {0 0 0 0}  -style fr_status.TButton  -command ::TE::TK::thread_cancel_process] -row 0 -column 2 -padx 3  -sticky e
    
    .fr_status.btn_x configure -state disabled

  #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    #--------------------------------
    #-- enable output for processing messages
    tsv::set ::TE::TK_MSG_EN ::TK 1
    
    #--------------------------------
    # check if wsl is installed
    if {$::tcl_platform(platform) eq "windows"} {
      set need_cmd [list]
      if {${::TE::WSL_EN} eq 0} {
        thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_TK-27 -msg "Windows Subsystem for Linux (WSL) is not installed. The software project can't be created. For more information and installation instructions, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
      } elseif {${::TE::WSL_EN} eq 1} {
        thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_TK-28 -msg "No Linux distribution installed for WSL. The software project can't be created. For more information and installation instructions, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
      } elseif {${::TE::WSL_EN} eq 2} {
        set command exec 
        lappend command wsl
        lappend command wsl
        catch {eval $command} result
        if {[string match "*command not found*" $result]} {
          thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_TK-29 -msg "Command 'wsl' not found.  Please install with: sudo apt install wsl" }
          lappend need_cmd wsl
        }
        set command exec 
        lappend command wsl 
        lappend command make
        lappend command -q
        catch {eval $command} result
        if {[string match "*command not found*" $result]} {
          thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_TK-30 -msg "Command 'make' not found.  Please install with: sudo apt install make" }
          lappend need_cmd make
        }
        set command exec 
        lappend command wsl 
        lappend command dos2unix
        lappend command --version
        catch {eval $command} result
        if {[string match "*command not found*" $result]} {
          thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_TK-31 -msg "Command 'dos2unix' not found.  Please install with: sudo apt install dos2unix" }
          lappend need_cmd dos2unix
        }
        if {$need_cmd ne ""} {
          thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type critical_warning -id TE_TK-32 -msg \"Please install missing commands in the linux distribution. Can't create software project without commands ($need_cmd). For more information see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html\" "
          tsv::set need_cmd ::TK "$need_cmd"
        } else {
          set ::TE::WSL_EN 3
          tsv::set ::TE::WSL_EN ::TK 3
        }
      }
    }
    
    #--------------------------------
    #-- check soceds
    # if { ${::TE::YOCTO_SRC_BSP_LAYER_NAME} ne "NA" && "${::TE::QEDITION}" eq "Lite" && ![file exist ${::TE::QUARTUS_INSTALLATION_PATH}/embedded/] } {
    #   thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type critical_warning -id TE_TK-02 -msg "Intel SoC FPGA EDS 20.1 not found (Path: ${::TE::QUARTUS_INSTALLATION_PATH}/embedded/).Can't convert handoff files for yocto project. Install Intel Soc FPGA EDS 20.1 as described here: https://wiki.trenz-electronic.de/display/PD/Install+Intel+Development+Tools" }
    # }

    #--------------------------------
    #-- init filter function
    ::TE::TK::set_filter 1
    
    #--------------------------------
    # create and center create project window
    wm withdraw .
    update    
    set x [expr {([winfo screenwidth .]-[winfo width .])/3}]
    set y [expr {([winfo screenheight .]-[winfo height .])/4}]
    wm geometry . +$x+$y    
    wm iconphoto . -default [image create photo -file ./scripts/logo.gif]  
    wm title . "Create Project"
    wm resizable . 0 0
    wm protocol . WM_DELETE_WINDOW {::TE::TK::exit_tk}
    wm deiconify .
    
    tkwait window .
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished create gui
  # -----------------------------------------------------------------------------------------------------------------------------------------

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # filter functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- clear filter 
  proc clear_filter {} {
    .fr_select.cb_board     set "all"
    .fr_select.cb_fam       set "all"
    .fr_select.cb_dev       set "all"
    .fr_select.cb_short     set "all"
    # .fr_select.cb_flashtyp  set "all"
    # .fr_select.cb_flashsize set "all"
    # .fr_select.cb_ddrdev    set "all"
    # .fr_select.cb_ddrsize   set "all"
    .fr_select.cb_rev       set "all"
    # .fr_select.cb_notes     set "all"

    .fr_select.tv column prodid     -width $::tvwidth
    .fr_select.tv column family     -width $::tvwidth
    .fr_select.tv column device     -width $::tvwidth
    .fr_select.tv column shortname  -width $::tvwidth
    # .fr_select.tv column flashtyp   -width $::tvwidth
    # .fr_select.tv column flashsize  -width $::tvwidth
    # .fr_select.tv column ddrdev     -width $::tvwidth
    # .fr_select.tv column ddrsize    -width $::tvwidth
    .fr_select.tv column rev        -width $::tvwidth
    # .fr_select.tv column notes      -width $::tvwidth
      
    set ::selected_id "NA"
    ::TE::TK::set_filter 0
  } 
    
  #--------------------------------
  #-- select device from list
  proc select_device {} {
    if {[.fr_select.tv selection] ne "" && [.fr_select.tv selection] ne $::selected_id} {
      set ::selected_id [.fr_select.tv selection]
      set ::otherfiledir "------"
      set ::selected_shortname [lindex ${::TE::BOARD_DEFINITION} $::selected_id 4]
      if {[string match -nocase "*tk_no_sch*" [lindex ${::TE::BOARD_DEFINITION} $::selected_id 10]]} {
        .fr_doc.lb303 configure -text "     >> [lindex ${::TE::BOARD_DEFINITION} $::selected_id 1] schematics - not available"
        .fr_doc.lb303 configure -state disabled
        bind .fr_doc.lb303 <Any-Enter> break
        bind .fr_doc.lb303 <1> break
      } else {
        .fr_doc.lb303 configure -text "     >> [lindex ${::TE::BOARD_DEFINITION} $::selected_id 1] schematics"
        .fr_doc.lb303 configure -state normal
        ::TE::TK::bind_link_label .fr_doc.lb303
        bind .fr_doc.lb303 <1> "$::open_extern https://www.trenz-electronic.de/fileadmin/docs/Trenz_Electronic/$::category/${::moduleseries}/[lindex ${::TE::BOARD_DEFINITION} $::selected_id 9]/Documents/SCH-[lindex ${::TE::BOARD_DEFINITION} $::selected_id 1].PDF "
      }
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type info -id TE_TK-03 -msg \"Selected Product ID: [lindex ${::TE::BOARD_DEFINITION} $::selected_id 1]\" "
    }              
  } 

  #--------------------------------
  #-- set filter 
  proc set_filter {init} {
    if {$::TE::BOARD_DEFINITION eq ""} {
       thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type error -id TE_TK-04 -msg "No board part definition list found - Path: $::TE::BOARDDEF_PATH" }
       return 0
    }
    set ::parameter "$::tk_BOARD {$::tk_FAM} $::tk_DEV $::tk_SHORT $::tk_FLASHTYP $::tk_FLASHSIZE $::tk_DDRDEV $::tk_DDRSIZE $::tk_REV $::tk_NOTES"
    set ::board_list      [list]
    set ::family_list     [list]
    set ::device_list     [list]
    set ::shortname_list  [list]
    set ::flashtyp_list   [list]
    set ::flashsize_list  [list]
    set ::ddrdev_list     [list]
    set ::ddrsize_list    [list]
    set ::rev_list        [list]
    set ::notes_list      [list]
    set filteredlist $::TE::BOARD_DEFINITION
    
    # deselect board
    .fr_select.tv selection remove [.fr_select.tv selection]
    set ::selected_id "NA"
    if {$init eq 0} {
      bind .fr_doc.lb303 <Any-Enter> break
      bind .fr_doc.lb303 <1> break
      .fr_doc.lb303 configure -text "     >> <selected_board> schematics -> select board in \"Board selection\"" -state disabled
    } elseif {$init eq 1} {
      foreach line $::TE::BOARD_DEFINITION {
        if {![string match *[lindex $line 1]* $::productid_list] && ![string match *PRODID* $line]} {lappend ::productid_list [lindex $line 1]}
      }
    }

    # make devices visible in gui
    foreach line $::TE::BOARD_DEFINITION {
      if {![string match *PRODID* $line]} {  
        if {![.fr_select.tv exists [lindex $line 0]]} {
          .fr_select.tv insert {} end -id [lindex $line 0] -values "[lindex $line 1] {[lindex $line 2]} [lindex $line 3] [lindex $line 4] [lindex $line 9]"
          #.fr_select.tv insert {} end -id [lindex $line 0] -values "[lindex $line 1] {[lindex $line 2]} [lindex $line 3] [lindex $line 4] [lindex $line 5] [lindex $line 6] [lindex $line 7] [lindex $line 8] [lindex $line 9] [lindex $line 10]"
        } else {
          .fr_select.tv move [lindex $line 0] {} [lindex $line 0]
        }
      }
    }
    
    # filter device list depending on selected filter
    foreach filter $::parameter {
      set tmplist [list]
      foreach line $filteredlist {
        if {![string match *PRODID* $line] && ([lsearch -exact $line $filter] ne -1 || $filter eq "all")} {
          lappend tmplist $line
        } elseif {![string match *PRODID* $line] && [lsearch -exact $line $filter] eq -1} {
          .fr_select.tv detach [lindex $line 0]
        }
      }
      set filteredlist $tmplist
    }

    # refresh filter selection
    foreach line $filteredlist {
      if {[lsearch -exact $::board_list [lindex [split [lindex $line 1] "-"] 0]] == -1} {lappend ::board_list [lindex [split [lindex $line 1] "-"] 0]}
      if {[lsearch -exact $::family_list    [lindex $line  2]] eq -1} {lappend ::family_list    [lindex $line  2]}
      if {[lsearch -exact $::device_list    [lindex $line  3]] eq -1} {lappend ::device_list    [lindex $line  3]}
      if {[lsearch -exact $::shortname_list [lindex $line  4]] eq -1} {lappend ::shortname_list  [lindex $line  4]}
      if {[lsearch -exact $::flashtyp_list  [lindex $line  5]] eq -1} {lappend ::flashtyp_list  [lindex $line  5]}
      if {[lsearch -exact $::flashsize_list [lindex $line  6]] eq -1} {lappend ::flashsize_list  [lindex $line  6]}
      if {[lsearch -exact $::ddrdev_list    [lindex $line  7]] eq -1} {lappend ::ddrdev_list    [lindex $line  7]}
      if {[lsearch -exact $::ddrsize_list   [lindex $line  8]] eq -1} {lappend ::ddrsize_list    [lindex $line  8]}
      if {[lsearch -exact $::rev_list       [lindex $line  9]] eq -1} {lappend ::rev_list        [lindex $line  9]}
      if {[lsearch -exact $::notes_list     [lindex $line 10]] eq -1} {lappend ::notes_list      [lindex $line 10]}
    }
    # sort filtered values
    set ::board_list      "all [lsort -dictionary $::board_list]"
    set ::family_list     "all [lsort -ascii      $::family_list]"
    set ::device_list     "all [lsort -dictionary $::device_list]"
    set ::shortname_list  "all [lsort -dictionary $::shortname_list]"
    set ::flashtyp_list   "all [lsort -dictionary $::flashtyp_list]"
    set ::flashsize_list  "all [lsort -dictionary $::flashsize_list]"
    set ::ddrdev_list     "all [lsort -dictionary $::ddrdev_list]"
    set ::ddrsize_list    "all [lsort -dictionary $::ddrsize_list]"
    set ::rev_list        "all [lsort -dictionary $::rev_list]"  
    set ::notes_list      "all [lsort -dictionary $::notes_list]"  
    
    # update device list 
    .fr_select.cb_board     configure -values $::board_list
    .fr_select.cb_fam       configure -values $::family_list
    .fr_select.cb_dev       configure -values $::device_list
    .fr_select.cb_short     configure -values $::shortname_list
    # .fr_select.cb_flashtyp  configure -values $::flashtyp_list
    # .fr_select.cb_flashsize configure -values $::flashsize_list
    # .fr_select.cb_ddrdev    configure -values $::ddrdev_list
    # .fr_select.cb_ddrsize   configure -values $::ddrsize_list
    .fr_select.cb_rev       configure -values $::rev_list
    # .fr_select.cb_notes     configure -values $::notes_list
    
  }  
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished filter functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # program device functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------  
  #--------------------------------
  #-- program fpga with prebuilt files
  proc program_device_window_tk {} {
    if {$::creating_project eq 1} {
      .fr_status.lb600 configure -text "\"Create Project\" process is running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::creating_project eq 1} {
          .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        } elseif { $::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
      }
      return 0
    }

    toplevel .prgdev -class Dialog
    
    # set color of wm .prgdev background
    grid  [ttk::label .prgdev.background]  -sticky nesw -rowspan 10 -columnspan 10
      
    set ::prog_file "prebuilt"
    grid [ttk::frame .prgdev.fr_prg  -padding {10 10 10 10}  ] -row 0 -column 0 -columnspan 3
    grid [ttk::radiobutton .prgdev.fr_prg.rbpreb  -text "Program prebuilt file" -variable ::prog_file -value "prebuilt" -command ::TE::TK::rb_selection   ] -row 0            -columnspan 3         -sticky w
    grid [ttk::label     .prgdev.fr_prg.lb405     -text "      Selected board:"                                                                           ] -row 1 -column 0                        -sticky e 
    grid [ttk::combobox  .prgdev.fr_prg.cb_progprodid  -state readonly  -values $::productid_list -textvariable ::prog_PRODUCTID   -width $::defaultwidth ] -row 1 -column 1                -padx 5 -sticky ew 
    grid [ttk::label     .prgdev.fr_prg.lb400     -text "       Prebuilt file:"                                                                           ] -row 2 -column 0                        -sticky e 
    grid [ttk::label     .prgdev.fr_prg.lb401     -text "------"           -width 85 -wraplength 575                                                      ] -row 2 -column 1  -columnspan 2 -padx 2 -sticky w
    grid [ttk::label     .prgdev.fr_prg.lb402     -text ""                                                                                                ] -row 3            -columnspan 3
      
    grid [ttk::radiobutton .prgdev.fr_prg.rboth   -text "Program other file"  -variable ::prog_file -value "other" -command ::TE::TK::rb_selection        ] -row 4 -column 0  -columnspan 3         -sticky w
    grid [ttk::label     .prgdev.fr_prg.lb403     -text "      Selected file:"                                                                            ] -row 5 -column 0                        -sticky n
    grid [ttk::label     .prgdev.fr_prg.lb404     -text "$::otherfiledir"     -width 68   -wraplength 455                                                 ] -row 5 -column 1                -padx 2
    grid [ttk::button     .prgdev.fr_prg.btn_browse -text "Browse ..."        -width 15   -command {::TE::TK::browse_prg_file}                            ] -row 5 -column 2                        -sticky ne
  
    grid [ttk::separator .prgdev.s400 -orient horizontal ]  -row 1 -columnspan 3 -sticky ew
  
    grid [ttk::frame .prgdev.fr_bot            -padding {5 5 5 5}] -row 2 -column 0 -columnspan 4  
    grid [ttk::button .prgdev.fr_bot.btn_start_prog   -text "Start program device"    -width 28 -command {::TE::TK::start_program_tk $::progfiledir}  ] -row 0 -column 1 -padx 4 -pady 10
    grid [ttk::button .prgdev.fr_bot.btn_open_proggui -text "Open quartus programmer" -width 28 -command ::TE::TK::thread_open_programmer_gui         ] -row 0 -column 2 -padx 4 -pady 10
    grid [ttk::button .prgdev.fr_bot.btn_cancel       -text "Cancel"                  -width 28 -command {destroy .prgdev}                            ] -row 0 -column 3 -padx 4 -pady 10
  
    bind .prgdev.fr_prg.cb_progprodid <<ComboboxSelected>> {::TE::TK::prog_productid_selection}  
    
    set ::prebfiles ""
      
    if {$::selected_id != "NA"} {
      set ::prog_PRODUCTID [lindex ${::TE::BOARD_DEFINITION} $::selected_id 1]
      ::TE::TK::prog_productid_selection
    } else {
      set ::prog_PRODUCTID "none"
    }
    
    ::TE::TK::rb_selection  
      
    # create and center program device window
    wm withdraw .prgdev
    update    
    set x_prgdev [expr {([winfo screenwidth .]-[winfo width .prgdev])/3}]
    set y_prgdev [expr {([winfo screenheight .]-[winfo height .prgdev])/4}]
    wm geometry .prgdev +$x_prgdev+$y_prgdev  
    wm title .prgdev "Program device"
    wm resizable .prgdev 0 0
    wm deiconify .prgdev
    
    tk::SetFocusGrab .prgdev
  
    tkwait window .prgdev
  }
  
  #--------------------------------
  #-- radiobutton programming file selection  
  proc prog_productid_selection {} {
    foreach line ${::TE::BOARD_DEFINITION} {
      if {[string match $::prog_PRODUCTID [lindex $line 1]]} {
        set ::prog_shortname [lindex $line 4]
        .fr_select.tv selection set [lindex $line 0]
        ::TE::TK::select_device
      }
    }
    
    # select shortname
    set filedir "${::TE::PREBUILT_PATH}/${::prog_shortname}/programming_files"

    # search for available prebuilt files
    set ::prebfiles   [glob -nocomplain -tail -directory $filedir/ *.jic *.pof *.sof]
    set ::prebbinfile [glob -nocomplain -tail -directory $filedir/../software/ *.bin]
    set text_binfile ""
  
    if {$::prebfiles != ""} {    
      if {[string match *.jic* $::prebfiles]} {
        regexp {(.*).jic} $::prebfiles matched_file
      } elseif {[string match *.pof* $::prebfiles]} {
        regexp {(.*).pof} $::prebfiles matched_file
      } elseif {[string match *.sof* $::prebfiles]} {
        regexp {(.*).sof} $::prebfiles matched_file
      }
      set ::prebfiledir "$filedir/$matched_file"
      
      if {$::prebbinfile ne ""} {
        regexp {(.*).bin} $::prebbinfile matched_bin_file
        set ::prebbinfiledir "$filedir/../software/$matched_bin_file"
        set text_binfile "\n<project folder>/prebuilt/${::prog_shortname}/software/$matched_bin_file"
      }
      .prgdev.fr_prg.lb401 configure -text "<project folder>/prebuilt/${::prog_shortname}/programming_files/$matched_file$text_binfile"
    }  
    
    ::TE::TK::rb_selection
  }
  
  #--------------------------------
  #-- radiobutton programming file selection  
  proc rb_selection {} {
    if {$::prog_file eq "other"} {
      .prgdev.fr_prg.lb400 configure -state disabled
      .prgdev.fr_prg.lb401 configure -state disabled -foreground $::colors(-darkgrey)
      .prgdev.fr_prg.lb405 configure -state disabled
      .prgdev.fr_prg.cb_progprodid configure -state disabled
      .prgdev.fr_prg.lb403 configure     -state normal
      .prgdev.fr_prg.btn_browse configure -state normal
      .prgdev.fr_prg.lb404 configure     -state normal
      set ::progfiledir $::otherfiledir
      if {![file exists $::otherfiledir]} {
        .prgdev.fr_bot.btn_start_prog configure -state disabled
      } else {
        .prgdev.fr_bot.btn_start_prog configure -state normal
      }
    } else {
      .prgdev.fr_prg.lb400 configure     -state normal
      .prgdev.fr_prg.lb401 configure     -state normal -foreground $::colors(-black)
      .prgdev.fr_prg.lb405 configure     -state normal
      .prgdev.fr_prg.cb_progprodid configure -state readonly
      
      .prgdev.fr_prg.lb403 configure     -state disabled
      .prgdev.fr_prg.btn_browse configure -state disabled
      .prgdev.fr_prg.lb404 configure     -state disabled
      set ::progfiledir $::prebfiledir
      if {![file exists $::prebfiledir]} {
        .prgdev.fr_bot.btn_start_prog configure -state disabled
      } else {
        .prgdev.fr_bot.btn_start_prog configure -state normal
      }
      if { $::prog_PRODUCTID == "none" } {
        set $::prebfiledir ""
        .prgdev.fr_bot.btn_start_prog configure -state disabled
        focus .prgdev.fr_prg.cb_progprodid
        .prgdev.fr_prg.lb401 configure -text "Select board for correct prebuilt file." -foreground $::colors(-red)
      } elseif {$::prebfiles eq ""} {
        .prgdev.fr_prg.lb401 configure -text "Not found in: <project folder>/prebuilt/${::prog_shortname}/programming_files/ \nDownload reference design with prebuilt files included." -foreground $::colors(-red)
      }        
    }
  }

  #--------------------------------
  #-- browse programming file directory
  proc browse_prg_file {} {
    set ::otherfiledir [tk_getOpenFile -title "Select programming file" -initialdir [pwd]/quartus -filetypes {{{Programming files} {*.sof *.pof *.jic *.elf *.bin}}}]
    .prgdev.fr_prg.lb404 configure -text "$::otherfiledir"
    set ::progfiledir $::otherfiledir
    if {![file exists $::progfiledir]} {
      .prgdev.fr_bot.btn_start_prog configure -state disabled
    } else {
      .prgdev.fr_bot.btn_start_prog configure -state normal
    }
  }

  #--------------------------------
  #-- start program device
  proc start_program_tk {filedir} {
    if {$::creating_project eq 1} {
      .fr_status.lb600 configure -text "\"Create Project\" process is already running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::creating_project eq 1} {
          .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        } elseif { $::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
      }
      return 0
    }

    if {$::programming_device eq 1} {
      .fr_status.lb600 configure -text "\"Program device\" process is running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::programming_device eq 1} {
          .fr_status.lb600 configure -text "Program device ..."
        } elseif {$::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
      }
      return 0
    }
    
    if {[file exists $filedir]} {
      if {[string match *time_limited* $filedir]} {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type critical_warning -id TE_TK-05 -msg \"Programming file is time limited, not licensed IP cores will be disabled after 1h or when closing GUI.\" "
      }
      # program device with prebuilt file 
      destroy .prgdev
      .fr_status.pbar01 configure -mode indeterminate -style visible.Horizontal.TProgressbar
      .fr_status.pbar01 start 5
      .fr_status.lb600 configure -text "Program device ..."
      set ::programming_device 1
      if {[string match *.jic $filedir] || [string match *.pof $filedir] || [string match *.sof $filedir]} {
        thread::send -async $::TE::MAINTHREAD " ;\
                          if {\[catch {::TE::QUART::program_dev -filedir $filedir} result\]} { ::TE::UTILS::te_msg -type error -id TE_TK-06 -msg \"(TE) Script (::TE::QUART::program_dev) failed: \$result.\" } ;\
                          thread::send -async [thread::id] { set ::programming_device 0; after 500 {.fr_status.pbar01 configure -mode indeterminate -style hidden.Horizontal.TProgressbar; .fr_status.pbar01 stop; .fr_status.lb600 configure -text \"\"} } ;\
                        " 
      } elseif {[string match *.elf $filedir]} {
        thread::send -async $::TE::MAINTHREAD " ;\
                          if {\[catch {::TE::SDK::download_elf $filedir} result\]} { ::TE::UTILS::te_msg -type error -id TE_TK-07 -msg \"(TE) Script (::TE::SDK::download_elf) failed: \$result.\" } ;\
                          thread::send -async [thread::id] { set ::programming_device 0; after 500 {.fr_status.pbar01 configure -mode determinate -style hidden.Horizontal.TProgressbar; .fr_status.pbar01 stop; .fr_status.lb600 configure -text \"\"} } ;\
                        " 
      } elseif {[string match *.bin $filedir]} {
        thread::send -async $::TE::MAINTHREAD " ;\
                          if {\[catch {::TE::SDK::write_flash_memory $filedir} result\]} { ::TE::UTILS::te_msg -type error -id TE_TK-07 -msg \"(TE) Script (::TE::SDK::write_flash_memory) failed: \$result.\" } ;\
                          thread::send -async [thread::id] { set ::programming_device 0; after 500 {.fr_status.pbar01 configure -mode determinate -style hidden.Horizontal.TProgressbar; .fr_status.pbar01 stop; .fr_status.lb600 configure -text \"\"} } ;\
                        " 
      }
    } else {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-08 -msg \"No programming file selected. Please select *.jic, *.pof, *.sof or *.elf file.\" "
      set ::programming_device 0
    }
  }

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished program device functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------  

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # quartus functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------  
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
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type info -id TE_TK-45 -msg \"Read sdk apps list (File: ${::TE::SDK_SOURCE_PATH}/apps_list.csv).\" "
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
              ::TE::UTILS::te_msg -type error -id TE_TK-46 -msg "Wrong apps list CSV Version (${::TE::SDK_SOURCE_PATH}/apps_list.csv) get [lindex $tmp 1] expected ${::TE::APPSLIST_CSV}."
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
    
      grid [ttk::frame .selectsdk.background ] -sticky nesw -rowspan 10 -columnspan 10 
      grid [ttk::frame .selectsdk.fr_info -padding {10 10 10 10} ] -sticky nesw -row 0
      
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
      grid [ttk::checkbutton  .selectsdk.fr_select.cb700 -text "No Project" -variable ::sdk_select0 -command { ::TE::TK::cb_select_sdk_project [llength ${::nios_sopcfile_list}] } ] -row 0 -sticky w
      set i 1
      # create checkbutton for each software prject
      foreach project ${::sdk_src_tmp_list} {
        grid [ttk::checkbutton  .selectsdk.fr_select.cb70$project -text "$project" -variable ::sdk_select$project -command { ::TE::TK::cb_select_sdk_project [llength ${::nios_sopcfile_list}] }] -row $i -column 0 -sticky w
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
      
      grid [ttk::separator .selectsdk.s700 -orient horizontal ] -row 2 -sticky ew
      
      grid [ttk::frame .selectsdk.fr_btn -padding {10 10 10 10} ] -row 3 -sticky es
      grid [ttk::button .selectsdk.fr_btn.ok_btn      -text "OK"      -width [expr $::buttonwidth/2] -command { ::TE::TK::check_selected_sdk_project [llength ${nios_sopcfile_list}]} ] -row 0 -padx 4 -sticky e
      grid [ttk::button .selectsdk.fr_btn.cancel_btn  -text "Cancel"  -width [expr $::buttonwidth/2] -command {set ::cancel_sdk_window 1; destroy .selectsdk; thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_TK-47 -msg "Process canceled." };} ] -row 0 -column 1 -padx 4 -sticky e
    
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
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-48 -msg \"No *.sopcinfo file selected for '$sdk'.\" "
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
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_TK-49 -msg \"The maximum number of sdk projects are already selected.\" "
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
  #-- create project for selected board
  proc create_project_tk {} {
    if {$::creating_project eq 1} {
      .fr_status.lb600 configure -text "\"Create Project\" process is already running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::creating_project eq 1} {
          .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        } elseif { $::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
      }
      return 0
    }
    if {$::project_opened eq 1} {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_TK-09 -msg \"Project '[glob -nocomplain ${::TE::QPROJ_PATH}/*.qpf]' is opened in quartus gui. Close project before create new project.\" "
      return 0
    }
    if {$::programming_device eq 1} {
      .fr_status.lb600 configure -text "\"Program device\" process is running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::programming_device eq 1} {
          .fr_status.lb600 configure -text "Program device ..."
        } elseif {$::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
      }
      return 0
    }
    set delproj ""
    # check for existing project
    if {$::selected_id ne "NA"} {
      if {[file exists ${::TE::QPROJ_PATH}]} {
        set delproj [tk_dialog  .createproj_dialog "Existing project" "Found existing quartus project. \"Create Project\" will delete old project.\nAre you sure to continue?" "warning" 1 "  Yes  " "  No   "]
      } 
      # delete existing project and create new project
      if {![file exists ${::TE::QPROJ_PATH}] || $delproj == 0} {
        thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_TK-10 -msg "Start creating project." }
        # initialize selected board for project generation
        set ::init_board_done 0
        thread::send -async $::TE::MAINTHREAD " if {\[catch {::TE::INIT::init_board \[::TE::BDEF::get_id $::selected_id\]} result\]} {::TE::UTILS::te_msg -type error -id TE_TK-50 -msg \"Script (TE::INIT::init_board) failed: \$result.\"; return -code error} "                
        vwait ::init_board_done
        # reinitialize variables
        tsv::get ::TE::QPROJ_SOURCE_PATH        ::TK ::TE::QPROJ_SOURCE_PATH
        tsv::get ::TE::SDK_SOURCE_PATH          ::TK ::TE::SDK_SOURCE_PATH
        tsv::get ::TE::NIOS_SRC_SOPC_FILE_LIST  ::TK ::TE::NIOS_SRC_SOPC_FILE_LIST
        tsv::get ::TE::YOCTO_BSP_LAYER_NAME     ::TK ::TE::YOCTO_BSP_LAYER_NAME
        tsv::get ::TE::YOCTO_SRC_BSP_LAYER_NAME ::TK ::TE::YOCTO_SRC_BSP_LAYER_NAME
        tsv::get ::TE::QPROJ_NAME               ::TK ::TE::QPROJ_NAME
        tsv::get ::TE::QPROJ_SRC_NAME           ::TK ::TE::QPROJ_SRC_NAME
        tsv::get ::TE::NIOS_SRC_SOPC_FILE_LIST  ::TK ::TE::NIOS_SRC_SOPC_FILE_LIST
        
        if {![file exist ${::TE::QPROJ_SOURCE_PATH}/${::TE::QPROJ_SRC_NAME}.tcl]} {
          thread::send -async $::TE::MAINTHREAD { ;\
            if {[catch {TE::UTILS::clean_project} result]}  {::TE::UTILS::te_msg -type error -id TE_TK-37 -msg "Script (TE::UTILS::clean_project) failed: $result.";  return 0} ;\
            if {[catch {TE::UTILS::clean_software} result]} {::TE::UTILS::te_msg -type error -id TE_TK-38 -msg "Script (TE::UTILS::clean_software) failed: $result."; return 0} ;\
          }
          
          if {[llength ${::TE::QPROJ_SRC_NAME}] > 1} {
            thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type warning -id TE_TK-36 -msg "Found Project source files for more than one project in ${::TE::QPROJ_SOURCE_PATH} (Project names: ${::TE::QPROJ_SRC_NAME}). Can't create project from source files." }
          } else {
            thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type warning -id TE_TK-42 -msg "Quartus source files not found." }
          }
          thread::send   -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_TK-43 -msg "Create empty project." }
          set ::newproject_dir ${::TE::QPROJ_PATH}
          ::TE::TK::create_new_project_window_tk
          return 0
        }
        # check if more than one software project exists
        ::TE::TK::check_sdk_sources ${::TE::NIOS_SRC_SOPC_FILE_LIST}
        if { $::cancel_sdk_window eq 1 } { return 0 }
        # start creating project 
        set ::run_selected_board [lindex ${::TE::BOARD_DEFINITION} $::selected_id 1]
        .fr_status.btn_x configure -state normal
        .fr_status.pbar01 configure -mode determinate -style visible.Horizontal.TProgressbar
        .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        set ::creating_project 1
        thread::send -async $::TE::MAINTHREAD " ;\
                          if {\[catch {::TE::DES::run_project $::selected_id 0 3} result\]} { ::TE::UTILS::te_msg -type error -id TE_TK-11 -msg \"(TE) Script (TE::DES::run_project) failed: \$result.\" } ;\
                          thread::send -async [thread::id] { set ::creating_project 0; after 500 {.fr_status.btn_x configure -state disabled; .fr_status.pbar01 configure -style hidden.Horizontal.TProgressbar; .fr_status.lb600 configure -text \"\"} } ;\
                        " 
      }      
    } else {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-12 -msg \"No Product ID selected. Please select the correct Product ID.\" "
      set ::creating_project 0
    }
  }

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished quartus functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------  

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # new project functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------    
  #--------------------------------
  #-- create new project for selected board
  proc create_new_project_window_tk {} {
    if {$::selected_id != "NA"} { set ::newproj_PRODUCTID [lindex ${::TE::BOARD_DEFINITION} $::selected_id 1] } else { set ::newproj_PRODUCTID "none" }

    # set toplevel
    toplevel .newproject -class Dialog
    
    grid [ttk::frame    .newproject.background ]  -sticky nesw -rowspan 10 -columnspan 10 
    grid [ttk::frame    .newproject.fr_setting -padding {10 10 10 10} ] -sticky nesw -row 0
    grid [ttk::label    .newproject.fr_setting.lb200        -text "Selected board:" -padding {0 0 10 0}                                                                     ] -row 0 -column 0 -padx 2 -pady 2  -sticky nw
    grid [ttk::combobox .newproject.fr_setting.cb_newprodid -state readonly         -values $::productid_list -textvariable ::newproj_PRODUCTID -width $::defaultwidth      ] -row 0 -column 1 -padx 5          -sticky nesw 
  
    grid [ttk::label    .newproject.fr_setting.lb201 -text "Project name:"                                                                                                  ] -row 1 -column 0 -padx 2 -pady 2  -sticky nw
    grid [ttk::entry    .newproject.fr_setting.en201 -textvariable ::newproject_name -validate focus -validatecommand { ::TE::TK::set_new_projectname } -width $::entrywidth] -row 1 -column 1
    if {${::newproject_name} eq ""} {
      ::TE::TK::set_new_projectname
    }
    
    grid [ttk::label    .newproject.fr_setting.lb202 -text "Project directory:"                                                                                             ] -row 2 -column 0 -padx 2 -pady 2  -sticky nw
    grid [ttk::entry    .newproject.fr_setting.en202 -textvariable ::newproject_dir -validate focus -validatecommand { ::TE::TK::set_new_projectdir }  -width $::entrywidth ] -row 2 -column 1 -padx 5
    if {${::newproject_dir} eq ""} {
      ::TE::TK::set_new_projectdir
    }
    
    grid [ttk::button   .newproject.fr_setting.btn_browse  -text "Browse ..."             -command { ::TE::TK::browse_new_projectdir }   -width $::buttonwidth              ] -row 2 -column 2                  -sticky ne
    
    grid [ttk::separator .newproject.s200 -orient horizontal ]  -row 1  -sticky ew
    
    grid [ttk::frame    .newproject.fr_btn -style .newproject.TFrame -padding {10 10 10 10} ] -row 2  -sticky nes
    grid [ttk::label    .newproject.fr_btn.lb203      -text ""        -foreground $::colors(-red)                                                                           ] -row 1 -column 0                  -sticky w
    grid [ttk::button   .newproject.fr_btn.ok_btn     -text "Create"  -width $::buttonwidth -command { ::TE::TK::create_new_project }                                       ] -row 1 -column 1 -padx 5          -sticky e
    grid [ttk::button   .newproject.fr_btn.cancel_btn -text "Cancel"  -width $::buttonwidth -command { destroy .newproject }                                                ] -row 1 -column 2                  -sticky e
    
    bind .newproject.fr_setting.cb_newprodid <<ComboboxSelected>> {
      foreach line ${::TE::BOARD_DEFINITION} {
        if {[string match $::newproj_PRODUCTID [lindex $line 1]]} {
          .fr_select.tv selection set [lindex $line 0]
          ::TE::TK::select_device
        }
      }
    }
    
    if { $::newproj_PRODUCTID == "none" } {
      focus .newproject.fr_setting.cb_newprodid
    } else {
      focus .newproject.fr_setting.en201
    }
    
    # create and center create new project window
    wm withdraw .newproject
    update    
    set x_newproject [expr {([winfo screenwidth .]-[winfo width .newproject])/3}]
    set y_newproject [expr {([winfo screenheight .]-[winfo height .newproject])/4}]
    wm geometry .newproject +$x_newproject+$y_newproject  
    wm title .newproject "Create new project"
    wm resizable .newproject 0 0
    wm deiconify .newproject
    
    tk::SetFocusGrab .newproject
    
    tkwait window .newproject
    
    set ::newproject_name ""
    set ::newproject_dir ""
  }
  
  #--------------------------------
  #-- browse new project directory
  proc browse_new_projectdir {} {
    set ::newproject_dir [tk_chooseDirectory -title "Select new project directory" -initialdir "[pwd]" -mustexist true ]
    .newproject.fr_setting.en202 configure -foreground $::colors(-black)
  }
  
  #--------------------------------
  #-- create new project
  proc create_new_project {} {
    if {$::creating_project eq 1} {
      .fr_status.lb600 configure -text "\"Create Project\" process is already running. Please wait until the process finished."
      .newproject.fr_btn.lb203 configure -text "\"Create Project\" process is running. Please wait ..."
      after 5000 {
        if {$::canceled eq 0 && $::creating_project eq 1} {
          .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        } elseif { $::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
        .newproject.fr_btn.lb203 configure -text ""
      }
      return 0
    }
    if {$::programming_device eq 1} {
      .fr_status.lb600 configure -text "\"Program device\" process is running. Please wait until the process finished."
      .newproject.fr_btn.lb203 configure -text "\"Program device\" process is running. Please wait ..."
      after 5000 {
        if {$::canceled eq 0 && $::programming_device eq 1} {
          .fr_status.lb600 configure -text "Program device ..."
        } elseif {$::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
        .newproject.fr_btn.lb203 configure -text ""
      }
      return 0
    }

    set existingproject [glob -nocomplain -directory $::newproject_dir *.qpf]
    
    if { $::newproj_PRODUCTID == "none" } {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-13 -msg \"No board selected. Please select board.\" "
      .newproject.fr_btn.lb203 configure -text "No board selected. Please select board."
      after 2500 {.newproject.fr_btn.lb203 configure -text ""}
      focus .newproject.fr_setting.cb_newprodid
      return 0
    } elseif { $::newproject_name == "<Enter new project name>" } {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-14 -msg \"Project name: empty string. Please enter new project name.\" "
      .newproject.fr_btn.lb203 configure -text "Project name: empty string. Please enter new project name."
      after 2500 {.newproject.fr_btn.lb203 configure -text ""}
      focus .newproject.fr_setting.en201
      return 0
    } elseif { $::newproject_dir == "<Enter new project directory>" } {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-15 -msg \"Project directory: empty string. Please enter project directory.\" "
      .newproject.fr_btn.lb203 configure -text "Project directory: empty string. Please enter project directory."
      after 2500 {.newproject.fr_btn.lb203 configure -text ""}
      focus .newproject.fr_setting.en202
      return 0
    } elseif { ![file isdirectory $::newproject_dir] } {
      if {[catch {file mkdir $::newproject_dir} result]} {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-16 -msg \"$result\nProject directory not valid. Please enter different project directory.\" "
        .newproject.fr_btn.lb203 configure -text "Project directory not valid. Please enter different project directory."
        after 2500 {.newproject.fr_btn.lb203 configure -text ""}
        focus .newproject.fr_setting.en202
        return 0
      } else {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type info -id TE_TK-39 -msg \"Create new project directory: $::newproject_dir]\" "
      }
    } elseif { $existingproject != "" } {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-17 -msg \"Found Quartus project [file tail $existingproject] in selected directory: '$::newproject_dir'. Please choose another directory.\" "
      .newproject.fr_btn.lb203 configure -text "Found existing project. Please choose another directory."
      after 2500 {.newproject.fr_btn.lb203 configure -text ""}
      focus .newproject.fr_setting.en202
      .newproject.fr_setting.en202 selection range 0 end
      return 0
    }
    set tmppwd [pwd]
    cd $::newproject_dir
    ::TE::TK::copy_boarddef_sources
    cd $tmppwd  
    # create new project for selected board
    thread::send -async $::TE::MAINTHREAD " ; \
                        set tmppwd [pwd] ;\
                        cd $::newproject_dir ;\
                        if {\[catch {::TE::INIT::init_board \[::TE::BDEF::get_id $::newproj_PRODUCTID\]} result\]} { ::TE::UTILS::te_msg -type error -id TE_TK-18 -msg \"(TE) Script (TE::INIT::init_board \"TE::BDEF::get_id $::newproj_PRODUCTID\") failed: \$result.\" } ;\
                        if {\[catch {::TE::QUART::create_empty_project $::newproject_name} result\]} { ::TE::UTILS::te_msg -type error -id TE_TK-19 -msg \"(TE) Script (TE::QUART::create_empty_project) failed: \$result.\" } ;\
                        cd \$tmppwd "  
    destroy .newproject
    return 0
  }
  
  #--------------------------------
  #-- set new project name
  proc set_new_projectname {} {
    if { $::newproject_name == "<Enter new project name>" }  {
      set ::newproject_name ""
      .newproject.fr_setting.en201 configure -foreground $::colors(-black)
    } elseif { [string map {" " ""} $::newproject_name] == "" } {
      set ::newproject_name "<Enter new project name>"
      .newproject.fr_setting.en201 configure -foreground #9e9e9e
    }
    return 0
  }
  
  #--------------------------------
  #-- set new project directory
  proc set_new_projectdir {} {
    if { $::newproject_dir == "<Enter new project directory>" }  {
      set ::newproject_dir ""
      .newproject.fr_setting.en202 configure -foreground $::colors(-black)
    } elseif { [string map {" " ""} $::newproject_dir] == "" } {
      set ::newproject_dir "<Enter new project directory>"
      .newproject.fr_setting.en202 configure -foreground #9e9e9e
    }
    return 0
  }
  
  proc copy_boarddef_sources {} {
    set tmp_bdef_src ""
    foreach bdef_src $::TE::BOARDDEF_SRC_LIST {
      if { [string match *$bdef_src ${::selected_shortname}] && [string length $bdef_src] > [string length $tmp_bdef_src]} {
        set tmp_bdef_src $bdef_src
      }
    }
    set bdefpath ${::TE::BOARDDEF_PATH}/${tmp_bdef_src}
    # copy presets and top.v and source pin_assignments.tcl
    set files [glob -nocomplain -directory ${bdefpath} *.tcl *.v *.sv *.vhd *.qprs ip hdl]
    foreach filedir $files {
      file copy -force $filedir ./
    }
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished new project functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------  

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # thread functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- open quartus programmer gui in thread
  proc thread_open_programmer_gui {} {
    if {$::programmer_opened eq 1} {
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_TK-20 -msg \"Quartus programmer is already opened. Change to programmer GUI.\" "
      return 0
    }
    set ::programmer_opened 1
    set ::programmer_tid [thread::create -preserved]
    thread::send -async $::programmer_tid " ;\
                        exec quartus_pgmw${::TE::WIN_EXE} ;\
                        thread::send -async [thread::id] { set ::programmer_opened 0 } ;\
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
    if {$::creating_project eq 1} {
      .fr_status.lb600 configure -text "\"Create Project\" process is running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::creating_project eq 1} {
          .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        } elseif { $::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        } 
      }
      return 0
    }
    
    set cur_projname [glob -nocomplain -tails -directory ${::TE::QPROJ_PATH}/ *.qpf]
    if {[llength $cur_projname] eq 1 } {
      set ::project_opened 1
      set ::project_tid [thread::create -preserved]
      thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -id TE_TK-33 -msg "Open project. Please change to GUI." }
      thread::send -async $::project_tid " ;\
                        exec quartus${::TE::WIN_EXE}  ${::TE::QPROJ_PATH}/$cur_projname ;\
                        thread::send -async [thread::id] { set ::project_opened 0 } ;\
                        thread::release $::project_tid ;\
                      "    
    } else {
      if {$cur_projname eq ""} {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-34 -msg \"Can't open Project. Project not found in ${::TE::QPROJ_PATH}. Please create project.\" "
      } elseif {$cur_projname > 1} {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-35 -msg \"Can't open Project. Found more than one project in ${::TE::QPROJ_PATH} (Project names: $cur_projname).\" "
      }
      set ::project_opened 0
    }
  }
  
  #--------------------------------
  #-- cancel running process in other thread
  proc thread_cancel_process {} {
    set ::canceled 1
    tsv::set ::cancel_process ::TK 1
    .fr_status.lb600 configure -text "Cancel process ..."
    vwait ::canceled 
    tsv::set ::cancel_process ::TK 0
    thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type warning -id TE_TK-21 -msg "Process canceled." }
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
      thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type critical_warning -id TE_TK-22 -msg \"Eclipse IDE not found. See '<quartus_installation_path>/$::qvers/nios2eds/bin/README' for installation instructions.\" "
    }
  }

  #--------------------------------
  #-- open 'NIOS II Command Shell' in thread
  proc thread_open_command_shell {} {
    set ::shell_tid [thread::create -preserved {thread::wait}]    
    if {$::tcl_platform(platform) eq "windows"} {
      switch ${::TE::WSL_EN} {
        0 { thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type error -id TE_TK-23 -msg "Windows Subsystem for Linux (WSL) is not installed. WSL is needed to open Nios II Command Shell. The software project can't be created. For more information and how to install WSL, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
          return 0
        }
        1 { thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type error -id TE_TK-24 -msg "No Linux distribution installed for WSL. A Linux distribution is needed to open Nios II Command Shell. For more information and installation instructions, see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html" }
          return 0
        }
        2 { thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-25 -msg \"Please install missing commands (\[tsv::get need_cmd ::TK\]) in the linux distribution. Can't open Nios II Command Shell without this commands. For more information see: https://www.intel.com/content/altera-www/global/en_us/index/support/support-resources/knowledge-base/tools/2019/how-do-i-install-the-windows--subsystem-for-linux---wsl--on-wind.html\" "
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
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type warning -id TE_TK-26 -msg \"Current desktop environment: $::env(XDG_CURRENT_DESKTOP). This scripts only support GNOME and KDE.\" "
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
  #-- menubar -> File -> Export prebuilt files to base directory
  proc export_prebfiles {} {
    if {$::creating_project eq 1} {
      .fr_status.lb600 configure -text "\"Create Project\" process is already running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::creating_project eq 1} {
          .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        } elseif { $::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
      }
      return 0
    }
    if {$::programming_device eq 1} {
      .fr_status.lb600 configure -text "\"Program device\" process is running. Please wait until the process finished."
      after 5000 {
        if {$::canceled eq 0 && $::programming_device eq 1} {
          .fr_status.lb600 configure -text "Program device ..."
        } elseif {$::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        }
      }
      return 0
    }
    
    if {$::selected_id ne "NA"} {
      # initialize selected board for export correct prebuilt files
      set ::init_board_done 0
      thread::send -async $::TE::MAINTHREAD " if {\[catch {::TE::INIT::init_board \[::TE::BDEF::get_id $::selected_id\]} result\]} {::TE::UTILS::te_msg -type error -id TE_TK-51 -msg \"Script (TE::INIT::init_board) failed: \$result.\"; return -code error} "                
      vwait ::init_board_done
      
      if {[file exists ${::TE::PREBUILT_PATH}/${::selected_shortname}]} {
        thread::send -async $::TE::MAINTHREAD " if {\[catch {exec {*}\[auto_execok start\] \[file nativename \[::TE::UTILS::copy_user_export\]\]} result\]} { ::TE::UTILS::te_msg -type error -id TE_TK-52 -msg \"(TE) Script (::TE::UTILS::copy_user_export) failed: \$result.\" } "  
      } else {
        thread::send -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-41 -msg \"No prebuilt files found for selected Product ID.\" "
      }
    } else {
      thread::send   -async $::TE::MAINTHREAD " ::TE::UTILS::te_msg -type error -id TE_TK-44 -msg \"No Product ID selected. Please select the correct Product ID.\" "
    }
  }
  
  #--------------------------------
  #-- menubar -> ? -> About
  proc about_window_tk {} {
    # set toplevel
    toplevel .about -class Dialog
  
    # set color of wm .about background
    ttk::style configure .about.TFrame    -background $::colors(-white)
    ttk::style configure .fr_info.TLabel  -background $::colors(-white)
    ttk::style configure .lb500.TLabel    -weight bold
    
    grid [ttk::frame .about.background ]  -sticky nesw -rowspan 10 -columnspan 10 

    grid [ttk::label .about.lb500 -text "\nCreate Project - Version $::tk_VERSION\n" -justify center -anchor center -font ownfont_12bold] -row 0
    
    grid [ttk::frame .about.fr_info -style .about.TFrame -padding {0 0 11 0}]  -sticky nesw -row 1
    grid [ttk::label .about.fr_info.lb501 -image [image create photo -file ${::TE::BASEFOLDER}/scripts/logo.gif] -compound center             -style .fr_info.TLabel] -row 1 -column 0 -rowspan 3 -padx 2 -pady 5
    grid [ttk::label .about.fr_info.lb502 -text "Address:"                                                                -padding {0 9 0 0}  -style .fr_info.TLabel] -row 1 -column 1            -padx 2 -pady 2  -sticky nw
    grid [ttk::label .about.fr_info.lb503 -text "Trenz Electronic GmbH\nBeendorfer Strasse 23\n32609 Huellhorst\nGermany" -padding {0 10 0 0} -style .fr_info.TLabel] -row 1 -column 2            -padx 2 -pady 2  -sticky nw
    grid [ttk::label .about.fr_info.lb504 -text "Email:"                                                                                      -style .fr_info.TLabel] -row 2 -column 1            -padx 2 -pady 2  -sticky nw
    grid [ttk::label .about.fr_info.lb505 -text "info@trenz-electronic.de"                                                                    -style .fr_info.TLabel] -row 2 -column 2            -padx 2 -pady 2  -sticky nw
    grid [ttk::label .about.fr_info.lb506 -text "Website:"                                                                                    -style .fr_info.TLabel] -row 3 -column 1            -padx 2 -pady 2  -sticky nw
    grid [ttk::label .about.fr_info.lb507 -text "https://www.trenz-electronic.de/"                                                            -style .fr_info.TLabel] -row 3 -column 2            -padx 2 -pady 2  -sticky nw
    
    grid [ttk::button .about.fr_info.ok_btn -text "OK"  -width 15 -command {destroy .about}] -row 4 -columnspan 3 -padx 4 -pady 10 -sticky e
  
    bind .about.fr_info.lb505 <1> "$::open_extern mailto:info@trenz-electronic.de"
    bind .about.fr_info.lb507 <1> "$::open_extern https://www.trenz-electronic.de"
    
    ::TE::TK::bind_link_label {.about.fr_info.lb507 .about.fr_info.lb505}
    
    # create and center about window
    wm withdraw .about
    update    
    set x_about [expr {([winfo screenwidth .]-[winfo width .about])/3}]
    set y_about [expr {([winfo screenheight .]-[winfo height .about])/4}]
    wm geometry .about +$x_about+$y_about    
    wm title .about "About - Create Project"
    wm resizable .about 0 0
    wm deiconify .about
    
    tk::SetFocusGrab .about
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
  #-- run, when exit Create Project GUI
  proc exit_tk {} {
    if {$::creating_project eq 1 || $::programming_device eq 1} {
      .fr_status.lb600 configure -text "A process is running. Please wait until the process finished."
      after 5000 { 
        if {$::canceled eq 0 && $::creating_project eq 1} {
          .fr_status.lb600 configure -text "Create project for $::run_selected_board ..."
        } elseif {$::canceled eq 0 && $::programming_device eq 1} {
          .fr_status.lb600 configure -text "Program device ..."
        } elseif { $::canceled eq 1} {
          .fr_status.lb600 configure -text "Cancel running process ..."
        } 
      }
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
  
  thread::send -async $::TE::MAINTHREAD { ::TE::UTILS::te_msg -type info -msg "(TE) Load TK script finished" }
}
