/*
 * simple_example.c  
 *
 * Copyright 2012 Christopher De Vries
 * This program is distributed under the Artistic License 2.0, a copy of which
 * is included in the file LICENSE.txt
 */
#include "tclled.h"
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

#ifndef SPIFILE
#define SPIFILE "/dev/spidev2.0"
#endif

static const char *device = SPIFILE;

int main(int argc, char *argv[]) {
  int fd;              /* SPI device file descriptor */
  const int leds = 50; /* 50 LEDs in the strand */
  tcl_buffer buf;      /* Memory buffer for pixel values */
  int count;           /* Count of iterations (up to 3) */
  int i;               /* Counting Integer */

  /* Open SPI device */
  fd = open(device,O_WRONLY);
  if(fd<0) {
      /* Open failed */
      fprintf(stderr, "Error: SPI device open failed.\n");
      exit(1);
  }

  /* Initialize SPI bus for TCL pixels */
  if(spi_init(fd)<0) {
      /* Initialization failed */
      fprintf(stderr, "Unable to initialize SPI bus.\n");
      exit(1);
  }

  /* Allocate memory for the pixel buffer and initialize it */
  if(tcl_init(&buf,leds)<0) {
      /* Memory allocation failed */
      fprintf(stderr, "Insufficient memory for pixel buffer.\n");
      exit(1);
  }

  /* Loop Forever */
  while(1) {
    /* Do three iterations */
    for(count=0;count<3;count++) {
      /* Write color for every pixel */
      for(i=0;i<leds;i++) {
        if((i+count)%3==0) {
          /* Red pixel */
          write_color(&buf.pixels[i],255,0,0);
        }
        else if((i+count)%3==1) {
          /* Green pixel */
          write_color(&buf.pixels[i],0,255,0);
        }
        else {
          /* Blue pixel */
          write_color(&buf.pixels[i],0,0,255);
        }
      }

      /* Send the data to the TCL lighting strand */
      if(send_buffer(fd,&buf)<0) {
        fprintf(stderr, "Error sending data.\n");
        exit(1);
      }

      /* Sleep for 1 second */
      usleep(1000000);
    }
  }

  /* Although the program never gets to this point, below is how to clean up */

  /* Free the pixel buffer */
  tcl_free(&buf);

  /* Close the SPI device */
  close(fd);

  return 0;
}
