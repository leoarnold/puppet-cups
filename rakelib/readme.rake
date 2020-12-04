require_relative 'forge_module'

def erb(mode, input, output)
  @mode = mode

  template = FORGE_MODULE.file(input)
  target = FORGE_MODULE.file(output)

  puts "[ERB] Rendering #{output} from #{input}"
  renderer = ERB.new(template.read, 0, '>')
  target.write(renderer.result)
end

desc 'Render README files from template'
task :readme do
  FileUtils.rm_f('.github/README.md')
  erb(:github, 'README.md.erb', '.github/README.md')

  FileUtils.rm_f('README.md')
  erb(:release, 'README.md.erb', 'README.md')
end

# rubocop:disable Rake/Desc
task build: :readme
task mdl: :readme
task 'strings:generate': :readme
# rubocop:enable Rake/Desc
