namespace :github do
  desc 'Break down language statistics'
  task :linguist do
    system('linguist --breakdown')
  end

  desc 'Generate online documentation'
  task :pages do
    system('puppet strings')
  end
end
