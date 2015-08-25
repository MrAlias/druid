require 'spec_helper'

describe 'druid::realtime', :type => 'class' do
  context 'On system with 10 GB RAM and defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('druid::realtime')
      should contain_druid__service('realtime')
      should contain_file('/etc/druid/realtime')
      should contain_file('/etc/druid/realtime/common.runtime.properties')
      should contain_file('/etc/druid/realtime/runtime.properties')
      should contain_file('/etc/systemd/system/druid-realtime.service')
      should contain_exec('Reload systemd daemon for new realtime service file')
      should contain_service('druid-realtime')
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
        should contain_file('/etc/systemd/system/druid-realtime.service')\
          .with_content("[Unit]\nDescription=Druid Realtime Node\n\n[Service]\nType=simple\nWorkingDirectory=/etc/druid/realtime/\nExecStart=/usr/bin/java -server -Xmx25g -Xms25g -XX:NewSize=6g -XX:MaxNewSize=6g -XX:MaxDirectMemorySize=64g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/usr/local/lib/druid/lib/* io.druid.cli.Main server realtime\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
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
        :host                                 => '192.168.0.105',
        :port                                 => 8094,
        :service                              => 'druid-test/realtime',
        :processing_buffer_size_bytes         => 1073741828,
        :processing_column_cache_size_bytes   => 3,
        :processing_format_string             => 'test-processing-%s',
        :processing_num_threads               => 5,
        :publish_type                         => 'noop',
        :query_group_by_max_intermediate_rows => 50003,
        :query_group_by_max_results           => 500003,
        :query_group_by_single_threaded       => true,
        :query_search_max_search_limit        => 1002,
        :segment_cache_locations              => '/tmp/cache',
        :spec_file                            => '/tmp/spc_file',
      }
    end

      it {
        should contain_file('/etc/druid/realtime/runtime.properties').with_content("# Node Config\ndruid.host=192.168.0.105\ndruid.port=8094\ndruid.service=druid-test/realtime\n\n# Realtime Operation\ndruid.publish.type=noop\ndruid.realtime.specFile=/tmp/spc_file\n\n# Intermediate Segments Storage\ndruid.segmentCache.locations=/tmp/cache\n\n# Query Configs\ndruid.processing.buffer.sizeBytes=1073741828\ndruid.processing.formatString=test-processing-%s\ndruid.processing.numThreads=5\ndruid.processing.columnCache.sizeBytes=3\ndruid.query.groupBy.singleThreaded=true\ndruid.query.groupBy.maxIntermediateRows=50003\ndruid.query.groupBy.maxResults=500003\ndruid.query.search.maxSearchLimit=1002\n")
      }
  end
end
