# Example Hiera usage

Hiera is an External Node Classifier (ENC).
The idea behind this is to keep (node specific) data
and Puppet logic in separate places.

Therefore we will only tell Puppet which classes to include

```puppet
# manifests/site.pp
node 'gibbons.initech.com' {
  include cups
}

# [...]
```

and use Hiera to provide the actual data

```yaml
# hieradata/common.yaml
---
cups::web_interface: false
# Create `cups_queue` resources using Hiera
cups::resources:
  Warehouse:
    ensure: printer
    model: drv:///sample.drv/generic.ppd
    uri: warehouse.initech.com
```

This directory contains a fully functional usage example.
