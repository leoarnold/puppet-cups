class cups::packages inherits cups {

  if ($::cups::package_manage) {
    package { $::cups::package_names :
      ensure  => $::cups::package_ensure,
    }
  }

}
