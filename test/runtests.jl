reload("PyTest")
module tst

using PyTest
using Base.Test
using SHA

# correct syntax, chaining of fixtures, basic usage flow
let
  @fixture f function() return [:f_result] end
  @fixture g function(f)
    [[:g_result]; f]
  end
  @fixture h (g, f) -> [[:h_result]; f; g]
  @fixture k (h, f) -> [[:k_result]; h; f]

  @pytest function(f, g, h, k)
    assert(f == [:f_result])
    assert(g == [:g_result; :f_result])
    assert(h == [:h_result; :f_result; :g_result; :f_result])
    assert(k == [:k_result; :h_result; :f_result; :g_result; :f_result;
                 :f_result])
  end
end

# test-level (default) fixtures executed once per test
let
  counter = 0

  @fixture f function() counter += 1 end
  @fixture g function(f) f end
  @fixture h function(f, g) return [f; g] end

  @pytest function(f)
    assert(f == 1)
  end

  @pytest function(f, g, h)
    assert(f == g == 2)
    assert(h == [2, 2])
  end

  # TODO: this should not have f,g
  @pytest function(f, g, h)
    assert(h == [3, 3])
  end
end

# no-fixture tests, execution of body
#= TODO: FAILS
let
  counter = 0
  @pytest function()
    called += 1
  end
  assert(called == 1)
end
=#

# correct scoping within and outside fixture/test bodies
let
  @fixture f function() :f_result end
  @fixture g function(f)
    assert(f == :f_result)
    f
  end
  @fixture h function(g)
    assert(typeof(f) == PyTest.Fixture)
    assert(g == :f_result)
  end

  assert(typeof(f) == typeof(g) == typeof(h) == PyTest.Fixture)

  #= TODO: FAILS
  @pytest function(h)
    assert(typeof(f) == PyTest.Fixture)
    assert(h == :f_result)
  end
  =#
end

# undefined fixture in fixture
#= TODO: fails
let
  @test_throws UndefVarError @fixture f function(g) end
end
=#

# undefined fixture in pytest
let
  @test_throws UndefVarError @pytest function(g) end
end

# incorrect syntax fixture
#= TODO: FAILS, NO IDEA WHY, problem with test_throws
let
  @test_throws ArgumentError @fixture function() end f
end
=#

# incorrect syntax pytest
#= TODO as above
let
  @test_throws ArgumentError @pytest function f() end
end
=#

# different module for fixture test

# redefinition of fixture

# use of :fixture_name in fixture body?

# use of imported symbols in fixture/test body



@pytest function()
  println("no args")
end

end
