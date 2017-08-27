source 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION']

# Gemnasium.com does not understand ternary operators
#
# rubocop:disable Bundler/DuplicatedGem
if puppetversion.nil?
  gem 'puppet', '~> 5.0'
else
  gem 'puppet', puppetversion
end
# rubocop:enable Bundler/DuplicatedGem

group :development do
  gem 'codacy-coverage', '~> 1.0'
  gem 'coderay', '~> 1.1'
  gem 'mdl', '~> 0.3'
  gem 'metadata-json-lint', '~> 2.0'
  gem 'parallel_tests', '~> 2.13'
  gem 'puppet-blacksmith', '~> 3.3'
  gem 'puppetlabs_spec_helper', '~> 2.0'
  gem 'rspec-puppet-facts', '~> 1.7'
  gem 'rubocop', '~> 0.37'
  gem 'semantic_puppet' if puppetversion.to_f < 4.9
  gem 'simplecov-console', '~> 0.4'
end

group :acceptance_testing do
  gem 'beaker', '~> 3.0', '< 3.14'
  gem 'beaker-rspec', '~> 6.0'
end

group :ci do
  gem 'codeclimate-test-reporter', '~> 1.0'
end

group :metatools do
  gem 'github-linguist', '~> 5.0'
  gem 'travis', '~> 1.8'
end
