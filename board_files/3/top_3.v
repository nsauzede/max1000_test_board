//
//  TEI0001 - MAX1000 - 3
// 

module top_3
(
  // user leds
  output      LED1,
  output      LED2,
  output      LED3,
  output      LED4,
  output      LED5,
  output      LED6,
  output      LED7,
  output      LED8,
  
  // FTDI - UART
  input     BDBUS0, //FPGA_RXD
  output    BDBUS1, //FPGA_TXD
  // input      BDBUS2, // RTS#
  // output     BDBUS3, // CTS#
  // input      BDBUS4, // DTR#
  // output     BDBUS5, // DSR#
  
  // sdram memory
  output      CAS,
  output      CKE,
  output      CLK,
  output      CS,
  inout   [15:0]  DQ,
  output  [1:0]   DQM,
  output  [11:0]  A,
  output  [1:0]   BA,
  output      RAS,
  output      WE,
  
  // clock
  input     CLK12M,
  
  // user flash memory
  output    F_CLK,
  output    F_CS,
  output    F_DI,
  input     F_DO,
  // can be used for QSPI flash 
  // inout      DEVCLRN,
  // inout      NSTATUS,
  
  // user buttons
  input     RESET,
  input     USER_BTN,
  
  // 3-axis accelerometer
  output    SEN_CS,
  output    SEN_SDI,
  input     SEN_SDO,
  output    SEN_SPC,
  input     SEN_INT1,
  input     SEN_INT2,

  // MAX10 ADC
  // input      AIN0,
  // input      AIN1,
  // input      AIN2,
  // input      AIN3,
  // input      AIN4,
  // input      AIN5,
  // input      AIN6,
  // input      AIN7,
  
  // Pin Header J1/J2 I/O
  // input/output D0,
  // input/output D1,
  // input/output D2,
  // input/output D3,
  // input/output D4,
  // input/output D5,
  // input/output D6,
  // input/output D7,
  // input/output D8,
  // input/output D9,
  // input/output D10,
  // input/output D11,
  // input/output D11_R,
  // input/output D12,
  // input/output D12_R,
  // input/output D13,
  // input/output D14,
  
  // Pin Header J6 I/O
  // input/output PIO_01,
  // input/output PIO_02,
  // input/output PIO_03,
  // input/output PIO_04,
  // input/output PIO_05,
  // input/output PIO_06,
  // input/output PIO_07,
  // input/output PIO_08,
  
  // Pin Header J4 I/O
  // input/output JTAGEN,
  
  // connected to LED D10
  output      CONF_DONE
);

endmodule
