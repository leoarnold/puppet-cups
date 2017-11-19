guard :bundler do
  watch('Gemfile')
  watch('gems.rb')
end

guard :livereload do
  watch('coverage/index.html')
  watch(%r{^doc/.+\.htm(l)?$})
end

guard :rake, task: 'mdl' do
  watch(%r{^(.github|examples)/.+\.md$})
  watch(/^\w+.md$/)
end

guard :rake, task: 'github:pages:generate' do
  watch(%r{^lib/.+\.rb$})
  watch(%r{^manifests/.+\.pp$})
  watch('README.md')
end

guard :rubocop, cli: %w[-a] do
  watch(%r{^(lib|spec)/.+\.rb$})
  watch(%r{^rakelib/.+\.rake$})
  watch(/^\w+file$/)
  watch(/^\w+\.rb$/)
end
