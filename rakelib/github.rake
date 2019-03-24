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

    release = {
      owner: FORGE_MODULE.github[:owner],
      repo: FORGE_MODULE.github[:repo],
      tag_name: FORGE_MODULE.metadata['version'],
      target_commitish: 'release',
      name: FORGE_MODULE.candidate[:title],
      body: FORGE_MODULE.candidate[:changes],
      draft: false,
      prerelease: false
    }

    puts '[GitHub] Creating new release ...'
    pp release

    response = github.repos.releases.create release

    asset = {
      owner: FORGE_MODULE.github[:owner],
      repo: FORGE_MODULE.github[:repo],
      id: response['id'],
      name: FORGE_MODULE.artefact[:name],
      filepath: FORGE_MODULE.artefact[:path],
      content_type: 'application/gzip'
    }

    puts "[GitHub] Adding new asset #{asset[:name]} ..."

    github.repos.releases.assets.upload asset

    puts '[GitHub] Module successfully released'
  end
end
