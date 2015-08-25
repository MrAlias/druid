class { 'druid':
  metadata_storage_type               => 'derby',
  metadata_storage_connector_uri      => '',
  metadata_storage_connector_user     => '',
  metadata_storage_connector_password => '',
}

class { 'druid::coordinator':
  jvm_opts => [
    '-server',
    '-Xmx512m',
    '-Xms512m',
    '-XX:NewSize=256m',
    '-XX:MaxNewSize=256m',
    '-XX:+UseG1GC',
    '-XX:+PrintGCDetails',
    '-XX:+PrintGCTimeStamps',
    '-Duser.timezone=UTC',
    '-Dfile.encoding=UTF-8',
    '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager',
  ],
}
