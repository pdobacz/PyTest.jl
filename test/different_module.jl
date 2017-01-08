# this is just a helper module to test cross-module fixtures
module different_module
  using PyTest

  export different_module_f, different_module_g,
         some_function

  @fixture function different_module_f() :dmf_result end
  @fixture function different_module_g(different_module_f)
    return [different_module_f, :dmg_result]
  end

  function some_function() :some_function_result end
end
