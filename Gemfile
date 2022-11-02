source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 7.0' : puppet_version)

group :development do
  gem 'coderay', '1.1.3'
  gem 'mdl', '0.12.0'
  gem 'metadata-json-lint', '3.0.2'
  gem 'pdk', '2.5.0'
  gem 'puppetlabs_spec_helper', '4.0.1'
  gem 'rake', '13.0.6'
  gem 'rspec-puppet-facts', '2.0.5'
  gem 'rubocop', '1.38.0'
  gem 'rubocop-performance', '1.15.0'
  gem 'rubocop-rake', '0.6.0'
  gem 'rubocop-rspec', '2.14.2'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '0.21.2'
end

group :acceptance_testing do
  gem 'beaker', '4.38.1'
  gem 'beaker-puppet', '1.28.0'
  gem 'beaker-rspec', '7.1.0'
  gem 'beaker-vagrant', '0.7.1'
end

group :documentation do
  gem 'puppet-strings', '3.0.1'
  gem 'redcarpet', '3.5.1'
end

group :release do
  gem 'github_api', '0.19.0'
  gem 'puppet-blacksmith', '6.1.1'
end

group :metatools do
  gem 'github-linguist', '7.23.0'
  gem 'overcommit', '0.59.1'
end
