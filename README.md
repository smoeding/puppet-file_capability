# file_capability

[![Build Status](https://travis-ci.org/smoeding/puppet-file_capability.svg?branch=master)](https://travis-ci.org/smoeding/puppet-file_capability)
[![Puppet Forge](http://img.shields.io/puppetforge/v/stm/file_capability.svg)](https://forge.puppetlabs.com/stm/file_capability)
[![License](https://img.shields.io/github/license/smoeding/puppet-file_capability.svg)](https://raw.githubusercontent.com/smoeding/puppet-file_capability/master/LICENSE)

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with file_capability](#setup)
    * [What file_capability affects](#what-file_capability-affects)
    * [Setup requirements](#setup-requirements)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage file capabilities on Linux.

## Module Description

Linux capabilities provide a more fine-grained privilege model than the traditional privileged user (`root`) vs. non-privileged user model. File capabilities associate capabilities with an executable and grant additional capabilities to the process calling the executable (similar to what a setuid binary does in the traditional model).

This module provides the `file_capability` type to set or reset file capabilities for a file. See the [`capabilities(7)`](http://man7.org/linux/man-pages/man7/capabilities.7.html) man page for details about the available capabilities in your operating system.

## Setup

### What file_capability affects

* Sets or resets file capabilities for a given file using the `setcap` and `getcap` binaries provided by the operating system.

### Setup requirements

* No additional Puppet modules are required for this type.

## Usage

### Initialize the class to install the required package

``` Puppet
include file_capability
```

On Debian based operating systems this will install the `libcap2-bin` package to ensure the required binaries are available. For RedHat based systems the package `libcap` will be installed instead.

### Set a single capability

Set the capability used by `ping` to be able to open a raw socket without being setuid:

``` Puppet
file_capability { '/bin/ping':
  ensure     => present,
  capability => 'cap_net_raw=ep',
}
```

### Set multiple capabilities

This set of capabilities is used by Wireshark to be available to non-root users:

``` Puppet
file_capability { '/usr/bin/dumpcap':
  capability => [ 'cap_net_admin=eip', 'cap_net_raw=eip', ],
}
```

Both capabilities use the same flags, so this can be abbreviated:

``` Puppet
file_capability { '/usr/bin/dumpcap':
  capability => 'cap_net_admin,cap_net_raw=eip',
}
```

### Clear all capabilities

Remove all file capabilities:

``` Puppet
file_capability { '/path/to/executable':
  ensure => absent,
}
```

### Use hiera to create resources

The main class uses the `file_capabilities` hash parameter to create `file_capability` resources. So the following hiera item will create the same resource that is shown in the first example:

``` yaml
file_capability::file_capabilities:
  '/bin/ping':
    ensure:     present
    capability: 'cap_net_raw=ep'
```

## Reference

See [REFERENCE.md](https://github.com/smoeding/puppet-file_capability/blob/master/REFERENCE.md)

## Limitations

The type uses a regular expression to validate the `capability` parameter. Unfortunately some illegal specifications are not caught by this check.

Capabilities are only available on more recent operating system releases like RedHat 7 and Debian 8. In addition the file system must support extended attributes to store the capabilities for the file.

The module is currently developed and tested on:
* Debian 9 (Stretch)

## Development

Feel free to send pull requests for new features.
