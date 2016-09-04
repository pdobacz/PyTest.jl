module PyTest

export @fixture, @pytest

type Fixture
  s::Symbol
  f::Function
  fargs::Array{Symbol, 1}
end

function get_fixture_result(fixture::Fixture, results::Dict{Symbol, Any})
  if fixture.s in keys(results)
    return results[fixture.s]
  end
  farg_results = [get_fixture_result(eval(farg), results) for farg in fixture.fargs]
  new_result = fixture.f(farg_results...)
  results[fixture.s] = new_result
  new_result
end

macro fixture(s, fixture_function)
  fargs = [farg for farg in fixture_function.args[1].args[1:end]]
  fixture_symbol = esc(s)
  s_name = string(s)
  return quote
    $fixture_symbol = Fixture($s_name, $fixture_function, $fargs)
  end
end

macro pytest(test_function)
  fargs = [farg for farg in test_function.args[1].args[1:end]]
  escfargs = [esc(farg) for farg in fargs]
  get_fixture_results_expr = quote
    [get_fixture_result(eval(farg), results) for farg in $fargs]
  end
  println(dump(get_fixture_results_expr.args[2]))
  return quote
    results = Dict{Symbol, Any}()
    farg_results = $get_fixture_results_expr
    $test_function(farg_results...)
  end
end




counter = Dict("counter" => 0)

@fixture f function() counter["counter"] += 1 end
@fixture g function(f) "dupa"*string(f) end
@fixture h function(f, g) "dupa"*string(f)*g end

@pytest function(f, g, h)
  println("hello", f, g)
  println("bye", h)
end

@pytest function(f, g, h)
  println("fdffd", f, g)
  println("errewerw", h)
end

@pytest function()
  println("no args")
end


end # module
