CFLAGS=		-D_DEFAULT_SOURCE -D_GNU_SOURCE \
		-DLIBBSD_OVERLAY -isystem /usr/include/bsd \
		-isystem /usr/local/include/bsd \
		-Wall
# On Debian libbsd-dev and libev-libevent-dev have to be installed.
# If an old libevent 1.4 exists on the system, use -lbsd -levent.
LDFLAGS=	-lbsd -lev
BINDIR?=        /usr/local/bin
MANDIR?=        /usr/local/man/man

.PHONY: all clean install
all:	tcpbench

clean:
	rm -f tcpbench tcpbench.o out

install:
	install -c -m 555 -s tcpbench ${DESTDIR}${BINDIR}
	install -c -m 444 tcpbench.1 ${DESTDIR}${MANDIR}1

.PHONY: test test-localhost test-localhost6
test: test-localhost test-localhost6

test-localhost:
	@echo '\n==== $@ ===='
	./tcpbench -s -4 >out & \
	    trap "kill -TERM $$!" EXIT; \
	    sleep 1; \
	    ./tcpbench -t2 127.0.0.1 || exit 1; \
	    true
	grep '^Conn:' out

test-localhost6:
	@echo '\n==== $@ ===='
	./tcpbench -s -6 >out & \
	    trap "kill -TERM $$!" EXIT; \
	    sleep 1; \
	    ./tcpbench -t2 ::1 || exit 1; \
	    true
	grep '^Conn:' out
