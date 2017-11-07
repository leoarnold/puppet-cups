# Private class
#
# @summary Creates cups_queue resources from hashes.
#
# This class is a convenience wrapper around the `create_resources` function.
# It inherits the `resources` attribute from the public {cups} class
# and enables Hiera or any other ENC to create {puppet_types::cups_queue} resources.
#
# @author Leo Arnold
# @since 2.0.0
#
# @example This class is implicitly used when providing Hiera data like
#   cups::resources:
#     Warehouse:
#       ensure: printer
#       model: drv:///sample.drv/generic.ppd
#       uri: socket://warehouse.initech.com
#
class cups::queues::resources {

  if ($::cups::resources) {
    create_resources('cups_queue', $::cups::resources)
  }

}
