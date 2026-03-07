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

## 💡 Roadmap & Ideias — Lista Completa

> Lista gigante de tudo que pode ser adicionado à SunUI. Usa como referência para futuras versões!

---

### 🧩 Novos Componentes — Lista Expandida

| Componente | Descrição detalhada |
|---|---|
| `Sec:RadioGroup({Options, Default})` | Grupo de botões exclusivos estilo radio — só um selecionável, com animação de "bolinha" deslizando |
| `Sec:NumberInput({Min, Max, Step})` | Campo numérico com botões **−** e **+** nas laterais + digitar direto, com clamp automático |
| `Sec:TagInput({Placeholder})` | Input que cria chips/tags clicáveis ao pressionar Enter — útil para listas de nomes |
| `Sec:Table({Headers, Rows})` | Tabela leve com linhas zebradas, scroll e colunas responsivas |
| `Sec:Accordion({Title, Content})` | Bloco colapsável com animação — agrupa configurações avançadas sem poluir a tela |
| `Sec:Changelog({entries})` | Lista de mudanças formatada: badge de versão + data + texto por linha |
| `Sec:TimePicker({})` | Seletor de hora/minuto estilo "tambor giratório" para agendar ações |
| `Sec:DatePicker({})` | Mini calendário para selecionar data — útil para eventos ou expiração de key |
| `Sec:RangeSlider({Min, Max})` | Slider com dois handles: define um intervalo mínimo e máximo |
| `Sec:Grid({Columns, Items})` | Layout em grade — exibe botões/toggles em N colunas ao invés de lista |
| `Sec:HexInput({Default})` | Input especializado para cores em hex com preview ao vivo e validação |
| `Sec:VectorInput({Axes})` | 2 ou 3 campos numéricos juntos para X/Y/Z — útil para posições e CFrame |
| `Sec:FileInput({Extensions})` | Input de nome de arquivo com sugestão de arquivos existentes no writefile |
| `Sec:Rating({Max})` | Componente de avaliação com estrelas clicáveis (ex: 1–5 estrelas) |
| `Sec:Gauge({Min, Max})` | Medidor semicircular estilo velocímetro — mais visual que progress bar |
| `Sec:Steps({Steps, Current})` | Indicador de progresso em etapas estilo "wizard" (passo 1/3, 2/3…) |
| `Sec:DualToggle({OptionA, OptionB})` | Toggle binário entre duas opções nomeadas (ex: "Amigos / Todos") |
| `Sec:PasteButton({Flag})` | Lê da área de transferência e coloca no flag — útil para colar IDs |
| `Sec:Countdown({Seconds})` | Timer regressivo visual com barra e número — executa callback ao zerar |
| `Sec:TreeView({data})` | Visualização de árvore colapsável para dados hierárquicos |

---

### 🎮 Gameplay — Lista Expandida

| Componente | Descrição detalhada |
|---|---|
| `Sec:ESP({})` | ESP completo: nomes, caixas, linhas tracers, distância, saúde, time colors — tudo configurável |
| `Sec:AimAssist({})` | Aimbot com FOV circle desenhável, smoothness, bone target, team check, fov slider |
| `Sec:Hitbox({})` | Aumenta hitbox local com slider de tamanho e visualização em wireframe opcional |
| `Sec:SpeedHack({})` | Toggle + slider de velocidade, reset automático ao morrer/teleportar |
| `Sec:NoClip({})` | Noclip com detecção de reset ao ser teleportado pelo servidor |
| `Sec:FlyHack({})` | Fly com slider de speed, teclas configuráveis de subir/descer |
| `Sec:InfJump({})` | Pulo infinito com controle de força por slider |
| `Sec:BunnyHop({})` | Auto-bhop com slider de timing |
| `Sec:AntiAFK({})` | Anti-AFK com movimento aleatório configurável |
| `Sec:AntiRagdoll({})` | Impede o personagem de ragdollar ao levar dano |
| `Sec:ChatSpy({})` | Exibe todas as mensagens de chat em painel flutuante separado |
| `Sec:FakeLag({Ping})` | Simula lag artificial para benefício em certos jogos |
| `Sec:AutoParry({})` | Detecta ataques e para automaticamente — útil para jogos de luta |
| `Sec:AutoFarm({})` | Template de auto-farm com toggle, delay configurável e zona de área |
| `Sec:ItemESP({})` | Destaca itens no chão com label de nome e distância |
| `Sec:SilentAim({})` | Silent aim com FOV configurável |
| `Sec:CamLock({})` | Trava a câmera em um player alvo |
| `Sec:TPToTarget({})` | Teleporta até o player selecionado no PlayerDropdown |
| `Sec:InvisWall({})` | Desativa colisão de paredes específicas |
| `Sec:GodMode({})` | Toggle de invencibilidade local |
| `Sec:InfAmmo({})` | Munição infinita sem reload |

---

### 🖥️ UI/UX — Lista Expandida

| Ideia | Descrição |
|---|---|
| **Sidebar recolhível** | Botão `«` que colapsa a sidebar para só ícones — abre com clique ou hover |
| **Aba detachável** | Botão `⊞` na aba que vira janela flutuante independente e arrastável |
| **Mini-mode** | Botão para comprimir a janela inteira numa barra compacta de ícones |
| **Resize handle** | ✅ v6 — arrastar redimensiona, duplo clique reseta ao tamanho padrão |
| **Fullscreen mode** | Botão `⛶` que expande a janela para preencher a tela toda |
| **Pin mode** | `📌` fixa a janela em cima de tudo — não some com ToggleKey |
| **Snap to edges** | Janela "gruda" nas bordas da tela quando arrastada perto |
| **Grid layout** | Opção de mostrar componentes em 2 colunas lado a lado |
| **Tabs no topo** | Modo alternativo: abas horizontais no topo em vez de sidebar vertical |
| **Tabs scroll** | Quando há muitas abas, a sidebar vira scroll com seta de rolagem |
| **Breadcrumb** | Linha no topo do conteúdo: `"Combat > Aimbot"` mostrando onde o user está |
| **Seção favoritos** | Estrela ⭐ em cada componente para adicioná-lo a uma aba "Favoritos" automática |
| **Ctrl+F global** | Atalho de teclado que foca a searchbar — encontra qualquer componente |
| **Modo daltônico** | Paleta alternativa que funciona para os 3 tipos de daltonismo |
| **Escala da UI** | Slider em Settings que escala toda a interface (0.75x–1.5x) |
| **Opacidade da janela** | Slider que controla transparência do fundo da janela |
| **Blur de fundo** | Efeito de blur do jogo visível através da janela (glassmorphism real) |
| **Animação de fechamento** | Janela fecha com animação estilo "shrink" ou "slide" — configurável |
| **Atalhos de teclado** | Ctrl+S = salvar config, Ctrl+Z = desfazer última mudança, Esc = fechar janela |
| **Context menu** | Clique direito em qualquer componente abre menu: Copiar valor, Resetar, Adicionar favorito |
| **Modo apresentação** | Esconde todos os controles e mostra só labels — para prints/showcase |
| **Separador colorido** | `Sec:Separator("Danger", Color3.fromRGB(239,68,68))` — separador com cor customizada |
| **Seção colapsável** | Clique no header da Section para recolher/expandir todo o grupo |
| **Indicador de alteração** | Ponto azul `●` aparece na aba quando algum valor nela foi mudado da config salva |

---

### 🎨 Animações & Efeitos — Lista Expandida

| Ideia | Descrição |
|---|---|
| **Partículas no clique** | Burst de ~8 partículas quadradas na cor do accent ao clicar botão |
| **Swipe entre abas** | Página atual sai deslizando para a esquerda, nova entra pela direita |
| **Neon glow** | `GlowBorder=true` — halo de luz externa em volta da janela via ImageLabel |
| **Glassmorphism real** | Blur do jogo por baixo da janela com `BlurEffect` + transparência |
| **Scanlines** | Linhas horizontais semi-transparentes sutis no fundo — estética hacker |
| **Matrix rain** | Easter egg: código cascateando no fundo tipo Matrix ao segurar uma tecla |
| **Número animado** | Labels numéricas contam suavemente ao atualizar (tween do valor) |
| **Confetti na key** | Confetti colorido explode ao digitar key correta |
| **Typing cursor** | Cursor `|` piscante no TextBox estilo terminal |
| **Loading shimmer** | Efeito shimmer nos componentes enquanto carregam (skeleton screen) |
| **Hover spotlight** | Foco de luz sutil seguindo o mouse dentro dos cards |
| **Ripple personalizado** | Tamanho, velocidade e cor do ripple configuráveis por componente |
| **Entrada por componente** | Cada elemento "entra" com pequeno fade+slide ao ser adicionado à seção |
| **Efeito de digitação no Label** | `Label:Typewrite("texto")` — escreve letra por letra como typewriter |
| **Pulso no badge** | Badge da aba pulsa suavemente quando tem número > 0 |
| **Transição de tema** | Ao trocar de tema, todos os elementos fazem tween suave de cor |
| **Crack/break animation** | Botão destrutivo confirmado faz animação de "quebra" antes de executar |
| **Shake na janela** | Erro crítico faz a janela inteira tremer levemente |
| **Trail customizável** | CursorTrail com shapes: círculo, estrela, coração, cubo |
| **Efeito de digitalização** | Linhas varrendo a janela verticalmente ao abrir — estética sci-fi |
| **Partículas de neve** | Modo sazonal: neve caindo pelo fundo da janela |

---

### 💾 Sistema / Config — Lista Expandida

| Ideia | Descrição |
|---|---|
| **Auto-update checker** | Compara versão com `version.txt` no GitHub, notifica e oferece botão de atualizar |
| **Crash logger** | Todo `pcall` interno que falhar salva stack trace em `SunUI_Errors.txt` com timestamp |
| **Config por PlaceId** | Config diferente por `game.PlaceId` — hubs multi-game com saves separados |
| **Config em nuvem** | Salva/carrega flags via servidor HTTP — sincroniza entre contas/PCs |
| **Sync via clipboard** | Exporta config como JSON comprimido em Base64 — colar em outro executor |
| **Flag observer** | `SunUI:Watch("Flag", function(old, new) end)` — callback a cada mudança |
| **Flags tipadas** | Define tipo esperado de cada flag (`bool`, `number`, `string`) e valida ao setar |
| **Flag history** | Mantém histórico das últimas 10 mudanças de cada flag — `SunUI:GetHistory("Flag")` |
| **Undo/Redo** | Ctrl+Z/Y desfaz/refaz a última mudança de qualquer componente |
| **Config diff** | Ao carregar perfil, mostra popup listando quais flags mudaram |
| **Config export/import** | Botões para exportar config como arquivo `.sunui` e importar de volta |
| **Config read-only mode** | `SunUI:Lock()` congela todos os valores — impede mudanças acidentais |
| **Config por personagem** | Salva config vinculada ao nome do personagem atual no jogo |
| **Backup automático** | Cria `Config_backup_YYYYMMDD.json` antes de sobrescrever — máximo de 5 backups |
| **Config encriptada** | Opção de encriptar o arquivo de config para esconder valores sensíveis |
| **Schema validation** | Define schema de config (min, max, opções válidas) e valida ao carregar |
| **Migração de config** | `SunUI:Migrate(oldVersion, newVersion, fn)` — adapta configs antigas para o novo formato |

---

### 🔑 Key System — Lista Expandida

| Ideia | Descrição |
|---|---|
| **Webhook de validação** | Valida key em servidor externo via `HttpGet` — pode invalidar keys remotamente |
| **Key com expiração** | Key válida por X dias, countdown visível no popup, bloqueia ao expirar |
| **Planos diferenciados** | Free/VIP/Admin keys desbloqueiam conjuntos de abas diferentes |
| **HWID lock** | Associa key ao HWID do executor — impede compartilhamento entre usuários |
| **Trial mode** | Sem key: funciona 10 minutos com aviso de "X min restantes" → pede key |
| **Key salva** | Armazena key criptografada localmente — não precisa redigitar toda sessão |
| **Rate limit** | Após 5 erros em 60s, bloqueia por 5 minutos com countdown visível |
| **Discord OAuth** | Login via Discord — abre link no browser, retorna token para validar |
| **Shake progressivo** | 1° erro: shake leve — 2° erro: shake médio — 3° erro: shake forte + lockout |
| **Confetti na aprovação** | Animação de celebração ao digitar key correta |
| **Key oculta** | Opção de esconder os caracteres com `•` enquanto digita |
| **Copy-paste protection** | Desabilita paste na key box para impedir automação |
| **Key QR Code** | Exibe QR code no popup que o usuário escaneia com o celular para pegar a key |
| **Multiple steps** | Key em 2 etapas: digita código + confirma num segundo input |
| **Grace period** | Após key correta, funciona por 24h sem precisar validar de novo |

---

### 🔔 Notificações — Lista Expandida

| Ideia | Descrição |
|---|---|
| **Fila (queue)** | Máximo de 4 visíveis; excesso entra em fila e aparece quando há espaço |
| **Botão de ação** | `Button="Desfazer"` — ação rápida diretamente na notificação |
| **Notif persistente** | `Duration=0` — só fecha clicando no `✕` |
| **Notif de progresso** | Barra de progresso que atualiza em tempo real: `notif:SetProgress(0.7)` |
| **Agrupamento** | Várias notifs do mesmo tipo colapsam: `"3 notificações de sucesso ▼"` |
| **Notif expansível** | Clique para expandir e ver mensagem longa — truncada por padrão |
| **Notif de imagem** | Asset ID de imagem no lado esquerdo ao invés do ícone de tipo |
| **Notif rich text** | Suporte a tags `<b>`, `<i>`, `<color>` no texto da mensagem |
| **Notif de player** | Mostra avatar do player junto: `Notify({Player=alvo})` |
| **Histórico** | Aba "📋 Logs" automática registra todas as notifs com timestamp |
| **Notif de som** | `Sound=true` toca som de sistema ao aparecer (se executor permitir) |
| **Notif de urgência** | Tipo `"Critical"` — a janela inteira pisca e a notif fica com borda pulsante |
| **Copiar notif** | Ícone de copiar que copia texto da notificação para clipboard |
| **Auto-dismiss all** | Botão "Fechar todas" que dispensa todas de uma vez com animação |
| **Notif de confirmação** | `Notify` com Sim/Não inline — sem abrir popup separado |

---

### 🌐 Social / Multiplayer — Lista Expandida

| Ideia | Descrição |
|---|---|
| `Sec:PlayerList({})` | Lista todos os players: avatar, nome, team, distância, ping, HP |
| `Sec:ServerInfo({})` | Card com PlaceId, JobId, região estimada, uptime, players/max |
| `Sec:FriendsList({})` | Lista amigos no servidor com botão de teleportar até eles |
| `Sec:TeamSelector({})` | Visualizador de times com cores e contagem de membros |
| `Sec:Leaderboard({})` | Placar customizável com posições e valores atualizados em tempo real |
| `Sec:ChatBox({})` | Mini-chat dentro da janela sem precisar abrir o chat do Roblox |
| `Sec:ChatFilter({})` | Filtro de palavras no chat com lista negra customizável |
| `Sec:TPMenu({})` | Menu de teleporte para posições salvas, jogadores, spawns do mapa |
| `Sec:VoiceList({})` | Lista players com VC ativa indicando quem está falando |
| `Sec:BugReport({})` | Formulário que captura o último erro do log e envia via webhook |
| `Sec:Votação({})` | Sistema de votação entre players (requer servidor) |
| `Sec:Spectate({})` | Modo espectador: câmera segue o player selecionado no PlayerDropdown |

---

### ⚙️ Developer Experience — Lista Expandida

| Ideia | Descrição |
|---|---|
| **`SunUI:Debug(true)`** | Modo debug: bordas vermelhas em elementos, logs de criação no F9, FPS do layout |
| **`SunUI:Inspect(flag)`** | Popup mostrando valor atual, tipo, histórico e componente dono da flag |
| **`SunUI:Reload()`** | Destrói e recria a janela inteira sem re-executar o script — hot reload |
| **`SunUI:On(event, fn)`** | Sistema de eventos: `TabChanged`, `WindowToggled`, `FlagChanged`, `ThemeChanged` |
| **`SunUI:Off(event)`** | Remove listener de evento |
| **`SunUI:Benchmark()`** | Mede tempo de criação de cada componente e exibe relatório no F9 |
| **`SunUI:Export()`** | Gera código Lua do hub atual — você edita a janela e exporta o script |
| **Template system** | `SunUI:LoadTemplate("combat")` — carrega conjunto pré-definido de abas/seções |
| **Mock players** | `PlayerDropdown({Mock={"A","B"}})` — testa sem precisar de outros players |
| **Componente conditional** | `Sec:If(condition, function(s) s:Toggle(...) end)` — adiciona componente só se condição for true |
| **Agrupamento por grupo** | Tags em componentes: `Group="aimbot"` — esconde/mostra grupos inteiros |
| **`SunUI:Snapshot()`** | Tira "foto" do estado atual de todos os flags em uma tabela |
| **`SunUI:Restore(snapshot)`** | Restaura estado a partir de um snapshot |
| **Validação de opts** | Warnings no F9 quando opts obrigatórios faltam ou têm tipo errado |
| **Playground mode** | `SunUI:Playground()` — janela de teste com todos os componentes auto-gerada |
| **`SunUI:Theme(name)`** | Troca tema em runtime com tween em todos os elementos |
| **`Sec:Group(name)`** | Agrupa componentes para mostrar/esconder em conjunto com uma chamada |
| **Documentação inline** | `SunUI:Help("Toggle")` — abre popup com documentação do componente |

---

### 🔧 Performance & Técnico — Lista Expandida

| Ideia | Descrição |
|---|---|
| **Lazy rendering** | Componentes fora do scroll não são renderizados — cria só ao fazer scroll até eles |
| **Virtual scroll** | Para listas com 100+ itens, renderiza só os visíveis + buffer |
| **Debounce automático** | Callbacks de slider têm debounce configurável: `Debounce=0.1s` |
| **Throttle de callbacks** | `Throttle=0.05s` — callback executa no máximo X vezes por segundo |
| **GC friendly** | Todas as conexões de eventos são armazenadas e desconectadas ao destruir |
| **Memory profiler** | `SunUI:MemoryUsage()` — retorna estimativa de KB usados pela lib |
| **Async loading** | Carregamento de avatares no PlayerDropdown com placeholder animado |
| **Batch updates** | `SunUI:BatchSet({Flag1=v1, Flag2=v2})` — atualiza vários flags de uma vez sem múltiplos callbacks |
| **Worker thread** | Callbacks pesados podem rodar em `task.spawn` automaticamente com `Async=true` |
| **Connection pool** | Reutiliza tweens em vez de criar novos a cada animação |
| **Object pooling** | Itens do PlayerDropdown são reciclados ao atualizar em vez de destruir e criar |
| **Compressed config** | Config salva comprimida para reduzir tamanho do arquivo |
| **Delta saves** | Salva só o que mudou desde o último save, não o estado inteiro |
| **Preload** | `SunUI:Preload()` pré-aquece todos os tweens e serviços antes de criar a janela |

---

### 🛡️ Segurança & Anti-Cheat evasion

| Ideia | Descrição |
|---|---|
| **Ofuscação de instâncias** | Nomes aleatórios nos GUIs internos — dificulta detecção por anti-cheats |
| **Anti-screenshot** | Esconde a janela automaticamente quando PrintScreen é pressionado |
| **Panic key** | Tecla de emergência que esconde e para tudo instantaneamente |
| **Proteção de flags** | Flags sensíveis ficam em tabela metatable com `__index` customizado |
| **Rate limit interno** | Bloqueia chamadas de callback mais rápidas que X/segundo para evitar abuso |
| **Anti-tamper** | Verifica integridade do código ao carregar — avisa se foi modificado |
| **Stealth mode** | `SunUI:Stealth(true)` — reduz footprint máximo: sem watermark, sem notifs visíveis |
| **Sandbox de callbacks** | Cada callback roda em ambiente isolado com `setfenv` — bugs não vazam |

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
