# named tests
let
  @pytest function test_name()
    @test 1 == 1
  end
end

# skip & broken
# FIXME: this requires stuff from Base.Test which is not in BaseTestNext
let
  result = true
  @pytest function skip_here()
    @test_skip result = false
  end
  @test result
end

let
  result = true
  @test_skip @pytest function skip_this()
    result = false
  end
end

let
  @pytest function broken_here()
    @test_broken false
  end
end

let
  result = true
  @test_broken @pytest function broken_this()
    @test false
    @test result = false
  end
  @test result == false
end
# end skip & broken
