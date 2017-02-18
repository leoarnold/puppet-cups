class cups::queues::resources {

  if ($::cups::resources) {
    create_resources('cups_queue', $::cups::resources)
  }

}
