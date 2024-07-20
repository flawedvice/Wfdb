module Headers

export HeaderRecord,
    HeaderSignal,
    HeaderSegment,
    OrdinaryHeader,
    MultiSegmentHeader,
    parseheader,
    readheader

include("Utils.jl")
using .Utils

"
Format: 
\"RECORD_NAME/SEGMENTS SIGNALS SAMPS_FREQ/COUNTER_FREQ(BASE_COUNTER) SAMPS_PER_SIGNAL BASE_TIME BASE_DATE\"
"
record_regex = r"
    [\" \t]* (?<record_name>[-\w]+)
        /?(?<segments>\d*)
    [ \t]+ (?<signals>\d+)
    [ \t]* (?<samps_freq>\d*\.?\d*)
        /*(?<counter_freq>-?\d*\.?\d*)
        \(?(?<base_counter>-?\d*\.?\d*)\)?
    [ \t]* (?<samps_per_signal>\d*)
    [ \t]* (?<base_time>\d{0,2}:?\d{0,2}:?\d{0,2}\.?\d{0,6})
    [ \t]* (?<base_date>\d{0,2}/?\d{0,2}/?\d{0,4})
    "x

"
Format: 
\"FILENAME FORMATxSAMPS_PER_FRAME:SKEW+BYTE_OFFSET ADC_GAIN(BASELINE)/UNITS ADC_RESOLUTION ADC_ZERO INIT_VALUE CHECKSUM BLOCK_SIZE DESCRIPTION\"
"
signal_regex = r"
    [ \t]* (?<filename>[-\w]+\.?\w*)
    [ \t]+ (?<format>\d+)
        x?(?<samps_per_frame>\d*)
        :?(?<skew>\d*)
        \+?(?<byte_offset>\d*)
    [ \t]* (?<adc_gain>-?\d*\.?\d*e?[\+-]?\d*)
        \(?(?<baseline>-?\d*)\)?
        /?(?<units>[\w\^\-\?%\/]*)
    [ \t]* (?<adc_resolution>\d*)
    [ \t]* (?<adc_zero>-?\d*)
    [ \t]* (?<init_value>-?\d*)
    [ \t]* (?<checksum>-?\d*)
    [ \t]* (?<block_size>\d*)
    [ \t]* (?<description>[\S]?[^\t\n\r\f\v]*)
    "x

"Format: 
\"NAME SAMPS_PER_SIGNAL\"
"
segment_regex = r"
    [ \t]* (?<name>[-\w]*~?)
    [ \t]+ (?<samps_per_signal>\d+)
    "x

struct HeaderRecord
    name::String
    segments::Int64
    signals::Int64
    sampling_frequency::Float64
    counter_frequency::Float64
    base_counter::Float64
    samples_per_signal::Int64
    base_time::String
    base_date::String
    function HeaderRecord(record::String)
        m = match(record_regex, record)
        name,
        segments,
        signals,
        samps_freq,
        counter_freq,
        base_counter,
        samps_per_signal,
        base_time,
        base_date = m
        sampling_frequency = validate(Float64, samps_freq, 250.0)
        new(
            validate(String, name, ""),
            validate(Int64, segments, convert(Int64, 1)),
            validate(Int64, signals, convert(Int64, 0)),
            sampling_frequency,
            validate(Float64, counter_freq, sampling_frequency),
            validate(Float64, base_counter, 0.0),
            validate(Int64, samps_per_signal, 0),
            validate(String, base_time, ""),
            validate(String, base_date, ""),
        )
    end
end # struct HeaderRecord

struct HeaderSignal
    filename::String
    format::Int64
    samples_per_frame::Int64
    skew::Float64
    byte_offset::Int64
    gain::Float64
    baseline::Int64
    units::String
    resolution::Int64
    zero::Int64
    initialvalue::Int64
    checksum::Int64
    size::Int64
    description::String
    function HeaderSignal(signal::String)
        m = match(signal_regex, signal)
        filename,
        format,
        samps_per_frame,
        skew,
        byte_offset,
        adc_gain,
        baseline,
        units,
        adc_resolution,
        adc_zero,
        init_value,
        checksum,
        block_size,
        description = m
        zero = validate(Int64, adc_zero, 0)
        new(
            validate(String, filename, ""),
            validate(Int64, format, 0),
            validate(Int64, samps_per_frame, 1),
            validate(Float64, skew, 0.0),
            validate(Int64, byte_offset, 0),
            validate(Float64, adc_gain, 200.0),
            validate(Int64, baseline, 0),
            validate(String, units, "mV"),
            validate(Int64, adc_resolution, 12),
            zero,
            validate(Int64, init_value, zero),
            validate(Int64, checksum, 0),
            validate(Int64, block_size, 0),
            validate(String, description, ""),
        )
    end
end # struct HeaderSignal

struct HeaderSegment
    name::String
    samples_per_signal::Int64
    function HeaderSegment(segment::String)
        m = match(segment_regex, segment)
        name, samps_per_signal = m
        new(validate(String, name, ""), validate(Int64, samps_per_signal, 0))
    end
end

struct OrdinaryHeader
    record::HeaderRecord
    signals::Vector{HeaderSignal}
    comments::Vector{String}
end # struct Header

struct MultiSegmentHeader
    record::HeaderRecord
    segments::Vector{HeaderSegment}
end

"Parses header file's content into an ordinary or multi-segment header."
function parseheader(lines::Vector{String})
    recordlines = []
    comments = []
    for line in lines
        if startswith(line, "#")
            append!(comments, [line])
        elseif isempty(line)
            continue
        else
            append!(recordlines, [line])
        end
    end

    record = HeaderRecord(recordlines[begin])
    if record.segments > 1
        segments = [HeaderSegment(seg_line) for seg_line in recordlines[2:end]]
        return MultiSegmentHeader(record, segments)
    else
        signals = [HeaderSignal(sign_line) for sign_line in recordlines[2:end]]
        return OrdinaryHeader(record, signals, comments)
    end
end

"Searches a header file and if exists, returns a WFDB OrdinaryHeader or MultiSegmentHeader object"
function readheader(headerpath::String)
    headerlines = readlines(headerpath)
    parseheader(headerlines)
end

end # module Headers