# The CUPS module

Development:
[![Build Status](https://travis-ci.org/leoarnold/puppet-cups.svg)](https://travis-ci.org/leoarnold/puppet-cups)
[![Gemnasium](https://img.shields.io/gemnasium/leoarnold/puppet-cups.svg)](https://gemnasium.com/leoarnold/puppet-cups)

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with cups](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with cups](#beginning-with-cups)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
    * [Classes](#classes)
    * [Defines](#defines)
    * [Types](#types)
    * [Facts](#facts)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module installs, configures, and manages the Common Unix Printing System (CUPS) service.

It provides Puppet types to install, configure, and manage CUPS printer queues and classes.
Key design goals include *locale independence* and *test driven development*.

## Setup

### Setup Requirements

* Ruby 1.9.0 or later
* Puppet 3.0.0 or later
* CUPS with `ipptool` (included since CUPS 1.5)

### Beginning with CUPS

#### Minimal manifest

All resources in this module require the CUPS daemon to be installed and configured in a certain way.
To ensure these preconditions you should include the main `cups` class wherever you use this module:

```puppet
include '::cups'
```

See the [section](#class-cups) on the `cups` class for details.

#### Minimal printer manifest

Using a suitable model from the output of the command `lpinfo -m` on the node:

```puppet
include '::cups'

cups_queue { 'MinimalPrinter':
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd'
}
```

#### Minimal class manifest

When defining a printer class, it is *mandatory* to also define its member printers in the same catalog:

```puppet
include '::cups'

cups_queue { 'MinimalClass':
  ensure  => 'class',
  members => ['Office', 'Warehouse']
}

cups_queue { ['Office', 'Warehouse']:
  ensure => 'printer',
  model  => 'drv:///sample.drv/generic.ppd'
}
```

For your convenience, the `Cups_queue['MinimalClass']` will autorequire its member resources `Cups_queue['Office', 'Warehouse']`.

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference

### Classes

#### Public Classes

* [`cups`](#class-cups)

#### Private Classes

* `cups::default_queue`

### Types

* [`cups_queue`](#type-cups_queue)

### Facts

* `cups_classes`: An array of the names of all installed classes.

* `cups_classmembers`: A hash with the names of all classes (as keys) and their members (as array value).

* `cups_printers`: An array of the names of all installed print queues (*excluding* classes).

* `cups_queues`: An array of the names of all installed print queues (*including* classes).

#### Class: `cups`

Installs, configures, and manages the CUPS service.

##### Attributes (all optional)

* `default_queue`: The name of the default destination for all print jobs. Requires the catalog to contain a `cups_queue` resource with the same name.

#### Type: `cups_queue`

Installs and manages CUPS print queues.

##### Attributes

* `name`: *mandatory* - CUPS queue names are case insensitive and may contain any printable character except SPACE, TAB, "/", or "#".

* `ensure`: *mandatory* - Specifies whether this queue should be a `class`, a `printer` or `absent`.

* `accepting`: Boolean value specifying whether the queue should accept print jobs or reject them. Default is `true`.

* `description`: A short informative description of the queue.

* `enabled`: Boolean value specifying whether the queue should be running or stopped. Default is `true`.

* `location`: A short information where to find the hardcopies.

* `shared`: Boolean value specifying whether to share this queue on the network. Default is `false`.

##### Class-only attributes

* `members`: *mandatory* - A non-empty array with the names of CUPS queues. The class will be synced to contain only these members in the given order. If the catalog contains `cups_queue` resources for these queues, they will be required automatically.

##### Printers-only attributes

* `model`: *mandatory* - A supported printer model. Use `lpinfo -m` on the node to list all models available.

* `uri`: The device URI of the printer. Use `lpinfo -v` on the node to scan for printer URIs.

## Limitations

This is where you list OS compatibility, version compatibility, etc. If there
are Known Issues, you might want to include them under their own heading here.

## Development

Since your module is awesome, other users will want to play with it. Let them
know what the ground rules for contributing are.

## Release Notes/Contributors/Etc. **Optional**

If you aren't using changelog, put your release notes here (though you should
consider using changelog). You can also add any additional sections you feel
are necessary or important to include here. Please use the `## ` header.
