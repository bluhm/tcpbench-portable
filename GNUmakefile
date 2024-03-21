CFLAGS+=	-D_DEFAULT_SOURCE -D_GNU_SOURCE -Wall \
		$(shell pkgconf --cflags libbsd-overlay)
LDFLAGS+=	-levent -lm \
		$(shell pkgconf --libs libbsd-overlay)
BINDIR?=        /usr/local/bin
MANDIR?=        /usr/local/man/man

.PHONY: all clean install
all:	tcpbench

tcpbench: tcpbench.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $< $(LDFLAGS) -o $@

clean:
	rm -f tcpbench tcpbench.o out

install:
	install -c -m 555 -s tcpbench -D -t ${DESTDIR}${BINDIR}
	install -c -m 444 tcpbench.1 -D -t ${DESTDIR}${MANDIR}1

.PHONY: test test-localhost test-localhost6
test: test-localhost test-localhost6

test-localhost:
	@echo -e '\n==== $@ ===='
	./tcpbench -s -4 >out & \
	    trap "kill -TERM $$!" EXIT; \
	    sleep 1; \
	    ./tcpbench -t2 127.0.0.1 || exit 1; \
	    true
	grep '^Conn:' out

test-localhost6:
	@echo -e '\n==== $@ ===='
	./tcpbench -s -6 >out & \
	    trap "kill -TERM $$!" EXIT; \
	    sleep 1; \
	    ./tcpbench -t2 ::1 || exit 1; \
	    true
	grep '^Conn:' out
