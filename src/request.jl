type Request
  fixturename::Union{Void, AbstractString}
  param::Any
end

function set_fixturename!(r::Request, name)
  r.fixturename = name
  nothing
end

Request() = Request(nothing, nothing)

@fixture request function()
  Request()
end
