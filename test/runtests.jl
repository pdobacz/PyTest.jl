reload("PyTest")
include("different_module.jl")

module tst

using PyTest

include("../src/import_basetestnext.jl")

@testset "PyTest tests" begin
  include("base_fixtures.jl")
  include("basetest_integration.jl")
  include("runner.jl")
  include("builtin/tempdir.jl")
end

end
