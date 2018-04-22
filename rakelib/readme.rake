require_relative 'forge_module'

def erb(mode, input, output)
  @mode = mode

  template = FORGE_MODULE.file(input)
  target = FORGE_MODULE.file(output)

  puts "[ERB] Rendering #{output} from #{input}"
  renderer = ERB.new(File.read(template), 0, '>')
  File.write(target, renderer.result)
end

file '.github/README.md' => 'README.md.erb' do
  erb(:github, 'README.md.erb', '.github/README.md')
end

file 'README.md' => 'README.md.erb' do
  erb(:release, 'README.md.erb', 'README.md')
end

desc 'Render README files from template'
task readme: ['README.md', '.github/README.md']

task build: :readme
