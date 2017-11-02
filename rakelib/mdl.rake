desc 'Check style of MarkDown documents'
task :mdl do
  Dir['*.md', '.github/**/*.md', 'examples/**/*.md'].each do |document|
    sh "mdl -s .mdl/style.rb #{document}"
  end
end
