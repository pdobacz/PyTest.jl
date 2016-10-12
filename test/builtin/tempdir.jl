# makes a good dir in default temp directory
let
  @pytest function(tempdir_fixture)
    @test isdir(tempdir_fixture)
    @test dirname(tempdir_fixture) == Base.tempdir()
  end
end

# deletes the tmpdir
let
  safe = Dict()
  @pytest function(tempdir_fixture)
    safe["tempdir_fixture"] = tempdir_fixture
  end
  @test !ispath(safe["tempdir_fixture"])
end
