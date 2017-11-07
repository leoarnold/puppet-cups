# Private class
#
# @summary Manages all OS dependent values.
#
# The name of the `cups` and `ipptool` packages for all supported
# operating systems are stored here and determined through facts.
#
# @author Leo Arnold
# @since 1.0.0
#
class cups::params {

  case $facts['os']['family'] {
    'Debian': {
      case $facts['os']['name'] {
        'Debian': {
          if (versioncmp($facts['os']['release']['major'], '7') >= 0) and (versioncmp($facts['os']['release']['major'], '9') < 0) {
            # CUPS ~> 1.5
            $package_names = ['cups']
          } elsif (versioncmp($facts['os']['release']['major'], '9') >= 0) {
            # CUPS ~> 2.0
            $package_names = ['cups', 'cups-ipp-utils']
          }
        }
        'Ubuntu': {
          if (versioncmp($facts['os']['release']['major'], '14.04') >= 0) and (versioncmp($facts['os']['release']['major'], '15.10') < 0) {
            # CUPS ~> 1.5
            $package_names = ['cups']
          } elsif (versioncmp($facts['os']['release']['major'], '15.10') >= 0) {
            # CUPS ~> 2.0
            $package_names = ['cups', 'cups-ipp-utils']
          }
        }
        'LinuxMint': {
          if (versioncmp($facts['os']['release']['major'], '17') >= 0) and (versioncmp($facts['os']['release']['major'], '18') < 0) {
            # CUPS ~> 1.5
            $package_names = ['cups']
          } elsif (versioncmp($facts['os']['release']['major'], '18') >= 0) {
            # CUPS ~> 2.0
            $package_names = ['cups', 'cups-ipp-utils']
          }
        }
        default: {
          $package_names = undef
        }
      }
    }

    'RedHat': {
      $package_names = ['cups', 'cups-ipptool']
    }
    'Suse': {
      $package_names = ['cups']
    }
    default: {
      $package_names = undef
    }
  }

}
