require 'spec_helper'
describe 'druid::historical' do
  context 'with defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it { should compile.with_all_deps }
    it { should contain_class('druid::historical') }
    it { should contain_file('/etc/druid/historical.runtime.properties').with(
      {
        :ensure => 'file',
      }
    )}
    it { should contain_file('/etc/systemd/system/druid-historical.service').with(
      {
        :ensure => 'file',
      }
    )}
    it { should contain_exec('Reload systemd daemon').with(
      {
        :command => '/bin/systemctl daemon-reload',
      }
    )}
  end
end
