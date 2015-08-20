require 'spec_helper'

describe 'druid', :type => 'class' do
  context 'On generic system with defaults for all parameters' do
    it {
      should compile.with_all_deps
      should contain_class('druid')
      should contain_file('/usr/local/lib/druid')\
        .with({:ensure => :link, :target => '/usr/local/lib/druid-0.8.0'})\
        .that_requires('Exec[Download and untar druid-0.8.0]')
      should contain_file('/usr/local/lib')\
        .with({:ensure => :directory})\
        .that_requires('Exec[Create /usr/local/lib]')
      should contain_file('/etc/druid')\
        .with({:ensure => :directory})\
        .that_requires('Exec[Create /etc/druid]')
      should contain_file('/etc/druid/common.runtime.properties')\
        .with({:ensure => :file})\
        .that_requires('File[/etc/druid]')
      should contain_exec('Create /usr/local/lib').with({
          :command => 'mkdir -p /usr/local/lib',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => '/usr/local/lib',
          :cwd     => '/',
      })
      should contain_exec('Create /etc/druid').with({
          :command => 'mkdir -p /etc/druid',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => '/etc/druid',
          :cwd     => '/',
      })
      should contain_exec('Download and untar druid-0.8.0').with({
          :command => 'wget -O - http://static.druid.io/artifacts/releases/druid-0.8.0-bin.tar.gz | tar zx',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => '/usr/local/lib/druid-0.8.0',
          :cwd     => '/usr/local/lib',
      }).that_requires('File[/usr/local/lib]').that_requires('Package[wget]')
      should contain_package('openjdk-7-jre-headless')\
        .with({:ensure => 'present'})
      should contain_package('wget')\
        .with({:ensure => 'present'})
    }
  end

  context 'On generic system with custom install parameters' do
    let(:params) do
      {
        :version     => '0.7.0',
        :java_pkg    => 'openjdk-7-jre',
        :install_dir => '/opt/druid',
        :config_dir  => '/opt/druid_config',
      }
    end

    it {
      should contain_file('/opt/druid/druid')\
        .with({:ensure => :link, :target => '/opt/druid/druid-0.7.0'})\
        .that_requires('Exec[Download and untar druid-0.7.0]')
      should contain_file('/opt/druid')\
        .with({:ensure => :directory})\
        .that_requires('Exec[Create /opt/druid]')
      should contain_file('/opt/druid_config')\
        .with({:ensure => :directory})\
        .that_requires('Exec[Create /opt/druid_config]')
      should contain_file('/opt/druid_config/common.runtime.properties')\
        .with({:ensure => :file})\
        .that_requires('File[/opt/druid_config]')
      should contain_exec('Create /opt/druid').with({
          :command => 'mkdir -p /opt/druid',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => '/opt/druid',
          :cwd     => '/',
      })
      should contain_exec('Create /opt/druid_config').with({
          :command => 'mkdir -p /opt/druid_config',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => '/opt/druid_config',
          :cwd     => '/',
      })
      should contain_exec('Download and untar druid-0.7.0').with({
          :command => 'wget -O - http://static.druid.io/artifacts/releases/druid-0.7.0-bin.tar.gz | tar zx',
          :path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          :creates => '/opt/druid/druid-0.7.0',
          :cwd     => '/opt/druid',
      }).that_requires('File[/opt/druid]').that_requires('Package[wget]')
      should contain_package('openjdk-7-jre')\
        .with({:ensure => 'present'})
    }
  end

  context 'On generic system with custom druid parameters' do
    let(:params) do
      {
        :extensions_remote_repositories           => ['http://repo1.maven.org/maven2/'],
        :extensions_local_repository              => '~/.m2-test/repository',
        :extensions_coordinates                   => ['groupID;artifactID:version'],
        :extensions_default_version               => 'test',
        :extensions_search_current_classloader    => false,
        :zk_service_host                          => '192.168.0.150',
        :zk_service_session_timeout_ms            => 30002,
        :curator_compress                         => false,
        :zk_paths_base                            => '/druid',
        :zk_paths_properties_path                 => '/druid/1',
        :zk_paths_announcements_path              => '/druid/2',
        :zk_paths_live_segments_path              => '/druid/3',
        :zk_paths_load_queue_path                 => '/druid/4',
        :zk_paths_coordinator_path                => '/druid/5',
        :zk_paths_indexer_base                    => '/druid/6',
        :zk_paths_indexer_announcements_path      => '/druid/7',
        :zk_paths_indexer_tasks_path              => '/druid/8',
        :zk_paths_indexer_status_path             => '/druid/9',
        :zk_paths_indexer_leader_latch_path       => '/druid/10',
        :discovery_curator_path                   => '/druid-test/discovery',
        :request_logging_type                     => 'file',
        :request_logging_dir                      => '/log/',
        :request_logging_feed                     => 'druid-test',
        :monitoring_emission_period               => 'PT2m',
        :monitoring_monitors                      => ['mode'],
        :emitter                                  => 'test-logging',
        :emitter_logging_logger_class             => 'ServiceEmitter',
        :emitter_logging_log_level                => 'debug',
        :emitter_http_time_out                    => 'PT6M',
        :emitter_http_flush_millis                => 60001,
        :emitter_http_flush_count                 => 501,
        :emitter_http_recipient_base_url          => '127.0.0.1',
        :metadata_storage_type                    => 'mysql',
        :metadata_storage_connector_uri           => 'jdbc:mysql://127.0.0.1:3306/druid?characterEncoding=UTF-8',
        :metadata_storage_connector_user          => 'druid-test',
        :metadata_storage_connector_password      => 'test_insecure_pass',
        :metadata_storage_connector_create_tables => false,
        :metadata_storage_tables_base             => 'druid-test',
        :metadata_storage_tables_segment_table    => 'druid-test_segments',
        :metadata_storage_tables_rule_table       => 'druid-test_rules',
        :metadata_storage_tables_config_table     => 'druid-test_config',
        :metadata_storage_tables_tasks            => 'druid-test_tasks',
        :metadata_storage_tables_task_log         => 'druid-test_taskLog',
        :metadata_storage_tables_task_lock        => 'druid-test_taskLock',
        :metadata_storage_tables_audit            => 'druid-test_audit',
        :storage_type                             => 's3',
        :storage_directory                        => '/tmp/druid-test/localStorage',
        :s3_access_key                            => 'key3',
        :s3_secret_key                            => 'key2',
        :s3_bucket                                => 'druid',
        :s3_base_key                              => 'key1',
        :storage_disable_acl                      => true,
        :s3_archive_bucket                        => 'druid-archive',
        :s3_archive_base_key                      => 'druid-base-key',
        :hdfs_directory                           => 'druid',
        :cassandra_host                           => '127.0.0.1',
        :cassandra_keyspace                       => 'none',
        :cache_type                               => 'memcached',
        :cache_uncacheable                        => 'groupBy',
        :cache_size_in_bytes                      => 2,
        :cache_initial_size                       => 500002,
        :cache_log_eviction_count                 => 2,
        :cache_expiration                         => 2592002,
        :cache_timeout                            => 501,
        :cache_hosts                              => ['127.0.0.1:1221'],
        :cache_max_object_size                    => 52428802,
        :cache_memcached_prefix                   => 'druid-test',
        :selectors_indexing_service_name          => 'druid-test/overlord',
        :announcer_type                           => 'lecagy',
        :announcer_segments_per_node              => 51,
        :announcer_max_bytes_per_node             => 524289,
      }
    end

    it {
      should contain_file('/etc/druid/common.runtime.properties')\
        .with_content("# This file is managed by Puppet\n# MODIFICATION WILL BE OVERWRITTEN\n\n# Extensions\ndruid.extensions.remoteRepositories=[\"http://repo1.maven.org/maven2/\"]\ndruid.extensions.localRepository=~/.m2-test/repository\ndruid.extensions.coordinates=[\"groupID;artifactID:version\"]\ndruid.extensions.defaultVersion=test\ndruid.extensions.searchCurrentClassloader=false\n\n# Zookeeper\ndruid.zk.paths.base=/druid\ndruid.zk.service.host=192.168.0.150\ndruid.zk.service.sessionTimeoutMs=30002\ndruid.curator.compress=false\ndruid.zk.paths.propertiesPath=/druid/1\ndruid.zk.paths.announcementsPath=/druid/2\ndruid.zk.paths.liveSegmentsPath=/druid/3\ndruid.zk.paths.loadQueuePath=/druid/4\ndruid.zk.paths.coordinatorPath=/druid/5\ndruid.zk.paths.indexer.base=/druid/6\ndruid.zk.paths.indexer.announcementsPath=/druid/7\ndruid.zk.paths.indexer.tasksPath=/druid/8\ndruid.zk.paths.indexer.statusPath=/druid/9\ndruid.zk.paths.indexer.leaderLatchPath=/druid/10\ndruid.discovery.curator.path=/druid-test/discovery\n\n# Request Logging\ndruid.request.logging.type=file\ndruid.request.logging.dir=/log/\n\n# Enabling Metrics\ndruid.monitoring.emissionPeriod=PT2m\ndruid.monitoring.monitors=[\"\"]\n\n# Emitting Metrics\ndruid.emitter=test-logging\n\n# Metadata Storage\ndruid.metadata.storage.type=mysql\ndruid.metadata.storage.connector.connectURI=jdbc:mysql://127.0.0.1:3306/druid?characterEncoding=UTF-8\ndruid.metadata.storage.connector.user=druid-test\ndruid.metadata.storage.connector.password=test_insecure_pass\ndruid.metadata.storage.connector.createTables=false\ndruid.metadata.storage.tables.base=druid-test\ndruid.metadata.storage.tables.segmentTable=druid-test_segments\ndruid.metadata.storage.tables.ruleTable=druid-test_rules\ndruid.metadata.storage.tables.configTable=druid-test_config\ndruid.metadata.storage.tables.tasks=druid-test_tasks\ndruid.metadata.storage.tables.taskLog=druid-test_taskLog\ndruid.metadata.storage.tables.taskLock=druid-test_taskLock\ndruid.metadata.storage.tables.audit=druid-test_audit\n\n# Deep Storage\ndruid.storage.type=s3\ndruid.s3.accessKey=key3\ndruid.s3.secretKey=key2\ndruid.storage.bucket=druid\ndruid.storage.baseKey=key1\ndruid.storage.disableAcl=true\ndruid.storage.archiveBucket=druid-archive\ndruid.storage.archiveBaseKey=druid-base-key\n\n# Caching\ndruid.cache.type=memcached\ndruid.cache.unCacheable=groupBy\ndruid.cache.expiration=2592002\ndruid.cache.timeout=501\ndruid.cache.hosts=[\"127.0.0.1:1221\"]\ndruid.cache.maxObjectSize=52428802\ndruid.cache.memcachedPrefix=druid-test\n\n# Indexing Service Discovery\ndruid.selectors.indexing.serviceName=druid-test/overlord\n\n# Announcing Segments\ndruid.announcer.type=lecagy\n")
    }
  end
end
