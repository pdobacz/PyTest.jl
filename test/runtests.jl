reload("PyTest")
module tst

using PyTest
using Base.Test


counter = Dict("counter" => 0)

@fixture f function() counter["counter"] end
@fixture g function(f) "dupa"*string(f) end
@fixture h function(f, g) "dupa"*string(f)*g end

@pytest function(f, g, h)
  println("hello", f, g)
  println("bye", h)
end

@pytest function(f, g, h)
  println("fdffd", f, g)
  println("errewerw", h)
end

@pytest function()
  println("no args")
end

end
