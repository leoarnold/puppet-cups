# Private class
#
# @summary Manages the default destination of the CUPS server.
#
# This class inherits the name of the desired `default_queue` from the public {cups} class.
# A corresponding {puppet_types::cups_queue} resource is required in the same catalog,
# or catalog compliation will fail.
#
# @author Leo Arnold
# @since 2.0.0
#
# @example This class is implicitly declared through
#   class { '::cups':
#     default_queue => 'Office'
#   }
#
class cups::queues::default inherits cups::queues {

  if ($::cups::default_queue) {
    exec { 'cups::queues::default':
      command => "lpadmin -d '${::cups::default_queue}'",
      unless  => "lpstat -d | grep -w '${::cups::default_queue}'",
      path    => ['/usr/sbin/', '/usr/bin/', '/sbin/', '/bin/'],
      require => Cups_queue[$::cups::default_queue]
    }
  }

}
