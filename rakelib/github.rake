require 'github_api'

require_relative 'forge_module'

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

    changelog = File.read('CHANGELOG.md').split("\n")
    subsections = changelog.each_index.select { |i| changelog[i] =~ /^## / }

    release = {
      owner: FORGE_MODULE.github[:owner],
      repo: FORGE_MODULE.github[:repo],
      tag_name: FORGE_MODULE.metadata['version'],
      target_commitish: 'release',
      name: changelog[subsections[0]].match(/^## \d+-\d+-\d+ - (?<name>.*)$/)[:name],
      body: changelog[(subsections[0] + 2)..(subsections[1] - 2)].join("\n"),
      draft: false,
      prerelease: false
    }

    response = github.repos.releases.create release

    asset = {
      owner: FORGE_MODULE.github[:owner],
      repo: FORGE_MODULE.github[:repo],
      id: response['id'],
      name: FORGE_MODULE.artefact_name,
      filepath: FORGE_MODULE.artefact_path,
      content_type: 'application/gzip'
    }

    github.repos.releases.assets.upload asset
  end
end
