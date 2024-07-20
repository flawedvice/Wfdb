using .Headers

@testset "Record reader works as expected" begin
    @testset "Ordinary records" begin
        datetime = joinpath("..", "sample-data", "datetime.hea")
        mit = joinpath("..", "sample-data", "mit_db_record_100.hea")
        wave = joinpath("..", "sample-data", "wave_4.hea")
        filepaths = [datetime, mit, wave]

        for filepath in filepaths
            @test_nowarn readheader(filepath)
        end
    end
    @testset "Multi-segment records" begin
        root = joinpath("..", "sample-data", "multi-segment")
        datadirs = readdir(root)

        for dir in datadirs
            currdir = joinpath(root, dir)
            files = readdir(currdir)
            for file in files
                if endswith(file, ".hea")
                    filepath = joinpath(currdir, file)
                    @test_nowarn readheader(filepath)
                end
            end
        end
    end
end
