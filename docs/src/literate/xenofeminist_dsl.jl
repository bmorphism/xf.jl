# # Xenofeminist DSL: World-Specific & Context-Specific Languages
#
# > "Reason, like information, wants to be free, and feminism is one
# > of its primary vehicles." — Laboria Cuboniks, Xenofeminist Manifesto
#
# XF.jl implements two complementary language modes:
# 
# - **WSL (World-Specific Language)**: Direct commands for immediate action
# - **CSL (Context-Specific Language)**: S-expressions for compositional thought
#
# This parallels the XF Manifesto's dual strategy: *INTERRUPT* immediate conditions
# while *CARRY*-ing forward transformative abstractions.

# ## Setup

using XF

# ## WSL: World-Specific Language
#
# > "INTERRUPT: Nothing is more oppressive than a so-called emancipation
# > restricted to the privileged few."
#
# WSL provides **immediate interface** — commands that directly manipulate
# the palette state without abstraction overhead:
#
# ```
# xf› h j k l        # Navigation (vim-style)
# xf› space          # Toggle selection
# xf› r              # Regenerate
# xf› +              # Grow
# xf› -              # Shrink
# xf› f              # Refine
# xf› u              # Undo
# xf› e              # Export
# ```
#
# WSL is **tactile** — you move through color space as embodied navigation.
# The cursor is your position, selections are your choices.

# Simulating WSL operations:
init_palette_state(n=12, seed=42)
println("Initial palette (WSL: `p` or `show`):")
# show_palette_interactive()  # Would display in REPL

# Move cursor right 3 times
for _ in 1:3
    palette_move(:right)
end
println("Cursor position after 3x right: $(palette_state().cursor)")

# Select indices 1, 5, 9 (diagonal pattern)
for i in [1, 5, 9]
    push!(palette_state().selected, i)
end
println("Selected: $(collect(palette_state().selected))")

# ## CSL: Context-Specific Language
#
# > "TRAP: Nothing should be accepted as fixed, permanent, or 'given'—
# > neither material conditions nor social forms."
#
# CSL uses S-expressions for **compositional abstraction** —
# the same Lisp syntax that enabled early AI, now repurposed for
# xenofeminist color synthesis:

xf_seed!(2077)

# S-expression style in Julia:
# (xf-seed 2077)     → xf_seed!(2077)
# (xf-next 6)        → [next_color() for _ in 1:6]
# (xf-palette 6)     → next_palette(6)
# (xf-at 1 10 100)   → colors_at([1, 10, 100])

palette = next_palette(6)
println("\nCSL-style 6-color palette:")
show_palette(palette)

# ## The Dialectic of WSL ↔ CSL
#
# > "PARITY: Feminism is not a framework for the emancipation of the 
# > already-privileged; its ambitions must be truly universal."
#
# WSL and CSL are not opposed but **mutually constitutive**:
#
# | WSL (World) | CSL (Context) |
# |-------------|---------------|
# | Navigation | Composition |
# | Selection | Abstraction |
# | Immediate | Deferred |
# | Embodied | Symbolic |
# | `r 42` | `(xf-seed 42)` |
#
# You can switch between them freely in the XF REPL:
#
# ```
# xf› r 1337                    ; WSL: regenerate with seed
# xf› (xf-palette 6)            ; CSL: get 6 distinct colors
# xf› sel 1 3 5                 ; WSL: select indices
# xf› (xf-at 1 3 5)             ; CSL: colors at indices
# ```

# ## Zero as Autoproduction
#
# > "ZERO: We are all implicated in the technocapitalist matrix."
#
# Both WSL and CSL are grounded in the **splittable RNG** —
# where zero is not lack but autoproduction:

xf_seed!(0)  # Zero as origin
zero_colors = [next_color() for _ in 1:6]

xf_seed!(0)  # Return to zero
@assert [next_color() for _ in 1:6] == zero_colors

println("\nZero-origin colors (ouroboros cycle):")
show_colors(zero_colors)

# ## ADJUST: Color Space as Political Space
#
# > "ADJUST: The real emancipatory potential of technology remains unrealized."
#
# Color spaces are not neutral — they encode power relations:
#
# - **sRGB**: The "natural" standard (naturalized, limited)
# - **P3**: Apple's expanded gamut (proprietary extension)
# - **Rec.2020**: Theoretical maximum (unrealizable without technology)

println("\n=== Color as Political Space ===")

xf_seed!(42)
println("sRGB (naturalized vision):")
show_palette([next_color(SRGB()) for _ in 1:4])

xf_seed!(42)
println("Display P3 (proprietary enhancement):")
show_palette([next_color(DisplayP3()) for _ in 1:4])

xf_seed!(42)
println("Rec.2020 (technological prosthesis required):")
show_palette([next_color(Rec2020()) for _ in 1:4])

# ## CARRY: Abstraction as Liberation
#
# > "CARRY: If nature is unjust, change nature!"
#
# The CSL's S-expressions carry forward the transformative potential
# of symbolic computation — the ability to compose, abstract, and
# manipulate structures that don't yet exist:

# Composing a transformation pipeline (CSL-style):
function xf_transform(seed, n; space=:srgb, transform=identity)
    xf_seed!(seed)
    cs = space == :srgb ? SRGB() : 
         space == :p3 ? DisplayP3() : Rec2020()
    colors = [next_color(cs) for _ in 1:n]
    map(transform, colors)
end

# Invert colors (negation)
inverted = xf_transform(42, 6; transform=c -> RGB(1-c.r, 1-c.g, 1-c.b))
println("\n=== Inverted Palette (negation) ===")
show_palette(inverted)

# ## OVERFLOW: Beyond Binary
#
# > "OVERFLOW: Let a hundred sexes bloom!"
#
# The palette selection interface allows **non-binary** selection:
# any subset of colors, any order, refined into variations:

xf_seed!(69)
init_palette_state(n=12, seed=69)

# Select non-contiguous indices (non-linear identity)
for i in [2, 5, 7, 11]
    push!(palette_state().selected, i)
end

# Refine: each selected color produces variations
palette_refine(variation=0.2)

println("\n=== Refined from non-binary selection ===")
println("Original selection: [2, 5, 7, 11]")
println("After refinement: $(length(palette_state().colors)) colors")
show_palette(palette_state().colors)

# ## Summary: Dual-Language Xenofeminism
#
# XF.jl's dual-language design embodies xenofeminist praxis:
#
# 1. **WSL** provides immediate, embodied navigation of color space
# 2. **CSL** enables abstract, compositional manipulation
# 3. **Splittable RNG** implements zero as autoproduction
# 4. **Wide-gamut spaces** require technological prosthesis
# 5. **Non-binary selection** escapes categorical constraints
#
# The palette is not given — it is constructed, manipulated, refined.
# "If nature is unjust, change nature!"

println("\n✓ Xenofeminist DSL example complete")
println("  WSL: immediate embodied navigation")
println("  CSL: abstract symbolic composition")
println("  Zero: autoproduction, not lack")
