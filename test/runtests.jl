using Test

include("../src/Headers.jl")

tests =
    [test for test in filter(file -> occursin(".test.", file), readdir("."))]

for test in tests
    include(test)
end