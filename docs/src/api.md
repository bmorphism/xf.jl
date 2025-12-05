# API Reference

## Color Generation

### Deterministic (Splittable RNG)

```@docs
next_color
next_colors
next_palette
```

### Random Access

```@docs
color_at
colors_at
palette_at
```

### Non-Deterministic

```@docs
random_color
random_colors
random_palette
```

## RNG Control

```@docs
xf_seed!
xf_rng
xf_split
XFRNG
XF_SEED
```

## Color Spaces

```@docs
ColorSpace
SRGB
DisplayP3
Rec2020
CustomColorSpace
Primaries
```

### Color Space Operations

```@docs
in_gamut
clamp_to_gamut
gamut_map
rgb_to_xyz_matrix
```

## Pride Flags

```@docs
pride_flag
rainbow
transgender
bisexual
nonbinary
pansexual
asexual
```

## Display

```@docs
show_colors
show_palette
```

## Palette Selection (REPL)

```@docs
init_xf_repl
palette_state
show_palette_interactive
palette_toggle
palette_move
palette_regenerate
palette_grow
palette_shrink
palette_refine
palette_undo
palette_extract
palette_pride
```

## Lisp Interface

```@docs
xf_next
xf_at
xf_palette
xf_seed
xf_space
xf_rng_state
xf_pride
```

## Comrade Sky Models

```@docs
SkyPrimitive
Ring
MRing
Gaussian
Disk
Crescent
SkyModel
comrade_ring
comrade_mring
comrade_gaussian
comrade_disk
comrade_crescent
sky_add
sky_stretch
sky_rotate
sky_shift
sky_show
sky_render
comrade_show
comrade_model
```
