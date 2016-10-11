#= """
Produces a fresh temporary dir, which is deleted on teardown

Usage:

```
@pytest function(tempdir_fixture)
  cp(stuff, tempdir_fixture)
  # test stuff in the tempdir_fixture, don't worry about cleanup or clashes
end
```
""" =#
# FIXME this is not documentable, hmm...
@fixture tempdir_fixture function()
  the_directory = Base.mktempdir()
  produce(the_directory)  # next lines are fixture teardown
  rm(the_directory, recursive=true)
end
