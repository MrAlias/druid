require 'spec_helper'
describe 'druid::broker', :type => 'class' do
  context 'On base system with defaults for all parameters' do
    it {
      should compile.with_all_deps
      should contain_class('druid::broker')
      should contain_druid__service('broker')
      should contain_file('/etc/druid/broker')
      should contain_file('/etc/druid/broker/common.runtime.properties')
      should contain_file('/etc/druid/broker/runtime.properties')
      should contain_file('/etc/systemd/system/druid-broker.service')
      should contain_exec('Reload systemd daemon for new broker service file')
      should contain_service('druid-broker')
    }
  end

  context 'On base system with custom JVM parameters ' do
    let(:params) do
      {
        :jvm_opts => [
          '-server',
          '-Xmx25g',
          '-Xms25g',
          '-XX:NewSize=6g',
          '-XX:MaxNewSize=6g',
          '-XX:MaxDirectMemorySize=64g',
          '-Duser.timezone=PDT',
          '-Dfile.encoding=latin-1',
          '-Djava.util.logging.manager=custom.LogManager',
          '-Djava.io.tmpdir=/mnt/tmp',
          '-Dcom.sun.management.jmxremote.port=17071',
          '-Dcom.sun.management.jmxremote.authenticate=false',
          '-Dcom.sun.management.jmxremote.ssl=false',
        ]
      }
    end

    it {
      should contain_file('/etc/systemd/system/druid-broker.service').with_content("[Unit]\nDescription=Druid Broker Node\n\n[Service]\nType=simple\nWorkingDirectory=/etc/druid/broker/\nExecStart=/usr/bin/java -server -Xmx25g -Xms25g -XX:NewSize=6g -XX:MaxNewSize=6g -XX:MaxDirectMemorySize=64g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -Dcom.sun.management.jmxremote.port=17071 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -classpath .:/usr/local/lib/druid/lib/* io.druid.cli.Main server broker\nSuccessExitStatus=130 143\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
    }
  end

  context 'On base system with all custom parameters.' do
    let(:params) do
      {
        :host                                 => '192.168.0.100',
        :port                                 => 8092,
        :service                              => 'druid-test/broker',
        :balancer_type                        => 'connectionCount',
        :cache_expiration                     => 2592002,
        :cache_hosts                          => ['127.0.0.1:1221'],
        :cache_initial_size                   => 500002,
        :cache_log_eviction_count             => 2,
        :cache_max_object_size                => 52428801,
        :cache_memcached_prefix               => 'druid-broker',
        :cache_populate_cache                 => true,
        :cache_size_in_bytes                  => 10,
        :cache_timeout                        => 1000,
        :cache_type                           => 'remote',
        :cache_uncacheable                    => ['groupBy'],
        :cache_use_cache                      => true,
        :http_num_connections                 => 20,
        :http_read_timeout                    => 'PT30M',
        :processing_buffer_size_bytes         => 2147483648,
        :processing_column_cache_size_bytes   => 10,
        :processing_format_string             => 'test-processing-%s',
        :processing_num_threads               => 2,
        :query_group_by_max_intermediate_rows => 50100,
        :query_group_by_max_results           => 500100,
        :query_group_by_single_threaded       => true,
        :query_search_max_search_limit        => 1001,
        :retry_policy_num_tries               => 3,
        :select_tier_custom_priorities        => [1, 10],
        :select_tier                          => 'lowestPriority',
        :server_http_max_idle_time            => 'PT10m',
        :server_http_num_threads              => 15,
      }
    end

    it {
      should contain_file('/etc/druid/broker/runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Node Configs\ndruid.host=192.168.0.100\ndruid.port=8092\ndruid.service=druid-test/broker\n\n# Query Configs\ndruid.broker.balancer.type=connectionCount\ndruid.broker.select.tier=lowestPriority\ndruid.broker.select.tier.custom.priorities=[1,10]\ndruid.server.http.numThreads=15\ndruid.server.http.maxIdleTime=PT10m\ndruid.broker.http.numConnections=20\ndruid.broker.http.readTimeout=PT30M\ndruid.broker.retryPolicy.numTries=3\ndruid.processing.buffer.sizeBytes=2147483648\ndruid.processing.formatString=test-processing-%s\ndruid.processing.numThreads=2\ndruid.processing.columnCache.sizeBytes=10\ndruid.query.groupBy.singleThreaded=true\ndruid.query.groupBy.maxIntermediateRows=50100\ndruid.query.groupBy.maxResults=500100\ndruid.query.search.maxSearchLimit=1001\n\n# Caching\ndruid.broker.cache.useCache=true\ndruid.broker.cache.populateCache=true\ndruid.cache.type=remote\ndruid.broker.cache.unCacheable=[\"groupBy\"]\n")
    }
  end

  context 'On base system with memcached as cache' do
    let(:params) do
      {
        :cache_expiration                     => 4184004,
        :cache_hosts                          => ['127.0.0.1:1223'],
        :cache_max_object_size                => 500,
        :cache_memcached_prefix               => 'test-druid-broker',
        :cache_type                           => 'memcached',
      }
    end

    it {
      should contain_file('/etc/druid/broker/runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Node Configs\ndruid.port=8082\ndruid.service=druid/broker\n\n# Query Configs\ndruid.broker.balancer.type=random\ndruid.broker.select.tier=highestPriority\ndruid.server.http.numThreads=10\ndruid.server.http.maxIdleTime=PT5m\ndruid.broker.http.numConnections=5\ndruid.broker.http.readTimeout=PT15M\ndruid.broker.retryPolicy.numTries=1\ndruid.processing.buffer.sizeBytes=1073741824\ndruid.processing.formatString=processing-%s\ndruid.processing.columnCache.sizeBytes=0\ndruid.query.groupBy.singleThreaded=false\ndruid.query.groupBy.maxIntermediateRows=50000\ndruid.query.groupBy.maxResults=500000\ndruid.query.search.maxSearchLimit=1000\n\n# Caching\ndruid.broker.cache.useCache=false\ndruid.broker.cache.populateCache=false\ndruid.cache.type=memcached\ndruid.broker.cache.unCacheable=[\"groupBy\",\"select\"]\ndruid.cache.expiration=4184004\ndruid.cache.timeout=500\ndruid.cache.hosts=127.0.0.1:1223\ndruid.cache.maxObjectSize=500\ndruid.cache.memcachedPrefix=test-druid-broker\n")
    }
  end
end
