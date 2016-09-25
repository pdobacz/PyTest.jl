runner_path = joinpath(Pkg.dir(), "PyTest/src/runner.jl")
julia_exe = Base.julia_cmd()
tests_count_indicator(passed, total) = "test set      |    $passed      $total"

cd(joinpath(Pkg.dir(), "PyTest/test/test_package")) do
  @test contains(readall(`$julia_exe $runner_path`),
                 tests_count_indicator(3,3))

  @test contains(readall(`$julia_exe $runner_path runtests.jl/one`),
                 tests_count_indicator(1,1))

  @test contains(readall(`$julia_exe $runner_path runtests.jl`),
                 tests_count_indicator(3,3))

  @test contains(readall(`$julia_exe $runner_path runtests.jl/one runtests.jl/two`),
                 tests_count_indicator(2,2))
end
