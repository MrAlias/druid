require 'spec_helper_acceptance'

coordinator_pp = <<-EOS
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
EOS

describe 'druid::coordinator' do
  describe 'running puppet code' do
    it 'should run without errors' do
      apply_manifest(coordinator_pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(coordinator_pp, :catch_changes => true)
    end

    it 'should have a working druid CLI' do
      druid_cli('version') do |r|
        expect(r.stdout).to match(/Druid version - \d\.\d\.\d/)
      end
    end

    sleep(180)

    describe service('druid-coordinator') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(8081) do
      it { should be_listening }
    end
  end
end
