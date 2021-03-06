FROM alpine:latest

COPY aria2.patch /aria2-master/
COPY entrypoint.sh /usr/local/bin/

RUN echo "http://dl-4.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories \
    && apk add --no-cache bash curl wget \
    && apk add --no-cache --virtual .build-deps \
    	build-base autoconf automake libtool gettext-dev git \
	    gnutls-dev expat-dev sqlite-dev c-ares-dev cppunit-dev libunistring-dev \
    && cd / \
    && curl -sSL "https://github.com/aria2/aria2/archive/master.tar.gz" | tar xz \
    && cd /aria2-master \
    && patch -p1 < aria2.patch \
    && autoreconf -i \
    && ./configure \
       --prefix=/usr \
       --sysconfdir=/etc \
       --mandir=/usr/share/man \
       --infodir=/usr/share/info \
       --localstatedir=/var \
       --disable-nls \
       --with-ca-bundle=/etc/ssl/certs/ca-certificates.crt \
    && make -j 5 && make install \
    && cd / \
    && rm -rf /aria2-master \
    && apk del .build-deps \
    && apk add --no-cache libgcc libstdc++ gnutls expat sqlite-libs c-ares \
    && chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT [ "entrypoint.sh" ]

# aria2 Options
ENV     ARIA2_PORT  "6800"
ENV     ARIA2_UP    ""
