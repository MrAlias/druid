require 'spec_helper_acceptance'

spec_file = <<-EOS
[
  {
    "dataSchema" : {
      "dataSource" : "wikipedia",
      "parser" : {
        "type" : "string",
        "parseSpec" : {
          "format" : "json",
          "timestampSpec" : {
            "column" : "timestamp",
            "format" : "auto"
          },
          "dimensionsSpec" : {
            "dimensions": ["page","language","user","unpatrolled","newPage","robot","anonymous","namespace","continent","country","region","city"],
            "dimensionExclusions" : [],
            "spatialDimensions" : []
          }
        }
      },
      "metricsSpec" : [{
        "type" : "count",
        "name" : "count"
      }, {
        "type" : "doubleSum",
        "name" : "added",
        "fieldName" : "added"
      }, {
        "type" : "doubleSum",
        "name" : "deleted",
        "fieldName" : "deleted"
      }, {
        "type" : "doubleSum",
        "name" : "delta",
        "fieldName" : "delta"
      }],
      "granularitySpec" : {
        "type" : "uniform",
        "segmentGranularity" : "DAY",
        "queryGranularity" : "NONE"
      }
    },
    "ioConfig" : {
      "type" : "realtime",
      "firehose": {
        "type": "kafka-0.8",
        "consumerProps": {
          "zookeeper.connect": "localhost:2181",
          "zookeeper.connection.timeout.ms" : "15000",
          "zookeeper.session.timeout.ms" : "15000",
          "zookeeper.sync.time.ms" : "5000",
          "group.id": "druid-example",
          "fetch.message.max.bytes" : "1048586",
          "auto.offset.reset": "largest",
          "auto.commit.enable": "false"
        },
        "feed": "wikipedia"
      },
      "plumber": {
        "type": "realtime"
      }
    },
    "tuningConfig": {
      "type" : "realtime",
      "maxRowsInMemory": 500000,
      "intermediatePersistPeriod": "PT10m",
      "windowPeriod": "PT10m",
      "basePersistDirectory": "\/tmp\/realtime\/basePersist",
      "rejectionPolicy": {
        "type": "serverTime"
      }
    }
  }
]
EOS

realtime_pp = <<-EOS
class { 'kafka':
  install_java => false,
  before       => Class['druid'],
}

class { 'druid':
  extensions_coordinates              => ["io.druid.extensions:druid-kafka-eight:0.8.0"],
  metadata_storage_type               => 'derby',
  metadata_storage_connector_uri      => '',
  metadata_storage_connector_user     => '',
  metadata_storage_connector_password => '',
  version                             => '0.8.0',
  before                              => Class['druid::realtime'],
}

class { 'druid::realtime':
  processing_buffer_size_bytes => 134217728,
  jvm_opts => [
    '-server',
    '-Xmx512m',
    '-Xms512m',
    '-XX:NewSize=256m',
    '-XX:MaxNewSize=256m',
    '-XX:MaxDirectMemorySize=300m',
    '-XX:+UseConcMarkSweepGC',
    '-XX:+PrintGCDetails',
    '-XX:+PrintGCTimeStamps',
    '-XX:+HeapDumpOnOutOfMemoryError',
    '-Duser.timezone=UTC',
    '-Dfile.encoding=UTF-8',
    '-Djava.util.logging.manager=org.apache.logging.log4j.jul.LogManager',
    '-Djava.io.tmpdir=/tmp',
    '-Dcom.sun.management.jmxremote.port=17071',
    '-Dcom.sun.management.jmxremote.authenticate=false',
    '-Dcom.sun.management.jmxremote.ssl=false',
  ],
  spec_file => '/etc/druid/realtime/spec_file.json',
  spec_file_content => '#{spec_file}',
}
EOS

describe 'druid::realtime' do
  describe 'Setup Kafka' do
    hosts.each do |host|
      on host, puppet('module install puppet-kafka -v 1.0.1')
    end
  end
  describe 'running puppet code' do
    it 'should run without errors' do
      apply_manifest(realtime_pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(realtime_pp, :catch_changes => true)
    end

    sleep(120)

    it 'should have a working druid CLI' do
      druid_cli('version') do |r|
        expect(r.stdout).to match(/Druid version - \d\.\d\.\d/)
      end
    end

    describe service('druid-realtime') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(8084) do
      it { should be_listening }
    end
  end

  after(:all) do
    shell('systemctl is-active druid-realtime.service && systemctl stop druid-realtime.service')
  end
end
