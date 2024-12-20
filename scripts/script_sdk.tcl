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
# -- $Date: 2019/10/25  | $Author: Thomas Dück
# -- - initial release
# ------------------------------------------
# -- $Date: 2020/02/12  | $Author: Thomas Dück
# -- - using *.xml template for generating software project
# ------------------------------------------
# -- $Date: 2020/03/24  | $Author: Thomas Dück
# -- - add download_elf function
# ------------------------------------------
# -- $Date: 2020/06/22  | $Author: Thomas Dück
# -- - add modify_sdk_files function
# -- - modified download_elf function
# ------------------------------------------
# -- $Date: 2021/06/10  | $Author: Thomas Dück
# -- - removed modify_sdk_files function
# -- - bugfixes
# ------------------------------------------
# -- $Date: 2023/09/08  | $Author: Thomas Dück
# -- - add niosv support
# -- - add function get_cpu_parameter
# ------------------------------------------
# -- $Date: 2024/02/05 | $Author: Dück, Thomas
# -- - add option to generate bin file to generate_hex_file
# -- - add new function proc write_flash_memory
# --------------------------------------------------------------------
# --------------------------------------------------------------------
namespace eval ::TE {
  variable sdksrcback "../.." ;# needed to change source file path in create-this-app file
 namespace eval SDK {
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # sdk functions
  # -----------------------------------------------------------------------------------------------------------------------------------------    
  #--------------------------------
  #-- create software files
  proc create_software_files {} {
    ::TE::UTILS::te_msg -type Info -id TE_SDK-01 -msg "Create software files. Please wait ...\n"
    if { ${::TE::QSYS_CPU_VARIANT} eq "altera_nios2_gen2" } {
      set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
      lappend command nios2-swexample-create${::TE::WIN_EXE}
      if {${::TE::QEDITION} == "Pro"} {
        lappend command --sopc-file=../quartus/${::TE::QSYS_SOPC_FILE_NAME}/${::TE::QSYS_SOPC_FILE_NAME}.sopcinfo
      } else {
        lappend command --sopc-file=../quartus/${::TE::QSYS_SOPC_FILE_NAME}.sopcinfo
      }
      lappend command --type=${::TE::SDK_SRC_NAME}
      lappend command --cpu-name=${::TE::QSYS_CPU_NAME}
      lappend command --elf-name=${::TE::SDK_SRC_NAME}.elf
      lappend command --app-dir=./${::TE::SDK_SRC_NAME}
      lappend command --bsp-dir=./${::TE::SDK_SRC_NAME}_bsp
      lappend command --search=${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}
      # run command
      if {[catch {eval $command} result]} {
        ::TE::UTILS::te_msg -type error -id TE_SDK-02 -msg "Error on command: $command" 
        ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-03
      }
    } else {
      set appfiles [glob -directory ${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}/ *.c *.h]
      set bspfiles [glob -directory ${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}/ *.tcl]
      
      if { [catch {
        # create app folder
        set command "file mkdir ${::TE::SDK_PATH}/${::TE::SDK_SRC_NAME}"
        eval $command
        # copy app files
        foreach file $appfiles {
          set command "file copy -force $appfiles ${::TE::SDK_PATH}/${::TE::SDK_SRC_NAME}/"
          eval $command
        }
        # create bsp folder
        set command "file mkdir ./${::TE::SDK_SRC_NAME}_bsp"
        eval $command
        # copy bsp files
        foreach file $bspfiles {
          set command "file copy -force $bspfiles ./${::TE::SDK_SRC_NAME}_bsp/"
          eval $command
        }
      } result] } {
          ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-23
      }
    }
    ::TE::UTILS::te_msg -type Info -id TE_SDK-04 -msg "Create software files -> done"
    ::TE::UTILS::te_msg -msg  "------------------------------"
  }

  #--------------------------------
  #-- create bsp  
  proc create_bsp {} {
    ::TE::UTILS::te_msg -type Info -id TE_SDK-05 -msg "Create bsp. Please wait ..."
    if { ${::TE::QSYS_CPU_VARIANT} eq "altera_nios2_gen2" } {
      # remove carriage return (\r) from file
      set fp_r [open create-this-bsp "r"] 
      set file_data [read $fp_r]
      close $fp_r
      set fp_w [open create-this-bsp "w"]
      fconfigure $fp_w -translation lf
      regsub {BSP_DIR=.} $file_data "BSP_DIR=${::TE::SDK_PATH}/${::TE::SDK_SRC_NAME}_bsp/" file_data
      puts $fp_w "$file_data"
      close $fp_w
      # create bsp nios2
      set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
      lappend command ./create-this-bsp --no-make
    } else {
      set type [ lindex [ split [glob -tail -directory ./ *_bsp.tcl] "_" ] 0 ]
      # create bsp niosv
      set command niosv-bsp
      lappend command --create
      lappend command --type=$type
      if {${::TE::QEDITION} == "Pro"} {
        lappend command --quartus-project=${::TE::QPROJ_PATH}/${::TE::QPROJ_SRC_NAME}.qpf
        lappend command --qsys=${::TE::QPROJ_PATH}/${::TE::QSYS_SOPC_FILE_NAME}.qsys
      } else {
        lappend command --sopcinfo=${::TE::QPROJ_PATH}/${::TE::QSYS_SOPC_FILE_NAME}.sopcinfo
      }
      lappend command --script=./${type}_bsp.tcl
      lappend command ./settings.bsp
    }
    # run command
    set command "exec ${::TE::NIOSV_BIN_PATH}/niosv-shell --wait --run \"$command\""
    [catch {eval $command} result]
    ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-06
    ::TE::UTILS::te_msg -type Info -id TE_SDK-07 -msg "Create bsp -> done"
    ::TE::UTILS::te_msg -msg  "------------------------------"
  }

  #--------------------------------
  #-- create app  
  proc create_app {} {
    ::TE::UTILS::te_msg -type Info -id TE_SDK-08 -msg "Create app. Please wait ..."
    if { ${::TE::QSYS_CPU_VARIANT} eq "altera_nios2_gen2" } {
      #remove carriage return (\r) from file
      set fp_r [open create-this-app "r"] 
      set file_data [read $fp_r]
      close $fp_r
      set fp_w [open create-this-app "w"]
      fconfigure $fp_w -translation lf
      regexp {source_files(.*)} ${::TE::SDK_SOURCE_PATH} sdksrcpath
      regsub -all {\${SOPC_KIT_NIOS2}/examples/software/(\w+)/} $file_data "${::TE::sdksrcback}/$sdksrcpath/${::TE::SDK_SRC_NAME}/" file_data
      puts $fp_w "$file_data"
      close $fp_w
      file copy ${::TE::SDK_SOURCE_PATH}/${::TE::SDK_SRC_NAME}/template.xml ./
      # create app nios2
      set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
      lappend command ./create-this-app --no-make
    } else {
      # create app niosv
      set appfileslist [glob -tail -directory ${::TE::SDK_PATH}/${::TE::SDK_SRC_NAME}/ *.c *.h]
      set appfilecs ""
      foreach file $appfileslist {
        if { $appfilecs eq "" } {
          set appfilecs "./${file}"
        } else {
          set appfilecs "${appfilecs},./${file}"
        }
      }
      set command "exec ${::TE::NIOSV_BIN_PATH}/niosv-app"
      lappend command --app-dir=./
      lappend command --bsp-dir=../${::TE::SDK_SRC_NAME}_bsp
      lappend command --incs=./
      lappend command --srcs=$appfilecs
      lappend command --elf-name=${::TE::SDK_SRC_NAME}.elf
    }
    # run command
    [catch {eval $command} result]
    ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-09
    
    ::TE::UTILS::te_msg -type Info -id TE_SDK-10 -msg "Create app -> done"
    ::TE::UTILS::te_msg -msg  "------------------------------"
  }
  
  #--------------------------------
  #-- build software project
  proc app_make {} {
    ::TE::UTILS::te_msg -type Info -id TE_SDK-11 -msg "Make all - software. Please wait ..."
    if { ${::TE::QSYS_CPU_VARIANT} eq "altera_nios2_gen2" } {
      # make nios2
      set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
      lappend command make
      if {[catch {eval $command} result]} {
        ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-12
      }
    } else {
      # make niosv
      # cmake
      set command "exec ${::TE::NIOSV_BIN_PATH}/niosv-shell --wait --run \"cmake -S ./ -B ./build -G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=Release \""
      [catch {eval $command} result]
      ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-24
      # make
      set command "exec ${::TE::NIOSV_BIN_PATH}/niosv-shell --run \" make -C ./build \""
      [catch {eval $command} result]
      ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-28
    }
    ::TE::UTILS::te_msg -type Info -id TE_SDK-13 -msg "Make all - software -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }  
  
  #--------------------------------
  #-- generate bsp
  proc generate_bsp {} {
    ::TE::UTILS::te_msg -type Info -id TE_SDK-25 -msg "Generate BSP. Please wait ..."
    if { ${::TE::QSYS_CPU_VARIANT} eq "altera_nios2_gen2" } {
      # generate bsp nios2
      set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
      lappend command nios2-bsp-generate-files${::TE::WIN_EXE}
      lappend command --settings=settings.bsp
      lappend command --bsp-dir=./
    } else {
      # generate bsp niosv
      set command "exec ${::TE::NIOSV_BIN_PATH}/niosv-app"
      lappend command niosv-bsp
      lappend command --generate
      lappend command --bsp-dir=./${::TE::SDK_SRC_NAME}_bsp
      lappend command ./${::TE::SDK_SRC_NAME}_bsp/settings.bsp
    }
    # run command
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-26
    }
    
    ::TE::UTILS::te_msg -type Info -id TE_SDK-27 -msg "Generate BSP -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }  
  
  #--------------------------------
  #-- generate *.hex from *.elf
  proc generate_hex_file {} {
    set generate_bin_file 0
    set tmp_text "hex"
    if {[file exists "${::TE::BASEFOLDER}/misc/d2xx_spi_flash_programmer"] && ${::TE::FLASHTYP} ne "NA"} { set generate_bin_file 1; set tmp_text "bin" }
    ::TE::UTILS::te_msg -type Info -id TE_SDK-14 -msg "Generate $tmp_text file. Please wait ..."
    # generate hex file for nios2
    if { ${::TE::QSYS_CPU_VARIANT} eq "altera_nios2_gen2" } {
      set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
      lappend command elf2flash${::TE::WIN_EXE}
      lappend command --input ${::TE::SDK_SRC_NAME}.elf 
      lappend command --output ${::TE::SDK_SRC_NAME}.srec
      lappend command --reset ${::TE::QSYS_CPU_RESETADDR}
      lappend command --base ${::TE::QSYS_CPU_RESETSLAVE_BASEADDR}
      lappend command --end ${::TE::QSYS_CPU_RESETSLAVE_ENDADDR}
      lappend command  --boot ${::TE::QROOTPATH}../nios2eds/components/altera_nios2/boot_loader_cfi.srec
      if {[catch {eval $command} result]} {::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-15}
      
      if {$generate_bin_file eq 1} {
        set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
        lappend command nios2-elf-objcopy${::TE::WIN_EXE}
        lappend command --input-target srec
        lappend command --output-target binary
        lappend command ${::TE::SDK_SRC_NAME}.srec
        lappend command ${::TE::SDK_SRC_NAME}.bin
      } else {
        set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
        lappend command nios2-elf-objcopy${::TE::WIN_EXE}
        lappend command --input-target srec
        lappend command --output-target ihex
        lappend command ${::TE::SDK_SRC_NAME}.srec
        lappend command ${::TE::SDK_SRC_NAME}.hex
      }
      if {[catch {eval $command} result]} {::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-16}
    } else {
    # generate hex file for niosv
      set command "exec ${::TE::NIOSV_BIN_PATH}/elf2flash"
      lappend command --input ./build/${::TE::SDK_SRC_NAME}.elf  
      lappend command --output ./build/${::TE::SDK_SRC_NAME}.srec
      lappend command  --reset ${::TE::QSYS_CPU_RESETADDR}
      lappend command --base ${::TE::QSYS_CPU_RESETSLAVE_BASEADDR}
      lappend command --end ${::TE::QSYS_CPU_RESETSLAVE_ENDADDR}
      
      set bootloader "${::TE::QROOTPATH}../niosv/components/bootloader/[string map {"intel_" ""} ${::TE::QSYS_CPU_VARIANT}]_bootloader.srec"
      if { [file exists $bootloader] } {
        lappend command --boot $bootloader
      } else {
        lappend command --boot ${::TE::QROOTPATH}../niosv/components/bootloader/niosv_bootloader.srec
      }
      if {[catch {eval $command} result]} {::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-17}
      
      if {$generate_bin_file eq 1} {
        set command "exec ${::TE::NIOSV_BIN_PATH}/niosv-shell --run \" riscv32-unknown-elf-objcopy --input-target srec --output-target binary ./build/${::TE::SDK_SRC_NAME}.srec ./${::TE::SDK_SRC_NAME}.bin \""
      } else {
        set command "exec ${::TE::NIOSV_BIN_PATH}/niosv-shell --run \" riscv32-unknown-elf-objcopy --input-target srec --output-target ihex ./build/${::TE::SDK_SRC_NAME}.srec ./${::TE::SDK_SRC_NAME}.hex \""
      }
      if {[catch {eval $command} result]} {::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-29}
    }
    ::TE::UTILS::te_msg -type Info -id TE_SDK-18 -msg "Generate $tmp_text file -> done"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  #--------------------------------
  #-- downlaod *.elf file to device
  proc download_elf {FILEDIR} {
    ::TE::UTILS::te_msg -type Info -id TE_SDK-19 -msg "Download [file tail $FILEDIR]. Please wait ..."
    # set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
    # lappend command nios2-download
    # lappend command $FILEDIR
    # lappend command --go
    
    # generate *.srec file from *.elf file
    set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
    lappend command nios2-elf-objcopy${::TE::WIN_EXE}
    lappend command $FILEDIR
    lappend command -O srec [string map {".elf" ".srec"} $FILEDIR]
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-20
    }    
    # download *.srec file to device and run processor
    set command "exec [subst ${::TE::NIOS2_COMMAND_SHELL_PATH}]"
    lappend command nios2-gdb-server${::TE::WIN_EXE}
    lappend command [string map {".elf" ".srec"} $FILEDIR]
    lappend command --go
    if {[catch {eval $command} result]} {
      ::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-21
    }
    # delete *.srec file
    file delete -force [string map {".elf" ".srec"} $FILEDIR]
    
    ::TE::UTILS::te_msg -type Info -id TE_SDK-22 -msg "Download [file tail $FILEDIR] finished"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }

  #--------------------------------
  #-- downlaod *.elf file to device
  proc write_flash_memory {FILEDIR {ERASE false} {SILENT ""}} {
    if {$ERASE} { set tmp_text "Erasing flash memory" } else { set tmp_text "Writing flash memory ([file tail $FILEDIR])" }
    ::TE::UTILS::te_msg -type Info -id TE_SDK-30 -msg "$tmp_text. Please wait ..."
    
    set pgm_flash_bin $FILEDIR
    if {$pgm_flash_bin ne "" || $ERASE} {
      set pgm_flash_exe [glob -nocomplain -dir ${::TE::BASEFOLDER}/misc/d2xx_spi_flash_programmer/ *.exe]
      set pgm_flash_sof [glob -nocomplain -dir ${::TE::BASEFOLDER}/misc/d2xx_spi_flash_programmer/ *.sof]
      if {[file exists $pgm_flash_exe] && [file exists $pgm_flash_sof]} {
        set command exec
        lappend command quartus_pgm${::TE::WIN_EXE}
        lappend command --cable Arrow-USB-Blaster
        lappend command --mode jtag
        lappend command --operation "p;$pgm_flash_sof"
        [catch {eval $command} result]
        if {[::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-31 $SILENT]} {
          return -code error "Program [file tail $pgm_flash_sof] failed."
        }
        ::TE::UTILS::te_msg -msg ""
        if {$::tcl_platform(platform) eq "windows"} {
          set command exec
          lappend command $pgm_flash_exe
          lappend command --channel=B
          if { $ERASE } {
            lappend command --erase
          } else {
            lappend command --program
            lappend command --verify
            lappend command --file=$pgm_flash_bin
          }
        } else {
          set command flashrom
          lappend command --programmer ft2232_spi:type=2232H,port=B,divisor=4
          if { $ERASE } { lappend command --erase } else { lappend command --write $pgm_flash_bin }
        }
        
        [catch {eval $command} result]
        if {[::TE::UTILS::report -msg $result -command $command -msgid TE_SDK-32 $SILENT]} {
          return -code error "$tmp_text flash memory failed."
        }
      } else {
        ::TE::UTILS::te_msg -type Critical_Warning -id TE_SDK-35 -msg "${::TE::BASEFOLDER}/misc/d2xx_spi_flash_programmer not found."
      }
    }
    
    ::TE::UTILS::te_msg -type Info -id TE_SDK-33 -msg "$tmp_text finished"
    ::TE::UTILS::te_msg -msg "------------------------------"
  }

  #--------------------------------
  #-- get cpu parameter
  proc get_cpu_parameter {} {
    ::TE::UTILS::te_msg -type Info -id TE_SDK-34 -msg "Get CPU parameter ..."
    
    set nios_parameter 0
    set ::TE::QSYS_CPU_RESETSLAVE_BASEADDR ""
    set ::TE::QSYS_CPU_RESETSLAVE_ENDADDR ""
    set ::TE::QSYS_CPU_VARIANT ""
    set ::TE::QSYS_CPU_NAME ""
    set ::TE::QSYS_CPU_RESETADDR ""
    set ::TE::QSYS_CPU_RESETSLAVE ""
    
    # read *.sopcinfo file
    if {${::TE::QEDITION} == "Pro"} {
      set fp_r [open ${::TE::QPROJ_PATH}/${::TE::QSYS_SOPC_FILE_NAME}/${::TE::QSYS_SOPC_FILE_NAME}.sopcinfo "r"]
    } else {
      set fp_r [open ${::TE::QPROJ_PATH}/${::TE::QSYS_SOPC_FILE_NAME}.sopcinfo "r"]
    }

    while { [gets $fp_r line] >= 0 } {
      # search for nios cpu variant
      if {[string match *kind=\"altera_nios2_gen2\"* $line]} {
        set ::TE::QSYS_CPU_VARIANT "altera_nios2_gen2"
      } elseif {[string match *kind=\"intel_niosv_m\"* $line]} {
        set ::TE::QSYS_CPU_VARIANT "intel_niosv_m"
      } elseif {[string match *kind=\"intel_niosv_g\"* $line]} {
        set ::TE::QSYS_CPU_VARIANT "intel_niosv_g"
      }
      # search for nios cpu name
      if { ${::TE::QSYS_CPU_VARIANT} ne "" && ${::TE::QSYS_CPU_NAME} eq ""} {
        if { ${::TE::QEDITION} == "Pro" } { set tmpline $oldline } else { set tmpline $line }
        regexp {name=\"(\w+)\"} $tmpline matched ::TE::QSYS_CPU_NAME
      }
      set oldline $line

      # search for nios cpu reset address, cpu reset agent
      if { [string match -nocase "*kind=\"${::TE::QSYS_CPU_VARIANT}\"*" $line] } {
        while {$nios_parameter ne 3} {
          [gets $fp_r line] 
          # get cpu reset_addr
          if { [string match -nocase *embeddedsw.CMacro.RESET_ADDR* $line] } {
            [gets $fp_r line]
            regexp {<value>(.*)</value>} $line matched ::TE::QSYS_CPU_RESETADDR
            incr nios_parameter
          }
        
          # get cpu resetSlave
          if { [string match -nocase *embeddedsw.configuration.resetSlave* $line] } {
            [gets $fp_r line]
            regexp {<value>(.*)</value>} $line matched ::TE::QSYS_CPU_RESETSLAVE
            incr nios_parameter
          }        
          # search for cpu resetSlave base and end address
          if { [string match -nocase "*slave name='${::TE::QSYS_CPU_RESETSLAVE}' start='*" $line] } {
            set tmpline [split $line "/"]
            foreach tmpline2 $tmpline {
              if { [string match -nocase *${::TE::QSYS_CPU_RESETSLAVE}* $tmpline2] } {
                regexp {start='(0[xX][0-9a-fA-F]+)' end='(0[xX][0-9a-fA-F]+)'} $tmpline2 matched ::TE::QSYS_CPU_RESETSLAVE_BASEADDR ::TE::QSYS_CPU_RESETSLAVE_ENDADDR
                incr nios_parameter
                break
              }
            }
          }
        }
      }
      if { $nios_parameter eq 3 } { break }
    }
    
    close $fp_r
    
    ::TE::UTILS::te_msg -type Info -msg "Software project info: \
                                       \n project:  ${::TE::SDK_SRC_NAME} \
                                       \n elf-name: ${::TE::SDK_SRC_NAME}.elf \
                                       \n cpu: \
                                       \n | variant:       ${::TE::QSYS_CPU_VARIANT} \
                                       \n | name:          ${::TE::QSYS_CPU_NAME} \
                                       \n | reset address: ${::TE::QSYS_CPU_RESETADDR} \
                                       \n | reset slave:   ${::TE::QSYS_CPU_RESETSLAVE} \
                                       \n   | base address: ${::TE::QSYS_CPU_RESETSLAVE_BASEADDR} \
                                       \n   | end address:  ${::TE::QSYS_CPU_RESETSLAVE_ENDADDR} \
                                       "
    ::TE::UTILS::te_msg -msg "------------------------------"
  }
  
  # -----------------------------------------------------------------------------------------------------------------------------------------
  # finished sdk functions
  # -----------------------------------------------------------------------------------------------------------------------------------------  
 }
  ::TE::UTILS::te_msg -type Info -msg "(TE) Load sdk script finished"
}
