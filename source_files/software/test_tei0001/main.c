/*
 * test_tei0001
 *
 * Description:
 * Test hardware of TEI0001 board.
 * This example tests the flash memory, sdram memory, user leds, user buttons and the 3-axis accelerometer.
 * There are some LED sequences for selection: 
 * Spirit level, Pulse-width modulation sequence, Case statement sequence, Shift register sequence and Knightrider sequence
 *
 */


#include "system.h"
#include "stdio.h"
#include "altera_avalon_pio_regs.h"
#include "altera_avalon_spi.h"

void init_g_sen();

int main()
{
  unsigned char wdata[1];
  unsigned char rdata[2];
  unsigned char led_out = 0x18;

  alt_8 y_value = 0;      // create buffer for filtering
  alt_8 y_value_1 = 0;
  alt_8 y_value_2 = 0;
  alt_8 y_value_3 = 0;
  alt_8 y_value_4 = 0;
  alt_8 y_value_5 = 0;

	alt_8 sel;
	alt_8 n_sel = 0x00;
  alt_u8 wb_send[1];
  alt_u8 wb_get[20];
  
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 0x55); // reset sel counter
  IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, 0xFF);

  init_g_sen();
  wdata[0]=0xC0 | 0x2A;    // read y-register and increment

	printf("\n\n\r================== LED sequences ==================\n\r");
	printf("Toggle between following LED sequences by pressing\n\r");
	printf("the user button:\n\n\r");
  printf("1. Spirit level\n\r");
  printf("2. Pulse-width modulation sequence\n\r");
  printf("3. Case statement sequence\n\r");
  printf("4. Shift register sequence\n\r");
  printf("5. Knightrider sequence\n\r");
  printf("\nCurrent LED sequence:\n\r");

  while (1)
  {
    sel = IORD_ALTERA_AVALON_PIO_DATA(PIO_SEL_BASE);

    if (sel != n_sel)
    {
      switch(sel)
      {
      case 0x01: printf("  1. Spirit level\n\r"); break;
      case 0x02: printf("  2. Pulse-width modulation sequence\n\r"); break;
      case 0x04: printf("  3. Case statement sequence\n\r"); break;
      case 0x08: printf("  4. Shift register sequence\n\r"); break;
      case 0x10: printf("  5. Knightrider sequence\n\r"); break;
      default: printf("Error: Select LED sequence failed\n\r"); break;
      }
      n_sel = sel;
    }

    if(sel == 0x01)
    {
      // read y-axis data from g-sensor
      alt_avalon_spi_command (SPI_G_SENSOR_BASE, 0, 1, wdata, 2, rdata, 0);

      // calculate average
      y_value_5 = y_value_4;
      y_value_4 = y_value_3;
      y_value_3 = y_value_2;
      y_value_2 = y_value_1;
      y_value_1 = rdata[1];

      y_value = (y_value_1 + y_value_2 + y_value_3 + y_value_4 + y_value_5) / 5;

      // determine LED setting according to y-axis value
      if (y_value > -4 && y_value < 4)      led_out = 0x18;
      if (y_value >= 4 && y_value < 8)      led_out = 0x08;
      if (y_value >= 8 && y_value < 12)     led_out = 0x04;
      if (y_value >= 12 && y_value < 16)    led_out = 0x02;
      if (y_value >= 16)                    led_out = 0x01;
      if (y_value > -8 && y_value <= -4)    led_out = 0x10;
      if (y_value > -12 && y_value <= -8)   led_out = 0x20;
      if (y_value > -16 && y_value <= -12)  led_out = 0x40;
      if (y_value <= -16)                   led_out = 0x80;

      // set LED
      IOWR_ALTERA_AVALON_PIO_DATA(PIO_LED_BASE, led_out);

      // wait 10 ms
      usleep(10000);
    }
  }
  return 0;
}

void init_g_sen()
{
  unsigned char wdata[3];
  unsigned char rdata[1];

  wdata[0]= 0x40 | 0x20;    // write multiple bytes with start address 0x20
  wdata[1]= 0x37;        // 25Hz mode, low power off, enable axis Z Y X
  wdata[2]= 0x00;        // all filters disabled

  alt_avalon_spi_command (SPI_G_SENSOR_BASE, 0, 3, wdata, 0, rdata, 0);

  wdata[0]= 0x40 | 0x22;    // write multiple bytes with start address 0x22
  wdata[1]= 0x00;        // all interrupts disabled
  wdata[2]= 0x00;        // continous update, little endian, 2g full scale, high resolution disabled, self test disabled, 4 wire SPI

  alt_avalon_spi_command (SPI_G_SENSOR_BASE, 0, 3, wdata, 0, rdata, 0);
}
