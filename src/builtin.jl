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
  mod::Module
  s::Symbol
  old
end

immutable ItemSet
  mod::Module
  s::Symbol
  key
  oldvalue
end

immutable Monkeypatcher
  methods_set::Vector{MethodSet}
  items_set::Vector{ItemSet}
  setmethod!::Function
  delmethod!::Function
  setitem!::Function
  delitem!::Function
end

function setmethod!(methods_set::Vector{MethodSet}, mod::Module, name::Symbol, newmethod)
  push!(methods_set, MethodSet(mod, name, mod.eval(name)))
  mod.eval(:($name = $newmethod))
end

function delmethod!(mod::Module, s::Symbol) nothing end

function setitem!(mod::Module, s::Symbol, key, newitem) nothing end
function delitem!(mod::Module, s::Symbol, key) nothing end

function Monkeypatcher()
  methods_set = Vector{MethodSet}()
  items_set = Vector{ItemSet}()
  method_setter = function(mod::Module, name::Symbol, newmethod)
    setmethod!(methods_set, mod, name, newmethod)
  end
  Monkeypatcher(methods_set, items_set, method_setter, delmethod!, setitem!, delitem!)
end

@fixture monkeypatch function()
  monkeypatcher = Monkeypatcher()
  produce(monkeypatcher)
  for method in monkeypatcher.methods_set
    name = method.s
    saved = method.mod.eval(name)
    saved = method.old
  end
end
