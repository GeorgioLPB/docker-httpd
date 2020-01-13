FROM httpd:2.4.41
#
# http://httpd.apache.org/
# https://hub.docker.com/_/httpd
# http://modsecurity.org/download.html
# https://github.com/SpiderLabs/owasp-modsecurity-crs/releases
# https://github.com/maxmind/libmaxminddb/releases
# https://github.com/maxmind/mod_maxminddb/releases
#
LABEL \
	maintainer georges.gregorio@gmail.com

ENV \
	MAXMIND_LIB="1.4.2" \
	MAXMIND_MOD="1.1.0"

ADD https://github.com/maxmind/libmaxminddb/releases/download/1.4.2/libmaxminddb-1.4.2.tar.gz /tmp/
ADD https://github.com/maxmind/mod_maxminddb/releases/download/1.1.0/mod_maxminddb-1.1.0.tar.gz /tmp/

RUN set -eux;\
	#
	# Installation des outils de compilation
	#
	apt-get update && apt-get install -y --no-install-recommends gcc make  && \
	export CFLAGS="-fstack-protector-strong -fpic -O2" && \
	export CPPFLAGS="${CFLAGS}" && \
	export LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu" && \
	#
	# Install libmaxminddb
	#
	tar -zxf "/tmp/libmaxminddb-${MAXMIND_LIB}.tar.gz" -C /tmp/ && \
	cd "/tmp/libmaxminddb-${MAXMIND_LIB}" && \
	./configure && \
	make -j $(nproc) && \
	make install && \
	#
	# Install mod_maxminddb
	#
	tar -zxf "/tmp/mod_maxminddb-${MAXMIND_MOD}.tar.gz" -C /tmp/ && \
	cd "/tmp/mod_maxminddb-${MAXMIND_MOD}" && \
	./configure  && \
	make -j $(nproc) && \
	make install && \
	#
	# Suppression des outils de compilation
	#
	unset CFLAGS CPPFLAGS LDFLAGS && \
	apt-get remove -y gcc make && \
	apt-get autoremove -y && \
	apt-get clean -y && \
	rm -r /var/lib/apt/lists/* && \
	rm -rf /tmp/libmaxminddb* /tmp/mod_maxminddb*
