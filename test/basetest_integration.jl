# named tests
let
  @pytest function test_name()
    println("dupa")
    @test 1 == 0
  end
end
