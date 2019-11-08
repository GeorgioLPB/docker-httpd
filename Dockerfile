FROM httpd:2.4.41
#
# http://httpd.apache.org/
# https://hub.docker.com/_/httpd
# https://github.com/maxmind/libmaxminddb/releases
# https://github.com/maxmind/mod_maxminddb/releases
# http://modsecurity.org/download.html
# https://github.com/SpiderLabs/owasp-modsecurity-crs/releases
#
LABEL \
	httpd 2.4.41 \
	maintainer georges.gregorio@gmail.com

ENV \
	MAXMIND_LIB="1.4.2" \
	MAXMIND_MOD="1.1.0" \
	MAXMIND_DATABASE_URL="https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz" \
	MODSECURITY="2.9.3" \
	MODSECURITY_URL="https://www.modsecurity.org/tarball/2.9.3/modsecurity-2.9.3.tar.gz" \
	MODSECURITY_SHA256="4192019d169d3f1dd82cc4714db6986df54c6ceb4ee1c8f253de78d1a6b62118" \
	OWASP_MODSECURITY_CRS="3.2.0" \
	OWASP_MODSECURITY_CRS_URL="https://github.com/SpiderLabs/owasp-modsecurity-crs/archive/v3.2.0.tar.gz" \
	HTTPD_USER_ID="33" \
	HTTPD_GROUP_ID="33"

RUN set -eux;\
	#
	# Installation des outils de compilation
	#
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates wget pkg-config dpkg-dev gcc g++ cpp make libtool autoconf \
		libpcre3-dev libxml2-dev libyajl-dev \
		libcurl4-openssl-dev liblua5.2-dev \
		\
		&& rm -r /var/lib/apt/lists/* && \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
	#
	# Install libmaxminddb
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
		./configure --prefix="/opt/libmaxminddb" && \
		make -j $(nproc) && \
		make install && \
		chown -R root:root "/opt/libmaxminddb" && \
		chmod -R u=rwX,g=rX,o=rX "/opt/libmaxminddb" && \
		unset CFLAGS CPPFLAGS LDFLAGS && \
		rm -rf /var/install/* && \
	#
	# Install mod_maxminddb
	#
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
	# Install mod_security2
	#
	mkdir -p '/var/install' && \
		cd '/var/install' && \
		wget -O "modsecurity-${MODSECURITY}.tar.gz" "${MODSECURITY_URL}" && \
		echo "${MODSECURITY_SHA256} *modsecurity-${MODSECURITY}.tar.gz" | sha256sum -c && \
		tar -zxvf "modsecurity-${MODSECURITY}.tar.gz" && \
		cd "modsecurity-${MODSECURITY}" && \
		export CFLAGS="-fstack-protector-strong -fpic -O2" && \
		export CPPFLAGS="${CFLAGS}" && \
		export LDFLAGS="-Wl,-O1 -Wl,--hash-style=gnu" && \
		./configure --prefix="/opt/modsecurity" \
			--enable-pcre-jit \
			--enable-lua-cache \
			--enable-request-early \
			--enable-htaccess-config && \
		make -j $(nproc) && \
		make install && \
		chown -R root:root '/opt/modsecurity' && \
		chmod -R u=rwX,g=rX,o=rX '/opt/modsecurity' && \
		unset CFLAGS CPPFLAGS LDFLAGS && \
		rm -rf /var/install/* && \
	#
	# Install owasp-modsecurity-crs
	#
	cd '/usr/local/apache2/conf' && \
		wget -O "owasp-modsecurity-crs-${OWASP_MODSECURITY_CRS}.tar.gz" "${OWASP_MODSECURITY_CRS_URL}" && \
		tar -zxvf "owasp-modsecurity-crs-${OWASP_MODSECURITY_CRS}.tar.gz" && \
		mv -vf "owasp-modsecurity-crs-${OWASP_MODSECURITY_CRS}" "owasp-modsecurity-crs" && \
		rm -vf "owasp-modsecurity-crs-${OWASP_MODSECURITY_CRS}.tar.gz" && \
		chown -R root:root "owasp-modsecurity-crs" && \
		chmod -R u=rwX,g=rX,o=rX "owasp-modsecurity-crs" && \
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
	find /usr/local -type f -executable -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' | sort -u \
		| xargs -r dpkg-query --search | cut -d: -f1 | sort -u \
		| xargs -r apt-mark manual; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	apt-get update && \
	apt-get install -y --no-install-recommends ca-certificates wget libyajl2 && \
	rm -r /var/lib/apt/lists/*;

ADD bin/ /usr/local/apache2/bin/

EXPOSE 80/tcp 443/tcp

CMD ["httpd-foreground"]
