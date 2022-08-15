PROG=		tcpbench
WARNINGS=	yes
LDADD=		-levent
DPADD=		${LIBEVENT}
BINDIR?=	/usr/local/bin
MANDIR?=        /usr/local/man/man

VERSION=	1.02
CLEANFILES=	tcpbench-${VERSION}.tar.gz

.PHONY: dist tcpbench-${VERSION}.tar.gz
dist: tcpbench-${VERSION}.tar.gz
	@echo ${.OBJDIR}/tcpbench-${VERSION}.tar.gz

tcpbench-${VERSION}.tar.gz:
	rm -rf tcpbench-${VERSION}
	mkdir tcpbench-${VERSION}
.for f in README LICENSE Changes Makefile GNUmakefile tcpbench.c tcpbench.1
	cp ${.CURDIR}/$f tcpbench-${VERSION}/
.endfor
	tar -czvf $@ tcpbench-${VERSION}
	rm -rf tcpbench-${VERSION}

CLEANFILES+=	out

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

.include <bsd.prog.mk>
