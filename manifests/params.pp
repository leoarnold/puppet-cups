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
      fail('This version of the CUPS module does not know how to install or manage the CUPS service on your operating system.')
    }
  }

  $lpoptions_file = '/etc/cups/lpoptions'

}