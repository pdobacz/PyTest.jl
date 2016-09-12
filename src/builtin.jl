@fixture tempdir function()
  the_directory = Base.mktempdir()
  produce(the_directory)
  rm(the_directory, recursive=true)
end
