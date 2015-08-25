class { 'druid::broker':
  processing_buffer_size_bytes => 134217728,
  jvm_opts                     => [
    '-server',
    '-Xmx512m',
    '-Xms512m',
    '-Duser.timezone=UTC',
    '-Dfile.encoding=UTF-8',
    '-Djava.io.tmpdir=/tmp',
    '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager'
  ],
  processing_num_threads       => 1,
}
