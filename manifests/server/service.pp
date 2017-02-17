class cups::server::service inherits cups::server {

  if ($::cups::service_manage) {
    service { $::cups::service_name :
      ensure  => $::cups::service_ensure,
      enable  => $::cups::service_enable,
    }
  }

}
