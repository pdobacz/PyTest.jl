type Request
  fixturename::Union{Void, Symbol}
  param::Any
end

function set_fixturename!(r::Request, name)
  r.fixturename = name
  nothing
end

function set_param!(r::Request, param)
  r.param = param
  nothing
end

Request() = Request(nothing, nothing)

@fixture request function()
  Request()
end
