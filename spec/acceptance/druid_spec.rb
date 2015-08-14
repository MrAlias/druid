require 'spec_helper_acceptance'

describe 'druid' do
  describe 'running puppet code' do
    it 'should be idempotent and run without errors' do
      pp = <<-EOS
        class { 'druid': }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      apply_manifest(pp, :catch_changes => true)
    end

    it 'can run the druid cli' do
      druid_cli('version') do |r|
        expect(r.stdout).to match(/Druid version - \d\.\d\.\d/)
      end
    end
  end
end
