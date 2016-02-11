# Class: cups
#
# Installs, configures, and manages the CUPS service and related files.
#
class cups inherits ::cups::params {

  package { $::cups::packages :
    ensure  => 'present',
  }

  service { $::cups::services :
    ensure  => 'running',
    enable  => true,
    require => Package[$::cups::packages],
  }

}
