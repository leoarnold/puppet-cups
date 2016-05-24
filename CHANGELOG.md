# Changelog

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
