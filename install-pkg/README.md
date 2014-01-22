# README

本文是对 `TaskServer` 和 `Worker` 服务器部署的简要说明

## TaskServer

### HAProxy

Use the `apt-get` command to install HAProxy.

	sudo apt-get update
	sudo apt-get install haproxy

We need to enable HAProxy to be started by the init script.

	vim /etc/default/haproxy

Set the `ENABLED` option to 1

	ENABLED=1

##Configuring HAProxy


We'll move the default configuration file and create our own one.


	sudo mv /etc/haproxy/haproxy.cfg{,.bak}
	
Create and edit a new configuration file:

	sudo vim /etc/haproxy/haproxy.cfg

```
global
    log 127.0.0.1 local0 notice
    maxconn 2000
    user haproxy
    group haproxy
defaults
    log     global
    mode    http
    option  httplog
    option  dontlognull
    retries 3
    option redispatch
    timeout connect  5000
    timeout client  10000
    timeout server  10000
listen appname 0.0.0.0:80
    mode http
    stats enable
    stats uri /haproxy
    stats realm Strictly\ Private
    stats auth admin:admin
    balance roundrobin
    option httpclose
    option forwardfor
    server query-server 13.141.43.227:80 check
    #rabbitmq status
    acl rabbitmq hdr_end(host) -i rabbitmq.query-server.dev
    use_backend rabbitmq_backend if rabbitmq
    #ganglia
    #acl ganglia hdr_end(host) -i ganglia.query-server.dev
    #use_backend ganglia_backend if ganglia

backend rabbitmq_backend
    server query-server 127.0.0.1:15672 check

```
    
```
sudo service haproxy restart
```


### RabbitMQ

	#添加 RabbitMQ 的singing-key-public.	wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc	sudo apt-key add rabbitmq-signing-key-public.asc
	echo "deb http://www.rabbitmq.com/debian/ testing main" >> /etc/apt/sources.list
	
	sudo apt-get update
    sudo apt-get install rabbitmq-server

或者

    dpkg -i http://www.rabbitmq.com/releases/rabbitmq-server/v3.2.2/rabbitmq-server_3.2.2-1_all.deb

安装控制插件，查看列表：
```
sudo rabbitmq-plugins listsudo rabbitmq-plugins enable rabbitmq_management
```一旦设成enable，你将看到以下几个选中：
```[e] amqp_client                       3.2.2
[ ] cowboy                            0.5.0-rmq3.2.2-git4b93c2d
[ ] eldap                             3.2.2-gite309de4
[e] mochiweb                          2.7.0-rmq3.2.2-git680dba8
[ ] rabbitmq_amqp1_0                  3.2.2
[ ] rabbitmq_auth_backend_ldap        3.2.2
[ ] rabbitmq_auth_mechanism_ssl       3.2.2
[ ] rabbitmq_consistent_hash_exchange 3.2.2
[ ] rabbitmq_federation               3.2.2
[ ] rabbitmq_federation_management    3.2.2
[ ] rabbitmq_jsonrpc                  3.2.2
[ ] rabbitmq_jsonrpc_channel          3.2.2
[ ] rabbitmq_jsonrpc_channel_examples 3.2.2
[E] rabbitmq_management               3.2.2
[e] rabbitmq_management_agent         3.2.2
[ ] rabbitmq_management_visualiser    3.2.2
[ ] rabbitmq_mqtt                     3.2.2
[ ] rabbitmq_shovel                   3.2.2
[ ] rabbitmq_shovel_management        3.2.2
[ ] rabbitmq_stomp                    3.2.2
[ ] rabbitmq_tracing                  3.2.2
[e] rabbitmq_web_dispatch             3.2.2
[ ] rabbitmq_web_stomp                3.2.2
[ ] rabbitmq_web_stomp_examples       3.2.2
[ ] rfc4627_jsonrpc                   3.2.2-git5e67120
[ ] sockjs                            0.3.4-rmq3.2.2-git3132eb9
[e] webmachine                        1.10.3-rmq3.2.2-gite9359c7
```重启服务后，改变将生效。
`sudo service rabbitmq-server restart`
首先创建一个用户
	sudo rabbitmqctl add_user user-name your-password
	
	#Give new user administration privileges
	sudo rabbitmqctl set_user_tags admin administrator`
	
	#Lets assign permissions to admin user
	sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
	#Delete the default guest account
	sudo rabbitmqctl delete_user guest
	#Restart the server for the changes to take effect.
	sudo service rabbitmq-server restart

Lastly, navigate to <http://localhost:55672> to view the web interface for your RabbitMQ server

### RedisServer

	sudo apt-get install redis-server

修改监听地址

	#/etc/redis/redis.conf
	
	...
	#bind 127.0.0.1
	bind 0.0.0.0
	...

### NFS-Server
	
	sudo apt-get install nfs-kernel-server
	sudo mkdir -p /dmsdocs/datastore
	sudo chown david: /dmsdocs/datastore
	echo "/dmsdocs/datastore  13.141.43.0/24(rw,sync,no_subtree_check)" > /etc/exports
	sudo service nfs-kernel-server restart
	
启动服务

  	cd dms/bin
	python uploading_watcher.py

## Worker

修改 `/etc/hosts` 文件 , 添加 `taskserver` 地址

	cd install-pkg/worker && ./install.sh
	
	sudo mkdir -p /dmsdocs/datastore
	
	sudo mount taskserver:/dmsdocs/datastore /dmsdocs/datastore
	
	ln -s dms/bin/run-worker.sh run-worker
	
	./run-worker
	
	
All Done .
	
