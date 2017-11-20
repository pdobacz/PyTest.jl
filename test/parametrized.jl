# parametrized fixture called
let
  remember = []
  @fixture params=(0, 1) function f(request)
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
  @fixture params=(0, 1) function f(request)
    request.param
  end
  @fixture params=('a', 0.1) function g(request)
    request.param
  end
  h_counter = Dict("key" => 0)
  @fixture function h()
    h_counter["key"] = h_counter["key"] + 1
  end
  @pytest function(f, g, h)
    push!(remember, (f, g, h))
  end
  @test remember == [(0, 'a', 1), (1, 'a', 2), (0, 0.1, 3), (1, 0.1, 4)]
end

# dependency as parametrized and non-parametrized fixtures
let
  remember = []
  @fixture params=(0, 1) function f(request)
    request.param
  end
  g_counter = Dict("key" => 0)
  @fixture function g(request)
    g_counter["key"] = g_counter["key"] + 1
  end
  h_counter = Dict("key" => 0)
  @fixture function h(f, g)
    h_counter["key"] = h_counter["key"] + 1
    f, g, h_counter["key"]
  end
  @pytest function(h)
    push!(remember, h)
  end
  @test remember == [(0, 1, 1), (1, 2, 2)]
end

# dependent parametrized fixture
let
  remember = []
  f_counter = Dict("key" => 0)
  @fixture function f()
    f_counter["key"] = f_counter["key"] + 1
  end
  @fixture params=('a', 0.1, []) function g(f, request)
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
  @fixture params=([], "a") function f(request)
    request.param
  end
  g_counter = Dict("key" => 0)
  @fixture function g(f)
    g_counter["key"] = g_counter["key"] + 1
    f, g_counter["key"]
  end
  h_counter = Dict("key" => 0)
  @fixture function h(f)
    h_counter["key"] = h_counter["key"] + 1
    f, h_counter["key"]
  end
  @pytest function(g, h)
    push!(remember, (g,h))
  end
  @test remember == [(([], 1), ([], 1)); (("a", 2), ("a", 2))]
end

# variable as parameters
let
  remember = []
  param1 = 'a'
  @fixture params=(param1, ) function f(request)
    request.param
  end
  @pytest function(f) push!(remember, f) end
  @test remember == ['a']
end
