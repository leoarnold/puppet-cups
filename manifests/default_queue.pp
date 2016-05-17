# Class: cups::default_queue
#
# Sets the default destination for all print jobs.
#
# Every node can only have one default CUPS destination.
# Therefore we implement it as class to generate a Puppet catalog singleton.
#
# String :: queue
#
class cups::default_queue (
  $queue
) {
  validate_string($queue)

  exec { "lpadmin-d-${queue}":
    command => "lpadmin -E -d ${queue}",
    unless  => "lpstat -d | grep -w ${queue}",
    path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
    require => Cups_queue[$queue]
  }
}
