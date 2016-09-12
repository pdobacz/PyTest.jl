tempdir = PyTest.tempdir

# makes a good dir in default temp directory
let
  @pytest function(tempdir)
    @test isdir(tempdir)
    @test dirname(tempdir) == Base.tempdir()

    # FIXME: fixture does not delete, so cleanup
    rm(tempdir, recursive=true)
  end
end

# deletes the tmpdir
let
  safe = Dict()
  @pytest function(tempdir)
    safe["tempdir"] = tempdir

    # FIXME: fixture does not delete, so cleanup
    rm(tempdir, recursive=true)
  end
  @test !ispath(safe["tempdir"])
end
