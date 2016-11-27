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

immutable MethodSet
  s::Symbol
  old
end

immutable ItemSet
  s::Symbol
  key
  oldvalue
end

immutable Monkeypatcher
  methods_set::Array{MethodSet}
  items_set::Array{ItemSet}
  setmethod!::Function
  delmethod!::Function
  setitem!::Function
  delitem!::Function
end

function setmethod!(mod::Module, s::Symbol, newmethod)
end

function delmethod!(mod::Module, s::Symbol) nothing end

function setitem!(mod::Module, s::Symbol, key, newitem) nothing end
function delitem!(mod::Module, s::Symbol, key) nothing end

function Monkeypatcher()
  Monkeypatcher([], [], setmethod!, delmethod!, setitem!, delitem!)
end

@fixture monkeypatch function()
  produce(Monkeypatcher())
end
