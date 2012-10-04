Total Control Lighting (p9813) Embedded Linux Library
Copyright 2012 Christopher De Vries
www.idolstarastronomer.com

INTRODUCTION

This library is designed to help you get started using the Total Control
Lighting RGB LED pixels from www.coolneon.com on your BeagleBone.
This library should work on any linux platform in which the spidev kernel
module has been included.

BACKGROUND

The p9813 chip operates with a voltage between 5V and 6.5V. In addition to V+
and Ground inputs, the chip also has a clock input, serial data input, clock
output, and serial data output. The p9813 chip has a maximum serial clock rate
of 15 MHz. 

The p9813 accepts data from the Serial Data in on the rising edge of the
serial input clock signal. It will read one bit per tick. A frame of 4 bytes
(32 bits) is required to set the pixel color. Each byte is sent on MSB order.
The first byte is a flag byte, the second byte is the blue data, the third is
green, and the fourth is red. Each color is represented as an 8 bit unsigned
integer running from 0 (completely off) to 255 (completely on). The flag byte
is made up of the following bits (from highest order, or most significant,
down):

Bit 7: Always 1
Bit 6: Always 1
Bit 5: Inverse of blue bit 7
Bit 4: Inverse of blue bit 6
Bit 3: Inverse of green bit 7
Bit 2: Inverse of green bit 6
Bit 1: Inverse of red bit 7
Bit 0: Inverse of red bit 6

As an example, the following sample of C code calculates the flag bit (this is
included in the library):

    uint8_t make_flag(uint8_t red, uint8_t green, uint8_t blue) {
      uint8_t flag;

      flag =  (red&0xc0)>>6;
      flag |= (green&0xc0)>>4;
      flag |= (blue&0xc0)>>2;

      return ~flag;
    }

Once a pixel's color is set, it will pass along subsequent 32 bit frames via
its clock out and serial data out ports. 

To initialize a p9813 chip to receive a new color you must send a frame
composed entirely of 0s (32 bits of 0s). In order to display the colors you
have sent to a chip, you must also send a frame of 32 bits of 0s. It appears
as though you actually must send more than one frame of 0s if the chain of
pixels is long. This library will send 1 frame of 0s to initialize the chip
prior to sending out pixel data and 2 frames of 0s to display the pixels
after.

The BeagleBone and Raspberri PI have processors with built-in support for SPI,
making it very fast.  In order to use this capability from userspace linux
programs, you must use a linux kernel with the spidev module built in. The
Angstrom linux BeagleBone demo image (available at
http://downloads.angstrom-distribution.org/demo/beaglebone/) starting with the
June 18, 2012 image have spidev compiled in. I have done my testing with the
June 18, 2012 image available at
http://downloads.angstrom-distribution.org/demo/beaglebone/archive/Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.05-beaglebone-2012.06.18.img.xz
You can find more information about installing the SPI drivers on your
Raspberry Pi by reading this entry in the Brian's Life blog:
http://www.brianhensley.net/2012/07/getting-spi-working-on-raspberry-pi.html .

HARDWARE

The Total Control Lighting pixel strands, sold by coolneon.com, have 4 wires
running from pixel to pixel. These wires are color coded in the following way:

Red: Vcc (+5 to +6.5 V)
White: Data
Green: Clock
Blue: Ground

Each pixel has an input set of wires and an output set. Usually there is an
arrow indicating the direction on the casing of the LED/chip unit. It is more
convenient to use the connectors which you can purchase from coolneon.com. You
will need the female connector to send data to the pixels. The wire coloring
on the connector is slightly different:

Red: Vcc (+5 to +6.5 V)
Green: Data
Yellow: Clock
Blue (or Black): Ground

It is useful, though not required, to purchase the "T-connectors" sold at
coolneon.com. The T-connectors pass through the Data and Clock lines, but
splice the Vcc and Ground lines to a 2.5mm center positive barrel connector.
We typically find that we provide power by using a T-connector every 100
pixels or so (depending on the application). 

BEAGLEBONE CONNECTIONS

On the BeagleBone the following pins are configured for SPI:

P9 Header Pin 30: Data out (SPI1_D1)
P9 Header Pin 31: Clock out (SPI1_SCLK)

You should also hook up a ground wire from the pixels and the power supply for
the pixels to P9 Header Pin 1 or 2. A typical wiring diagram is shown below:


+-----------------------------+
|                         5 V +---------+
| Pixel Power Source          |         |
|                         GND +----+    |
+-----------------------------+    |    |
                                   |    |     +-----------------------------+
+-----------------------------+    |    +-----+ V+                          |
+                   P9 Pin 1  +----+----------+ GND        TCL Pixel        |
+ BeagleBone        P9 Pin 30 +---------------+ Data                        |
+                   P9 Pin 31 +---------------+ Clock                       |
+-----------------------------+               +-----------------------------+

RASPBERRY PI CONNECTIONS

On the Raspberry PI the following pins are configured for SPI:

Pin 19: Data out (SP10 MOSI)
Pin 23: Clock out (SP10 SCLK)

You should also hook up a ground wire from the pixels and the power supply for
the pixels and connect it to Pin 6 so the Raspberry Pi and the pixels share a
common ground. A typical wiring diagram is shown below:

+-----------------------------+
|                         5 V +---------+
| Pixel Power Source          |         |
|                         GND +----+    |
+-----------------------------+    |    |
                                   |    |     +-----------------------------+
+-----------------------------+    |    +-----+ V+                          |
+                      Pin 6  +----+----------+ GND        TCL Pixel        |
+ Raspberry Pi         Pin 19 +---------------+ Data                        |
+                      Pin 23 +---------------+ Clock                       |
+-----------------------------+               +-----------------------------+

LIBRARY

This library is written in ANSI C, and I will demonstrate how to use it by
creating a simple program below.  To use the C library, you first need to
include several header files, including "tclled.h" for this library, and
"fcntl.h" and "unistd.h" for low level I/O. To run the examples below you will
also need to include "stdio.h". Include all the header files like so:

    #include "tclled.h"
    #include <fcntl.h>
    #include <unistd.h>
    #include <stdio.h>

Within the program, you will want to open the spidev device using low-level
I/O, and initiate the SPI bus. In this example I use "/dev/spidev2.0" as the
device, which is typical on the BeagleBone. For the Raspberry Pi this is
typically "/dev/spidev0.0". Initialization can be accomplished using the code
below.

    int fd;  /* SPI device file descriptor */

    /* Open SPI device */
    fd = open("/dev/spidev2.0",O_WRONLY);
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

Next create a buffer for your pixel color and flag values. I will assume there
are 50 LEDs in our Total Control Lighting strand for the example below.

    const int leds = 50; /* 50 LEDs in the strand */
    tcl_buffer buf;      /* Memory buffer for pixel values */

    /* Allocate memory for the pixel buffer and initialize it */
    if(tcl_init(&buf,leds)<0) {
        /* Memory allocation failed */
        fprintf(stderr, "Insufficient memory for pixel buffer.\n");
        exit(1);
    }

After creating the pixel buffer, you can then start writing to it. There are
two options. You can send raw pixel colors to the TCL strands using the
"write_color" function. This function accepts red, green, and blue colors as
uint8_t integers in the range of 0 to 255. Unfortunately a color of 127 for
any of the LED colors does not appear to be half as bright as 255. It is in
fact much brighter to our eyes. Therefore, you can also use the
"write_gamma_color" function which will apply a gamma correction for each
color that you establish using the "set_gamma" function. Both the
"write_color" and "write_gamma_color" functions accept four arguments. The
first is a pointer to a tcl_color structure. The second is a uint8_t integer
that represents red, the third is a uint8_t integer representing green, and
the fourth is a uint8_t integer representing blue. To set the 24th pixel in a
strand to solid bright blue, I could use the following code:

    write_color(&buf.pixels[24],0,0,255);

If I wanted to apply gamma correction to that pixel, and set it to about 1/2
brightness green. I would use the following code:

    write_gamma_color(&buf.pixels[24],0,127,0);

Note that before using the "write_gamma_color" function you must set the gamma
correction factors. They can be set differently for each LED color. Values
betwen 2.2 and 3.0 appear to work best. The "set_gamma" function takes three
double precision floating point values as arguments. The red gamma correction
facor is first, followed by the green and then the blue factor. To set all
colors to a gamma correction of 2.2 I would use the following code:

    set_gamma(2.2,2.2,2.2);

The gamma correction function sets up a lookup table so that each
"write_gamma_color" will be fast.

Finally, you must send the data over the SPI bus to the pixels. To do this you
use the function "send_buffer", which takes two arguments. The file descriptor
and a pointer to the tcl_buffer structure. The send_buffer function will
always either send all the data in the buffer (and return the number of bytes
sent) or return a negative integer when an error occurs. Sending the data can
in the tcl_buffer buf can be accomplished with the code below.

    /* Send the data to the TCL lighting strand */
    if(send_buffer(fd,&buf)<0) {
        fprintf(stderr, "Error sending data.\n");
        exit(1);
    }

When you are finished using the pixels you should free up the allocated memory
in the tcl_buffer structure and close the file description. This can be
accomplished with the code below.

    /* Free the pixel buffer */
    tcl_free(&buf);

    /* Close the SPI device */
    close(fd);

COMPILING

The code compiles with the gcc compiler available on each platform. Note that
you must include the math library ( -lm ) when compiling because the gamma
correction subroutine makes use of it. Feel free to look at the included
Makefile for information about compiling the code. You must compile the
following files along with your source code:

tclled.h - The library header file.
tclled.c - The library source code.

ADDITIONAL RESOURCES

Additional documentation for the individual functions can be found in the
tclled.h header file. There are also a few sample programs:

1. simple_example.c - This runs through a simple example setting the lights to
be red, green, and blue and cycling through those colors with one color change
a second. 

2. blink_test.c - This is a code which blinks random gamma corrected colors at
random intervals all along the strand.

3. tcl_speedtest.c - This sample program sends 10,000 images (of a single blue
moving along a strand) to a strand of 1,250 pixels as fast as it can. It
measures the time elapsed and calculates the number of frames per second.
