source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 6.0' : puppet_version)

group :development do
  gem 'codacy-coverage', '2.2.1'
  gem 'coderay', '1.1.3'
  gem 'mdl', '0.11.0'
  gem 'metadata-json-lint', '3.0.2'
  gem 'pdk', '2.5.0'
  gem 'puppetlabs_spec_helper', '4.0.1'
  gem 'rake', '13.0.6'
  gem 'rspec-puppet-facts', '2.0.5'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '~> 0.17.0' # See: https://github.com/codeclimate/test-reporter/issues/413
end

group :acceptance_testing do
  gem 'beaker', '4.36.1'
  gem 'beaker-puppet', '1.26.2'
  gem 'beaker-rspec', '7.1.0'
  gem 'beaker-vagrant', '0.7.1'
end

group :documentation do
  gem 'puppet-strings', '2.9.0'
  gem 'redcarpet', '3.5.1'
end

group :release do
  gem 'github_api', '0.19.0'
  gem 'puppet-blacksmith', '6.1.1'
end

group :metatools do
  gem 'github-linguist', '7.21.0'
  gem 'overcommit', '0.59.1'
  gem 'rubocop', '1.31.0'
  gem 'rubocop-performance', '1.14.2'
  gem 'rubocop-rake', '0.6.0'
  gem 'rubocop-rspec', '2.11.1'
end
