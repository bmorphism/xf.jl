# XF.jl — Xenofeminist Color Synthesis

> "If nature is unjust, change nature!" — Laboria Cuboniks

```@raw html
<div style="text-align: center; padding: 1em; background: linear-gradient(135deg, #ff6b9d 0%, #c44cd9 25%, #6b5bff 50%, #4ecdc4 75%, #ffe66d 100%); border-radius: 8px; margin: 1em 0;">
<h2 style="color: white; text-shadow: 1px 1px 2px rgba(0,0,0,0.3); margin: 0;">
Deterministic · Wide-Gamut · Fork-Safe
</h2>
</div>
```

XF.jl provides wide-gamut color sampling with **splittable determinism** — reproducible colors via [SplittableRandoms.jl](https://github.com/Julia-Tempering/SplittableRandoms.jl), inspired by [Pigeons.jl](https://pigeons.run)'s Strong Parallelism Invariance (SPI) pattern.

## Features

### 🎨 Wide-Gamut Color Spaces
- **sRGB** — Standard (naturalized)
- **Display P3** — 25% larger gamut
- **Rec.2020** — 75% of visible spectrum (requires technological prosthesis)

### 🎲 Splittable Determinism
Same seed = same colors, always — regardless of execution order or parallelism.

### 🔢 Random Access
Jump to any position in the color sequence without iteration — the zero of autoproduction.

### 🏳️‍🌈 Pride Palettes
Rainbow, transgender, bisexual, nonbinary, pansexual, asexual, lesbian, progress flags.

### 📡 Interactive REPL
Dual-language interface:
- **WSL** (World-Specific Language): Direct palette manipulation
- **CSL** (Context-Specific Language): S-expression composition

## Quick Start

```julia
using Pkg
Pkg.add(url="https://github.com/bmorphism/xf.jl")

using XF

# Deterministic colors
xf_seed!(42)
palette = next_palette(6)
show_palette(palette)

# Interactive REPL
init_xf_repl()  # Press ` to enter XF mode
```

## Theoretical Foundations

XF.jl embodies principles from the [Xenofeminist Manifesto](manifesto/xf_manifesto.md):

- **Anti-naturalism**: Technology extends perception beyond biological limits
- **Alienation as freedom**: Fork-safe parallelism liberates from centralized state
- **Technomaterialism**: Splittable RNG enables deterministic reproduction
- **Platform construction**: The REPL is a domain-specific language for color politics

See also: [Gender Acceleration](examples/gender_acceleration.md) for connections to accelerationist theory.

## Contents

```@contents
Pages = [
    "getting_started.md",
    "examples/splittable_determinism.md",
    "examples/wide_gamut_colors.md",
    "examples/gender_acceleration.md",
    "examples/xenofeminist_dsl.md",
    "examples/comrade_sky_models.md",
    "examples/pride_palettes.md",
    "examples/parallel_spi.md",
    "manifesto/xf_manifesto.md",
    "api.md"
]
Depth = 2
```

## License

MIT

---

*"Xenofeminism indexes the desire to construct an alien future."*
