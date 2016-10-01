let
  remember = []
  @fixture f params=[0, 1] function(request)
    request.param
  end
  @pytest function(f)
    push!(remember, f)
  end
  @test remember == [0, 1]
end
