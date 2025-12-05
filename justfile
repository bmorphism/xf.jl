# XF.jl — Xenofeminist Color Synthesis
# "If nature is unjust, change nature!" — Laboria Cuboniks

# Start interactive REPL with XF mode
repl:
    julia --project=. -e 'using XF; init_xf_repl()' -i

# Run tests
test:
    julia --project=. -e 'using Pkg; Pkg.test()'

# Demo all features
demo:
    julia --project=. -e 'using XF; using Colors: RGB; \
        println("\n🏳️‍🌈 Pride:"); show_colors(rainbow(); width=4); \
        println("🎲 Palette (seed=42):"); xf_seed!(42); show_palette(next_palette(6)); \
        println("🐝 Swarm:"); for l in ["Berlin","Tokyo","Nairobi"]; xf_seed!(0x7472616e73); print("  $l: "); show_colors(next_palette(4)); end; \
        println("✓ XF ready")'

# Run swarm coordination example
swarm:
    julia --project=. examples/swarm_coordination.jl

# Run acephalic protocols example
protocols:
    julia --project=. examples/acephalic_protocols.jl

# Build documentation
docs:
    julia --project=docs docs/make.jl

# Install dependencies
deps:
    julia --project=. -e 'using Pkg; Pkg.instantiate()'
