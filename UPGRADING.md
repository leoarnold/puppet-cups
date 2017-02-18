# Upgrade instructions

## From 1.2.2 to 2.0.0

### Class: `cups`

#### Attribute `confdir`

The attribute was removed without alternative.
The module now only supports `/etc/cups` as CUPS configuration directory.

#### Attribute `hiera`

The attribute was removed. Refactor to use `resources`.
See the [Hiera example](examples/using_hiera/) for more information.

#### Attribute `packages`

The attribute was renamed to `package_names`.
Package management can now be disabled using `package_manage => false`.

#### Attribute `services`

The attribute was renamed to `service_names`.
service management can now be disabled using `service_manage => false`.

#### Attribute `webinterface`

The attribute was renamed to `web_interface`.

### Define `cups::ctl`

The define `cups::ctl` was removed without alternative.
