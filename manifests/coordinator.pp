# == Class: druid::coordinator
#
# Setup a Druid node runing the coordinator service.
#
# === Parameters
#
# [*host*]
#   Host address the service listens on.
#
#   Default value: The `$ipaddress` fact.
#
# [*port*]
#   Port the service listens on.
#
#   Default value: `8084`.
#
# [*service*]
#   The name of the service.
#
#   This is used as a dimension when emitting metrics and alerts.  It is
#   used to differentiate between the various services
#
#   Default value: `'druid/coordinator'`.
#
# [*conversion_on*]
#   Specify if old segment indexing versions should be converted to the
#   latest.
#
#   Valid values: `true` or `false`.
#
#   Default value: `false`.
#
# [*jvm_opts*]
#   Array of options to set for the JVM running the service.
#
#   Default value: `[
#     '-server',
#     '-Duser.timezone=UTC',
#     '-Dfile.encoding=UTF-8',
#     '-Djava.io.tmpdir=/tmp',
#     '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
#   ]`
#
# [*load_timeout*]
#   Time before the coordinator assigns a segment to a historical node.
#
#   Default value: `'PT15M'`.
#
# [*manager_config_poll_duration*]
#   Time between polls of the config table for updates.
#
#   Default value: `'PT1m'`.
#
# [*manager_rules_alert_threshold*]
#   The duration after a failed poll upon which an alert should be emitted.
#
#   Default value: `'PT10M'`.
#
# [*manager_rules_default_tier*]
#   The default tier which default rules will be loaded from.
#
#   Default value: `'_default'`.
#
# [*manager_rules_poll_duration*]
#   Time between polls of the set of active rules for updates.
#
#   Defines the amount of lag time it can take for the coordinator to notice
#   rule changes.
#
#   Default value: `'PT1M'`.
#
# [*manager_segment_poll_duration*]
#   Time between polls of the set of active segments for updates.
#
#   Defines the amount of lag time it can take for the coordinator to notice
#   segment changes.
#
#   Default value: `'PT1M'`.
#
# [*merge_on*]
#   Specify if the coordinator should try and merge small segments.
#
#   This helps keep segements in a more optimal segment size.
#
#   Default value: `false`.
#
# [*period*]
#   The run period for the coordinator.
#
#   The coordinator’s operates by maintaining the current state of the world
#   in memory and periodically looking at the set of segments available and
#   segments being served to make decisions about whether any changes need
#   to be made to the data topology. This parameter sets the delay between
#   each of these runs.
#
#   Default value: `'PT60S'`.
#
# [*period_indexing_period*]
#   How often to send indexing tasks to the indexing service.
#
#   Only applies if merge or conversion is turned on.
#
#   Default value: `'PT1800S'` (30 mins).
#
# [*start_delay*]
#   Time to let the service think it has all data.
#
#   The operation of the Coordinator works on the assumption that it has an
#   up-to-date view of the state of the world when it runs, the current ZK
#   interaction code, however, is written in a way that doesn’t allow the
#   Coordinator to know for a fact that it’s done loading the current state
#   of the world. This delay is a hack to give it enough time to believe
#   that it has all the data.
#
#   Default value: `'PT300S'`.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#

class druid::coordinator (
  $host                          = hiera("${module_name}::druid::coordinator::host", $ipaddress),
  $port                          = hiera("${module_name}::druid::coordinator::port", 8081),
  $service                       = hiera("${module_name}::druid::coordinator::service", 'druid/coordinator'),
  $conversion_on                 = hiera("${module_name}::druid::coordinator::conversion_on", false),
  $jvm_opts                      = hiera_array("${module_name}::broker::jvm_opts", ['-server', '-Duser.timezone=UTC', '-Dfile.encoding=UTF-8', '-Djava.io.tmpdir=/tmp', '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager']),
  $load_timeout                  = hiera("${module_name}::druid::coordinator::load_timeout", 'PT15M'),
  $manager_config_poll_duration  = hiera("${module_name}::druid::coordinator::manager_config_poll_duration", 'PT1m'),
  $manager_rules_alert_threshold = hiera("${module_name}::druid::coordinator::manager_rules_alert_threshold", 'PT10M'),
  $manager_rules_default_tier    = hiera("${module_name}::druid::coordinator::manager_rules_default_tier", '_default'),
  $manager_rules_poll_duration   = hiera("${module_name}::druid::coordinator::manager_rules_poll_duration", 'PT1M'),
  $manager_segment_poll_duration = hiera("${module_name}::druid::coordinator::manager_segment_poll_duration", 'PT1M'),
  $merge_on                      = hiera("${module_name}::druid::coordinator::merge_on", false),
  $period                        = hiera("${module_name}::druid::coordinator::period", 'PT60S'),
  $period_indexing_period        = hiera("${module_name}::druid::coordinator::period_indexing_period", 'PT1800S'),
  $start_delay                   = hiera("${module_name}::druid::coordinator::start_delay", 'PT300S'),
) {
  require druid

  validate_string(
    $host,
    $service,
    $load_timeout,
    $manager_config_poll_duration,
    $manager_rules_alert_threshold,
    $manager_rules_default_tier,
    $manager_rules_poll_duration,
    $manager_segment_poll_duration,
    $period,
    $period_indexing_period,
    $start_delay,
  )
  
  validate_integer($port)
  
  validate_bool($conversion_on, $merge_on)

  validate_array($jvm_opts)

  druid::service { 'coordinator':
    config_content  => template("${module_name}/coordinator.runtime.properties.erb"),
    service_content => template("${module_name}/druid-coordinator.service.erb"),
  }
}
