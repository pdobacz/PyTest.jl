using ArgParse

argparse_settings = ArgParseSettings()
@add_arg_table argparse_settings begin
    "testpath"
        help = "Path to tests which should be run"
end

parsed_args = parse_args(argparse_settings)

include(joinpath(pwd(), "test/runtests.jl"))
