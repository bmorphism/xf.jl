# Getting Started

> "If nature is unjust, change nature!" — Laboria Cuboniks, Xenofeminist Manifesto

## Installation

XF.jl is not yet in the Julia General registry. Install directly from GitHub:

```julia
using Pkg
Pkg.add(url="https://github.com/bmorphism/xf.jl")
```

## The XF REPL

XF.jl provides an interactive palette selection interface with two modes:

### World-Specific Language (WSL)
Direct commands for palette manipulation — navigation, selection, generation.

### Context-Specific Language (CSL)  
S-expression syntax for programmatic color operations.

```julia
using XF
init_xf_repl()  # Press ` (backtick) to enter XF mode
```

## Quick Start

### Generate Your First Colors

```julia
using XF

# Deterministic color (reproducible)
xf_seed!(42)
c = next_color()

# Next 6 colors
colors = [next_color() for _ in 1:6]
show_palette(colors)
```

### Interactive Palette Selection

In the XF REPL:

```
xf[0]› p                  # Show current palette
xf[0]› r                  # Regenerate with random seed
xf[0]› r 1337             # Regenerate with specific seed
xf[0]› space              # Toggle selection at cursor
xf[0]› sel 1 3 5          # Select indices 1, 3, 5
xf[0]› f                  # Refine: generate variations
xf[0]› e                  # Export selected colors
```

### Navigation (vim-style)

| Key | Action |
|-----|--------|
| `h` / `←` | Move left |
| `j` / `↓` | Move down |
| `k` / `↑` | Move up |
| `l` / `→` | Move right |
| `space` / `x` | Toggle selection |

### Use Pride Flags

```
xf› rainbow       # Rainbow flag
xf› trans         # Transgender flag
xf› pride bi      # Bisexual flag
xf› pride nb      # Nonbinary flag
xf› pride pan     # Pansexual flag
xf› pride ace     # Asexual flag
xf› pride progress  # Progress Pride flag
```

Or in Julia:

```julia
show_colors(rainbow())
show_colors(transgender())
show_palette(pride_flag(:progress))
```

## Understanding Seeds

The seed determines the entire color sequence — deterministic reproduction independent of execution context:

```julia
xf_seed!(42)
c1 = next_color()
c2 = next_color()

xf_seed!(42)      # Reset to same seed
@assert next_color() == c1  # Same sequence!
@assert next_color() == c2
```

Different seeds produce different sequences:

```julia
xf_seed!(42)
a = next_color()

xf_seed!(1337)
b = next_color()

@assert a != b
```

### Strong Parallelism Invariance

Results are identical regardless of execution order or parallelism:

```julia
# Sequential
xf_seed!(42)
seq = [color_at(i) for i in 1:100]

# Random order access — same results
xf_seed!(42)
random_order = colors_at([50, 1, 99, 25, 75])
@assert random_order == [seq[50], seq[1], seq[99], seq[25], seq[75]]
```

## Color Spaces

XF.jl supports multiple wide-gamut color spaces:

```julia
# Set global color space
xf_space(:srgb)      # Standard (default)
xf_space(:p3)        # Display P3 (25% larger)
xf_space(:rec2020)   # Rec.2020 (75% of visible)

# Or specify per-call
next_color(SRGB())
next_color(DisplayP3())
next_color(Rec2020())
```

In the REPL:

```
xf› srgb
xf› p3  
xf› rec2020
```

## Random Access

Jump to any position in the sequence without iterating — the **zero** of autoproduction:

```julia
# These give the same color regardless of prior calls
color_at(100)
color_at(100)  # Same!

# Batch access
colors_at([1, 10, 100, 1000])

# Palette at specific index
palette_at(42, 6)  # 6-color palette starting at index 42
```

## S-Expression Syntax (CSL)

In the XF REPL, use Lisp syntax for color operations:

```lisp
xf› (xf-seed 42)              ; Set seed
xf› (xf-next)                 ; Next deterministic color
xf› (xf-next 5)               ; Next 5 colors
xf› (xf-palette 6)            ; 6 distinct colors
xf› (xf-at 1 10 100)          ; Colors at indices
xf› (xf-space :rec2020)       ; Set color space
xf› (xf-pride :trans)         ; Trans flag colors
xf› (xf-rng-state)            ; Show (seed, invocation)
```

## Next Steps

- [Splittable Determinism](examples/splittable_determinism.md) — Deep dive into SPI
- [Wide-Gamut Colors](examples/wide_gamut_colors.md) — Beyond sRGB
- [Gender Acceleration](examples/gender_acceleration.md) — Accelerationist color theory
- [Xenofeminist DSL](examples/xenofeminist_dsl.md) — WSL/CSL design philosophy
- [Comrade Sky Models](examples/comrade_sky_models.md) — Black hole imaging
- [Pride Palettes](examples/pride_palettes.md) — Flag color schemes
- [Parallel SPI](examples/parallel_spi.md) — Fork-safe parallelism
