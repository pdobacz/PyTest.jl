"Internal! this should hold all PyTest specific args gathered from the invocation"
runner_args = Dict{AbstractString, Any}()

"Helper function that injects invocation args to all @pytest calls"
function set_parsed_args!(pa)
 global runner_args
 runner_args = pa
end
