class cups::queues::unmanaged inherits cups::queues {

  resources { 'cups_queue':
    purge   => $::cups::purge_unmanaged_queues,
  }

}
