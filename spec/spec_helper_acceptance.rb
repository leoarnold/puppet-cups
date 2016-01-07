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
  c.before :suite do
    hosts.each do |host|
      copy_module_to(host, source: project_root, module_name: 'cups')
    end
  end
end
