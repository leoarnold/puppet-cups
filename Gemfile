source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 6.0' : puppet_version)

group :development do
  gem 'codacy-coverage', '2.2.1'
  gem 'coderay', '1.1.3'
  gem 'mdl', '0.11.0'
  gem 'metadata-json-lint', '3.0.0'
  gem 'pdk', '2.1.0'
  gem 'puppetlabs_spec_helper', '3.0.0'
  gem 'rake', '13.0.3'
  gem 'rspec-puppet-facts', '2.0.1'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '~> 0.17.0' # See: https://github.com/codeclimate/test-reporter/issues/413
end

group :acceptance_testing do
  gem 'beaker', '4.28.1'
  gem 'beaker-puppet', '1.21.0'
  gem 'beaker-rspec', '6.3.0'
  gem 'beaker-vagrant', '0.6.7'
end

group :documentation do
  gem 'puppet-strings', '2.6.0'
  gem 'redcarpet', '3.5.1'
end

group :release do
  gem 'github_api', '0.19.0'
  gem 'puppet-blacksmith', '6.1.0'
end

group :metatools do
  gem 'github-linguist', '7.13.0'
  gem 'overcommit', '0.57.0'
  gem 'rubocop', '1.12.0'
  gem 'rubocop-performance', '1.10.2'
  gem 'rubocop-rake', '0.5.1'
  gem 'rubocop-rspec', '2.2.0'
end
