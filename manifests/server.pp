# Class 'cups::server'
#
# Manages the CUPS server configuration files.
#
class cups::server inherits cups {

  contain cups::server::config
  contain cups::server::service

  Class[cups::server::config]
  ~> Class[cups::server::service]

}
