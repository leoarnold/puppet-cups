# encoding: UTF-8
require 'codacy-coverage'
require 'codeclimate-test-reporter'

SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  Codacy::Formatter,
  CodeClimate::TestReporter::Formatter
]

SimpleCov.start do
  add_filter '/spec/'
  add_filter '/.vendor/'
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet/spec_helper'

# Make all files in this module available to #require
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../'))

# RSpec configuration
# http://www.rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration
RSpec.configure do |c|
  c.color = true
  c.formatter = :documentation
  c.mock_with(:rspec)
end

# RSpec-Puppet configuration
# http://rspec-puppet.com/setup/
fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
RSpec.configure do |c|
  c.after(:suite) { RSpec::Puppet::Coverage.report! }
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.module_path = File.join(fixture_path, 'modules')
end
