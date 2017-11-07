# Private class
#
# @summary Encapsulates all private classes managing the CUPS server.
#
# This class encapsulates the management of the CUPS server and its configuration files,
# and serves as a common container for dependecy relationships.
#
# @author Leo Arnold
# @since 2.0.0
#
class cups::server inherits cups {

  contain cups::server::config
  contain cups::server::services

  Class[cups::server::config]
  ~> Class[cups::server::services]

}
