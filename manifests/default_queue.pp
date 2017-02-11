# Class: cups::default_queue
#
# Sets the default destination for all print jobs.
#
# Every node can only have one default CUPS destination.
# Therefore we implement it as class to generate a Puppet catalog singleton.
#
class cups::default_queue (
  String $queue,
) {
  $queue_e = shellquote($queue)
  exec { "lpadmin-d-${queue}":
    command => "lpadmin -E -d ${queue_e}",
    unless  => "lpstat -d | grep -w ${queue_e}",
    path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
    require => Cups_queue[$queue]
  }

}
