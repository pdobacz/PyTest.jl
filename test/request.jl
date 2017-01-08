# just check if request is available in fixtures equally as well and not in pytest
let
  @fixture function f(request)
    @test isa(request. PyTest.Request)
  end
end

# test most basic fixturename here
let
  @fixture function f(request)
    @test request.fixturename == :f
  end
  @fixture function g(f) end
  @pytest function(f) end
  @pytest function(g) end
end

# request can be overriden
let
  @fixture function request() 5 end
  @pytest function(request)
    @test request == 5
  end
end
