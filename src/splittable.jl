# Deterministic splittable random color generation
# Inspired by Pigeons.jl's Strong Parallelism Invariance (SPI)
#
# "Reason, like information, wants to be free" — XF Manifesto

using SplittableRandoms: SplittableRandom, split

export XFRNG, xf_seed!, xf_rng, xf_split, next_color, next_colors, next_palette

"""
    XFRNG

A splittable random number generator for deterministic color generation.
Each color operation splits the RNG to ensure reproducibility regardless
of execution order (Strong Parallelism Invariance).

The RNG state tracks an invocation counter to generate a unique deterministic
stream for each call, enabling reproducible sequences even across sessions.
"""
mutable struct XFRNG
    root::SplittableRandom
    current::SplittableRandom
    invocation::UInt64
    seed::UInt64
end

# Global RNG instance - default seed encodes "xenofem" 
const XF_SEED = UInt64(0x78656e6f66656d21)  # "xenofem!" as bytes
const GLOBAL_XF_RNG = Ref{XFRNG}()

"""
    XFRNG(seed::Integer=XF_SEED)

Create a new XFRNG with the given seed.
"""
function XFRNG(seed::Integer=XF_SEED)
    root = SplittableRandom(UInt64(seed))
    current = split(root)
    XFRNG(root, current, UInt64(0), UInt64(seed))
end

"""
    xf_seed!(seed::Integer)

Reset the global XF RNG with a new seed.
All subsequent color generations will be deterministic from this seed.
"""
function xf_seed!(seed::Integer)
    GLOBAL_XF_RNG[] = XFRNG(seed)
    return seed
end

"""
    xf_rng()

Get the global XF RNG, initializing if needed.
"""
function xf_rng()
    if !isassigned(GLOBAL_XF_RNG)
        GLOBAL_XF_RNG[] = XFRNG()
    end
    return GLOBAL_XF_RNG[]
end

"""
    xf_split(rng::XFRNG=xf_rng())

Split the RNG for a new independent stream.
Increments invocation counter for tracking.
"""
function xf_split(rng::XFRNG=xf_rng())
    rng.invocation += 1
    rng.current = split(rng.current)
    return rng.current
end

"""
    xf_split(n::Integer, rng::XFRNG=xf_rng())

Get n independent RNG splits as a vector.
"""
function xf_split(n::Integer, rng::XFRNG=xf_rng())
    return [xf_split(rng) for _ in 1:n]
end

# ═══════════════════════════════════════════════════════════════════════════
# Deterministic color generation using splittable RNG
# ═══════════════════════════════════════════════════════════════════════════

"""
    next_color(cs::ColorSpace=SRGB(); rng::XFRNG=xf_rng())

Generate the next deterministic random color.
Each call splits the RNG for reproducibility.
"""
function next_color(cs::ColorSpace=SRGB(); rng::XFRNG=xf_rng())
    splitted = xf_split(rng)
    return random_color(cs; rng=splitted)
end

"""
    next_colors(n::Int, cs::ColorSpace=SRGB(); rng::XFRNG=xf_rng())

Generate n deterministic random colors.
"""
function next_colors(n::Int, cs::ColorSpace=SRGB(); rng::XFRNG=xf_rng())
    splitted = xf_split(rng)
    return random_colors(n, cs; rng=splitted)
end

"""
    next_palette(n::Int, cs::ColorSpace=SRGB(); 
                 min_distance::Float64=30.0, rng::XFRNG=xf_rng())

Generate n deterministic visually distinct colors.
"""
function next_palette(n::Int, cs::ColorSpace=SRGB();
                      min_distance::Float64=30.0, rng::XFRNG=xf_rng())
    splitted = xf_split(rng)
    return random_palette(n, cs; min_distance=min_distance, rng=splitted)
end

# ═══════════════════════════════════════════════════════════════════════════
# Invocation-indexed color access (like Pigeons explorer indexing)
# ═══════════════════════════════════════════════════════════════════════════

"""
    color_at(index::Integer, cs::ColorSpace=SRGB(); seed::Integer=XF_SEED)

Get the color at a specific invocation index.
This allows random access to the deterministic color sequence.

# Example
```julia
# These will always return the same colors for the same indices
c1 = color_at(1)
c42 = color_at(42)
c1_again = color_at(1)  # Same as c1
```
"""
function color_at(index::Integer, cs::ColorSpace=SRGB(); seed::Integer=XF_SEED)
    # Create a fresh RNG from seed
    root = SplittableRandom(UInt64(seed))
    current = root
    
    # Split to the desired index
    for _ in 1:index
        current = split(current)
    end
    
    # Generate color at this index
    return random_color(cs; rng=current)
end

"""
    colors_at(indices::AbstractVector{<:Integer}, cs::ColorSpace=SRGB(); 
              seed::Integer=XF_SEED)

Get colors at specific invocation indices.
"""
function colors_at(indices::AbstractVector{<:Integer}, cs::ColorSpace=SRGB();
                   seed::Integer=XF_SEED)
    return [color_at(i, cs; seed=seed) for i in indices]
end

"""
    palette_at(index::Integer, n::Int, cs::ColorSpace=SRGB();
               min_distance::Float64=30.0, seed::Integer=XF_SEED)

Get a palette at a specific invocation index.
"""
function palette_at(index::Integer, n::Int, cs::ColorSpace=SRGB();
                    min_distance::Float64=30.0, seed::Integer=XF_SEED)
    root = SplittableRandom(UInt64(seed))
    current = root
    for _ in 1:index
        current = split(current)
    end
    return random_palette(n, cs; min_distance=min_distance, rng=current)
end
