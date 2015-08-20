# == Class: druid::broker
#
# Setup a Druid node runing the broker service.
#
# === Parameters
#
# [*host*]
#   Host address for the service to listen on.
#
#   Default value: The `$ipaddress` fact.
#
# [*port*]
#   Port the service listens on.
#
#   Default value: `8082`.
#
# [*service*]
#   The name of the service.
#
#   This is used as a dimension when emitting metrics and alerts.  It is
#   used to differentiate between the various services
#
#   Default value: `'druid/broker'`.
#
# [*balancer_type*]
#   The way connections to historical nodes are balanced.
#
#   Valid values:
#     * `'random'`: Choose randomly.
#     * `'connectionCount'`: Use node with the fewest active connections.
#
#   Default value: `'random'`.
#
# [*cache_expiration*]
#   Memcached expiration time.
#
#   Default value: `2592000` (30 days).
#
# [*cache_hosts*]
#   Array of Memcached hosts (i.e. '<host:port>').
#
#   Default value: `[]`.
#
# [*cache_initial_size*]
#   Initial size of the hashtable backing the cache.
#
#   Default value: `500000`.
#
# [*cache_log_eviction_count*]
#   If non-zero, log cache eviction every logEvictionCount items.
#
#   Default value: `0`.
#
# [*cache_max_object_size*]
#   Maximum object size in bytes for a Memcached object.
#
#   Default value: `52428800` (50 MB).
#
# [*cache_memcached_prefix*]
#   Key prefix for all keys in Memcached.
#
#   Default value: `'druid'`.
#
# [*cache_populate_cache*]
#   Populate the cache on the broker.
#
#   Valid values: `true`, `false`.
#
#   Default value: `false`.
#
# [*cache_size_in_bytes*]
#   Maximum cache size in bytes.
#
#   Zero disables caching.
#
#   Default value: `0`.
#
# [*cache_timeout*]
#   Maximum time in milliseconds to wait for a response from Memcached.
#
#   Default value: `500`.
#
# [*cache_type*]
#   Type of cache to use for queries.
#
#   Valid values:
#     * `'local'`: Use local file cache.
#     * `'memcached'`: Use Memcached.
#
#   Default value: `'local'`.
#
# [*cache_uncacheable*]
#   All query types to not cache.
#
#   Default value: `['groupBy', 'select']`.
#
# [*cache_use_cache*]
#   Enable the cache on the broker.
#
#   Valid values: `true`, `false`.
#
#   Default value: `false`.
#
# [*http_num_connections*]
#   Connection pool size.
#
#   Specifically, this is the number of connections the Broker uses to
#   connect to historical and real-time nodes. If there are more queries
#   than this number that all need to speak to the same node, then they
#   will queue up.
#
#   Default value: `5`.
#
# [*http_read_timeout*]
#   The timeout for data reads.
#
#   Default value: `'PT15M'`.

# [*jvm_default_timezone*]
#   Sets the default time zone of the JVM.
#
#   Default value: `'UTC'`.
#
# [*jvm_file_encoding*]
#   Sets the default file encoding of the JVM.
#
#   Default value: `'UTF-8'`.
#
# [*jvm_logging_manager*]
#   Specifies the logging manager to use for the JVM.
#
#   Default value: `'org.apache.logging.log4j.jul.LogManager'`.
#
# [*jvm_max_direct_byte_buffer_size*]
#   Maximum memory the JVM will reserve for all Direct Byte Buffers.
#
# [*jvm_max_mem_allocation_pool*]
#   Maximum amount of memory the JVM will allocate for it's heep.
#
#   Default value: 10% of total memory or 250 MB (whichever is larger).
#
# [*jvm_min_mem_allocation_pool*]
#   Minimum amount of memory the JVM will allocate for it's heep.
#
#   Default value: 10% of total memory or 250 MB (whichever is larger).
#
# [*jvm_new_gen_max_size*]
#   Maximum JVM new generation memory size.
#
# [*jvm_new_gen_min_size*]
#   Minimum JVM new generation memory size.
#
# [*jvm_print_gc_details*]
#   Specifies if the JVM should print garbage collection details.
#
#   Default value: `true`.
#
# [*jvm_print_gc_time_stamps*]
#   Specifies if the JVM should print garbage collection time stamps.
#
#   Default value: `true`.
#
# [*jvm_tmp_dir*]
#   Specifies the tmp directory for the JVM.
#
#   Many production systems are set up to have small (but fast) /tmp
#   directories, which can be problematic with Druid so it is
#   recommend to point the JVM’s tmp directory to something with a little
#   more meat.
#
# [*jvm_use_concurrent_mark_sweep_gc*]
#   Specifies if the JVM should use concurrent mark-sweep collection for
#   the old generation.
#
#   Default value: `true`.
#
# [*processing_buffer_size_bytes*]
#   Buffer size for the storage of intermediate results.
#
#   The computation engine in both the Historical and Realtime nodes will
#   use a scratch buffer of this size to do all of their intermediate
#   computations off-heap. Larger values allow for more aggregations in a
#   single pass over the data while smaller values can require more passes
#   depending on the query that is being executed.
#
#   Default value: `1073741824` (1GB).
#
# [*processing_column_cache_size_bytes*]
#   Maximum size in bytes for the dimension value lookup cache.
#
#   Any value greater than 0 enables the cache. It is currently disabled by
#   default. Enabling the lookup cache can significantly improve the
#   performance of aggregators operating on dimension values, such as the
#   JavaScript aggregator, or cardinality aggregator, but can slow things
#   down if the cache hit rate is low (i.e. dimensions with few repeating
#   values). Enabling it may also require additional garbage collection
#   tuning to avoid long GC pauses.
#
#   Default value: `0` (disabled).
#
# [*processing_format_string*]
#   Format string to name processing threads.
#
#   Default value: `'processing-%s'`.
#
# [*processing_num_threads*]
#   Number of processing threads available for processing of segments.
#
#   Rule of thumb is num_cores - 1, which means that even under heavy load
#   there will still be one core available to do background tasks like
#   talking with ZooKeeper and pulling down segments. If only one core is
#   available, this property defaults to the value 1.
#
# [*query_group_by_max_intermediate_rows*]
#   Maximum number of intermediate rows.
#
#   Default value: `50000`.
#
# [*query_group_by_max_results*]
#   Maximum number of results.
#
#   Default value: `500000`.
#
# [*query_group_by_single_threaded*]
#   Run single threaded group by queries.
#
#   Valid values: `true`, `false`.
#
#   Default value: `false`.
#
# [*query_search_max_search_limit*]
#   Maximum number of search results to return.
#
#   Default value: `1000`.
#
# [*retry_policy_num_tries*]
#   Number of tries.
#
#   Default value: `1`.
#
# [*select_tier_custom_priorities*]
#   Array of integer priorities to select server tiers with.
#
#   Default value: `[]`.
#
# [*select_tier*]
#   Preference of tier to select based on priority.
#
#   If segments are cross-replicated across tiers in a cluster, you can tell
#   the broker to prefer to select segments in a tier with a certain
#   priority.
#
#   Valid values:
#     * `'highestPriority'`
#     * `'lowestPriority'`
#     * `'custom'`
#
#   Default value: `'highestPriority'`.
#
# [*server_http_max_idle_time*]
#   The Jetty max idle time for a connection.
#
#   Default value: `'PT5m'`.
#
# [*server_http_num_threads*]
#   Number of threads for HTTP requests.
#
#   Default value: `10`.
#
# === Examples
#
#  class { 'druid::broker': }
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
class druid::broker (
  $host                                 = hiera("${module_name}::broker::host", $::ipaddress),
  $port                                 = hiera("${module_name}::broker::port", 8082),
  $service                              = hiera("${module_name}::broker::service", 'druid/broker'),
  $balancer_type                        = hiera("${module_name}::broker::balancer_type", 'random'),
  $cache_expiration                     = hiera("${module_name}::broker::cache_expiration", 2592000),
  $cache_hosts                          = hiera_array("${module_name}::broker::cache_hosts", []),
  $cache_initial_size                   = hiera("${module_name}::broker::cache_initial_size", 500000),
  $cache_log_eviction_count             = hiera("${module_name}::broker::cache_log_eviction_count", 0),
  $cache_max_object_size                = hiera("${module_name}::broker::cache_max_object_size", 52428800),
  $cache_memcached_prefix               = hiera("${module_name}::broker::cache_memcached_prefix", 'druid'),
  $cache_populate_cache                 = hiera("${module_name}::broker::cache_populate_cache", false),
  $cache_size_in_bytes                  = hiera("${module_name}::broker::cache_size_in_bytes", 0),
  $cache_timeout                        = hiera("${module_name}::broker::cache_timeout", 500),
  $cache_type                           = hiera("${module_name}::broker::cache_type", 'local'),
  $cache_uncacheable                    = hiera("${module_name}::broker::cache_uncacheable", ['groupBy', 'select']),
  $cache_use_cache                      = hiera("${module_name}::broker::cache_use_cache", false),
  $http_num_connections                 = hiera("${module_name}::broker::http_num_connections", 5),
  $http_read_timeout                    = hiera("${module_name}::broker::http_read_timeout", 'PT15M'),
  $jvm_default_timezone                 = hiera("${module_name}::broker::jvm_default_timezone", 'UTC'),
  $jvm_file_encoding                    = hiera("${module_name}::broker::jvm_file_encoding", 'UTF-8'),
  $jvm_logging_manager                  = hiera("${module_name}::broker::jvm_logging_manager", 'org.apache.logging.log4j.jul.LogManager'),
  $jvm_max_direct_byte_buffer_size      = hiera("${module_name}::broker::jvm_max_direct_byte_buffer_size", undef),
  $jvm_max_mem_allocation_pool          = hiera("${module_name}::broker::jvm_max_mem_allocation_pool", percent_mem(10, '250m')),
  $jvm_min_mem_allocation_pool          = hiera("${module_name}::broker::jvm_min_mem_allocation_pool", percent_mem(10, '250m')),
  $jvm_new_gen_max_size                 = hiera("${module_name}::broker::jvm_new_gen_max_size", undef),
  $jvm_new_gen_min_size                 = hiera("${module_name}::broker::jvm_new_gen_min_size", undef),
  $jvm_print_gc_details                 = hiera("${module_name}::broker::jvm_print_gc_details", true),
  $jvm_print_gc_time_stamps             = hiera("${module_name}::broker::jvm_print_gc_time_stamps", true),
  $jvm_tmp_dir                          = hiera("${module_name}::broker::jvm_tmp_dir", undef),
  $jvm_use_concurrent_mark_sweep_gc     = hiera("${module_name}::broker::jvm_use_concurrent_mark_sweep_gc", true),
  $processing_buffer_size_bytes         = hiera("${module_name}::broker::processing_buffer_size_bytes", 1073741824),
  $processing_column_cache_size_bytes   = hiera("${module_name}::broker::processing_column_cache_size_bytes", 0),
  $processing_format_string             = hiera("${module_name}::broker::processing_format_string", 'processing-%s'),
  $processing_num_threads               = hiera("${module_name}::broker::processing_num_threads", undef),
  $query_group_by_max_intermediate_rows = hiera("${module_name}::broker::query_group_by_max_intermediate_rows", 50000),
  $query_group_by_max_results           = hiera("${module_name}::broker::query_group_by_max_results", 500000),
  $query_group_by_single_threaded       = hiera("${module_name}::broker::query_group_by_single_threaded", false),
  $query_search_max_search_limit        = hiera("${module_name}::broker::query_search_max_search_limit", 1000),
  $retry_policy_num_tries               = hiera("${module_name}::broker::retry_policy_num_tries", 1),
  $select_tier_custom_priorities        = hiera_array("${module_name}::broker::select_tier_custom_priorities", []),
  $select_tier                          = hiera("${module_name}::broker::select_tier", 'highestPriority'),
  $server_http_max_idle_time            = hiera("${module_name}::broker::server_http_max_idle_time", 'PT5m'),
  $server_http_num_threads              = hiera("${module_name}::broker::server_http_num_threads", 10),
) {
  require druid

  validate_string(
    $service,
    $balancer_type,
    $cache_memcached_prefix,
    $cache_type,
    $http_read_timeout,
    $jvm_default_timezone,
    $jvm_file_encoding,
    $jvm_logging_manager,
    $jvm_max_direct_byte_buffer_size,
    $jvm_max_mem_allocation_pool,
    $jvm_min_mem_allocation_pool,
    $jvm_new_gen_max_size,
    $jvm_new_gen_min_size,
    $jvm_tmp_dir,
    $processing_format_string,
    $select_tier,
    $server_http_max_idle_time,
  )

  validate_integer($port)
  validate_integer($cache_expiration)
  validate_integer($cache_initial_size)
  validate_integer($cache_log_eviction_count)
  validate_integer($cache_max_object_size)
  validate_integer($cache_size_in_bytes)
  validate_integer($cache_timeout)
  validate_integer($http_num_connections)
  validate_integer($processing_buffer_size_bytes)
  validate_integer($processing_column_cache_size_bytes)
  validate_integer($query_group_by_max_intermediate_rows)
  validate_integer($query_group_by_max_results)
  validate_integer($query_search_max_search_limit)
  validate_integer($retry_policy_num_tries)
  validate_integer($server_http_num_threads)

  if ($processing_num_threads != undef) {
    validate_integer($processing_num_threads)
  }

  validate_bool(
    $cache_populate_cache,
    $cache_use_cache,
    $jvm_print_gc_details,
    $jvm_print_gc_time_stamps,
    $jvm_use_concurrent_mark_sweep_gc,
    $query_group_by_single_threaded,
  )

  validate_array(
    $cache_hosts,
    $cache_uncacheable,
    $select_tier_custom_priorities,
  )

  file { "${druid::config_dir}/broker":
    ensure => directory,
    require => File[$druid::config_dir],
  }

  file { "${druid::config_dir}/broker/runtime.properties":
    ensure  => file,
    content => template("${module_name}/broker.runtime.properties.erb"),
    require => File["${druid::config_dir}/broker"],
  }

  file { "${druid::config_dir}/broker/common.runtime.properties":
    ensure  => link,
    target  => "${druid::config_dir}/common.runtime.properties",
    require => [
      File["${druid::config_dir}/broker"],
      File["${druid::config_dir}/common.runtime.properties"],
    ],
  }

  file { '/etc/systemd/system/druid-broker.service':
    ensure  => file,
    content => template("${module_name}/druid-broker.service.erb"),
    notify  => Exec['Reload systemd daemon'],
  }

  exec { 'Reload systemd daemon':
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { 'druid-broker':
    ensure    => running,
    enable    => true,
    require   => File['/etc/systemd/system/druid-broker.service'],
    subscribe => Exec['Reload systemd daemon'],
  }
}
