source 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION']
if puppetversion
  gem 'puppet', puppetversion, require: false
else
  gem 'puppet', ['>= 3.3', '< 5.0'], require: false
end

facterversion = ENV['FACTER_GEM_VERSION']
if facterversion
  gem 'facter', facterversion, require: false
else
  gem 'facter', '~> 2.0', require: false
end

group :development do
  gem 'puppetlabs_spec_helper', '~> 1.1', require: false
  gem 'rubocop', '~> 0.37', require: false
  gem 'puppet-lint', '~> 1.0', require: false
  gem 'metadata-json-lint', '~> 0.0', require: false
  gem 'mdl', '~> 0.3', require: false
  gem 'codacy-coverage', '~> 1.0', require: false
  gem 'codeclimate-test-reporter', '~> 0.5', require: false
end

group :acceptance_testing do
  gem 'beaker-rspec', '~> 5.3', require: false
  gem 'serverspec', '~> 2.26', require: false
end

group :metatools do
  gem 'github-linguist', '~> 4.7', require: false if RUBY_VERSION.to_f >= 2.0
  gem 'travis', '~> 1.8', require: false
end
