## 2016-03-07 - Release 1.0.0

Published at [PuppetForge](https://forge.puppetlabs.com/leoarnold/cups/1.0.0) and [GitHub](https://github.com/leoarnold/puppet-cups/releases/tag/1.0.0).

### Summary
Existing CUPS modules in the [PuppetForge](https://forge.puppetlabs.com/) lacked some desirable functionality by design.
This module was written from scratch, taking divergent architectural decisions and employing test driven development
to provide all features required in an office network setting.

### Key features
- Locale independence (tested on english and spanish VMs)
- Support for a wide range of Linux distributions
- Unified support for printer queues and class queues
- Default queue management
- Support for printer driver changes
- Support for queue access control
- Unified support for CUPS options and PPD options
