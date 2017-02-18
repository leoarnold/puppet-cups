class cups::queues inherits cups {

  contain cups::queues::default
  contain cups::queues::resources
  contain cups::queues::unmanaged

}
