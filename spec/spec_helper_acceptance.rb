require 'beaker-rspec'
require 'beaker/puppet_install_helper'

# Install Puppet on the node
# https://github.com/puppetlabs/beaker-puppet_install_helper
run_puppet_install_helper

# RSpec configuration
# http://www.rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration
RSpec.configure do |c|
  c.color = true
  c.formatter = :documentation
  c.mock_with(:rspec)
end

# Beaker related configuration
# http://www.rubydoc.info/github/puppetlabs/beaker/Beaker/DSL
RSpec.configure do |c|
  project_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  c.before(:suite) do
    hosts.each do |host|
      shell("/bin/sed -i '/templatedir/d' #{default['puppetpath']}/puppet.conf")
      on(host, puppet('module install puppetlabs-stdlib --version 4.5.0'), acceptable_exit_codes: [0, 1])
      copy_module_to(host, source: project_root, module_name: 'cups')
    end
  end
end

# Custom helper functions

def ensure_cups_is_running
  apply_manifest('class { "cups": }', catch_failures: true)
end

def add_printers(names)
  names.each do |name|
    shell("lpadmin -p #{name} -m drv:///sample.drv/generic.ppd")
  end
end

def add_printers_to_classes(classmembers)
  dummy = %w(Dummy)
  add_printers(dummy)
  classmembers.keys.each do |classname|
    members = classmembers[classname]
    members = dummy if members.empty?
    members.each do |printername|
      shell("lpadmin -p #{printername} -c #{classname}")
    end
  end
  remove_queues(dummy)
end

def remove_queues(names)
  names.each do |name|
    shell("lpadmin -x #{name}")
  end
end

def purge_all_queues
  result = shell('lpstat -v', acceptable_exit_codes: [0, 1])
  if result.exit_code == 0
    lines = result.stdout.split("\n")
    lines.each do |line|
      printer = line.gsub(/(device for |:.*)/, '')
      remove_queues([printer])
    end
  else
    fail unless result.stderr.include?('No destinations added')
  end
end
