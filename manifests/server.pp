# Class 'cups::server'
#
# Manages the CUPS server configuration files.
#
class cups::server inherits cups {

  contain cups::server::config
  contain cups::server::services

  Class[cups::server::config]
  ~> Class[cups::server::services]

}
