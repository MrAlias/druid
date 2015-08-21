# == Define Type: druid::service
#
# Generic setup for Druic service related resources.
#
# === Parameters
#
# [*service_name*]
#   Name the service is known by (e.g historical, broker, realtime, ...).
#
#   Default value: `$name`
#
# [*config_content*]
#   Required content for the service properties file.
#
# [*service_content*]
#   Required content for the systemd service file.
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#

define druid::service (
  $config_content,
  $service_content,
  $service_name = $title,
) {
  require druid

  validate_string($config_content, $service_content, $service_name)

  file { "${druid::config_dir}/${service_name}":
    ensure  => directory,
    require => File[$druid::config_dir],
  }

  file { "${druid::config_dir}/${service_name}/runtime.properties":
    ensure  => file,
    content => $config_content,
    require => File["${druid::config_dir}/${service_name}"],
  }

  file { "${druid::config_dir}/${service_name}/common.runtime.properties":
    ensure  => link,
    target  => "${druid::config_dir}/common.runtime.properties",
    require => [
      File["${druid::config_dir}/${service_name}"],
      File["${druid::config_dir}/common.runtime.properties"],
    ],
  }

  file { "/etc/systemd/system/druid-${service_name}.service":
    ensure  => file,
    content => $service_content,
    notify  => Exec["Reload systemd daemon for new ${service_name} service file"],
  }

  exec { "Reload systemd daemon for new ${service_name} service file":
    command     => '/bin/systemctl daemon-reload',
    refreshonly => true,
  }

  service { "druid-${service_name}":
    ensure    => running,
    enable    => true,
    require   => File["/etc/systemd/system/druid-${service_name}.service"],
    subscribe => Exec["Reload systemd daemon for new ${service_name} service file"],
  }
}
