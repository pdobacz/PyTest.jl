type Request
  fixturename::Union{Void, AbstractString}
end

function set_fixturename!(r::Request, name)
  r.fixturename = name
  nothing
end

Request() = Request(nothing)

@fixture request function()
  Request()
end
