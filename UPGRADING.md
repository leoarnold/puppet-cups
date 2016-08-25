# Upgrade instructions

## From 1.2.2 to 2.0.0

### Class: `cups`

#### Attribute `confdir`

Before:

```Puppet
class { '::cups':
  confdir => '/etc/custom_dir',
}
```

After:

```Puppet
class { '::cups':
}

class { '::cups::server':
  conf_directory => '/etc/custom_dir',
}
```

#### Attribute `webinterface`

Before:

```Puppet
class { '::cups':
  webinterface => true,
}
```

After:

```Puppet
class { '::cups':
}

class { '::cups::server':
  web_interface => true,
}
```

### Define `cups::ctl`

Use the corresponding attribute of the new class `cups::server`.
See the [manual](README.md#class-cupsserver) for a complete list of available attributes.
