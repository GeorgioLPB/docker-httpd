FROM httpd:2.4.41
#
# http://httpd.apache.org/
# https://hub.docker.com/_/httpd
# http://modsecurity.org/download.html
# https://github.com/SpiderLabs/owasp-modsecurity-crs/releases
#
LABEL \
	maintainer georges.gregorio@gmail.com

ENV \
	MODSECURITY="2.9.3" \
	MAXMIND_LIB="1.4.2" \
	MAXMIND_MOD="1.1.0"

ADD https://www.modsecurity.org/tarball/2.9.3/modsecurity-2.9.3.tar.gz /tmp/
ADD https://github.com/maxmind/libmaxminddb/releases/download/1.4.2/libmaxminddb-1.4.2.tar.gz /tmp/
ADD https://github.com/maxmind/mod_maxminddb/releases/download/1.1.0/mod_maxminddb-1.1.0.tar.gz /tmp/

RUN set -eux;\
	#
	# Installation des outils de compilation
	#
	apt-get update && apt-get install -y --no-install-recommends \
		gcc make libtool autoconf automake libpcre3-dev libxml2-dev libcurl4-openssl-dev && \
	#
	# Install mod_security2
	#
	tar -zxf "/tmp/modsecurity-${MODSECURITY}.tar.gz" -C /tmp/ && \
	cd "/tmp/modsecurity-${MODSECURITY}" && \
	export CFLAGS="-fstack-protector-strong -fpic -O2" && \
	export CPPFLAGS="${CFLAGS}" && \
	export LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu" && \
	./autogen.sh && \
	./configure --prefix=/opt/modsecurity --disable-dependency-tracking && \
	make -j $(nproc) && \
	make test && \
	make install && \
	cp modsecurity.conf-recommended /usr/local/apache2/conf/modsecurity.conf && \
	chmod 644 /usr/local/apache2/conf/modsecurity.conf && \
	#
	# Install libmaxminddb
	#
	tar -zxf "/tmp/libmaxminddb-${MAXMIND_LIB}.tar.gz" -C /tmp/ && \
	cd "/tmp/libmaxminddb-${MAXMIND_LIB}" && \
	export CFLAGS="-fstack-protector-strong -fpic -O2" && \
	export CPPFLAGS="${CFLAGS}" && \
	export LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu" && \
	./configure --prefix="/opt/libmaxminddb" && \
	make -j $(nproc) && \
	make install && \
	#
	# Install mod_maxminddb
	#
	tar -zxf "/tmp/mod_maxminddb-${MAXMIND_MOD}.tar.gz" -C /tmp/ && \
	cd "/tmp/mod_maxminddb-${MAXMIND_MOD}" && \
	export CFLAGS="-fstack-protector-strong -fpic -O2 -I/opt/libmaxminddb/include" && \
	export CPPFLAGS="${CFLAGS}" && \
	export LDFLAGS="-Wl,-O2 -Wl,--hash-style=gnu -L/opt/libmaxminddb/lib" && \
	./configure --prefix="/opt/libmaxminddb" && \
	make -j $(nproc) && \
	make install && \
	#
	# Suppression des outils de compilation
	#
	unset CFLAGS CPPFLAGS LDFLAGS && \
	apt-get remove -y gcc make libtool autoconf automake libpcre3-dev libxml2-dev libcurl4-openssl-dev && \
	apt-get autoremove -y && \
	rm -r /var/lib/apt/lists/* && \
	rm -rf /tmp/modsecurity* /tmp/libmaxminddb* /tmp/mod_maxminddb*

