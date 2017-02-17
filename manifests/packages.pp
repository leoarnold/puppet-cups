class cups::packages inherits cups {

  if ($package_manage) {
    package { $package_names :
      ensure  => $package_ensure,
    }
  }

}
