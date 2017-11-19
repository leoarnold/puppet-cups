Ipptool
  when querying the attributes of a generic queue
    Get-Printer-Attributes
      with STATUS successful-ok
        ipptool - c
          exit code
            should eq 1
          stdout
            should eq ""
          stderr
            should eq "successful-ok\n"
        'ipptool -t'
          exit code
            should equal 1
          stdout
            should include "[FAIL]"
            should include "status-code = successful-ok (successful-ok)"
            should include "printer-is-shared (boolean) = false"
          stderr
            should eq ""
  when no queue is installed
    CUPS-Get-Classes
      with STATUS successful-ok
        'ipptool -c'
          exit code
            should equal 1
          stdout
            should eq ""
          stderr
            should eq "No destinations added.\n"
        'ipptool -t'
          exit code
            should equal 1
          stdout
            should include "[FAIL]"
            should include "EXPECTED: STATUS successful-ok (got client-error-not-found)"
            should not include "printer-name"
          stderr
            should eq ""
      without STATUS clause
        'ipptool -c'
          exit code
            should equal 0
          stdout
            should eq "printer-name,member-names\n"
          stderr
            should eq ""
        'ipptool -t'
          exit code
            should equal 0
          stdout
            should include "[PASS]"
            should not include "printer-name"
          stderr
            should eq ""
    CUPS-Get-Printers
      with STATUS successful-ok
        'ipptool -c'
          exit code
            should equal 1
          stdout
            should eq ""
          stderr
            should eq "No destinations added.\n"
        'ipptool -t'
          exit code
            should equal 1
          stdout
            should include "[FAIL]"
            should include "EXPECTED: STATUS successful-ok (got client-error-not-found)"
            should not include "printer-name"
          stderr
            should eq ""
      without STATUS clause
        'ipptool -c'
          exit code
            should equal 0
          stdout
            should eq "printer-name\n"
          stderr
            should eq ""
        'ipptool -t'
          exit code
            should equal 0
          stdout
            should include "[PASS]"
            should not include "printer-name"
          stderr
            should eq ""
  when there are printer queues but no class queues
    CUPS-Get-Classes
      with STATUS successful-ok
        'ipptool -c'
          exit code
            should equal 0
          stdout
            should eq "printer-name,member-names\n"
          stderr
            should eq ""
        'ipptool -t'
          exit code
            should equal 0
          stdout
            should include "[PASS]"
            should not include "printer-name"
          stderr
            should eq ""
      without STATUS clause
        'ipptool -c'
          exit code
            should equal 0
          stdout
            should eq "printer-name,member-names\n"
          stderr
            should eq ""
        'ipptool -t'
          exit code
            should equal 0
          stdout
            should include "[PASS]"
            should not include "printer-name"
          stderr
            should eq ""
    CUPS-Get-Printers
      with STATUS successful-ok
        'ipptool -c'
          exit code
            should equal 1
          stdout
            should eq ""
          stderr
            should eq "successful-ok\n"
        'ipptool -t'
          exit code
            should equal 1
          stdout
            should include "[FAIL]"
            should include "status-code = successful-ok (successful-ok)"
            should include "printer-name (nameWithoutLanguage) = BackOffice"
            should include "printer-name (nameWithoutLanguage) = Office"
            should include "printer-name (nameWithoutLanguage) = Warehouse"
          stderr
            should eq ""
      without STATUS clause
        'ipptool -c'
          exit code
            should equal 1
          stdout
            should eq ""
          stderr
            should eq "successful-ok\n"
        'ipptool -t'
          exit code
            should equal 1
          stdout
            should include "[FAIL]"
            should include "status-code = successful-ok (successful-ok)"
            should include "printer-name (nameWithoutLanguage) = BackOffice"
            should include "printer-name (nameWithoutLanguage) = Office"
            should include "printer-name (nameWithoutLanguage) = Warehouse"
          stderr
            should eq ""
  when there are printer and class queues
    CUPS-Get-Classes
      with STATUS successful-ok
        'ipptool -c'
          exit code
            should equal 0
          stdout
            should eq "printer-name,member-names\nCrawlSpace,\nGroundFloor,\"Office,Warehouse\"\nUpperFloor,BackOffice\n"
          stderr
            should eq ""
        'ipptool -t'
          exit code
            should equal 0
          stdout
            should include "[PASS]"
            should include "printer-name (nameWithoutLanguage) = CrawlSpace"
            should include "        printer-name (nameWithoutLanguage) = GroundFloor\n        member-names (1setOf nameWithoutLanguage) = Office,Warehouse\n"
            should include "        printer-name (nameWithoutLanguage) = UpperFloor\n        member-names (nameWithoutLanguage) = BackOffice\n"
          stderr
            should eq ""
      without STATUS clause
        'ipptool -c'
          exit code
            should equal 0
          stdout
            should eq "printer-name,member-names\nCrawlSpace,\nGroundFloor,\"Office,Warehouse\"\nUpperFloor,BackOffice\n"
          stderr
            should eq ""
        'ipptool -t'
          exit code
            should equal 0
          stdout
            should include "[PASS]"
            should include "printer-name (nameWithoutLanguage) = CrawlSpace"
            should include "        printer-name (nameWithoutLanguage) = GroundFloor\n        member-names (1setOf nameWithoutLanguage) = Office,Warehouse\n"
            should include "        printer-name (nameWithoutLanguage) = UpperFloor\n        member-names (nameWithoutLanguage) = BackOffice\n"
          stderr
            should eq ""
    CUPS-Get-Printers
      with STATUS successful-ok
        'ipptool -c'
          exit code
            should equal 1
          stdout
            should eq ""
          stderr
            should eq "successful-ok\n"
        'ipptool -t'
          exit code
            should equal 1
          stdout
            should include "[FAIL]"
            should include "status-code = successful-ok (successful-ok)"
            should include "printer-name (nameWithoutLanguage) = BackOffice"
            should include "printer-name (nameWithoutLanguage) = Office"
            should include "printer-name (nameWithoutLanguage) = Warehouse"
          stderr
            should eq ""
      without STATUS clause
        'ipptool -c'
          exit code
            should equal 1
          stdout
            should eq ""
          stderr
            should eq "successful-ok\n"
        'ipptool -t'
          exit code
            should equal 1
          stdout
            should include "[FAIL]"
            should include "status-code = successful-ok (successful-ok)"
            should include "printer-name (nameWithoutLanguage) = BackOffice"
            should include "printer-name (nameWithoutLanguage) = Office"
            should include "printer-name (nameWithoutLanguage) = Warehouse"
          stderr
            should eq ""

Finished in 57.01 seconds (files took 13.93 seconds to load)
110 examples, 0 failures

