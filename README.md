# druid

#### Table of Contents

1. [Module Description](#module-description)
2. [Setup](#setup)
    * [What Druid Affects](#what-druid-affects)
    * [What Druid Does Not Manage](#what-druid-does-not-manage)
    * [Setup Requirements](#setup-requirements)
    * [Beginning With Druid](#beginning-with-druid)
3. [Usage](#usage)
    * [Standalone Druid Packages](#standalone-druid-packages)
    * [Hiera Support](#hiera-support)
    * [Historical Node](#historical-node)
4. [Reference](#reference)
    * [Private Classes](#private-classes)
       * [druid::indexing](#druidindexing)
    * [Public Classes](#public-classes)
       * [druid](#druid-1)
       * [druid::broker](#druidbroker)
       * [druid::coordinator](#druidcoordinator)
       * [druid::historical](#druidhistorical)
       * [druid::indexing::overlord](#druidindexingoverlord)
       * [druid::indexing::middle_manager](#druidindexingmiddle_manager)
       * [druid::realtime](#druidrealtime)
    * [Private Defined Types](#private-defined-types)
       * [druid::service](#druidservice)
5. [Limitations](#limitations)

## Module Description

[Druid](druid.io) is a data store solution designed for online analytical processing of time-series data.  This module is used to manage the Druid services used throughout a Druid cluster, namely the Historical, Broker, Coordinator, Indexing Services, and Realtime services.

## Setup

### What Druid Affects

* Installs the Druid jars to the local filesystem.
* Created Druid configuration files on the local filesystem.
* Creates and manages a [systemd](http://www.freedesktop.org/wiki/Software/systemd/) service for each Druid service to run.

### What Druid Does Not Manage

This module will not setup all the additional services a full Druid cluster will need.  Specificaly it does not manage the following.

* Cluster deep storage
* Metadata storage
* ZooKeeper

### Setup Requirements

* Puppet >= 3.x  (It might work with a previous version, but no guarantees are made).
* Ruby >= 1.9.3
* [systemd](http://www.freedesktop.org/wiki/Software/systemd/)

### Beginning With Druid

To install the Druid jars and setup basic configurations the following is all you need.

```puppet
include druid
```

## Usage

The module is designed to be called differently depending on the type of Druid service the node should be running.

### Standalone Druid Packages

If you want to run the druid service on your own the base `druid` class can be used to maintain settings. The following will install the Druid-0.8.0 release in `/opt/`, create a symlink from the installed directory to `/opt/druid/`, and then install a basic common properties file in `/opt/druid/configs/`

```puppet
class { 'druid':
  version     => '0.8.0',
  install_dir => '/opt',
  config_dir  => '/opt/druid/configs',
}
```

### Hiera Support

All parameters for all druid classes are definable in hiera.  The following hiera excerpt shows how the [above example](#standalone-druid-packages) could have been accomplished by defining the parameters in hiera.

```yaml
druid::version: '0.8.0',
druid::install_dir: '/opt'
druid::config_dir: '/opt/druid/configs'
```

### Historical Node

The `druid::historical` class is used to setup and manage Druid as a historical node.

```puppet
class { 'druid::historical':
  host => $::ipaddress_lo,
  port => 8080,
}
```

If you need to manage common configuration options you can additionally call the base `druid` class.

```puppet
class { 'druid':
  storage_type        => 's3',
  s3_access_key       => 'some_access_key',
  s3_secret_key       => 'super_secret_fake_key',
  s3_bucket           => 'druid',
  s3_base_key         => 'test-druid',
  s3_archive_bucket   => 'druid-archive',
  s3_archive_base_key => 'test_archive_base_key',
}
```

However, a simpler way to accomplish this would be to define the whole configuration via hiera.

```yaml
druid::storage_type: 's3'
druid::s3_access_key: 'some_access_key'
druid::s3_secret_key: 'super_secret_fake_key'
druid::s3_bucket: 'druid'
druid::s3_base_key: 'test-druid'
druid::s3_archive_bucket: 'druid-archive'
druid::s3_archive_base_key: 'test_archive_base_key'
druid::historical::host: %{::ipaddress_lo}
druid::historical::port: 8080
```

## Reference

### Private Classes

These classes should not be called outside of the module.

#### druid::indexing

Provides management of all common indexing related configurations.

##### `druid::indexing::azure_logs_container`

The Azure Blob Store container to store logs at. 

##### `druid::indexing::azure_logs_prefix`

The path to prepend to logs for Azure storage. 

##### `druid::indexing::hdfs_logs_directory`

The HDFS directory to store logs. 

##### `druid::indexing::local_logs_directory`

Local filesystem path to store logs. 

Default value: `'/var/log'`

##### `druid::indexing::logs_type`

Where to store task logs. 

Valid values: `'noop'`, `'s3'`, `'azure'`, `'hdfs'`, `'file'`. 

Default value: `'file'`. 

##### `druid::indexing::s3_logs_bucket`

S3 bucket name to store logs at. 

##### `druid::indexing::s3_logs_prefix`

S3 key prefix. 

### Public Classes

#### druid

The main module class.  This class is not intended to be called directly. All parameters a expected to be configured via hiera, but support is still provided to directly configure this class as a puppet class resource directly.

##### `druid::announcer_max_bytes_per_node`

Max byte size for Znode. 

Default value: `524288`.

##### `druid::announcer_segments_per_node`

Each Znode contains info for up to this many segments. 

Default value: `50`. 

##### `druid::announcer_type`

The type of data segment announcer to use. 

Valid values: `'legacy'` or `'batch'`. 

Default value: `'batch'`. 

##### `druid::cache_expiration`

Memcached expiration time. 

Default value: `2592000` (30 days). 

##### `druid::cache_hosts`

Array of Memcached hosts (`'host:port'`). 

Default value: `[]`. 

##### `druid::cache_initial_size`

Initial size of the hashtable backing the local cache. 

Default value: `500000`. 

##### `druid::cache_log_eviction_count`

If non-zero, log local cache eviction for that many items. 

Default value: `0`. 

##### `druid::cache_max_object_size`

Maximum object size in bytes for a Memcached object. 

Default value: `52428800` (50 MB). 

##### `druid::cache_memcached_prefix`

Key prefix for all keys in Memcached. 

Default value: `'druid'`. 

##### `druid::cache_size_in_bytes`

Maximum local cache size in bytes. Zero disables caching. 

Default value: `0`. 

##### `druid::cache_timeout`

Maximum time in milliseconds to wait for a response from Memcached. 

Default value: `500`. 

##### `druid::cache_type`

The type of cache to use for queries. 

Valid values: `'local'` or `'memcached'`. 

Default value: `'local'`. 

##### `druid::cache_uncacheable`

All query types to not cache. 

##### `druid::cassandra_host`

Cassandra host to access for deep storage. 

##### `druid::cassandra_keyspace`

Cassandra key space. 

##### `druid::config_dir`

Directory druid will keep configuration files. 

Default value: `'/etc/druid'`. 

##### `druid::curator_compress`

Boolean flag for whether or not created Znodes should be compressed. 

Default value: `true`. 

##### `druid::discovery_curator_path`

Services announce themselves under this ZooKeeper path. 

Default value: `'/druid/discovery'`. 

##### `druid::emitter_http_flush_count`

How many messages can the internal message buffer hold before flushing (sending). 

Default value: `500`. 

##### `druid::emitter_http_flush_millis`

How often to internal message buffer is flushed (data is sent). 

Default value: `60000`. 

##### `druid::emitter_http_recipient_base_url`

The base URL to emit messages to. Druid will POST JSON to be consumed at the HTTP endpoint specified by this property. 

Default value: `''`. 

##### `druid::emitter_http_time_out`

The timeout for data reads. 

Default value: `'PT5M'`. 

##### `druid::emitter_logging_log_level`

The log level at which message are logged. 

Valid values: `'debug'`, `'info'`, `'warn'`, or `'error'`

Default value: `'info'`. 

##### `druid::emitter_logging_logger_class`

The class used for logging. 

Valid values: `'HttpPostEmitter'`, `'LoggingEmitter'`, `'NoopServiceEmitter'`, or `'ServiceEmitter'`

Default value: `'LoggingEmitter'`. 

##### `druid::emitter`

Emitter module to use. 

Valid values: `'noop'`, `'logging'`, or `'http'`. 

Default value: `'logging'`. 

##### `druid::extensions_coordinates`

Array of "groupId:artifactId[:version]" maven coordinates. 

Default value: `[]`. 

##### `druid::extensions_default_version`

Version to use for extension artifacts without version information. 

##### `druid::extensions_local_repository`

The way maven gets dependencies is that it downloads them to a "local repository" on your local disk and then collects the paths to each of the jars. This specifies the directory to consider the "local repository". If this is set, `extensions_remote_repositories` is not required. 

Default value: `'~/.m2/repository'`. 

##### `druid::extensions_remote_repositories`

Array of remote repositories to load dependencies from. 

Default value: `['http://repo1.maven.org/maven2/', 'https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local', ]`. 

##### `druid::extensions_search_current_classloader`

This is a boolean flag that determines if Druid will search the main classloader for extensions. It defaults to true but can be turned off if you have reason to not automatically add all modules on the classpath. 

Default value: `true`. 

##### `druid::hdfs_directory`

HDFS directory to use as deep storage. 

##### `druid::install_dir`

Directory druid will be installed in. 

Default value: `'/usr/local/lib'`. 

##### `druid::java_pkg`

Name of the java package to ensure installed on system. 

Default value: `'openjdk-7-jre-headless'`. 

##### `druid::metadata_storage_connector_create_tables`

Specifies to create tables in the metadata storage if they do not exits. 

Default value: `true`. 

##### `druid::metadata_storage_connector_password`

The password to connect with. 

Default value: `'insecure_pass'`. 

##### `druid::metadata_storage_connector_uri`

The URI for the metadata storage. 

Default value: `'jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8'`

##### `druid::metadata_storage_connector_user`

The username to connect to the metadata storage with. 

Default value: `'druid'`. 

##### `druid::metadata_storage_tables_audit`

The table to use for audit history of configuration changes. 

Default value: `'druid_audit'`. 

##### `druid::metadata_storage_tables_base`

The base name for tables. 

Default value: `'druid'`. 

##### `druid::metadata_storage_tables_config_table`

The table to use to look for configs. 

Default value: `'druid_config'`. 

##### `druid::metadata_storage_tables_rule_table`

The table to use to look for segment load/drop rules. 

Default value: `'druid_rules'`. 

##### `druid::metadata_storage_tables_segment_table`

The table to use to look for segments. 

Default value: `'druid_segments'`. 

##### `druid::metadata_storage_tables_task_lock`

Used by the indexing service to store task locks. 

Default value: `'druid_taskLock'`. 

##### `druid::metadata_storage_tables_task_log`

Used by the indexing service to store task logs. 

Default value: `'druid_taskLog'`. 

##### `druid::metadata_storage_tables_tasks`

The table used by the indexing service to store tasks. 

Default value: `'druid_tasks'`. 

##### `druid::metadata_storage_type`

The type of metadata storage to use. 

Valid values: `'mysql'`, `'postgres'`, or `'derby'`

Default value: `'mysql'`. 

##### `druid::monitoring_emission_period`

How often metrics are emitted. 

Default value: `'PT1m'`. 

##### `druid::monitoring_monitors`

Array of Druid monitors used by a node. See below for names and more information. 

Valid array values:

| Array Value | Description |
| --- | --- |
| `'io.druid.client.cache.CacheMonitor'` | Emits metrics (to logs) about the segment results cache for Historical and Broker nodes. Reports typical cache statistics include hits, misses, rates, and size (bytes and number of entries), as well as timeouts and errors. |
| `'com.metamx.metrics.SysMonitor'` | This uses the SIGAR library to report on various system activities and statuses. Make sure to add the sigar library jar to your classpath if using this monitor. |
| `'io.druid.server.metrics.HistoricalMetricsMonitor'` | Reports statistics on Historical nodes. |
| `'com.metamx.metrics.JvmMonitor'` | Reports JVM-related statistics. |
| `'io.druid.segment.realtime.RealtimeMetricsMonitor'` | Reports statistics on Realtime nodes. |

Default value: `[]`. 

##### `druid::request_logging_dir`

Historical, Realtime and Broker nodes maintain request logs of all of the requests they get (interacton is via POST, so normal request logs don’t generally capture information about the actual query), this specifies the directory to store the request logs in. 

Default value: `''`. 

##### `druid::request_logging_feed`

Feed name for requests. 

Default value: `'druid'`. 

##### `druid::request_logging_type`

Specifies the type of logging used. 

Valid values: `'noop'`, `'file'`, `'emitter'`. 

Default value: `'noop'`. 

##### `druid::s3_access_key`

The access key to use to access S3. 

##### `druid::s3_archive_base_key`

S3 object key prefix for archiving. 

##### `druid::s3_archive_bucket`

S3 bucket name for archiving when running the indexing-service archive task. 

##### `druid::s3_base_key`

S3 object key prefix for storage. 

##### `druid::s3_bucket`

S3 bucket name. 

##### `druid::s3_secret_key`

The secret key to use to access S3. 

##### `druid::selectors_indexing_service_name`

The service name of the indexing service Overlord node. To start the Overlord with a different name, set it with this property. 

Default value: `'druid/overlord'`. 

##### `druid::storage_directory`

Directory on disk to use as deep storage if `$storage_type` is set to `'local'`. 

Default value: `'/tmp/druid/localStorage'`. 

##### `druid::storage_disable_acl`

Boolean flag for ACL. 

Default value: `false`. 

##### `druid::storage_type`

The type of deep storage to use. 

Valid values: `'local'`, `'noop'`, `'s3'`, `'hdfs'`, or `'c*'`

Default value: `'local'`. 

##### `druid::version`
Version of druid to install. 

Default value: `'0.8.1'`. 

##### `druid::zk_paths_announcements_path`

Druid node announcement path. 

##### `druid::zk_paths_base`

Base Zookeeper path. 

Default value: `'/druid'`. 

##### `druid::zk_paths_coordinator_path`

Used by the coordinator for leader election. 

##### `druid::zk_paths_indexer_announcements_path`

Middle managers announce themselves here. 

##### `druid::zk_paths_indexer_base`

Base zookeeper path for indexers. 

##### `druid::zk_paths_indexer_leader_latch_path`

Used for Overlord leader election. 

##### `druid::zk_paths_indexer_status_path`

Parent path for announcement of task statuses. 

##### `druid::zk_paths_indexer_tasks_path`

Used to assign tasks to middle managers. 

##### `druid::zk_paths_live_segments_path`

Current path for where Druid nodes announce their segments. 

##### `druid::zk_paths_load_queue_path`

Entries here cause historical nodes to load and drop segments. 

##### `druid::zk_paths_properties_path`

Zookeeper properties path. 

##### `druid::zk_service_host`

The ZooKeeper hosts to connect to. 

Default value: `'localhost'`. 

##### `druid::zk_service_session_timeout_ms`

ZooKeeper session timeout, in milliseconds. 

Default value: `30000`. 

#### druid::broker

##### `druid::broker::host`

Host address for the service to listen on.

Default value: The `$ipaddress` fact.

##### `druid::broker::port`

Port the service listens on.

Default value: `8082`.

##### `druid::broker::service`

The name of the service.

This is used as a dimension when emitting metrics and alerts.  It is used to differentiate between the various services

Default value: `'druid/broker'`.

##### `druid::broker::balancer_type`

The way connections to historical nodes are balanced.

Valid values:
* `'random'`: Choose randomly.
* `'connectionCount'`: Use node with the fewest active connections.

Default value: `'random'`.

##### `druid::broker::cache_expiration`

Memcached expiration time.

Default value: `2592000` (30 days).

##### `druid::broker::cache_hosts`

Array of Memcached hosts (i.e. '<host:port>').

Default value: `[]`.

##### `druid::broker::cache_initial_size`

Initial size of the hashtable backing the cache.

Default value: `500000`.

##### `druid::broker::cache_log_eviction_count`

If non-zero, log cache eviction every logEvictionCount items.

Default value: `0`.

##### `druid::broker::cache_max_object_size`

Maximum object size in bytes for a Memcached object.

Default value: `52428800` (50 MB).

##### `druid::broker::cache_memcached_prefix`

Key prefix for all keys in Memcached.

Default value: `'druid'`.

##### `druid::broker::cache_populate_cache`

Populate the cache on the broker.

Valid values: `true`, `false`.

Default value: `false`.

##### `druid::broker::cache_size_in_bytes`

Maximum cache size in bytes.

Zero disables caching.

Default value: `0`.

##### `druid::broker::cache_timeout`

Maximum time in milliseconds to wait for a response from Memcached.

Default value: `500`.

##### `druid::broker::cache_type`

Type of cache to use for queries.

Valid values:
* `'local'`: Use local file cache.
* `'memcached'`: Use Memcached.

Default value: `'local'`.

##### `druid::broker::cache_uncacheable`

All query types to not cache.

Default value: `['groupBy', 'select']`.

##### `druid::broker::cache_use_cache`

Enable the cache on the broker.

Valid values: `true`, `false`.

Default value: `false`.

##### `druid::broker::http_num_connections`

Connection pool size.

Specifically, this is the number of connections the Broker uses to connect to historical and real-time nodes. If there are more queries than this number that all need to speak to the same node, then they will queue up.

Default value: `5`.

##### `druid::broker::http_read_timeout`

The timeout for data reads.

Default value: `'PT15M'`.

##### `druid::broker::jvm_opts`

Array of options to set for the JVM running the service.

Default value: `['-server', '-Duser.timezone=UTC', '-Dfile.encoding=UTF-8', '-Djava.io.tmpdir=/tmp', '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager']`

##### `druid::broker::processing_buffer_size_bytes`

Buffer size for the storage of intermediate results.

The computation engine in both the Historical and Realtime nodes will use a scratch buffer of this size to do all of their intermediate computations off-heap. Larger values allow for more aggregations in a single pass over the data while smaller values can require more passes depending on the query that is being executed.

Default value: `1073741824` (1GB).

##### `druid::broker::processing_column_cache_size_bytes`

Maximum size in bytes for the dimension value lookup cache.

Any value greater than 0 enables the cache. It is currently disabled by default. Enabling the lookup cache can significantly improve the performance of aggregators operating on dimension values, such as the JavaScript aggregator, or cardinality aggregator, but can slow things down if the cache hit rate is low (i.e. dimensions with few repeating values). Enabling it may also require additional garbage collection tuning to avoid long GC pauses.

Default value: `0` (disabled).

##### `druid::broker::processing_format_string`

Format string to name processing threads.

Default value: `'processing-%s'`.

##### `druid::broker::processing_num_threads`

Number of processing threads available for processing of segments.

Rule of thumb is num\_cores - 1, which means that even under heavy load there will still be one core available to do background tasks like talking with ZooKeeper and pulling down segments. If only one core is available, this property defaults to the value 1.

##### `druid::broker::query_group_by_max_intermediate_rows`

Maximum number of intermediate rows.

Default value: `50000`.

##### `druid::broker::query_group_by_max_results`

Maximum number of results.

Default value: `500000`.

##### `druid::broker::query_group_by_single_threaded`

Run single threaded group by queries.

Valid values: `true`, `false`.

Default value: `false`.

##### `druid::broker::query_search_max_search_limit`

Maximum number of search results to return.

Default value: `1000`.

##### `druid::broker::retry_policy_num_tries`

Number of tries.

Default value: `1`.

##### `druid::broker::select_tier_custom_priorities`

Array of integer priorities to select server tiers with.

Default value: `[]`.

##### `druid::broker::select_tier`

Preference of tier to select based on priority.

If segments are cross-replicated across tiers in a cluster, you can tell the broker to prefer to select segments in a tier with a certain priority.

Valid values:
* `'highestPriority'`
* `'lowestPriority'`
* `'custom'`

Default value: `'highestPriority'`.

##### `druid::broker::server_http_max_idle_time`

The Jetty max idle time for a connection.

Default value: `'PT5m'`.

##### `druid::broker::server_http_num_threads`

Number of threads for HTTP requests.

Default value: `10`.

#### druid::coordinator

Sets up configuration and manages the Druid coordinator service.

##### `druid::coordinator::host`

Host address the service listens on.

Default value: The `$ipaddress` fact.

##### `druid::coordinator::port`

Port the service listens on.

Default value: `8081`.

##### `druid::coordinator::service`

The name of the service.

This is used as a dimension when emitting metrics and alerts.  It is used to differentiate between the various services

Default value: `'druid/coordinator'`.

##### `druid::coordinator::conversion_on`

Specify if old segment indexing versions should be converted to the latest.

Valid values: `true` or `false`.

Default value: `false`.

##### `druid::coordinator::jvm_opts`

Array of options to set for the JVM running the service.

Default value: `[
    '-server',
    '-Duser.timezone=UTC',
    '-Dfile.encoding=UTF-8',
    '-Djava.io.tmpdir=/tmp',
    '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
  ]`

##### `druid::coordinator::load_timeout`

Time before the coordinator assigns a segment to a historical node.

Default value: `'PT15M'`.

##### `druid::coordinator::manager_config_poll_duration`

Time between polls of the config table for updates.

Default value: `'PT1m'`.

##### `druid::coordinator::manager_rules_alert_threshold`

The duration after a failed poll upon which an alert should be emitted.

Default value: `'PT10M'`.

##### `druid::coordinator::manager_rules_default_tier`

The default tier which default rules will be loaded from.

Default value: `'_default'`.

##### `druid::coordinator::manager_rules_poll_duration`

Time between polls of the set of active rules for updates.

Defines the amount of lag time it can take for the coordinator to notice rule changes.

Default value: `'PT1M'`.

##### `druid::coordinator::manager_segment_poll_duration`

Time between polls of the set of active segments for updates.

Defines the amount of lag time it can take for the coordinator to notice segment changes.

Default value: `'PT1M'`.

##### `druid::coordinator::merge_on`

Specify if the coordinator should try and merge small segments.

This helps keep segements in a more optimal segment size.

Default value: `false`.

##### `druid::coordinator::period`

The run period for the coordinator.

The coordinator’s operates by maintaining the current state of the world in memory and periodically looking at the set of segments available and segments being served to make decisions about whether any changes need to be made to the data topology. This parameter sets the delay between each of these runs.

Default value: `'PT60S'`.

##### `druid::coordinator::period_indexing_period`

How often to send indexing tasks to the indexing service.

Only applies if merge or conversion is turned on.

Default value: `'PT1800S'` (30 mins).

##### `druid::coordinator::start_delay`

Time to let the service think it has all data.

The operation of the Coordinator works on the assumption that it has an up-to-date view of the state of the world when it runs, the current ZK interaction code, however, is written in a way that doesn’t allow the Coordinator to know for a fact that it’s done loading the current state of the world. This delay is a hack to give it enough time to believe that it has all the data.

Default value: `'PT300S'`.

#### druid::historical

Historical node class.

##### `druid::historical::host`

The host for the current node. 

Default value: The `$ipaddress` fact. 

##### `druid::historical::port`

This is the port to actually listen on; unless port mapping is used, this will be the same port as is on `druid::historical::host`. 

Default value: `8083`. 

##### `druid::historical::service`

The name of the service. This is used as a dimension when emitting metrics and alerts to differentiate between the various services

Default value: `'druid/historical'`. 

##### `druid::historical::jvm_opts`

Array of options to set for the JVM running the service.

Default value: `['-server', '-Duser.timezone=UTC', '-Dfile.encoding=UTF-8', '-Djava.io.tmpdir=/tmp', '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager']`

##### `druid::historical::populate_cache`

Populate the cache on the historical. 

Default value: `false`. 

##### `druid::historical::processing_buffer_size_bytes`

This specifies a buffer size for the storage of intermediate results. The computation engine in both the Historical and Realtime nodes will use a scratch buffer of this size to do all of their intermediate computations off-heap. Larger values allow for more aggregations in a single pass over the data while smaller values can require more passes depending on the query that is being executed. 

Default value: `1073741824` (1GB). 

##### `druid::historical::processing_column_cache_size_bytes`

Maximum size in bytes for the dimension value lookup cache. Any value greater than 0 enables the cache.  Enabling the lookup cache can significantly improve the performance of aggregators operating on dimension values, such as the JavaScript aggregator, or cardinality aggregator, but can slow things down if the cache hit rate is low (i.e. dimensions with few repeating values).  Enabling it may also require additional garbage collection tuning to avoid long GC pauses. 

Default value: `0` (disabled). 

##### `druid::historical::processing_format_string`

Realtime and historical nodes use this format string to name their processing threads. 

Default value: `'processing-%s'`. 

##### `druid::historical::processing_num_threads`

The number of processing threads to have available for parallel processing of segments.  Druid will default to using 'num\_cores - 1 || 1'. 

##### `druid::historical::query_groupBy_max_intermediate_rows`

Maximum number of intermediate rows. 

Default value: `50000`. 

##### `druid::historical::query_groupBy_max_results`

Maximum number of results. 

Default value: `500000`. 

##### `druid::historical::query_groupBy_single_threaded`

Run single threaded group By queries. 

Default value: `false`. 

##### `druid::historical::query_search_max_search_limit`

Maximum number of search results to return. 

Default value: `1000`. 

##### `druid::historical::segment_cache_announce_interval_millis`

How frequently to announce segments while segments are loading from cache.  Set this value to zero to wait for all segments to be loaded before announcing. 

Default value: `5000` (5 seconds). 

##### `druid::historical::segment_cache_delete_on_remove`

Delete segment files from cache once a node is no longer serving a segment. 

Default value: `true`. 

##### `druid::historical::segment_cache_drop_segment_delay_millis`

How long a node delays before completely dropping segment. 

Default value: `30000` (30 seconds). 

##### `druid::historical::segment_cache_info_dir`

Historical nodes keep track of the segments they are serving so that when the process is restarted they can reload the same segments without waiting for the Coordinator to reassign. This path defines where this metadata is kept. 

##### `druid::historical::segment_cache_locations`

Segments assigned to a Historical node are first stored on the local file system (in a disk cache) and then served by the Historical node. These locations define where that local cache resides. 

Valid values: 'none' (also `undef`) or an absolute file path. 

##### `druid::historical::segment_cache_num_loading_threads`

How many segments to load concurrently from from deep storage. 

Default value: `1`. 

##### `druid::historical::server_http_max_idle_time`

The Jetty max idle time for a connection. 

Default value: `'PT5m'`. 

##### `druid::historical::server_http_num_threads`

Number of threads for HTTP requests. 

Default value: `10`. 

##### `druid::historical::server_max_size`

The maximum number of bytes-worth of segments that the node wants assigned to it. This is not a limit that Historical nodes actually enforces, just a value published to the Coordinator node so it can plan accordingly. 

Default value: `0`. 

##### `druid::historical::server_priority`

In a tiered architecture, the priority of the tier, thus allowing control over which nodes are queried. Higher numbers mean higher priority. The Druid default (no priority) works for architecture with no cross replication (tiers that have no data-storage overlap). Data centers typically have equal priority. 

Default value: `0`. 

##### `druid::historical::server_tier`

A string to name the distribution tier that the storage node belongs to.  Many of the rules Coordinator nodes use to manage segments can be keyed on tiers. 

Default value: `'_default_tier'`. 

##### `druid::historical::uncacheable`

All query types to not cache. 

Default value: `["groupBy", "select"]`. 

##### `druid::historical::use_cache`

Enable the cache on the historical. 

Default value: `false`. 

#### druid::indexing::overlord

Manages and sets up the indexing overlord.

##### `druid::indexing::overlord::host`

Host address the service listens on.

Default value: The `$ipaddress` fact.

##### `druid::indexing::overlord::port`

Port the service listens on.

Default value: `8090`.

##### `druid::indexing::overlord::service`

The name of the service.

This is used as a dimension when emitting metrics and alerts.  It is used to differentiate between the various services

Default value: `'druid/overlord'`.

##### `druid::indexing::overlord::autoscale`

Enable autoscaling.

Valid values: `true` or `false`.

Default value: `false`.

##### `druid::indexing::overlord::autoscale_max_scaling_duration`

Time to wait for a middle manager to appear before giving up.

Default value: `'PT15M'`.

##### `druid::indexing::overlord::autoscale_num_events_to_track`

The number of autoscaling events to track.

This includes node creation and termination.

Default value: `10`.

##### `druid::indexing::overlord::autoscale_origin_time`

Starting time stamp the terminate period increments upon.

Default value: `'2012-01-01T00:55:00.000Z'`.

##### `druid::indexing::overlord::autoscale_pending_task_timeout`

Time a task can be "pending" before scaling up.

Default value: `'PT30S'`.

##### `druid::indexing::overlord::autoscale_provision_period`

Time window to check if new middle managers should be added.

Default value: `'PT1M'`.

##### `druid::indexing::overlord::autoscale_strategy`

Strategy to run when autoscaling is required.

Valid values: `'noop'` or `'ec2'`.

Default value: `'noop'`.

##### `druid::indexing::overlord::autoscale_terminate_period`

Time window to check if middle managers should be removed.

Default value: `'PT5M'`.

##### `druid::indexing::overlord::autoscale_worker_idle_timeout`

Idle time of a worker before it is considered for termination.

Default value: `'PT90M'`.

##### `druid::indexing::overlord::autoscale_worker_port`

Port that middle managers will listen on.

Default value: `8080`.

##### `druid::indexing::overlord::autoscale_worker_version`

Node versions to create.

If set, the overlord will only create nodes of set version during autoscaling. This overrides dynamic configuration.

##### `druid::indexing::overlord::jvm_opts`

Array of options to set for the JVM running the service.

Default value: `['-server', '-Duser.timezone=UTC', '-Dfile.encoding=UTF-8', '-Djava.io.tmpdir=/tmp', '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager']`

##### `druid::indexing::overlord::queue_max_size`

Maximum number of active tasks at one time.

##### `druid::indexing::overlord::queue_restart_delay`

Sleep time when queue management throws an exception.

Default value: `'PT30S'`.

##### `druid::indexing::overlord::queue_start_delay`

Sleep time before starting overlord queue management.

This can be useful to give a cluster time to re-orient itself (e.g.  after a widespread network issue).

Default value: `'PT1M'`.

##### `druid::indexing::overlord::queue_storage_sync_rate`

Rate to sync state with an underlying task persistence mechanism.

Default value: `'PT1M'`.

##### `druid::indexing::overlord::runner_compress_znodes`

Expect middle managers to compress Znodes.

Valid values: `true` or `false`.

Default value: `true`.

##### `druid::indexing::overlord::runner_max_znode_bytes`

Maximum Znode size in bytes that can be created in Zookeeper.

Default value: `524288`.

##### `druid::indexing::overlord::runner_min_worker_version`

Minimum middle manager version to send tasks to.

Default value: `'0'`.

##### `druid::indexing::overlord::runner_task_assignment_timeout`

Time to wait after a task has been assigned to a middle manager.

Tasks that take longer then this results in an error being thrown.

Default value: `'PT5M'`.

##### `druid::indexing::overlord::runner_task_cleanup_timeout`

Time to wait before failing a task when the middle manager assigned the task becomes disconnected from Zookeeper.

Default value: `'PT15M'`.

##### `druid::indexing::overlord::runner_type`

Specify if tasks are run locally or in a distributed environment.

Valid values: `'local'` or `'remote'`.

Default value: `'local'`.

##### `druid::indexing::overlord::storage_recently_finished_threshold`

Time to store task results.

Default value: `'PT24H'`.

##### `druid::indexing::overlord::storage_type`

Specify where incoming task are stored.

Storing incoming tasks in metadata storage allows for tasks to be resumed if the overlord should fail.

Valid values:

    * `'local'`: In heap
    * `'metadata'`: Metadata storage.

Default value: `'local'`.

#### druid::indexing::middle\_manager

Manages and sets up the indexing middle managers.

##### `druid::indexing::middle_manager::host`

Host address the service listens on.

Default value: The `$ipaddress` fact.

##### `druid::indexing::middle_manager::port`

Port the service listens on.

Default value: `8080`.

##### `druid::indexing::middle_manager::service`

The name of the service.

This is used as a dimension when emitting metrics and alerts.  It is used to differentiate between the various services

Default value: `'druid/middlemanager'`.


##### `druid::indexing::middle_manager::fork_properties`

Hash of explicit child peon config options.

Peons inherit the configurations of their parent middle managers, but if this is undesired for certain config options they can be explicitly passed here.

These key value pairs are expected in Druid config format and are unvalidated.  The keys should NOT include `'druid.indexer.fork.property'` as a prefix.

Example:

```puppet
{
  "druid.monitoring.monitors" => "[\"com.metamx.metrics.JvmMonitor\"]",
  "druid.processing.numThreads" => 2,
}
```

Default value: `{}`

##### `druid::indexing::middle_manager::jvm_opts`

Array of options to set for the JVM running the service.

Default value: `['-server', '-Duser.timezone=UTC', '-Dfile.encoding=UTF-8', '-Djava.io.tmpdir=/tmp', '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager']`

##### `druid::indexing::middle_manager::peon_mode`

Mode peons are run in.

Valid values:

    * `'local'`: Standalone mode (Not recommended).
    * `'remote'`: Pooled.

Default value: `'remote'`.

##### `druid::indexing::middle_manager::remote_peon_max_retry_count`

Max retries a remote peon makes communicating with the overlord.

Default value: `10`.

##### `druid::indexing::middle_manager::remote_peon_max_wait`

Max retry time a remote peon makes communicating with the overlord.

Default value: `'PT10M'`.

##### `druid::indexing::middle_manager::remote_peon_min_wait`

Min retry time a remote peon makes communicating with the overlord.

Default value: `'PT1M'`.

##### `druid::indexing::middle_manager::runner_allowed_prefixes`

Array of prefixes of configs that are passed down to peons.

Default value: `['com.metamx', 'druid', 'io.druid', 'user.timezone', 'file.encoding']`.

##### `druid::indexing::middle_manager::runner_classpath`

Java classpath for the peons.

##### `druid::indexing::middle_manager::runner_compress_znodes`

Specify if Znodes are compressed.

Default value: `true`.

##### `druid::indexing::middle_manager::runner_java_command`

Command for peons to use to execute java.

Default value: `'java'`.

##### `druid::indexing::middle_manager::runner_java_opts`

Java "-X" options for the peon to use in its own JVM.

##### `druid::indexing::middle_manager::runner_max_znode_bytes`

Maximum Znode size in bytes that can be created in Zookeeper.

Default value: `524288`.

##### `druid::indexing::middle_manager::runner_start_port`

Port peons begin running on.

Default value: `8100`.

##### `druid::indexing::middle_manager::task_base_dir`

Base temporary working directory.

Default value: `'/tmp'`.

##### `druid::indexing::middle_manager::task_base_task_dir`

Base temporary working directory for tasks.

Default value: `'/tmp/persistent/tasks'`.

##### `druid::indexing::middle_manager::task_chat_handler_type`

Specify service discovery type.

Certain tasks will use service discovery to announce an HTTP endpoint that events can be posted to.

Valid values: `'noop'` or `'announce'`.

Default value: `'noop'`.

##### `druid::indexing::middle_manager::task_default_hadoop_coordinates`

Array of default Hadoop version to use.

This is used with HadoopIndexTasks that do not request a particular version.

Default value: `['org.apache.hadoop:hadoop-client:2.3.0']`.

##### `druid::indexing::middle_manager::task_default_row_flush_boundary`

Highest row count before persisting to disk.

Used for indexing generating tasks.

Default value: `50000`.

##### `druid::indexing::middle_manager::task_hadoop_working_path`

Temporary working directory for Hadoop tasks.

Default value: `'/tmp/druid-indexing'`.

##### `druid::indexing::middle_manager::worker_capacity`

Maximum number of tasks to accept.

##### `druid::indexing::middle_manager::worker_ip`

The IP of the worker.

Default value: `'localhost'`.

##### `druid::indexing::middle_manager::worker_version`

Version identifier for the middle manager.

Default value: `'0'`.

#### druid::realtime

Sets up configuration and manages the Druid realtime service.

##### `druid::realtime::host`

Host address the service listens on.

Default value: The `$ipaddress` fact.

##### `druid::realtime::port`

Port the service listens on.

Default value: `8084`.

##### `druid::realtime::service`

The name of the service.

This is used as a dimension when emitting metrics and alerts.  It is used to differentiate between the various services

Default value: `'druid/realtime'`.

##### `druid::realtime::jvm_opts`

Array of options to set for the JVM running the service.

Default value: `[
    '-server',
    '-Duser.timezone=UTC',
    '-Dfile.encoding=UTF-8',
    '-Djava.io.tmpdir=/tmp',
    '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
  ]`

##### `druid::realtime::processing_buffer_size_bytes`

Buffer size for the storage of intermediate results.

The computation engine uses a scratch buffer of this size to do all intermediate computations off-heap. Larger values allow for more aggregations in a single pass over the data while smaller values can require more passes depending on the query that is being executed.

Default value: `1073741824` (1GB).

##### `druid::realtime::processing_column_cache_size_bytes`

Maximum size in bytes for the dimension value lookup cache.

Any value greater than `0` enables the cache. Enabling the lookup cache can significantly improve the performance of aggregators operating on dimension values, such as the JavaScript aggregator, or cardinality aggregator, but can slow things down if the cache hit rate is low (i.e.  dimensions with few repeating values). Enabling it may also require additional garbage collection tuning to avoid long GC pauses.

Default value: `0` (disabled).

##### `druid::realtime::processing_format_string`

Format string to name processing threads.

Default value: `'processing-%s'`.

##### `druid::realtime::processing_num_threads`

Number of processing threads for processing of segments.

Rule of thumb is num\_cores - 1, which means that even under heavy load there will still be one core available to do background tasks like talking with ZooKeeper and pulling down segments.

##### `druid::realtime::publish_type`

Where to publish segments.

Valid values: `'noop'` or `'metadata'`.

Default value: `'metadata'`.

##### `druid::realtime::query_group_by_max_intermediate_rows`

Maximum number of intermediate rows.

Default value: `50000`.

##### `druid::realtime::query_group_by_max_results`

Maximum number of results.

Default value: `500000`.

##### `druid::realtime::query_group_by_single_threaded`

Run single threaded `groupBy` queries.

Default value: `false`.

##### `druid::realtime::query_search_max_search_limit`

Maximum number of search results to return.

Default value: `1000`.

##### `druid::realtime::segment_cache_locations`

Where intermediate segments are stored.

##### `druid::realtime::spec_file`

File location of realtime specFile.

##### `druid::realtime::spec_file_content`

Content to ensure in spec\_file.

### Private Defined Types

#### druid::service

Resource used to setup common files needed for Druic services.

##### `druid::indexing::middle_manager::service_name`

Name the service is known by (e.g historical, broker, realtime, ...).

Default value: `$namevar`

##### `druid::service::config_content`

Required content of the service properties file.

##### `druid::serviceservice_content`

Required content of the systemd service file.

## Limitations

The module has been designed to run on a Debian based system using systemd as a service manager.

Testing is currently only being done on Debian 8 (Jessie).
