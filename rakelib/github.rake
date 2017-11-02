namespace :github do
  desc 'Break down language statistics'
  task :linguist do
    system('linguist --breakdown')
  end

  desc 'Publish online documentation'
  task pages: 'strings:gh_pages:update'
end
