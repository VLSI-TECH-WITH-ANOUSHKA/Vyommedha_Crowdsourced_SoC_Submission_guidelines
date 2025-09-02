#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <irq.h>
#include <uart.h>
#include <console.h>
#include <generated/csr.h>

// --------------------------------------------------------------------
// Simple Console Input
// --------------------------------------------------------------------
static char *readstr(void) {
    char c[2];
    static char s[64];
    static int ptr = 0;

    if (readchar_nonblock()) {
        c[0] = readchar();
        c[1] = 0;
        switch (c[0]) {
            case 0x7f: // backspace
            case 0x08:
                if (ptr > 0) {
                    ptr--;
                    putsnonl("\x08 \x08");
                }
                break;
            case 0x07: // bell
                break;
            case '\r':
            case '\n':
                s[ptr] = 0x00;
                putsnonl("\n");
                ptr = 0;
                return s;
            default:
                if (ptr >= (sizeof(s) - 1))
                    break;
                putsnonl(c);
                s[ptr] = c[0];
                ptr++;
                break;
        }
    }
    return NULL;
}

static char *get_token(char **str) {
    char *c, *d;

    c = (char *)strchr(*str, ' ');
    if (c == NULL) {
        d = *str;
        *str = *str + strlen(*str);
        return d;
    }
    *c = 0;
    d = *str;
    *str = c + 1;
    return d;
}

// --------------------------------------------------------------------
// Commands
// --------------------------------------------------------------------
static void prompt(void) {
    printf("RUNTIME> ");
}

static void help(void) {
    puts("Available commands:");
    puts("help       - Show this help");
    puts("reboot     - Reset CPU");
    puts("led        - LED test pattern");
    puts("switches   - Read switch state");
}

static void reboot(void) {
    ctrl_reset_write(1);
}

static void led_test(void) {
    int i;
    printf("led_test...\n");
    for (i = 0; i < 256; i++) {
        leds_out_write(i & 0xFF);  // write 8-bit pattern
        busy_wait(1);
    }
    leds_out_write(0); // turn off
}

static void switches_test(void) {
    unsigned sw = switches_in_read();
    printf("Switches: 0x%02x\n", sw & 0x0F);
}

static void console_service(void) {
    char *str;
    char *token;

    str = readstr();
    if (str == NULL) return;
    token = get_token(&str);

    if (strcmp(token, "help") == 0)
        help();
    else if (strcmp(token, "reboot") == 0)
        reboot();
    else if (strcmp(token, "led") == 0)
        led_test();
    else if (strcmp(token, "switches") == 0)
        switches_test();
    else
        printf("Unknown command: %s\n", token);

    prompt();
}

// --------------------------------------------------------------------
// Main
// --------------------------------------------------------------------
int main(void) {
#ifdef CONFIG_CPU_HAS_INTERRUPT
    irq_setmask(0);
    irq_setie(1);
#endif
    uart_init();

    puts("\nLiteX DE0-Nano Console built "__DATE__" "__TIME__"\n");
    help();
    prompt();

    while (1) {
        console_service();
    }
    return 0;
}

