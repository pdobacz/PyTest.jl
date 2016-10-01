#= """
Produces a fresh temporary dir, which is deleted on teardown

Usage:

```
@pytest function(tempdir)
  cp(stuff, tempdir)
  # test stuff in the tempdir, don't worry about cleanup or clashes
end
```
""" =#
# FIXME this is not documentable, hmm...
@fixture tempdir function()
  the_directory = Base.mktempdir()
  produce(the_directory)  # next lines are fixture teardown
  rm(the_directory, recursive=true)
end

immutable Request
  fixturename::AbstractString
end

@fixture request function()
  Request("")
end
