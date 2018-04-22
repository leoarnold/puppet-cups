require 'json'
require 'net/https'
require 'singleton'

# A data object offering convenience methods
# to access the module's metadata
class ForgeModule
  include Singleton

  def artefact_name
    "#{name}-#{version}.tar.gz"
  end

  def artefact_path
    file("pkg/#{filename}")
  end

  def file(relative_path)
    File.expand_path(File.join(__dir__, '..', *relative_path.split('/')))
  end

  def github
    return @github if @github

    regex = %r{https://github.com/(?<owner>\w+)/(?<repo>[^\/\#\?\s]+)}

    raise ArgumentError, "metadata.json: Value for key 'source' is not a GitHub repository" unless source =~ regex

    @github = metadata['source'].match(regex).named_captures
  end

  def name
    metadata['name'].strip
  end

  def published?
    releases.include?(version)
  end

  def releases
    forgedata['releases'].map { |release| release['version'].strip }
  end

  def source
    metadata['source'].strip
  end

  def version
    metadata['version'].strip
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
end

FORGE_MODULE = ForgeModule.instance
