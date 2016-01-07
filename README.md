# cups

[![Build Status](https://travis-ci.org/leoarnold/puppet-cups.svg)](https://travis-ci.org/leoarnold/puppet-cups)

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

## Setup

### Setup Requirements

* Ruby 1.9.0 or later
* Puppet 3.0.0 or later
* CUPS 1.5 or later

### Beginning with CUPS

#### Minimal manifest

To ensure that CUPS is installed and the service is running, you should always declare the `cups` class.

~~~puppet
class { '::cups': }
~~~

## Usage

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference

### Classes

#### Public Classes

* [`cups`](#class-cups)

#### Private Classes

### Types

### Facts

#### Class: `cups`

Installs, configures, and manages the CUPS service.

##### Parameters (all optional)

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
