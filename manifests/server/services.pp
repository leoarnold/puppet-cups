# Private class
#
# @summary Installs and manages all required CUPS services
#
# This class is a convenience wrapper around a `service` resource.
# It inherits the `service_*` attributes from the public {cups} class
# and by default ensures their presence.
#
# @author Leo Arnold
# @since 2.0.0
#
# @example This class is implicitly declared through
#   class { '::cups':
#     service_names => 'cups'
#   }
#
class cups::server::services inherits cups::server {

  if ($::cups::service_manage) {
    service { $::cups::service_names :
      ensure => $::cups::service_ensure,
      enable => $::cups::service_enable,
    }
  }

}
