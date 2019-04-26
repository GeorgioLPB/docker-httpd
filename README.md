# The Apache HTTP Server container with ModSecurity, OWASP ModSecurity Core Rule Set (CRS) and GeoIP2 MAXMIND

The [Apache HTTP Server Project](http://httpd.apache.org/) with mod_security module from [ModSecurity](http://modsecurity.org/), [OWASP ModSecurity Core Rule Set](https://github.com/SpiderLabs/owasp-modsecurity-crs) and mod_maxminddb module from [MAXMIND](https://www.maxmind.com/) for GeoIP localisation

| Tags     | Debian         | Apache HTTP Server | ModSecurity | OWASP CRS | MAXMIND Library | MAXMIND Module |
| :------: | :------------: | -----------------: | ----------: | --------: | --------------: | -------------: |
| `2.4.39` | `stretch-slim` | `2.4.39`           | `2.9.3`     | `3.1.0`   | `1.3.2`         | `1.1.0`        |

## Supported tags and respective Dockerfile links

* [2.4.39, latest, (2.4.39/Dockerfile)](https://github.com/GeorgioLPB/docker-httpd/blob/2.4.39/Dockerfile)

## Usage

### Simple Usage

	docker run -d -p 80:80 ggregorio/httpd

### Usage with specifique uid/gid

```
docker run -d \
	-e HTTPD_USER_ID=1000 \
	-e HTTPD_GROUP_ID=1000 \
	-p 80:80 \
	ggregorio/httpd
```

## Quick reference

* Apache HTTP Server
  * [Apache HTTP Server Version 2.4 Documentation](http://httpd.apache.org/docs/2.4/)
  * [httpd Docker Official Images](https://hub.docker.com/_/httpd)
* ModSecurity mod_security
  * [ModSecurity Documentation](http://modsecurity.org/documentation.html)
  * [OWASP ModSecurity Core Rule Set (CRS)](https://github.com/SpiderLabs/owasp-modsecurity-crs)
* MAXMIND mod_maxminddb
  * [MaxMind DB Apache Module](http://maxmind.github.io/mod_maxminddb/)
  * [GitHub maxmind / mod_maxminddb](https://github.com/maxmind/mod_maxminddb)

## Configuration (environment variables)

| Environment variable | Default value | Description                                             |
| :------------------- | ------------: | :------------------------------------------------------ |
| `HTTPD_USER_ID`      | 33            | The userid under which the server will answer requests. |
| `HTTPD_GROUP_ID`     | 33            | Group under which the server will answer requests.      |
