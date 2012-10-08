CFLAGS = -O3
CC = gcc
BUNDLE = Makefile README.txt LICENSE.txt tclled.h tclled.c tcl_speedtest.c blink_test.c simple_example.c blink_hsv.c rainbows.c
VERSION = 1.1
ARCHIVE = elinux-tcl
LIBS = -lm

all: tcl_speedtest blink_test simple_example blink_hsv rainbows

archive: $(BUNDLE)
	mkdir $(ARCHIVE)-$(VERSION)
	cp $(BUNDLE) $(ARCHIVE)-$(VERSION)/
	tar cvfz $(ARCHIVE)-$(VERSION).tar.gz $(ARCHIVE)-$(VERSION)
	rm -rf $(ARCHIVE)-$(VERSION)

clean:
	$(RM) *.o
	$(RM) $(ARCHIVE)-$(VERSION).tar.gz

tcl_speedtest: tcl_speedtest.o tclled.o
	$(CC) $(CFLAGS) $(LIBS) -o $@ $^

tcl_speedtest.o: tclled.h tcl_speedtest.c

blink_test.o: tclled.h blink_test.c

blink_test: blink_test.o tclled.o
	$(CC) $(CFLAGS) $(LIBS) -o $@ $^

blink_hsv.o: tclled.h blink_hsv.c

blink_hsv: blink_hsv.o tclled.o
	$(CC) $(CFLAGS) $(LIBS) -o $@ $^

simple_example.o: tclled.h simple_example.c

simple_example: simple_example.o tclled.o
	$(CC) $(CFLAGS) $(LIBS) -o $@ $^

rainbows.o: tclled.h rainbows.c

rainbows: rainbows.o tclled.o
	$(CC) $(CFLAGS) $(LIBS) -o $@ $^

tclled.o: tclled.h tclled.c
