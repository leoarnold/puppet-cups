require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet/spec_helper'

fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
RSpec.configure do |c|
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.module_path = File.join(fixture_path, 'modules')
end
