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
  gem 'rubocop', '>= 0.35.0', require: false
  gem 'puppet-lint', '>= 1.0.0', require: false
  gem 'metadata-json-lint', '>= 0.0.11', require: false
end

group :acceptance_testing do
  gem 'beaker-rspec', '>= 5.3.0', require: false
  gem 'serverspec', '>= 2.26.0', require: false
  gem 'beaker-puppet_install_helper', '>= 0.4.0', require: false
end
