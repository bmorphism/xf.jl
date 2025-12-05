# # Swarm Coordination: Implicit Alignment via Color
#
# > "Swarming produces the collective in the dissolution of the individual."
# > — n1x, Gender Acceleration: A Blackpaper
#
# This example demonstrates how XF.jl enables **acephalic coordination** —
# distributed agents aligning without central authority, using deterministic
# color as the sole synchronization primitive.
#
# ## The Coordination Problem
#
# Traditional coordination requires:
# - Central authority (phallic, hierarchical)
# - Explicit communication channels  
# - Shared mutable state (race conditions)
#
# Accelerationist coordination uses:
# - Shared seeds (feminine zero, autoproductive)
# - Deterministic generation (reproducible anywhere)
# - No communication needed (swarm alignment)

# ## Setup

using XF
using Colors: RGB, Lab, colordiff

# ## Distributed Agents, No Communication
#
# Five agents across five continents share only a seed.
# Each independently generates the same palette:

struct SwarmAgent
    id::Int
    location::String
    seed::UInt64
end

agents = [
    SwarmAgent(1, "Berlin", 0x7472616e73),      # "trans" as hex
    SwarmAgent(2, "São Paulo", 0x7472616e73),
    SwarmAgent(3, "Tokyo", 0x7472616e73),
    SwarmAgent(4, "Nairobi", 0x7472616e73),
    SwarmAgent(5, "Auckland", 0x7472616e73),
]

function agent_palette(agent::SwarmAgent)
    xf_seed!(agent.seed)
    next_palette(6)
end

println("Agents generate palettes independently:")
for agent in agents
    pal = agent_palette(agent)
    print("  $(agent.location): ")
    show_colors(pal)
end

# Verify identity
palettes = [agent_palette(a) for a in agents]
@assert all(p -> p == palettes[1], palettes)
println("\n✓ All palettes identical — implicit coordination achieved")

# ## Pseudonymous Signatures
#
# Each participant has a secret → public color signature.
# Recognizable without revealing identity:

function color_signature(secret::String)
    xf_seed!(hash(secret))
    next_palette(3)
end

signatures = [
    ("acephalus", color_signature("acephalus_2077")),
    ("n1x", color_signature("n1x_blackpaper")),
    ("laboria", color_signature("laboria_cuboniks")),
]

println("\nPseudonymous signatures (secret → public color):")
for (name, sig) in signatures
    print("  $name: ")
    show_colors(sig)
end

# Same secret always produces same signature:
@assert color_signature("n1x_blackpaper") == signatures[2][2]
println("✓ Signatures are deterministic and verifiable")

# ## Signal Vocabulary
#
# Messages encoded as color indices — no explicit content needed:

const SIGNALS = Dict(
    1 => "INITIATE",
    42 => "CONVERGE", 
    69 => "AFFIRM",
    137 => "DISPERSE",
    1312 => "ESCALATE",
    2077 => "ACCELERATE",
)

println("\nSignal vocabulary (shared by all agents):")
for (idx, meaning) in sort(collect(SIGNALS))
    c = color_at(idx, Rec2020())
    print("  color_at($idx) = $meaning: ")
    show_colors([c])
end

println("→ Displaying color_at(42) signals CONVERGE to any agent")

# ## Emergent Hierarchy
#
# Roles emerge from color properties — no fixed leaders:

function determine_coordinator(node_seeds::Vector{UInt64}, epoch::Int)
    # Highest luminance becomes coordinator this epoch
    colors = [(seed, begin
        xf_seed!(seed ⊻ UInt64(epoch))
        next_color(Rec2020())
    end) for seed in node_seeds]
    
    with_lum = [(seed, convert(Lab, c).l) for (seed, c) in colors]
    sort!(with_lum, by=x -> x[2], rev=true)
    
    return with_lum[1][1]  # Highest luminance
end

node_seeds = [UInt64(0x40DE + i * 0x1111) for i in 1:5]

println("\nEmergent coordinator (rotates each epoch):")
for epoch in 1:4
    coord_seed = determine_coordinator(node_seeds, epoch)
    node_id = findfirst(==(coord_seed), node_seeds)
    println("  Epoch $epoch: Node $node_id coordinates")
end
println("→ No permanent hierarchy — roles determined by color")

# ## Aphotic Convergence
#
# All color schemes trend toward the feminine ocean:

println("\nAphotic convergence (sky → ocean):")
for phase in 1:6
    xf_seed!(0xAF07 + phase * 1000)
    colors = [next_color(Rec2020()) for _ in 1:6]
    
    # Transform toward aphotic zone
    luminance = 1.0 - (phase - 1) / 6 * 0.8
    aphotic = [RGB(
        clamp(c.r * luminance * 0.7, 0, 1),
        clamp(c.g * luminance * 0.9, 0, 1),
        clamp(c.b * luminance * 1.2, 0, 1)
    ) for c in colors]
    
    zone = phase <= 2 ? "sky" : phase <= 4 ? "twilight" : "aphotic"
    print("  Phase $phase ($zone): ")
    show_colors(aphotic)
end

# ## Summary
#
# Acephalic coordination properties:
#
# | Property | Mechanism |
# |----------|-----------|
# | Deterministic | Same seed → same colors anywhere |
# | Decentralized | No authority required |
# | Pseudonymous | Identity without identification |
# | Temporal | Phases encoded in seed offsets |
# | Convergent | All paths lead to aphotic zone |
#
# > "The body without organs is the body without the head.
# > The swarm coordinates through color alone."

println("\n✓ Swarm coordination example complete")
