PROG=		tcpbench
WARNINGS=	yes
LDADD=		-lm -levent -ltls -lcrypto
DPADD=		${LIBM} ${LIBEVENT} ${LIBTLS} ${LIBCRYPTO}
BINDIR?=	/usr/local/bin
MANDIR?=	/usr/local/man/man

VERSION=	3.00
CLEANFILES=	tcpbench-${VERSION}.tar.gz*

.PHONY: dist tcpbench-${VERSION}.tar.gz
dist: tcpbench-${VERSION}.tar.gz
	gpg --armor --detach-sign tcpbench-${VERSION}.tar.gz
	@echo ${.OBJDIR}/tcpbench-${VERSION}.tar.gz

tcpbench-${VERSION}.tar.gz:
	rm -rf tcpbench-${VERSION}
	mkdir tcpbench-${VERSION}
.for f in README LICENSE Changes Makefile GNUmakefile tcpbench.c tcpbench.1
	cp ${.CURDIR}/$f tcpbench-${VERSION}/
.endfor
	tar -czvf $@ tcpbench-${VERSION}
	rm -rf tcpbench-${VERSION}

CLEANFILES+=	out *.crt *.key *.req *.srl

.PHONY: test test-localhost test-localhost6 test-tls test-ciphers
test: test-localhost test-localhost6 test-tls test-ciphers

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

.include <bsd.prog.mk>
