require 'puppetlabs_spec_helper/rake_tasks'
require 'rspec-puppet/rake_task'

require 'rubocop/rake_task'
RuboCop::RakeTask.new

desc 'Check style of MarkDown documents'
task :mdl do
  Dir['.github/**/*.md', '**/*.md'].each do |document|
    sh "mdl -s .mdl/style.rb #{document}"
  end
end
