require 'json'
require 'net/https'
require 'pathname'
require 'singleton'

# A data object offering convenience methods
# to access the module's metadata
class ForgeModule
  include Singleton

  def artefact
    artefact_name = "#{name}-#{version}.tar.gz"

    {
      name: artefact_name,
      path: file("pkg/#{artefact_name}").to_s
    }
  end

  def file(relative_path)
    path = File.expand_path(File.join(__dir__, '..', *relative_path.split('/')))

    Pathname.new(path)
  end

  def github
    return @github if @github

    regex = %r{https://github.com/(?<owner>\w+)/(?<repo>[^/\#?\s]+)}

    raise ArgumentError, "metadata.json: Value for key 'source' is not a GitHub repository" unless source =~ regex

    match_data = metadata['source'].match(regex)

    @github = { owner: match_data['owner'], repo: match_data['repo'] }
  end

  def name
    metadata['name'].strip
  end

  def published?
    releases.include?(version)
  end

  def candidate
    @changelog ||= file('CHANGELOG.md').read

    title = nil
    changes = []
    @changelog.each_line do |line|
      break if line =~ /^## / && !title.nil?

      changes << line unless title.nil?
      title = line.match(/^## \d+-\d+-\d+ - (?<title>.*)$/)[:title] if line =~ /^## /
    end

    { title: title.strip, changes: changes.join.strip, version: version }
  end

  def releases
    forgedata['releases'].map { |release| release['version'].strip }
  end

  def source
    metadata['source'].strip
  end

  def forgedata
    return @forgedata if @forgedata

    uri = URI("https://forgeapi.puppet.com/v3/modules/#{name}")
    response = Net::HTTP.get_response(uri)

    @forgedata = JSON.parse(response.body)
  end

  def metadata
    return @metadata if @metadata

    content = File.read('metadata.json')
    @metadata = JSON.parse(content)
  end

  def version
    metadata['version'].strip
  end
end

FORGE_MODULE = ForgeModule.instance
