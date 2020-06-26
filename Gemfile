source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 6.0' : puppet_version)

group :development do
  gem 'codacy-coverage', '2.2.1'
  gem 'coderay', '1.1.3'
  gem 'mdl', '0.9.0'
  gem 'metadata-json-lint', '2.4.0'
  gem 'pdk', '1.18.0'
  gem 'puppetlabs_spec_helper', '2.15.0'
  gem 'rake', '13.0.1'
  gem 'rspec-puppet-facts', '1.10.0'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '0.18.5'
end

group :acceptance_testing do
  gem 'beaker', '4.25.0'
  gem 'beaker-puppet', '1.19.2'
  gem 'beaker-rspec', '6.2.4'
  gem 'beaker-vagrant', '0.6.6'
end

group :documentation do
  gem 'puppet-strings', '2.4.0'
  gem 'redcarpet', '3.5.0'
end

group :release do
  gem 'github_api', '0.19.0'
  gem 'puppet-blacksmith', '6.0.0'
end

group :metatools do
  gem 'github-linguist', '7.9.0'
  gem 'overcommit', '0.54.0'
  gem 'rubocop', '0.86.0'
  gem 'rubocop-performance', '1.6.1'
  gem 'rubocop-rspec', '1.40.0'
  gem 'travis', '1.8.11'
end
