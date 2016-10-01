

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
macro fixture(args...)
  s = args[1]
  fixture_function = args[end]

  kwargs = Dict{Symbol, Any}()
  for arg in args[2:end-1]
    arg.head == :(=) || throw(ArgumentError("middle arguments to @fixture must have a=b form"))
    kwargs[arg.args[1]] = arg.args[2]
  end

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
    full_test_name = get_full_test_name(@__FILE__, $test_name)

    # only runs tests which name has been (partially) mentioned in test paths
    # or all tests if no test path specified
    testpaths = get(runner_args, "testpaths", [])
    if testpaths == [] || any((testpath) -> contains(full_test_name, testpath), testpaths)

      fixtures = $escfargs
      # empty collection of fixtures' results
      results = Dict{Symbol, Any}()
      # empty collection of fixtures' tasks (for pytest-style teardown)
      tasks = Dict{Symbol, Task}()

      # go through all fixtures used (recursively) and evaluate
      farg_results = [get_fixture_result(f, results, tasks) for f in fixtures]

      @testset "$full_test_name" begin
        $(esc(test_function))(farg_results...)
      end

      [teardown_fixture(f, tasks) for f in fixtures]
    end
  end
end

# helpers

"Based on filename of macro call and user-supplied name get a nice qualified test name"
function get_full_test_name(test_path, test_name)
  runtestdir = splitdir(test_path)
  test_file = runtestdir[2]
  relative_testdir = ""
  while runtestdir[1] != "/" && !isfile(joinpath(runtestdir[1], "runtests.jl"))
    runtestdir = splitdir(runtestdir[1])
    relative_testdir = joinpath(relative_testdir, runtestdir[2])
  end
  runtestdir[1] == "/" && error("unexpectedly found / when searching for tests root")
  relative_testfile = joinpath(relative_testdir, test_file)
  full_test_name = joinpath(relative_testfile, test_name)
end

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
function get_fixture_result(fixture::Fixture, results::Dict{Symbol, Any}, tasks::Dict{Symbol, Task};
                            caller_name="")
  if fixture.s in keys(results)
    return results[fixture.s]
  end
  farg_results = [get_fixture_result(fixture.fixtures_dict[farg], results, tasks,
                                     caller_name=string(fixture.s)) for farg in fixture.fargs]
  new_task = Task(() -> fixture.f(farg_results...))
  new_result = consume(new_task)

  if fixture.s == :request && isa(new_result, Request)
    set_fixturename!(new_result, caller_name)
  end

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
