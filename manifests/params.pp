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
            $package_names = ['cups']
            $services = ['cups']
          } elsif (versioncmp($::lsbdistrelease, '9') >= 0) {
            # CUPS ~> 2.0
            $package_names = ['cups', 'cups-ipp-utils']
            $services = ['cups']
          }
        }
        'Ubuntu': {
          if (versioncmp($::lsbdistrelease, '14.04') >= 0) and (versioncmp($::lsbdistrelease, '15.10') < 0) {
            # CUPS ~> 1.5
            $package_names = ['cups']
            $services = ['cups']
          } elsif (versioncmp($::lsbdistrelease, '15.10') >= 0) {
            # CUPS ~> 2.0
            $package_names = ['cups', 'cups-ipp-utils']
            $services = ['cups']
          }
        }
        'LinuxMint': {
          if (versioncmp($::lsbdistrelease, '17') >= 0) and (versioncmp($::lsbdistrelease, '18') < 0) {
            # CUPS ~> 1.5
            $package_names = ['cups']
            $services = ['cups']
          } elsif (versioncmp($::lsbdistrelease, '18') >= 0) {
            # CUPS ~> 2.0
            $package_names = ['cups', 'cups-ipp-utils']
            $services = ['cups']
          }
        }
        default: {
          $package_names = undef
          $services = undef
        }
      }
    }

    'RedHat': {
      $package_names = ['cups', 'cups-ipptool']
      $services = ['cups']
    }
    'Suse': {
      $package_names = ['cups']
      $services = ['cups']
    }
    default: {
      $package_names = undef
      $services = undef
    }
  }

}