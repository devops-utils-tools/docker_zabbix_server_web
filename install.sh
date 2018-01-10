#!/bin/bash
#zabbix agent install By:liuwei Mail:al6008@163.com
#curl http://10.16.140.18:8081/install.sh|bash
zabbix_ip=172.16.110.203
which apt-get &&apt-get install -y build-essential
which yum &&yum install -y gcc-c++
wget -O /tmp/zabbix-3.0.14.tar.gz http://${zabbix_ip}/zabbix-3.0.14.tar.gz&&cd /tmp
find `pwd` -maxdepth 1 -type f -name "zabbix*.tar*"|xargs tar xf
cd `find $(pwd) -maxdepth 1 -type d -name "zabbix-*" `
./configure --enable-agent
useradd -r -s /sbin/nologin zabbix
make -j &&make -j install
cp misc/init.d/fedora/core/zabbix_agentd /etc/init.d/
chmod 755 /etc/init.d/zabbix_agentd
chkconfig zabbix_agentd on
sed -i "s@ServerActive=127.0.0.1@ServerActive=${zabbix_ip}@g" /usr/local/etc/zabbix_agentd.conf
sed -i "s@Server=127.0.0.1@Server=${zabbix_ip}@g" /usr/local/etc/zabbix_agentd.conf
chkconfig zabbix_agentd on
/etc/init.d/zabbix_agentd restart
netstat -tunlp |grep -q 10050&&echo "zabbix_agent install ok" &&exit 0
exit 1
