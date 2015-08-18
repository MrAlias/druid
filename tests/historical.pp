class { 'druid::historical':
  server_max_size              => 268435456,      # 256MB
  processing_buffer_size_bytes => 134217728,      # 128MB
  max_mem_allocation_pool      => '512m',
  min_mem_allocation_pool      => '512m',
  processing_num_threads       => 1, 
  segment_cache_locations      => [
    {
      'path'    => '/tmp/druid/indexCache',
      'maxSize' => 10000000000,
    },
  ],
}
