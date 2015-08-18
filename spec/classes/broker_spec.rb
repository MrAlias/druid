require 'spec_helper'
describe 'druid::broker' do
  context 'with defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it { should compile.with_all_deps }
    it { should contain_class('druid::broker') }
    it { should contain_file('/etc/druid/runtime.properties').with(
      {
        :ensure => 'file',
      }
    )}
    it { should contain_file('/etc/systemd/system/druid-broker.service').with(
      {
        :ensure => 'file',
      }
    )}
    it { should contain_exec('Reload systemd daemon').with(
      {
        :command => '/bin/systemctl daemon-reload',
      }
    )}
    it { should contain_service('druid-broker').with(
      {
        :ensure => 'running',
        :enable => true,
      }
    )}
  end
end
