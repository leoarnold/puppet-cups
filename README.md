# The CUPS module

<!-- release:exclude -->
[![Build Status](https://travis-ci.org/leoarnold/puppet-cups.svg)](https://travis-ci.org/leoarnold/puppet-cups)
[![Code Climate](https://codeclimate.com/github/leoarnold/puppet-cups/badges/gpa.svg)](https://codeclimate.com/github/leoarnold/puppet-cups)
[![Code Quality](https://img.shields.io/codacy/0404c3f7b7b345859d5eb9d2cbeecc39.svg)](https://www.codacy.com/app/leoarnold/puppet-cups)
[![Coverage](https://codeclimate.com/github/leoarnold/puppet-cups/badges/coverage.svg)](https://codeclimate.com/github/leoarnold/puppet-cups/coverage)
[![Depfu](https://badges.depfu.com/badges/b664de4d78caad461da4a66da7c9efeb/overview.svg)](https://depfu.com/github/leoarnold/puppet-cups)
<!-- release:include -->

[![Puppet Forge Version](https://img.shields.io/puppetforge/v/leoarnold/cups.svg)](https://forge.puppet.com/leoarnold/cups)
[![Puppet Forge Endorsement](http://img.shields.io/puppetforge/e/leoarnold/cups.svg)](https://forge.puppet.com/leoarnold/cups)
[![Puppet Forge Downloads](http://img.shields.io/puppetforge/dt/leoarnold/cups.svg)](https://forge.puppet.com/leoarnold/cups)
[![Puppet Forge Score](http://img.shields.io/puppetforge/f/leoarnold/cups.svg)](https://forge.puppet.com/leoarnold/cups)
[![Documentation](http://inch-ci.org/github/leoarnold/puppet-cups.svg?branch=master)](https://leoarnold.github.io/puppet-cups)
[![MIT License](https://img.shields.io/badge/license-MIT-yellow.svg)](LICENSE)
[![Gitter](https://badges.gitter.im/leoarnold/puppet-cups.svg)](https://gitter.im/leoarnold/puppet-cups)

## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
    * [What cups affects](#what-cups-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cups](#beginning-with-cups)
1. [Usage - A quick start guide](#usage)
    * [Managing printers](#managing-printers)
    * [Managing classes](#managing-classes)
    * [Configuring queues](#configuring-queues)
    * [Configuring CUPS](#configuring-cups)
    * [Automatic dependencies](#automatic-dependencies)
    * [Using Hiera (or any other ENC)](#using-hiera)
1. [Reference - The documentation of all features available](#reference)
    * [Classes](#classes)
    * [Types](#types)
1. [Limitations](#limitations)
    * [Evince (aka Document Viewer)](#evince-aka-document-viewer)
    * [Option defaults](#option-defaults)
1. [Contributing - Guidelines for users and developers](#contributing)

## Description

This module installs, configures, and manages the Common Unix Printing System (CUPS) service.

It provides Puppet types to install, configure, and manage CUPS printer queues and classes.

Key design goals include *locale independence* and *test driven development*.

## Setup

### What cups affects

* The CUPS packages will be installed.

* The CUPS service will be enabled and launched.

* The files in `/etc/cups/` will be modified using CUPS command line utilities.

* The entire content of the file `/etc/cups/cupsd.conf` will be managed by the module.

* The file `/etc/cups/lpoptions` will be deleted. See the section on [limitations](#option-defaults) for details.

### Setup Requirements

This module is written for and tested on Linux systems with

* Puppet 4 or 5

* CUPS `~> 1.5` or `~> 2.x`

### Beginning with CUPS

First you need to install this module. One way to do this is

```puppet
puppet module install leoarnold-cups
```

All resources in this module require the CUPS daemon to be installed and configured in a certain way.
To ensure these preconditions you should include the main `cups` class wherever you use this module:

```puppet
# General inclusion
include '::cups'

# OR

# Explicit class configuration
# (May only be defined once per catalog)
class { '::cups':
  # Your settings custom here
}
```

See the [section](#class-cups) on the `cups` class for details.
Adding printer or class resources is described in the section on [usage](#usage).

## Usage

In this section, you will learn the straightforward way to set up CUPS queues from scratch.
If the queues are already installed on the node, you can easily obtain a manifest with their current configuration by running

  ```Text
  puppet resource cups_queue
  ```

and adjust it following the instructions on [configuring queues](#configuring-queues).

### Managing Printers

There are several ways to set up a printer queue in CUPS.
This section provides the minimal manifest for each method.

**Note** These minimal manifests will *NOT* update or change the PPD file on already existing queues,
as CUPS does not provide a robust way to determine how a given queue was installed.
See however the section on [changing the driver](#changing-the-driver) for a workaround.

If you are unsure which way to choose, we recommend to set up the printer
using the tools provided by your operating system (or the [CUPS web interface](http://localhost:631)),
then take the corresponding PPD file from `/etc/cups/ppd/` and use the `ppd` method.

Minimal printer manifests:

* Creating a local raw printer:

  ```puppet
  include '::cups'

  cups_queue { 'MinimalRaw':
    ensure => 'printer',
    uri    => 'lpd://192.168.2.105/binary_p1' # Replace with your printer's URI
  }
  ```

  To configure this queue see the section on [setting the usual options](#configuring-queues) or the `cups_queue` [type reference](#type-cups_queue).

* Using a suitable model from the output of the command `lpinfo -m` on the node:

  ```puppet
  include '::cups'

  cups_queue { 'MinimalModel':
    ensure => 'printer',
    model  => 'drv:///sample.drv/generic.ppd',
    uri    => 'lpd://192.168.2.105/binary_p1' # Replace with your printer's URI
  }
  ```

  To configure this queue see the section on [setting the usual options](#configuring-queues) or the `cups_queue` [type reference](#type-cups_queue).

* Using a custom PPD file:

  ```puppet
  include '::cups'

  cups_queue { 'MinimalPPD':
    ensure => 'printer',
    ppd    => '/usr/share/cups/model/myprinter.ppd',
    uri    => 'lpd://192.168.2.105/binary_p1' # Replace with your printer's URI
  }
  ```

  To configure this queue see the section on [setting the usual options](#configuring-queues) or the [type reference](#type-cups_queue).

  In a master-agent setting, you could transfer the PPD file to the client using a `file` resource

  ```puppet
  file { '/usr/share/cups/model/myprinter.ppd':
    ensure => 'file',
    source => 'puppet:///modules/myModule/myprinter.ppd'
  }
  ```

  which will automatically be required by `Cups_queue['MinimalPPD']`.

#### Changing the driver

When a printer queue is already present and managed using a PPD file,
it is generally hard to tell which model or PPD file was used to install the queue.
Nevertheless it might become necessary to change the model or update the PPD file
*without* changing the queue name, e.g. because the PPD file contains some login credentials.

This module introduces a way to update the driver (i.e. force a reinstall)
through syncing the `make_and_model` property, which defaults to

* the `NickName` (fallback `ModelName`) value from the printer's PPD file in `/etc/cups/ppd/`
  if the printer was installed using a PPD file or a model.

* `Local Raw Printer` for raw print queues.

**Example:** On the node, running `puppet resource cups_queue Office` returns

  ```puppet
  cups_queue { 'Office':
    ensure         => 'printer',
    make_and_model => 'HP Color LaserJet 4730mfp Postscript (recommended)',
    # ...
  }
  ```

and you would like to

* use a different model

  ```Text
  $ lpinfo -m | grep 4730mfp
  # ...
  drv:///hpcups.drv/hp-color_laserjet_4730mfp-pcl3.ppd HP Color LaserJet 4730mfp pcl3, hpcups 3.14.3
  postscript-hp:0/ppd/hplip/HP/hp-color_laserjet_4730mfp-ps.ppd HP Color LaserJet 4730mfp Postscript (recommended)
  # ...
  ```

  then you just need to adapt the manifest from above to

  ```puppet
  cups_queue { 'Office':
    ensure         => 'printer',
    model          => 'drv:///hpcups.drv/hp-color_laserjet_4730mfp-pcl3.ppd',
    make_and_model => 'HP Color LaserJet 4730mfp pcl3, hpcups 3.14.3',
    # ...
  }
  ```

* use a custom PPD file instead which contains the line

  ```Text
  *NickName: "HP Color LaserJet 4730mfp Postscript (MyCompany v2)"
  ```

  then you just need to adapt the manifest from above to

  ```puppet
  cups_queue { 'Office':
    ensure         => 'printer',
    ppd            => '/usr/share/cups/model/hp4730v2.ppd',
    make_and_model => 'HP Color LaserJet 4730mfp Postscript (MyCompany v2)',
    # ...
  }
  ```

* make it a raw queue. Then you just need to adapt the manifest from above to

  ```puppet
  cups_queue { 'Office':
    ensure         => 'printer',
    make_and_model => 'Local Raw Printer',
    # ...
  }
  ```

### Managing Classes

When defining a printer class, it is *mandatory* to also define its member printers in the same catalog:

  ```puppet
  include '::cups'

  cups_queue { 'MinimalClass':
    ensure  => 'class',
    members => ['Office', 'Warehouse']
  }

  cups_queue { 'Office':
    ensure => 'printer',
    # ...
  }

  cups_queue { 'Warehouse':
    ensure => 'printer',
    # ...
  }
  ```

The `Cups_queue['MinimalClass']` resource will automatically require its member resources `Cups_queue['Office', 'Warehouse']`.

### Configuring queues

Once you have your minimal [printer](#managing-printers) or [class](#managing-classes) manifest,
you will need to apply some configuration.

**Job handling:**
In CUPS, newly installed queues are disabled and rejecting by default, which can lead to confusion at times.
The corresponding `cups_queue` properties are:

* `accepting`: Should incoming jobs be enqueued or rejected?

* `enabled`: Should pending jobs be sent to the device or kept pending?

If you want your print queues to "just work", you should set both to `true`.
This module does not set default values by itself, since it might be of disadvantage in a professional copy shop environment.

Most users will prefer to set both options to `true` for all queues using

   ```puppet
   Cups_queue {
     accepting => true,
     enabled   => true
   }
   ```

**Option defaults:**
Sometimes you need to set some default values for CUPS or vendor options of a print queue,
e.g. to enable Duplex to save trees or because you use A4 paper instead of US Letter.

To see all vendor options and their possible values for the queue `Office`, you can use `lpoptions`:

  ```Text
  $ lpoptions -p Office -l
  PageSize/Media Size: *Letter Legal Executive Tabloid A3 A4 A5 B5 EnvISOB5 Env10 EnvC5 EnvDL EnvMonarch
  InputSlot/Media Source: *Default Upper Manual
  Duplex/2-Sided Printing: *None DuplexNoTumble DuplexTumble
  Option1/Duplexer: *False True
  ```

The asterisk (*) indicates the current value. Use this to adapt your manifest

  ```puppet
  cups_queue { 'Office':
    # ...
    options => {
      'Duplex'   => 'DuplexNoTumble',
      'PageSize' => 'A4',
    }
  }
  ```

You only need to provide values for options you actually care about.

**Access control:**
Of course you want your boss Mr. Lumbergh, the secretary Nina and every member of the workers' council
to be able to print to the office printer from every node. But all others should be denied to use this printer.

Assuming they respectively have the user accounts `lumbergh`, `nina`, and the user group `council`,
this can be achieved by:

  ```puppet
  cups_queue { 'Office':
    # ...
    access => {
      'policy' => 'allow',
      'users'  => ['lumbergh', 'nina', '@council'],
    }
  }
  ```

Note that group names must be prefixed with an `@` sign.

Changing the policy to `deny` would deny all `users`, but allow everybody else.
Furthermore, you can unset all restrictions by using

  ```puppet
  cups_queue { 'Office':
    # ...
    access => {
      'policy' => 'allow',
      'users'  => ['all'],
    }
  }
  ```

because `all` is interpreted by CUPS as a wildcard, not as an account name.

### Configuring CUPS

Now that you have created manifest for all your queues, you may want to set the default destination.

  ```puppet
  class { '::cups'
    default_queue => 'Office',
  }
  ```

This will require the resource `Cups_queue['Office']` to be defined in the catalog.

To find out about all options available for `Class['::cups']` see the [section below](#class-cups).

### Automatic dependencies

For your convenience, this module establishes many resource dependencies automatically.
For example, on a Debian system the manifest

```puppet
class { '::cups':
  default_queue => 'Warehouse'
}

cups_queue { 'GroundFloor':
  ensure  => 'class',
  members => ['Office', 'Warehouse']
}

cups_queue { 'Office':
  ensure => 'printer',
  # ...
}

cups_queue { 'Warehouse':
  ensure => 'printer',
  # ...
}
```

by default generates the dependencies

```Text
                     Class['cups']
                    /             \
Cups_queue['Office']               Cups_queue['Warehouse']
                    \             /                       \
               Cups_queue['GroundFloor']                   Class['cups::queues::default']
```

### Using Hiera

Make sure your Puppet setup includes the `::cups` class on the relevant nodes.
Configuration is straightforward:

```YAML
---
cups::default_queue: Warehouse
cups::web_interface: true
```

Beyond that you can also create `cups_queue` resources using Hiera. Just replace a manifest like

```puppet
class { 'cups':
  default_queue => 'Warehouse',
  web_interface => true
}

cups_queue { 'MinimalClass':
  ensure  => 'class',
  members => ['Office', 'Warehouse']
}

cups_queue { 'Office':
  ensure => 'printer',
  uri    => 'socket://office.initech.com',
}

cups_queue { 'Warehouse':
  ensure => 'printer',
  uri    => 'socket://warehouse.initech.com',
}
```

with the Hiera data

```YAML
---
cups::default_queue: Warehouse
cups::web_interface: true
cups::resources:
  GroundFloor:
    ensure: class
    members:
      - Office
      - Warehouse
  Office:
    ensure: printer
    uri: socket://office.initech.com
  Warehouse:
    ensure: printer
    uri: socket://warehouse.initech.com
```

## Reference

### Classes

* [`cups`](#class-cups)

### Types

* [`cups_queue`](#type-cups_queue)

#### Class: `cups`

Installs, configures, and manages the CUPS service.

##### Attributes

* `default_queue`: The name of the default destination for all print jobs.
  Requires the catalog to contain a `cups_queue` resource with the same name.

* `listen`: Which addresses to the CUPS daemon should listen to.
  Accepts (an array of) strings.
  Defaults to `['localhost:631', '/var/run/cups/cups.sock']`.
  Note that the `cupsd.conf` directive `Port 631` is equivalent to `Listen *:631`.
  *Warning*: For this module to work, it is *mandatory* that CUPS is listening on `localhost:631`.

* `package_ensure`: Whether CUPS packages should be `present` or `absent`. Defaults to `present`.

* `package_manage`: Whether to manage package installation at all. Defaults to `true`.

* `package_names`: A name or an array of names of all packages needed to be installed
  in order to run CUPS and provide `ipptool`. OS dependent defaults apply.

* `papersize`: Sets the system's default `/etc/papersize`. See `man papersize` for supported values.

* `purge_unmanaged_queues`: Setting `true` will remove all queues from the node
  which do not match a `cups_queue` resource in the current catalog. Defaults to `false`.

* `resources`: This attribute is intended for use with Hiera or any other ENC (see the [example above](#using-hiera)).

* `service_enable`: Whether the CUPS services should be enabled to run at boot.
  Defaults to `true`.

* `service_ensure`: Whether the CUPS services should be `running` or `stopped`.
  Defaults to `running`.

* `service_manage`:  Whether to manage services at all. Defaults to `true`.

* `service_names`: A name or an array of names of all CUPS services to be managed. Defaults to `cups`.

* `web_interface`:  Boolean value to enable or disable the server's web interface.

#### Type: `cups_queue`

Installs and manages CUPS print queues.

##### Attributes

* `name`: (mandatory) Queue names may contain any printable character
  except SPACES, TABS, (BACK)SLASHES, QUOTES, COMMAS or "#".
  We recommend to use only ASCII characters because the node's shell might not support Unicode.

* `ensure`: *mandatory* - Specifies whether this queue should be a `class`, a `printer` or `absent`.

* `access`: Manages queue access control. Takes a hash with keys `policy` and `users`.
  The `allow` policy restricts access to the `users` provided, while the `deny` policy
  lets everybody submit jobs except the specified `users`.
  The `users` are provided as a non-empty array of Unix group names (prefixed with an `@`) and Unix user names.

* `accepting`: Boolean value specifying whether the queue should accept print jobs or reject them.

* `description`: A short informative description of the queue.

* `enabled`: Boolean value specifying whether the queue should be running or stopped.

* `held`: A held queue will print all jobs in print or pending, but all new jobs will be held.
  Setting `false` will release them.

* `location`: A short information where to find the hard copies.

* `options`: A hash of options (as keys) and their target value. Almost every option you can set with
  `lpadmin -p [queue_name] -o key=value` is supported here. Use `puppet resource cups_queue [queue_name]`
  on the node for a list of all supported options for the given queue, and `lpoptions -p [queue_name] -l`
  to see a list of available values for the most commonly used printer specific options.

* `shared`: Boolean value specifying whether to share this queue on the network.

##### Class-only attributes

* `members`: *mandatory* - A non-empty array with the names of CUPS queues.
  The class will be synced to contain only these members in the given order.
  If the catalog contains `cups_queue` resources for these queues, they will be required automatically.

##### Printers-only attributes

* `make_and_model`: This value is used for [driver updates and changes](#changing-the-driver).
  Matches the `NickName` (fallback `ModelName`) value from the printer's PPD file
  if the printer was installed using a PPD file or a model,
  and `Local System V Printer` or `Local Raw Printer` otherwise.

* `model`: A supported printer model. Use `lpinfo -m` on the node to list all models available.

* `ppd`: The absolute path to a PPD file on the node.
  If the catalog contains a `file` resource with this path as title, it will automatically be required.
  The recommended location for your PPD files is `/usr/share/cups/model/` or `/usr/local/share/cups/model/`.

* `uri`: The device URI of the printer. Use `lpinfo -v` on the node to scan for printer URIs.

## Limitations

### Evince (aka Document Viewer)

Setting `papersize => 'a4'` only modifies `/etc/papersize`,
but [Evince](https://wiki.gnome.org/Apps/Evince) uses
the environment variable `LC_PAPER` to determine your preferred paper size,
as [Patrick Min](http://www.patrickmin.com/linux/tip.php?name=evince_default_paper_size) figured out.

On Debian and Ubuntu, you can set a global default value for `LC_PAPER` using the manifest

```puppet
augeas { 'papersize':
  context => '/files/etc/default/locale',
  changes => 'set LC_PAPER \'"es_ES.UTF-8"\'' # Change to your locale
}
```

### Option defaults

Sometimes it may be necessary to modify the default values for some queue options to ensure an intuitive user experience,
e.g. to enable the use of an optional duplex unit.
For historic reasons there are two ways to set default values for all users:

* Daemon defaults are set using `sudo lpadmin` and will affect all jobs from both local and remote hosts.
  The CUPS daemon saves them frequently - but not immediately - to `/etc/cups/classes.conf`,
  `/etc/cups/printers.conf`, and the PPD files in `/etc/cups/ppd/`.

* Local defaults are set using `sudo lpoptions` and will only affect jobs from the local host,
  *overriding* the daemon defaults for these jobs. The values are saved to the file `/etc/cups/lpoptions`.

Hence there is no robust way to determine the current daemon defaults when used in conjunction with local defaults.
If local defaults aren't used, the command `lpoptions -p [queue_name] -l` will return the daemon defaults.

In order to provide a stable and idempotent way for Puppet to set default option values for all jobs sent to a queue,
this module will *disable* the use of local defaults by deleting the file `/etc/cups/lpoptions`.

## Contributing

There are several ways to contribute for both users and developers:

* If you like this module, please show your appreciation by giving it a
  [positive rating](https://forge.puppet.com/leoarnold/cups) in the Puppet Forge
  and spreading the news in your favorite way.

* Want to suggesting a new feature, point out a flaw in the documentation or report a bug?
  Please open a [GitHub issue](https://github.com/leoarnold/puppet-cups/issues)
  using the suggested skeleton from the [contribution guidelines](CONTRIBUTING.md).

* Developers might want to submit a [GitHub pull request](https://github.com/leoarnold/puppet-cups/pulls).
  It is highly recommended to open an **issue first** and discuss changes with the maintainer.
  See the [contribution guidelines](CONTRIBUTING.md) for our quality standards and legal requirements.

_Thank you for your interest in the CUPS module_.
