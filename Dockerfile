FROM httpd:2.4.39
#
# http://httpd.apache.org/
# https://hub.docker.com/_/httpd
#
LABEL \
	httpd 2.4.39 \
	maintainer georges.gregorio@gmail.com

ENV \
	MAXMIND_LIB="1.3.2" \
	MAXMIND_MOD="1.1.0" \
	HTTPD_USER_ID="33" \
	HTTPD_GROUP_ID="33"

RUN set -eux;\
	#
	# Installation des outils de compilation
	#
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates wget pkg-config dpkg-dev gcc g++ cpp make libtool autoconf \
		\
		&& rm -r /var/lib/apt/lists/* && \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
	#
	# Installation de module mod_maxminddb
	#
	mkdir -p '/var/install' && \
		cd '/var/install' && \
		wget -O "libmaxminddb-${MAXMIND_LIB}.tar.gz" \
			"https://github.com/maxmind/libmaxminddb/releases/download/${MAXMIND_LIB}/libmaxminddb-${MAXMIND_LIB}.tar.gz" && \
		tar -zxvf "libmaxminddb-${MAXMIND_LIB}.tar.gz" && \
		cd "libmaxminddb-${MAXMIND_LIB}" && \
		export CFLAGS="-fstack-protector-strong -fpic -O2" && \
		export CPPFLAGS="${CFLAGS}" && \
		export LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu" && \
		./configure --prefix="/opt/libmaxminddb-${MAXMIND_LIB}" && \
		make -j $(nproc) && \
		make install && \
		chown -R root:root "/opt/libmaxminddb-${MAXMIND_LIB}" && \
		chmod -R u=rwX,g=rX,o=rX "/opt/libmaxminddb-${MAXMIND_LIB}" && \
		cd "/opt" && \
		ln -sn "libmaxminddb-${MAXMIND_LIB}" "libmaxminddb" && \
		unset CFLAGS CPPFLAGS LDFLAGS && \
		rm -rf /var/install/* && \
	mkdir -p '/var/install' && \
		cd '/var/install' && \
		wget -O "mod_maxminddb-${MAXMIND_MOD}.tar.gz" \
			"https://github.com/maxmind/mod_maxminddb/releases/download/${MAXMIND_MOD}/mod_maxminddb-${MAXMIND_MOD}.tar.gz" && \
		tar -zxvf "mod_maxminddb-${MAXMIND_MOD}.tar.gz" && \
		cd "mod_maxminddb-${MAXMIND_MOD}" && \
		export CFLAGS="-fstack-protector-strong -I/opt/libmaxminddb/include -O2" && \
		export CPPFLAGS="${CFLAGS}" && \
		export LDFLAGS="-Wl,-O2 -Wl,--hash-style=gnu -L/opt/libmaxminddb/lib" && \
		./configure --with-apxs='/usr/local/apache2/bin/apxs' && \
		make -j $(nproc) && \
		make install && \
		chown root:root '/usr/local/apache2/modules/mod_maxminddb.so' && \
		chmod 644 '/usr/local/apache2/modules/mod_maxminddb.so' && \
		unset CFLAGS CPPFLAGS LDFLAGS && \
		rm -rf /var/install/* && \
	#
	# Configuration du user par defaut
	#
	sed -i "s|^User daemon$|User www-data|g" /usr/local/apache2/conf/httpd.conf && \
	sed -i "s|^Group daemon$|Group www-data|g" /usr/local/apache2/conf/httpd.conf && \
	#
	# Suppression des outils de compilation
	#
	apt-mark auto '.*' > /dev/null && \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark && \
	#find /usr/local -type f -executable -exec ldd '{}' ';' \
	#	| awk '/=>/ { print $(NF-1) }' | sort -u \
	#	| xargs -r dpkg-query --search | cut -d: -f1 | sort -u \
	#	| xargs -r apt-mark manual; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false;

COPY httpd-foreground /usr/local/bin/

EXPOSE 80/tcp

#CMD [ "/usr/local/apache2/bin/httpd", "-f", "/appli/apache/https/conf/httpd.conf", "-DFOREGROUND" ]
#CMD [ "/bin/bash" ]
CMD ["httpd-foreground"]
