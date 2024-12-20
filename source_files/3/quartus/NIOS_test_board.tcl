# qsys scripting (.tcl) file for NIOS_test_board
package require -exact qsys 16.0
# #TE_MOD#_Add next line
set arg [split $::args "|"] 
# #TE_MOD#_Add next line
set ::device [lindex $arg 0] 
# #TE_MOD#_Add next line
set ::device_family [lindex $arg 1] 
# #TE_MOD#_Add next line
set ::ddr_device [lindex $arg 2] 
# #TE_MOD#_Add next line
set ::sdk_name [lindex $arg 3] 

create_system {NIOS_test_board}

# #TE_MOD# set_project_property DEVICE_FAMILY {MAX 10} 
# #TE_MOD#_Add next line 
set_project_property DEVICE_FAMILY $::device_family
# #TE_MOD# set_project_property DEVICE {10M08SAU169C8G} 
# #TE_MOD#_Add next line 
set_project_property DEVICE $::device
set_project_property HIDE_FROM_IP_CATALOG {false}

# Instances and instance parameters
# (disabled instances are intentionally culled)
add_instance clk clock_source
set_instance_parameter_value clk {clockFrequency} {12000000.0}
set_instance_parameter_value clk {clockFrequencyKnown} {1}
set_instance_parameter_value clk {resetSynchronousEdges} {NONE}

add_instance pll altpll
set_instance_parameter_value pll {AVALON_USE_SEPARATE_SYSCLK} {NO}
set_instance_parameter_value pll {BANDWIDTH} {}
set_instance_parameter_value pll {BANDWIDTH_TYPE} {AUTO}
set_instance_parameter_value pll {CLK0_DIVIDE_BY} {3}
set_instance_parameter_value pll {CLK0_DUTY_CYCLE} {50}
set_instance_parameter_value pll {CLK0_MULTIPLY_BY} {25}
set_instance_parameter_value pll {CLK0_PHASE_SHIFT} {0}
set_instance_parameter_value pll {CLK1_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK1_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK1_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK1_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK2_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK2_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK2_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK2_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK3_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK3_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK3_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK3_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK4_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK4_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK4_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK4_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK5_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK5_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK5_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK5_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK6_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK6_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK6_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK6_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK7_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK7_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK7_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK7_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK8_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK8_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK8_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK8_PHASE_SHIFT} {}
set_instance_parameter_value pll {CLK9_DIVIDE_BY} {}
set_instance_parameter_value pll {CLK9_DUTY_CYCLE} {}
set_instance_parameter_value pll {CLK9_MULTIPLY_BY} {}
set_instance_parameter_value pll {CLK9_PHASE_SHIFT} {}
set_instance_parameter_value pll {COMPENSATE_CLOCK} {CLK0}
set_instance_parameter_value pll {DOWN_SPREAD} {}
set_instance_parameter_value pll {DPA_DIVIDER} {}
set_instance_parameter_value pll {DPA_DIVIDE_BY} {}
set_instance_parameter_value pll {DPA_MULTIPLY_BY} {}
set_instance_parameter_value pll {ENABLE_SWITCH_OVER_COUNTER} {}
set_instance_parameter_value pll {EXTCLK0_DIVIDE_BY} {}
set_instance_parameter_value pll {EXTCLK0_DUTY_CYCLE} {}
set_instance_parameter_value pll {EXTCLK0_MULTIPLY_BY} {}
set_instance_parameter_value pll {EXTCLK0_PHASE_SHIFT} {}
set_instance_parameter_value pll {EXTCLK1_DIVIDE_BY} {}
set_instance_parameter_value pll {EXTCLK1_DUTY_CYCLE} {}
set_instance_parameter_value pll {EXTCLK1_MULTIPLY_BY} {}
set_instance_parameter_value pll {EXTCLK1_PHASE_SHIFT} {}
set_instance_parameter_value pll {EXTCLK2_DIVIDE_BY} {}
set_instance_parameter_value pll {EXTCLK2_DUTY_CYCLE} {}
set_instance_parameter_value pll {EXTCLK2_MULTIPLY_BY} {}
set_instance_parameter_value pll {EXTCLK2_PHASE_SHIFT} {}
set_instance_parameter_value pll {EXTCLK3_DIVIDE_BY} {}
set_instance_parameter_value pll {EXTCLK3_DUTY_CYCLE} {}
set_instance_parameter_value pll {EXTCLK3_MULTIPLY_BY} {}
set_instance_parameter_value pll {EXTCLK3_PHASE_SHIFT} {}
set_instance_parameter_value pll {FEEDBACK_SOURCE} {}
set_instance_parameter_value pll {GATE_LOCK_COUNTER} {}
set_instance_parameter_value pll {GATE_LOCK_SIGNAL} {}
set_instance_parameter_value pll {HIDDEN_CONSTANTS} {CT#PORT_clk5 PORT_UNUSED CT#PORT_clk4 PORT_UNUSED CT#PORT_clk3 PORT_UNUSED CT#PORT_clk2 PORT_UNUSED CT#PORT_clk1 PORT_UNUSED CT#PORT_clk0 PORT_USED CT#CLK0_MULTIPLY_BY 25 CT#PORT_SCANWRITE PORT_UNUSED CT#PORT_SCANACLR PORT_UNUSED CT#PORT_PFDENA PORT_UNUSED CT#PORT_PLLENA PORT_UNUSED CT#PORT_SCANDATA PORT_UNUSED CT#PORT_SCANCLKENA PORT_UNUSED CT#WIDTH_CLOCK 5 CT#PORT_SCANDATAOUT PORT_UNUSED CT#LPM_TYPE altpll CT#PLL_TYPE AUTO CT#CLK0_PHASE_SHIFT 0 CT#PORT_PHASEDONE PORT_UNUSED CT#OPERATION_MODE NORMAL CT#PORT_CONFIGUPDATE PORT_UNUSED CT#COMPENSATE_CLOCK CLK0 CT#PORT_CLKSWITCH PORT_UNUSED CT#INCLK0_INPUT_FREQUENCY 83333 CT#PORT_SCANDONE PORT_UNUSED CT#PORT_CLKLOSS PORT_UNUSED CT#PORT_INCLK1 PORT_UNUSED CT#AVALON_USE_SEPARATE_SYSCLK NO CT#PORT_INCLK0 PORT_USED CT#PORT_clkena5 PORT_UNUSED CT#PORT_clkena4 PORT_UNUSED CT#PORT_clkena3 PORT_UNUSED CT#PORT_clkena2 PORT_UNUSED CT#PORT_clkena1 PORT_UNUSED CT#PORT_clkena0 PORT_UNUSED CT#PORT_ARESET PORT_UNUSED CT#BANDWIDTH_TYPE AUTO CT#INTENDED_DEVICE_FAMILY {MAX 10} CT#PORT_SCANREAD PORT_UNUSED CT#PORT_PHASESTEP PORT_UNUSED CT#PORT_SCANCLK PORT_UNUSED CT#PORT_CLKBAD1 PORT_UNUSED CT#PORT_CLKBAD0 PORT_UNUSED CT#PORT_FBIN PORT_UNUSED CT#PORT_PHASEUPDOWN PORT_UNUSED CT#PORT_extclk3 PORT_UNUSED CT#PORT_extclk2 PORT_UNUSED CT#PORT_extclk1 PORT_UNUSED CT#PORT_PHASECOUNTERSELECT PORT_UNUSED CT#PORT_extclk0 PORT_UNUSED CT#PORT_ACTIVECLOCK PORT_UNUSED CT#CLK0_DUTY_CYCLE 50 CT#CLK0_DIVIDE_BY 3 CT#PORT_LOCKED PORT_UNUSED}
set_instance_parameter_value pll {HIDDEN_CUSTOM_ELABORATION} {altpll_avalon_elaboration}
set_instance_parameter_value pll {HIDDEN_CUSTOM_POST_EDIT} {altpll_avalon_post_edit}
set_instance_parameter_value pll {HIDDEN_IF_PORTS} {IF#phasecounterselect {input 3} IF#locked {output 0} IF#reset {input 0} IF#clk {input 0} IF#phaseupdown {input 0} IF#scandone {output 0} IF#readdata {output 32} IF#write {input 0} IF#scanclk {input 0} IF#phasedone {output 0} IF#c4 {output 0} IF#c3 {output 0} IF#address {input 2} IF#c2 {output 0} IF#c1 {output 0} IF#c0 {output 0} IF#writedata {input 32} IF#read {input 0} IF#areset {input 0} IF#scanclkena {input 0} IF#scandataout {output 0} IF#configupdate {input 0} IF#phasestep {input 0} IF#scandata {input 0}}
set_instance_parameter_value pll {HIDDEN_IS_FIRST_EDIT} {0}
set_instance_parameter_value pll {HIDDEN_IS_NUMERIC} {IN#WIDTH_CLOCK 1 IN#CLK0_DUTY_CYCLE 1 IN#PLL_TARGET_HARCOPY_CHECK 1 IN#SWITCHOVER_COUNT_EDIT 1 IN#INCLK0_INPUT_FREQUENCY 1 IN#PLL_LVDS_PLL_CHECK 1 IN#PLL_AUTOPLL_CHECK 1 IN#PLL_FASTPLL_CHECK 1 IN#PLL_ENHPLL_CHECK 1 IN#DIV_FACTOR0 1 IN#LVDS_MODE_DATA_RATE_DIRTY 1 IN#GLOCK_COUNTER_EDIT 1 IN#CLK0_DIVIDE_BY 1 IN#MULT_FACTOR0 1 IN#CLK0_MULTIPLY_BY 1 IN#USE_MIL_SPEED_GRADE 1}
set_instance_parameter_value pll {HIDDEN_MF_PORTS} {MF#clk 1 MF#inclk 1}
set_instance_parameter_value pll {HIDDEN_PRIVATES} {PT#GLOCKED_FEATURE_ENABLED 0 PT#SPREAD_FEATURE_ENABLED 0 PT#BANDWIDTH_FREQ_UNIT MHz PT#CUR_DEDICATED_CLK c0 PT#INCLK0_FREQ_EDIT 83333.000 PT#BANDWIDTH_PRESET Low PT#PLL_LVDS_PLL_CHECK 0 PT#BANDWIDTH_USE_PRESET 0 PT#AVALON_USE_SEPARATE_SYSCLK NO PT#PLL_ENHPLL_CHECK 0 PT#OUTPUT_FREQ_UNIT0 MHz PT#PHASE_RECONFIG_FEATURE_ENABLED 1 PT#CREATE_CLKBAD_CHECK 0 PT#CLKSWITCH_CHECK 0 PT#INCLK1_FREQ_EDIT 100.000 PT#NORMAL_MODE_RADIO 1 PT#SRC_SYNCH_COMP_RADIO 0 PT#PLL_ARESET_CHECK 0 PT#LONG_SCAN_RADIO 1 PT#SCAN_FEATURE_ENABLED 1 PT#PHASE_RECONFIG_INPUTS_CHECK 0 PT#USE_CLK0 1 PT#PRIMARY_CLK_COMBO inclk0 PT#BANDWIDTH 1.000 PT#GLOCKED_COUNTER_EDIT_CHANGED 1 PT#PLL_FASTPLL_CHECK 0 PT#SPREAD_FREQ_UNIT KHz PT#PLL_AUTOPLL_CHECK 1 PT#LVDS_PHASE_SHIFT_UNIT0 ps PT#SWITCHOVER_FEATURE_ENABLED 0 PT#MIG_DEVICE_SPEED_GRADE Any PT#OUTPUT_FREQ_MODE0 0 PT#BANDWIDTH_FEATURE_ENABLED 1 PT#INCLK0_FREQ_UNIT_COMBO ps PT#ZERO_DELAY_RADIO 0 PT#OUTPUT_FREQ0 100.00000000 PT#SHORT_SCAN_RADIO 0 PT#LVDS_MODE_DATA_RATE_DIRTY 0 PT#CUR_FBIN_CLK c0 PT#PLL_ADVANCED_PARAM_CHECK 0 PT#CLKBAD_SWITCHOVER_CHECK 0 PT#PHASE_SHIFT_STEP_ENABLED_CHECK 0 PT#DEVICE_SPEED_GRADE Any PT#PLL_FBMIMIC_CHECK 0 PT#LVDS_MODE_DATA_RATE {Not Available} PT#LOCKED_OUTPUT_CHECK 0 PT#SPREAD_PERCENT 0.500 PT#PHASE_SHIFT0 0.00000000 PT#DIV_FACTOR0 3 PT#CNX_NO_COMPENSATE_RADIO 0 PT#USE_CLKENA0 0 PT#CREATE_INCLK1_CHECK 0 PT#GLOCK_COUNTER_EDIT 1048575 PT#INCLK1_FREQ_UNIT_COMBO MHz PT#EFF_OUTPUT_FREQ_VALUE0 100.000397 PT#SPREAD_FREQ 50.000 PT#USE_MIL_SPEED_GRADE 0 PT#EXPLICIT_SWITCHOVER_COUNTER 0 PT#STICKY_CLK4 0 PT#STICKY_CLK3 0 PT#STICKY_CLK2 0 PT#STICKY_CLK1 0 PT#STICKY_CLK0 1 PT#EXT_FEEDBACK_RADIO 0 PT#MIRROR_CLK0 0 PT#SWITCHOVER_COUNT_EDIT 1 PT#SELF_RESET_LOCK_LOSS 0 PT#PLL_PFDENA_CHECK 0 PT#INT_FEEDBACK__MODE_RADIO 1 PT#INCLK1_FREQ_EDIT_CHANGED 1 PT#CLKLOSS_CHECK 0 PT#SYNTH_WRAPPER_GEN_POSTFIX 0 PT#PHASE_SHIFT_UNIT0 ps PT#BANDWIDTH_USE_AUTO 1 PT#HAS_MANUAL_SWITCHOVER 1 PT#MULT_FACTOR0 25 PT#SPREAD_USE 0 PT#GLOCKED_MODE_CHECK 0 PT#SACN_INPUTS_CHECK 0 PT#DUTY_CYCLE0 50.00000000 PT#INTENDED_DEVICE_FAMILY {MAX 10} PT#PLL_TARGET_HARCOPY_CHECK 0 PT#INCLK1_FREQ_UNIT_CHANGED 1 PT#RECONFIG_FILE ALTPLL1695385435321644.mif PT#ACTIVECLK_CHECK 0}
set_instance_parameter_value pll {HIDDEN_USED_PORTS} {UP#c0 used UP#inclk0 used}
set_instance_parameter_value pll {INCLK0_INPUT_FREQUENCY} {83333}
set_instance_parameter_value pll {INCLK1_INPUT_FREQUENCY} {}
set_instance_parameter_value pll {INTENDED_DEVICE_FAMILY} {MAX 10}
set_instance_parameter_value pll {INVALID_LOCK_MULTIPLIER} {}
set_instance_parameter_value pll {LOCK_HIGH} {}
set_instance_parameter_value pll {LOCK_LOW} {}
set_instance_parameter_value pll {OPERATION_MODE} {NORMAL}
set_instance_parameter_value pll {PLL_TYPE} {AUTO}
set_instance_parameter_value pll {PORT_ACTIVECLOCK} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_ARESET} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_CLKBAD0} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_CLKBAD1} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_CLKLOSS} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_CLKSWITCH} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_CONFIGUPDATE} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_ENABLE0} {}
set_instance_parameter_value pll {PORT_ENABLE1} {}
set_instance_parameter_value pll {PORT_FBIN} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_FBOUT} {}
set_instance_parameter_value pll {PORT_INCLK0} {PORT_USED}
set_instance_parameter_value pll {PORT_INCLK1} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_LOCKED} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_PFDENA} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_PHASECOUNTERSELECT} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_PHASEDONE} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_PHASESTEP} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_PHASEUPDOWN} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_PLLENA} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANACLR} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANCLK} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANCLKENA} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANDATA} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANDATAOUT} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANDONE} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANREAD} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCANWRITE} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_SCLKOUT0} {}
set_instance_parameter_value pll {PORT_SCLKOUT1} {}
set_instance_parameter_value pll {PORT_VCOOVERRANGE} {}
set_instance_parameter_value pll {PORT_VCOUNDERRANGE} {}
set_instance_parameter_value pll {PORT_clk0} {PORT_USED}
set_instance_parameter_value pll {PORT_clk1} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clk2} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clk3} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clk4} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clk5} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clk6} {}
set_instance_parameter_value pll {PORT_clk7} {}
set_instance_parameter_value pll {PORT_clk8} {}
set_instance_parameter_value pll {PORT_clk9} {}
set_instance_parameter_value pll {PORT_clkena0} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clkena1} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clkena2} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clkena3} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clkena4} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_clkena5} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_extclk0} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_extclk1} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_extclk2} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_extclk3} {PORT_UNUSED}
set_instance_parameter_value pll {PORT_extclkena0} {}
set_instance_parameter_value pll {PORT_extclkena1} {}
set_instance_parameter_value pll {PORT_extclkena2} {}
set_instance_parameter_value pll {PORT_extclkena3} {}
set_instance_parameter_value pll {PRIMARY_CLOCK} {}
set_instance_parameter_value pll {QUALIFY_CONF_DONE} {}
set_instance_parameter_value pll {SCAN_CHAIN} {}
set_instance_parameter_value pll {SCAN_CHAIN_MIF_FILE} {}
set_instance_parameter_value pll {SCLKOUT0_PHASE_SHIFT} {}
set_instance_parameter_value pll {SCLKOUT1_PHASE_SHIFT} {}
set_instance_parameter_value pll {SELF_RESET_ON_GATED_LOSS_LOCK} {}
set_instance_parameter_value pll {SELF_RESET_ON_LOSS_LOCK} {}
set_instance_parameter_value pll {SKIP_VCO} {}
set_instance_parameter_value pll {SPREAD_FREQUENCY} {}
set_instance_parameter_value pll {SWITCH_OVER_COUNTER} {}
set_instance_parameter_value pll {SWITCH_OVER_ON_GATED_LOCK} {}
set_instance_parameter_value pll {SWITCH_OVER_ON_LOSSCLK} {}
set_instance_parameter_value pll {SWITCH_OVER_TYPE} {}
set_instance_parameter_value pll {USING_FBMIMICBIDIR_PORT} {}
set_instance_parameter_value pll {VALID_LOCK_MULTIPLIER} {}
set_instance_parameter_value pll {VCO_DIVIDE_BY} {}
set_instance_parameter_value pll {VCO_FREQUENCY_CONTROL} {}
set_instance_parameter_value pll {VCO_MULTIPLY_BY} {}
set_instance_parameter_value pll {VCO_PHASE_SHIFT_STEP} {}
set_instance_parameter_value pll {WIDTH_CLOCK} {5}
set_instance_parameter_value pll {WIDTH_PHASECOUNTERSELECT} {}

add_instance niosv_m intel_niosv_m
set_instance_parameter_value niosv_m {enableDebug} {0}
set_instance_parameter_value niosv_m {enableDebugReset} {0}
set_instance_parameter_value niosv_m {numGpr} {32}
set_instance_parameter_value niosv_m {resetOffset} {0}
set_instance_parameter_value niosv_m {resetSlave} {flash.avl_mem}
set_instance_parameter_value niosv_m {useResetReq} {0}

add_instance flash intel_generic_serial_flash_interface_top
set_instance_parameter_value flash {CHIP_SELECT_BYPASS} {0}
set_instance_parameter_value flash {CHIP_SELS} {1}
set_instance_parameter_value flash {DEBUG_OPTION} {0}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_0} {1}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_1} {16}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_2} {0}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_3} {0}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_4} {0}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_5} {3}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_6} {1282}
set_instance_parameter_value flash {DEFAULT_VALUE_REG_7} {6149}
set_instance_parameter_value flash {DEVICE_DENSITY} {64}
set_instance_parameter_value flash {ENABLE_SIM_MODEL} {0}
set_instance_parameter_value flash {PIPE_CMD_GEN_CMD} {0}
set_instance_parameter_value flash {PIPE_CSR} {0}
set_instance_parameter_value flash {PIPE_MUX_CMD} {0}
set_instance_parameter_value flash {PIPE_XIP} {0}
set_instance_parameter_value flash {USE_CHIP_SEL_FROM_CSR} {1}
set_instance_parameter_value flash {gui_use_asmiblock} {1}
set_instance_parameter_value flash {gui_use_csr_byteenable} {0}
set_instance_parameter_value flash {gui_use_gpio} {1}

add_instance sdram_controller sdram_controller_axi4
# #TE_MOD#_Add next line
apply_preset sdram_controller "$::ddr_device" 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_BANKS} {4} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_CAS_LATENCY} {3} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_COL_W} {8} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_MHZ} {100} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_ROW_W} {12} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_START_DELAY_US} {200} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_TRCD_NS} {15} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_TRFC_NS} {60} 
# #TE_MOD# set_instance_parameter_value sdram_controller {SDRAM_TRP_NS} {15} 

add_instance pio_led altera_avalon_pio
set_instance_parameter_value pio_led {bitClearingEdgeCapReg} {0}
set_instance_parameter_value pio_led {bitModifyingOutReg} {0}
set_instance_parameter_value pio_led {captureEdge} {0}
set_instance_parameter_value pio_led {direction} {Output}
set_instance_parameter_value pio_led {edgeType} {RISING}
set_instance_parameter_value pio_led {generateIRQ} {0}
set_instance_parameter_value pio_led {irqType} {LEVEL}
set_instance_parameter_value pio_led {resetValue} {0.0}
set_instance_parameter_value pio_led {simDoTestBenchWiring} {0}
set_instance_parameter_value pio_led {simDrivenValue} {0.0}
set_instance_parameter_value pio_led {width} {8}

add_instance pio_sel altera_avalon_pio
set_instance_parameter_value pio_sel {bitClearingEdgeCapReg} {0}
set_instance_parameter_value pio_sel {bitModifyingOutReg} {0}
set_instance_parameter_value pio_sel {captureEdge} {0}
set_instance_parameter_value pio_sel {direction} {Input}
set_instance_parameter_value pio_sel {edgeType} {RISING}
set_instance_parameter_value pio_sel {generateIRQ} {0}
set_instance_parameter_value pio_sel {irqType} {LEVEL}
set_instance_parameter_value pio_sel {resetValue} {0.0}
set_instance_parameter_value pio_sel {simDoTestBenchWiring} {0}
set_instance_parameter_value pio_sel {simDrivenValue} {0.0}
set_instance_parameter_value pio_sel {width} {5}

add_instance spi_g_sensor altera_avalon_spi
set_instance_parameter_value spi_g_sensor {clockPhase} {0}
set_instance_parameter_value spi_g_sensor {clockPolarity} {0}
set_instance_parameter_value spi_g_sensor {dataWidth} {8}
set_instance_parameter_value spi_g_sensor {disableAvalonFlowControl} {0}
set_instance_parameter_value spi_g_sensor {insertDelayBetweenSlaveSelectAndSClk} {0}
set_instance_parameter_value spi_g_sensor {insertSync} {0}
set_instance_parameter_value spi_g_sensor {lsbOrderedFirst} {0}
set_instance_parameter_value spi_g_sensor {masterSPI} {1}
set_instance_parameter_value spi_g_sensor {numberOfSlaves} {1}
set_instance_parameter_value spi_g_sensor {syncRegDepth} {2}
set_instance_parameter_value spi_g_sensor {targetClockRate} {128000.0}
set_instance_parameter_value spi_g_sensor {targetSlaveSelectToSClkDelay} {0.0}

add_instance uart altera_avalon_uart
set_instance_parameter_value uart {baud} {115200}
set_instance_parameter_value uart {dataBits} {8}
set_instance_parameter_value uart {fixedBaud} {1}
set_instance_parameter_value uart {parity} {NONE}
set_instance_parameter_value uart {simCharStream} {}
set_instance_parameter_value uart {simInteractiveInputEnable} {0}
set_instance_parameter_value uart {simInteractiveOutputEnable} {0}
set_instance_parameter_value uart {simTrueBaud} {0}
set_instance_parameter_value uart {stopBits} {1}
set_instance_parameter_value uart {syncRegDepth} {2}
set_instance_parameter_value uart {useCtsRts} {0}
set_instance_parameter_value uart {useEopRegister} {0}
set_instance_parameter_value uart {useRelativePathForSimFile} {0}

# exported interfaces
add_interface clk_in clock sink
set_interface_property clk_in EXPORT_OF clk.clk_in
add_interface pio_led conduit end
set_interface_property pio_led EXPORT_OF pio_led.external_connection
add_interface pio_sel conduit end
set_interface_property pio_sel EXPORT_OF pio_sel.external_connection
add_interface qspi conduit end
set_interface_property qspi EXPORT_OF flash.qspi_pins
add_interface reset reset sink
set_interface_property reset EXPORT_OF clk.clk_in_reset
add_interface sdram conduit end
set_interface_property sdram EXPORT_OF sdram_controller.wire
add_interface spi_g_sen conduit end
set_interface_property spi_g_sen EXPORT_OF spi_g_sensor.external
add_interface uart conduit end
set_interface_property uart EXPORT_OF uart.external_connection

# connections and connection parameters
add_connection clk.clk pll.inclk_interface

add_connection clk.clk_reset flash.reset

add_connection clk.clk_reset niosv_m.reset

add_connection clk.clk_reset pio_led.reset

add_connection clk.clk_reset pio_sel.reset

add_connection clk.clk_reset pll.inclk_interface_reset

add_connection clk.clk_reset sdram_controller.reset

add_connection clk.clk_reset spi_g_sensor.reset

add_connection clk.clk_reset uart.reset

add_connection niosv_m.data_manager flash.avl_csr
set_connection_parameter_value niosv_m.data_manager/flash.avl_csr arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/flash.avl_csr baseAddress {0x01000000}
set_connection_parameter_value niosv_m.data_manager/flash.avl_csr defaultConnection {0}

add_connection niosv_m.data_manager flash.avl_mem
set_connection_parameter_value niosv_m.data_manager/flash.avl_mem arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/flash.avl_mem baseAddress {0x0000}
set_connection_parameter_value niosv_m.data_manager/flash.avl_mem defaultConnection {0}

add_connection niosv_m.data_manager niosv_m.timer_sw_agent
set_connection_parameter_value niosv_m.data_manager/niosv_m.timer_sw_agent arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/niosv_m.timer_sw_agent baseAddress {0x01000180}
set_connection_parameter_value niosv_m.data_manager/niosv_m.timer_sw_agent defaultConnection {0}

add_connection niosv_m.data_manager pio_led.s1
set_connection_parameter_value niosv_m.data_manager/pio_led.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/pio_led.s1 baseAddress {0x01000150}
set_connection_parameter_value niosv_m.data_manager/pio_led.s1 defaultConnection {0}

add_connection niosv_m.data_manager pio_sel.s1
set_connection_parameter_value niosv_m.data_manager/pio_sel.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/pio_sel.s1 baseAddress {0x01000140}
set_connection_parameter_value niosv_m.data_manager/pio_sel.s1 defaultConnection {0}

add_connection niosv_m.data_manager pll.pll_slave
set_connection_parameter_value niosv_m.data_manager/pll.pll_slave arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/pll.pll_slave baseAddress {0x01000160}
set_connection_parameter_value niosv_m.data_manager/pll.pll_slave defaultConnection {0}

add_connection niosv_m.data_manager sdram_controller.s1
set_connection_parameter_value niosv_m.data_manager/sdram_controller.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/sdram_controller.s1 baseAddress {0x00800000}
set_connection_parameter_value niosv_m.data_manager/sdram_controller.s1 defaultConnection {0}

add_connection niosv_m.data_manager spi_g_sensor.spi_control_port
set_connection_parameter_value niosv_m.data_manager/spi_g_sensor.spi_control_port arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/spi_g_sensor.spi_control_port baseAddress {0x01000100}
set_connection_parameter_value niosv_m.data_manager/spi_g_sensor.spi_control_port defaultConnection {0}

add_connection niosv_m.data_manager uart.s1
set_connection_parameter_value niosv_m.data_manager/uart.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.data_manager/uart.s1 baseAddress {0x01000120}
set_connection_parameter_value niosv_m.data_manager/uart.s1 defaultConnection {0}

add_connection niosv_m.instruction_manager flash.avl_csr
set_connection_parameter_value niosv_m.instruction_manager/flash.avl_csr arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/flash.avl_csr baseAddress {0x01000000}
set_connection_parameter_value niosv_m.instruction_manager/flash.avl_csr defaultConnection {0}

add_connection niosv_m.instruction_manager flash.avl_mem
set_connection_parameter_value niosv_m.instruction_manager/flash.avl_mem arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/flash.avl_mem baseAddress {0x0000}
set_connection_parameter_value niosv_m.instruction_manager/flash.avl_mem defaultConnection {0}

add_connection niosv_m.instruction_manager pio_led.s1
set_connection_parameter_value niosv_m.instruction_manager/pio_led.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/pio_led.s1 baseAddress {0x01000150}
set_connection_parameter_value niosv_m.instruction_manager/pio_led.s1 defaultConnection {0}

add_connection niosv_m.instruction_manager pio_sel.s1
set_connection_parameter_value niosv_m.instruction_manager/pio_sel.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/pio_sel.s1 baseAddress {0x01000140}
set_connection_parameter_value niosv_m.instruction_manager/pio_sel.s1 defaultConnection {0}

add_connection niosv_m.instruction_manager pll.pll_slave
set_connection_parameter_value niosv_m.instruction_manager/pll.pll_slave arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/pll.pll_slave baseAddress {0x01000160}
set_connection_parameter_value niosv_m.instruction_manager/pll.pll_slave defaultConnection {0}

add_connection niosv_m.instruction_manager sdram_controller.s1
set_connection_parameter_value niosv_m.instruction_manager/sdram_controller.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/sdram_controller.s1 baseAddress {0x00800000}
set_connection_parameter_value niosv_m.instruction_manager/sdram_controller.s1 defaultConnection {0}

add_connection niosv_m.instruction_manager spi_g_sensor.spi_control_port
set_connection_parameter_value niosv_m.instruction_manager/spi_g_sensor.spi_control_port arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/spi_g_sensor.spi_control_port baseAddress {0x01000100}
set_connection_parameter_value niosv_m.instruction_manager/spi_g_sensor.spi_control_port defaultConnection {0}

add_connection niosv_m.instruction_manager uart.s1
set_connection_parameter_value niosv_m.instruction_manager/uart.s1 arbitrationPriority {1}
set_connection_parameter_value niosv_m.instruction_manager/uart.s1 baseAddress {0x01000120}
set_connection_parameter_value niosv_m.instruction_manager/uart.s1 defaultConnection {0}

add_connection niosv_m.platform_irq_rx spi_g_sensor.irq
set_connection_parameter_value niosv_m.platform_irq_rx/spi_g_sensor.irq irqNumber {1}

add_connection niosv_m.platform_irq_rx uart.irq
set_connection_parameter_value niosv_m.platform_irq_rx/uart.irq irqNumber {0}

add_connection pll.c0 flash.clk

add_connection pll.c0 niosv_m.clk

add_connection pll.c0 pio_led.clk

add_connection pll.c0 pio_sel.clk

add_connection pll.c0 sdram_controller.clk

add_connection pll.c0 spi_g_sensor.clk

add_connection pll.c0 uart.clk

# interconnect requirements
set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
set_interconnect_requirement {$system} {qsys_mm.enableEccProtection} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.insertDefaultSlave} {FALSE}
set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {1}
# #TE_MOD#_Add next line
auto_assign_system_base_addresses 

save_system {NIOS_test_board.qsys}


