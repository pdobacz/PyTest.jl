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

`PyTest.jl` uses `Base.Test` (in its `v0.5` flavour -- `BaseTestNext`), so every `@pytest` is also a (basic) `@testset`. A description to `@testset` can be given as a name of the test function:

```julia
@pytest function test_one_equals_one()
  @test 1 == 1
end
```

**NOTE** the fully qualified name of this tests will be `path/to/testfile.jl/test_one_equals_one`, where the path is relative to directory containing `runtests.jl`.

## Invoking tests using `PyTest/runner.jl`

There is an experimental option to select tests to be run in style similar to `pytest`. To use:

```sh
# navigate to a package root directory (one containing the standard test/runtests.jl)
cd path/to/package
# assuming julia is in PATH
# this will run all tests as if test/runtests.jl was run
julia path/to/PyTest/runner.jl
# this will only pick a certain test or test file
julia path/to/PyTest/runner.jl runtests.jl/some_top_level_test_name
julia path/to/PyTest/runner.jl testsubdir/tests.jl
julia path/to/PyTest/runner.jl testsubdir/tests.jl/particular_test1 testsubdir/tests.jl/particular_test2
```
