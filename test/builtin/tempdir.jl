tempdir = PyTest.tempdir

# makes a good dir in default temp directory
let
  @pytest function(tempdir)
    @test isdir(tempdir)
    @test dirname(tempdir) == Base.tempdir()
  end
end

# deletes the tmpdir
let
  safe = Dict()
  @pytest function(tempdir)
    safe["tempdir"] = tempdir
  end
  @test !ispath(safe["tempdir"])
end
