module PyTest

# see https://github.com/JuliaCI/BaseTestNext.jl
if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

include("exceptions.jl")
include("testset.jl")

export @fixture, @pytest,
       PyTestException,
       tempdir

"Helper type holding information about a fixture definition"
type Fixture
  s::Symbol
  f::Function
  fargs::Array{Symbol, 1}  # all dependency-fixtures' symbols
  fixtures_dict  # maps dependency-fixtures' symbols to their resp. Fixtures
end

"""
Defines a fixture, that's called on every call to `@pytest` and calls
its set of dependency-fixtures.

Usage:
```
@fixture fixture_name function(other_fixture1, other_fixture2)
  # other_fixture1 holds the result of dependency other_fixture1
  do_sth_with(other_fixture1)
  do_sth_with(other_fixture2)
  # ...
  return fixture_results
end
```
"""
macro fixture(s, fixture_function)
  typeof(s) == Symbol || throw(ArgumentError("s must be an indentifier"))
  fixture_function.head in [:function, :->] || throw(ArgumentError("fixture_function should be a function"))
  fixture_function.args[1].head == :call && throw(ArgumentError("fixture_function should be anonymous"))

  fargs, escfargs = get_fixtures_from_function(fixture_function)
  return quote
    fixtures = $escfargs

    # gather all dependency-fixtures from this fixture
    fixtures_dict = Dict{Symbol, Fixture}(zip($fargs, fixtures))

    # build the Fixture instance and assign to the given variable
    $(esc(s)) = Fixture($(string(s)), $(esc(fixture_function)), $fargs, fixtures_dict)
  end
end

"""
Defines a single test, that calls its depenency-fixtures

Usage:
```
@pytest function(fixture1, fixture2)
  # fixture1 holds result of call to fixture1 etc
  do_sth_with(fixture1)
  # ... rest of test
end
```
"""
macro pytest(test_function)
  test_function.head in [:function, :->] || throw(ArgumentError("test_function should be a function"))
  if (test_function.args[1].head == :call)
    test_name = string(test_function.args[1].args[1])
  else
    test_name = "anonymous"
  end

  fargs, escfargs = get_fixtures_from_function(test_function)
  return quote
    fixtures = $escfargs

    # empty collection of fixtures' results
    results = Dict{Symbol, Any}()

    # empty collection of fixtures' tasks (for pytest-style teardown)
    tasks = Dict{Symbol, Task}()

    # go through all fixtures used (recursively) and evaluate
    farg_results = [get_fixture_result(f, results, tasks) for f in fixtures]

    output_buf = IOBuffer()
    rd, wr = redirect_stdout()
    testset_type = PyTestSet

    # @testset $test_name begin
    @testset $test_name testset_type $(esc(:stream))=rd begin
      $(esc(test_function))(farg_results...)
    end

    [teardown_fixture(f, tasks) for f in fixtures]
  end
end

# helpers

"Convenience function to extract information from `@pytest` `@fixture` call"
function get_fixtures_from_function(f)
  fargs = [farg for farg in f.args[1].args[1:end]]
  if f.args[1].head == :call
    deleteat!(fargs, 1)
  end

  escfargs = Expr(:vect, [esc(farg) for farg in fargs]...)
  fargs, escfargs
end

"Convenience function to call a single fixture, after all dependencies are called"
function get_fixture_result(fixture::Fixture, results::Dict{Symbol, Any}, tasks::Dict{Symbol, Task})
  if fixture.s in keys(results)
    return results[fixture.s]
  end
  farg_results = [get_fixture_result(fixture.fixtures_dict[farg], results, tasks) for farg in fixture.fargs]
  new_task = Task(() -> fixture.f(farg_results...))
  new_result = consume(new_task)
  results[fixture.s] = new_result
  if(!istaskdone(new_task))
    tasks[fixture.s] = new_task
  end
  new_result
end

"Convenience function to call the teardown bits, after all dependencies got torn down"
function teardown_fixture(fixture::Fixture, tasks::Dict{Symbol, Task})
  if !(fixture.s in keys(tasks))
    return nothing
  end
  [teardown_fixture(fixture.fixtures_dict[farg], tasks) for farg in fixture.fargs]
  consume(tasks[fixture.s])
  assert(istaskdone(tasks[fixture.s]))
  delete!(tasks, fixture.s)
  nothing
end

include("builtin.jl")

end # module
