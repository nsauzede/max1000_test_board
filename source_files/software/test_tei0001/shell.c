#include <stdio.h>
#include <string.h>
#define SHELL_HELP              "help"
#define SHELL_SPI               "spi"
#define SHELL_OUT_HELP      "Help: bla bla"
#define SHELL_OUT_UNKNOWN   "Unknown command"
void shell_eval(int input_len, char *input, int output_len, char *output) {
    if (!strcmp(input, SHELL_HELP)) {
        snprintf(output, output_len, SHELL_OUT_HELP);
    } else if (!strncmp(input, SHELL_SPI, strlen(SHELL_SPI))) {
        alt_u8 wdata[3]={0, 0, 0};
        int a1, a2, a3, a4, a5;
        int n = sscanf(input + strlen(SHELL_SPI), "%x %x %x %x %x", &a1, &a2, &a3, &a4, &a5);
        wdata[0] = a3;
        wdata[1] = a4;
        wdata[2] = a5;
//        printf("sscanf returned %d - input=[%s]\n\r", n, input);
//        a3 = 0xa;a4 = 0xd;
//        snprintf(output, output_len, "%x %x %x %x %x", a1, a2, wdata[0], wdata[1], wdata[2]);
        if (n>=2 && a1 <= 2) {
                alt_u8 rdata[2]={0,0};
                alt_avalon_spi_command (SPI_G_SENSOR_BASE, 0, a2, wdata, a1, rdata, 0);
                snprintf(output, output_len, "%x %x", rdata[0], rdata[1]);
                int y_value_1 = 0, y_value_2 = 0, y_value_3 = 0, y_value_4 = 0, y_value_5 = 0, y_value = 0;
                printf("alt_avalon_spi_command(%x %x %x %x %x) => %x %x => y1=%x y2=%x y3=%x y4=%x y5=%x => y_value=%x\n\r",
                    a1, a2, wdata[0], wdata[1], wdata[2],
                    rdata[0], rdata[1],
                    y_value_1, y_value_2, y_value_3, y_value_4, y_value_5,
                    y_value
                );
                return;
        }
        snprintf(output, output_len, "%s", "");
        return;
    } else {
        snprintf(output, output_len, SHELL_OUT_UNKNOWN);
    }
}
#if 1
void mygets(char *s, int size) {
    int done = 0;
    memset(s, 0, size);
    while (!done) {
//        printf("Enter a char!\n\r");
        int c = getchar();
        if (c == '\n' || c == '\r' || c == 'Z' || c == 0 || c == -1) {
            printf("\n\r");
            done = 1;
        } else {
//            printf("Added '%c'!\n\r", c);
            *s++ = c;
            printf("%c", c);fflush(stdout);
        }
    }
}
void shell() {
    char input[512], output[512];
    printf("Welcome to the SHELL! Enter: \"spi <a1> <a2> <a3> <a4> <a5>\\n\"\n\r");
    mygets(input, sizeof(input));
//    printf("calling shell_eval..\n\r");
    shell_eval(strlen(input), input, sizeof(output), output);
    printf("%s: input=[%s] => output=[%s]\n\r", __func__, input, output);
}
#endif
