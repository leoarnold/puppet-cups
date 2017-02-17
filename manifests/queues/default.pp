class cups::queues::default inherits cups::queues {

  if ($default_queue) {
    exec { 'cups::queues::default':
      command => "lpadmin -E -d '${default_queue}'",
      unless  => "lpstat -d | grep -w '${default_queue}'",
      path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
      require => Cups_queue[$default_queue]
    }
  }

}
