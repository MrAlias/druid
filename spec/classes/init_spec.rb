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
  end
end
