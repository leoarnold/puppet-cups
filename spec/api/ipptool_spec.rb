# frozen_string_literal: true

require 'spec_helper_acceptance'

def ipptool(param, resource, ipp_request)
  shell("ipptool #{param} ipp://localhost#{resource} /dev/stdin", stdin: ipp_request, acceptable_exit_codes: [0, 1])
end

OS_NAME = fact('os.name')
OS_RELEASE_FULL = fact('os.release.full')
DEBIAN_PWG_RASTER_PATCH = (OS_NAME == 'Ubuntu' && ['16.10', '17.04'].include?(OS_RELEASE_FULL))

RSpec.describe 'Ipptool' do
  before(:all) do
    ensure_cups_is_running
  end

  context 'when querying the attributes of a generic queue' do
    before(:all) do
      purge_all_queues
      add_printers('Office')
    end

    describe 'Get-Printer-Attributes' do
      context 'with STATUS successful-ok' do
        before(:all) do
          @ipp_resource = '/printers/Office'
          @ipp_request = <<~REQUEST
            {
              OPERATION Get-Printer-Attributes
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              ATTR uri printer-uri $uri
              STATUS successful-ok
              DISPLAY printer-is-shared
            }
          REQUEST
        end

        describe 'ipptool -c' do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it do
              expected = (DEBIAN_PWG_RASTER_PATCH ? 1 : 0)
              expect(@result.exit_code).to eq expected
            end
          end

          describe 'stdout' do
            it do
              expected = (DEBIAN_PWG_RASTER_PATCH ? '' : "printer-is-shared\nfalse\n")

              expect(@result.stdout).to eq expected
            end
          end

          describe 'stderr' do
            it do
              expected = (DEBIAN_PWG_RASTER_PATCH ? "successful-ok\n" : '')

              expect(@result.stderr).to eq expected
            end
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? 1 : 0

              expect(@result.exit_code).to be expected
            end
          end

          describe 'stdout' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? '[FAIL]' : '[PASS]'

              expect(@result.stdout).to include expected
            end

            it { expect(@result.stdout).to include 'status-code = successful-ok (successful-ok)' } if DEBIAN_PWG_RASTER_PATCH

            it { expect(@result.stdout).to include 'printer-is-shared (boolean) = false' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end
    end
  end

  context 'when no queue is installed' do
    before(:all) do
      purge_all_queues
    end

    describe 'CUPS-Get-Classes' do
      context 'with STATUS successful-ok' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
            {
              OPERATION CUPS-Get-Classes
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              STATUS successful-ok
              DISPLAY printer-name
              DISPLAY member-names
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 1 }
          end

          describe 'stdout' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? '' : <<~OUTPUT
        EXPECTED: STATUS successful-ok (got client-error-not-found)
        status-message="No destinations added."
              OUTPUT

              expect(@result.stdout).to eq expected
            end
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq "No destinations added.\n" }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 1 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to include '[FAIL]' }

            it { expect(@result.stdout).to include 'EXPECTED: STATUS successful-ok (got client-error-not-found)' }

            it { expect(@result.stdout).to_not include 'printer-name' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end

      context 'without STATUS clause' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
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

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to eq "printer-name,member-names\n" }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to include '[PASS]' }

            it { expect(@result.stdout).to_not include 'printer-name' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end
    end

    describe 'CUPS-Get-Printers' do
      context 'with STATUS successful-ok' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
            {
              OPERATION CUPS-Get-Printers
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              STATUS successful-ok
              DISPLAY printer-name
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 1 }
          end

          describe 'stdout' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? '' : <<~OUTPUT
        EXPECTED: STATUS successful-ok (got client-error-not-found)
        status-message="No destinations added."
              OUTPUT

              expect(@result.stdout).to eq expected
            end
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq "No destinations added.\n" }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 1 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to include '[FAIL]' }

            it { expect(@result.stdout).to include 'EXPECTED: STATUS successful-ok (got client-error-not-found)' }

            it { expect(@result.stdout).to_not include 'printer-name' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end

      context 'without STATUS clause' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
            {
              OPERATION CUPS-Get-Printers
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              DISPLAY printer-name
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to eq "printer-name\n" }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to include '[PASS]' }

            it { expect(@result.stdout).to_not include 'printer-name' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end
    end
  end

  context 'when there are printer queues but no class queues' do
    before(:all) do
      purge_all_queues
      @printers = %w[BackOffice Office Warehouse]
      @printers.each { |printer| add_printers(printer) }
    end

    describe 'CUPS-Get-Classes' do
      context 'with STATUS successful-ok' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
            {
              OPERATION CUPS-Get-Classes
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              STATUS successful-ok
              DISPLAY printer-name
              DISPLAY member-names
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to eq "printer-name,member-names\n" }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to include '[PASS]' }

            it { expect(@result.stdout).to_not include 'printer-name' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end

      context 'without STATUS clause' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
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

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to eq "printer-name,member-names\n" }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            it { expect(@result.stdout).to include '[PASS]' }

            it { expect(@result.stdout).to_not include 'printer-name' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end
    end

    describe 'CUPS-Get-Printers' do
      context 'with STATUS successful-ok' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
            {
              OPERATION CUPS-Get-Printers
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              STATUS successful-ok
              DISPLAY printer-name
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? 1 : 0

              expect(@result.exit_code).to be expected
            end
          end

          describe 'stdout' do
            let(:expected) do
              DEBIAN_PWG_RASTER_PATCH ? '' : <<~OUTPUT
                printer-name
                BackOffice
                Office
                Warehouse
              OUTPUT
            end

            it { expect(@result.stdout).to eq expected }
          end

          describe 'stderr' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? "successful-ok\n" : '' }

            it { expect(@result.stderr).to eq expected }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? 1 : 0 }

            it { expect(@result.exit_code).to be expected }
          end

          describe 'stdout' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? '[FAIL]' : '[PASS]' }

            it { expect(@result.stdout).to include expected }

            it { expect(@result.stdout).to include 'status-code = successful-ok (successful-ok)' } if DEBIAN_PWG_RASTER_PATCH

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = BackOffice' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Office' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Warehouse' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end

      context 'without STATUS clause' do
        let(:ipp_resource) { '/' }
        let(:ipp_request) do
          <<~REQUEST
            {
              OPERATION CUPS-Get-Printers
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              DISPLAY printer-name
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? 1 : 0 }

            it { expect(@result.exit_code).to be expected }
          end

          describe 'stdout' do
            let(:expected) do
              DEBIAN_PWG_RASTER_PATCH ? '' : <<~OUTPUT
                printer-name
                BackOffice
                Office
                Warehouse
              OUTPUT
            end

            it { expect(@result.stdout).to eq expected }
          end

          describe 'stderr' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? "successful-ok\n" : '' }

            it { expect(@result.stderr).to eq expected }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? 1 : 0 }

            it { expect(@result.exit_code).to be expected }
          end

          describe 'stdout' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? '[FAIL]' : '[PASS]' }

            it { expect(@result.stdout).to include expected }

            it { expect(@result.stdout).to include 'status-code = successful-ok (successful-ok)' } if DEBIAN_PWG_RASTER_PATCH

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = BackOffice' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Office' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Warehouse' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end
    end
  end

  context 'when there are printer and class queues' do
    before(:all) do
      purge_all_queues
      add_printers('BackOffice', 'Office', 'Warehouse')
      add_printers_to_classes(
        'CrawlSpace' => %w[],
        'GroundFloor' => %w[Office Warehouse],
        'UpperFloor' => %w[BackOffice]
      )
    end

    describe 'CUPS-Get-Classes' do
      context 'with STATUS successful-ok' do
        let(:ipp_resource) { '/' }
        let(:ipp_request) do
          <<~REQUEST
            {
              OPERATION CUPS-Get-Classes
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              STATUS successful-ok
              DISPLAY printer-name
              DISPLAY member-names
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', ipp_resource, ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            let(:expected) do
              <<~OUTPUT
                printer-name,member-names
                CrawlSpace,
                GroundFloor,"Office,Warehouse"
                UpperFloor,BackOffice
              OUTPUT
            end

            it { expect(@result.stdout).to eq expected }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            let(:class_and_members) do
              <<~OUTPUT
                printer-name (nameWithoutLanguage) = GroundFloor
                member-names (1setOf nameWithoutLanguage) = Office,Warehouse
              OUTPUT
            end

            let(:printers) do
              <<~OUTPUT
                printer-name (nameWithoutLanguage) = UpperFloor
                member-names (nameWithoutLanguage) = BackOffice
              OUTPUT
            end

            it { expect(@result.stdout).to include '[PASS]' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = CrawlSpace' }

            it { expect(@result.stdout).to include class_and_members }

            it { expect(@result.stdout).to include printers }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end

      context 'without STATUS clause' do
        let(:ipp_resource) { '/' }
        let(:ipp_request) do
          <<~REQUEST
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

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', ipp_resource, ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            let(:expected) do
              <<~OUTPUT
                printer-name,member-names
                CrawlSpace,
                GroundFloor,"Office,Warehouse"
                UpperFloor,BackOffice
              OUTPUT
            end

            it { expect(@result.stdout).to eq expected }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', ipp_resource, ipp_request)
          end

          describe 'exit code' do
            it { expect(@result.exit_code).to be 0 }
          end

          describe 'stdout' do
            let(:class_and_members) do
              <<~OUTPUT
                printer-name (nameWithoutLanguage) = GroundFloor
                member-names (1setOf nameWithoutLanguage) = Office,Warehouse
              OUTPUT
            end

            let(:printers) do
              <<~OUTPUT
                printer-name (nameWithoutLanguage) = UpperFloor
                member-names (nameWithoutLanguage) = BackOffice
              OUTPUT
            end

            it { expect(@result.stdout).to include '[PASS]' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = CrawlSpace' }

            it { expect(@result.stdout).to include class_and_members }

            it { expect(@result.stdout).to include printers }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end
    end

    describe 'CUPS-Get-Printers' do
      context 'with STATUS successful-ok' do
        let(:ipp_resource) { '/' }
        let(:ipp_request) do
          <<~REQUEST
            {
              OPERATION CUPS-Get-Printers
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              STATUS successful-ok
              DISPLAY printer-name
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', ipp_resource, ipp_request)
          end

          describe 'exit code' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? 1 : 0 }

            it { expect(@result.exit_code).to be expected }
          end

          describe 'stdout' do
            let(:expected) do
              DEBIAN_PWG_RASTER_PATCH ? '' : <<~OUTPUT
                printer-name
                BackOffice
                CrawlSpace
                GroundFloor
                Office
                UpperFloor
                Warehouse
              OUTPUT
            end

            it { expect(@result.stdout).to eq expected }
          end

          describe 'stderr' do
            let(:expected) { DEBIAN_PWG_RASTER_PATCH ? "successful-ok\n" : '' }

            it { expect(@result.stderr).to eq expected }
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', ipp_resource, ipp_request)
          end

          describe 'exit code' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? 1 : 0

              expect(@result.exit_code).to be expected
            end
          end

          describe 'stdout' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? '[FAIL]' : '[PASS]'

              expect(@result.stdout).to include expected
            end

            it { expect(@result.stdout).to include 'status-code = successful-ok (successful-ok)' } if DEBIAN_PWG_RASTER_PATCH

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = CrawlSpace' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = GroundFloor' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = UpperFloor' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = BackOffice' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Office' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Warehouse' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end

      context 'without STATUS clause' do
        before(:all) do
          @ipp_resource = '/'
          @ipp_request = <<~REQUEST
            {
              OPERATION CUPS-Get-Printers
              GROUP operation
              ATTR charset attributes-charset utf-8
              ATTR language attributes-natural-language en
              DISPLAY printer-name
            }
          REQUEST
        end

        describe "'ipptool -c'" do
          before(:all) do
            @result = ipptool('-c', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? 1 : 0

              expect(@result.exit_code).to be expected
            end
          end

          describe 'stdout' do
            let(:expected) do
              DEBIAN_PWG_RASTER_PATCH ? '' : <<~OUTPUT
                printer-name
                BackOffice
                CrawlSpace
                GroundFloor
                Office
                UpperFloor
                Warehouse
              OUTPUT
            end

            it do
              expect(@result.stdout).to eq expected
            end
          end

          describe 'stderr' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? "successful-ok\n" : ''

              expect(@result.stderr).to eq expected
            end
          end
        end

        describe "'ipptool -t'" do
          before(:all) do
            @result = ipptool('-t', @ipp_resource, @ipp_request)
          end

          describe 'exit code' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? 1 : 0

              expect(@result.exit_code).to be expected
            end
          end

          describe 'stdout' do
            it do
              expected = DEBIAN_PWG_RASTER_PATCH ? '[FAIL]' : '[PASS]'

              expect(@result.stdout).to include expected
            end

            it { expect(@result.stdout).to include 'status-code = successful-ok (successful-ok)' } if DEBIAN_PWG_RASTER_PATCH

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = CrawlSpace' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = GroundFloor' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = UpperFloor' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = BackOffice' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Office' }

            it { expect(@result.stdout).to include 'printer-name (nameWithoutLanguage) = Warehouse' }
          end

          describe 'stderr' do
            it { expect(@result.stderr).to eq '' }
          end
        end
      end
    end
  end
end
