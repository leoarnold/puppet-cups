namespace :travis do
  desc 'Validate the Travis CI config file'
  task :lint do
    system('travis lint')
  end

  desc 'Perform all static code analysis checks'
  task ci: %i[rake:lint validate spec check:symlinks check:test_file check:dot_underscore check:git_ignore mdl]
end
