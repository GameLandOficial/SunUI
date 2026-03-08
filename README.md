<div align="center">

# ☀ SunUI v9.0 — Executor UI Library

![versão](https://img.shields.io/badge/versão-9.0.0-blueviolet?style=for-the-badge)
![status](https://img.shields.io/badge/status-estável-brightgreen?style=for-the-badge)
![lua](https://img.shields.io/badge/Luau-compatible-orange?style=for-the-badge)
![executors](https://img.shields.io/badge/Xeno%20%7C%20Fluxus%20%7C%20KRNL%20%7C%20Delta%20%7C%20Synapse-supported-blue?style=for-the-badge)

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/GameLandOficial/SunUI/main/SunUI.lua"))()
```

---

## O que há de novo na v9.0

| Categoria | Novidade |
|-----------|----------|
| **Temas** | +3 novos: Midnight, Sakura, Matrix (total: 9 temas) |
| **Hot-reload** | `SunUI:SetTheme("Midnight")` — troca tema sem recriar janela |
| **Sidebar** | Modo compacto (só ícones) — `CompactSidebar=true` ou botão `◀` |
| **Scroll de abas** | Setas `▲▼` aparecem automaticamente quando há muitas abas |
| **Scale** | `Scale="auto"` escala automática pela resolução; `Scale=0.9` manual |
| **Mobile** | `TouchEnabled` detectado, hit areas maiores, janela adaptada |
| **Animações** | Opcionais: `Animations=false` desativa tudo — padrão: ativo |
| **Partículas** | Explodem do Toggle ao ativar (se Animations=true) |
| **Shimmer** | Brilho deslizante ao salvar perfil (se Animations=true) |
| **Scanline** | Linha animada na intro (se Animations=true) |
| **Countdown** | `DestroyButton({Countdown=3})` — conta regressiva antes de confirmar |
| **Som** | `SunUI:SetNotifySounds({Success="id"})` — som por tipo de notif |
| **Favoritos** | `Sec:FavoritesList` — lista persistente de jogadores favoritos |
| **Filtro JoinLeave** | `Filter=fn` ou `Filter="padrão"` no StartJoinLeaveNotifier |
| **WatchFlag** | `SunUI:WatchFlag("flag", fn)` — escuta flag específica |
| **ExportToFile** | `SunUI:ExportToFile("backup.json")` — salva JSON via executor |
| **TimePicker** | `Sec:TimePicker` — agenda callback para horário específico |
| **ImagePreview** | `Sec:ImagePreview` — imagem por AssetId dentro de um card |
| **AvatarCard** | `Sec:AvatarCard` — card de jogador com avatar + stats + botões |
| **Group** | `Tab:Group("Nome")` — conjunto colapsável de seções numa aba |

---

## Início rápido

```lua
local SunUI = loadstring(game:HttpGet("URL_RAW_DO_GITHUB"))()

local Win = SunUI:CreateWindow({
    Title        = "Meu Hub",
    Subtitle     = "v1.0",
    Theme        = "Dark",         -- Dark | Amethyst | Crimson | Neon
                                   -- Emerald | Light | Midnight | Sakura | Matrix
    AccentColor  = Color3.fromRGB(99,102,241),
    RainbowBorder= false,
    ToggleKey    = Enum.KeyCode.RightShift,
    Intro        = true,
    ConfigFile   = "MeuHub_Config",
    DiscordUrl   = "https://discord.gg/xxx",
    NotifyPosition = "BotRight",   -- TopLeft | TopRight | BotLeft | BotRight

    -- v9: opções novas
    CompactSidebar = false,        -- sidebar só com ícones
    Animations     = true,         -- partículas, shimmer, scanline, etc.
    Scale          = "auto",       -- "auto" | número (ex: 0.9) | nil = padrão

    KeySystem = {
        Title   = "Verificação",
        Sub     = "Insira sua key",
        Key     = { "SUNUI-FREE-2025" },
        -- Tiers: Key = { Free={"k1"}, VIP={"k2"} }
        MaxAttempts = 3,
        LockTime    = 5,
    },
})

local Tab = Win:Tab("Combat", "⚔", 3)   -- nome, ícone, badge (opcional)
local Sec = Tab:Section("Aimbot")

Sec:Toggle({
    Name     = "Ativar Aimbot",
    Default  = false,
    Flag     = "AimbotOn",
    Callback = function(v) print("Aimbot:", v) end,
})
```

---

## Temas disponíveis (v9)

```lua
-- Escuro
Win:SetTheme("Dark")       -- padrão violeta
Win:SetTheme("Amethyst")   -- roxo-escuro
Win:SetTheme("Crimson")    -- vermelho
Win:SetTheme("Neon")       -- azul-ciano
Win:SetTheme("Emerald")    -- verde
Win:SetTheme("Midnight")   -- azul GitHub [NOVO v9]
Win:SetTheme("Sakura")     -- rosa [NOVO v9]
Win:SetTheme("Matrix")     -- verde Matrix [NOVO v9]

-- Claro
Win:SetTheme("Light")
```

---

## API — CreateWindow

| Opção | Tipo | Padrão | Descrição |
|-------|------|--------|-----------|
| `Title` | string | "SunUI" | Título da janela |
| `Subtitle` | string | "" | Subtítulo |
| `Version` | string | nil | Versão exibida |
| `Theme` | string / table | "Dark" | Nome do tema ou tabela customizada |
| `AccentColor` | Color3 | — | Cor accent custom |
| `AccentColor2` | Color3 | — | Segunda accent (gradiente) |
| `RainbowBorder` | bool | false | Borda rainbow animada |
| `ToggleKey` | KeyCode | RightShift | Tecla para mostrar/ocultar |
| `Width` / `Height` | number | 720 / 500 | Tamanho inicial |
| `Intro` | bool | true | Animação de intro |
| `ConfigFile` | string | "SunUI_Config" | Nome do arquivo de config |
| `DiscordUrl` | string | nil | Link Discord (botão na sidebar) |
| `NotifyPosition` | string | "BotRight" | Posição das notificações |
| `KeySystem` | table | nil | Config do key system |
| **`CompactSidebar`** | bool | false | Sidebar só com ícones `[v9]` |
| **`Animations`** | bool | true | Partículas, shimmer, scanline `[v9]` |
| **`Scale`** | "auto" / number | nil | Escala automática ou manual `[v9]` |

---

## API — Win (janela)

```lua
Win:Tab(name, icon, badge?)          -- cria aba
Win:Notify({...})                    -- notificação
Win:Toast(msg, duration?)            -- toast mini
Win:Debug(true/false)                -- overlay de debug
Win:Export()                         -- retorna cópia dos Flags
Win:ExportToFile(filename?)          -- salva JSON [v9]
Win:SetTheme(name)                   -- hot-reload tema [v9]
Win:WatchFlag(key, fn)               -- escuta flag [v9]
Win:UnwatchFlag(key)                 -- remove escuta [v9]
Win:SetNotifySounds({...})           -- sons por tipo [v9]
Win:SetCompact(bool)                 -- toggle sidebar compacta [v9]
Win:SetTitle(text)
Win:FocusTab(name)
Win:DisableTab(name)
Win:EnableTab(name)
Win:EnableAutoSave()
Win:Watermark({Text, Position?})
Win:StatsWidget({Position?})
Win:EnableCursorTrail({Color?, Size?, Life?})
Win:DisableCursorTrail()
Win:StartJoinLeaveNotifier(opts)
Win:StopJoinLeaveNotifier()
Win:SetNotifyPosition(pos)
```

---

## API — SunUI (global)

```lua
SunUI.Flags["NomeFlag"]             -- lê flag direto
SunUI:SetFlag(key, value)           -- define flag + dispara OnFlagChanged e WatchFlag
SunUI:GetFlag(key)                  -- lê flag
SunUI:WatchFlag(key, fn)            -- [v9] escuta mudança de uma flag específica
SunUI:UnwatchFlag(key)              -- [v9] remove escutas de uma flag
SunUI.OnFlagChanged = function(k,v) -- callback global de flag
SunUI:SetTheme(name)                -- [v9] hot-reload de tema
SunUI:SetAccentColor(c1, c2?, rainbow?)
SunUI:Export()                      -- retorna cópia dos Flags
SunUI:ExportToFile(filename?)       -- [v9] salva JSON via writefile
SunUI:SetNotifySounds({             -- [v9] sons por tipo
    Info    = "soundId",
    Success = "soundId",
    Warning = "soundId",
    Error   = "soundId",
    ["*"]   = "soundId",            -- som padrão para todos
})
SunUI:Notify({Title, Message, Duration?, Type?, Persistent?})
SunUI:Toast(msg, duration?)
SunUI:Debug(enable)
SunUI:SaveConfig() / SunUI:LoadConfig()
SunUI:SaveProfile(name) / SunUI:LoadProfile(name)
SunUI.Ranks = { [userId] = "👑 Owner" }
SunUI._joinHistory                  -- array de eventos join/leave
SunUI._joinFavorites                -- {[userId]=true}
SunUI:AddJoinFavorite(userIdOrName)
SunUI:RemoveJoinFavorite(userIdOrName)
SunUI:GetJoinHistory()
SunUI:CreatePlayerCountHUD({Position?})
```

---

## API — Tab

```lua
local Tab = Win:Tab("Nome", "⚔", badge?)

Tab:Section("NomeDaSeção")    -- cria seção normal → retorna Sec
Tab:Group("NomeDoGrupo", open?) -- [v9] grupo colapsável → retorna GObj com :Section()
Tab:SetBadge(n)               -- atualiza badge da aba
```

### Tab:Group — Exemplo

```lua
local G = Tab:Group("Configurações Gerais", true)
local S1 = G:Section("Básico")
S1:Label({Text="Use Tab:Section() para seções completas dentro do grupo."})
S1:Separator()
-- Para componentes completos (Toggle, Slider, etc.), use Tab:Section() normal
-- O Group apenas agrupa visualmente seções num bloco colapsável
```

---

## API — Sec (seção)

### Controles

```lua
Sec:Toggle({Name, Desc?, Default, Flag, Tooltip?, Callback})
    → {Set(v), Get(), Toggle(), AddDep(el, inv?)}

Sec:Slider({Name, Desc?, Min, Max, Default, Step?, Suffix?, Flag, Tooltip?, Callback})
    → {Set(v), Get()}

Sec:Button({Name, Desc?, Icon?, Tooltip?, Cooldown?, Confirm?, ConfirmText?, Callback})

Sec:Dropdown({Name, Options, Default?, Multi?, Flag, Tooltip?, Callback})
    → {Set(v), Get(), Refresh(newOpts)}

Sec:PlayerDropdown({Name, Multi?, IncludeLocal?, AutoUpdate?, Flag, Tooltip?, Callback})
    → {Get(), GetName(), Clear(), Refresh()}

Sec:Keybind({Name, Default?, AllowNone?, Mode?, Flag, Tooltip?, OnPress?})
    → {Get(), Set(key), Clear()}

Sec:TextBox({Name, Placeholder?, Default?, Flag, Numeric?, Tooltip?, OnChanged?, OnSubmit?})
    → {Set(v), Get()}

Sec:ColorPicker({Name, Default?, Flag, Tooltip?, Callback})
    → {Set(c3), Get()}

Sec:ProgressBar({Name, Min?, Max?, Default?, Suffix?})
    → {Set(v), Get()}
```

### Exibição

```lua
Sec:Label({Text, Color?, Bold?, Icon?})           → {Set(txt), SetColor(c)}
Sec:Separator(text?)
Sec:BannerAlert({Text, Type?, Dismissible?})      -- Info|Warning|Error|Success
Sec:CodeBlock({Name?, Code, Language?, MaxLines?}) → {SetCode(code)}
```

### Input composto

```lua
Sec:ChipSelector({Name, Options, Multi?, Default?, Flag, Callback})   → {Get(), Set()}
Sec:StarRating({Name, Max?, Default?, Flag, Callback})                 → {Get(), Set()}
Sec:NumberInput({Name, Min?, Max?, Default?, Step?, Flag, Callback})   → {Get(), Set()}
Sec:RangeSlider({Name, Min, Max, DefaultLow?, DefaultHigh?, Step?, Suffix?, Flag, Callback})
    → {Get() → (low,high), Set(l,h)}
Sec:TagInput({Name, Placeholder?, MaxTags?, Flag, Callback})           → {Get(), Add(t), Clear()}
```

### Tabelas / Listas

```lua
Sec:Table({Name?, Columns, Rows?, Striped?})   → {AddRow(r), SetRows(t), ClearRows()}
Sec:LogViewer({Name?, MaxLines?, Filter?})
    → {Log(msg,level?), Info(m), Warn(m), Error(m), Ok(m), Debug(m), Clear()}
Sec:Accordion({Title, Content?, Open?})         → {Open(), Close(), IsOpen()}
```

### v9: Novos componentes

```lua
-- TimePicker — agenda callback para um horário
Sec:TimePicker({Name, Hour, Minute, Repeat?, Flag, Tooltip?, Callback})
    → {Get(), Set(h,m), Activate(), Deactivate()}
-- Exemplo:
Sec:TimePicker({
    Name="Auto Collect", Hour=9, Minute=30, Repeat=true,
    Callback=function(t) print("São "..t.Hour..":"..t.Minute) end,
})

-- ImagePreview — imagem por AssetId
Sec:ImagePreview({Name?, AssetId?, Caption?, Height?, Clickable?, OnClick?})
    → {SetImage(id), SetCaption(txt)}

-- AvatarCard — card de jogador
Sec:AvatarCard({
    Name?,
    UserId?,    -- ou Username?
    Stats = { {Label="Kills", Value="42"}, ... },
    Buttons = { {Text="Teleport", Callback=function(userId, name) end}, ... },
})
→ {Refresh(newUserId)}

-- FavoritesList — lista de jogadores favoritos persistida
Sec:FavoritesList({Name?, MaxFavorites?, Flag?, OnSelect?})
    → {Get(), Add(name), Remove(name), Clear()}
```

### Hub

```lua
Sec:ToggleSlider({...})        -- Toggle + Slider combinados
Sec:AccentPicker({Name?, Tooltip?})
Sec:ProfileManager()
Sec:BackgroundManager()
Sec:NotifyPositionPicker({Name?})
Sec:DestroyButton({Name?, Desc?, ConfirmText?, Countdown?})
    -- Countdown=3 → conta regressiva de 3s antes de habilitar "Confirmar" [v9]
Sec:JoinLeaveConfig({Name?})
Sec:ThirdPersonCamera({DefaultDist?, MaxDist?, DefaultSens?, DefaultFOV?, DefaultShoulder?, LockY?, OnToggle?})
    → {SetEnabled(v), SetDistance(n), SetSensitivity(n), SetFOV(n), SetShoulder(-1|0|1)}
```

---

## JoinLeave Notifier com Filtro (v9)

```lua
Win:StartJoinLeaveNotifier({
    -- Filtro opcional:
    Filter = function(player)          -- função: retorna true para notificar
        return player.Name:sub(1,1)~="#"   -- ignora guests
    end,
    -- ou padrão Lua:
    -- Filter = "^Admin",              -- só jogadores cujo nome começa com "Admin"

    RejoinWindow = 60,   -- segundos para considerar como rejoin
    OnJoin  = function(player, isFriend, isFav, isRejoin) end,
    OnLeave = function(player, isFriend, isFav) end,
})
```

---

## Sons de Notificação (v9)

```lua
SunUI:SetNotifySounds({
    Info    = "6518811702",
    Success = "9120386436",
    Warning = "5997765300",
    Error   = "1375393548",
    ["*"]   = "123456789",   -- som padrão se tipo não tiver som específico
})
-- Ou via Win:
Win:SetNotifySounds({ Success = "id" })
```

---

## WatchFlag (v9)

```lua
-- Escuta uma flag específica (mais eficiente que OnFlagChanged para muitas flags)
SunUI:WatchFlag("AimbotOn", function(value)
    print("Aimbot mudou para:", value)
end)

-- Remove todos os watchers de uma flag
SunUI:UnwatchFlag("AimbotOn")

-- OnFlagChanged ainda funciona (global, para todas as flags)
SunUI.OnFlagChanged = function(key, value)
    print(key, "=", value)
end
```

---

## Animações Opcionais (v9)

```lua
-- Desativa todas as animações (partículas, shimmer, scanline, countdown)
local Win = SunUI:CreateWindow({
    Animations = false,  -- padrão: true
    ...
})

-- Com Animations=true (padrão):
-- • Toggle ativado: partículas explodem do card
-- • Salvar perfil: shimmer desliza + multi-partículas no botão
-- • Intro: scanline desliza da tela
-- • DestroyButton com Countdown=N: conta regressiva no botão confirmar
```

---

## Scale Automático (v9)

```lua
-- Escala automática pela resolução da tela (útil para monitores 4K ou pequenos)
local Win = SunUI:CreateWindow({
    Scale = "auto",   -- calcula baseado em 1366x768 como base
    ...
})

-- Escala manual (0.5 a 2.0)
local Win = SunUI:CreateWindow({
    Scale = 0.85,
    ...
})
```

---

## Sidebar Compacta (v9)

```lua
-- Começa compacta (só ícones, sem textos)
local Win = SunUI:CreateWindow({
    CompactSidebar = true,
    ...
})

-- Ou toggle em runtime:
Win:SetCompact(true)   -- ativa compacto
Win:SetCompact(false)  -- volta ao normal
-- O botão ◀/▶ no canto inferior da sidebar também faz o toggle
```

---

## Mobile (v9)

```lua
-- SunUI detecta TouchEnabled automaticamente
-- Quando em dispositivo touch:
--   • Janela ligeiramente maior (+60 largura, +40 altura)
--   • Ripple responde a Touch além de MouseButton1
--   • Draggable e sliders funcionam com touch
-- Não precisa configurar nada — acontece automaticamente
```

---

## Organização de Abas — Boas Práticas

### Estrutura recomendada
```
├── Aba "Combat" (⚔)
│   ├── Section "Aimbot"
│   │   ├── Toggle: Ativar
│   │   ├── Slider: FOV
│   │   └── Slider: Smoothness
│   └── Section "ESP"
│       ├── Toggle: Players
│       └── ColorPicker: Cor ESP
├── Aba "Farm" (🌾)
│   └── Section "Auto Farm"
├── Aba "Misc" (⚙)
│   ├── Section "Configurações"
│   │   ├── AccentPicker
│   │   ├── ProfileManager
│   │   └── NotifyPositionPicker
│   └── Section "Hub"
│       └── DestroyButton
```

### Dicas de performance
- Use `Flag=` em todos os controles para salvar/carregar config automaticamente
- `Win:EnableAutoSave()` carrega config salva ao iniciar
- Use `Tab:Group()` para agrupar seções relacionadas e reduzir scroll
- Não crie mais de 50 elementos por aba — separe em abas
- Use `SunUI:WatchFlag()` ao invés de `OnFlagChanged` quando possível (mais eficiente)
- `Sec:Accordion` esconde seções raramente usadas, mantendo a aba limpa
- Prefira `Sec:LogViewer` a `print()` para debug in-game

---

## Compatibilidade com Executors

| Executor | Status |
|----------|--------|
| Xeno v3+ | ✅ (usa `gethui()`) |
| Fluxus | ✅ |
| Delta | ✅ |
| Synapse X | ✅ (usa `cloneref`) |
| KRNL | ✅ |
| Script-Ware | ✅ |
| Outros | ✅ (fallback PlayerGui) |

---

## Changelog

### v9.0
- 3 temas novos: Midnight, Sakura, Matrix
- Hot-reload via `SunUI:SetTheme()` e `Win:SetTheme()` (sem recriar janela)
- Sidebar compacta `CompactSidebar=true` + botão ◀/▶ + `Win:SetCompact()`
- Scroll automático de abas com setas ▲▼ quando há overflow
- `Scale="auto"` e `Scale=number` — redimensionamento automático por tela
- Suporte a mobile (TouchEnabled detectado, janela/touch adaptados)
- `Animations=true/false` — partículas no toggle, shimmer no perfil, scanline no intro, countdown no DestroyButton
- Sons de notificação: `SunUI:SetNotifySounds({Success="id", ...})`
- `SunUI:WatchFlag(key, fn)` e `SunUI:UnwatchFlag(key)`
- `SunUI:ExportToFile(filename)` — salva snapshot JSON
- `Sec:TimePicker` — agenda callbacks por horário
- `Sec:ImagePreview` — imagem por AssetId
- `Sec:AvatarCard` — card de jogador com stats e botões
- `Sec:FavoritesList` — lista persistente de favoritos
- `Tab:Group` — conjunto colapsável de seções
- Filtro (`Filter=fn` ou `Filter="padrão"`) no StartJoinLeaveNotifier
- ThemeRefs — frames registrados atualizam automaticamente no hot-reload
- `Win:SetCompact()`, `Win:SetTheme()`, `Win:WatchFlag()`, `Win:ExportToFile()`, `Win:SetNotifySounds()`

### v8.0
- 10 novos componentes: Table, ChipSelector, StarRating, NumberInput, RangeSlider, CodeBlock, BannerAlert, TagInput, LogViewer, Accordion
- Key System com tiers e contador visual
- Keybind com AllowNone + ESC para limpar
- Notificações: fila inteligente (limite 4), agrupamento, persistente
- Join/Leave: histórico, favoritos, rejoin, contador HUD
- Third Person: shoulder cam, FOV configurável
- Win:Toast, Win:Debug, Win:Export, Win:SetTitle, Win:FocusTab, DisableTab, EnableTab
- SunUI.OnFlagChanged, SunUI:Export, SunUI:Debug, SunUI:Toast

### v7.0
- ThirdPersonCamera nativa
- JoinLeave Notifier com prioridade de amigos
- Mouse unlock/lock automático no toggle
- Watermark posicionado abaixo-esquerda
- Melhorias visuais gerais

---

*SunUI v9.0 — feito com ☀ por Sun*
