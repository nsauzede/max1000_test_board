#
#  TEI0001 - MAX1000 pin assignments - 4
# 

package require ::quartus::project

set_global_assignment -name TOP_LEVEL_ENTITY top_4
set_global_assignment -name VERILOG_FILE top_4.v
set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
set_global_assignment -name INTERNAL_FLASH_UPDATE_MODE "SINGLE IMAGE WITH ERAM"
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name ENABLE_DEVICE_WIDE_RESET OFF
set_global_assignment -name ENABLE_BOOT_SEL_PIN OFF
set_global_assignment -name ENABLE_OCT_DONE OFF
set_global_assignment -name ENABLE_CONFIGURATION_PINS OFF
set_global_assignment -name USE_CONFIGURATION_DEVICE ON
set_global_assignment -name CRC_ERROR_OPEN_DRAIN OFF

set_location_assignment PIN_H6 -to CLK12M
# set_location_assignment PIN_G5 -to CLK_X
set_location_assignment PIN_E6 -to USER_BTN
set_location_assignment PIN_E7 -to RESET
set_location_assignment PIN_E5 -to JTAGEN
set_location_assignment PIN_B9 -to DEVCLRN
set_location_assignment PIN_C4 -to NSTATUS
set_location_assignment PIN_C5 -to CONF_DONE

set_location_assignment PIN_B2 -to F_DO
set_location_assignment PIN_A2 -to F_DI
set_location_assignment PIN_B3 -to F_CS
set_location_assignment PIN_A3 -to F_CLK

set_location_assignment PIN_A8 -to LED1
set_location_assignment PIN_A9 -to LED2
set_location_assignment PIN_A11 -to LED3
set_location_assignment PIN_A10 -to LED4
set_location_assignment PIN_B10 -to LED5
set_location_assignment PIN_C9 -to LED6
set_location_assignment PIN_C10 -to LED7
set_location_assignment PIN_D8 -to LED8

set_location_assignment PIN_K6 -to A[0]
set_location_assignment PIN_M5 -to A[1]
set_location_assignment PIN_N5 -to A[2]
set_location_assignment PIN_J8 -to A[3]
set_location_assignment PIN_N10 -to A[4]
set_location_assignment PIN_M11 -to A[5]
set_location_assignment PIN_N9 -to A[6]
set_location_assignment PIN_L10 -to A[7]
set_location_assignment PIN_M13 -to A[8]
set_location_assignment PIN_N8 -to A[9]
set_location_assignment PIN_N4 -to A[10]
set_location_assignment PIN_M10 -to A[11]
set_location_assignment PIN_L11 -to A[12]
# set_location_assignment PIN_M12 -to A[13]
set_location_assignment PIN_N6 -to BA[0]
set_location_assignment PIN_K8 -to BA[1]
set_location_assignment PIN_N7 -to CAS
set_location_assignment PIN_M8 -to CKE
set_location_assignment PIN_M9 -to CLK
set_location_assignment PIN_M4 -to CS
set_location_assignment PIN_D11 -to DQ[0]
set_location_assignment PIN_G10 -to DQ[1]
set_location_assignment PIN_F10 -to DQ[2]
set_location_assignment PIN_F9 -to DQ[3]
set_location_assignment PIN_E10 -to DQ[4]
set_location_assignment PIN_D9 -to DQ[5]
set_location_assignment PIN_G9 -to DQ[6]
set_location_assignment PIN_F8 -to DQ[7]
set_location_assignment PIN_F13 -to DQ[8]
set_location_assignment PIN_E12 -to DQ[9]
set_location_assignment PIN_E13 -to DQ[10]
set_location_assignment PIN_D12 -to DQ[11]
set_location_assignment PIN_C12 -to DQ[12]
set_location_assignment PIN_B12 -to DQ[13]
set_location_assignment PIN_B13 -to DQ[14]
set_location_assignment PIN_A12 -to DQ[15]
set_location_assignment PIN_E9 -to DQM[0]
set_location_assignment PIN_F12 -to DQM[1]
set_location_assignment PIN_M7 -to RAS
set_location_assignment PIN_K7 -to WE

set_location_assignment PIN_J6 -to SEN_SPC
set_location_assignment PIN_K5 -to SEN_SDO
set_location_assignment PIN_J7 -to SEN_SDI
set_location_assignment PIN_L5 -to SEN_CS
set_location_assignment PIN_J5 -to SEN_INT1
set_location_assignment PIN_L4 -to SEN_INT2

set_location_assignment PIN_A4 -to BDBUS0
set_location_assignment PIN_B4 -to BDBUS1
set_location_assignment PIN_B5 -to BDBUS2
set_location_assignment PIN_A6 -to BDBUS3
set_location_assignment PIN_B6 -to BDBUS4
set_location_assignment PIN_A7 -to BDBUS5

set_location_assignment PIN_E1 -to AIN0
set_location_assignment PIN_C2 -to AIN1
set_location_assignment PIN_D1 -to AIN2
set_location_assignment PIN_D1 -to AIN3
set_location_assignment PIN_E3 -to AIN4
set_location_assignment PIN_F1 -to AIN5
set_location_assignment PIN_E4 -to AIN6
set_location_assignment PIN_B1 -to AIN7

set_location_assignment PIN_H8 -to D0
set_location_assignment PIN_K10 -to D1
set_location_assignment PIN_H5 -to D2
set_location_assignment PIN_H4 -to D3
set_location_assignment PIN_J1 -to D4
set_location_assignment PIN_J2 -to D5
set_location_assignment PIN_L12 -to D6
set_location_assignment PIN_J12 -to D7
set_location_assignment PIN_J13 -to D8
set_location_assignment PIN_K11 -to D9
set_location_assignment PIN_K12 -to D10
set_location_assignment PIN_J10 -to D11
set_location_assignment PIN_B11 -to D11_R
set_location_assignment PIN_H10 -to D12
set_location_assignment PIN_G13 -to D12_R
set_location_assignment PIN_H13 -to D13
set_location_assignment PIN_G12 -to D14

set_location_assignment PIN_M3 -to PIO_01
set_location_assignment PIN_L3 -to PIO_02
set_location_assignment PIN_M2 -to PIO_03
set_location_assignment PIN_M1 -to PIO_04
set_location_assignment PIN_N3 -to PIO_05
set_location_assignment PIN_N2 -to PIO_06
set_location_assignment PIN_K2 -to PIO_07
set_location_assignment PIN_K1 -to PIO_08
