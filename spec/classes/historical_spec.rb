require 'spec_helper'
describe 'druid::historical', :type => 'class' do
  context 'On system with 10 GB RAM and defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('druid::historical')
      should contain_druid__service('historical')
      should contain_file('/etc/druid/historical')
      should contain_file('/etc/druid/historical/common.runtime.properties')
      should contain_file('/etc/druid/historical/runtime.properties')
      should contain_file('/etc/systemd/system/druid-historical.service')
      should contain_exec('Reload systemd daemon for new historical service file')
      should contain_service('druid-historical')
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
        ]
      }
    end

      it {
        should contain_file('/etc/systemd/system/druid-historical.service')\
          .with_content("[Unit]\nDescription=Druid Historical Node\n\n[Service]\nType=simple\nWorkingDirectory=/etc/druid/historical/\nExecStart=/usr/bin/java -server -Xmx25g -Xms25g -XX:NewSize=6g -XX:MaxNewSize=6g -XX:MaxDirectMemorySize=64g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/usr/local/lib/druid/lib/* io.druid.cli.Main server historical\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
      }
  end

  context 'On system with 10 GB RAM and custom druid configs' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    let(:params) do
      {
        :host                                    => '192.168.0.101',
        :port                                    => 8093,
        :service                                 => 'druid-test/historical',
        :server_max_size                         => 1024,
        :server_tier                             => '_test_tier',
        :server_priority                         => 2,
        :segment_cache_locations                 => ['/cache1/', '/cache2/'],
        :segment_cache_delete_on_remove          => false,
        :segment_cache_drop_segment_delay_millis => 30002,
        :segment_cache_info_dir                  => '/cache_info',
        :segment_cache_announce_interval_millis  => 5003,
        :segment_cache_num_loading_threads       => 3,
        :server_http_num_threads                 => 12,
        :server_http_max_idle_time               => 'PT6m',
        :processing_buffer_size_bytes            => 1073741826,
        :processing_format_string                => 'test-processing-%s',
        :processing_num_threads                  => 2,
        :processing_column_cache_size_bytes      => 2,
        :query_group_by_single_threaded          => true,
        :query_group_by_max_intermediate_rows    => 50001,
        :query_group_by_max_results              => 500001,
        :query_search_max_search_limit           => 1001,
        :use_cache                               => true,
        :populate_cache                          => true,
        :uncacheable                             => ['groupBy'],
      }
    end

      it {
        should contain_file('/etc/druid/historical/runtime.properties')\
          .with_content("# Node Configs\ndruid.host=192.168.0.101\ndruid.port=8093\ndruid.service=druid-test/historical\n\n# General Configuration\ndruid.server.maxSize=1024\ndruid.server.tier=_test_tier\ndruid.server.priority=2\n\n# Storing Segments\ndruid.segmentCache.locations=[\"/cache1/\",\"/cache2/\"]\ndruid.segmentCache.deleteOnRemove=false\ndruid.segmentCache.dropSegmentDelayMillis=30002\ndruid.segmentCache.infoDir=/cache_info\ndruid.segmentCache.announceIntervalMillis=5003\ndruid.segmentCache.numLoadingThreads=3\n\n# Query Configs\ndruid.server.http.numThreads=12\ndruid.server.http.maxIdleTime=PT6m\n\n# Processing\ndruid.processing.buffer.sizeBytes=1073741826\ndruid.processing.formatString=test-processing-%s\ndruid.processing.numThreads=2\ndruid.processing.columnCache.sizeBytes=2\n\n# General Query Configuration\ndruid.query.groupBy.singleThreaded=true\ndruid.query.groupBy.maxIntermediateRows=50001\ndruid.query.groupBy.maxResults=500001\n\n# Search Query Config\ndruid.query.search.maxSearchLimit=1001\n\n# Caching\ndruid.historical.cache.useCache=true\ndruid.historical.cache.populateCache=true\ndruid.historical.cache.unCacheable=[\"groupBy\"]\n")
      }
  end
end
