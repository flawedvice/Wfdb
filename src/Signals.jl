module Signals

export readsignal

include("Headers.jl")
using .Headers: HeaderSignal, readheader

function readsignal(signalheader::HeaderSignal, signaldir::String)
    filepath = joinpath(signaldir, signalheader.filename)
    try
        io = open(filepath, "r")
        data = Array{UInt8}(undef, 100)
        read!(io, data)
        for row in data
            println(row)
        end
    catch e
        println(e)
    end
end

end # module Signals