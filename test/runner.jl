runner_path = "/home/piotr/.julia/v0.4/PyTest/src/runner.jl"
julia_exe = Base.julia_cmd()

cd("/home/piotr/.julia/v0.4/PyTest/test/test_package") do
  @test contains(readall(`$julia_exe $runner_path`), "test set      |    3      3")
  @test contains(readall(`$julia_exe $runner_path runtests.jl/one`), "test set      |    1      3")
  @test contains(readall(`$julia_exe $runner_path runtests.jl`), "test set      |    2      3")
end
