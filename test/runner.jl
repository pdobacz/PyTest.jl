runner_path = "/home/piotr/.julia/v0.4/PyTest/src/runner.jl"
julia_exe = Base.julia_cmd()
tests_count_indicator(passed, total) = "test set      |    $passed      $total"

cd("/home/piotr/.julia/v0.4/PyTest/test/test_package") do
  @test contains(readall(`$julia_exe $runner_path`),
                 tests_count_indicator(3,3))
  output = readall(`$julia_exe $runner_path runtests.jl`)
  println("outpt $output")
  @test contains(readall(`$julia_exe $runner_path runtests.jl/one`),
                 tests_count_indicator(1,1))
  @test contains(output,
                 tests_count_indicator(3,3))
  @test contains(readall(`$julia_exe $runner_path runtests.jl/one runtests.jl/two`),
                 tests_count_indicator(2,2))
end
