#zabbix 数据库
#rm -rf /data/zabbix
docker stop zabbix_mysql
docker rm -f zabbix_mysql
docker run -d --restart always --name zabbix_mysql --hostname zabbix_mysql \
	-p 3306:3306 \
	-e MYSQL_ROOT_PASSWORD=Arxan_Liuwei \
	-v /data/zabbix/mysql:/var/lib/mysql \
mysql:5.7

#zabbix Server And Web
docker build -t zabbix_server_web ./
docker stop zabbix_server_web
docker rm zabbix_server_web
rm -rf /usr/local/nginx/html
docker run -d --restart always --name zabbix_server_web --hostname zabbix_server_web \
-p 9080:80 \
-p 9443:443 \
-p 10051:10051 \
-e mysqlhost=172.16.110.99 \
-e root_pass=Arxan_Liuwei \
-e zabbixuser=zabbix \
-e zabbixpassword=Arxan_Liuwei \
-v /data/zabbix/ssl:/etc/nginx/ssl \
-v /data/zabbix/html:/usr/local/nginx/html \
-v /data/zabbix/alertscripts:/usr/local/etc/zabbix/alertscripts \
zabbix_server_web
docker logs -tf zabbix_server_web

#zabbix_agent
name=hbase_172.16.110.166
docker stop zabbix_agent
docker rm -f  zabbix_agent
docker build -t zabbix_agent ./
docker run -d --restart always --name zabbix_agent \
-p 10050:10050 \
-e Zabbix_Server=172.16.110.88 \
-e Zabbix_Agent_Name=${name} \
--hostname ${name} \
-v /data/zabbix_agent:/usr/local/etc/zabbix_agentd.conf.d \
--network host --privileged \
zabbix_agent
