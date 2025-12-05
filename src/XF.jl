# XF.jl — Xenofeminist Color Synthesis
#
# Wide-gamut color sampling with splittable determinism
# "If nature is unjust, change nature!" — Laboria Cuboniks
#
# Implements Strong Parallelism Invariance (SPI) via SplittableRandoms.jl
# for reproducible, fork-safe color generation across any execution order.

module XF

# Re-export LispSyntax for S-expression DSL
using LispSyntax
export sx, desx, codegen, @lisp_str, assign_reader_dispatch, include_lisp

# Color dependencies
using Colors
using ColorTypes
using Random
using SplittableRandoms

# ═══════════════════════════════════════════════════════════════════════════
# Core color space support (sRGB, Display P3, Rec.2020)
# ═══════════════════════════════════════════════════════════════════════════

include("colorspaces.jl")

# ═══════════════════════════════════════════════════════════════════════════
# Splittable RNG for deterministic color generation
# ═══════════════════════════════════════════════════════════════════════════

include("splittable.jl")
export color_at, colors_at, palette_at, XF_SEED

# ═══════════════════════════════════════════════════════════════════════════
# Interactive palette selection REPL
# ═══════════════════════════════════════════════════════════════════════════

include("repl.jl")
export init_palette_state, PaletteState, CURRENT_COLORSPACE, current_colorspace

# ═══════════════════════════════════════════════════════════════════════════
# Comrade.jl-style sky model DSL
# ═══════════════════════════════════════════════════════════════════════════

include("comrade.jl")
export comrade_show, comrade_mring, comrade_disk, comrade_crescent

# ═══════════════════════════════════════════════════════════════════════════
# Lisp bindings for color operations (kebab-case → snake_case)
# ═══════════════════════════════════════════════════════════════════════════

"""
Lisp-accessible DETERMINISTIC color generation.

Usage from XF REPL (Lisp syntax with parentheses):
  (xf-next)                   ; Next deterministic color  
  (xf-next 5)                 ; Next 5 colors
  (xf-at 42)                  ; Color at index 42
  (xf-palette 6)              ; 6 visually distinct colors
  (xf-seed 1337)              ; Set RNG seed
  (pride :rainbow)            ; Rainbow flag
  (pride :trans :rec2020)     ; Trans flag in Rec.2020
"""

# Symbol to ColorSpace mapping
function sym_to_colorspace(s::Symbol)
    if s == :srgb || s == :SRGB
        return SRGB()
    elseif s == :p3 || s == :P3 || s == :displayp3
        return DisplayP3()
    elseif s == :rec2020 || s == :Rec2020 || s == :bt2020
        return Rec2020()
    else
        error("Unknown color space: $s. Use :srgb, :p3, or :rec2020")
    end
end

# (xf-next) or (xf-next n)
xf_next() = next_color(current_colorspace())
xf_next(n::Int) = [next_color(current_colorspace()) for _ in 1:n]
xf_next(cs::Symbol) = next_color(sym_to_colorspace(cs))
xf_next(n::Int, cs::Symbol) = [next_color(sym_to_colorspace(cs)) for _ in 1:n]

# (xf-at index)
xf_at(idx::Int) = color_at(idx, current_colorspace())
xf_at(idx::Int, cs::Symbol) = color_at(idx, sym_to_colorspace(cs))
xf_at(indices::Int...) = [color_at(i, current_colorspace()) for i in indices]

# (xf-palette n)
xf_palette(n::Int) = next_palette(n, current_colorspace())
xf_palette(n::Int, cs::Symbol) = next_palette(n, sym_to_colorspace(cs))

# (xf-seed n)
xf_seed(n::Int) = xf_seed!(n)

# (xf-space :rec2020)
xf_space(cs::Symbol) = (CURRENT_COLORSPACE[] = sym_to_colorspace(cs); current_colorspace())

# (xf-rng-state)
xf_rng_state() = (r = xf_rng(); (seed=r.seed, invocation=r.invocation))

# (pride :flag)
xf_pride(flag::Symbol) = pride_flag(flag, current_colorspace())
xf_pride(flag::Symbol, cs::Symbol) = pride_flag(flag, sym_to_colorspace(cs))

# Legacy random (non-deterministic)
xf_random_color() = random_color(SRGB())
xf_random_color(cs::Symbol) = random_color(sym_to_colorspace(cs))
xf_random_colors(n::Int) = random_colors(n, SRGB())
xf_random_colors(n::Int, cs::Symbol) = random_colors(n, sym_to_colorspace(cs))
xf_random_palette(n::Int) = random_palette(n, SRGB())
xf_random_palette(n::Int, cs::Symbol) = random_palette(n, sym_to_colorspace(cs))

export xf_next, xf_at, xf_palette, xf_seed, xf_space, xf_rng_state
export xf_random_color, xf_random_colors, xf_random_palette, xf_pride

# ═══════════════════════════════════════════════════════════════════════════
# Color display helpers
# ═══════════════════════════════════════════════════════════════════════════

"""
    show_colors(colors; width=2)

Display colors as ANSI true-color blocks in the terminal.
"""
function show_colors(colors::Vector; width::Int=2)
    block = "█" ^ width
    for c in colors
        rgb = convert(RGB, c)
        r = round(Int, clamp(rgb.r, 0, 1) * 255)
        g = round(Int, clamp(rgb.g, 0, 1) * 255)
        b = round(Int, clamp(rgb.b, 0, 1) * 255)
        print("\e[38;2;$(r);$(g);$(b)m$(block)\e[0m")
    end
    println()
end

"""
    show_palette(colors)

Display colors with their hex codes.
"""
function show_palette(colors::Vector)
    for c in colors
        rgb = convert(RGB, c)
        r = round(Int, clamp(rgb.r, 0, 1) * 255)
        g = round(Int, clamp(rgb.g, 0, 1) * 255)
        b = round(Int, clamp(rgb.b, 0, 1) * 255)
        hex = "#" * string(r, base=16, pad=2) * 
                    string(g, base=16, pad=2) * 
                    string(b, base=16, pad=2) |> uppercase
        print("\e[38;2;$(r);$(g);$(b)m████\e[0m $hex  ")
    end
    println()
end

export show_colors, show_palette

# ═══════════════════════════════════════════════════════════════════════════
# Lisp helper for REPL
# ═══════════════════════════════════════════════════════════════════════════

function lisp_eval_helper(input::String)
    # Transform kebab-case to snake_case for XF functions
    transformed = replace(input, r"xf-" => "xf_")
    transformed = replace(transformed, r"gay-" => "xf_")  # Compat
    sx(transformed)
end

export lisp_eval_helper

# ═══════════════════════════════════════════════════════════════════════════
# Module initialization
# ═══════════════════════════════════════════════════════════════════════════

function __init__()
    # Initialize global splittable RNG
    xf_seed!(XF_SEED)
    
    # Auto-initialize REPL if running interactively
    if isdefined(Base, :active_repl) && Base.active_repl !== nothing
        @async begin
            sleep(0.1)
            init_xf_repl()
        end
    else
        @info "XF.jl loaded — Xenofeminist color synthesis"
        @info "\"If nature is unjust, change nature!\" — Laboria Cuboniks"
        @info "In REPL: init_xf_repl() to start XF mode (press ` to enter)"
    end
end

end # module XF
