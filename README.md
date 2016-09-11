# PyTest

[![Build Status](https://travis-ci.org/pdobacz/PyTest.jl.svg?branch=master)](https://travis-ci.org/pdobacz/PyTest.jl)

At the moment, *PyTest.jl* allows a very basic setting up of test resources using [pytest](http://doc.pytest.org/en/latest/index.html#)-inspired approach with fixtures.

## Instalation

To install, you need to clone the git repo manually into the appropriate package directory

## Example use

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

