# The Apache HTTP Server container with GeoIP2 MAXMIND

## Supported tags and respective `Dockerfile` links

| Tags     | Apache HTTP Server | MAXMIND Library | MAXMIND Module |
|:--------:|-------------------:|----------------:|---------------:|
| `latest` | `2.4.46`           |  `1.4.2`        | `1.2.0`        |


* [latest, (latest/Dockerfile)](https://github.com/GeorgioLPB/docker-httpd/blob/master/Dockerfile)

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

## What is Apache HTTP Server Project?

* The [Apache HTTP Server Project](http://httpd.apache.org/) with mod_security module from [ModSecurity](http://modsecurity.org/), [OWASP ModSecurity Core Rule Set](https://github.com/SpiderLabs/owasp-modsecurity-crs) and mod_maxminddb module from [MAXMIND](https://www.maxmind.com/) for GeoIP localisation

## How to use this image

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

### Update GeoIP2 Databases

	docker exec <container_name> update_geoip2_database

## Configuration (environment variables)

| Environment variable | Default value | Description                                             |
| :------------------- | ------------: | :------------------------------------------------------ |
| `HTTPD_USER_ID`      | 33            | The userid under which the server will answer requests. |
| `HTTPD_GROUP_ID`     | 33            | Group under which the server will answer requests.      |
