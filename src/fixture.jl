import Iterators: product

"Helper type holding information about a fixture definition"
type Fixture
 s::Symbol
 f::Function
 fargs::Array{Symbol, 1}  # all dependency-fixtures' symbols
 fixtures_dict  # maps dependency-fixtures' symbols to their resp. Fixtures
 kwargs
end

"Fixture's params as an array of (symbol, param) pairs"
function parametrization_as_pairs(fixture::Fixture)
  [(fixture.s, param) for param in fixture.kwargs[:params]]
end

"Gets a matrix of parametrizations (cartesian product) for an iterable of fixtures"
function get_param_matrix(fixtures)
  consumed = Set{Symbol}()
  parametrized = Array{Fixture, 1}()
  sift_for_parametrized_fixtures!(fixtures, parametrized, consumed)
  product([parametrization_as_pairs(f) for f in parametrized]...)
end

# FIXME: get rid of recursions?
"Searches recursively an iterable of fixtures in search of parametrized ones"
function sift_for_parametrized_fixtures!(fixtures, parametrized::Array{Fixture, 1},
                                         consumed::Set{Symbol})
  for f in fixtures
    if :params in keys(f.kwargs) && !(f.s in consumed)
      push!(parametrized, f)
      push!(consumed, f.s)
    end
    sift_for_parametrized_fixtures!(values(f.fixtures_dict), parametrized, consumed)
  end
end
