druid::service { 'realtime test service':
  service_name    => 'realtime',
  config_content  => 'Test realtime config content',
  service_content => 'Test realtime service content',
}
