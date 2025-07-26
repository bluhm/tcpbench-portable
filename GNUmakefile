CFLAGS+=	-D_DEFAULT_SOURCE -D_GNU_SOURCE -Wall \
		$(shell pkgconf --cflags libbsd-overlay) \
		$(shell pkgconf --cflags libtls)
LDFLAGS+=	-levent -lm -ltls -lcrypto \
		$(shell pkgconf --libs libbsd-overlay) \
		$(shell pkgconf --libs libtls)
BINDIR?=        /usr/local/bin
MANDIR?=        /usr/local/man/man

.PHONY: all clean install
all:	tcpbench

tcpbench: tcpbench.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $< $(LDFLAGS) -o $@

clean:
	rm -f tcpbench tcpbench.o out *.crt *.key *.req *.srl

install:
	install -c -m 555 -s tcpbench -D -t ${DESTDIR}${BINDIR}
	install -c -m 444 tcpbench.1 -D -t ${DESTDIR}${MANDIR}1

.PHONY: test test-localhost test-localhost6 test-tls test-ciphers
.NOTPARALLEL: test test-localhost test-localhost6 test-tls test-ciphers
test: test-localhost test-localhost6 test-tls test-ciphers

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

test-tls: server.crt
	@echo '\n==== $@ ===='
	./tcpbench -c -C server.crt -K server.key -s -4 >out & \
	    trap "kill -TERM $$!" EXIT; \
	    sleep 1; \
	    ./tcpbench -c -t2 127.0.0.1 || exit 1; \
	    true
	grep '^Conn:' out

test-ciphers: server.crt
	@echo '\n==== $@ ===='
	./tcpbench -T ciphers=AES128-GCM-SHA256 \
	    -c -C server.crt -K server.key -s -4 >out & \
	    trap "kill -TERM $$!" EXIT; \
	    sleep 1; \
	    ./tcpbench -T ciphers=AES128-GCM-SHA256 \
	    -c -t2 127.0.0.1 || exit 1; \
	    true
	grep '^Conn:' out

ca.crt:
	openssl req -batch -new \
	    -subj /L=OpenBSD/O=tcpbench-regress/OU=ca/CN=root/ \
	    -nodes -newkey rsa -keyout ca.key -x509 \
	    -out ca.crt

server.req:
	openssl req -batch -new \
	    -subj /L=OpenBSD/O=tcpbench-regress/OU=server/CN=localhost/ \
	    -nodes -newkey rsa -keyout server.key \
	    -out server.req

server.crt: ca.crt server.req
	openssl x509 -CAcreateserial -CAkey ca.key -CA ca.crt \
	    -req -in server.req \
	    -out server.crt
