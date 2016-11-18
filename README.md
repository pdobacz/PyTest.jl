# PyTest

[![Build Status](https://travis-ci.org/pdobacz/PyTest.jl.svg?branch=master)](https://travis-ci.org/pdobacz/PyTest.jl)
[![Coverage Status](https://coveralls.io/repos/github/pdobacz/PyTest.jl/badge.svg?branch=master)](https://coveralls.io/github/pdobacz/PyTest.jl?branch=master)

At the moment, *PyTest.jl* allows for basic setting up of test resources using [pytest](http://doc.pytest.org/en/latest/index.html#)-inspired approach with fixtures.

## Instalation

To install, use the `Pkg.clone`:

```julia
Pkg.clone("git://github.com/pdobacz/PyTest.jl.git")
```

## Example fixture use

When in need of a particular test resources: `needed_resource` and `needed_resource2` (which may depend on each other), you can setup fresh instances of the resources (i.e. test fixtures) as follows:

```julia
using PyTest
using TestedModule

@fixture needed_resource function()
  # returns some needed_resource
end

@fixture needed_resource2 function(needed_resource)
  # needed_resource here will hold the former fixture!
  # returns some other needed_resource2
end

@pytest function(needed_resource, needed_resource2)
  # test body using both resources
  # (gets fresh instances of both resources for every @pytest invocation)
end
```

**NOTE**: For combining `@pytest` with `Base.Test.@testset` see [here](https://github.com/pdobacz/PyTest.jl#using-with-base-test-testset).

A more concrete example to shed more light:

```julia
@fixture matrix_size function()
  return 1200
end

@fixture random_numbers function(matrix_size)
  return randn(matrix_size)
end

@fixture random_square_matrix function(matrix_size)
  return randn(matrix_size, matrix_size)
end

@pytest function test_multiplication(random_square_matrix, random_numbers, matrix_size)
  result = random_square_matrix * random_numbers
  @test size(result) == (matrix_size, )
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

**NOTE** parametrization information is appended to the name of the test, if it uses parametrized fixtures

**NOTE** you may want to wrap all your test in a `@testset` invocation, so that the tests are summarized properly

**NOTE** for more about what _could potentially_ be achieved with `pytest`-style fixtures, see [`pytest` docs on Fixtures](http://doc.pytest.org/en/latest/fixture.html).

## Parametrized fixtures

Fixtures can be parametrized. For any `@pytest` invocation that depends on parametrized fixtures, every possible combination of fixture parameters will be tried.

In a parametrized fixture, the value of a parameter is fetched using a special `request` fixture:

```julia
@fixture integer_number params=[1, 2] function(request)
  return request.param
end

@fixture some_character params=['a', 'c'] function(request)
  return request.param
end

@pytest function test_numbers_and_chars(integer_number, some_character)
  println(integer_number, some_character)
end
```

This should print (among `Base.Test` summaries):
```
1a
2a
1c
2c
```

## Example builtin fixture: `tempdir_fixture`

At this stage there is a single builtin fixture `tempdir_fixture` which provides a fresh temporary directory, created and torndown specifically for the particular test.

```julia
remember = ""
@pytest function test_isdir(tempdir_fixture)
  remember = tempdir_fixture
  @test isdir(tempdir_fixture)
end
@test !(isdir(remember))
```

**NOTE** for more ideas on what builtin fixtures _could potentially_ be ofered look in [`pytest` docs here](http://doc.pytest.org/en/latest/builtin.html#builtin-fixtures-function-arguments)

## Using with Base Test @testset

To use *PyTest.jl* fixtures in tests using standard `Base.Test.@testset`, currently one needs to nest the invocations:

```julia
@testset [CustomTestSet] [option=val...] "description $w, $v" for w in ..., v in ...
  @pytest function test_name(...)
    ...
  end
end
```

See #1.

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
