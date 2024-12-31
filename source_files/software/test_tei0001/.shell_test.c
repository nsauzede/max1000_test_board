#include <inttypes.h>
// Mock
int set_sensor(int read_length, int read_data[], int write_length, int write_data[]) {
    if (write_length == 1 && read_length == 1 && write_data[0] == 0xcf) {
        read_data[0] = 0x33;
    } else if (read_length == 2) {
        read_data[0] = 1;
        read_data[1] = 2;
    }
    return -1;
}

#include "shell.c"
/******************************************************************************/
#include <ut/ut.h>

#include <string.h>

TESTCASE(TestDevice)
    TESTMETHOD(test_check_sensor) {
        ASSERT_EQ(1, check_sensor());
    }

/*
#define lsb_msb_to_type(t,b,o) (t)(((t)b[o+1] << 8) | b[o])
// temperature is always 8 bit
    if (adc3 && temp_cfg & 0x40)
        *adc3 = (lsb_msb_to_type ( int16_t, data, 4) >> 8) + 25;
    else if (adc3)
        *adc3 = lsb_msb_to_type ( int16_t, data, 4) >> (ctrl1.LPen ? 8 : 6);
*/
// char: 0x80=-128 0x7f=127
// int16: 0x8000=-32768 0x7fff=32767
#define msb_lsb_to_type(t,b,o) (t)(((t)b[o] << 8) | b[o+1])
#define lsb_msb_to_type(t,b,o) (t)(((t)b[o+1] << 8) | b[o])
TESTCASE(TestTemp)
    TESTMETHOD(test_temp) {
        unsigned char data[2] = {0x40, 0x10};
//        unsigned char data[2] = {0xc0, 0x0e};
        int16_t adc3 = (lsb_msb_to_type ( int16_t, data, 0) >> 8) + 25;
        printf("data: %x,%x - adc3=%d\n", data[0], data[1], adc3);
        ASSERT_EQ(0,0);
    }

TESTCASE(TestShell)
    TESTMETHOD(test_eval) {
        char output[512]="";
        char input[512]="";
        snprintf(input, sizeof(input), "UnknownCommand");
        shell_eval(strlen(input), input, sizeof(output), output);
        ASSERT_EQ((const char *)SHELL_OUT_UNKNOWN, output);
        snprintf(input, sizeof(input), SHELL_HELP);
        shell_eval(strlen(input), input, sizeof(output), output);
        ASSERT_EQ((const char *)SHELL_OUT_HELP, output);
        int a1 = 2, a2 = 3, a3 = 0xa, a4 = 0xb, a5 = 0xc;
        snprintf(input, sizeof(input), "%s %x %x %x %x %x", SHELL_SPI, a1, a2, a3, a4, a5);
        shell_eval(strlen(input), input, sizeof(output), output);
        snprintf(input, sizeof(input), "%x %x", 1, 2);
//        snprintf(input, sizeof(input), "%x %x %x %x %x", a1, a2, a3, a4, a5);
        ASSERT_EQ((const char *)input, output);
    }
    TESTMETHOD(test_eval_check_sensor) {
        char output[512]="";
        char input[512]="";
        snprintf(input, sizeof(input), SHELL_CHECK_SENSOR);
        shell_eval(strlen(input), input, sizeof(output), output);
        ASSERT_EQ((const char *)SHELL_OUT_OK, output);
    }
