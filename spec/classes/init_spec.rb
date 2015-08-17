require 'spec_helper'
describe 'druid' do

  context 'with defaults for all parameters' do
    it { should compile.with_all_deps }
    it { should contain_class('druid') }
    it { should contain_file('/usr/local/lib/druid').with(
        {
            :ensure => :link,
        }
    )}
    it { should contain_file('/usr/local/lib').with(
        {
            :ensure => :directory,
        }
    )}
    it { should contain_file('/etc/druid').with(
        {
            :ensure => :directory,
        }
    )}
    it { should contain_file('/etc/druid/common.runtime.properties').with(
        {
            :ensure => :file,
        }
    )}
    it { should contain_exec('Create /usr/local/lib').with(
        {
            :command => 'mkdir -p /usr/local/lib',
        }
    )}
    it { should contain_exec('Create /etc/druid').with(
        {
            :command => 'mkdir -p /etc/druid',
        }
    )}
    it { should contain_exec('Download and untar druid-0.8.0').with(
        {
            :command => 'wget -O - http://static.druid.io/artifacts/releases/druid-0.8.0-bin.tar.gz | tar zx',
        }
    )}
    it { should contain_package('openjdk-7-jre-headless').with(
        {
            :ensure => 'present',
        }
    )}
    it { should contain_package('wget').with(
        {
            :ensure => 'present',
        }
    )}
  end
end
