require 'spec_helper'

describe 'druid::indexing::middle_manager', :type => 'class' do
  context 'On system with 10 GB RAM and defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('druid::indexing::middle_manager')
      should contain_druid__service('middle_manager')
      should contain_file('/etc/druid/middle_manager')
      should contain_file('/etc/druid/middle_manager/common.runtime.properties')
      should contain_file('/etc/druid/middle_manager/runtime.properties')
      should contain_file('/etc/systemd/system/druid-middle_manager.service')
      should contain_exec('Reload systemd daemon for new middle_manager service file')
      should contain_service('druid-middle_manager')
    }
  end

  context 'On base system with custom JVM parameters ' do
    let(:params) do
      {
        :jvm_opts => [
          '-server',
          '-Xmx4g',
          '-Xms4g',
          '-XX:NewSize=256m',
          '-XX:MaxNewSize=256m',
          '-XX:MaxDirectMemorySize=2g',
          '-Duser.timezone=PDT',
          '-Dfile.encoding=latin-1',
          '-Djava.util.logging.manager=custom.LogManager',
          '-Djava.io.tmpdir=/mnt/tmp',
        ]
      }
    end

    it {
      should contain_file('/etc/systemd/system/druid-middle_manager.service').with_content("[Unit]\nDescription=Druid Middle Manager Node\n\n[Service]\nType=simple\nWorkingDirectory=/etc/druid/middle_manager/\nExecStart=/usr/bin/java -server -Xmx4g -Xms4g -XX:NewSize=256m -XX:MaxNewSize=256m -XX:MaxDirectMemorySize=2g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/usr/local/lib/druid/lib/* io.druid.cli.Main server middleManager\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
    }
  end

  context 'On default system with custom druid configs' do
    let(:params) do
      {
        :host                            => '101.101.10.1',
        :port                            => 8090,
        :service                         => 'test-druid/middlemanager',
        :peon_mode                       => 'local',
        :runner_allowed_prefixes         => ['druid', 'io.druid', 'user.timezone', 'file.encoding'],
        :runner_classpath                => '.:/test',
        :runner_compress_znodes          => false,
        :runner_java_command             => '/usr/bin/java',
        :runner_java_opts                => '-server',
        :runner_max_znode_bytes          => 524188,
        :runner_start_port               => 8110,
        :task_base_dir                   => '/mnt/tmp',
        :task_base_task_dir              => '/mnt/tmp/persistent/tasks',
        :task_default_hadoop_coordinates => 'org.apache.hadoop:hadoop-client:1.1.1',
        :task_default_row_flush_boundary => 50009,
        :task_hadoop_working_path        => '/mnt/tmp/druid-indexing',
        :worker_capacity                 => 2,
        :worker_ip                       => '127.0.0.1',
        :worker_version                  => '2',
      }
    end 
    
    it {
      should contain_file('/etc/druid/middle_manager/runtime.properties').with_content("# Node Configs\ndruid.host=101.101.10.1\ndruid.port=8090\ndruid.service=test-druid/middlemanager\n\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n")
    }
  end
end
