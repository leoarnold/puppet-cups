require 'github_api'

namespace :github do
  desc 'Break down language statistics'
  task :linguist do
    system('linguist --breakdown')
  end

  desc 'Publish online documentation'
  task pages: 'strings:gh_pages:update'

  desc 'Clean, build, tag, push, and release the module on GitHub'
  task release: [:clean, :build, 'module:tag', 'module:push'] do
    github = Github.new oauth_token: YAML.load_file('.github.yml')['oauth_token']

    metadata = JSON.parse(File.read('metadata.json'))
    remote = metadata['source'].match(%r{https://github.com/(?<owner>\w+)/(?<repo>[^/]+)})
    filename = "#{metadata['name']}-#{metadata['version']}.tar.gz"

    changelog = File.read('CHANGELOG.md').split("\n")
    subsections = changelog.each_index.select { |i| changelog[i] =~ /^## / }

    release = {
      owner: remote[:owner],
      repo: remote[:repo],
      tag_name: metadata['version'],
      name: changelog[subsections[0]].match(/^## \d+-\d+-\d+ - (?<name>.*)$/)[:name],
      body: changelog[subsections[0]..subsections[1] - 2].join("\n"),
      draft: false,
      prerelease: false
    }

    response = github.repos.releases.create release

    asset = {
      owner: remote[:owner],
      repo: remote[:repo],
      id: response['id'],
      name: filename,
      filepath: "pkg/#{filename}",
      content_type: 'application/gzip'
    }

    github.repos.releases.assets.upload asset
  end
end
