# parametrized fixture called
let
  remember = []
  @fixture f params=(0, 1) function(request)
    request.param
  end
  @pytest function(f)
    push!(remember, f)
  end
  @test remember == [0, 1]
end

# parametrized and non-parametrized fixture mixed
let
  remember = []
  @fixture f params=(0, 1) function(request)
    request.param
  end
  @fixture g params=('a', 0.1) function(request)
    request.param
  end
  h_counter = 0
  @fixture h function()
    h_counter += 1
  end
  @pytest function(f, g, h)
    push!(remember, (f, g, h))
  end
  @test remember == [(0, 'a', 1), (1, 'a', 2), (0, 0.1, 3), (1, 0.1, 4)]
end

# dependency as parametrized and non-parametrized fixtures
let
  remember = []
  @fixture f params=(0, 1) function(request)
    request.param
  end
  g_counter = 0
  @fixture g function(request) g_counter += 1 end
  h_counter = 0
  @fixture h function(f, g) return (f, g, h_counter += 1) end
  @pytest function(h)
    push!(remember, h)
  end
  @test remember == [(0, 1, 1), (1, 2, 2)]
end

# dependent parametrized fixture
let
  remember = []
  f_counter = 0
  @fixture f function() f_counter += 1 end
  @fixture g params=('a', 0.1, []) function(f, request)
    (f, request.param)
  end
  @pytest function(g)
    push!(remember, g)
  end
  @test remember == [(1, 'a'); (2, 0.1); (3, [])]
end

# diamond shaped dependency
let
  remember = []
  @fixture f params=([], "a") function(request)
    request.param
  end
  g_counter = 0
  @fixture g function(f) return (f, g_counter += 1) end
  h_counter = 0
  @fixture h function(f) return (f, h_counter += 1) end
  @pytest function(g, h)
    push!(remember, (g,h))
  end
  @test remember == [(([], 1), ([], 1)); (("a", 2), ("a", 2))]
end

# variable as parameters
let
  remember = []
  param1 = 'a'
  @fixture f params=(param1, ) function(request)
    request.param
  end
  @pytest function(f) push!(remember, f) end
  @test remember == ['a']
end
