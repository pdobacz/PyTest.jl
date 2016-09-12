reload("PyTest")
include("different_module.jl")

module tst

using PyTest
using Base.Test

include("base_fixtures.jl")


end
