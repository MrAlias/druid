require 'spec_helper'
describe 'druid::broker', :type => 'class' do
  context 'On system with 10 GB RAM and defaults for all parameters' do
    let(:facts) do
      {
        :memorysize => '10 GB',
      }
    end

    it {
      should compile.with_all_deps
      should contain_class('druid::broker')
      should contain_file('/etc/druid/broker/runtime.properties').with({:ensure => 'file'})
      should contain_file('/etc/systemd/system/druid-broker.service').with({:ensure => 'file'})
      should contain_exec('Reload systemd daemon').with({:command => '/bin/systemctl daemon-reload'})
      should contain_service('druid-broker').with({:ensure => 'running', :enable => true})
    }
  end
end
