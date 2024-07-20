module Records

export readrecord, readheader, readsignal

include("Signals.jl")
using .Signals: readsignal, readheader

function readrecord(headerpath::String)
    dir, filename = splitdir(headerpath)

    header = readheader(headerpath)
    signal = header.signals[begin]
    readsignal(signal, dir)
    return
end



end # module Records