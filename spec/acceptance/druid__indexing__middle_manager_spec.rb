require 'spec_helper_acceptance'

middle_manager_pp = <<-EOS
class { 'druid':
  metadata_storage_type               => 'derby',
  metadata_storage_connector_uri      => '',
  metadata_storage_connector_user     => '',
  metadata_storage_connector_password => '',
}

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
EOS

describe 'druid::indexing::middle_manager' do
  describe 'running puppet code' do
    it 'should run without errors' do
      apply_manifest(middle_manager_pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(middle_manager_pp, :catch_changes => true)
    end

    it 'should have a working druid CLI' do
      druid_cli('version') do |r|
        expect(r.stdout).to match(/Druid version - \d\.\d\.\d/)
      end
    end

    describe service('druid-middle_manager') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(8080) do
      it {
        # Give the service time to finish starting
        sleep(15)
        should be_listening
      }
    end
  end
end
