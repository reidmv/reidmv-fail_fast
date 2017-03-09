# Fail Fast module

## Usage

```puppet
class profile::important {

  notify { 'important':
    message => 'if ANY resource in this class fails Puppet should abort',
  }

  file { '/this/path/is/invalid/FILE':
    ensure => present,
  }

  # Note that the fail-fast resource is placed at the BOTTOM of the class
  # definition. This is important! It is also important that the resource
  # specify NO dependencies. The resource does not yet implement auto-ordering
  # to ensure it is always evaluated last even if there are failures. Placing
  # it at the bottom of the class definition is an 80% solution that gives
  # decent assurance it will be evaluated at the correct time to fail-fast a
  # Puppet run if necessary.

  fail_fast { 'Profile::Important': }
}
```
