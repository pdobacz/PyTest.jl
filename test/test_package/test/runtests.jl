using PyTest
include("../../../src/import_basetestnext.jl")

@testset begin
  @testset begin @test 1==1 end
  @pytest function() 1 == 1 end
  @pytest function() 1 == 1 end
  @pytest function() 1 == 1 end
end
