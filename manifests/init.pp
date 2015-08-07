# == Class: druid
#
# Install druid and all needed dependencies.
#
# === Parameters
#
# [*version*]
#   Version of druid to install.
#
#   Defaults to '0.8.0'.
#
# [*java_pkg*]
#   Name of the java package to ensure installed on system.
#
#   Defaults to 'openjdk-7-jre-headless'.
#
# [*install_dir*]
#   Directory druid will be installed in.
#
#   Defaults to '/usr/local/lib/druid'.
#
# [*config_dir*]
#   Directory druid will keep configuration files.
#
#   Defaults to '/etc/druid'.
#
# === Examples
#
#  class { 'druid': 
#    version     => '0.8.0',
#    java_pkg    => 'openjdk-7-jre-headless',
#    install_dir => '/usr/local/lib/druid',
#    config_dir  => '/etc/druid',
#  }
#
# === Authors
#
# Tyler Yahn <codingalias@gmail.com>
#
class druid (
  $version     = hiera("${module_name}::version", '0.8.0'),
  $java_pkg    = hiera("${module_name}::java_pkg", 'openjdk-7-jre-headless'),
  $install_dir = hiera("${module_name}::install_dir", '/usr/local/lib/druid'),
  $config_dir  = hiera("${module_name}::config_dir", '/etc/druid'),
) {
  validate_string($java_pkg)
  validate_absolute_path($install_dir, $config_dir)
  validate_re($version, '^([0-9]+)\.([0-9]+)\.([0-9]+)$')

  ensure_packages(['wget', $java_pkg])

  exec { "Create ${install_dir}":
    command => "mkdir -p ${install_dir}",
    creates => $install_dir,
    cwd     => '/',
  }

  exec { "Create ${config_dir}":
    command => "mkdir -p ${config_dir}",
    creates => $config_dir,
    cwd     => '/',
  }

  file { $install_dir:
    ensure  => directory,
    require => Exec["Create ${install_dir}"],
  }

  file { $config_dir:
    ensure  => directory,
    require => Exec["Create ${config_dir}"],
  }

  $url = "http://static.druid.io/artifacts/releases/druid-${version}-bin.tar.gz"
  exec { "Download and untar druid-${version}":
    command => "wget -O - ${url} | tar zx",
    creates => "${install_dir}/druid-${version}",
    cwd     => $install_dir,
    require => [
      File[$install_dir],
      Package['wget'],
    ],
  }
}
