# named tests
let
  @pytest function test_name()
    @test 1 == 1
  end
end

# nesting @pytest in @testset
let
  import Base.Test.DefaultTestSet
  @fixture params=(100, 200) function h(request) request.param end
  @fixture function f(h) h end
  @fixture function g(f) return (f, :g, ) end
  tests_performed = 0
  const number_v = 5
  @testset DefaultTestSet "testset description $v, $w" for w in [:a, :b], v in 1:number_v
    @pytest function pytest_description(g, h)
      @test g == (h, :g, )
      tests_performed += 1
    end
  end
  @test tests_performed == number_v * 2 * 2
end
