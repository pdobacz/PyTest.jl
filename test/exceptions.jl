# undefined fixture
let
  @test_throws UndefVarError @pytest function(g) end
end

# unnamed fixture
let
  @test_throws ArgumentError eval(macroexpand(:(@fixture function() end)))
end

# incorrect middle arguments to fixture
let
  @test_throws ArgumentError eval(macroexpand(:(@fixture wrooooong function f() end)))
end
