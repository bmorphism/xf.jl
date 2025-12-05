using XF
using Test

@testset "XF.jl" begin
    @testset "Splittable Determinism" begin
        # Same seed → same colors
        xf_seed!(42)
        c1 = next_color()
        c2 = next_color()
        
        xf_seed!(42)
        @test next_color() == c1
        @test next_color() == c2
    end
    
    @testset "Random Access" begin
        # color_at is reproducible
        @test color_at(1) == color_at(1)
        @test color_at(100) == color_at(100)
        @test color_at(1) != color_at(2)
    end
    
    @testset "Color Spaces" begin
        xf_seed!(42)
        srgb = next_color(SRGB())
        
        xf_seed!(42)
        p3 = next_color(DisplayP3())
        
        xf_seed!(42)
        rec2020 = next_color(Rec2020())
        
        # Different spaces produce different colors
        @test typeof(srgb) == typeof(p3) == typeof(rec2020)
    end
    
    @testset "Pride Flags" begin
        @test length(rainbow()) == 6
        @test length(transgender()) == 5
        @test length(bisexual()) == 3
        @test length(pride_flag(:progress)) == 11
    end
    
    @testset "Palettes" begin
        xf_seed!(42)
        pal = next_palette(6)
        @test length(pal) == 6
        
        # Palette at index is reproducible
        pal1 = palette_at(5, 6)
        pal2 = palette_at(5, 6)
        @test pal1 == pal2
    end
    
    @testset "Palette State" begin
        init_palette_state(n=12, seed=42)
        ps = palette_state()
        @test length(ps.colors) == 12
        @test ps.seed == 42
        
        # Selection
        palette_toggle(1)
        @test 1 in ps.selected
        palette_toggle(1)
        @test !(1 in ps.selected)
        
        # Navigation
        @test ps.cursor == 1
        palette_move(:right)
        @test ps.cursor == 2
    end
end
