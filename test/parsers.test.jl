using .Headers

@testset "Header record parsing" begin

    @testset "sampling_frequencyimple records" begin
        records = [HeaderRecord("100 2 360 650000")]
        expectations = [
            Dict(
                :name => "100",
                :signals => 2,
                :sampling_frequency => 360.0f0,
                :samples_per_signal => 650000,
            ),
        ]
        for (record, expected) in zip(records, expectations)
            for field in collect(keys(expected))
                @test getfield(record, field) == expected[field]
            end

        end
    end

    @testset "Multi-segment records" begin
        records = [HeaderRecord("multi/3 2 360 45000")]
        expectations = [
            Dict(
                :name => "multi",
                :segments => 3,
                :signals => 2,
                :sampling_frequency => 360.0f0,
                :samples_per_signal => 45000,
            ),
        ]
        for (record, expected) in zip(records, expectations)
            for field in collect(keys(expected))
                @test getfield(record, field) == expected[field]
            end

        end
    end

    @testset "Dated records" begin
        records = [HeaderRecord("datetime 3 2048 10240 13:05:00 25/4/1989")]
        expectations = [
            Dict(
                :name => "datetime",
                :signals => 3,
                :sampling_frequency => 2048.0f0,
                :samples_per_signal => 10240,
                :base_time => "13:05:00",
                :base_date => "25/4/1989",
            ),
        ]
        for (record, expected) in zip(records, expectations)
            for field in collect(keys(expected))
                @test getfield(record, field) == expected[field]
            end
        end
    end
end

@testset "Header signal parsing" begin
    signals = [
        HeaderSignal("wave_4.dat 16x1000 1(1)/uV 15 0 5393 -12624 0 ECG"),
        HeaderSignal("s0010_re.dat 16 2000 16 0 -489 -8337 0 i"),
        HeaderSignal("drive02.dat 16x2 1000 16 0 1802 13501 0 foot GSR"),
        HeaderSignal("3269321_0002.dat 80 255(-128)/NU 8 0 4 5246 0 PLETH"),
        HeaderSignal("test01_00s.dat 16:3 100/mV 16 0 -8 941 0 ECG_2"),
    ]
    expectations = [
        Dict(
            :filename => "wave_4.dat",
            :format => 16,
            :samples_per_frame => 1000,
            :skew => 0.0,
            :byte_offset => 0,
            :gain => 1,
            :baseline => 1,
            :units => "uV",
            :resolution => 15,
            :zero => 0,
            :initialvalue => 5393,
            :checksum => -12624,
            :size => 0,
            :description => "ECG",
        ),
        Dict(
            :filename => "s0010_re.dat",
            :format => 16,
            :samples_per_frame => 1,
            :skew => 0.0,
            :byte_offset => 0,
            :gain => 2000.0,
            :baseline => 0,
            :units => "mV",
            :resolution => 16,
            :zero => 0,
            :initialvalue => -489,
            :checksum => -8337,
            :size => 0,
            :description => "i",
        ),
        Dict(
            :filename => "drive02.dat",
            :format => 16,
            :samples_per_frame => 2,
            :skew => 0.0,
            :byte_offset => 0,
            :gain => 1000.0,
            :baseline => 0,
            :units => "mV",
            :resolution => 16,
            :zero => 0,
            :initialvalue => 1802,
            :checksum => 13501,
            :size => 0,
            :description => "foot GSR",
        ),
        Dict(
            :filename => "3269321_0002.dat",
            :format => 80,
            :samples_per_frame => 1,
            :skew => 0.0,
            :byte_offset => 0,
            :gain => 255.0,
            :baseline => -128,
            :units => "NU",
            :resolution => 8,
            :zero => 0,
            :initialvalue => 4,
            :checksum => 5246,
            :size => 0,
            :description => "PLETH",
        ),
        Dict(
            :filename => "test01_00s.dat",
            :format => 16,
            :samples_per_frame => 1,
            :skew => 3.0,
            :byte_offset => 0,
            :gain => 100.0,
            :baseline => 0,
            :units => "mV",
            :resolution => 16,
            :zero => 0,
            :initialvalue => -8,
            :checksum => 941,
            :size => 0,
            :description => "ECG_2",
        ),
    ]

    for (signal, expected) in zip(signals, expectations)
        for field in collect(keys(expected))
            @test getfield(signal, field) == expected[field]
        end
    end
end

@testset "Header segment parsing" begin
    segments = [
        HeaderSegment("041s01 1000"),
        HeaderSegment("v102s_1 75000"),
        HeaderSegment("3269321_layout 0"),
        HeaderSegment("~ 3750"),
    ]
    expectations = [
        Dict(:name => "041s01", :samples_per_signal => 1000),
        Dict(:name => "v102s_1", :samples_per_signal => 75000),
        Dict(:name => "3269321_layout", :samples_per_signal => 0),
        Dict(:name => "~", :samples_per_signal => 3750),
    ]
    for (segment, expected) in zip(segments, expectations)
        for field in collect(keys(expected))
            @test getfield(segment, field) == expected[field]
        end
    end
end