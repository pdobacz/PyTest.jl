# smoke test
let
  @fixture f function() :f_result end
  @fixture g function(f) f end

  @pytest function(f)
    @test f == :f_result
  end
  @pytest function(g)
    @test g == :f_result
  end
end

# correct syntax, chaining of fixtures, basic usage flow
let
  @fixture f function() return [:f_result] end
  @fixture g function(f)
    [[:g_result]; f]
  end
  @fixture h (g, f) -> [[:h_result]; f; g]
  @fixture k (h, f) -> [[:k_result]; h; f]

  @pytest function(f, g, h, k)
    @test f == [:f_result]
    @test g == [:g_result; :f_result]
    @test h == [:h_result; :f_result; :g_result; :f_result]
    @test k == [:k_result; :h_result; :f_result; :g_result; :f_result; :f_result]
  end
end

# test-level (default) fixtures executed once per test
let
  counter = 0

  @fixture f function() counter += 1 end
  @fixture g function(f) f end
  @fixture h function(f, g) return [f; g] end

  @pytest function(f)
    @test f == 1
  end

  @pytest function(f, g, h)
    @test f == g == 2
    @test h == [2, 2]
  end

  @pytest function(h)
    @test h == [3, 3]
  end
end

# no-fixture tests, execution of body anyway
let
  called = false
  @pytest function() called = true end
  @test called
end

# correct scoping within and outside fixture/test bodies
let
  @fixture f function() :f_result end
  @fixture g function(f)
    @test f == :f_result
    f
  end
  @fixture h function(g)
    @test typeof(f) == PyTest.Fixture
    @test g == :f_result
    g
  end

  @test typeof(f) == typeof(g) == typeof(h) == PyTest.Fixture

  @pytest function(h)
    @test typeof(f) == PyTest.Fixture
    @test h == :f_result
  end
end

# undefined fixture
let
  @test_throws UndefVarError @pytest function(g) end
end

# fixture defined in different module
using different_module
let
  @pytest function(different_module_f, different_module_g)
    @test different_module_f == :dmf_result
    @test different_module_g == [:dmf_result, :dmg_result]
  end
end

# redefinition of fixture
let
  @fixture f function() :one end
  @fixture f function() :two end
  @pytest function(f) @test f == :two end
end

# use of :fixture_name in fixture body?
# not sure if relevant?
let
  @fixture f function() :f_result end
  @fixture g function(f) :f end
  @pytest function(f, g)
    @test f == :f_result
    @test g == :f
  end
end

# use of imported symbols in fixture/test body
using different_module
let
  @fixture f function() @test some_function() == :some_function_result end
  @pytest function(f) @test some_function() == :some_function_result end
end

# teardown gets called in right order
let
  active_objects = []
  @fixture f function()
    produce(push!(active_objects, :f_result))  # next lines are teardown
    pop!(active_objects)
  end
  @fixture g function(f) push!(active_objects, :g_result) end
  @fixture h function(f, g)
    produce(push!(active_objects, :h_result))  # ditto
    push!(active_objects, :h_down)
  end
  @pytest function(h)
    @test active_objects == [:f_result, :g_result, :h_result]
  end
  @test active_objects == [:f_result, :g_result, :h_down]
end

# tears down even if intermediate fixture is noop
let
  deleted = []
  @fixture f function()
    produce(nothing)
    push!(deleted, :f_result)
  end
  @fixture g function(f) end
  @pytest function(g) error end
  @test deleted == [:f_result]
end

# tears down also on exception in test
let
  deleted = []
  @fixture f function()
    produce(nothing)
    push!(deleted, :f_result)
  end
  @fixture g function(f)
    produce(nothing)
    push!(deleted, :g_result)
  end
  @pytest function(g) error end
  @test deleted == [:f_result, :g_result]
end

# tears down also on exception in fixture
let
  deleted = []
  @fixture f function()
    produce(nothing)
    push!(deleted, :f_result)
  end
  @fixture g function(f)
    produce(nothing)
    push!(deleted, :g_result)
  end
  @fixture h function(g) end
  @pytest function(h) error end
  @test deleted == [:f_result, :g_result]
end
