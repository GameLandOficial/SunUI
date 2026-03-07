<div align="center">

# ☀ SunUI
### A melhor biblioteca de UI para Roblox Executors

![versão](https://img.shields.io/badge/versão-6.0.0-blueviolet?style=for-the-badge)
![status](https://img.shields.io/badge/status-estável-brightgreen?style=for-the-badge)
![lua](https://img.shields.io/badge/Luau-compatible-orange?style=for-the-badge)
![executors](https://img.shields.io/badge/Xeno%20%7C%20Fluxus%20%7C%20KRNL%20%7C%20Synapse-supported-blue?style=for-the-badge)

**Design moderno • 6 temas • 100% Bug-Free • Universal**

</div>

---

## 📦 Instalação

```lua
local SunUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/GameLandOficial/SunUI/refs/heads/main/SunUI.lua"
))()
```

> **Como hospedar:** Suba `SunUI.lua` no GitHub → abra o arquivo → clique em **Raw** → copie a URL.

**Executors suportados:** Xeno ✅ · Fluxus ✅ · Delta ✅ · Synapse X ✅ · KRNL ✅ · Wave ✅ · e mais

---

## 🚀 Exemplo completo

```lua
local SunUI = loadstring(game:HttpGet("SEU_RAW_URL"))()

local Win = SunUI:CreateWindow({
    Title          = "Meu Hub",
    Subtitle       = "v1.0 — Feito com SunUI",
    Version        = "v1.0",
    Theme          = "Dark",       -- Dark | Amethyst | Crimson | Neon | Emerald | Light
    AccentColor    = Color3.fromRGB(99, 102, 241),
    RainbowBorder  = false,
    ToggleKey      = Enum.KeyCode.RightShift,
    Intro          = true,
    ConfigFile     = "MeuHub",
    DiscordUrl     = "https://discord.gg/xxx",
    NotifyPosition = "BotRight",   -- TopLeft | TopRight | BotLeft | BotRight
    KeySystem      = {
        Title     = "Key System",
        Sub       = "Entre no Discord para obter a key",
        Key       = "MINHAKEY123",     -- string ou tabela: {"KEY1", "KEY2"}
        Note      = "discord.gg/xxx",
        GetKeyUrl = "https://...",     -- botão "Get Key" no popup (opcional)
    },
})

local Tab = Win:Tab("Combat", "⚔")
local Sec = Tab:Section("Aimbot")

local togObj = Sec:Toggle({
    Name     = "Ativar Aimbot",
    Desc     = "Liga/desliga o aimbot",
    Default  = false,
    Flag     = "AimbotOn",
    Tooltip  = "Pressione RightShift para abrir/fechar o menu",
    Callback = function(state)
        print("Aimbot:", state)
    end,
})

local sldObj = Sec:Slider({
    Name     = "Smoothness",
    Min      = 0, Max = 100, Default = 50,
    Suffix   = "%",
    Flag     = "AimbotSmooth",
    Callback = function(val) print("Smooth:", val) end,
})

-- Desabilita o slider quando o toggle está desligado:
togObj:AddDep(sldObj)

-- Ler valores a qualquer momento:
print(SunUI.Flags["AimbotOn"])
print(SunUI.Flags["AimbotSmooth"])
```

---

## 🎨 Temas

| Nome | Cor principal | Fundo |
|---|---|---|
| `Dark` | Índigo | Preto azulado (padrão) |
| `Amethyst` | Roxo/Rosa | Escuro profundo |
| `Crimson` | Vermelho | Escuro avermelhado |
| `Neon` | Ciano | Azul marinho |
| `Emerald` | Verde | Escuro esverdeado |
| `Light` | Índigo | Branco/Claro |

**Tema 100% customizado:**
```lua
Theme = {
    Name        = "Custom",
    Bg          = Color3.fromRGB(10,10,15),
    Surface     = Color3.fromRGB(18,18,28),
    SurfaceHigh = Color3.fromRGB(24,24,38),
    SurfaceHover= Color3.fromRGB(32,32,50),
    Sidebar     = Color3.fromRGB(12,12,20),
    TitleBar    = Color3.fromRGB(8,8,14),
    Accent      = Color3.fromRGB(255,100,50),
    AccentB     = Color3.fromRGB(255,150,80),
    AccentHover = Color3.fromRGB(230,80,30),
    AccentDim   = Color3.fromRGB(90,35,15),
    Border      = Color3.fromRGB(40,40,60),
    BorderBright= Color3.fromRGB(60,60,85),
    Text        = Color3.fromRGB(245,245,255),
    TextSub     = Color3.fromRGB(150,150,185),
    TextMuted   = Color3.fromRGB(75,75,110),
    TextAccent  = Color3.fromRGB(255,170,120),
    Good        = Color3.fromRGB(52,211,153),
    Warn        = Color3.fromRGB(251,191,36),
    Bad         = Color3.fromRGB(239,68,68),
    ToggleOff   = Color3.fromRGB(40,40,60),
    TrackBg     = Color3.fromRGB(28,28,45),
    InputBg     = Color3.fromRGB(12,12,20),
    NotifyBg    = Color3.fromRGB(16,16,26),
    Scrollbar   = Color3.fromRGB(70,70,120),
}
```

---

## 📋 API Completa

### `SunUI:CreateWindow(opts)` → `Win`

| Campo | Tipo | Padrão | Descrição |
|---|---|---|---|
| `Title` | string | `"SunUI"` | Título da janela |
| `Subtitle` | string | `""` | Subtítulo abaixo do título |
| `Version` | string | nil | Badge de versão no canto |
| `Theme` | string/table | `"Dark"` | Nome do tema ou tabela customizada |
| `AccentColor` | Color3 | nil | Sobrescreve a cor de accent do tema |
| `AccentColor2` | Color3 | nil | Segunda cor do gradient |
| `RainbowBorder` | bool | `false` | Borda RGB animada |
| `ToggleKey` | KeyCode | `RightShift` | Tecla para mostrar/esconder |
| `Intro` | bool | `true` | Animação de entrada |
| `ConfigFile` | string | `"SunUI_Config"` | Nome do arquivo `.json` de save |
| `DiscordUrl` | string | nil | Link do Discord (botão na sidebar) |
| `NotifyPosition` | string | `"BotRight"` | Posição das notificações |
| `KeySystem` | table | nil | Ver seção Key System |
| `Width` / `Height` | number | `720` / `500` | Tamanho inicial da janela |

---

### `Win:Tab(name, icon, badge?)` → `Tab`

```lua
local Tab = Win:Tab("Configurações", "⚙")

-- Badge numérico no ícone da aba (opcional):
local Tab2 = Win:Tab("Notificações", "🔔", 3)
Tab2:SetBadge(5)   -- atualiza o número depois
Tab2:SetBadge(0)   -- esconde o badge
```

---

### `Tab:Section(name)` → `Sec`

Agrupa elementos visualmente com separador e título.

```lua
local Sec = Tab:Section("Aimbot")
```

---

## 🧩 Componentes

### Toggle
```lua
local tog = Sec:Toggle({
    Name     = "Nome",
    Desc     = "Descrição opcional",
    Default  = false,
    Flag     = "MinhaFlag",
    Tooltip  = "Texto do tooltip (aparece após 0.5s de hover)",
    Callback = function(state) end,
})

tog:Set(true)
tog:Get()                          -- bool atual
tog:Toggle()                       -- inverte
tog:AddDep(outroElemento)          -- esconde/mostra dependendo do toggle
tog:AddDep(outroElemento, true)    -- inverted: esconde quando ativo
```

### Slider
```lua
local sld = Sec:Slider({
    Name     = "Velocidade",
    Min      = 0, Max = 100, Default = 50,
    Step     = 1,
    Suffix   = " km/h",
    Flag     = "Speed",
    Tooltip  = "...",
    Callback = function(val) end,
})

sld:Set(75)     -- valor no range: aplica normalmente
sld:Set(999)    -- fora do range: flash vermelho + shake animado ✨
sld:Get()
```

### Button
```lua
-- Normal:
Sec:Button({
    Name     = "Teleportar",
    Desc     = "Vai para o spawn",
    Icon     = "🚀",
    Tooltip  = "...",
    Cooldown = 3,      -- cooldown visual em segundos (opcional)
    Callback = function() end,
})

-- Destrutivo — popup de confirmação antes de executar: ✨
Sec:Button({
    Name        = "Deletar Dados",
    Icon        = "🗑",
    Confirm     = true,
    ConfirmText = "Isso apagará todos os seus dados. Tem certeza?",
    Callback    = function() end,
})
```

### Dropdown
```lua
local dd = Sec:Dropdown({
    Name     = "Arma",
    Options  = {"AK-47", "M4A1", "AWP"},
    Default  = "AK-47",
    Multi    = false,
    Flag     = "Arma",
    Tooltip  = "...",
    Callback = function(val) end,
})

dd:Set("M4A1")
dd:Get()
dd:Refresh({"Nova", "Lista"})
```

### PlayerDropdown ⭐ NOVO
Lista de jogadores do servidor com **foto**, **DisplayName** e **@username**.
```lua
local pd = Sec:PlayerDropdown({
    Name         = "Selecionar Player",
    Multi        = false,          -- true = selecionar vários
    IncludeLocal = true,           -- false = não mostra você mesmo
    AutoUpdate   = true,           -- atualiza quando alguém entra/sai
    Flag         = "TargetPlayer",
    Tooltip      = "...",
    Callback     = function(player)
        -- player é um objeto Player do Roblox
        print(player.Name, player.DisplayName)
    end,
})

pd:Get()        -- retorna Player (ou tabela de Players se Multi=true)
pd:GetName()    -- retorna string do nome (ou tabela de strings se Multi=true)
pd:Clear()      -- limpa a seleção
pd:Refresh()    -- força rebuild da lista manualmente
```

**Funcionalidades:**
- 🖼️ Foto do avatar (headshot) de cada jogador
- Nome em negrito + @username menor embaixo
- Anel do avatar fica na cor do accent no hover
- Busca por nome ou @username em tempo real
- Scroll automático quando há mais de 5 players
- Auto-limpa seleção se o player selecionado sair do servidor

### Keybind
```lua
local kb = Sec:Keybind({
    Name    = "Ativar ESP",
    Default = Enum.KeyCode.X,
    Mode    = "Toggle",     -- "Toggle" | "Hold"
    Flag    = "ESPKey",
    Tooltip = "...",
    OnPress = function(holding) end,
})

kb:Get()
```

### TextBox
```lua
local tb = Sec:TextBox({
    Name        = "Target",
    Placeholder = "Nome do jogador...",
    Default     = "",
    Numeric     = false,
    Flag        = "Target",
    Tooltip     = "...",
    OnChanged   = function(text) end,
    OnSubmit    = function(text) end,
})

tb:Set("Player1")
tb:Get()
```

### ColorPicker
```lua
local cp = Sec:ColorPicker({
    Name     = "Cor do ESP",
    Default  = Color3.fromRGB(255, 80, 80),
    Flag     = "ESPColor",
    Tooltip  = "...",
    Callback = function(color3) end,
})

cp:Set(Color3.fromRGB(0, 255, 0))
cp:Get()
```
Suporta: **HSV picker** visual + **Hex** (#RRGGBB) + preview **RGB** em tempo real.

### ProgressBar
```lua
local pb = Sec:ProgressBar({
    Name    = "Saúde",
    Min     = 0, Max = 100, Default = 75,
    Suffix  = "%",
})

pb:Set(50)
pb:Get()
```

### Label
```lua
local lbl = Sec:Label({
    Text  = "Versão: 1.0.0",
    Color = Color3.fromRGB(150, 150, 200),
    Bold  = false,
    Icon  = "ℹ",
})

lbl:Set("Versão: 2.0.0")
lbl:SetColor(Color3.fromRGB(255, 200, 0))

Sec:Label("Texto simples")   -- atalho
```

### Separator
```lua
Sec:Separator()
Sec:Separator("Avançado")
```

### ToggleSlider
```lua
local tog, sld = Sec:ToggleSlider({
    Name      = "Speed Hack",
    TDefault  = false,  TFlag = "SpeedOn",  TCallback = function(s) end,
    SName     = "Multiplicador",
    Min = 1,  Max = 10, SDefault = 2,
    Suffix    = "x",    SFlag = "SpeedVal",  SCallback = function(v) end,
})
```

### AccentPicker
```lua
Sec:AccentPicker({
    Name    = "Cor do Hub",
    Tooltip = "...",
})
-- 8 presets + botão 🌈 RGB animado
```

### BackgroundManager
```lua
Sec:BackgroundManager()
-- Asset ID numérico, lista de até 12 salvos (SunUI_Backgrounds.json)
-- Botões: Aplicar, Remover atual, Deletar da lista
-- Corrigido na v6: imagem agora aplica corretamente na janela
```

### ProfileManager
```lua
Sec:ProfileManager()
-- Salva/carrega configs nomeadas (SunUI_Profile_NOME.json)
```

### NotifyPositionPicker
```lua
Sec:NotifyPositionPicker({ Name = "Posição das Notificações" })
-- Botões ↖ ↗ ↙ ↘ para o usuário escolher o canto
```

### DestroyButton ⭐ NOVO v6
```lua
Sec:DestroyButton({
    Name        = "Fechar Hub",
    Desc        = "Fecha o hub permanentemente",
    ConfirmText = "Isso irá fechar o hub. Reexecute o script para reabrir.",
})
-- Popup de confirmação com Confirmar / Cancelar antes de destruir
-- Salva configs automaticamente antes de fechar
```

---

## 🔔 Notificações

```lua
SunUI:Notify({
    Title    = "Sucesso!",
    Message  = "Config salva.",
    Duration = 4,
    Type     = "Success",  -- Info | Success | Warning | Error
})

SunUI:SetNotifyPosition("TopRight")  -- TopLeft | TopRight | BotLeft | BotRight
Win:SetNotifyPosition("BotLeft")
```

---

## 💾 Config & Perfis

```lua
Win:EnableAutoSave()         -- carrega config ao abrir, salva a cada ~55s

SunUI:SaveConfig()
SunUI:LoadConfig()

SunUI:SaveProfile("PvP")
SunUI:LoadProfile("PvP")

SunUI.Flags["MinhaFlag"]
SunUI:SetFlag("MinhaFlag", true)
SunUI:GetFlag("MinhaFlag")
```

---

## 🛠️ Extras

### Watermark
```lua
local wm = Win:Watermark({ Text = "MeuHub v1.0", Position = UDim2.new(0,8,0,8) })
wm:Set("MeuHub v1.0  |  ⚡ 60 FPS")
wm:Hide()
```

### Stats Widget
```lua
local stats = Win:StatsWidget({ Position = UDim2.new(1,-120,0,8) })
-- FPS verde/amarelo/vermelho, Ping ms, Players online
stats:Hide()
```

### Cursor Trail
```lua
Win:EnableCursorTrail({ Color = Color3.fromRGB(99,102,241), Size = 6, Life = 0.4 })
Win:DisableCursorTrail()
```

### Accent em runtime
```lua
SunUI:SetAccentColor(Color3.fromRGB(239,68,68))             -- sólido
SunUI:SetAccentColor(Color3.fromRGB(99,102,241), nil, true) -- RGB animado
```

---

## 🔑 Key System

```lua
KeySystem = {
    Title     = "Key System",
    Sub       = "Entre no Discord para pegar a key",
    Key       = "MINHAKEY123",                   -- string simples
    Key       = {"KEY_FREE", "KEY_VIP"},         -- ou múltiplas
    Note      = "discord.gg/xxx",
    GetKeyUrl = "https://linktr.ee/seusite",     -- botão "Get Key" no popup (v6)
}
```
- Shake animado a cada tentativa errada
- Bloqueia por **2s** após 3 erros seguidos
- **Botão "Get Key"** abre link externo direto no browser do Roblox (v6)
- Janela só abre após key correta

---

## 🏗️ Comparativo

| Feature | SunUI | Rayfield | LinoriaLib | Orion |
|---|---|---|---|---|
| Temas prontos | ✅ 6 | ✅ | ❌ | ❌ |
| Tema 100% customizado | ✅ | ⚠️ parcial | ❌ | ❌ |
| Key System com shake | ✅ | ✅ | ❌ | ❌ |
| Notificações posicionáveis | ✅ 4 cantos | ❌ | ❌ | ❌ |
| Background manager | ✅ corrigido v6 | ❌ | ❌ | ❌ |
| Sistema de perfis nomeados | ✅ | ❌ | ❌ | ❌ |
| PlayerDropdown c/ avatar | ✅ | ❌ | ❌ | ❌ |
| Confirmação destrutiva | ✅ popup animado | ❌ | ❌ | ❌ |
| Dropdowns sem clipping | ✅ v6 | ❌ | ❌ | ❌ |
| Resize + duplo-clique reset | ✅ v6 | ❌ | ❌ | ❌ |
| DestroyButton | ✅ v6 | ❌ | ❌ | ❌ |
| Animação de erro no slider | ✅ | ❌ | ❌ | ❌ |
| Cursor trail | ✅ | ❌ | ❌ | ❌ |
| Stats widget integrado | ✅ | ❌ | ❌ | ❌ |
| Watermark flutuante | ✅ | ❌ | ❌ | ❌ |
| ColorPicker HSV+Hex+RGB | ✅ | ✅ | ✅ | ❌ |
| Busca global de elementos | ✅ | ✅ | ❌ | ❌ |
| Badge em abas | ✅ | ❌ | ❌ | ❌ |
| Cooldown visual em botões | ✅ | ❌ | ❌ | ❌ |
| Tooltip com delay+fade | ✅ | ⚠️ | ✅ | ❌ |
| Xeno + gethui() nativo | ✅ | ⚠️ | ⚠️ | ❌ |
| Todos callbacks em pcall | ✅ | ⚠️ | ⚠️ | ❌ |

---

## 🐛 Resolução de Problemas

**Janela não aparece:**
- Confirme que o executor suporta `game:HttpGet`
- Pressione a tecla de toggle (padrão: `RightShift`)
- SunUI tenta `gethui()` → `cloneref(CoreGui)` → `CoreGui` → `PlayerGui` nessa ordem

**Erro no F9:**
- SunUI envolve **toda** criação de instância e **todos** os callbacks em `pcall`
- Se aparecer erro, é no **seu código** dentro do callback — teste com `print(v)` primeiro

**Config não salva:**
- Executor precisa ter `writefile`/`readfile` — Xeno, Syn X, KRNL, Fluxus, Delta: ✅
- Sem filesystem: lib não crasha, config simplesmente não persiste

**Key System travado:**
- Após 3 erros há cooldown de 2s — espere e tente novamente
- A lib remove espaços automaticamente da key digitada

**PlayerDropdown não carrega avatares:**
- Normal em alguns jogos que bloqueiam ImageLabel com URLs externas
- Os nomes ainda aparecem corretamente — só a foto fica em branco

**Dropdown não atualiza:**
- Use `dd:Refresh({"Nova", "Lista"})` em vez de recriar o componente

**Dropdown ou ColorPicker atrás de outros elementos:**
- Corrigido na v6 — painéis flutuam na ScreenGui com ZIndex 750
- Se ainda ocorrer, verifique se há outro ScreenGui com ZIndex mais alto

---

## 📝 Changelog

### v6.0
- Dropdowns e PlayerDropdown flutuam acima do hub (sem clipping pelo ScrollingFrame)
- ColorPicker renderiza acima de tudo (ZIndex 750, parented to screen)
- Janela voltou ao tamanho padrão 720×500
- Resize handle: arrastar redimensiona • duplo clique reseta ao tamanho padrão
- Key System: botão "Get Key" (`GetKeyUrl`) abre link externo no browser
- `Sec:DestroyButton({...})` — fecha o hub com confirmação
- BackgroundManager: corrigido bug onde a imagem não era aplicada
- Intro: overlay cobre a tela toda sem gap no topo

### v5.5
- Arquitetura MainWrap + Main (borda não clipada pelo conteúdo)
- Sombra com referência local para hide/show correto no toggle
- `_guiVisible` boolean — toggle key funciona de qualquer estado
- Tema aplicado em tempo real sem reiniciar a janela
- Watermark/Stats com `Hide()`/`Show()` sem destruir
- DisplayName + sistema de Ranks na sidebar
- Versão exibida na titlebar

### v5.4
- PlayerDropdown com avatar, DisplayName e @username
- `Sec:Separator(texto?)` com e sem título
- `Sec:ToggleSlider({...})` combinado
- Animação de erro no Slider (flash vermelho + shake)

### v5.3
- Key System com shake em key errada
- Notificações posicionáveis nos 4 cantos
- BackgroundManager (Asset ID / URL)
- ProfileManager, AccentPicker, CursorTrail
- Stats Widget (FPS/Ping/Players)

---

## 📄 Licença

MIT — livre para usar, modificar e distribuir.  
Créditos apreciados mas não obrigatórios. ☀
