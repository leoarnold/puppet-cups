require 'puppet_blacksmith/rake_tasks'

Blacksmith::RakeTask.new do |t|
  t.tag_pattern = '%s'
end
