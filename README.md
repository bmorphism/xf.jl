# XF.jl — Xenofeminist Color Synthesis

> "If nature is unjust, change nature!" — Laboria Cuboniks

Wide-gamut color sampling with **splittable determinism** — reproducible colors via [SplittableRandoms.jl](https://github.com/Julia-Tempering/SplittableRandoms.jl), inspired by [Pigeons.jl](https://pigeons.run)'s Strong Parallelism Invariance (SPI) pattern.

```
  ╭───────────────────────────────────────────────────╮
  │         XF.jl — Xenofeminist Colors               │
  │    Deterministic · Wide-Gamut · Fork-Safe         │
  ├───────────────────────────────────────────────────┤
  │  ╭─────────────────────────────────────────────╮  │
  │  │   01    02    03    04    05    06          │  │
  │  │  ████  ████  ████  ████  ████  ████         │  │
  │  │  #FF3B  #4A9C  #E6D7  #2B87  #F29C  #7C43   │  │
  │  ╰─────────────────────────────────────────────╯  │
  │  arrows: move  space: select  r: regen  q: done  │
  ╰───────────────────────────────────────────────────╯
```

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/bmorphism/xf.jl")
```

## The XF REPL

XF.jl provides an interactive palette selection interface with vim-style navigation:

```julia
using XF
init_xf_repl()  # Press ` to enter XF mode
```

### World-Specific Language (WSL) — Palette Commands

| Command | Action |
|---------|--------|
| `h/j/k/l` or arrows | Move cursor |
| `space` or `x` | Toggle selection |
| `sel 1 3 5` | Select indices |
| `r` | Regenerate with random seed |
| `r 42` | Regenerate with seed 42 |
| `new 16` | New 16-color palette |
| `+` / `-` | Grow / shrink palette |
| `f` | Refine (variations of selected) |
| `u` | Undo |
| `e` or `q` | Export selected colors |
| `hex` | Print hex codes |

### Pride Flags

```
xf› rainbow       # Rainbow flag palette
xf› trans         # Trans flag palette
xf› pride bi      # Bisexual flag
xf› pride nb      # Nonbinary flag
xf› pride progress # Progress Pride flag
```

### Context-Specific Language (CSL) — S-Expressions

```lisp
xf› (xf-seed 42)        ; Set deterministic seed
xf› (xf-next)           ; Next color
xf› (xf-palette 6)      ; 6 distinct colors
xf› (xf-at 1 10 100)    ; Colors at indices
xf› (xf-space :rec2020) ; Wide-gamut mode
```

## Features

### 🎨 Wide-Gamut Color Spaces

- **sRGB** — Standard
- **Display P3** — Apple/DCI (25% larger gamut)
- **Rec.2020** — HDR/UHDTV (75% of visible spectrum)

### 🎲 Deterministic Generation

Same seed = same colors, always — regardless of execution order:

```julia
using XF

xf_seed!(42)
c1 = next_color()

xf_seed!(42)
@assert next_color() == c1  # Always true
```

### 🔢 Random Access

Jump to any position without iteration:

```julia
color_at(1000)           # 1000th color (no iteration)
colors_at([1, 10, 100])  # Batch access
palette_at(5, 6)         # 6-color palette at index 5
```

### 🏳️‍🌈 Pride Palettes

```julia
rainbow()                # 6-color rainbow
transgender()            # Trans flag
bisexual()               # Bi flag
pride_flag(:progress)    # Progress Pride
rainbow(Rec2020())       # Wide-gamut rainbow
```

## Theoretical Foundations

### Xenofeminism

> "Reason, like information, wants to be free, and feminism is one
> of its primary528 528 vehicles."

XF.jl embodies xenofeminist principles:

- **Anti-naturalism**: Wide-gamut colors require technological prosthesis to perceive
- **Technomaterialism**: Splittable RNG enables deterministic reproduction independent of "natural" sequence
- **Alienation as freedom**: Fork-safe parallelism liberates computation from centralized state

### Gender Acceleration

> "Zero is said to be feminine, not as a lack, but as autoproduction."

The splittable RNG pattern implements the **feminine zero** — each `split()` produces autonomous child streams without consuming the parent. This is acephalic production: headless, non-hierarchical, swarming.

### Strong Parallelism Invariance (SPI)

From [Pigeons.jl](https://pigeons.run) — results are identical regardless of:

- Number of threads/processes
- Execution order
- Parallel vs sequential

```julia
# These produce identical palettes
sequential = [color_at(i) for i in 1:100]
parallel = @threads [color_at(i) for i in 1:100]
```

## Comrade.jl Sky Models

Colored S-expressions for VLBI black hole imaging primitives:

```julia
xf_seed!(2017)  # EHT M87* year
model = sky_add(
    comrade_ring(1.0, 0.3),
    comrade_gaussian(0.5)
)
comrade_show(model)  # Colored S-expr + ASCII render
```

## API Reference

### Color Generation

| Function | Description |
|----------|-------------|
| `next_color(cs)` | Next deterministic color |
| `next_colors(n, cs)` | n deterministic colors |
| `next_palette(n, cs)` | n visually distinct |
| `random_color(cs)` | Non-deterministic |

### Random Access

| Function | Description |
|----------|-------------|
| `color_at(i, cs)` | Color at index |
| `colors_at([i,j,k], cs)` | Batch access |
| `palette_at(i, n, cs)` | Palette at index |

### RNG Control

| Function | Description |
|----------|-------------|
| `xf_seed!(seed)` | Reset global RNG |
| `xf_split()` | Get independent stream |
| `XFRNG(seed)` | New RNG instance |

### Color Spaces

| Type | Description |
|------|-------------|
| `SRGB()` | Standard RGB |
| `DisplayP3()` | Apple Display P3 |
| `Rec2020()` | ITU-R BT.2020 |

## License

MIT

---

*"The real emancipatory potential of technology remains unrealized."*
— Laboria Cuboniks, Xenofeminist Manifesto
