reload("PyTest")
include("different_module.jl")

module tst

using PyTest

using Base.Test

@testset "PyTest tests" begin
  include("base_fixtures.jl")
  include("exceptions.jl")
  include("request.jl")
  include("parametrized.jl")
  include("basetest_integration.jl")
  include("runner.jl")
  include("builtin/tempdir.jl")
end

end
