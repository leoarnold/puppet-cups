# frozen_string_literal: true

require 'bundler/setup'
require 'codacy-coverage'
require 'simplecov-murmur'

SimpleCov.formatters = [
  SimpleCov::Formatter::MurMurFormatter,
  SimpleCov::Formatter::HTMLFormatter,
  Codacy::Formatter
]

SimpleCov::Formatter::MurMurFormatter.mode = :all

SimpleCov.start do
  add_filter '/.mdl/'
  add_filter '/vendor/'
  add_filter '/spec/'
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet/spec_helper'

require 'rspec-puppet-facts'
include RspecPuppetFacts # rubocop:disable Style/MixinUsage

def any_supported_os(morefacts = {})
  {
    operatingsystem: 'CentOS',
    osfamily: 'Suse',
    os: { 'family' => 'Suse', 'name' => 'CentOS' }
  }.merge(morefacts)
end

# Make all files in this module available to #require
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + '/../'))

# RSpec configuration
# http://www.rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration
RSpec.configure do |c|
  c.disable_monkey_patching!
  c.expect_with :rspec do |e|
    e.syntax = :expect
  end
  c.mock_with(:rspec)
  c.example_status_persistence_file_path = '.rspec_status'
end

# RSpec-Puppet configuration
# http://rspec-puppet.com/setup/
fixture_path = File.expand_path(File.join(__FILE__, '..', 'fixtures'))
RSpec.configure do |c|
  c.after(:suite) { RSpec::Puppet::Coverage.report! }
  c.manifest_dir = File.join(fixture_path, 'manifests')
  c.module_path = File.join(fixture_path, 'modules')
end
