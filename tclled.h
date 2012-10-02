#ifndef _TCLLED_H
#define _TCLLED_H
#include <stdint.h>
#include <linux/types.h>
#include <stdlib.h>

typedef struct _tcl_color {
  uint8_t flag;
  uint8_t blue;
  uint8_t green;
  uint8_t red;
} tcl_color;

typedef struct _tcl_buffer {
  int leds; /* number of LEDS */
  size_t size; /* size of buffer */
  tcl_color *buffer; /* pointer to buffer memory */
  tcl_color *pixels; /* pointer to start of pixels */
} tcl_buffer;

void tcl_init(tcl_buffer *buf, int leds);
int spi_init(int filedes);
void write_color(tcl_color *p, uint8_t red, uint8_t green, uint8_t blue);
int send_buffer(int filedes, tcl_buffer *buf);
void tcl_free(tcl_buffer *buf);
void set_gamma(double gamma_red, double gamma_green, double gamma_blue);
void write_gamma_color(tcl_color *p, uint8_t red, uint8_t green, uint8_t blue);

#endif /*!_TCLLED_H*/
