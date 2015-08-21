require 'spec_helper'

describe 'druid::service', :type => :define do
  context 'Check config_content is a required parameter' do
    let(:title) {'config_content test'}
    let(:params) do
      {
        :service_content => 'test service content'
      }
    end

    it { should compile.and_raise_error(/Must pass config_content to/) }
  end

  context 'Check service_content is a required parameter' do
    let(:title) {'service_content test'}
    let(:params) do
      {
        :config_content => 'test config content'
      }
    end

    it { should compile.and_raise_error(/Must pass service_content to/) }
  end

  context 'Check fails for non-string service name' do
    let(:title) {'non-string title test'}
    let(:params) do
      {
        :service_name    => [123, 321],
        :config_content  => 'test config content',
        :service_content => 'test service content',
      }
    end

    it { should compile.and_raise_error(/\["123", "321"\] is not a string/) }
  end

  context 'Check fails for non-string config content' do
    let(:title) {'non-string config content test'}
    let(:params) do
      {
        :service_name    => 'test_service',
        :config_content  => ['test config content'],
        :service_content => 'test service content',
      }
    end

    it { should compile.and_raise_error(/\["test config content"\] is not a string/) }
  end

  context 'Check fails for non-string service content' do
    let(:title) {'non-string service content test'}
    let(:params) do
      {
        :service_name    => 'test_service',
        :config_content  => 'test config content',
        :service_content => ['test service content'],
      }
    end

    it { should compile.and_raise_error(/\["test service content"\] is not a string/) }
  end

  context 'Check runs with generic params' do
    let(:title) {'test'}
    let(:params) do
      {
        :service_name    => 'test_service',
        :config_content  => 'test config content',
        :service_content => 'test service content',
      }
    end

    it { 
      should compile

      should contain_druid__service('test')

      should contain_class('druid')

      should contain_file('/etc/druid/test_service').with({
        :ensure => 'directory'
      }).that_requires('File[/etc/druid]')

      should contain_file('/etc/druid/test_service/runtime.properties').with({
        :ensure => 'file'
      }).that_requires(
        'File[/etc/druid/test_service]'
      ).with_content(
        'test config content'
      )

      should contain_file('/etc/druid/test_service/common.runtime.properties').with({
        :ensure => 'link',
        :target => '/etc/druid/common.runtime.properties',
      }).that_requires(
        'File[/etc/druid/test_service]'
      ).that_requires(
        'File[/etc/druid/common.runtime.properties]'
      )

      should contain_file('/etc/systemd/system/druid-test_service.service').with({
        :ensure => 'file',
      }).that_notifies(
        'Exec[Reload systemd daemon for new test_service service file]'
      ).with_content(
        'test service content'
      )

      should contain_exec('Reload systemd daemon for new test_service service file').with({
        :command     => '/bin/systemctl daemon-reload',
        :refreshonly => true,
      })

      should contain_service('druid-test_service').with({
        :ensure => 'running',
        :enable => true,
      }).that_requires(
        'File[/etc/systemd/system/druid-test_service.service]'
      ).that_subscribes_to(
        'Exec[Reload systemd daemon for new test_service service file]'
      )
    }
  end
end
