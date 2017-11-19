# FIXME: don't know how to get rid of the necessity to do this using here
using ResumableFunctions

# smoke test
let
  @fixture function f() :f_result end
  @fixture function g(f) f end

  @pytest function(f)
    @test f == :f_result
  end
  @pytest function(g)
    @test g == :f_result
  end
end

# correct syntax, chaining of fixtures, basic usage flow
let
  @fixture function f() return [:f_result] end
  @fixture function g(f)
    [[:g_result]; f]
  end
  @fixture function h(g, f) return [[:h_result]; f; g] end
  @fixture function k(h, f) return [[:k_result]; h; f] end

  @pytest function(f, g, h, k)
    @test f == [:f_result]
    @test g == [:g_result; :f_result]
    @test h == [:h_result; :f_result; :g_result; :f_result]
    @test k == [:k_result; :h_result; :f_result; :g_result; :f_result; :f_result]
  end
end

# test-level (default) fixtures executed once per test
# let
#   counter = 0
#
#   @fixture function f() counter += 1 end
#   @fixture function g(f) f end
#   @fixture function h(f, g) return [f; g] end
#
#   @pytest function(f)
#     @test f == 1
#   end
#
#   @pytest function(f, g, h)
#     @test f == g == 2
#     @test h == [2, 2]
#   end
#
#   @pytest function(h)
#     @test h == [3, 3]
#   end
# end

# no-fixture tests, execution of body anyway
let
  called = false
  @pytest function() called = true end
  @test called
end

# correct scoping within and outside fixture/test bodies
let
  @fixture function f() :f_result end
  @fixture function g(f)
    @test f == :f_result
    f
  end
  @fixture function h(g)
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
  @fixture function f() :one end
  @fixture function f() :two end
  @pytest function(f) @test f == :two end
end

# use of :fixture_name in fixture body?
# not sure if relevant?
let
  @fixture function f() :f_result end
  @fixture function g(f) :f end
  @pytest function(f, g)
    @test f == :f_result
    @test g == :f
  end
end

# use of imported symbols in fixture/test body
using different_module
let
  @fixture function f() @test some_function() == :some_function_result end
  @pytest function(f) @test some_function() == :some_function_result end
end

# teardown gets called in right order
let
  active_objects = []
  @fixture function f()
    @yield push!(active_objects, :f_result)  # next lines are teardown
    pop!(active_objects)
  end
  @fixture function g(f) push!(active_objects, :g_result) end
  @fixture function h(f, g)
    @yield push!(active_objects, :h_result)  # ditto
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
  @fixture function f()
    @yield nothing
    push!(deleted, :f_result)
  end
  @fixture function g(f) end
  @pytest function(g) error end
  @test deleted == [:f_result]
end

# tears down also on exception in test
let
  deleted = []
  @fixture function f()
    @yield nothing
    push!(deleted, :f_result)
  end
  @fixture function g(f)
    @yield nothing
    push!(deleted, :g_result)
  end
  @pytest function(g) error end
  @test deleted == [:f_result, :g_result]
end

# tears down also on exception in fixture
let
  deleted = []
  @fixture function f()
    @yield nothing
    push!(deleted, :f_result)
  end
  @fixture function g(f)
    @yield nothing
    push!(deleted, :g_result)
  end
  @fixture function h(g) end
  @pytest function(h) error end
  @test deleted == [:f_result, :g_result]
end
