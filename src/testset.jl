import BaseTestNext: record, finish
using BaseTestNext: DefaultTestSet, AbstractTestSet, Result, Pass, Fail, Error
using BaseTestNext: get_testset_depth, get_testset
immutable PyTestSet <: BaseTestNext.AbstractTestSet
    default_ts::BaseTestNext.DefaultTestSet
    stream::Base.PipeEndpoint
    # constructor takes a description string and options keyword arguments
    PyTestSet(desc; stream=Base.PipeEndpoint()) = new(BaseTestNext.DefaultTestSet(desc), stream)
end

old = STDOUT

record(ts::PyTestSet, res) = record(ts.default_ts, res)
function finish(ts::PyTestSet)
  # captured = takebuf_string(ts.stream)
  captured = ascii(readavailable(ts.stream))
  redirect_stdout(old)
  finish(ts.default_ts)
  length(captured) >= 0 && println("Captured output:\n", captured)
end

macro testtt()
  return quote
    buffff = IOBuffer()
    rd, wr = redirect_stdout()
    try
      @testset PyTestSet $(esc(:stream))=rd "dupa" begin
        println("dupadupa")
        @test 1 == 1
      end
    finally
    end
  end
end

@testtt

# println(takebuf_string(buffff))
