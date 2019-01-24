all: tcpbench

tcpbench.o: tcpbench.c
	cc -O2 -Wall -Wno-unused-variable -D_GNU_SOURCE -I/usr/include -I/usr/local/include -lbsd -levent -c tcpbench.c

tcpbench: tcpbench.o
	cc -L/usr/local/lib -lbsd -levent -Wl,-rpath /usr/local/lib tcpbench.o -o tcpbench

install:
	install -m 555 -s tcpbench /usr/local/bin/
	install -m 444 tcpbench.1 /usr/local/man/man1/

clean:
	rm -f tcpbench.o tcpbench
