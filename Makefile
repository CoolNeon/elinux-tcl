CFLAGS = -O3
CC = gcc
BUNDLE = Makefile tclled.h tclled.c tcl_speedtest.c 
VERSION = 0.5
ARCHIVE = beagle-tcl
LIBS = -lm

all: tcl_speedtest 

archive: $(BUNDLE)
	mkdir $(ARCHIVE)-$(VERSION)
	cp $(BUNDLE) $(ARCHIVE)-$(VERSION)/
	tar cvfz $(ARCHIVE)-$(VERSION).tar.gz $(ARCHIVE)-$(VERSION)
	rm -rf $(ARCHIVE)-$(VERSION)

clean:
	$(RM) *.o
	$(RM) $(ARCHIVE)-$(VERSION).tar.gz

tcl_speedtest: tcltest.o tclled.o
	$(CC) $(CFLAGS) $(LIBS) -o tcltest $^

tcl_speedtest.o: tclled.h tcltest.c

tclled.o: tclled.h tclled.c
