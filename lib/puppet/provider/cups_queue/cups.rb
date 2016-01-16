require_relative '../../../cups_helper.rb'

Puppet::Type.type(:cups_queue).provide(:cups) do
  @doc = 'Installs and manages CUPS printer queues.'

  commands(lpadmin: 'lpadmin')

  ### Static provider methods

  def self.instances
    providers = []
    Facter.value(:cups_classmembers).each do |classname, membernames|
      providers << new(name: classname, ensure: :class, members: membernames)
    end
    Facter.value(:cups_printers).each do |printername|
      providers << new(name: printername, ensure: :printer)
    end
    providers
  end

  def self.prefetch(specified)
    discovered = instances
    specified.keys.each do |name|
      provider = discovered.find { |instance| instance.name == name }
      specified[name].provider = provider if provider
    end
  end

  ### Existence

  def class_exists?
    Facter.value(:cups_classes).include? name
  end

  def printer_exists?
    Facter.value(:cups_printers).include? name
  end

  ### Creation and destruction

  def create_class
    self.members = resource.should(:members)
  end

  def create_printer
    lpadmin('-E', '-p', name, '-m', resource.value(:model))
    self.uri = resource.should(:uri) if resource.should(:uri)
  end

  def destroy
    lpadmin('-E', '-x', name)
  end

  ### Property getters and setters

  def ensure
    prefetched = @property_hash[:ensure]
    prefetched ? prefetched : :absent
  end

  def members
    prefetched = @property_hash[:members]
    prefetched if prefetched
  end

  def members=(value)
    members.each { |member| lpadmin('-E', '-p', member, '-r', name) } if members
    value.each { |member| lpadmin('-E', '-p', member, '-c', name) }
  end

  def uri
    query('device-uri') if printer?
  end

  def uri=(value)
    lpadmin('-E', '-p', name, '-v', value)
  end

  private

  def class?
    self.ensure == :class
  end

  def printer?
    self.ensure == :printer
  end

  def query(property)
    Cups::Queue::Attribute.query(name, property)
  end
end
