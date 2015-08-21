# == Class: druid::indexing
#
# Private class used to setup Druid nodes runing an indexing service.
#
# === Parameters
#
# [*azure_logs_container*]
#   The Azure Blob Store container to store logs at. 
#
# [*azure_logs_prefix*]
#   The path to prepend to logs for Azure storage. 
#
# [*hdfs_logs_directory*]
#   The HDFS directory to store logs. 
#
# [*local_logs_directory*]
#   Local filesystem path to store logs. 
#
#   Default value: `'/var/log'`
#
# [*logs_type*]
#   Where to store task logs. 
#
#   Valid values: `'noop'`, `'s3'`, `'azure'`, `'hdfs'`, `'file'`. 
#
#   Default value: `'file'`. 
#
# [*s3_logs_bucket*]
#   S3 bucket name to store logs at. 
#
# [*s3_logs_prefix*]
#   S3 key prefix. 
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#

class druid::indexing (
  $azure_logs_container = hiera("${module_name}::indexing::azure_logs_container", undef),
  $azure_logs_prefix    = hiera("${module_name}::indexing::azure_logs_prefix", undef),
  $hdfs_logs_directory  = hiera("${module_name}::indexing::hdfs_logs_directory", undef),
  $local_logs_directory = hiera("${module_name}::indexing::local_logs_directory", '/var/log'),
  $logs_type            = hiera("${module_name}::indexing::logs_type", 'file'),
  $s3_logs_bucket       = hiera("${module_name}::indexing::s3_logs_bucket", undef),
  $s3_logs_prefix       = hiera("${module_name}::indexing::s3_logs_prefix", undef),
) {
  require druid

  validate_re($logs_type, ['^noop$', '^s3$', '^azure$', '^hdfs$', '^file$'])
  validate_string(
    $azure_logs_container,
    $azure_logs_prefix,
    $hdfs_logs_directory,
    $local_logs_directory,
    $s3_logs_bucket,
    $s3_logs_prefix,
  )
}
