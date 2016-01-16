# Class: cups::default_queue
#
# Every node can only have one default CUPS destination.
# Therefore we implement it as class to generate a Puppet catalog singleton.
#
class cups::default_queue (
  $queue
) {
  validate_string($queue)

  exec { 'lpadmin-d':
    command => "lpadmin -d ${queue}",
    unless  => "lpstat -d | grep ${queue}",
    path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
    require => Cups_queue[$queue]
  }
}