#include <inttypes.h>
#define SPI_G_SENSOR_BASE 1234
typedef uint32_t alt_u32;
typedef uint8_t alt_u8;
int alt_avalon_spi_command(alt_u32 base, alt_u32 slave,
                           alt_u32 write_length, const alt_u8 * write_data,
                           alt_u32 read_length, alt_u8 * read_data,
                           alt_u32 flags) {
    read_data[0] = 1;
    read_data[1] = 2;
    return 0;
}

#include "shell.c"
/******************************************************************************/
#include <ut/ut.h>

#include <string.h>

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
