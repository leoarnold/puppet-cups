# Private class
#
# @summary Handles the installation of all required CUPS packages
#
# This class is a convenience wrapper around a `package` resource.
# It inherits the `package_*` attributes from the public {cups} class
# and by default ensures their presence.
#
# @author Leo Arnold
# @since 2.0.0
#
# @example This class is implicitly declared through
#   class { '::cups':
#     package_names => ['cups', 'ipptool']
#   }
#
class cups::packages inherits cups {

  if ($::cups::package_manage) {
    package { $::cups::package_names :
      ensure  => $::cups::package_ensure,
    }
  }

}
