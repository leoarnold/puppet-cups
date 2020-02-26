source 'https://rubygems.org'

puppet_version = ENV['PUPPET_GEM_VERSION']

gem 'puppet', (puppet_version.nil? ? '~> 6.0' : puppet_version)

group :development do
  gem 'codacy-coverage', '2.2.1'
  gem 'coderay', '1.1.2'
  gem 'mdl', '0.8.0'
  gem 'metadata-json-lint', '2.2.0'
  gem 'pdk', '1.16.0'
  gem 'puppetlabs_spec_helper', '2.14.1'
  gem 'rake', '13.0.1'
  gem 'rspec-puppet-facts', '1.10.0'
  gem 'semantic_puppet' if puppet_version.to_f < 4.9
  gem 'simplecov', '0.18.5'
end

group :acceptance_testing do
  gem 'beaker', '4.14.1'
  gem 'beaker-puppet', '1.18.13'
  gem 'beaker-rspec', '6.2.4'
  gem 'beaker-vagrant', '0.6.4'
end

group :documentation do
  gem 'puppet-strings', '2.3.1'
  gem 'redcarpet', '3.5.0'
end

group :release do
  gem 'github_api', '0.18.2'
  gem 'puppet-blacksmith', '5.0.0'
end

group :metatools do
  gem 'github-linguist', '7.8.0'
  gem 'overcommit', '0.52.1'
  gem 'rubocop', '0.79.0'
  gem 'rubocop-performance', '1.5.2'
  gem 'rubocop-rspec', '1.38.1'
  gem 'travis', '1.8.10'
end
