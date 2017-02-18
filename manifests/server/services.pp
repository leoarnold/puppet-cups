class cups::server::services inherits cups::server {

  if ($::cups::service_manage) {
    service { $::cups::service_names :
      ensure => $::cups::service_ensure,
      enable => $::cups::service_enable,
    }
  }

}
