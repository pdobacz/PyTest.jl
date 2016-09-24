using ArgParse
using PyTest

argparse_settings = ArgParseSettings()
@add_arg_table argparse_settings begin
    "testpaths"
        help = "Paths to tests which should be run"
        nargs = '*'
        arg_type = AbstractString
end

PyTest.add_parsed_args!(parse_args(argparse_settings))

println(joinpath(pwd(), "test/runtests.jl"))

include(joinpath(pwd(), "test/runtests.jl"))
