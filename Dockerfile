from centos:7.2.1511
maintainer By:liuwei "al6008@163.com"
run yum install -y net-tools make gcc-c++ autoconf openssl openssl-devel openldap-clients curl iproute &&\
	yum install -y bzip2-devel libjpeg-devel freetype-devel libpng-devel  curl-devel pcre-devel  zlib-devel libxml2 && \
	yum install -y gcc-c++ net-snmp-devel curl-devel libxml2-devel mariadb-devel mysql-devel &&\
	yum install -y kde-l10n-Chinese && yum -y reinstall glibc-common &&\
	yum install -y openldap-devel &&\
	localedef -c -f UTF-8 -i zh_CN zh_CN.utf8 &&\
	export LC_ALL=zh_CN.utf8 &&\
    yum clean all

env LC_ALL zh_CN.utf8

run cd /tmp &&\
	curl -O http://119.254.97.233:65523/openldap/aaa/zabbix/mhash-0.9.9.9.tar.gz &&\
	tar xf mhash-0.9.9.9.tar.gz &&\
	cd mhash-0.9.9.9 &&\
	./configure &&make -j &&make -j install &&\
	cd / && rm -rf /tmp/*

run cd /tmp &&\
	curl -O http://119.254.97.233:65523/openldap/aaa/zabbix/libmcrypt-2.5.8.tar.gz &&\
	tar xf libmcrypt-2.5.8.tar.gz &&\
	cd libmcrypt-2.5.8 &&\
	./configure &&make -j &&make -j install &&\
	cd / && rm -rf /tmp/*
run cd /tmp &&\
	yum install -y  libxml2 libxml2-devel &&\
	echo '/usr/local/lib64' >>/etc/ld.so.conf &&\
	echo '/usr/local/lib' >>/etc/ld.so.conf &&\
	echo '/usr/lib' >>/etc/ld.so.conf &&\
	echo '/usr/lib64' >>/etc/ld.so.conf &&\
	source /etc/profile&&ldconfig -v &&\
	curl -O http://cn2.php.net/distributions/php-5.6.32.tar.gz &&\
	tar xf php-5.6.32.tar.gz &&\
	cd php-5.6.32/ &&\
	cp -frp /usr/lib64/libldap* /usr/lib/ &&\
	./configure --prefix=/usr/local/php5.6.32 --with-mysql=mysqlnd --with-pdo-mysql=mysqlnd --with-mysqli=mysqlnd --with-openssl --with-gettext --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir --with-mcrypt --with-bz2 --with-zlib-dir --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --enable-opcache=no --enable-mbstring --enable-xml --enable-sockets --enable-fpm --with-curl --enable-bcmath --with-gd --disable-ipv6 --disable-rpath --disable-debug  --enable-zip  && \
	make -j &&make -j install &&\
	ln -s /usr/local/php5.6.32 /usr/local/php &&\
	cp php.ini-production /etc/php.ini &&\
	cp sapi/fpm/init.d.php-fpm /etc/rc.d/init.d/php-fpm &&\
	chmod +x /etc/rc.d/init.d/php-fpm &&\
	cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf &&\
	sed -i "s@listen = 127.0.0.1:9000@listen = 0.0.0.0:9000@g" /usr/local/php/etc/php-fpm.conf &&\
	sed -i "/^listen/alisten = /dev/shm/php-cgi.sock" /usr/local/php/etc/php-fpm.conf &&\
	sed -i "s@user = nobody@user = nginx@g" /usr/local/php/etc/php-fpm.conf &&\
	sed -i "s@group = nobody@group = nginx@g" /usr/local/php/etc/php-fpm.conf &&\
	sed -i "s@;listen.owner = nobody@listen.owner = nginx@g" /usr/local/php/etc/php-fpm.conf &&\
	sed -i "s@;listen.group = nobody@listen.group = nginx@g" /usr/local/php/etc/php-fpm.conf &&\
	useradd -s /sbin/nologin nginx &&\
	cd /tmp/php-5.6.32/ext/ldap/ &&\
	/usr/local/php/bin/phpize &&\
	./configure --with-php-config=/usr/local/php/bin/php-config &&\
	make -j &&make -j install &&\
        echo 'extension=/usr/local/php5.6.32/lib/php/extensions/no-debug-non-zts-20131226/ldap.so' >>/etc/php.ini &&\
	cd / && rm -rf /tmp/* && yum clean all

run cd /tmp &&\
    curl -O http://nginx.org/download/nginx-1.12.2.tar.gz&&\
    tar xf nginx-1.12.2.tar.gz &&\
    cd  nginx-1.12.2 &&\
    ./configure --prefix=/usr/local/nginx-1.12.2 --sbin-path=/sbin/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log  --error-log-path=/var/log/nginx/error.log  --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --user=nginx --group=nginx --with-stream=dynamic --with-http_ssl_module --without-mail_pop3_module --without-mail_imap_module --without-mail_smtp_module --without-select_module --without-http_uwsgi_module --without-http_scgi_module --without-http_uwsgi_module &&\
	make -j &&make -j install &&\
	mkdir /var/www/ -p &&\
	mkdir -p /var/lib/nginx/body &&\
	mkdir -p /etc/nginx/conf.d &&\
	ln -sf /usr/local/nginx-1.12.2 /usr/local/nginx &&\
	ln -sf /usr/local/nginx-1.12.2/html /var/www &&\
	chown nginx:nginx -R /var/lib/nginx/body &&\ 
    	cd / && rm -rf /tmp/*

run cd /tmp &&\
	curl -O http://xcache.lighttpd.net/pub/Releases/3.2.0/xcache-3.2.0.tar.gz &&\
	tar xf xcache-3.2.0.tar.gz &&\
	cd xcache-3.2.0 &&\
	/usr/local/php/bin/phpize &&\
	./configure --enable-xcache --with-php-config=/usr/local/php/bin/php-config &&\
	make -j &&make -j install &&\
	mkdir -p /etc/php.d &&\
	cp xcache.ini /etc/php.d/ &&\
	sed -i "s@^extension = xcache.so@extension = /usr/local/php/lib/php/extensions/no-debug-non-zts-20131226/xcache.so@g" /etc/php.d/xcache.ini &&\
	sed -i '$a\xcache.admin.user = "admin"' /etc/php.d/xcache.ini &&\
	sed -i '$a\xcache.admin.pass = "21232f297a57a5a743894a0e4a801fc3"' /etc/php.d/xcache.ini &&\
	cp -r htdocs /usr/local/nginx/html/xcache  &&\
	sed -i 's@;date.timezone =@date.timezone = Asia/Shanghai@g' /etc/php.ini &&\
	cd / && rm -rf /tmp/*

#zabbix
add zabbix-3.0.14.tar.gz /
copy zabbix-3.0.14.tar.gz /zabbix-3.0.14.tar.gz
copy install.sh /install.sh
add simkai.ttf /zabbix-3.0.14
run cd /zabbix-3.0.14 &&\
	./configure --enable-server --enable-agent  --with-mysql --with-net-snmp --with-libcurl --with-libxml2 &&\
	make -j &&make install &&\ 
	yum install -y mysql

#微信报警
add simplejson-3.8.2.tar.gz /
add wechat.py /
run cd /simplejson-3.8.2 &&\
	python setup.py install

#nginx 
workdir /usr/local/nginx/html
add nginx.conf /etc/nginx/nginx.conf
add zabbix.conf /etc/nginx/conf.d/zabbix.conf
add run.sh /run.sh
cmd ["/bin/bash","/run.sh"]
