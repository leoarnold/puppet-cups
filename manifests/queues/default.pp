class cups::queues::default inherits cups::queues {

  if ($::cups::default_queue) {
    exec { 'cups::queues::default':
      command => "lpadmin -E -d '${::cups::default_queue}'",
      unless  => "lpstat -d | grep -w '${::cups::default_queue}'",
      path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
      require => Cups_queue[$::cups::default_queue]
    }
  }

}
