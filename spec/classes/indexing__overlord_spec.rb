require 'spec_helper'

describe 'druid::indexing::overlord', :type => 'class' do
  context 'On system with 10 GB RAM and defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('druid::indexing::overlord')
      should contain_druid__service('overlord')
      should contain_file('/etc/druid/overlord')
      should contain_file('/etc/druid/overlord/common.runtime.properties')
      should contain_file('/etc/druid/overlord/runtime.properties')
      should contain_file('/etc/systemd/system/druid-overlord.service')
      should contain_exec('Reload systemd daemon for new overlord service file')
      should contain_service('druid-overlord')
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
      should contain_file('/etc/systemd/system/druid-overlord.service').with_content("[Unit]\nDescription=Druid Overlord Node\n\n[Service]\nType=simple\nWorkingDirectory=/etc/druid/overlord/\nExecStart=/usr/bin/java -server -Xmx4g -Xms4g -XX:NewSize=256m -XX:MaxNewSize=256m -XX:MaxDirectMemorySize=2g -Duser.timezone=PDT -Dfile.encoding=latin-1 -Djava.util.logging.manager=custom.LogManager -Djava.io.tmpdir=/mnt/tmp -classpath .:/usr/local/lib/druid/lib/* io.druid.cli.Main server overlord\nRestart=on-failure\n\n[Install]\nWantedBy=multi-user.target\n")
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
        :host                                => '192.168.17.54',
        :port                                => 9090,
        :service                             => 'druid/test-overlord',
        :autoscale                           => true,
        :autoscale_max_scaling_duration      => 'PT16M',
        :autoscale_num_events_to_track       => 13,
        :autoscale_origin_time               => '2014-01-01T00:55:00.000Z',
        :autoscale_pending_task_timeout      => 'PT31S',
        :autoscale_provision_period          => 'PT3M',
        :autoscale_strategy                  => 'ec2',
        :autoscale_terminate_period          => 'PT7M',
        :autoscale_worker_idle_timeout       => 'PT92M',
        :autoscale_worker_port               => 8082,
        :autoscale_worker_version            => 'v1',
        :queue_max_size                      => 1024,
        :queue_restart_delay                 => 'PT32S',
        :queue_start_delay                   => 'PT2M',
        :queue_storage_sync_rate             => 'PT4M',
        :runner_compress_znodes              => false,
        :runner_max_znode_bytes              => 524291,
        :runner_min_worker_version           => '1',
        :runner_task_assignment_timeout      => 'PT7M',
        :runner_task_cleanup_timeout         => 'PT17M',
        :runner_type                         => 'remote',
        :storage_recently_finished_threshold => 'PT25H',
        :storage_type                        => 'metadata',
      }
    end 
    
    it {
      should contain_file('/etc/druid/overlord/runtime.properties').with_content("# Node Configs\ndruid.host=192.168.17.54\ndruid.port=9090\ndruid.service=druid/test-overlord\n\n# Task Logging\ndruid.indexer.logs.type=file\ndruid.indexer.logs.directory=/var/log\n\n# Overlord Service\ndruid.indexer.runner.type=remote\ndruid.indexer.storage.type=metadata\ndruid.indexer.storage.recentlyFinishedThreshold=PT25H\ndruid.indexer.queue.maxSize=1024\ndruid.indexer.queue.startDelay=PT2M\ndruid.indexer.queue.restartDelay=PT32S\ndruid.indexer.queue.storageSyncRate=PT4M\n\n# Remote Mode\ndruid.indexer.runner.taskAssignmentTimeout=PT7M\ndruid.indexer.runner.minWorkerVersion=1\ndruid.indexer.runner.compressZnodes=false\ndruid.indexer.runner.maxZnodeBytes=524291\ndruid.indexer.runner.taskCleanupTimeout=PT17M\n\n# Autoscaling\ndruid.indexer.autoscale.doAutoscale=true\ndruid.indexer.autoscale.strategy=ec2\ndruid.indexer.autoscale.provisionPeriod=PT3M\ndruid.indexer.autoscale.terminatePeriod=PT7M\ndruid.indexer.autoscale.originTime=2014-01-01T00:55:00.000Z\ndruid.indexer.autoscale.workerIdleTimeout=PT92M\ndruid.indexer.autoscale.maxScalingDuration=PT16M\ndruid.indexer.autoscale.numEventsToTrack=13\ndruid.indexer.autoscale.pendingTaskTimeout=PT31S\ndruid.indexer.autoscale.workerVersion=v1\ndruid.indexer.autoscale.workerPort=8082\n")

    }
  end
end
