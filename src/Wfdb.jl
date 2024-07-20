module Wfdb

include("Records.jl")
using .Records: readrecord

readrecord("sample-data/100.hea")
#header = readheader("sample-data/100.hea")
#signal = header.signals[begin]
#readsignal(signal, "sample-data")



end # module Wfdb