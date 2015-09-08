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
      should contain_file('/etc/systemd/system/druid-middle_manager.service').with_content("[Unit]\nDescription=Druid Middle Manager Node\n\n[Service]\nType=simple\nWorkingDirectory=/etc/druid/middle_manager/\nExecStart=/usr/bin/java -server -Xmx4g -Xms4g -XX:NewSize=256m -XX:MaxNewSize=256m -XX:MaxDirectMemorySize=2g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/usr/local/lib/druid/lib/* io.druid.cli.Main server middleManager\nSuccessExitStatus=130 143\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
    }
  end

  context 'On default system with custom druid configs' do
    let(:params) do
      {
        :host                            => '101.101.10.1',
        :port                            => 8090,
        :service                         => 'test-druid/middlemanager',
        :peon_mode                       => 'remote',
        :remote_peon_max_retry_count     => 15,
        :remote_peon_max_wait            => 'PT15M',
        :remote_peon_min_wait            => 'PT6M',
        :runner_allowed_prefixes         => ['druid', 'io.druid', 'user.timezone', 'file.encoding'],
        :runner_classpath                => '.:/test',
        :runner_compress_znodes          => false,
        :runner_java_command             => '/usr/bin/java',
        :runner_java_opts                => '-server',
        :runner_max_znode_bytes          => 524188,
        :runner_start_port               => 8110,
        :task_base_dir                   => '/mnt/tmp',
        :task_base_task_dir              => '/mnt/tmp/persistent/tasks',
        :task_chat_handler_type          => 'announce',
        :task_default_hadoop_coordinates => ['org.apache.hadoop:hadoop-client:1.1.1'],
        :task_default_row_flush_boundary => 50009,
        :task_hadoop_working_path        => '/mnt/tmp/druid-indexing',
        :worker_capacity                 => 2,
        :worker_ip                       => '127.0.0.1',
        :worker_version                  => '2',
      }
    end 
    
    it {
      should contain_file('/etc/druid/middle_manager/runtime.properties').with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Node Configs\ndruid.host=101.101.10.1\ndruid.port=8090\ndruid.service=test-druid/middlemanager\n\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n\n# MiddleManager Service\ndruid.indexer.runner.allowedPrefixes=[\"druid\",\"io.druid\",\"user.timezone\",\"file.encoding\"]\ndruid.indexer.runner.classpath=.:/test\ndruid.indexer.runner.javaCommand=/usr/bin/java\ndruid.indexer.runner.javaOpts=-server\ndruid.indexer.runner.maxZnodeBytes=524188\ndruid.indexer.runner.startPort=8110\ndruid.worker.ip=127.0.0.1\ndruid.worker.version=2\ndruid.worker.capacity=2\n\n# Peon Configs\ndruid.peon.mode=remote\ndruid.indexer.task.baseDir=/mnt/tmp\ndruid.indexer.task.baseTaskDir=/mnt/tmp/persistent/tasks\ndruid.indexer.task.hadoopWorkingPath=/mnt/tmp/druid-indexing\ndruid.indexer.task.defaultRowFlushBoundary=50009\ndruid.indexer.task.defaultHadoopCoordinates=[\"org.apache.hadoop:hadoop-client:1.1.1\"]\ndruid.indexer.task.chathandler.type=announce\n\n# Remote Peon Configs\ndruid.peon.taskActionClient.retry.minWait=PT6M\ndruid.peon.taskActionClient.retry.maxWait=PT15M\ndruid.peon.taskActionClient.retry.maxRetryCount=15\n")
    }
  end
end
