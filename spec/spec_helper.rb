# frozen_string_literal: true

PROJECT_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '..')).freeze

require 'simplecov'

unless defined?(Spec::Runner::Formatter::TeamcityFormatter)
  require 'codacy-coverage'
  require 'simplecov-murmur'

  SimpleCov.formatters = [
    SimpleCov::Formatter::MurMurFormatter,
    SimpleCov::Formatter::HTMLFormatter,
    Codacy::Formatter
  ]

  SimpleCov::Formatter::MurMurFormatter.mode = :all
end

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

# RSpec configuration
# http://www.rubydoc.info/github/rspec/rspec-core/RSpec/Core/Configuration
RSpec.configure do |c|
  c.order = :random
  Kernel.srand c.seed
  c.disable_monkey_patching!
  c.expect_with :rspec do |e|
    e.syntax = :expect
  end
  c.mock_with(:rspec)
  c.example_status_persistence_file_path = '.rspec_status'
end

# RSpec-Puppet configuration
# http://rspec-puppet.com/setup/
FIXTURE_PATH = File.join(PROJECT_ROOT, 'spec', 'fixtures').freeze
RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report! unless defined?(Spec::Runner::Formatter::TeamcityFormatter)
  end
  c.manifest_dir = File.join(FIXTURE_PATH, 'manifests')
  c.module_path = File.join(FIXTURE_PATH, 'modules')
end

# Make Puppet eXtension modules available
Dir["#{PROJECT_ROOT}/lib/puppet_x/**/*.rb"].each do |file|
  require file
end
