# Changelog

## 2017-01-18 - Bugfix release 2.0.3

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/2.0.3)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/2.0.3).

### Summary

This release fixes several bugs where retrieved values were still
surrounded by quotes, thereby incorrectly breaking idempotence.

## 2017-11-21 - Bugfix release 2.0.2

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/2.0.2)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/2.0.2).

### Summary

This release fixes a conflict when using remotely shared queues.

### Bugfixes

- Removed the default value `shared => false` for type `cups_queue`
  in order to comply with [CUPS #4766](https://github.com/apple/cups/issues/4766)

## 2017-11-16 - Official Approval by Puppet Inc

We are proud to announce that Puppet Inc [officially approved](https://tickets.puppetlabs.com/browse/MODULES-5903)
version 2.0.1 of this module.

## 2017-11-09 - Service release 2.0.1

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/2.0.1)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/2.0.1).

### Summary

This service release adds extensive inline documentation
and some code quality improvements.

### Improvements

- Inline [Yard](https://yardoc.org) and [Puppet Strings](https://github.com/puppetlabs/puppet-strings) documentation
- Online [Yard documentation](https://leoarnold.github.io/puppet-cups)
- Several Ruby modules refactored to static methods of a single module
- Tests now use unquoted booleans as customary in Puppet 5

## 2017-11-01 - Release 2.0.0

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/2.0.0)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/2.0.0).

### Summary

The new major release drops support for Puppet 3 installations
and introduces some breaking changes in the API.
Please adjust your manifests according to the [upgrade instructions](UPGRADING.md).

### Breaking changes

- Puppet 3.x is no longer supported. All manifests now use Puppet 4 syntax
- Ruby 1.x is no longer supported since Puppet 4 comes with Ruby `~> 2.1`
- All facts were removed
- Some attributes were removed from the `cups` class
- The defined type `cups::ctl` was removed
- System V interface scripts are no longer supported
  since CUPS dropped support for them in [V2.2b1](https://github.com/apple/cups/blob/v2.2.0/CHANGES.txt#L67)

### Features

- `Class[cups]` now features tunables for package and service management
- The `Listen` directive of `cupsd.conf` can now be managed through `Class[cups]`
- `cups_queue` now supports managing the option `auth-info-required`

### Bugfixes

- Execution of `ipptool` now enjoys more comprehensive error handling
- A fallback method for IPP queries was added to enable correct execution
  even on systems with an erroneous CUPS installation (e.g. Ubuntu 16.10 and 17.04)
- Queue names with special characters (e.g. ampersands) are now handled correctly
- Handling of queue option `job-sheets-default` was fixed

## 2016-05-24 - Maintenance release 1.2.2

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/1.2.2)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/1.2.2).

### Summary

This release fixes package installation on Debian derivatives shipping with CUPS 2.x.

### Changes

- On Debian derivatives shipping with CUPS 2.x, the package `cups-ipp-utils` will now be installed automatically
- Acceptance tests were adapted to work on Ruby 2.x

## 2016-05-17 - Maintenance release 1.2.1

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/1.2.1)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/1.2.1).

### Summary

This release improves the module's log message output.

### Changes

- The private class `cups::default_queue` now logs which queue was set as daemon default
- The new private class `cups::papersize` now logs which papersize was set

## 2016-05-12 - Release 1.2.0

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/1.2.0)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/1.2.0).

### Summary

This release introduces some new functionality.

### Features

- Direct resource creation by an External Node Classifier (as requested in issue #2)
- Managing `/etc/papersize`

## 2016-04-10 - Release 1.1.0

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/1.1.0)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/1.1.0).

### Summary

This release introduces a new feature and adjusts to Puppet's brand refresh.

### Features

- All unmanaged CUPS queues can now be removed automatically

## 2016-03-19 - Maintenance release 1.0.2

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/1.0.2)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/1.0.2).

### Summary

This maintenance release overcomes an unintuitive 3rd-party behavior
and improves the internal structure of the module.

### Changes in default behavior

- The default value for `ensure` was removed.

### Bugfixes

- A workaround for [CUPS issue 4781](https://github.com/apple/cups/issues/4781)
- Using `puppet resource cups_queue` to modify an already installed queue
  is now possible without specifying `ensure`
- Automatic resource relations were adjusted to show up correctly in the dependency graph

## 2016-03-19 - Maintenance release 1.0.1

_retracted_.

## 2016-03-07 - Release 1.0.0

Published at [Puppet Forge](https://forge.puppet.com/leoarnold/cups/1.0.0)
and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/1.0.0).

### Summary

Existing CUPS modules in the [Puppet Forge](https://forge.puppet.com/) lacked some desirable functionality by design.
This module was written from scratch, taking divergent architectural decisions and employing test driven development
to provide all features required in an office network setting.

### Key features

- Locale independence (tested on English and Spanish VMs)
- Support for a wide range of Linux distributions
- Unified support for printer queues and class queues
- Default queue management
- Support for printer driver changes
- Support for queue access control
- Unified support for CUPS options and PPD options
