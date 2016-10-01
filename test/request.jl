# just check if request is available in fixtures equally as well and not in pytest
let
  @fixture f function(request)
    @test isa(request. PyTest.Request)
  end

  # FIXME @test_throws seems not to work for exceptions throw at compile time, how to fix?
  # @test_throws ArgumentError @pytest function(request) end
end

# test most basic fixturename here
let
  @fixture f function(request)
    @test request.fixturename == "f"
  end
  @pytest function(f) end
end

# request can be overriden
let
  @fixture request function() 5 end

  # FIXME: this throws for now, since @pytest just checks if it has no request fixture
  # @pytest function(request)
  #   @test request == 5
  # end
end
