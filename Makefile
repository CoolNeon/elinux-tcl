CFLAGS = -O3
CC = gcc
BUNDLE = Makefile tclled.h tclled.c tcl_speedtest.c blink_test.c simple_example.c
VERSION = 1.0
ARCHIVE = elinux-tcl
LIBS = -lm

all: tcl_speedtest blink_test simple_example

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

simple_example.o: tclled.h simple_example.c

simple_example: simple_example.o tclled.o
	$(CC) $(CFLAGS) $(LIBS) -o $@ $^

tclled.o: tclled.h tclled.c
