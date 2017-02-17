# Class 'cups'
#
class cups (
  Optional[String] $default_queue          = undef,
  String           $package_ensure         = 'present',
  Boolean          $package_manage         = true,
  Array[String]    $package_names          = $::cups::params::package_names,
  Optional[String] $papersize              = undef,
  Boolean          $purge_unmanaged_queues = false,
  String           $service_ensure         = 'running',
  Boolean          $service_enable         = true,
  Boolean          $service_manage         = true,
  String           $service_name           = 'cups',
) inherits cups::params {

  contain cups::packages
  contain cups::server
  contain cups::queues

  Class[cups::packages]
  -> Class[cups::server]
  -> Class[cups::queues]

}
