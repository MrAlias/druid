require 'beaker-rspec'

hosts.each do |host|
  on host, install_puppet
end

RSpec.configure do |c|
  module_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  module_name = module_root.split(File::SEPARATOR).last

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install modules
    puppet_module_install(:source => module_root, :module_name => module_name)
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs/stdlib'), { :acceptable_exit_codes => [0,1] }
    end
  end
end

def druid_cli(command, opts = '', exit_codes = [0], &block)
  classpath = ":/etc/druid/:/usr/local/lib/druid/lib/*"
  cmd = "/usr/bin/java #{opts} -classpath #{classpath} io.druid.cli.Main #{command}"
  shell(cmd, :acceptable_exit_codes => exit_codes, &block)
end
