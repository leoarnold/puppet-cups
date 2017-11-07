# Private class
#
# @summary A convenience wrapper around the `resources` metatype.
#
# This class inherits the `purge_unmanaged_queues` attribute from the public {cups} class.
# If set to `true` all CUPS queues not managed in the current Puppet catalog will be deleted.
#
# @author Leo Arnold
# @since 2.0.0
#
# @example This class is implicitly declared through
#   class { '::cups':
#     purge_unmanaged_queues => true
#   }
#
class cups::queues::unmanaged inherits cups::queues {

  resources { 'cups_queue':
    purge   => $::cups::purge_unmanaged_queues,
  }

}
