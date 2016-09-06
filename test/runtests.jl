reload("PyTest")

# this is just a helper module to test cross-module fixtures
module different_module
  using PyTest

  export different_module_f, different_module_g,
         some_function

  @fixture different_module_f function() :dmf_result end
  @fixture different_module_g function(different_module_f)
    return [different_module_f, :dmg_result]
  end

  function some_function() :some_function_result end
end

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

  @pytest function(h)
    assert(h == [3, 3])
  end
end

# no-fixture tests, execution of body anyway
let
  called = false
  @pytest function() called = true end
  assert(called)
end

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

# undefined fixture
let
  @test_throws UndefVarError @pytest function(g) end
end

# different module for fixture test
using different_module
let
  @pytest function(different_module_f, different_module_g)
    assert(different_module_f == :dmf_result)
    assert(different_module_g == [:dmf_result, :dmg_result])
  end
end

# redefinition of fixture
let
  @fixture f function() :one end
  @fixture f function() :two end
  @pytest function(f) assert(f == :two) end
end

# use of :fixture_name in fixture body?
# not sure if relevant?
let
  @fixture f function() :f_result end
  @fixture g function(f) :f end
  @pytest function(f, g)
    assert(f == :f_result)
    assert(g == :f)
  end
end

# use of imported symbols in fixture/test body
using different_module
let
  @fixture f function() assert(some_function() == :some_function_result) end
  @pytest function(f) assert(some_function() == :some_function_result) end
end

end
