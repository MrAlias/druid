require 'spec_helper_acceptance'

overlord_pp = <<-EOS
class { 'druid::indexing::overlord':
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

describe 'druid::indexing::overlord' do
  describe 'running puppet code' do
    it 'should run without errors' do
      apply_manifest(overlord_pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(overlord_pp, :catch_changes => true)
    end

    it 'should have a working druid CLI' do
      druid_cli('version') do |r|
        expect(r.stdout).to match(/Druid version - \d\.\d\.\d/)
      end
    end

    sleep(180)

    describe service('druid-overlord') do
      it { should be_enabled }
      it { should be_running }
    end

    describe port(8090) do
      it { should be_listening }
    end
  end
end
