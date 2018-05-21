require 'puppet-strings/tasks'

Rake::Task.tasks.each do |task|
  task.clear_comments if task.name.start_with?('strings:')
end
