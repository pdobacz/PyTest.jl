module PyTest

include("exceptions.jl")

export @fixture, @pytest,
       PyTestException

type Fixture
  s::Symbol
  f::Function
  fargs::Array{Symbol, 1}
  fixtures_dict
end

macro fixture(s, fixture_function)
  typeof(s) == Symbol || throw(ArgumentError("s must be an indentifier"))
  fixture_function.head in [:function, :->] || throw(ArgumentError("fixture_function should be a function"))
  fixture_function.args[1].head == :call && throw(ArgumentError("fixture_function should be anonymous"))

  fargs = [farg for farg in fixture_function.args[1].args[1:end]]
  fixture_symbol = esc(s)
  s_name = string(s)
  escfargs = [esc(farg) for farg in fargs]
  escfargs2 = Expr(:vect, escfargs...)
  return quote
    fixtures = $escfargs2
    fixtures_dict = Dict{Symbol, Fixture}()
    for (s, f) in zip($fargs, fixtures)
      fixtures_dict[s] = f
    end
    $fixture_symbol = Fixture($s_name, $(esc(fixture_function)), $fargs, fixtures_dict)
  end
end

function get_fixture_result(fixture::Fixture, results::Dict{Symbol, Any})
  if fixture.s in keys(results)
    return results[fixture.s]
  end
  farg_results = [get_fixture_result(fixture.fixtures_dict[farg], results) for farg in fixture.fargs]
  new_result = fixture.f(farg_results...)
  results[fixture.s] = new_result
  new_result
end

macro pytest(test_function)
  test_function.head in [:function, :->] || throw(ArgumentError("test_function should be a function"))
  test_function.args[1].head == :call && throw(ArgumentError("test_function should be anonymous"))

  fargs = [farg for farg in test_function.args[1].args[1:end]]
  escfargs = [esc(farg) for farg in fargs]
  escfargs2 = Expr(:vect, escfargs...)
  return quote
    fixtures = $escfargs2

    results = Dict{Symbol, Any}()
    farg_results = [get_fixture_result(f, results) for f in fixtures]
    $(esc(test_function))(farg_results...)
  end
end


end # module
