source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 5.0' : puppet_version)

group :development do
  gem 'bundler', '~> 1.16'
  gem 'codacy-coverage', '2.1.0'
  gem 'coderay', '1.1.2'
  gem 'mdl', '0.5.0'
  gem 'metadata-json-lint', '2.2.0'
  gem 'puppetlabs_spec_helper', '2.11.0'
  gem 'rake', '12.3.1'
  gem 'rspec-puppet-facts', '1.9.0'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '0.16.1'
end

group :acceptance_testing do
  gem 'beaker', '4.0.0'
  gem 'beaker-puppet', '1.6.0'
  gem 'beaker-rspec', '6.2.4'
  gem 'beaker-vagrant', '0.5.0'
end

group :documentation do
  gem 'puppet-strings', '2.1.0'
  gem 'redcarpet', '3.4.0'
end

group :release do
  gem 'github_api', '0.18.2'
  gem 'puppet-blacksmith', '4.1.2'
end

group :metatools do
  gem 'github-linguist', '7.0.0'
  gem 'overcommit', '0.46.0'
  gem 'rubocop', '0.59.2'
  gem 'rubocop-rspec', '1.30.0'
  gem 'travis', '1.8.9'
end
