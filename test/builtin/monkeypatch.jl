# tests inspired by github.com/burrowsa/Fixtures.jl
function firstline(filename)
    f = open(filename)
    try
        return chomp(readlines(f)[1])
    finally
        close(f)
    end
end

# test monkey patching functions and undoing
let
  fake_open(filename) = IOBuffer("Hello Julia\nGoodbye Julia")
  @fixture with_fake_open function(monkeypatch)
    monkeypatch.setmethod!(Base, :open, fake_open)
  end
  @pytest function(with_fake_open)
    @test firstline("some_file") == "Hello Julia"
  end
  @test open !== fake_open
end

# # test monkey deleting functions
# let
#   @fixture without_open function(monkeypatch)
#     monkeypatch.delmethod!(Base, :open)
#   end
#   @pytest function(without_open)
#     @test_throws MethodError firstline("some_file")
#   end
#   @test open !== nothing
# end
#
# # throwing on patching non-existent stuff
# let
#   @pytest function(monkeypatch)
#     @test_throws UndefVarError monkeypatch.setattr!(Base, :no_such_thing, fake_open)
#     @test_throws UndefVarError monkeypatch.delattr!(Base, :no_such_thing)
#   end
# end
#
# module Dictmodule
#   somedict = Dict('a' => 1, 'b' => 2)
# end
# # monkeypatching dicts
# let
#   @fixture patched_dict function(monkeypatch)
#     monkeypatch.setitem!(Dictmodule, :somedict, 'a', 3)
#     monkeypatch.delitem!(Dictmodule, :somedict, 'b')
#   end
#   @pytest function(patched_dict)
#     @test Dictmodule.somedict['a'] == 3
#     @test ! 'b' in keys(Dictmodule.somedict)
#   end
#   @test Dictmodule.somedict['a'] == 1
#   @test 'b' in keys(Dictmodule.somedict)
# end
#
# # throwing monkeypatching dicts
# let
#   @pytest function(monkeypatch)
#     @test_throws KeyError monkeypatch.delitem!(Dictmodule, :somedict, 'c')
#   end
# end
