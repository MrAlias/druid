require 'beaker-rspec'

hosts.each do |host|
  install_package(host, 'wget')
  install_package(host, 'rsync')
  install_package(host, 'locales')

  create_remote_file host, '/etc/locale.gen', 'en_US.UTF-8 UTF-8'
  shell 'locale-gen'
  host.add_env_var('LANG', 'en_US.UTF-8')
  host.add_env_var('LANGUAGE', 'en_US.UTF-8')
  host.add_env_var('LC_ALL', 'en_US.UTF-8')

  on host, install_puppet
end

zookeeper_pp = <<-EOS
class { 'zookeeper':
  client_ip => $::ipaddress_lo
}
EOS

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split(File::SEPARATOR).last

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    puppet_module_install(:source => module_root, :module_name => module_name)

    hosts.each do |host|
      on host, puppet('module install puppetlabs-stdlib -v 4.9.0')
      on host, puppet('module install deric-zookeeper -v 0.3.9')

      # Make sure a working instance of zookeeper is running
      apply_manifest(zookeeper_pp)
    end
  end
end

def druid_cli(command, opts = '', exit_codes = [0], &block)
  classpath = ":/etc/druid/:/usr/local/lib/druid/lib/*"
  cmd = "/usr/bin/java #{opts} -classpath #{classpath} io.druid.cli.Main #{command}"
  shell(cmd, :acceptable_exit_codes => exit_codes, &block)
end
