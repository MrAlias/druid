class { 'druid::indexing::middle_manager':
  jvm_opts => [
    '-server',
    '-Xmx512m',
    '-Xms512m',
    '-Duser.timezone=UTC',
    '-Dfile.encoding=UTF-8',
    '-Djava.io.tmpdir=/tmp',
    '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
  ],
}
