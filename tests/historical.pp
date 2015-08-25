class { 'druid::historical':
  server_max_size              => 268435456,
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
  segment_cache_locations      => [
    {
      'path'    => '/tmp/druid/indexCache',
      'maxSize' => 10000000000,
    },
  ],
}
