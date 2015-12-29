source 'https://rubygems.org'

puppetversion = ENV['PUPPET_GEM_VERSION']
if puppetversion
  gem 'puppet', puppetversion, require: false
else
  gem 'puppet', '>= 3.3', require: false
end

facterversion = ENV['FACTER_GEM_VERSION']
if facterversion
  gem 'facter', facterversion, require: false
else
  gem 'facter', '>= 1.7.0', require: false
end

group :development do
  gem 'puppetlabs_spec_helper', '>= 0.8.2', require: false
  gem 'puppet-lint', '>= 1.0.0', require: false
  gem 'metadata-json-lint', '>= 0.0.11', require: false
end
