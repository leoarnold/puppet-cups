require 'github_api'

namespace :github do
  desc 'Break down language statistics'
  task :linguist do
    system('linguist --breakdown')
  end

  desc 'Generate Yard documentation in /doc'
  task pages: ['strings:generate', 'strings:gh_pages:configure']

  desc 'Release the module on GitHub'
  task release: %i[clean build] do
    github = Github.new oauth_token: ENV['GITHUB_TOKEN']

    metadata = JSON.parse(File.read('metadata.json'))
    remote = metadata['source'].match(%r{https://github.com/(?<owner>\w+)/(?<repo>[^/]+)})
    filename = "#{metadata['name']}-#{metadata['version']}.tar.gz"

    changelog = File.read('CHANGELOG.md').split("\n")
    subsections = changelog.each_index.select { |i| changelog[i] =~ /^## / }

    release = {
      owner: remote[:owner],
      repo: remote[:repo],
      tag_name: metadata['version'],
      target_commitish: 'release',
      name: changelog[subsections[0]].match(/^## \d+-\d+-\d+ - (?<name>.*)$/)[:name],
      body: changelog[(subsections[0] + 2)..(subsections[1] - 2)].join("\n"),
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
