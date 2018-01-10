#!/bin/bash
#zabbix_run By:liuwei Mail:al6008@163com

#zabbixuser=admin
#zabbixpassword=adminsa
#mysqlhost=172.16.110.203
#root_pass=Arxan_Liuwei

export mysqlhost=${mysqlhost:-"172.16.110.203"}
export root_pass=${root_pass:-"Arxan_Liuwei"}
export zabbixuser=${zabbixuser:-"zabbix"}
export zabbixpassword=${zabbixpassword:-"Arxan_Liuwei"}

if [ ! -e "/etc/nginx/ssl/zabbix.crt" ];then
	mkdir -p /etc/nginx/ssl
	subject=/C=CN/ST=BeiJing/L=BeiJing/O=arxan/OU=Arxan_CA_liuwei/CN=Arxan_CA_liuwei/emailAddress=al6008@163.com
	openssl req -newkey rsa:4096 -nodes -sha256 -keyout /etc/nginx/ssl/zabbix.key -x509 -days 3650 -out /etc/nginx/ssl/zabbix.crt -subj ${subject}
fi

if [ ! -e "/etc/nginx/ssl/dhparam.pem" ];then
	mkdir -p /etc/nginx/ssl
	 openssl dhparam -out "/etc/nginx/ssl/dhparam.pem" 1024
fi


grep -q ${mysqlhost} /usr/local/etc/zabbix_server.conf
if [ $? -ne 0 ];then
	mysql -h ${mysqlhost} -u root -p${root_pass} -e "create database zabbix default charset utf8"
	mysql -h ${mysqlhost} -u root -p${root_pass} -e "grant all on zabbix.* to '${zabbixuser}'@'%' identified by '${zabbixpassword}'"
	mysql -h ${mysqlhost} -u root -p${root_pass} -e "flush privileges"
	mysql -h ${mysqlhost} -u root -p${root_pass} -e "select user,host from mysql.user"

	mysql -h ${mysqlhost} -u ${zabbixuser} -p${zabbixpassword} zabbix < /zabbix-3.0.14/database/mysql/schema.sql
	mysql -h ${mysqlhost} -u ${zabbixuser} -p${zabbixpassword} zabbix < /zabbix-3.0.14/database/mysql/images.sql
	mysql -h ${mysqlhost} -u ${zabbixuser} -p${zabbixpassword} zabbix < /zabbix-3.0.14/database/mysql/data.sql

	sed -i "/# DBHost=localhost/aDBHost=${mysqlhost}" /usr/local/etc/zabbix_server.conf
	sed -i "s@DBUser=zabbix@DBUser=${zabbixuser}@g" /usr/local/etc/zabbix_server.conf
	sed -i "/# DBPassword=/aDBPassword=${zabbixpassword}" /usr/local/etc/zabbix_server.conf
	sed -i "/# AlertScriptsPath/iAlertScriptsPath=\/usr\/local\/etc\/zabbix\/alertscripts" /usr/local/etc/zabbix_server.conf

	rm -rf /usr/local/nginx/html/*
	cp -ar /zabbix-3.0.14/frontends/php/* /usr/local/nginx/html/
	cp /zabbix-3.0.14.tar.gz /usr/local/nginx/html/zabbix-3.0.14.tar.gz
	cp /install.sh /usr/local/nginx/html/install.sh
	cp /zabbix-3.0.14/simkai.ttf /usr/local/nginx/html/fonts/DejaVuSans.ttf
	cp /wechat.py /usr/local/etc/zabbix/alertscripts/wechat.py
	chmod 755 /usr/local/etc/zabbix/alertscripts/wechat.py
	useradd -r -s /sbin/nologin zabbix

	#Zabbix Php 参数
	sed -i "s@;date.timezone =@date.timezone = Asia/Shanghai@g" /etc/php.ini
	sed -i "s@max_execution_time = 30@max_execution_time = 300@g" /etc/php.ini
	sed -i "s@post_max_size = 8M@post_max_size = 32M@g" /etc/php.ini
	sed -i "s@max_input_time = 60@max_input_time = 300@g" /etc/php.ini
	sed -i "s@memory_limit = 128M@memory_limit = 128M@g" /etc/php.ini
	sed -i "s@;mbstring.func_overload = 0@ambstring.func_overload = 2@g" /etc/php.ini
	sed -i "s@;always_populate_raw_post_data = -1@always_populate_raw_post_data = -1@g" /etc/php.ini
fi

chown nginx:nginx -R /usr/local/nginx/

#停止服务
ps uax |grep nginx |grep -v grep |awk '{print $2}'|xargs kill &>/dev/null
ps uax |grep zabbix |grep -v grep |awk '{print $2}'|xargs kill &>/dev/null

#启动服务
if [ ! -e "/dev/shm/php-cgi.sock" ];then
	/etc/init.d/php-fpm start
else
	/etc/init.d/php-fpm restart
fi
sleep 3
/sbin/nginx

zabbix_server -c /usr/local/etc/zabbix_server.conf
tail -f /var/log/nginx/error.log && exit 0
exit 1
