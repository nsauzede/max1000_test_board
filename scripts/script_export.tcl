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
# -- $Date: 2020/01/29 | $Author: Dück, Thomas
# -- - modified proc export_project_files
# ------------------------------------------
# -- $Date: 2019/10/25 | $Author: Dück, Thomas
# -- - initial release
# ------------------------------------------
# -- $Date: 2021/06/10 | $Author: Dück, Thomas
# -- - changed generate_prebuilt_files function 
# ------------------------------------------
# -- $Date: 2022/01/24 | $Author: Dück, Thomas
# -- - add function export_yocto_files
# -- - add os/yocto files to generate_prebuilt_files
# ------------------------------------------
# -- $Date: 2022/03/17 | $Author: Dück, Thomas
# -- - add write_zip_info function
# -- - add zip teinfo request to zip_project
# ------------------------------------------
# -- $Date: 2022/09/16 | $Author: Dück, Thomas
# -- - modifed function export_project_files
# ------------------------------------------
# -- $Date: 2022/12/06 | $Author: Dück, Thomas
# -- - modifed "Production" option in proc zip_project
# -- - created proc zip_general
# ------------------------------------------
# -- $Date: 2023/06/26 | $Author: Dück, Thomas
# -- - change structure of exported project files
# -- - remove component version from qsys tcl in proc generate_tcl_qsys
# ------------------------------------------
# -- $Date: 2024/02/05 | $Author: Dück, Thomas
# -- - add *.bin file to generate_prebuilt_files
# --------------------------------------------------------------------
# --------------------------------------------------------------------

namespace eval ::TE {
 namespace eval EXP {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # export functions
  # -----------------------------------------------------------------------------------------------------------------------------------------    
  #--------------------------------
  #-- create folder for source files
  proc create_source_folder {} {
    ::TE::UTILS::te_msg -type info -id TE_EXP-01 -msg "Create new project source folder. Please wait ..."  
    if {![file exists ${::TE::SOURCE_PATH}/quartus]} {
      file mkdir ${::TE::SOURCE_PATH}/quartus
    }
    if {![file exists ${::TE::SOURCE_PATH}/software]} {
      file mkdir ${::TE::SOURCE_PATH}/software
    }    
    ::TE::UTILS::te_msg -type info -id TE_EXP-02 -msg "Create new project source folder -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- copy quartus project files to source_files/quartus
  proc export_project_files {} {
    ::TE::UTILS::te_msg -type info -id TE_EXP-03 -msg "Copy quartus project files to source folder. Please wait ..."
    #search quartus design files
    set found_qsys_name 0
    set qdir [glob -tail -directory ${::TE::QPROJ_PATH}/ *.bdf *.sdc *.vhd *.v *.sv *.tcl *.cof *.ip *.sh]
    set subdir [glob -nocomplain -tail -directory ${::TE::QPROJ_PATH}/ ip ip/* hdl hdl/*]
    foreach dir $subdir {
      # search generated files from platform desginer
      foreach tmp_qsys_name ${::TE::QSYS_NAME} { if { [string match -nocase *${tmp_qsys_name}* $dir] } { set found_qsys_name 1 } }
      # create source directories and add source files to copy list
      if {($found_qsys_name ne 1 || ${::TE::QSYS_NAME} eq "") && ![string match -nocase "*/db" $dir] } {
        if { [file isdirectory  ${::TE::QPROJ_PATH}/${dir}] && ![file exists ${::TE::SOURCE_PATH}/quartus/${dir}] } {
          file mkdir ${::TE::QPROJ_SOURCE_PATH}/${dir}
          if {[string match -nocase "ip/*" ${dir}] && [glob -nocomplain -tail -directory ${::TE::QPROJ_PATH}/ ${dir}/*.ip] eq ""} {
            set tmpdir [glob -nocomplain -tail -directory ${::TE::QPROJ_PATH}/ ${dir}/*] ;#search source files from subdirectories
          } else {
            set tmpdir [glob -nocomplain -tail -directory ${::TE::QPROJ_PATH}/ ${dir}/*.ip ${dir}/*.v ${dir}/*.sv ${dir}/*.vhd ${dir}/*.tcl ${dir}/*.qprs] ;#search source files from subdirectories
          }

          foreach dir $tmpdir {  lappend qdir $dir }
        } elseif { [file exists ${::TE::SOURCE_PATH}/quartus/${dir}] } {
            ::TE::UTILS::te_msg -type Warning -msg "         ${dir} found in ${::TE::SOURCE_PATH}/quartus/"
        }
      }
      set found_qsys_name 0
    }
    #copy quartus design files
    foreach filedir $qdir {
      if { ![file exists ${::TE::SOURCE_PATH}/quartus/${filedir}] } {
        file copy -force ${::TE::QPROJ_PATH}/$filedir ${::TE::QPROJ_SOURCE_PATH}/$filedir
        ::TE::UTILS::te_msg -type info -msg "            ${::TE::QPROJ_PATH}/$filedir -> ${::TE::QPROJ_SOURCE_PATH}/$filedir"
      } else {
        ::TE::UTILS::te_msg -type Warning -msg "         ${filedir} found in ${::TE::SOURCE_PATH}/quartus/"
      }
    }
    ::TE::UTILS::te_msg -type info -id TE_EXP-04 -msg "Copy quartus project files to source folder -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
    
  #--------------------------------
  #-- copy software files to source_files/software
  proc export_software_files {project} {
    ::TE::UTILS::te_msg -type info -id TE_EXP-05 -msg "Copy software files for '$project' to source folder. Please wait ..."
    file mkdir ${::TE::SDK_SOURCE_PATH}/${project}
    set sdkdir [glob -tail -nocomplain -directory ${::TE::SDK_PATH}/${project}/ *.c *.h *.xml]
    set sdkbspdir [glob -tail -nocomplain -directory ${::TE::SDK_PATH}/${project}_bsp/ *_bsp.tcl]
    foreach filedir $sdkdir { 
      if {[catch {file copy -force ${::TE::SDK_PATH}/${project}/$filedir ${::TE::SDK_SOURCE_PATH}/${project}/$filedir} result]} {
        ::TE::UTILS::te_msg -type error -id TE_EXP-14 -msg "Error on copying $filedir: $result"
      } else {
        ::TE::UTILS::te_msg -type info -id TE_EXP-06 -msg " - $filedir copied."
      }
    }
    if {$sdkbspdir ne ""} {
      file copy -force ${::TE::SDK_PATH}/${project}_bsp/$sdkbspdir ${::TE::SDK_SOURCE_PATH}/${project}/$sdkbspdir
    }
    ::TE::UTILS::te_msg -type info -id TE_EXP-07 -msg "Copy software files '$project' to source folder -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- copy yocto files to source_files/os
  proc export_yocto_files {} {
    ::TE::UTILS::te_msg -type info -id TE_EXP-36 -msg "Copy os files for 'yocto/${::TE::YOCTO_BSP_LAYER_NAME}' to source folder. Please wait ..."
    file mkdir ${::TE::YOCTO_SOURCE_PATH}
    if {[catch {file copy -force ${::TE::YOCTO_PATH}/${::TE::YOCTO_BSP_LAYER_NAME} ${::TE::YOCTO_SOURCE_PATH}/${::TE::YOCTO_BSP_LAYER_NAME}} result]} {
      ::TE::UTILS::te_msg -type error -id TE_EXP-37 -msg "Error on copying ${::TE::YOCTO_PATH}/${::TE::YOCTO_BSP_LAYER_NAME}: $result"
    } else {
      ::TE::UTILS::te_msg -type info -id TE_EXP-38 -msg " - ${::TE::YOCTO_PATH}/${::TE::YOCTO_BSP_LAYER_NAME} copied."
      set del_files [glob -tail -nocomplain -directory ${::TE::YOCTO_SOURCE_PATH}/${::TE::YOCTO_BSP_LAYER_NAME}/ recipes-bsp/u-boot/files/qts/* recipes-bsp/rbf/files/*]
      ::TE::UTILS::te_msg -type info -id TE_EXP-39 -msg "Deleted files:"
      foreach file ${del_files} {
        ::TE::UTILS::te_msg -type info -msg "     ${file}"
        file delete -force ${::TE::YOCTO_SOURCE_PATH}/${::TE::YOCTO_BSP_LAYER_NAME}/${file}
      }
    }
      
    ::TE::UTILS::te_msg -type info -id TE_EXP-40 -msg "Copy os files 'yocto/${::TE::YOCTO_BSP_LAYER_NAME}' to source folder -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- generate <project>.tcl
  proc generate_tcl_proj {} {
    ::TE::UTILS::te_msg -type info -id TE_EXP-08 -msg "Generate ${::TE::QPROJ_NAME}.tcl file. Please wait ..."
    ::quartus::pjc_tcl_project_open ${::TE::QPROJ_PATH}/${::TE::QPROJ_NAME}
    set command ::quartus::pjc_tcl_project_generate_tcl_file      
    lappend command ${::TE::QPROJ_PATH}/${::TE::QPROJ_NAME}
    lappend command overwrite  
    if {[catch {eval $command} result]} {
      ::TE::UTILS::te_msg -type error -id TE_EXP-09 -msg "Results on command: $command:\n$result"
    }
    ::quartus::pjc_tcl_project_close
    if {[file tail [pwd]]=="quartus"} {
      cd ../
    }
    ::TE::UTILS::te_msg -type info -id TE_EXP-10 -msg "Generate ${::TE::QPROJ_NAME}.tcl file -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }  
  
  #--------------------------------
  #-- generate <qsys>.tcl
  proc generate_tcl_qsys {} {
    foreach qsysname ${::TE::QSYS_NAME} {
      ::TE::UTILS::te_msg -type info -id TE_EXP-11 -msg "Generate $qsysname.tcl file. Please wait ..."
      set command exec
      lappend command ${::TE::QROOTPATH}sopc_builder/bin/qsys-generate${::TE::WIN_EXE}
      lappend command ${::TE::QPROJ_PATH}/${qsysname}.qsys
      lappend command --export-qsys-script
      if {${::TE::QEDITION} == "Pro"} {      
        lappend command --quartus-project=${::TE::QPROJ_PATH}/${::TE::QPROJ_NAME}
      }
      [catch {eval $command} result]    
      ::TE::UTILS::report -msg $result -command $command -msgid TE_EXP-12  
      ::TE::UTILS::te_msg -type info -id TE_EXP-13 -msg "Generate $qsysname.tcl file -> done"
    }
    set subsystem_tcl [list]
    foreach qsysname ${::TE::QSYS_NAME} {
      set fpr [open "${::TE::QPROJ_PATH}/${qsysname}.tcl" r]
      set file_data [read $fpr]
      close $fpr
      set file_data [split $file_data "\n"]
       
      set fpw [open "${::TE::QPROJ_PATH}/${qsysname}.tcl" w]
      foreach line $file_data {
        if {[string match "*set_module_property NAME *" $line] && ${::TE::QEDITION} == "Pro"} {
          foreach qsys_subsystem ${::TE::QSYS_NAME} {
            if {[string match "*$qsys_subsystem*" $line] && $qsysname ne $qsys_subsystem} {
              lappend subsystem_tcl ${qsys_subsystem}
            }
          }
        }
         
        if {[string match "add_instance *" $line] || [string match "*add_component *" $line]} {
          regsub { (\d+).(\d+)(.*)} $line {} line
        }
         
        puts $fpw $line
      }
      close $fpw
       
    }
    foreach delete_file $subsystem_tcl {
      file delete ${::TE::QPROJ_PATH}/${delete_file}.tcl
    }

    ::TE::UTILS::te_msg -msg "------------------------------"
  }    
    
  #--------------------------------
  #-- generate prebuilt files (*.pof, *.jic)
  proc generate_prebuilt_files {id} {
    ::TE::UTILS::te_msg -type info -id TE_EXP-18 -msg "Generate prebuilt files - ID: $id. Please wait ..."    
    set tmp_folder [clock format [clock seconds] -format %Y%m%d%H%M%S]
    set ::TE::QPROJ_PATH ${::TE::BASEFOLDER}/$tmp_folder/quartus
    set ::TE::SDK_PATH ${::TE::BASEFOLDER}/$tmp_folder/software
    set ::TE::OS_PATH ${::TE::BASEFOLDER}/$tmp_folder/os
    set ::TE::YOCTO_PATH ${::TE::BASEFOLDER}/$tmp_folder/os/yocto
    set ::TE::sdksrcback "../../.."
    
    set prebstarttime [clock seconds]
    set ::TE::cntprebinfo 0
    set ::TE::cntprebwarning 0
    set ::TE::cntprebcriticalwarning 0
    set ::TE::cntpreberror 0    
      
    file mkdir $tmp_folder
    cd $tmp_folder
            
    # if {[catch {eval ::TE::INIT::init_board $id} result]}   {::TE::UTILS::te_msg -type error -id TE_EXP-22 -msg "$result"}

    #create and compile project and software
    if {[catch {eval ::TE::DES::run_build_project} result]}   {::TE::UTILS::te_msg -type error -id TE_EXP-23 -msg "Error on ::TE::DES::run_build_project:\n$result"}

    #create prebuilt subfolders if not exist
    if {![file exist ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/programming_files]} {
      file mkdir ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/programming_files
    }
    if {![file exist ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/hardware] && ${::TE::QSYS_SRC_NAME} ne ""} {
      file mkdir ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/hardware
    }
    if {![file exist ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/software] && ${::TE::SDK_SRC_NAME} ne "no_project" } {
      file mkdir ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/software
    }
    if {![file exist ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/os] && ${::TE::YOCTO_SRC_BSP_LAYER_NAME} ne "NA" } {
      file mkdir ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/os
    }

    #copy generated prebuilt files to prebuilt subfolders
    set prebfile_list [glob -nocomplain -directory ${::TE::QPROJ_PATH}/output_files/ *.sof *.pof *.jic *.rbf]
    if {[string match -nocase *.jic* $prebfile_list]} {
      set copylist [glob -nocomplain -directory ${::TE::QPROJ_PATH}/output_files/ *.sof *.jic]
    } elseif {[string match -nocase *.rbf* $prebfile_list]} {
      set copylist [glob -nocomplain -directory ${::TE::QPROJ_PATH}/output_files/ *.sof *.rbf]
     } elseif {[string match -nocase *.pof* $prebfile_list]} {
      set copylist [glob -nocomplain -directory ${::TE::QPROJ_PATH}/output_files/ *.pof]
     } else {
      set copylist [glob -nocomplain -directory ${::TE::QPROJ_PATH}/output_files/ *.sof]
    }
      
    foreach preb_source $copylist {
      regexp {(\w+)\.(\w+)} [file tail $preb_source] matched name type
      set new_name ${name}-${::TE::SHORTNAME}.${type}
      if {![file exist ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/${new_name}]} {  
        if {[catch {file copy -force [glob  ${::TE::QPROJ_PATH}/output_files/${matched}] ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/programming_files} result]} {::TE::UTILS::te_msg -type error -id TE_EXP-24 -msg "$result"}
        if {[catch {file rename ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/programming_files/${matched} ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/programming_files/${new_name}} result]} {::TE::UTILS::te_msg -type error -id TE_EXP-25 -msg "$result"}
      } else {post_message -type warning "File ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/programming_files/${new_name} already exist."}
    }
    #copy quartus project files to prebuilt folder
    if {${::TE::QEDITION} eq "Pro"} { set sopcdir "${::TE::BASEFOLDER}/$tmp_folder/quartus/${::TE::QSYS_SOPC_FILE_NAME}" } else { set sopcdir "${::TE::BASEFOLDER}/$tmp_folder/quartus" }
    if { ${::TE::QSYS_SRC_NAME} ne "" } {
      if {[catch {file copy -force [glob -directory  $sopcdir *.sopcinfo] ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/hardware} result]} {::TE::UTILS::te_msg -type error -id TE_EXP-26 -msg "$result"}
    }
    #copy software project files to prebuilt folder
    if { ${::TE::SDK_SRC_NAME} ne "no_project" } {
      foreach tmp_sw_file [glob -directory  ${::TE::SDK_PATH} /**/*.elf /**/**/*.elf /**/*.bin] {
        if {[catch {file copy -force ${tmp_sw_file} ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/software} result]} {::TE::UTILS::te_msg -type error -id TE_EXP-27 -msg "$result"}
      }
    }
    #copy os project files to prebuilt folder
    if { [file exist ${::TE::OS_PATH}] } {
      #copy yocto files
      if {[catch {file copy -force ${::TE::YOCTO_PATH} ${::TE::PREBUILT_PATH}/${::TE::SHORTNAME}/os } result]} {::TE::UTILS::te_msg -type error -id TE_EXP-35 -msg "$result"}
    }
      
    set prebstoptime [clock seconds]
    set ::TE::prebtime [expr ${prebstoptime} -${prebstarttime}] 
    if {[catch {eval ::TE::UTILS::report_prebuilt_hw_summary} result]}   {::TE::UTILS::te_msg -type error -id TE_EXP-28 -msg "Error on ::TE::UTILS::report_prebuilt_hw_summary:\n$result"}

    cd ${::TE::BASEFOLDER}
    file delete -force $tmp_folder      
    
    set ::TE::QPROJ_PATH ${::TE::BASEFOLDER}/quartus
    set ::TE::SDK_PATH ${::TE::BASEFOLDER}/software
    set ::TE::OS_PATH ${::TE::BASEFOLDER}/os
    set ::TE::YOCTO_PATH ${::TE::BASEFOLDER}/os/yocto
    set ::TE::sdksrcback "../.."

    ::TE::UTILS::te_msg -type info -id TE_EXP-29 -msg "Export prebuilt files - ID: $id -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- zip_project: 
  proc zip_project { EXCLUDELIST ZIPNAME {release "NA"} {initials "NA"} {dest "NA"} {ttyp "NA"} {btyp "NA"} {pext "NA"}} {

    if {$dest eq "NA"} {
      set someVar "NA"
      puts "---------------------------------------------"
      puts "--Additional Information for ZIP are required"
      puts "---------------------------------------------"
      puts "Insered Initials(optional):"
      while {1} {
        gets stdin someVar
        if {![string match -nocase "" $someVar ]} {
          set initials $someVar
          break
        } 
      }
      
      puts "Insered destination:"
      puts "- 0 for PublicDoc"
      puts "- 1 for Production"
      puts "- 2 for Development"
      puts "- 3 for Preliminary"

      while {1} {
        set someVar "NA"
        gets stdin someVar
        if {[string match -nocase "0" $someVar ]} {
          set dest "PublicDoc"
          break
        } elseif {[string match -nocase "1" $someVar ]} {
          set dest "Production"
          set someVar "NA"
          while {1} {
            puts "Insered destination:"
            puts "- 0 for Manual Test"
            puts "- 1 for Halfautomatic Test"
            puts "- 2 for Automatic Test System"
            puts "- 3 for Others"
            gets stdin someVar
            if {[string match -nocase "0" $someVar ]} {
              set ttyp "MT"
              break
            } elseif {[string match -nocase "1" $someVar ]} {
              set ttyp "HT"
              break
            } elseif {[string match -nocase "2" $someVar ]} {
              set ttyp "ATS"
              break
            } elseif {[string match -nocase "3" $someVar ]} {
              set ttyp "NA"
              break
            }
          }
          set someVar "NA"
          while {1} {
            puts "Insered Board Type(Test Reason):"
            puts "- 0 for Module Test Export"
            puts "- 1 for Carrier Test Export"
            puts "- 2 for Motherboard Test Export"
            puts "- 3 for FMC-Card Test Export"
            puts "- 4 for PCIe-Card Test Export"
            puts "- 5 for Others"
            gets stdin someVar
            if {[string match -nocase "0" $someVar ]} {
              set btyp "Module"
              break
            } elseif {[string match -nocase "1" $someVar ]} {
              set btyp "Carrier"
              break
            } elseif {[string match -nocase "2" $someVar ]} {
              set btyp "Motherboard"
              break
            } elseif {[string match -nocase "3" $someVar ]} {
              set btyp "FMC-Card"
              break
            } elseif {[string match -nocase "4" $someVar ]} {
              set btyp "PCIe-Card"
              break
            } elseif {[string match -nocase "5" $someVar ]} {
              set btyp "NA"
              break
            }
          }
          set someVar "NA"
          while {1} {
              puts "Include init.sh extention:"
              puts "- 0 with extentions"
              puts "- 1 without extentions"
              gets stdin someVar
            if {[string match -nocase "0" $someVar ]} {
              set pext "yes"
              break
            } elseif {[string match -nocase "1" $someVar ]} {
              set pext "NA"
              break
            }
          }
          break
        } elseif {[string match -nocase "2" $someVar ]} {
          set dest "Development"
          break
        } elseif {[string match -nocase "3" $someVar ]} {
          set dest "Preliminary"
          break
        }
      }
    }
    
    ::TE::UTILS::te_msg -type info -id TE_EXP-30 -msg "Zip Project. Please wait ..."  
    
    # source path
    set sourcepath [string trim ${::TE::QPROJ_PATH} "quartus"]
    set destinationpath ${::TE::BACKUP_PATH}/${::TE::QPROJ_SRC_NAME}
    set zipteinfo_path "${destinationpath}/settings"
    
    #remove old backup project copy
    if {[file exists ${destinationpath}]} { 
      file delete -force ${destinationpath}  
    }
    #create new destination folder
    file mkdir ${destinationpath}
    
    #get all files
    set filelist [ glob ${sourcepath}*]
    #remove backup folder
    set findex [lsearch $filelist *backup]
    set filelist [lreplace $filelist[set filelist {}] $findex $findex]
    #remove console folder if dest==PublicDoc/Preliminary
    if {[string match "PublicDoc" ${dest}] || [string match "Preliminary" ${dest}]} { 
      set findex [lsearch $filelist *console]
      set filelist [lreplace $filelist[set filelist {}] $findex $findex] 
    }
      
    foreach el $filelist {
      file copy -force ${el} ${destinationpath}
    }

    foreach el $EXCLUDELIST {
      set find ""
      if {[catch {set find [glob -join -dir $destinationpath $el]}] && [catch {set find [glob -type hidden -join -dir $destinationpath $el]}]} {
        ::TE::UTILS::te_msg -type info -id TE_EXP-31 -msg "$el doesn't exist."
      } else {
        ::TE::UTILS::te_msg -type info -id TE_EXP-32 -msg "Excluded from backup: $find"
        file delete -force $find
      }
    }
    # remove .svn folder from reference design backup
    ::TE::UTILS::delete_files -n ".svn" -t "d" -d $destinationpath -s
    
    # modify design_basic_settings.tcl for production
    if {[string match "Production" ${dest}]} {
      set fp_r [open "${destinationpath}/settings/design_basic_settings.tcl" r]
      set file_data [read $fp_r]
      close $fp_r
      set data [split $file_data "\n"]
      set fp_w [open "${destinationpath}/settings/design_basic_settings.tcl" w]
      foreach line $data {
        if { [string match "QUARTUS_PATH_WIN=*" $line] }   { set line "QUARTUS_PATH_WIN=C:/intelFPGA_pro" }
        if { [string match "QUARTUS_PATH_LINUX=*" $line] } { set line "QUARTUS_PATH_LINUX=~/intelFPGA_pro" }
        if { [string match "QUARTUS_VERSION=*" $line] }    { set line "QUARTUS_VERSION=21.1" }
        if { [string match "QUARTUS_EDITION=*" $line] }    { set line "QUARTUS_EDITION=Pro" }
        if { [string match "QUARTUS_PROG=*" $line] }       { set line "QUARTUS_PROG=1" }
        puts $fp_w "$line"
      }
      close $fp_w
    }
    #add _dev for dest==Development and _prelim for dest==Preliminary
    if {[string match "Development" ${dest}]} {
      set ZIPNAME "$ZIPNAME_dev"
    } elseif {[string match "Preliminary" ${dest}]} {
      set ZIPNAME "$ZIPNAME_prelim"
    }
    # write zipinfo and zip project
    ::TE::EXP::write_zip_info $zipteinfo_path $ZIPNAME $release $initials $dest $ttyp $btyp "NA"
    ::TE::EXP::zip_general ${destinationpath} ${ZIPNAME}

    # in case with production extentions:
    if {[string match "yes" ${pext}]} {
      #remove project copy
      if {[file exists ${destinationpath}]} { 
        file delete -force ${destinationpath}  
      }
      set destinationpath "${TE::BACKUP_PATH}/Produktionstest"
      if {[file exists ${destinationpath}]} { 
        file delete -force ${destinationpath}  
      }
      file mkdir ${destinationpath}
      file copy -force ${TE::BACKUP_PATH}/${ZIPNAME}.zip ${destinationpath}
      file delete -force ${TE::BACKUP_PATH}/${ZIPNAME}.zip 
      file copy -force "${TE::BASEFOLDER}/../prod_cfg_list.csv" ${destinationpath}
      file copy -force "${TE::BASEFOLDER}/../cfg_init" ${destinationpath}
      # remove .svn folder from production test zip
      ::TE::UTILS::delete_files -n ".svn" -t "d" -d ${destinationpath} -s
        
      set ZIPNAME "${ZIPNAME}_extended"
      zip_general "${::TE::BACKUP_PATH}/Produktionstest/" $ZIPNAME
    }

    #remove project copy
    if {[file exists ${destinationpath}]} { 
      file delete -force ${destinationpath}
    }

    ::TE::UTILS::te_msg -type info -id TE_EXP-34 -msg "Zip Project -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- zip_general: zip project
  proc zip_general { ZIPPATH ZIPNAME } {
    set command exec
    if {[file exists $::quartus(binpath)7z${::TE::WIN_EXE}]} {
      puts "7z: $ZIPPATH"
      lappend command 7z${::TE::WIN_EXE}
      lappend command a
      lappend command -tzip 
      lappend command -o${::TE::BACKUP_PATH}
      #lappend command -r  
      lappend command "${ZIPNAME}.zip"
      lappend command ${ZIPPATH}  
    } else {
      lappend command zip${::TE::WIN_EXE}
      #lappend command -r
      lappend command ${ZIPNAME}.zip
      lappend command ${ZIPPATH}
    }

    cd ${::TE::BACKUP_PATH}
    catch {eval $command} result
    ::TE::UTILS::te_msg -type info -id TE_EXP-33 -msg "Result of command $command:\n$result" 
    cd ${::TE::BASEFOLDER}  
  }
  
  #--------------------------------
  #-- write_zip_info: 
  proc write_zip_info {{path "NA"} {zipname "NA"} {release "NA"} {initials "NA"} {dest "NA"} {ttyp "NA"} {btyp "NA"} {revision "NA"}} { 
    ::TE::UTILS::te_msg -type info -id TE_EXP-41 -msg "Write zip teinfo file"
      
    #Destination: Production, PublicDoc, Development, Preliminary
    #ExporterInitials: 
    #typ: Prod: MT,HT,ATS, others "NA"
    #BoardTyp: Module, Carrier, Motherboard, FMC-Card, PCIe-Card, Others
    #ProjectName: project base folder name
    #ProjectToolName: "Vivado-xxxx.y"
    #ReleaseDate: Date
    #Revision: NA (Futures usage)
    if {![string match "NA" $path ]} {
      set infofile ${path}/zip.teinfo
      set fp_w [open ${infofile} "w"] 
      puts $fp_w "#-----------------------------------------------#"
      puts $fp_w "#--Automatically generated file. Do not modify--#"
      puts $fp_w "#-----------------------------------------------#"
      puts $fp_w "ZIPINFO_CSV=        ${TE::ZIPINFO_CSV}"
      puts $fp_w "ExporterInitials=   $initials"
      puts $fp_w "ZIPName=            $zipname"
      puts $fp_w "Destination=        $dest"
      puts $fp_w "Typ=                $ttyp"
      puts $fp_w "BoardTyp=           $btyp"
      puts $fp_w "ProjectName=        ${TE::QPROJ_SRC_NAME}"
      puts $fp_w "ProjectToolName=    Quartus_${::TE::QEDITION}-${::TE::QVERSION}"
      puts $fp_w "ReleaseDate=        $release"
      puts $fp_w "Revision=           --"
      close $fp_w
    } else {
      #to nothing...
    }

    ::TE::UTILS::te_msg -type info -id TE_EXP-42 -msg "Write zip teinfo file -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #-----------------------------------------------------------------------------------------------------------------------------------------
  # finished export functions
  # -----------------------------------------------------------------------------------------------------------------------------------------  
 }
  ::TE::UTILS::te_msg -type info -msg "(TE) Load export script finished"
}


