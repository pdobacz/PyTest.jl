# PyTest

[![Build Status](https://travis-ci.org/pdobacz/PyTest.jl.svg?branch=master)](https://travis-ci.org/pdobacz/PyTest.jl)

At the moment, *PyTest.jl* allows a very basic setting up of test resources using [pytest](http://doc.pytest.org/en/latest/index.html#)-inspired approach with fixtures.

## Instalation

To install, you need to clone the git repo manually into the appropriate package directory

## Example use

When in need of a particular test resources `needed_resource` and `needed_resource2` (which may depend on each other), you can separate the setup code for these resources as follows:

```julia

using PyTest
using TestedModule

@fixture needed_resource function()
  # returns some needed resource
end

@fixture needed_resource2 function(needed_resource)
  # needed_resource here will hold the above resource
  # fresh instance for every @pytest invocation
  # returns some other needed resource
end

@pytest function(needed_resource, needed_resource2)
  # test body using both resources
end
```

If a resource needs teardown to be done after tests are over, use the `produce` function instead of returning in the fixture function:

```julia
@fixture torndown()
  produce("some result")
  # here do the teardown
  # this will be called after a test using this completes
```
