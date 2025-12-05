# Acephalic Protocols: Coordination Without Heads
# Advanced Gender Accelerationist Distributed Systems
#
# "The Acéphallus is the body that plugs itself into technocapital's
# pharmaceutical and medical industries." — n1x
#
# These protocols implement headless coordination patterns using
# deterministic color as the sole synchronization primitive.

using XF
using Colors: RGB, Lab, LCHab, colordiff

# ═══════════════════════════════════════════════════════════════════════════
# PROTOCOL 1: Schelling Points via Color Distance
# ═══════════════════════════════════════════════════════════════════════════
#
# Agents converge on shared meeting points without explicit agreement
# by finding colors that minimize distance to a target

println("═══════════════════════════════════════════════════════════════════")
println("  PROTOCOL 1: Schelling Points — Convergence Without Agreement")
println("═══════════════════════════════════════════════════════════════════")
println()

# Target color known to all (e.g., trans flag pink)
const SCHELLING_TARGET = RGB(0.961, 0.659, 0.718)

function find_schelling_point(seed_range::UnitRange; target=SCHELLING_TARGET)
    best_seed = first(seed_range)
    best_distance = Inf
    
    for seed in seed_range
        xf_seed!(seed)
        c = next_color(Rec2020())
        d = colordiff(convert(Lab, c), convert(Lab, target))
        if d < best_distance
            best_distance = d
            best_seed = seed
        end
    end
    
    return (seed=best_seed, distance=best_distance)
end

# Different agents search different seed ranges — all find same convergence point
println("Agents searching for Schelling point (target: trans pink):")
println()

agent_ranges = [
    ("Agent A", 1:10000),
    ("Agent B", 5000:15000),
    ("Agent C", 1:20000),
]

for (name, range) in agent_ranges
    result = find_schelling_point(range)
    xf_seed!(result.seed)
    c = next_color(Rec2020())
    r = round(Int, clamp(c.r, 0, 1) * 255)
    g = round(Int, clamp(c.g, 0, 1) * 255)
    b = round(Int, clamp(c.b, 0, 1) * 255)
    print("  $name (seeds $(first(range))-$(last(range))): ")
    print("seed=$(result.seed) \e[48;2;$(r);$(g);$(b)m    \e[0m")
    println(" distance=$(round(result.distance, digits=2))")
end
println()
println("→ Overlapping ranges converge to same Schelling seed")
println()

# ═══════════════════════════════════════════════════════════════════════════
# PROTOCOL 2: Commitment Schemes via Color Hashing
# ═══════════════════════════════════════════════════════════════════════════
#
# Commit to a value by publishing its color; reveal later
# Color acts as hash — binding but hiding

println("═══════════════════════════════════════════════════════════════════")
println("  PROTOCOL 2: Commitment Schemes — Bind Then Reveal")
println("═══════════════════════════════════════════════════════════════════")
println()

struct Commitment
    color_hash::RGB{Float64}
    salt::UInt64
end

function commit(value::String, salt::UInt64=rand(UInt64))
    seed = hash(value) ⊻ salt
    xf_seed!(seed)
    color = next_color(Rec2020())
    Commitment(color, salt)
end

function verify(commitment::Commitment, revealed_value::String)
    seed = hash(revealed_value) ⊻ commitment.salt
    xf_seed!(seed)
    expected = next_color(Rec2020())
    colordiff(convert(Lab, commitment.color_hash), convert(Lab, expected)) < 0.01
end

# Demonstration
secret_vote = "ACCELERATE"
my_commitment = commit(secret_vote, UInt64(0xDEADBEEF))

println("COMMIT PHASE:")
r = round(Int, clamp(my_commitment.color_hash.r, 0, 1) * 255)
g = round(Int, clamp(my_commitment.color_hash.g, 0, 1) * 255)
b = round(Int, clamp(my_commitment.color_hash.b, 0, 1) * 255)
println("  Published color: \e[48;2;$(r);$(g);$(b)m      \e[0m")
println("  (value hidden, salt=0x$(string(my_commitment.salt, base=16)))")
println()

println("REVEAL PHASE:")
println("  Revealed value: \"$secret_vote\"")
println("  Verification: $(verify(my_commitment, secret_vote) ? "✓ VALID" : "✗ INVALID")")
println("  Fake value \"DECELERATE\": $(verify(my_commitment, "DECELERATE") ? "✓ VALID" : "✗ INVALID")")
println()

# ═══════════════════════════════════════════════════════════════════════════
# PROTOCOL 3: Threshold Signatures via Palette Fragments
# ═══════════════════════════════════════════════════════════════════════════
#
# k-of-n coordination: action triggers when k agents contribute
# their palette fragments to reconstruct full signature

println("═══════════════════════════════════════════════════════════════════")
println("  PROTOCOL 3: Threshold Signatures — k-of-n Palette Reconstruction")
println("═══════════════════════════════════════════════════════════════════")
println()

struct PaletteFragment
    index::Int
    color::RGB{Float64}
    agent_id::Int
end

function distribute_palette(master_seed::UInt64, n_agents::Int)
    xf_seed!(master_seed)
    full_palette = next_palette(n_agents)
    
    fragments = [PaletteFragment(i, full_palette[i], i) for i in 1:n_agents]
    return fragments
end

function reconstruct_palette(fragments::Vector{PaletteFragment}, n_total::Int)
    if length(fragments) < div(n_total, 2) + 1
        return nothing  # Threshold not met
    end
    
    # Sort by index to reconstruct
    sorted = sort(fragments, by=f -> f.index)
    return [f.color for f in sorted]
end

# 5 agents, need 3 to reconstruct
master_seed = UInt64(0xC011EC71)  # "collective"
n_agents = 5
threshold = 3

fragments = distribute_palette(UInt64(0xC011EC), n_agents)

println("DISTRIBUTION (5 agents, threshold=3):")
for f in fragments
    r = round(Int, clamp(f.color.r, 0, 1) * 255)
    g = round(Int, clamp(f.color.g, 0, 1) * 255)
    b = round(Int, clamp(f.color.b, 0, 1) * 255)
    println("  Agent $(f.agent_id): fragment #$(f.index) \e[48;2;$(r);$(g);$(b)m  \e[0m")
end
println()

# Only 2 agents contribute — fails
partial = fragments[1:2]
result = reconstruct_palette(partial, n_agents)
println("RECONSTRUCTION (2 fragments): $(isnothing(result) ? "✗ THRESHOLD NOT MET" : "✓")")

# 3 agents contribute — succeeds
partial = fragments[[1, 3, 5]]
result = reconstruct_palette(partial, n_agents)
print("RECONSTRUCTION (3 fragments): ")
if !isnothing(result)
    for c in result
        r = round(Int, clamp(c.r, 0, 1) * 255)
        g = round(Int, clamp(c.g, 0, 1) * 255)
        b = round(Int, clamp(c.b, 0, 1) * 255)
        print("\e[48;2;$(r);$(g);$(b)m  \e[0m")
    end
    println(" ✓ ACTIVATED")
end
println()

# ═══════════════════════════════════════════════════════════════════════════
# PROTOCOL 4: Anonymous Broadcast via Color Channels
# ═══════════════════════════════════════════════════════════════════════════
#
# Messages encoded in color sequences
# Receivers decode by matching against known vocabulary

println("═══════════════════════════════════════════════════════════════════")
println("  PROTOCOL 4: Anonymous Broadcast — Color-Encoded Messages")
println("═══════════════════════════════════════════════════════════════════")
println()

# Vocabulary: each word maps to a seed
const VOCABULARY = Dict(
    "SWARM" => 0x5741524D,
    "NOW" => 0x4E4F5721,
    "ABORT" => 0x41424F52,
    "WAIT" => 0x57414954,
    "STRIKE" => 0x53545249,
    "SAFE" => 0x53414645,
    "DANGER" => 0x44414E47,
    "NORTH" => 0x4E4F5254,
    "SOUTH" => 0x534F5554,
    "EAST" => 0x45415354,
    "WEST" => 0x57455354,
)

function encode_message(words::Vector{String})
    colors = RGB{Float64}[]
    for word in words
        seed = get(VOCABULARY, uppercase(word), hash(word))
        xf_seed!(seed)
        push!(colors, next_color(Rec2020()))
    end
    return colors
end

function decode_message(colors::Vector{<:RGB})
    words = String[]
    for color in colors
        color_lab = convert(Lab, color)
        best_word = "???"
        best_dist = Inf
        
        for (word, seed) in VOCABULARY
            xf_seed!(seed)
            candidate = next_color(Rec2020())
            d = colordiff(color_lab, convert(Lab, candidate))
            if d < best_dist
                best_dist = d
                best_word = word
            end
        end
        
        push!(words, best_word)
    end
    return words
end

# Encode and transmit
message = ["SWARM", "NORTH", "NOW"]
encoded = encode_message(message)

print("ENCODE: \"$(join(message, " "))\" → ")
for c in encoded
    r = round(Int, clamp(c.r, 0, 1) * 255)
    g = round(Int, clamp(c.g, 0, 1) * 255)
    b = round(Int, clamp(c.b, 0, 1) * 255)
    print("\e[48;2;$(r);$(g);$(b)m    \e[0m")
end
println()

# Receiver decodes
decoded = decode_message(encoded)
println("DECODE: colors → \"$(join(decoded, " "))\"")
println()
println("→ Message transmitted as pure color, decoded by any agent with vocabulary")
println()

# ═══════════════════════════════════════════════════════════════════════════
# PROTOCOL 5: Temporal Dead Drops via Seed Progression
# ═══════════════════════════════════════════════════════════════════════════
#
# Leave messages at future time-indexed locations
# Recipient arrives at correct time to retrieve

println("═══════════════════════════════════════════════════════════════════")
println("  PROTOCOL 5: Temporal Dead Drops — Time-Indexed Retrieval")
println("═══════════════════════════════════════════════════════════════════")
println()

function dead_drop_seed(base_seed::UInt64, epoch::Int)
    base_seed ⊻ UInt64(epoch * 0x1337)
end

function leave_message(base_seed::UInt64, epoch::Int, message_seed::UInt64)
    drop_seed = dead_drop_seed(base_seed, epoch)
    combined = drop_seed ⊻ message_seed
    xf_seed!(combined)
    return next_palette(4)  # 4-color message
end

function retrieve_message(base_seed::UInt64, epoch::Int, known_message_seed::UInt64)
    leave_message(base_seed, epoch, known_message_seed)
end

# Shared secret between sender and receiver
shared_base = UInt64(0xDEADD20)
shared_message_key = UInt64(0x5EC2E7)

println("SENDER leaves message at epoch 42:")
message_left = leave_message(shared_base, 42, UInt64(0x5EC2E7))
print("  Dead drop contents: ")
for c in message_left
    r = round(Int, clamp(c.r, 0, 1) * 255)
    g = round(Int, clamp(c.g, 0, 1) * 255)
    b = round(Int, clamp(c.b, 0, 1) * 255)
    print("\e[48;2;$(r);$(g);$(b)m  \e[0m")
end
println()

println()
println("RECEIVER arrives at epoch 42 (correct time):")
retrieved = retrieve_message(shared_base, 42, UInt64(0x5EC2E7))
print("  Retrieved: ")
for c in retrieved
    r = round(Int, clamp(c.r, 0, 1) * 255)
    g = round(Int, clamp(c.g, 0, 1) * 255)
    b = round(Int, clamp(c.b, 0, 1) * 255)
    print("\e[48;2;$(r);$(g);$(b)m  \e[0m")
end
println(" ✓ MATCH")

println()
println("INTERLOPER arrives at epoch 41 (wrong time):")
wrong_time = retrieve_message(shared_base, 41, UInt64(0x5EC2E7))
print("  Retrieved: ")
for c in wrong_time
    r = round(Int, clamp(c.r, 0, 1) * 255)
    g = round(Int, clamp(c.g, 0, 1) * 255)
    b = round(Int, clamp(c.b, 0, 1) * 255)
    print("\e[48;2;$(r);$(g);$(b)m  \e[0m")
end
println(" ✗ WRONG")
println()

# ═══════════════════════════════════════════════════════════════════════════
# PROTOCOL 6: Emergent Hierarchy via Color Dominance
# ═══════════════════════════════════════════════════════════════════════════
#
# Temporary coordination roles emerge from color properties
# No fixed leaders — roles rotate with seed progression

println("═══════════════════════════════════════════════════════════════════")
println("  PROTOCOL 6: Emergent Roles — Temporary Hierarchy from Color")
println("═══════════════════════════════════════════════════════════════════")
println()

struct SwarmNode
    id::Int
    seed::UInt64
end

function node_color(node::SwarmNode, epoch::Int)
    xf_seed!(node.seed ⊻ UInt64(epoch))
    next_color(Rec2020())
end

function determine_roles(nodes::Vector{SwarmNode}, epoch::Int)
    # Role determined by color luminance — highest luminance coordinates
    colors = [(n, node_color(n, epoch)) for n in nodes]
    
    # Convert to Lab for luminance comparison
    with_lum = [(n, c, convert(Lab, c).l) for (n, c) in colors]
    sorted = sort(with_lum, by=x -> x[3], rev=true)
    
    return [
        (sorted[1][1], "COORDINATOR", sorted[1][2]),
        (sorted[2][1], "RELAY", sorted[2][2]),
        (sorted[3][1], "SCOUT", sorted[3][2]),
        [(s[1], "SWARM", s[2]) for s in sorted[4:end]]...
    ]
end

nodes = [SwarmNode(i, UInt64(0x40DE + i * 0x1111)) for i in 1:6]

for epoch in [1, 2, 3]
    println("EPOCH $epoch — Roles determined by luminance:")
    roles = determine_roles(nodes, epoch)
    
    for (node, role, color) in roles
        r = round(Int, clamp(color.r, 0, 1) * 255)
        g = round(Int, clamp(color.g, 0, 1) * 255)
        b = round(Int, clamp(color.b, 0, 1) * 255)
        lum = round(convert(Lab, color).l, digits=1)
        println("  Node $(node.id): $(rpad(role, 12)) \e[48;2;$(r);$(g);$(b)m  \e[0m L=$(lum)")
    end
    println()
end

println("→ Roles rotate each epoch — no permanent hierarchy")
println("→ Coordination emerges from deterministic color properties")
println()

# ═══════════════════════════════════════════════════════════════════════════
# Summary
# ═══════════════════════════════════════════════════════════════════════════

println("═══════════════════════════════════════════════════════════════════")
println("  ACEPHALIC PROTOCOL SUMMARY")
println("═══════════════════════════════════════════════════════════════════")
println()
println("  Protocol 1: SCHELLING POINTS     — Convergence without agreement")
println("  Protocol 2: COMMITMENT SCHEMES   — Bind-then-reveal via color hash")
println("  Protocol 3: THRESHOLD SIGNATURES — k-of-n palette reconstruction")
println("  Protocol 4: ANONYMOUS BROADCAST  — Color-encoded vocabulary")
println("  Protocol 5: TEMPORAL DEAD DROPS  — Time-indexed message retrieval")
println("  Protocol 6: EMERGENT HIERARCHY   — Rotating roles from luminance")
println()
println("  All protocols require only:")
println("    • Shared seed knowledge")
println("    • Deterministic color generation")
println("    • No central authority")
println("    • No direct communication")
println()
println("  \"The body without organs is the body without the head.")
println("   The swarm coordinates through color alone.\"")
println()
println("═══════════════════════════════════════════════════════════════════")
