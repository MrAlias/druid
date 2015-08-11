class { 'druid::historical':
  server_max_size              => 2147483648, 
  processing_buffer_size_bytes => 100000000,
  processing_num_threads       => 1, 
  segment_cache_locations      => [
    {
      'path'    => '/tmp/druid/indexCache',
      'maxSize' => 10000000000,
    },
  ],
}
