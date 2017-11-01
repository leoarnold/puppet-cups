# Hiera 5 usage example

Hiera is an External Node Classifier (ENC).
The idea behind this is to keep (node specific) data
and Puppet logic in separate places.

Therefore we will only tell Puppet which classes to include

```puppet
# manifests/site.pp
include cups
```

and use Hiera to provide the actual data

```yaml
# data/common.yaml
---
  # Configure Class['cups']
  cups::default_queue: Warehouse
  cups::web_interface: true
  # Create `cups_queue` resources using Hiera
  cups::resources:
    Warehouse:
      ensure: printer
      model: drv:///sample.drv/generic.ppd
      uri: socket://warehouse.initech.com
```

This directory contains a fully functional usage example.
