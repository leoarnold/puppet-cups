# Class: cups
class cups {
  package { 'cups':
    ensure => present,
  }

  service { 'cups':
    ensure  => running,
    enable  => true,
    require => Package['cups'],
  }
}
