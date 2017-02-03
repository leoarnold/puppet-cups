source 'https://rubygems.org'

facterversion = ENV['FACTER_GEM_VERSION']
puppetversion = ENV['PUPPET_GEM_VERSION']

group :dependencies do
  gem 'facter', (facterversion.nil? ? '~> 2.0' : facterversion), require: false
  gem 'puppet', (puppetversion.nil? ? '~> 4.0' : puppetversion), require: false
end

group :development do
  gem 'codacy-coverage', '~> 1.0', require: false
  gem 'codeclimate-test-reporter', '~> 1.0', require: false
  gem 'coderay', '~> 1.1', require: false
  gem 'mdl', '~> 0.3', require: false
  gem 'metadata-json-lint', '~> 1.0', require: false
  gem 'puppetlabs_spec_helper', '~> 1.1', require: false
  gem 'rubocop', '~> 0.37', require: false
end

group :acceptance_testing do
  gem 'beaker-rspec', '~> 6.0', require: false
  gem 'serverspec', '~> 2.26', require: false
end

group :metatools do
  gem 'github-linguist', '~> 4.7', require: false
  gem 'travis', '~> 1.8', require: false
end
