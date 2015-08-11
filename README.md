# druid

#### Table of Contents

1. [Module Description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with druid](#setup)
    * [What druid affects](#what-druid-affects)
    * [Beginning with druid](#beginning-with-druid)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Limitations](#limitations)

## Module Description

[Druid](druid.io) is a data store solutions designed for online analytical processing of time-series data.  This module is used to managing nodes in a Druid cluster that run the Druid service, namely: Historical, Broker, Coordinator, Indexing Service, and Realtime nodes.

This module assumes that the deep storage, metadata storage, and ZooKeeper portions of the Druid cluster are managed elsewhere.

## Setup

### What druid affects

* Installs the Druid jars to the local filesystem.
* Created Druid configuration files on the local filesystem.

### Beginning with druid

The module is designed to be called differently depending on the type of Druid service the node should be running.  However, the service can be setup with a bare bones common configuration by just including the main class:

```puppet
include druid
```

## Usage

Put the classes, types, and resources for customizing, configuring, and doing
the fancy stuff with your module here.

## Reference

### Classes

#### druid

The main module class.  This class is not intended to be called directly. All parameters a expected to be configured via hiera, but support is still provided to directly configure this class as a puppet class resource directly.

##### `druid::version`
Version of druid to install.

Defaults to '0.8.0'.

##### `druid::java_pkg`

Name of the java package to ensure installed on system.

Defaults to 'openjdk-7-jre-headless'.

##### `druid::install_dir`

Directory druid will be installed in.

Defaults to '/usr/local/lib'.

##### `druid::config_dir`

Directory druid will keep configuration files.

Defaults to '/etc/druid'.

##### `druid::extensions_remote_repositories`

Array of remote repositories to load dependencies from.

Defaults to `['http://repo1.maven.org/maven2/', 'https://metamx.artifactoryonline.com/metamx/pub-libs-releases-local', ]`.

##### `druid::extensions_local_repository`

The way maven gets dependencies is that it downloads them to a "local repository" on your local disk and then collects the paths to each of the jars. This specifies the directory to consider the "local repository". If this is set, `extensions_remote_repositories` is not required.

Defaults to `'~/.m2/repository'`.

##### `druid::extensions_coordinates`

Array of "groupId:artifactId[:version]" maven coordinates.

Defaults to `[]`.

##### `druid::extensions_default_version`

Version to use for extension artifacts without version information.

##### `druid::extensions_search_current_classloader`

This is a boolean flag that determines if Druid will search the main classloader for extensions. It defaults to true but can be turned off if you have reason to not automatically add all modules on the classpath.

Defaults to `true`.

##### `druid::zk_paths_base`

Base Zookeeper path.

Defaults to `'/druid'`.

##### `druid::zk_service_host`

The ZooKeeper hosts to connect to.

Defaults to `'localhost'`.

##### `druid::zk_service_session_timeout_ms`

ZooKeeper session timeout, in milliseconds.

Defaults to `30000`.

##### `druid::curator_compress`

Boolean flag for whether or not created Znodes should be compressed.

Defaults to `true`.

##### `druid::zk_paths_base`

Base Zookeeper path.

Defaults to `'/druid'`.

##### `druid::zk_paths_properties_path`

Zookeeper properties path.

##### `druid::zk_paths_announcements_path`

Druid node announcement path.

##### `druid::zk_paths_live_segments_path`

Current path for where Druid nodes announce their segments.

##### `druid::zk_paths_load_queue_path`

Entries here cause historical nodes to load and drop segments.

##### `druid::zk_paths_coordinator_path`

Used by the coordinator for leader election.

##### `druid::zk_paths_indexer_base`

Base zookeeper path for indexers.

##### `druid::zk_paths_indexer_announcements_path`

Middle managers announce themselves here.

##### `druid::zk_paths_indexer_tasks_path`

Used to assign tasks to middle managers.

##### `druid::zk_paths_indexer_status_path`

Parent path for announcement of task statuses.

##### `druid::zk_paths_indexer_leader_latch_path`

Used for Overlord leader election.

##### `druid::discovery_curator_path`

Services announce themselves under this ZooKeeper path.

Defaults to `'/druid/discovery'`.

##### `druid::request_logging_type`

Specifies the type of logging used.

Valid values: `'noop'`, `'file'`, `'emitter'`.

Defaults to `'noop'`.

##### `druid::request_logging_dir`

Historical, Realtime and Broker nodes maintain request logs of all of the requests they get (interacton is via POST, so normal request logs don’t generally capture information about the actual query), this specifies the directory to store the request logs in.

Defaults to `''`.

##### `druid::request_logging_feed`

Feed name for requests.

Defaults to `'druid'`.

##### `druid::monitoring_emission_period`

How often metrics are emitted.

Defaults to `'PT1m'`.

##### `druid::monitoring_monitors`

Array of Druid monitors used by a node. See below for names and more information.

Valid array values are:

| Array Value | Description |
| --- | --- |
| `'io.druid.client.cache.CacheMonitor'` | Emits metrics (to logs) about the segment results cache for Historical and Broker nodes. Reports typical cache statistics include hits, misses, rates, and size (bytes and number of entries), as well as timeouts and errors. |
| `'com.metamx.metrics.SysMonitor'` | This uses the SIGAR library to report on various system activities and statuses. Make sure to add the sigar library jar to your classpath if using this monitor. |
| `'io.druid.server.metrics.HistoricalMetricsMonitor'` | Reports statistics on Historical nodes. |
| `'com.metamx.metrics.JvmMonitor'` | Reports JVM-related statistics. |
| `'io.druid.segment.realtime.RealtimeMetricsMonitor'` | Reports statistics on Realtime nodes. |

Defaults to `[]`.

##### `druid::emitter`

Emitter module to use.

Valid values are: `'noop'`, `'logging'`, or `'http'`.

Defaults to `'logging'`.

##### `druid::emitter_logging_logger_class`

The class used for logging.

Valid values are: `'HttpPostEmitter'`, `'LoggingEmitter'`, `'NoopServiceEmitter'`, or `'ServiceEmitter'`

Defaults to `'LoggingEmitter'`.

##### `druid::emitter_logging_log_level`

The log level at which message are logged.

Valid values are: `'debug'`, `'info'`, `'warn'`, or `'error'`

Defaults to `'info'`.

##### `druid::emitter_http_time_out`

The timeout for data reads.

Defaults to `'PT5M'`.

##### `druid::emitter_http_flush_millis`

How often to internal message buffer is flushed (data is sent).

Defaults to `60000`.

##### `druid::emitter_http_flush_count`

How many messages can the internal message buffer hold before flushing (sending).

Defaults to `500`.

##### `druid::emitter_http_recipient_base_url`

The base URL to emit messages to. Druid will POST JSON to be consumed at the HTTP endpoint specified by this property.

Defaults to `''`.

##### `druid::metadata_storage_type`

The type of metadata storage to use.

Valid values are: `'mysql'`, `'postgres'`, or `'derby'`

Defaults to `'mysql'`.

##### `druid::metadata_storage_connector_uri`

The URI for the metadata storage.

Defaults to `'jdbc:mysql://localhost:3306/druid?characterEncoding=UTF-8'`

##### `druid::metadata_storage_connector_user`

The username to connect to the metadata storage with.

Defaults to `'druid'`.

##### `druid::metadata_storage_connector_password`

The password to connect with.

Defaults to `'insecure_pass'`.

##### `druid::metadata_storage_connector_create_tables`

Specifies to create tables in the metadata storage if they do not exits.

Defaults to `true`.

##### `druid::metadata_storage_tables_base`

The base name for tables.

Defaults to `'druid'`.

##### `druid::metadata_storage_tables_segment_table`

The table to use to look for segments.

Defaults to `'druid_segments'`.

##### `druid::metadata_storage_tables_rule_table`

The table to use to look for segment load/drop rules.

Defaults to `'druid_rules'`.

##### `druid::metadata_storage_tables_config_table`

The table to use to look for configs.

Defaults to `'druid_config'`.

##### `druid::metadata_storage_tables_tasks`

The table used by the indexing service to store tasks.

Defaults to `'druid_tasks'`.

##### `druid::metadata_storage_tables_task_log`

Used by the indexing service to store task logs.

Defaults to `'druid_taskLog'`.

##### `druid::metadata_storage_tables_task_lock`

Used by the indexing service to store task locks.

Defaults to `'druid_taskLock'`.

##### `druid::metadata_storage_tables_audit`

The table to use for audit history of configuration changes.

Defaults to `'druid_audit'`.

##### `druid::storage_type`

The type of deep storage to use.

Valid values are: `'local'`, `'noop'`, `'s3'`, `'hdfs'`, or `'c*'` 

Defaults to `'local'`.

##### `druid::storage_directory`

Directory on disk to use as deep storage if `$storage_type` is set to `'local'`.

Defaults to `'/tmp/druid/localStorage'`.

##### `druid::s3_access_key`

The access key to use to access S3.

##### `druid::s3_secret_key`

The secret key to use to access S3.

##### `druid::s3_bucket`

S3 bucket name.

##### `druid::s3_base_key`

S3 object key prefix for storage.

##### `druid::storage_disable_acl`

Boolean flag for ACL.

Defaults to `false`.

##### `druid::s3_archive_bucket`

S3 bucket name for archiving when running the indexing-service archive task.

##### `druid::s3_archive_base_key`

S3 object key prefix for archiving.

##### `druid::hdfs_directory`

HDFS directory to use as deep storage.

##### `druid::cassandra_host`

Cassandra host to access for deep storage.

##### `druid::cassandra_keyspace`

Cassandra key space.

##### `druid::cache_type`

The type of cache to use for queries.

Valid values: `'local'` or `'memcached'`.

Defaults to `'local'`.

##### `druid::cache_uncacheable`

All query types to not cache.

##### `druid::cache_size_in_bytes`

Maximum local cache size in bytes. Zero disables caching.

Defaults to `0`.

##### `druid::cache_initial_size`

Initial size of the hashtable backing the local cache.

Defaults to `500000`.

##### `druid::cache_log_eviction_count`

If non-zero, log local cache eviction for that many items.

Defaults to `0`.

##### `druid::cache_expiration`

Memcached expiration time.

Defaults to `2592000` (30 days).

##### `druid::cache_timeout`

Maximum time in milliseconds to wait for a response from Memcached.

Defaults to `500`.

##### `druid::cache_hosts`

Array of Memcached hosts (`'host:port'`).

Defaults to `[]`.

##### `druid::cache_max_object_size`

Maximum object size in bytes for a Memcached object.

Defaults to `52428800` (50 MB).

##### `druid::cache_memcached_prefix`

Key prefix for all keys in Memcached.

Defaults to `'druid'`.

##### `druid::selectors_indexing_service_name`

The service name of the indexing service Overlord node. To start the Overlord with a different name, set it with this property.

Defaults to `'druid/overlord'`.

##### `druid::announcer_type`

The type of data segment announcer to use.

Valid values are: `'legacy'` or `'batch'`.

Defaults to `'batch'`.

##### `druid::announcer_segments_per_node`

Each Znode contains info for up to this many segments.

Defaults to `50`.

##### `druid::announcer_max_bytes_per_node`

Max byte size for Znode.

Defaults to `524288`.

#### druid::historical

Historical node class.

##### `druid::historical::host`

The host for the current node.

Defaults to the facter defined `$ipaddress`.

##### `druid::historical::port`

This is the port to actually listen on; unless port mapping is used, this will be the same port as is on `druid::historical::host`.

Defaults to `8083`.

##### `druid::historical::service`

The name of the service. This is used as a dimension when emitting metrics and alerts to differentiate between the various services

Defaults to `'druid/historical'`.

##### `druid::historical::server_max_size`

The maximum number of bytes-worth of segments that the node wants assigned to it. This is not a limit that Historical nodes actually enforces, just a value published to the Coordinator node so it can plan accordingly.

Defaults to `0`.

##### `druid::historical::server_tier`

A string to name the distribution tier that the storage node belongs to.  Many of the rules Coordinator nodes use to manage segments can be keyed on tiers.

Defaults to `'_default_tier'`.

##### `druid::historical::server_priority`

In a tiered architecture, the priority of the tier, thus allowing control over which nodes are queried. Higher numbers mean higher priority. The Druid default (no priority) works for architecture with no cross replication (tiers that have no data-storage overlap). Data centers typically have equal priority.

Defaults to `0`.

##### `druid::historical::segment_cache_locations`

Segments assigned to a Historical node are first stored on the local file system (in a disk cache) and then served by the Historical node. These locations define where that local cache resides.

Valid values are 'none' (also `undef`) or an absolute file path.

##### `druid::historical::segment_cache_delete_on_remove`

Delete segment files from cache once a node is no longer serving a segment.

Defaults to `true`.

##### `druid::historical::segment_cache_drop_segment_delay_millis`

How long a node delays before completely dropping segment.

Defaults to `30000` (30 seconds).

##### `druid::historical::segment_cache_info_dir`

Historical nodes keep track of the segments they are serving so that when the process is restarted they can reload the same segments without waiting for the Coordinator to reassign. This path defines where this metadata is kept.

##### `druid::historical::segment_cache_announce_interval_millis`

How frequently to announce segments while segments are loading from cache.  Set this value to zero to wait for all segments to be loaded before announcing.

Defaults to `5000` (5 seconds).

##### `druid::historical::segment_cache_num_loading_threads`

How many segments to load concurrently from from deep storage.

Defaults to `1`.

##### `druid::historical::server_http_num_threads`

Number of threads for HTTP requests.

Defaults to `10`.

##### `druid::historical::server_http_max_idle_time`

The Jetty max idle time for a connection.

Defaults to `'PT5m'`.

##### `druid::historical::processing_buffer_size_bytes`

This specifies a buffer size for the storage of intermediate results. The computation engine in both the Historical and Realtime nodes will use a scratch buffer of this size to do all of their intermediate computations off-heap. Larger values allow for more aggregations in a single pass over the data while smaller values can require more passes depending on the query that is being executed.

Defaults to `1073741824` (1GB).

##### `druid::historical::processing_format_string`

Realtime and historical nodes use this format string to name their processing threads.

Defaults to `'processing-%s'`.

##### `druid::historical::processing_num_threads`

The number of processing threads to have available for parallel processing of segments.  Druid will default to using 'num_cores - 1 || 1'.

##### `druid::historical::processing_column_cache_size_bytes`

Maximum size in bytes for the dimension value lookup cache. Any value greater than 0 enables the cache.  Enabling the lookup cache can significantly improve the performance of aggregators operating on dimension values, such as the JavaScript aggregator, or cardinality aggregator, but can slow things down if the cache hit rate is low (i.e. dimensions with few repeating values).  Enabling it may also require additional garbage collection tuning to avoid long GC pauses.

Defaults to `0` (disabled).

##### `druid::historical::query_groupBy_single_threaded`

Run single threaded group By queries.

Defaults to `false`.

##### `druid::historical::query_groupBy_max_intermediate_rows`

Maximum number of intermediate rows.

Defaults to `50000`.

##### `druid::historical::query_groupBy_max_results`

Maximum number of results.

Defaults to `500000`.

##### `druid::historical::query_search_max_search_limit`

Maximum number of search results to return.

Defaults to `1000`.

##### `druid::historical::use_cache`

Enable the cache on the historical.

Defaults to `false`.

##### `druid::historical::populate_cache`

Populate the cache on the historical.

Defaults to `false`.

##### `druid::historical::uncacheable`

All query types to not cache.

Defaults to `["groupBy", "select"]`.

##### `druid::historical::max_mem_allocation_pool`

Maximum amount of memory the JVM will allocate for it's heep.

Defaults to 25% of the systems total memory or 250 MB (whichever is larger).

##### `druid::historical::min_mem_allocation_pool`

Minimum amount of memory the JVM will allocate for it's heep.

Defaults to 25% of the systems total memory or 250 MB (whichever is larger).

##### `druid::historical::new_gen_max_size`

Maximum JVM new generation memory size.

##### `druid::historical::new_gen_min_size`

Minimum JVM new generation memory size.

##### `druid::historical::max_direct_byte_buffer_size`

Maximum memory the JVM will reserve for all Direct Byte Buffers.

##### `druid::historical::use_concurrent_mark_sweep_gc`

Specifies if the JVM should use concurrent mark-sweep collection for the old generation.

Defaults to `true`.

##### `druid::historical::print_gc_details`

Specifies if the JVM should print garbage collection details.

Defaults to `true`.

##### `druid::historical::print_gc_time_stamps`

Specifies if the JVM should print garbage collection time stamps.

Defaults to `true`.

##### `druid::historical::jvm_default_timezone`

Sets the default time zone of the JVM.

Defaults to `'UTC'`.

##### `druid::historical::jvm_file_encoding`

Sets the default file encoding of the JVM.

Defaults to `'UTF-8'`.

##### `druid::historical::logging_manager`

Specifies the logging manager to use for the JVM.

Defaults to `'org.apache.logging.log4j.jul.LogManager'`.

##### `druid::historical::jvm_tmp_dir`

Specifies the tmp directory for the JVM.

Many production systems are set up to have small (but fast) /tmp directories, which can be problematic with Druid so it is recommend to point the JVM’s tmp directory to something with a little more meat.

## Limitations

The module has been designed to run on a Debian based system using systemd as a service manager.

Currently it has only received testing on a Debian 8 (Jessie) system.
