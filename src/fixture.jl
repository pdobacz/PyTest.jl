"Helper type holding information about a fixture definition"
type Fixture
 s::Symbol
 f::Function
 fargs::Array{Symbol, 1}  # all dependency-fixtures' symbols
 fixtures_dict  # maps dependency-fixtures' symbols to their resp. Fixtures
 kwargs
end
