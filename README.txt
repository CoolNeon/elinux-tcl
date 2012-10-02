Total Control Lighting (p9813) BeagleBone library
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

The BeagleBone's processor has built-in support for SPI, making it very fast.
In order to use this capability from userspace linux programs, you must use a
linux kernel with the spidev module built in. The Angstrom linux BeagleBone
demo image (available at
http://downloads.angstrom-distribution.org/demo/beaglebone/) starting with the
June 18, 2012 image have spidev compiled in. I have done my testing with the
June 18, 2012 image available at
http://downloads.angstrom-distribution.org/demo/beaglebone/archive/Angstrom-Cloud9-IDE-GNOME-eglibc-ipk-v2012.05-beaglebone-2012.06.18.img.xz

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

LIBRARY



