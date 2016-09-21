runner_path = "/home/piotr/.julia/v0.4/PyTest/src/runner.jl"

cd("/home/piotr/.julia/v0.4/PyTest/test/test_package") do
  println(pwd())
  output = readall(`$runner_path`)
  println("this is the output $output")
  @test contains(output, "test set      |    1      1")
end
