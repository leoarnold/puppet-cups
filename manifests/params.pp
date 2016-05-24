# Class: cups::params
#
# Provides platform dependent default parameters
#
class cups::params {

  case $::osfamily {
    'Debian': {
      case $::operatingsystem {
        'Debian': {
          if (versioncmp($::lsbdistrelease, '7') >= 0) and (versioncmp($::lsbdistrelease, '9') < 0) {
            # CUPS ~> 1.5
            $packages = ['cups']
            $services = ['cups']
          } elsif (versioncmp($::lsbdistrelease, '9') >= 0) {
            # CUPS ~> 2.0
            $packages = ['cups', 'cups-ipp-utils']
            $services = ['cups']
          }
        }
        'Ubuntu': {
          if (versioncmp($::lsbdistrelease, '14.04') >= 0) and (versioncmp($::lsbdistrelease, '15.10') < 0) {
            # CUPS ~> 1.5
            $packages = ['cups']
            $services = ['cups']
          } elsif (versioncmp($::lsbdistrelease, '15.10') >= 0) {
            # CUPS ~> 2.0
            $packages = ['cups', 'cups-ipp-utils']
            $services = ['cups']
          }
        }
        'LinuxMint': {
          if (versioncmp($::lsbdistrelease, '17') >= 0) and (versioncmp($::lsbdistrelease, '18') < 0) {
            # CUPS ~> 1.5
            $packages = ['cups']
            $services = ['cups']
          } elsif (versioncmp($::lsbdistrelease, '18') >= 0) {
            # CUPS ~> 2.0
            $packages = ['cups', 'cups-ipp-utils']
            $services = ['cups']
          }
        }
        default: {
          $packages = undef
          $services = undef
        }
      }
    }

    'RedHat': {
      $packages = ['cups', 'cups-ipptool']
      $services = ['cups']
    }
    'Suse': {
      $packages = ['cups']
      $services = ['cups']
    }
    default: {
      $packages = undef
      $services = undef
    }
  }

  $confdir = '/etc/cups'

}