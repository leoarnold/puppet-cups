# Class: cups::params
#
# Provides platform dependent default parameters
#
class cups::params {

  case $::osfamily {
    'RedHat': {
      $packages = ['cups', 'cups-ipptool']
      $services = ['cups']
    }
    'Debian', 'Suse': {
      $packages = ['cups']
      $services = ['cups']
    }
    default: {
      $packages = undef
      $services = undef
    }
  }

  $lpoptions_file = '/etc/cups/lpoptions'

}