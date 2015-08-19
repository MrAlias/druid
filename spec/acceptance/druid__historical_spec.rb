require 'spec_helper_acceptance'

historical_pp = <<-EOS
class { 'druid::historical':
  server_max_size              => 268435456,
  processing_buffer_size_bytes => 134217728,
  jvm_max_mem_allocation_pool  => '512m',
  jvm_min_mem_allocation_pool  => '512m',
  processing_num_threads       => 1, 
  segment_cache_locations      => [
    {
      'path'    => '/tmp/druid/indexCache',
      'maxSize' => 10000000000,
    },
  ],
}
EOS

describe 'druid::historical' do
  describe 'running puppet code' do
    it 'should run without errors' do
      apply_manifest(historical_pp, :catch_failures => true)
    end

    it 'should be idempotent' do
      apply_manifest(historical_pp, :catch_changes => true)
    end

    it 'should have a working druid CLI' do
      druid_cli('version') do |r|
        expect(r.stdout).to match(/Druid version - \d\.\d\.\d/)
      end
    end

    describe port(8083) do
      it { should be_listening }
    end

    describe service('druid-historical') do
      it { should be_enabled }
      it { should be_running }
    end
  end
end
