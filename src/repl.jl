# XF.jl REPL — Xenofeminist Palette Selection Interface
# World-Specific Language (WSL) + Context-Specific Language (CSL) for color
#
# "If nature is unjust, change nature!" — Laboria Cuboniks

using REPL: REPL, LineEdit
using ReplMaker
using Colors: RGB, Lab, LCHab

# Current color space state (must be defined before use)
const CURRENT_COLORSPACE = Ref{ColorSpace}(SRGB())
current_colorspace() = CURRENT_COLORSPACE[]

# ═══════════════════════════════════════════════════════════════════════════
# XF Prompt — shifts hue over time (non-static identity)
# ═══════════════════════════════════════════════════════════════════════════

function xf_prompt_color(invocation::Int)
    # Hue rotates with each invocation — identity is process, not essence
    hue = mod(invocation * 37, 360)
    lch = LCHab(70, 80, hue)
    rgb = convert(RGB, lch)
    r = round(Int, clamp(rgb.r, 0, 1) * 255)
    g = round(Int, clamp(rgb.g, 0, 1) * 255)
    b = round(Int, clamp(rgb.b, 0, 1) * 255)
    "\e[38;2;$(r);$(g);$(b)m"
end

const RESET = "\e[0m"

function xf_prompt()
    inv = isassigned(GLOBAL_XF_RNG) ? GLOBAL_XF_RNG[].invocation : 0
    color = xf_prompt_color(Int(inv))
    "$(color)xf[$(inv)]›$(RESET) "
end

# ═══════════════════════════════════════════════════════════════════════════
# Palette Selection State Machine
# ═══════════════════════════════════════════════════════════════════════════

mutable struct PaletteState
    colors::Vector{RGB{Float64}}
    selected::Set{Int}
    cursor::Int
    mode::Symbol  # :browse, :select, :refine
    history::Vector{Vector{RGB{Float64}}}
    seed::UInt64
end

const PALETTE_STATE = Ref{PaletteState}()

function init_palette_state(; n::Int=12, seed::Int=42)
    xf_seed!(seed)
    colors = [next_color(current_colorspace()) for _ in 1:n]
    PALETTE_STATE[] = PaletteState(
        colors,
        Set{Int}(),
        1,
        :browse,
        Vector{RGB{Float64}}[],
        UInt64(seed)
    )
end

function palette_state()
    if !isassigned(PALETTE_STATE)
        init_palette_state()
    end
    PALETTE_STATE[]
end

# ═══════════════════════════════════════════════════════════════════════════
# Visual Palette Display with Selection Indicators
# ═══════════════════════════════════════════════════════════════════════════

function show_palette_interactive(ps::PaletteState=palette_state())
    n = length(ps.colors)
    cols = min(n, 6)
    rows = ceil(Int, n / cols)
    
    println()
    println("  ╭─────────────────────────────────────────────────────╮")
    println("  │  XF Palette   seed=$(ps.seed)   mode=:$(ps.mode)  │")
    println("  ├─────────────────────────────────────────────────────┤")
    
    for row in 1:rows
        # Color blocks row
        print("  │ ")
        for col in 1:cols
            i = (row - 1) * cols + col
            if i <= n
                c = ps.colors[i]
                r = round(Int, clamp(c.r, 0, 1) * 255)
                g = round(Int, clamp(c.g, 0, 1) * 255)
                b = round(Int, clamp(c.b, 0, 1) * 255)
                
                # Selection indicator
                is_selected = i in ps.selected
                is_cursor = i == ps.cursor
                
                if is_cursor
                    print("\e[7m")  # Inverse
                end
                print("\e[48;2;$(r);$(g);$(b)m")
                
                # Show index in block
                idx_str = lpad(string(i), 2)
                if is_selected
                    print(" ✓$(idx_str) ")
                else
                    print("  $(idx_str) ")
                end
                print("\e[0m ")
            else
                print("       ")
            end
        end
        println("│")
        
        # Hex codes row
        print("  │ ")
        for col in 1:cols
            i = (row - 1) * cols + col
            if i <= n
                c = ps.colors[i]
                hex = color_to_hex(c)
                print(" $(hex)")
            else
                print("       ")
            end
        end
        println("│")
    end
    
    println("  ├─────────────────────────────────────────────────────┤")
    println("  │ arrows: move  space: select  r: regenerate  q: done │")
    println("  │ +/-: grow/shrink  s: save  u: undo  f: refine       │")
    println("  ╰─────────────────────────────────────────────────────╯")
    println()
end

function color_to_hex(c::RGB)
    r = round(Int, clamp(c.r, 0, 1) * 255)
    g = round(Int, clamp(c.g, 0, 1) * 255)
    b = round(Int, clamp(c.b, 0, 1) * 255)
    "#" * string(r, base=16, pad=2) * string(g, base=16, pad=2) * string(b, base=16, pad=2) |> uppercase
end

# ═══════════════════════════════════════════════════════════════════════════
# Palette Operations (WSL Commands)
# ═══════════════════════════════════════════════════════════════════════════

# Select/deselect color at index
function palette_toggle(i::Int)
    ps = palette_state()
    if 1 <= i <= length(ps.colors)
        if i in ps.selected
            delete!(ps.selected, i)
        else
            push!(ps.selected, i)
        end
    end
    ps
end

# Move cursor
function palette_move(dir::Symbol)
    ps = palette_state()
    n = length(ps.colors)
    cols = min(n, 6)
    
    new_pos = if dir == :left
        ps.cursor > 1 ? ps.cursor - 1 : n
    elseif dir == :right
        ps.cursor < n ? ps.cursor + 1 : 1
    elseif dir == :up
        ps.cursor > cols ? ps.cursor - cols : ps.cursor + (ceil(Int, n/cols) - 1) * cols
    elseif dir == :down
        ps.cursor + cols <= n ? ps.cursor + cols : mod1(ps.cursor, cols)
    else
        ps.cursor
    end
    
    ps.cursor = clamp(new_pos, 1, n)
    ps
end

# Regenerate palette with new seed
function palette_regenerate(; seed::Int=rand(1:99999))
    ps = palette_state()
    push!(ps.history, copy(ps.colors))  # Save for undo
    
    xf_seed!(seed)
    ps.colors = [next_color(current_colorspace()) for _ in 1:length(ps.colors)]
    ps.seed = UInt64(seed)
    ps.selected = Set{Int}()
    ps
end

# Grow palette (add more colors)
function palette_grow(n::Int=3)
    ps = palette_state()
    push!(ps.history, copy(ps.colors))
    
    for _ in 1:n
        push!(ps.colors, next_color(current_colorspace()))
    end
    ps
end

# Shrink palette (remove unselected)
function palette_shrink()
    ps = palette_state()
    if !isempty(ps.selected)
        push!(ps.history, copy(ps.colors))
        ps.colors = [ps.colors[i] for i in sort(collect(ps.selected))]
        ps.selected = Set{Int}()
        ps.cursor = 1
    end
    ps
end

# Refine: generate variations of selected colors
function palette_refine(; variation::Float64=0.15)
    ps = palette_state()
    if isempty(ps.selected)
        return ps
    end
    
    push!(ps.history, copy(ps.colors))
    
    new_colors = RGB{Float64}[]
    for i in ps.selected
        base = ps.colors[i]
        push!(new_colors, base)
        
        # Generate variations in LCH space
        lch = convert(LCHab, base)
        for _ in 1:2
            rng = xf_split()
            # Perturb L, C, H
            new_l = clamp(lch.l + (rand(rng) - 0.5) * 20 * variation, 0, 100)
            new_c = clamp(lch.c + (rand(rng) - 0.5) * 30 * variation, 0, 150)
            new_h = mod(lch.h + (rand(rng) - 0.5) * 60 * variation, 360)
            
            push!(new_colors, convert(RGB{Float64}, LCHab(new_l, new_c, new_h)))
        end
    end
    
    ps.colors = new_colors
    ps.selected = Set{Int}()
    ps.cursor = 1
    ps
end

# Undo last operation
function palette_undo()
    ps = palette_state()
    if !isempty(ps.history)
        ps.colors = pop!(ps.history)
        ps.selected = Set{Int}()
        ps.cursor = 1
    end
    ps
end

# Extract selected as final palette
function palette_extract()
    ps = palette_state()
    if isempty(ps.selected)
        ps.colors
    else
        [ps.colors[i] for i in sort(collect(ps.selected))]
    end
end

# ═══════════════════════════════════════════════════════════════════════════
# Pride Flag Quick Access
# ═══════════════════════════════════════════════════════════════════════════

function palette_pride(flag::Symbol)
    ps = palette_state()
    push!(ps.history, copy(ps.colors))
    ps.colors = collect(pride_flag(flag, current_colorspace()))
    ps.selected = Set{Int}()
    ps.cursor = 1
    ps
end

# ═══════════════════════════════════════════════════════════════════════════
# XF REPL Evaluation
# ═══════════════════════════════════════════════════════════════════════════

function xf_eval(input::String)
    input = strip(input)
    isempty(input) && return nothing
    
    # WSL: Palette selection commands (single chars/words)
    cmd = lowercase(input)
    
    # Navigation
    if cmd in ["h", "left", "←"]
        palette_move(:left)
        show_palette_interactive()
        return nothing
    elseif cmd in ["l", "right", "→"]
        palette_move(:right)
        show_palette_interactive()
        return nothing
    elseif cmd in ["k", "up", "↑"]
        palette_move(:up)
        show_palette_interactive()
        return nothing
    elseif cmd in ["j", "down", "↓"]
        palette_move(:down)
        show_palette_interactive()
        return nothing
    
    # Selection
    elseif cmd in [" ", "space", "select", "x"]
        palette_toggle(palette_state().cursor)
        show_palette_interactive()
        return nothing
    elseif startswith(cmd, "sel ")
        # Select by index: sel 1 3 5
        indices = parse.(Int, split(cmd)[2:end])
        for i in indices
            push!(palette_state().selected, i)
        end
        show_palette_interactive()
        return nothing
        
    # Operations
    elseif cmd in ["r", "regen", "regenerate"]
        palette_regenerate()
        show_palette_interactive()
        return nothing
    elseif startswith(cmd, "r ") || startswith(cmd, "seed ")
        seed = parse(Int, split(cmd)[2])
        palette_regenerate(seed=seed)
        show_palette_interactive()
        return nothing
    elseif cmd in ["+", "grow"]
        palette_grow()
        show_palette_interactive()
        return nothing
    elseif cmd in ["-", "shrink"]
        palette_shrink()
        show_palette_interactive()
        return nothing
    elseif cmd in ["f", "refine"]
        palette_refine()
        show_palette_interactive()
        return nothing
    elseif cmd in ["u", "undo"]
        palette_undo()
        show_palette_interactive()
        return nothing
    elseif cmd in ["c", "clear"]
        palette_state().selected = Set{Int}()
        show_palette_interactive()
        return nothing
        
    # Pride flags
    elseif startswith(cmd, "pride ")
        flag = Symbol(split(cmd)[2])
        palette_pride(flag)
        show_palette_interactive()
        return nothing
    elseif cmd == "rainbow"
        palette_pride(:rainbow)
        show_palette_interactive()
        return nothing
    elseif cmd == "trans"
        palette_pride(:trans)
        show_palette_interactive()
        return nothing
        
    # Display/export
    elseif cmd in ["p", "palette", "show"]
        show_palette_interactive()
        return nothing
    elseif cmd in ["e", "export", "done", "q"]
        colors = palette_extract()
        println("\n  Extracted $(length(colors)) colors:")
        show_palette(colors)
        return colors
    elseif cmd in ["hex", "codes"]
        for (i, c) in enumerate(palette_state().colors)
            if isempty(palette_state().selected) || i in palette_state().selected
                println("  $(color_to_hex(c))")
            end
        end
        return nothing
        
    # Color space
    elseif cmd in ["srgb", "p3", "rec2020"]
        cs = cmd == "srgb" ? SRGB() : cmd == "p3" ? DisplayP3() : Rec2020()
        CURRENT_COLORSPACE[] = cs
        println("  Color space: $(typeof(cs))")
        return cs
        
    # Help
    elseif cmd in ["?", "help"]
        xf_help()
        return nothing
        
    # New palette with size
    elseif startswith(cmd, "new ")
        n = parse(Int, split(cmd)[2])
        init_palette_state(n=n, seed=rand(1:99999))
        show_palette_interactive()
        return nothing
        
    # Lisp S-expressions (CSL)
    elseif startswith(input, "(")
        result = eval_lisp_xf(input)
        maybe_show_color(result)
        return result
        
    # Julia fallback
    else
        return eval_julia_xf(input)
    end
end

function eval_julia_xf(input::String)
    expr = Meta.parse(input)
    result = Core.eval(Main, expr)
    maybe_show_color(result)
    return result
end

function eval_lisp_xf(input::String)
    result = Core.eval(Main, lisp_eval_helper(input))
    maybe_show_color(result)
    return result
end

function maybe_show_color(result)
    if result isa RGB || result isa Color
        print("  ")
        show_color_inline(result)
        println()
    elseif result isa AbstractVector && !isempty(result) && first(result) isa Color
        print("  ")
        for c in result
            show_color_inline(c)
        end
        println()
    end
end

function show_color_inline(c::Color)
    rgb = convert(RGB, c)
    r = round(Int, clamp(rgb.r, 0, 1) * 255)
    g = round(Int, clamp(rgb.g, 0, 1) * 255)
    b = round(Int, clamp(rgb.b, 0, 1) * 255)
    print("\e[48;2;$(r);$(g);$(b)m  \e[0m")
end

# ═══════════════════════════════════════════════════════════════════════════
# Help
# ═══════════════════════════════════════════════════════════════════════════

function xf_help()
    println("""
  ╔═══════════════════════════════════════════════════════════════════════════╗
  ║  XF.jl — Xenofeminist Color Interface                                     ║
  ║  "If nature is unjust, change nature!" — Laboria Cuboniks                 ║
  ╠═══════════════════════════════════════════════════════════════════════════╣
  ║  PALETTE NAVIGATION (WSL)                                                 ║
  ║    h/j/k/l or ←↓↑→    Move cursor                                         ║
  ║    space or x         Toggle selection at cursor                          ║
  ║    sel 1 3 5          Select indices 1, 3, 5                              ║
  ║    c                  Clear all selections                                ║
  ╠═══════════════════════════════════════════════════════════════════════════╣
  ║  PALETTE OPERATIONS                                                       ║
  ║    r / regen          Regenerate with random seed                         ║
  ║    r 42 / seed 42     Regenerate with specific seed                       ║
  ║    new 16             New palette with 16 colors                          ║
  ║    + / grow           Add 3 more colors                                   ║
  ║    - / shrink         Keep only selected colors                           ║
  ║    f / refine         Generate variations of selected                     ║
  ║    u / undo           Undo last operation                                 ║
  ╠═══════════════════════════════════════════════════════════════════════════╣
  ║  PRIDE FLAGS                                                              ║
  ║    rainbow            Rainbow flag palette                                ║
  ║    trans              Trans flag palette                                  ║
  ║    pride <flag>       Any flag: bi, nb, pan, ace, lesbian, progress       ║
  ╠═══════════════════════════════════════════════════════════════════════════╣
  ║  EXPORT                                                                   ║
  ║    p / show           Display current palette                             ║
  ║    e / export / q     Extract selected (or all) colors                    ║
  ║    hex                Print hex codes                                     ║
  ╠═══════════════════════════════════════════════════════════════════════════╣
  ║  COLOR SPACES                                                             ║
  ║    srgb / p3 / rec2020    Set color space                                 ║
  ╠═══════════════════════════════════════════════════════════════════════════╣
  ║  S-EXPRESSIONS (CSL — Lisp syntax)                                        ║
  ║    (xf-seed 42)           Set deterministic seed                          ║
  ║    (xf-next)              Next color                                      ║
  ║    (xf-palette 6)         6 distinct colors                               ║
  ║    (xf-at 1 10 100)       Colors at indices                               ║
  ╚═══════════════════════════════════════════════════════════════════════════╝
""")
end

# ═══════════════════════════════════════════════════════════════════════════
# REPL Initialization
# ═══════════════════════════════════════════════════════════════════════════

function init_xf_repl(; start_key::String = "`", sticky::Bool = true)
    # Initialize palette state
    init_palette_state()
    
    ReplMaker.initrepl(
        xf_eval,
        repl = Base.active_repl,
        prompt_text = xf_prompt,
        prompt_color = :nothing,
        start_key = start_key,
        sticky_mode = sticky,
        mode_name = "XF"
    )
    
    println()
    println("  ╭───────────────────────────────────────────────────╮")
    println("  │         XF.jl — Xenofeminist Colors               │")
    println("  │    Deterministic · Wide-Gamut · Fork-Safe         │")
    println("  ├───────────────────────────────────────────────────┤")
    println("  │  \"If nature is unjust, change nature!\"            │")
    println("  │              — Laboria Cuboniks, XF Manifesto     │")
    println("  ╰───────────────────────────────────────────────────╯")
    println()
    println("  Press $(start_key) to enter XF mode. Type ? for help.")
    println()
    
    show_palette_interactive()
end

export init_xf_repl, palette_state, show_palette_interactive
export palette_toggle, palette_move, palette_regenerate
export palette_grow, palette_shrink, palette_refine, palette_undo
export palette_extract, palette_pride
