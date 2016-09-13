reload("PyTest")
include("different_module.jl")

module tst

using PyTest

# see https://github.com/JuliaCI/BaseTestNext.jl
if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end

include("base_fixtures.jl")
include("builtin/tempdir.jl")

end
