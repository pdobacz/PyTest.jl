using PyTest
using Base.Test

# FIXME: there needs to be this top-level @testset for this to make sense
@testset begin
  @pytest function one() @test 1 == 1 end
  @pytest function two() @test 1 == 1 end
  @pytest function three() @test 1 == 1 end
end
