# Fail Fast module

## Purpose

Puppet is designed to implement and enforce a graph of sometimes related, sometimes unrelated configurations. When a resource in the graph experiences a failure of any kind, directly related downstream configuration will be skipped. Puppet will continue to enforce configuration in the graph that doesn't have a direct, ordered relationship to the failed resource. This module is intended to allow alteration of the latter behavior.

Sometimes it can be useful to short-circuit an entire Puppet run when a critical configuration failure occurs. For example, when the first Puppet run triggered by an automated build system fails to configure core software for reasons related to 3rd party systems outside of Puppet's control. While Puppet _could_ continue to configure the system, if the core software configuration has failed the work is moot. The automated build system will be deprovisioning the node as soon as it learns about the failure.

It is desireable to be able to designate a class or resource "critical", and fast-fail the entire run if a failure occurs on such a resource.

Using hard, ordered dependencies can be undesirable because outside of broad-strokes groupings, there is no dependency order. Stages may not be a good option due to performance concerns, and forces Puppet users to think about ordering when really they just want to think about what should happen if a class or resource fails.

This module is proof-of-concept and a work in progress. It provides a start on a mechanism to implement a fast-fail behavior for any resource failure that occurs inside a given class.

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

## Aspirations

For the class use case, it would be ideal if a function could be used at the top of the class to designate the desired behavior. For example,

```puppet
class profile::important {
  fail_fast::on_class_failure()

  notify { "important things": }
}
```

This idealized user experience is not implemented.
