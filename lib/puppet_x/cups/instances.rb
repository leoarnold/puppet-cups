require_relative 'ipp'

module PuppetX
  module Cups
    # Namespace for methods related to querying the CUPS server for available queue instances
    #
    # The design of this module is based on the ideas of R. Tyler Croy:
    # http://unethicalblogger.com/2014/03/01/testing-custom-facts-with-rspec.html
    #
    # @author Leo Arnold
    # @since 1.0.0
    module Instances
      # Returns an array with the names of all installed classes
      #
      # @author Leo Arnold
      # @since 1.0.0
      #
      # @return [Array] The names of all installed class queues
      def self.classes
        classmembers.keys
      end

      # Sends a {cups_get_classes} request and parses the names of class queues and their members
      #
      # From the CSV table
      #
      # ```
      # printer-name,member-names
      # CrawlSpace,
      # GroundFloor,"Office,Warehouse"
      # UpperFloor,BackOffice
      # ```
      #
      # the method extracts
      #
      # ```
      # {
      #   'CrawlSpace'  => [],
      #   'GroundFloor' => ['Office', 'Warehouse'],
      #   'UpperFloor'  => ['BackOffice']
      # }
      # ```
      #
      # @author Leo Arnold
      # @since 1.0.0
      #
      # @return [Hash] Class names as key and an array with the names of the members as value
      def self.classmembers
        answer = {}

        query = PuppetX::Cups::Ipp::QueryC.new('/', cups_get_classes)
        query.results.each do |line|
          classname, members = line.split(',', 2)
          answer[classname] = members.gsub(/\A"|"\Z/, '').split(',') if members
        end

        answer
      end

      # The IPP request required to retrieve all installed class queues and their members
      #
      # @see https://www.cups.org/doc/spec-ipp.html#CUPS_GET_CLASSES
      #
      # @author Leo Arnold
      # @since 1.0.0
      #
      # @return [String] IPP `CUPS-Get-Classes` request to display `printer-name` and `member-names`
      def self.cups_get_classes
        <<-REQUEST
          {
            OPERATION CUPS-Get-Classes
            GROUP operation
            ATTR charset attributes-charset utf-8
            ATTR language attributes-natural-language en
            DISPLAY printer-name
            DISPLAY member-names
          }
        REQUEST
      end

      # An array of the names of all installed printer queues
      #
      # @author Leo Arnold
      # @since 1.0.0
      #
      # @return [Array] The names of all installed printer queues
      def self.printers
        queues - classes
      end

      # Sends a {cups_get_printers} request and returns an array of the names of all installed queues
      #
      # @author Leo Arnold
      # @since 1.0.0
      #
      # @return [Array] The names of all installed queues
      def self.queues
        query = PuppetX::Cups::Ipp.query('/', cups_get_printers)

        query.results
      end

      # The IPP request required to retrieve the names of all installed queues
      #
      # @see https://www.cups.org/doc/spec-ipp.html#CUPS_GET_PRINTERS
      #
      # @author Leo Arnold
      # @since 1.0.0
      #
      # @return [String] IPP `CUPS-Get-Printers` request to display `printer-name`
      def self.cups_get_printers
        <<-REQUEST
          {
            OPERATION CUPS-Get-Printers
            GROUP operation
            ATTR charset attributes-charset utf-8
            ATTR language attributes-natural-language en
            DISPLAY printer-name
          }
        REQUEST
      end
    end
  end
end
