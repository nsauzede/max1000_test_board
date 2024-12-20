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
# -- $Date: 2019/11/11 | $Author: Dück, Thomas
# -- - copy preset files to project folder
# ------------------------------------------
# -- $Date: 2022/01/24 | $Author: Dück, Thomas
# -- - add generated os files to clean_project
# ------------------------------------------
# -- $Date: 2022/03/17 | $Author: Dück, Thomas
# -- - add copy_user_export function
# -- - add write_board_select function
# ------------------------------------------
# -- $Date: 2022/08/10 | $Author: Dück, Thomas
# -- - add copy_pgm_flash_template function
# ------------------------------------------
# -- $Date: 2022/09/28 | $Author: Dück, Thomas
# -- - add optional arguments to proc report, proc copy_user_export, proc write_board_select
# -- - add new function proc findFiles, proc find_com_port, proc pr_putty, proc run_putty, proc run_serial, proc Dos2Unix
# ------------------------------------------
# -- $Date: 2023/06/02 | $Author: Dück, Thomas
# -- - check if file exists in proc modify_files {}
# -- - adapt proc copy_source_files {} to new source files structure
# ------------------------------------------
# -- $Date: 2023/09/21 | $Author: Dück, Thomas
# -- - add function delete_files
# --------------------------------------------------------------------
# --------------------------------------------------------------------
namespace eval ::TE {
  tsv::set ::TE::TK_MSG_EN ::TK 0
  set ::TE::LOG_PATH [pwd]/log ;#need for ::TE::UTILS::write_log_file
  set ::TE::cntscriptinfo 0
  set ::TE::cntscriptwarning 0
  set ::TE::cntscriptcriticalwarning 0
  set ::TE::cntscripterror 0
  
  set ::TE::cntprebinfo 0
  set ::TE::cntprebwarning 0
  set ::TE::cntprebcriticalwarning 0
  set ::TE::cntpreberror 0
  
 namespace eval UTILS {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # report functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- report: 
  proc report {{args ""}} {
    set RESULT "NA"
    set COMMAND "NA"
    set MSGID "NA"
    set SILENT ""
    set num [llength $args]
    for {set option 0} {$option < $num} {incr option} {
      switch [lindex $args $option] {
        "-msg"      { set RESULT  [lindex $args $option+1];   incr option; }  
        "-command"  { set COMMAND  [lindex $args $option+1];  incr option; }
        "-msgid"    { set MSGID    [lindex $args $option+1];  incr option; }
        "-silent"   { set SILENT   "-silent" }
        ""          {}
        default     { ::TE::UTILS::write_log_file "Unrecognised argument: report [lindex $args $option]."
                      ::TE::UTILS::te_msg -type error -id TE_UTILS-01 -msg "Unrecognised argument [lindex $args $option]."
                      ::TE::UTILS::te_msg -msg "Expected arguments: report \[-result \"<result>\"\] \[-command \"<command>\"\] \[-msgid \"<message id>\"\]"
                      ::TE::UTILS::te_msg -msg "     Options:"
                      ::TE::UTILS::te_msg -msg "         -silent"
                      return
                    }
      }
    }
  
    ::TE::UTILS::te_msg -type Info -id $MSGID -msg "Command results on: $COMMAND:\n" $SILENT
    set data [split $RESULT "\n"]
    foreach line $data {
      if {([regexp -nocase {Error: (.*)} $line matched linetmp1] || [regexp -nocase {Error! (.*)} $line matched linetmp1] || [regexp {Error (\((.*)\): (.*))} $line matched linetmp1] || [regexp -nocase {(.*)Hardware\ not\ attached(.*)} $line linetmp1]) && ![regexp -nocase {(.*)Device family can not be determined(.*)} $line linetmp1]} {
        ::TE::UTILS::te_msg -type Error -msg "$linetmp1"
        return 1
      } elseif {[regexp -nocase {Critical Warning: (.*)} $line matched linetmp3] || [regexp {Critical Warning (\((.*)\): (.*))} $line matched linetmp3] || [regexp -nocase {(.*)Device family can not be determined(.*)} $line linetmp3]} {  ;#https://www.intel.com/content/www/us/en/programmable/support/support-resources/knowledge-base/tools/2017/error--device-family-can-not-be-determined.html
        ::TE::UTILS::te_msg -type Critical_Warning -msg "$linetmp3" $SILENT
      } elseif {[regexp -nocase {Warning: (.*)} $line matched linetmp2] || [regexp {Warning (\((.*)\): (.*))} $line matched linetmp2]} {
        ::TE::UTILS::te_msg -type Warning -msg "$linetmp2" $SILENT
      } elseif {[string match "*GetProcAddress failed*" $line]} {
        ::TE::UTILS::te_msg -msg "$line" -silent
      } else {
        if {[regexp -nocase {Info: (.*)} $line matched linetmp4] || [regexp {Info (\((.*)\): (.*))} $line matched linetmp4]} {
          ::TE::UTILS::te_msg -type Info -msg "$linetmp4" $SILENT
        } else {
          ::TE::UTILS::te_msg -msg "$line" $SILENT
        }
      }
    }
    return 0
  }  

  #--------------------------------
  #-- report prebuilt_hw_summary.csv 
  proc report_prebuilt_hw_summary {} {
    set date "[ clock format [clock seconds] -format "%Y-%m-%d_%H:%M:%S"]"
    set status "Error"
    set counts [split [extract_rpt_files] ","]
    if {[lindex $counts 3] == 0 && ${::TE::cntpreberror} == 0} {set status "Ok"}

    set report "[format "%-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s" "$date" "$status" "${::TE::QPROJ_SRC_NAME}" "${::TE::SDK_SRC_NAME}" "${::TE::SHORTNAME}" "${::TE::PRODID}"  "[lindex $counts 0]" "[lindex $counts 1]" "[lindex $counts 2]" "[lindex $counts 3]" "${::TE::cntprebinfo}" "${::TE::cntprebwarning}" "${::TE::cntprebcriticalwarning}" "${::TE::cntpreberror}" "${::TE::prebtime}"]"

    set prebuilt_file ${::TE::PREBUILT_PATH}/hardware_summary.csv

    if {[file exists ${prebuilt_file}]} {
      set fp_r [open ${prebuilt_file} "r"]
      set filedata [read $fp_r]
      close $fp_r  

      if {[string match "* ${::TE::SHORTNAME} *" $filedata]} {
        set data [split $filedata "\n"]
        set fp_w [open ${prebuilt_file} "w"]
        foreach line $data {
          if {[string match "* ${::TE::SHORTNAME} *" $line]} {
            puts $fp_w $report
          } else {
            puts $fp_w $line
          }
        }
        close $fp_w
      } else {
        set fp_a [open ${prebuilt_file} "a"]
        puts $fp_a $report
        close $fp_a
      }
    } else {
      set fp_w [open ${prebuilt_file} "w"]
      puts $fp_w "[format "%-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s, %-40s" "Date" "Status" "ProjName" "SDKName" "BoardDefShortName" "BoardDefName" "CompInfo" "CompWarnings" "CompCritWarnings" "CompError" "PrebInfo" "PrebWarnings" "PrebCritWarnings" "PrebError" "Prebtime/s"]\n$report"
      close $fp_w
    }

  }

  #--------------------------------
  #-- extract_rpt_files: 
  proc extract_rpt_files {} {
    set cntinfo 0
    set cntwarning 0
    set cntcriticalwarning 0
    set cnterror 0
    
    if {[file exists ${::TE::QPROJ_PATH}/output_files]} {
      set rpt_filedir ${::TE::QPROJ_PATH}/output_files
    } else {
      set rpt_filedir ${::TE::QPROJ_PATH}
    }
    
    set rpt_files [glob -nocomplain -directory $rpt_filedir *.rpt]
    if {$rpt_files eq ""} { return "error,error,error,error" }
   
    foreach rpt $rpt_files {
      set messages false
      set fp_r [open ${rpt} "r"]
      set file_data [read $fp_r]
      set data [split $file_data "\n"]
      close $fp_r
    
      if {![regexp -nocase {(.*) report} [lindex $data 0] matched rpt_name]} {
        ::TE::UTILS::te_msg -type Critical_Warning -id TE_UTILS-27 -msg "File: $rpt. Report name not found."
      } else {  
        foreach line $data {
          if {[string match -nocase "\; $rpt_name Messages \;" $line]} {
            set messages true
          }
        
          if {$messages} {
            if {[regexp {Info } $line matched]} {
              incr cntinfo
            }
            if {[regexp {Warning } $line matched] && ![regexp {Critical Warning } $line matched]} {
              incr cntwarning
            }
            if {[regexp {Critical Warning } $line matched]} {
              incr cntcriticalwarning
            }
            if {[regexp {Error } $line matched]} {
              incr cnterror
            }
          }
        }
      }            
    }
    return "$cntinfo,$cntwarning,$cntcriticalwarning,$cnterror"
  }   

  #--------------------------------
  #-- write output to log file quartus_<date>-<time>.log: 
  proc write_log_file {DATA} {  
    set fp_a [open ${::TE::LOG_PATH}/${::TE::CURRENT_LOG_FILE} a]
    puts $fp_a "$DATA"
    close $fp_a
  }

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished report functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # modify tcl files functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- modify tcl:  
  proc modify_files {} {      
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-30 -msg "Modify files. Please wait ..."
    ::TE::INIT::init_mod_list
    set data "NA"
    set found "NA"
    set file_not_found 0
    foreach modlist $::TE::MOD_LIST {
      if { $file_not_found eq 0 } { ::TE::UTILS::te_msg -type Info -msg "  >> $modlist" }
      set line_index -1
      set id [lindex $modlist 0]
      set line_check [lindex $modlist 1]
      set modify [list]
      for {set i 2} {$i < [llength $modlist]} {incr i} {
        lappend modify [lindex $modlist $i]
      }
      
      foreach line $data {
        incr line_index
        switch $id {
          "read" {
            if { ![file exists ${::TE::QPROJ_SOURCE_PATH}/[lindex $modlist 1]] } {
              ::TE::UTILS::te_msg -type critical_warning -id TE_UTILS-31 -msg "${::TE::QPROJ_SOURCE_PATH}/[lindex $modlist 1]: File not found."
              set file_not_found 1
            } else {
              set fpr [open "${::TE::QPROJ_SOURCE_PATH}/[lindex $modlist 1]" r]
              set filedata [read $fpr]
              close $fpr
              set data [split $filedata "\n"]
              if {[string match -nocase "*<?xml *" $data]} {
                set commentout_start "<!--"
                set commentout_end "-->"
              } else {
                set commentout_start "#"
                set commentout_end ""
              }
            }
            break
          }
          "write" {
            if { $file_not_found eq 0 } {
              set fpw [open "${::TE::QPROJ_SOURCE_PATH}/[lindex $modlist 1]" w]
              foreach line $data {
                puts $fpw $line
              }
              close $fpw
            } else {
              set file_not_found 0
            }
            break
          }
          "0" { ;# remove(comment) line (set modify to NA, if no line to add after removed line)
            if {[string match $line_check $line] && ![string match *#TE_MOD#* $line] && $file_not_found eq 0 } {
              if {$modify ne "NA"} {
                foreach mod $modify {
                  set data [lreplace $data[set data {}] $line_index $line_index "${commentout_start} #TE_MOD# $line ${commentout_end}\n${commentout_start} #TE_MOD#_Add next line ${commentout_end}\n$mod"]  
                }
              } else {
                set data [lreplace $data[set data {}] $line_index $line_index "${commentout_start} #TE_MOD# $line ${commentout_end}"]
              }
            }
          }
          "1" { ;# add line {add modify text before line_check}
            if {[string match $line_check $line] && ![string match *#TE_MOD#* $line] && $file_not_found eq 0 } {
              foreach mod $modify {
                set data [linsert $data[set data {}] [expr $line_index-1] "${commentout_start} #TE_MOD#_Add next line\n$mod ${commentout_end}"]
              }
            }
          }
          "2" { ;# add line {add modify text after line_check}
            if {[string match $line_check $line] && ![string match *#TE_MOD#* $line] && $file_not_found eq 0 } {
              set i 0
              foreach mod $modify {
                incr i
                set data [linsert $data[set data {}] [expr $line_index+$i]  "${commentout_start} #TE_MOD#_Add next line\n$mod ${commentout_end}"]
              }
            }
          }
          "3" { ;#  remove(comment) component property {instance name, property,property,...}
            if {([string match "add_instance $line_check *" $line] || [string match "*add_component $line_check*" $line]) && ![string match *#TE_MOD#* $line] && $file_not_found eq 0 } {
              set found 1
            } elseif {([string match "add_instance *" $line] || [string match "*add_component *" $line]) && ![string match *#TE_MOD#* $line]} {
              set found 0
            } elseif {$found eq 1} {
              foreach mod $modify {
                if {([string match "*set_instance_parameter_value $line_check {$mod}*" $line] || [string match "*set_component_parameter_value $mod*" $line]) && ![string match *#TE_MOD#* $line]} {
                  set data [lreplace $data[set data {}] $line_index $line_index "${commentout_start} #TE_MOD# $line ${commentout_end}"]
                }          
              }
            }
          }
          "4" { ;# add component property {instance name, property,property,...}
            if {([string match "add_instance $line_check *" $line] || [string match "*load_component $line_check" $line]) && ![string match *#TE_MOD#* $line] && $file_not_found eq 0 } {
              set i 0
              foreach mod $modify {
                incr i
                set data [linsert $data[set data {}] [expr $line_index+$i]  "${commentout_start} #TE_MOD#_Add next line\n$mod ${commentout_end}"]
              }
            }
          }
          "5" { ;# replace strings
            if {[regexp $line_check $line matched] && ![string match *#TE_MOD#* $line] && $file_not_found eq 0 } {
              foreach mod $modify {  
                regsub "$matched" $line "$mod" line
                set data [lreplace $data[set data {}] $line_index $line_index "${commentout_start} #TE_MOD#_Replaced string next line \"${matched}\" -> \"$mod\"\n$line ${commentout_end}"]
              }
            }
          }
          "tcl_cmd" { ;# special tcl commands for project
            if { $file_not_found eq 0 } { catch [eval $line_check] result }
          }
          default {::TE::UTILS::te_msg -type error -id TE_UTILS-29 -msg "(::TE::UTILS::modify_tcl) unrecognised option: ID: $id, line_check: $line_check, modify: $modify"}
        }      
      }
    }  
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-32 -msg "Modify files -> done"
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished modify tcl files functions
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # Clean functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
  #--------------------------------
  #-- clean_all:  
  proc clean_all {} {
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-04 -msg "Clean all (project, software, log and prebuilt folder)"
    ::TE::UTILS::clean_project
    ::TE::UTILS::clean_software
    ::TE::UTILS::clean_prebuilt
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-05 -msg "Clean all -> finished"
  }
  
  #--------------------------------
  #-- clean_project:  
  proc clean_project {} {
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-06 -msg "Clean project workspace"
    if {[file exist ${::TE::QPROJ_PATH}]} {
      if {[catch {file delete -force ${::TE::QPROJ_PATH}} result]} {
        ::TE::UTILS::te_msg -type Error -id TE_UTILS-07 -msg "Error on ::TE::UTILS::clean_project:\n$result"
        return -code error
      } else {
        ::TE::UTILS::te_msg -type Info -id TE_UTILS-08 -msg "${::TE::QPROJ_PATH} deleted."
      } 
    } else {
      ::TE::UTILS::te_msg -type Info -id TE_UTILS-09 -msg "${::TE::QPROJ_PATH} doesn't exist."
    }
    
    if {[file exist ${::TE::OS_PATH}]} {
      if {[catch {file delete -force ${::TE::OS_PATH}} result]} {
        ::TE::UTILS::te_msg -type Error -id TE_UTILS-02 -msg "Error on ::TE::UTILS::clean_project:\n$result"
        return -code error
      } else {
        ::TE::UTILS::te_msg -type Info -id TE_UTILS-03 -msg "${::TE::OS_PATH} deleted."
      } 
    }
  }
  
  #--------------------------------
  #-- clean_software:  
  proc clean_software {} {
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-10 -msg "Clean software workspace"
    if {[file exist ${::TE::SDK_PATH}]} {
      if {[catch {file delete -force ${::TE::SDK_PATH}} result]} {
        ::TE::UTILS::te_msg -type Error -id TE_UTILS-11 -msg "Error on ::TE::UTILS::clean_software:\n$result"
        return -code error
      } else {
        ::TE::UTILS::te_msg -type Info -id TE_UTILS-12 -msg "${::TE::SDK_PATH} deleted."
      }
    } else {
      ::TE::UTILS::te_msg -type Info -id TE_UTILS-13 -msg "${::TE::SDK_PATH} doesn't exist."
    }
  }  
  
  #--------------------------------
  #-- clean_source_files:  
  proc clean_source_files {} {
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-18 -msg "Clean source_files folder"
    if {[file exist ${::TE::SOURCE_PATH}] && [glob -nocomplain -directory ${::TE::SOURCE_PATH} os quartus software] != ""} {
      foreach dir [glob -tail -nocomplain -directory ${::TE::SOURCE_PATH} *] {
        if {[catch {file delete -force ${::TE::SOURCE_PATH}/${dir}} result]} {
          ::TE::UTILS::te_msg -type Error -id TE_UTILS-19 -msg "Error on ::TE::UTILS::clean_source_files -> ${dir}:\n$result"
          return -code error
        } else {
          ::TE::UTILS::te_msg -type Info -id TE_UTILS-20 -msg "${::TE::SOURCE_PATH}/${dir} deleted."
        }
      }
    } else {
      ::TE::UTILS::te_msg -type Info -id TE_UTILS-21 -msg "${::TE::SOURCE_PATH} is already empty."
    }
  }
  
  #--------------------------------
  #-- clean prebuilt files:  
  proc clean_prebuilt {shortname} {
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-22 -msg "Clean prebuilt folder"
    if {[file exists ${::TE::PREBUILT_PATH}] && [glob -nocomplain -directory ${::TE::PREBUILT_PATH} *] != ""} {
      foreach dir [glob -tail -nocomplain -directory ${::TE::PREBUILT_PATH} *] {    
        if {$shortname ne "all" && [lsearch -exact ${dir} $shortname] ne -1} {
          if {[catch {file delete -force ${::TE::PREBUILT_PATH}/${dir}} result]} {
            ::TE::UTILS::te_msg -type Error -id TE_UTILS-23 -msg "Error on ::TE::UTILS::clean_prebuilt -> ${dir}:\n$result"
            return -code error
          } 
        } else {
          ::TE::UTILS::te_msg -type Info -id TE_UTILS-24 -msg "${::TE::PREBUILT_PATH}/${dir} does not exists."
        }
      }
    } else {
      ::TE::UTILS::te_msg -type Info -id TE_UTILS-25 -msg "${::TE::PREBUILT_PATH} is already empty."
    }
  }
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished clean functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------

  # -----------------------------------------------------------------------------------------------------------------------------------------
  # Additional functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  #--------------------------------
  #-- print_boardlist:  
  proc print_boardlist {} {
    foreach line $::TE::BOARD_DEFINITION {
      if {[string match -nocase *id* $line]} {
        ::TE::UTILS::te_msg -msg [format "========================================================================================================================================================================"]
        ::TE::UTILS::te_msg -msg [format "|%-3s|%-20s|%-20s|%-20s|%-15s|%-10s|%-12s|%-37s|%-10s|%-10s|" "[lindex $line 0]" "[lindex $line 1]" "[lindex $line 2]" "[lindex $line 3]" "[lindex $line 4]" "[lindex $line 5]" "[lindex $line 6]" "[lindex $line 7]" "[lindex $line 8]" "[lindex $line 9]"]
        ::TE::UTILS::te_msg -msg [format "========================================================================================================================================================================"]
      } else {
        ::TE::UTILS::te_msg -msg [format "|%-3s|%-20s|%-20s|%-20s|%-15s|%-10s|%-12s|%-37s|%-10s|%-10s|" "[lindex $line 0]" "[lindex $line 1]" "[lindex $line 2]" "[lindex $line 3]" "[lindex $line 4]" "[lindex $line 5]" "[lindex $line 6]" "[lindex $line 7]" "[lindex $line 8]" "[lindex $line 9]"]
        ::TE::UTILS::te_msg -msg [format "------------------------------------------------------------------------------------------------------------------------------------------------------------------------"]
      }      
    }
  }
  
  #--------------------------------
  #-- copy source files to project folder
  proc copy_source_files {} {
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-26 -msg "Copy source files to project ..."
    set srclist1 [list]
    # add files from ./source_files/quartus to srclist1
    if { [file exists ${::TE::SOURCE_PATH}/quartus] } {
      foreach addsrc1 [glob -nocomplain -directory ${::TE::SOURCE_PATH}/quartus/ *] {
        lappend srclist1 "$addsrc1"
      }
    }
    if { ${::TE::QPROJ_SOURCE_PATH} ne "${::TE::SOURCE_PATH}//quartus" } {
      # add files from ./source_files/shortname/quartus to srclist1
      foreach addsrc2 [glob -nocomplain -directory ${::TE::QPROJ_SOURCE_PATH}/ *] {
        lappend srclist1 "$addsrc2"
      }
    }
    # copy files to project directory from srclist1
    foreach sourcefile $srclist1 {
      set command "file copy -force $sourcefile ${::TE::QPROJ_PATH}"
      if { [file exists ${::TE::QPROJ_PATH}/[file tail $sourcefile]] && [file isdirectory ${::TE::QPROJ_PATH}/[file tail $sourcefile]] } {
        foreach addsrc3 [glob -nocomplain -directory ${sourcefile}/ *] {
          set command "file copy -force $addsrc3 ${::TE::QPROJ_PATH}/[file tail $sourcefile]"
          if {[catch {eval $command } result]} {
            ::TE::UTILS::te_msg -type error -id TE_UTILS-33 -msg "Error on $command: \n $result"
            return -code error 
          }
        }
      } elseif {[catch {eval $command } result]} {
        ::TE::UTILS::te_msg -type error -id TE_UTILS-28 -msg "Error on $command: \n $result"
        return -code error 
      }
    }

    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- Export prebuilt files to base directory
  proc copy_user_export {{args ""}} {
    set SILENT ""
    set args_cnt [llength $args]
    for {set option 0} {$option < $args_cnt} {incr option} {
      switch [lindex $args $option] { 
        "-silent" { set SILENT "-silent" }
        ""        {}
        default   { ::TE::UTILS::te_msg -type error -id TE_UTILS-37 -msg "Unrecognised argument: copy_user_export [lindex $args $option]."
                    ::TE::UTILS::te_msg -msg "Expected arguments: copy_user_export \[options\]"
                    ::TE::UTILS::te_msg -msg "     Options:"
                    ::TE::UTILS::te_msg -msg "         -silent"
                    return
                  }
      }
    }

    set hwlist [list]
    set elflist [list]
    set oslist [list]
    set hwlist  [glob -nocomplain -dir ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/hardware/ *]
    set elflist [glob -nocomplain -dir ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/software/ *]
    set oslist  [glob -nocomplain -dir ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/os/ *]
      
    set ::binaries_basepath ${::TE::BASEFOLDER}/_binaries_${::TE::PRODID}
    if {[file exist $::binaries_basepath]} {
      file delete -force $::binaries_basepath
    }
    if {$hwlist ne ""} {
      set hw_loc  ${::binaries_basepath}/res_hw
      file mkdir  ${hw_loc}
      foreach hw $hwlist {
        file copy -force ${hw} ${hw_loc}
      }
    }
    if {$oslist ne ""} {
      set os_loc  ${::binaries_basepath}/res_os
      file mkdir  ${os_loc}
      foreach os $oslist {
        if { ![string match -nocase *boot_linux* $os] } {
          file copy -force ${os} ${os_loc}
        } else {
          file copy -force ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/os/boot_linux ${::binaries_basepath}
        }
      }
    } else {
      file copy -force ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/programming_files ${::binaries_basepath}
    }
    if {$elflist ne ""} {
      set elf_loc  ${::binaries_basepath}/res_elf
      file mkdir  ${elf_loc}
      foreach elf $elflist {
        if {[string match *.bin $elf] && [file exists ${::binaries_basepath}/programming_files]} {
          file copy -force ${elf} ${::binaries_basepath}/programming_files
        } else {
          file copy -force ${elf} ${elf_loc}
        }
      }
    }
    
    ::TE::UTILS::write_board_select -dir $::binaries_basepath $SILENT
    
    return $::binaries_basepath
  }

  #--------------------------------  
  #-- copy pgm_flash_TE.xml file to quartus installation path: 
  proc copy_pgm_flash_template {} {
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-38 -msg "pgm flash xml custom search path (GFPDB_CUSTOM_DATABASE_DIRECTORY): [get_user_option -name GFPDB_CUSTOM_DATABASE_DIRECTORY]"
    return 0
    if {[file exists ${::TE::SET_PATH}/pgm_flash_TE.xml]} {
      if { ![file exists ${::TE::QROOTPATH}common/devinfo/programmer/xml/pgm_flash_TE.xml] } {
        ::TE::UTILS::te_msg -type Info -id TE_UTILS-14 -msg "Copy pgm_flash_TE.xml to ${::TE::QROOTPATH}common/devinfo/programmer/xml/"
        if {[catch { file copy -force ${::TE::SET_PATH}/pgm_flash_TE.xml ${::TE::QROOTPATH}common/devinfo/programmer/xml/ } result]} {::TE::UTILS::te_msg -type critical_warning -id TE_UTILS-15 -msg "$result."}
      } else {
        set fp [open "${::TE::QROOTPATH}common/devinfo/programmer/xml/pgm_flash_TE.xml" r]
        set file_data [read $fp]
        close $fp

        set data [split $file_data "\n"]
        foreach line $data {
          #  check file version ignore comments and empty lines
          if { [string match -nocase "*<qspi_flash version=*" $line] } {
            #remove spaces
            set linetmp [string map {" " ""} $line]
            #remove tabs
            set linetmp [string map {"\t" ""} $linetmp]
            set linetmp [string map {">" ""} $linetmp]
            set linetmp [string map {"\"" ""} $linetmp]
            #check version
            set tmp [split $linetmp "="]
            if {[string match [lindex $tmp 1] ${::TE::PGM_FLASH_XML}] != 1} {
              ::TE::UTILS::te_msg -type info -id TE_UTILS-16 -msg "Wrong pgm flash TE xml version (${::TE::QROOTPATH}common/devinfo/programmer/xml/pgm_flash_TE.xml): get [lindex $tmp 1] expected ${TE::PGM_FLASH_XML}."
              ::TE::UTILS::te_msg -type info -msg "Copy latest pgm_flash_TE.xml file to ${::TE::QROOTPATH}common/devinfo/programmer/xml/."
              if {[catch { file copy -force ${::TE::SET_PATH}/pgm_flash_TE.xml ${::TE::QROOTPATH}common/devinfo/programmer/xml/ } result]} {::TE::UTILS::te_msg -type critical_warning -id TE_UTILS-17 -msg "$result."}
            }
            return 0
          }
        }
      }
    }
  }
 
  #--------------------------------  
  #-- write_board_select: 
  proc write_board_select {{args ""}} {
  
    set DIR "NA"
    set SILENT ""
    set args_cnt [llength $args]
    for {set option 0} {$option < $args_cnt} {incr option} {
      switch [lindex $args $option] { 
        "-dir"    { set DIR [lindex $args $option+1];  incr option; }
        "-silent" { set SILENT "-silent" }
        ""        {}
        default   { ::TE::UTILS::te_msg -type error -id TE_UTILS-50 -msg "Unrecognised argument: write_board_select [lindex $args $option]."
                    ::TE::UTILS::te_msg -msg "Expected arguments: write_board_select \[options\]"
                    ::TE::UTILS::te_msg -msg "     Options:"
                    ::TE::UTILS::te_msg -msg "          -dir"
                    ::TE::UTILS::te_msg -msg "          -silent"
                    return
                  }
      }
    }
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-34 -msg "Write board select info file ..." $SILENT
    set infofile ${::TE::QPROJ_PATH}/${::TE::PRODID}.teinfo
    if {![string match "NA" $DIR ]} {
      set infofile ${DIR}/${::TE::PRODID}.teinfo
    }
    set fp_w [open ${infofile} "w"] 
    puts $fp_w "Creation Date:    [ clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]"
    puts $fp_w "TE::ID:           ${::TE::ID}         "
    puts $fp_w "TE::PRODID:       ${::TE::PRODID}     "
    puts $fp_w "TE::FAMILY:       ${::TE::FAMILY}     "
    puts $fp_w "TE::DEVICE:       ${::TE::DEVICE}     "
    puts $fp_w "TE::SHORTNAME:    ${::TE::SHORTNAME}  "
    puts $fp_w "TE::FLASHTYP:     ${::TE::FLASHTYP}   "
    puts $fp_w "TE::FLASH_SIZE:   ${::TE::FLASH_SIZE} "
    puts $fp_w "TE::DDR_DEV:      ${::TE::DDR_DEV}    "
    puts $fp_w "TE::DDR_SIZE:     ${::TE::DDR_SIZE}   "
    puts $fp_w "TE::PCB_REV:      ${::TE::PCB_REV}    "
    puts $fp_w "TE::NOTES:        ${::TE::NOTES}      "
    close $fp_w
    
    ::TE::UTILS::te_msg -type Info -id TE_UTILS-35 -msg "Board select info file directory: $infofile" $SILENT
    ::TE::UTILS::te_msg -msg "------------------------------" $SILENT
  }

  #--------------------------------
  #-- findFiles: Find recursive files in folders and return list with full path
  proc findFiles { baseDir pattern } {
    set dirs [ glob -nocomplain -type d [ file join $baseDir * ] ]
    set files {}
    foreach dir $dirs { 
      lappend files {*}[ findFiles $dir $pattern ] 
    }
    lappend files {*}[ glob -nocomplain -type f [ file join $baseDir $pattern ] ] 
    return $files
  }  
  
  #--------------------------------
  #-- find_com_port: search com port for serial console, only for WinOS
  proc find_com_port {} {  
    set command exec
    lappend command powershell${::TE::WIN_EXE}
    lappend command -command
    # lappend command "Get-PnpDevice -PresentOnly | Where-Object { \$_.InstanceId -like \"*VID_0403*PID_6010*\" } | Select-Object Status,Class,FriendlyName,InstanceId | Format-List"
    lappend command "Get-PnpDevice -Class Ports -PresentOnly | Where-Object { \$_.InstanceId -like \"FTDIBUS*\" } | Select-Object Status,Class,FriendlyName,InstanceId | Format-List"
    set result ""
    [catch {set val [eval $command]} result]
    ::TE::UTILS::report -msg $result -command $command -msgid TE_UTILS-46 -silent
    set result [string map {" " ""} $result]
    
    set comportlist [list]
    foreach line $result {
      if { $line ne "" && [string match "*COM*" $line]} {
        regexp -nocase -line {COM(\w+)} $line comport
        if {[lsearch $::TE::COM_IGNORE_LIST $comport] eq -1} {
          lappend comportlist $comport
        }
      } 
    }
    
    if {$comportlist ne ""} {
      ::TE::UTILS::te_msg -type info -id TE_UTILS-47 -msg "Available COM Ports: $comportlist"
    } else {
      ::TE::UTILS::te_msg -type error -id TE_UTILS-48 -msg "COM Ports for serial console not found."
    }
    
    return $comportlist
  }
  
  #--------------------------------
  #-- pr_putty: Requires Putty installation
  proc pr_putty {{args ""}} {
    set DISPLAY_COM false
    set LOGNAME ""

    set args_cnt [llength $args]
    for {set option 0} {$option < $args_cnt} {incr option} {
      switch [lindex $args $option] { 
        "-available_com"  { set DISPLAY_COM             true }
        "-com"            { set ::TE::DESIGN_UART_COM   [lindex $args $option+1];  incr option; }
        "-speed"          { set ::TE::DESIGN_UART_SPEED [lindex $args $option+1];  incr option; }
        "-log"            { set LOGNAME                 [lindex $args $option+1];  incr option; }
        default           { ::TE::UTILS::te_msg -type error -id TE_UTILS-36 -msg "Unrecognised argument: pr_putty [lindex $args $option]."
                            ::TE::UTILS::te_msg -msg "Expected arguments: pr_putty \[options\]"
                            ::TE::UTILS::te_msg -msg "     Options:"
                            ::TE::UTILS::te_msg -msg "          -available_com"
                            ::TE::UTILS::te_msg -msg "          -com   \"<com port>\""
                            ::TE::UTILS::te_msg -msg "          -speed \"<baudrate>\""
                            ::TE::UTILS::te_msg -msg "          -log   \"<log file name>\""
                            return
                          }
      }
    }
    ::TE::UTILS::te_msg -type info -id TE_UTILS-39 -msg "Start Putty console"
    if { ${DISPLAY_COM} } {
      ::TE::UTILS::find_com_port
    } else {
      if { ${::TE::DESIGN_UART_COM} eq "NA" } {
        ::TE::UTILS::te_msg -type warning -id TE_UTILS-44 -msg "Scripts try auto detect of COM port, if failed, try to open putty and connect to COM port manually."
      }        
      if { ${::TE::DESIGN_UART_SPEED} eq "NA"} {
        ::TE::UTILS::te_msg -type error -id TE_UTILS-40 -msg "Specify UART speed with TE::pr_putty -set_speed <arg>"
        return -code error
      }
      if { [catch {   
        set tmpcomlist [::TE::UTILS::find_com_port]
        if { $tmpcomlist eq "" } { 
          ::TE::UTILS::te_msg -type error -id TE_UTILS-49 -msg "Putty not opend"
          return
        }
        
        set com_av false
        foreach line $tmpcomlist {
          if {[string match "${::TE::DESIGN_UART_COM}" $line]} { set com_av true }
        }
        if { [llength $tmpcomlist] > 1 && !$com_av } {
          return "Found more than one serial COM port. Connect only one device and try again or open putty and connect to COM port manually"
        }
        if { ${com_av} eq false } {
          set ::TE::DESIGN_UART_COM [lindex $tmpcomlist [expr [llength $tmpcomlist]-1]]
          ::TE::UTILS::te_msg -type Info -id TE_UTILS-41 -msg "Set COM Port to ${::TE::DESIGN_UART_COM}"
        }
        ::TE::UTILS::te_msg -type info -id TE_UTILS-42 -msg "Open Putty on ${::TE::DESIGN_UART_COM} with speed ${::TE::DESIGN_UART_SPEED}"
        set printout [::TE::UTILS::run_putty $LOGNAME]
        ::TE::UTILS::te_msg -type info -id TE_UTILS-43 -msg "Putty is opened with PID: $printout"
      } result] } {::TE::UTILS::te_msg -type error -id TE_UTILS-45 -msg "Script (::TE::UTILS::run_putty) failed: $result."; return -code error}
    }

    ::TE::UTILS::te_msg -type info -id TE_UTILS-51 -msg "Start Putty console finished."
  }
  
  #--------------------------------
  #-- run_putty: under development, only for WinOS
  proc run_putty {{filename ""}} {
    if {$::tcl_platform(platform) eq "windows"} {
      # putty -serial com12 -sercfg 115200,8,n,1,N
      set command exec
      if { [file exists ${::TE::COM_PATH}/putty.exe] } {
        lappend command ${::TE::COM_PATH}/putty.exe
      } else {
        lappend command putty
      }
      lappend command -serial ${::TE::DESIGN_UART_COM} 
      lappend command -sercfg ${::TE::DESIGN_UART_SPEED},8,n,1,N
      if {[llength $filename] > 4} {
        lappend command -sessionlog ${::TE::LOG_PATH}/$filename
      } elseif {$filename eq "d"} {
      } else {
        lappend command -sessionlog ${::TE::LOG_PATH}/putty-${::TE::PRODID}-&y&m&d-&t.log
      }
      lappend command &
      set pid [eval $command]
      return $pid
    } else {
      return "Not supported on this OS"
    }
  }
  
  #--------------------------------
  #-- run_serial: 
  proc run_serial {{serial NA}  {metadata 0} {factoryorder 0}} {
    set val "Scanning not available"
    set command exec
    lappend command powershell${::TE::WIN_EXE}
    lappend command -file  
    lappend command ${::TE::SERIAL_PATH}/getartikelbyserial.ps1
    lappend command $serial
    lappend command ${::TE::SERIAL_PATH}
    lappend command ${metadata}
    lappend command ${factoryorder}
    lappend command "0"

    if {[catch {set val [eval $command]} result]} {set val "$result"}

    return $val
  }
  
  #--------------------------------
  #-- Dos2Unix: translate style from dos to unix
  proc Dos2Unix {f} {
    # puts $f
    if {[file isdirectory $f]} {
      foreach g [glob [file join $f *]] {
        Dos2Unix $g
      }
    } else {
      set in [open $f]
      set out [open $f.new w]
      fconfigure $out -translation lf
      puts -nonewline $out [read $in]
      close $out
      close $in
      file rename -force $f.new $f
    }
  }
  
  #--------------------------------
  #-- remove files/folder from directory and subdirectories
  proc delete_files {{args ""}} {
    set NAME ""
    set TYPE ""
    set BASE_DIR ""
    set SUB_DIR false
    # get args and set variables
    set args_cnt [llength $args]
    for {set option 0} {$option < $args_cnt} {incr option} {
      switch [lindex $args $option] {
        "--filename"        -
        "-n"                { set NAME      [lindex $args $option+1]; incr option; }
        "--filetype"        -
        "-t"                { set TYPE      [lindex $args $option+1]; incr option; }
        "--base_directory"  -
        "-d"                { set BASE_DIR  [lindex $args $option+1]; incr option; }
        "--include_subdir"  -
        "-s"                { set SUB_DIR   true }
          ""                {}
        default             { ::TE::UTILS::te_msg -type error -id TE_UTILS-52 -msg "Unrecognised argument: delete_files [lindex $args $option]."
                              ::TE::UTILS::te_msg -msg "Arguments: delete_files \[options\]"
                              ::TE::UTILS::te_msg -msg "  Expected Options:"
                              ::TE::UTILS::te_msg -msg "      --filename or -n         \"<name>\"             -> full name or with wildcards \"*\""
                              ::TE::UTILS::te_msg -msg "      --filetype or -t         \"f\"                  -> search for simple files"
                              ::TE::UTILS::te_msg -msg "                               \"d\"                  -> search for folder"
                              ::TE::UTILS::te_msg -msg "      --base_directory or -d \"<base directory>\"     -> start in this directory"
                              ::TE::UTILS::te_msg -msg "      --include_subdir or -s                        -> enable searching for files/folder also in subdirectories"
                              return
                            }
      }
    }
    # start search and delete files/folder
    set next_dir_list [list]
    
    while { [llength $BASE_DIR] ne 0 } { 
      foreach dir $BASE_DIR {
        set delfiles [list]
        # get all none hidden folder/files
        catch {
          foreach delfile [glob -types [subst {\{$TYPE\}}] -directory $dir $NAME] {
            file delete -force $delfile
            ::TE::UTILS::te_msg -msg "  -> $delfile deleted"
          }
        }
        # get all hidden folder/files
        catch {
          foreach delfile [glob -types [subst {\{$TYPE\}}] -types {hidden} -directory $dir $NAME] {
            file delete -force $delfile
            ::TE::UTILS::te_msg -msg "  -> $delfile deleted"
          }
        }
        # set subdir
        foreach nextdir [glob -nocomplain -types {d} -directory $dir *] {
          lappend next_dir_list $nextdir
        }
      }  
      set BASE_DIR $next_dir_list
      set next_dir_list [list]
      # end loop if search in subdir is disabled
      if {!$SUB_DIR} {break}
    }
  }
  
  #--------------------------------
  #-- post message + write to log file
  proc te_msg {{args ""}} {
    #ID: TE_MAIN, TE_DES, TE_EXP, TE_QUART, TE_SDK, TE_INIT, TE_BDEF, TE_UTILS, TE_TK
    #last ID number:
    #TE_MAIN  19    -> script_main.tcl
    #TE_DES   88    -> script_designs.tcl
    #TE_EXP   42    -> script_export.tcl
    #TE_QUART 44    -> script_quartus.tcl
    #TE_SDK   35    -> script_sdk.tcl
    #TE_INIT  31    -> script_settings.tcl
    #TE_BDEF  1     -> script_settings.tcl
    #TE_UTILS 52    -> script_utils.tcl  
    #TE_TK    52    -> script_tk.tcl
    #TE_DEV   43    -> script_dev_tk.tcl
    #TE_OS    16    -> script_os.tcl
    #TYPE: INFO, WARNING, CRITICAL_WARNING, ERROR, STD
    #Example: ::TE::UTILS::te_msg -type Info -id "TE_UTILS-1" -msg "te_msg example"
    
    set TYPE "NA"
    set ID "NA"
    set MESSAGE "NA"
    set SILENT false
    set num [llength $args]
    for {set option 0} {$option < $num} {incr option} {
      switch [lindex $args $option] {
        "-type"   { set TYPE    [lindex $args $option+1]; incr option; }  
        "-id"     { set ID      [lindex $args $option+1]; incr option; }
        "-msg"    { set MESSAGE [lindex $args $option+1]; incr option; }
        "-silent" { set SILENT  true }
        ""        {}
        default   { ::TE::UTILS::write_log_file "(::TE::UTILS::te_msg) unrecognised argument: te_msg [lindex $args $option]."
                    post_message -type Error "(::TE::UTILS::te_msg) unrecognised argument: te_msg [lindex $args $option]."
                    puts "Expected arguments: te_msg \[options\] \[-msg \"<message>\"\]"
                    puts "     Options:"
                    puts "          -id    \"<id>\""
                    puts "          -type  {Info || Warning || Critical_Warning || Error}"
                    return
                  }
      }
    }
    
    if {$TYPE ne "NA"} { # for better overview in log file
      switch -nocase $TYPE { 
        "info"              {set TYPE "Info";             incr ::TE::cntscriptinfo;             incr ::TE::cntprebinfo}
        "warning"           {set TYPE "Warning";          incr ::TE::cntscriptwarning;          incr ::TE::cntprebwarning}
        "critical_warning"  {set TYPE "Critical_Warning"; incr ::TE::cntscriptcriticalwarning;  incr ::TE::cntprebcriticalwarning}
        "error"             {set TYPE "Error";            incr ::TE::cntscripterror;            incr ::TE::cntpreberror}
        default             {post_message -type error "Invalid type $TYPE. Available types: Info || Warning || Critical_Warning || Error"; ::TE::UTILS::write_log_file "::TE::UTILS::te_msg invalid type $TYPE."}
      }
    }
    
    if {![string match -nocase "NA" $MESSAGE]} {  
      if {![string match -nocase "NA" $TYPE]} {
        if {![string match -nocase "NA" $ID]} {
          if {!$SILENT} { post_message -type $TYPE "\[$ID\] $MESSAGE" }
          ::TE::UTILS::write_log_file "$TYPE: \[$ID\] $MESSAGE"
        } else {
          if {!$SILENT} { post_message -type $TYPE "$MESSAGE" }
          ::TE::UTILS::write_log_file "$TYPE: $MESSAGE"
        }
      } else {
        if {![string match -nocase "NA" $ID]} {
          if {!$SILENT} { puts "\[$ID\] $MESSAGE" }
          ::TE::UTILS::write_log_file "\[$ID\] $MESSAGE"
        } else {
          if {!$SILENT} { puts "$MESSAGE" }
          ::TE::UTILS::write_log_file "$MESSAGE"
        }
      }
      
      # print message in tcl/tk gui
      if {[tsv::get ::TE::TK_MSG_EN ::TK] eq 1} {
        set MESSAGE [string map {\\ \\\\}     $MESSAGE]
        set MESSAGE [string map {"\$" "\\$"}  $MESSAGE]
        set MESSAGE [string map {"\[" "\\["}  $MESSAGE]
        set MESSAGE [string map {"\]" "\\]"}  $MESSAGE]
        set MESSAGE [string map {\" \\"}      $MESSAGE]
        
        if {![string match -nocase "NA" $ID]} { 
          thread::send -async $::TE::THREAD_TK_ID "::TE::show_msg_tk $TYPE \"\\\[$ID\\\] $MESSAGE\""
        } else {
          thread::send -async $::TE::THREAD_TK_ID "::TE::show_msg_tk $TYPE \"$MESSAGE\""
        }        
      }
    
    } else {
      ::TE::UTILS::write_log_file "::TE::UTILS::te_msg -id $ID -type $TYPE -msg $MESSAGE failed. No message available."
      post_message -type Error "::TE::UTILS::te_msg -id $ID -type $TYPE -msg $Message failed. No message available.\nExpected arguments: te_msg \[options\] \[-msg \"<message>\"\]\n                  \
                                    Options: \n                      \
                                      -id \"<id>\" \n                      \
                                      -type {Info || Warning || Critical_Warning || Error}\n"
    }
  }
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished additional functions 
  # -----------------------------------------------------------------------------------------------------------------------------------------
  
 }
  
  set ::TE::CURRENT_LOG_FILE "quartus_[clock format [clock seconds] -format %Y%m%d-%H%M%S].log"
  if {![file exist ${::TE::LOG_PATH}/${::TE::CURRENT_LOG_FILE}]} {
    set fp [open ${::TE::LOG_PATH}/${::TE::CURRENT_LOG_FILE} w]
  } else {
    set fp [open ${::TE::LOG_PATH}/${::TE::CURRENT_LOG_FILE} a]
  }
  puts $fp  " -----------------------------------------------------------------------------------------------------------\n\
              Quartus $::quartus(version)\n\
              Start of session at: [clock format [clock seconds] -format "%a %b %d %Y %T"]\n\
              Current directory: [pwd]\n\
              Log file: ${::TE::LOG_PATH}/${::TE::CURRENT_LOG_FILE}\n\
              -----------------------------------------------------------------------------------------------------------\n"
  close $fp
      
  ::TE::UTILS::te_msg -type info -msg "(TE) Load Utilities script finished"
}


