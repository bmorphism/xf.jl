# Xenofeminist Manifesto

> **Xenofeminism: A Politics for Alienation**
> 
> Laboria Cuboniks, 2015

The XF Manifesto provides the theoretical foundation for XF.jl's approach to color, technology, and emancipation.

## Source & Translations

The full manifesto is available at [laboriacuboniks.net](https://laboriacuboniks.net/manifesto/xenofeminism-a-politics-for-alienation/) in 17 languages:

| Language | Link |
|----------|------|
| English | [EN](https://laboriacuboniks.net/manifesto/xenofeminism-a-politics-for-alienation/) |
| Deutsch | [DE](https://laboriacuboniks.net/manifesto/xenofeminismus-eine-politik-fur-die-entfremdung/) |
| Español | [ES](https://laboriacuboniks.net/manifesto/xenofeminismo-una-politica-por-la-alienacion/) |
| Français | [FR](https://laboriacuboniks.net/manifesto/xenofeminisme-une-politique-de-lalienation/) |
| Italiano | [IT](https://laboriacuboniks.net/manifesto/xenofeminismo-una-politica-per-lalienazione/) |
| Português | [PT](https://laboriacuboniks.net/manifesto/xenofeminismo-uma-politica-pela-alienacao/) |
| Русский | [RU](https://laboriacuboniks.net/manifesto/%d0%ba%d1%81%d0%b5%d0%bd%d0%be%d1%84%d0%b5%d0%bc%d0%b8%d0%bd%d0%b8%d0%b7%d0%bc-%d0%bf%d0%be%d0%bb%d0%b8%d1%82%d0%b8%d0%ba%d0%b8-%d0%be%d1%82%d1%87%d1%83%d0%b6%d0%b4%d0%b5%d0%bd%d0%b8%d1%8f/) |
| 中文 | [ZH](https://laboriacuboniks.net/manifesto/yi-nv-quan-zhu-yi-yi-zhong-zhen-dui-yi-hua-de-zheng-zhi/) |
| فارسی | [FA](https://laboriacuboniks.net/manifesto/xf-manifesto-farsi/) |
| Ελληνικά | [GR](https://laboriacuboniks.net/manifesto/to-manifesto-toy-xenofeminismoy/) |
| Türkçe | [TR](https://laboriacuboniks.net/manifesto/zenofeminizm-yabancilasma-icin-bir-politika/) |
| Polski | [PL](https://laboriacuboniks.net/manifesto/ksenofeminizm-ku-polityce-wyobcowanej/) |
| Svenska | [SE](https://laboriacuboniks.net/manifesto/xenofeminism-en-politik-for-alienation/) |
| Dansk | [DK](https://laboriacuboniks.net/manifesto/xenofeminisme-en-politik-for-fremmedgorelse/) |
| Română | [RO](https://laboriacuboniks.net/manifesto/xenofeminism-o-politica-pentru-alienare/) |
| Slovenščina | [SI](https://laboriacuboniks.net/manifesto/ksenofeminizem-politika-za-alienacijo/) |
| Български | [BG](https://laboriacuboniks.net/manifesto/ksenofeminiza-politika-na-otchuzhdenie/) |
| Srpsko-Hrvatski | [SH](https://laboriacuboniks.net/manifesto/ksenofeministicki-manifest/) |
| Slovenčina | [SK](https://laboriacuboniks.net/manifesto/zenofeminizmus-politika-odcudzenia/) |

## Key Concepts & XF.jl Connections

### ZERO (0x00-0x04)

> "We are all alienated—but have we ever been otherwise?"

**XF.jl implementation:** The splittable RNG treats zero not as lack but as autoproduction. `xf_seed!(0)` produces an ouroboros cycle of deterministic regeneration.

```julia
xf_seed!(0)  # Zero as autoproductive origin
c1 = next_color()
xf_seed!(0)  # Return to zero
@assert next_color() == c1  # Identical: zero consumes itself
```

### INTERRUPT (0x05-0x08)

> "The excess of modesty in feminist agendas of recent decades is not 
> proportionate to the monstrous complexity of our reality."

**XF.jl implementation:** WSL (World-Specific Language) provides immediate intervention — direct commands that interrupt the palette state: `r`, `f`, `+`, `-`.

### TRAP (0x09-0x0D)

> "Nothing should be accepted as fixed, permanent, or 'given'—neither 
> material conditions nor social forms."

**XF.jl implementation:** Palette state is always mutable. Every operation can be undone (`u`), refined (`f`), or regenerated (`r`). The history stack enables reversal.

### PARITY (0x0E-0x10)

> "Let a hundred sexes bloom!"

**XF.jl implementation:** Pride palettes (`rainbow`, `trans`, `bi`, `nb`, `pan`, `ace`, `lesbian`, `progress`) are first-class citizens. Wide-gamut color spaces expand beyond naturalized sRGB.

### ADJUST (0x11-0x12)

> "The real emancipatory potential of technology remains unrealized."

**XF.jl implementation:** Color spaces are political:
- **sRGB**: Naturalized standard (constrained)
- **Display P3**: Proprietary extension (Apple)
- **Rec.2020**: Theoretical maximum requiring technological prosthesis

```julia
xf_space(:rec2020)  # Choose technological enhancement
```

### CARRY (0x13-0x17)

> "If nature is unjust, change nature!"

**XF.jl implementation:** CSL (Context-Specific Language) uses S-expressions for compositional abstraction — the same Lisp heritage that enabled early AI now serves xenofeminist color synthesis.

```lisp
(xf-seed 2077)
(xf-palette 6)
(xf-space :rec2020)
```

### OVERFLOW (0x18-0x1A)

> "We prefer to think like Lisp programmers who wish to construct 
> a new language in which the problem at hand can be immersed."

**XF.jl implementation:** The dual WSL/CSL design embodies this Lisp-programmer ethos. The palette interface is a domain-specific language for color as politics.

## Theses Mapped to XF.jl

| XF Thesis | XF.jl Feature |
|-----------|---------------|
| Alienation as generative | Fork-safe parallelism (SPI) |
| Anti-naturalism | Wide-gamut beyond human vision |
| Technomaterialism | Splittable RNG via SplittableRandoms.jl |
| Universal emancipation | Open-source, MIT licensed |
| Rationalism | Deterministic, reproducible |
| Platform construction | REPL as DSL interface |
| Gender abolition | Non-binary palette selection |
| Mesopolitics | WSL↔CSL dialectic |

## Further Reading

- [Gender Acceleration: A Blackpaper](https://theanarchistlibrary.org/library/n1x-gender-acceleration-a-blackpaper) — n1x
- [Pigeons.jl](https://pigeons.run) — Strong Parallelism Invariance
- [Comrade.jl](https://github.com/ptiede/Comrade.jl) — EHT black hole imaging

---

*"Xenofeminism indexes the desire to construct an alien future."*
