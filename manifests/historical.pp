# == Class: druid::historical
#
# Setup a historical druid node.
#
# === Parameters
#
# [*host*]
#   The host for the current node.
#
#   Defaults to the facter defined `$ipaddress`.
#
# [*port*]
#  This is the port to actually listen on; unless port mapping is used, this
#  will be the same port as is on druid.host
#
#  Defaults to 8083.
#
# [*service*]
#  The name of the service. This is used as a dimension when emitting metrics
#  and alerts to differentiate between the various services
#
#  Defaults to 'druid/historical'.
#
# [*server_max_size*]
#  The maximum number of bytes-worth of segments that the node wants assigned
#  to it. This is not a limit that Historical nodes actually enforces, just a
#  value published to the Coordinator node so it can plan accordingly.
#
#  Defaults to 0.
#
# [*server_tier*]
#  A string to name the distribution tier that the storage node belongs to.
#  Many of the rules Coordinator nodes use to manage segments can be keyed on
#  tiers.
#
#  Defaults to '_default_tier'.
#
# [*server_priority*]
#  In a tiered architecture, the priority of the tier, thus allowing control
#  over which nodes are queried. Higher numbers mean higher priority. The
#  default (no priority) works for architecture with no cross replication
#  (tiers that have no data-storage overlap). Data centers typically have
#  equal priority.
#
#  Defaults to 0.
#
# [*segment_cache_locations*]
#  Segments assigned to a Historical node are first stored on the local file
#  system (in a disk cache) and then served by the Historical node. These
#  locations define where that local cache resides.
#
#  Valid values are 'none' (also `undef`) or an absolute file path.
#
# [*segment_cache_delete_on_remove*]
#  Delete segment files from cache once a node is no longer serving a segment.
#
#  Defaults to true.
#
# [*segment_cache_drop_segment_delay_millis*]
#  How long a node delays before completely dropping segment.
#
#  Defaults to 30000 (30 seconds).
#
# [*segment_cache_info_dir*]
#  Historical nodes keep track of the segments they are serving so that when
#  the process is restarted they can reload the same segments without waiting
#  for the Coordinator to reassign. This path defines where this metadata is
#  kept. Directory will be created if needed.
#
# [*segment_cache_announce_interval_millis*]
#  How frequently to announce segments while segments are loading from cache.
#  Set this value to zero to wait for all segments to be loaded before
#  announcing.
#
#  Defaults to 5000 (5 seconds).
#
# [*segment_cache_num_loading_threads*]
#  How many segments to load concurrently from from deep storage.
#
#  Defaults to 1.
#
# [*server_http_num_threads*]
#  Number of threads for HTTP requests.
#
#  Defaults to 10.
#
# [*server_http_max_idle_time*]
#  The Jetty max idle time for a connection.
#
#  Defaults to 'PT5m'.
#
# [*processing_buffer_size_bytes*]
#  This specifies a buffer size for the storage of intermediate results. The
#  computation engine in both the Historical and Realtime nodes will use a
#  scratch buffer of this size to do all of their intermediate computations
#  off-heap. Larger values allow for more aggregations in a single pass over
#  the data while smaller values can require more passes depending on the
#  query that is being executed.
#
#  Defaults to 1073741824 (1GB).
#
# [*processing_format_string*]
#  Realtime and historical nodes use this format string to name their processing threads.
#
#  Defaults to 'processing-%s'.
#
# [*processing_num_threads*]
#  The number of processing threads to have available for parallel processing
#  of segments. Our rule of thumb is num_cores - 1, which means that even
#  under heavy load there will still be one core available to do background
#  tasks like talking with ZooKeeper and pulling down segments.
#
# [*processing_column_cache_size_bytes*]
#  Maximum size in bytes for the dimension value lookup cache. Any value
#  greater than 0 enables the cache. It is currently disabled by default.
#  Enabling the lookup cache can significantly improve the performance of
#  aggregators operating on dimension values, such as the JavaScript
#  aggregator, or cardinality aggregator, but can slow things down if
#  the cache hit rate is low (i.e. dimensions with few repeating values).
#  Enabling it may also require additional garbage collection tuning to avoid
#  long GC pauses.
#
#  Defaults to 0 (disabled).
#
# [*query_groupBy_single_threaded*]
#  Run single threaded group By queries.
#
#  Defaults to false.
#
# [*query_groupBy_max_intermediate_rows*]
#  Maximum number of intermediate rows.
#
#  Defaults to 50000.
#
# [*query_groupBy_max_results*]
#  Maximum number of results.
#
#  Defaults to 500000.
#
# [*query_search_max_search_limit*]
#  Maximum number of search results to return.
#
#  Defaults to 1000.
#
# [*historical_cache_use_cache*]
#  Enable the cache on the historical.
#
#  Defaults to false.
#
# [*historical_cache_populate_cache*]
#  Populate the cache on the historical.
#
#  Defaults to false.
#
# [*historical_cache_uncacheable*]
#  All query types to not cache.
#
#  Defaults to ["groupBy", "select"].
#
# === Examples
#
#  class { 'druid::historical': }
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
class druid::historical (
  $host                                    = hiera("${module_name}::historical::host", $::ipaddress),
  $port                                    = hiera("${module_name}::historical::port", 8083),
  $service                                 = hiera("${module_name}::historical::service", 'druid/historical'),
  $server_max_size                         = hiera("${module_name}::historical::server_max_size", 0),
  $server_tier                             = hiera("${module_name}::historical::server_tier", '_default_tier'),
  $server_priority                         = hiera("${module_name}::historical::server_priority", 0),
  $segment_cache_locations                 = hiera("${module_name}::historical::segment_cache_locations", undef),
  $segment_cache_delete_on_remove          = hiera("${module_name}::historical::segment_cache_delete_on_remove", true),
  $segment_cache_drop_segment_delay_millis = hiera("${module_name}::historical::segment_cache_drop_segment_delay_millis", 30000),
  $segment_cache_info_dir                  = hiera("${module_name}::historical::segment_cache_info_dir", undef),
  $segment_cache_announce_interval_millis  = hiera("${module_name}::historical::segment_cache_announce_interval_millis", 5000),
  $segment_cache_num_loading_threads       = hiera("${module_name}::historical::segment_cache_num_loading_threads", 1),
  $server_http_num_threads                 = hiera("${module_name}::historical::server_http_num_threads", 10),
  $server_http_max_idle_time               = hiera("${module_name}::historical::server_http_max_idle_time", 'PT5m'),
  $processing_buffer_size_bytes            = hiera("${module_name}::historical::processing_buffer_size_bytes", 1073741824),
  $processing_format_string                = hiera("${module_name}::historical::processing_format_string", 'processing-%s'),
  $processing_num_threads                  = hiera("${module_name}::historical::processing_num_threads", undef),
  $processing_column_cache_size_bytes      = hiera("${module_name}::historical::processing_column_cache_size_bytes", 0),
  $query_group_by_single_threaded          = hiera("${module_name}::historical::query_groupBy_single_threaded", false),
  $query_group_by_max_intermediate_rows    = hiera("${module_name}::historical::query_groupBy_max_intermediate_rows", 50000),
  $query_group_by_max_results              = hiera("${module_name}::historical::query_groupBy_max_results", 500000),
  $query_search_max_search_limit           = hiera("${module_name}::historical::query_search_max_search_limit", 1000),
  $historical_cache_use_cache              = hiera("${module_name}::historical::historical_cache_use_cache", false),
  $historical_cache_populate_cache         = hiera("${module_name}::historical::historical_cache_populate_cache", false),
  $historical_cache_uncacheable            = hiera("${module_name}::historical::historical_cache_uncacheable", ['groupBy', 'select']),
) {
  require druid

  validate_string(
    $service,
    $server_tier,
    $server_http_max_idle_time,
    $processing_format_string,
    $query_group_by_max_intermediate_rows,
    $query_group_by_max_results,
    $query_search_max_search_limit,
  )

  validate_integer($port)
  validate_integer($server_max_size)
  validate_integer($server_priority)
  validate_integer($segment_cache_drop_segment_delay_millis)
  validate_integer($segment_cache_announce_interval_millis)
  validate_integer($segment_cache_num_loading_threads)
  validate_integer($server_http_num_threads)
  validate_integer($processing_column_cache_size_bytes)
  validate_integer($processing_buffer_size_bytes)

  if ($processing_num_threads != undef) {
    validate_integer($processing_num_threads)
  }

  validate_bool(
    $segment_cache_delete_on_remove,
    $query_group_by_single_threaded,
    $historical_cache_use_cache,
    $historical_cache_populate_cache
  )

  validate_array($historical_cache_uncacheable)

  if ($segment_cache_locations != undef) {
    validate_absolute_path($segment_cache_locations)
    if ($segment_cache_info_dir != undef) {
      validate_absolute_path($segment_cache_info_dir)
    }
  }

  file { "${druid::config_dir}/historical.runtime.properties":
    ensure  => file,
    content => template("${module_name}/historical.runtime.properties.erb"),
    require => File[$druid::config_dir],
  }
}
