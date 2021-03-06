define REDIS1_CONF
daemonize yes
port 6379
pidfile /tmp/redis1.pid
dir /tmp
endef

define REDIS2_CONF
daemonize yes
port 6380
pidfile /tmp/redis2.pid
dir /tmp
endef

export REDIS1_CONF
export REDIS2_CONF
export ZOOCFG := test/resources/zoo.cfg
NODE_VERSION="v0.6.19"
NODE_VERSION_LOCAL=$(shell /usr/local/node/bin/node --version)

test:
	echo "$$REDIS1_CONF" | /usr/local/bin/redis-server -
	echo "$$REDIS2_CONF" | /usr/local/bin/redis-server -

	test/resources/zookeeper-3.4.3/bin/zkServer.sh start ${ZOOCFG}
#	sleep 10 
	./node_modules/.bin/_mocha --globals myThis,myHolder,myCallee,State_myThis --reporter spec -t 5000 -s 3000 ${REGEX} ${TESTFILE}

	test/resources/zookeeper-3.4.3/bin/zkServer.sh stop ${ZOOCFG}

	kill `cat /tmp/redis1.pid`
	kill `cat /tmp/redis1.pid`

prepare_development:
	cd /tmp; git clone https://github.com/antirez/redis.git; cd redis; git checkout 5471b8babddbb99a50010593483f24187e51981a; make install;
	cd /tmp; wget http://nodejs.org/dist/v0.8.22/node-v0.8.22.tar.gz; tar -xvzf node-v0.8.22.tar.gz; cd node-v0.8.22; ./configure && make && make install;
	npm install;

run_development:
	if test "$(shell redis-cli ping)" = "PONG"; then (redis-cli shutdown); fi;
	redis-server &
	./bin/http_launcher.js
	

.PHONY: test
