source 'https://rubygems.org'

puppet_gem_version = ENV['PUPPET_GEM_VERSION']

# Gemnasium.com does not understand ternary operators
#
# rubocop:disable Bundler/DuplicatedGem
if puppet_gem_version.nil?
  gem 'puppet', '~> 5.0'
else
  gem 'puppet', puppet_gem_version
end
# rubocop:enable Bundler/DuplicatedGem

group :development do
  gem 'bundler'
  gem 'codacy-coverage'
  gem 'coderay'
  gem 'guard'
  gem 'guard-bundler'
  gem 'guard-livereload'
  gem 'guard-rake'
  gem 'guard-rubocop'
  gem 'mdl'
  gem 'metadata-json-lint'
  gem 'overcommit'
  gem 'parallel_tests'
  gem 'puppetlabs_spec_helper'
  gem 'rake'
  gem 'rspec-puppet-facts'
  gem 'rubocop'
  gem 'semantic_puppet' if puppet_gem_version.to_f < 4.9
  gem 'simplecov'
  gem 'simplecov-murmur'
end

group :acceptance_testing do
  gem 'beaker'
  gem 'beaker-rspec'
end

group :ci do
  gem 'codeclimate-test-reporter'
end

group :documentation do
  gem 'puppet-strings'
  gem 'redcarpet'
  gem 'rgen'
end

group :release do
  gem 'github_api'
  gem 'puppet-blacksmith'
end

group :metatools do
  gem 'github-linguist'
  gem 'travis'
end
