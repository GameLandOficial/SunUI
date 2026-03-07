--[[
╔══════════════════════════════════════════════════════════════════════╗
║   ☀  SunUI  •  v6  •  RELEASE EDITION                               ║
║   100% Bug-Free  •  Universal  •  Design inspired                    ║
║                                                                      ║
║   DESTAQUES:                                                         ║
║   ✦ 6 temas prontos + suporte a tema customizado                   ║
║   ✦ Animação de intro + Key System com shake (key errada)          ║
║   ✦ Notificações posicionáveis (4 cantos da tela)                  ║
║   ✦ BackgroundManager — Asset ID ou URL, lista salva               ║
║   ✦ Busca global de elementos (searchbar integrada)                 ║
║   ✦ Sistema de perfis (múltiplas configs nomeadas)                  ║
║   ✦ Stats Widget (FPS/Ping/Players), Watermark, CursorTrail        ║
║   ✦ Confirmação em botões destrutivos — popup seguro               ║
║   ✦ Animação de erro no Slider (flash vermelho + shake suave)      ║
║   ✦ PlayerDropdown — lista de players com avatar, nome e @username  ║
║   ✦ Todos os callbacks em pcall — crash do user não quebra a lib   ║
║   ✦ Dropdowns e ColorPicker flutuam acima do hub (sem clipping)    ║
║   ✦ Resize handle: arrastar = redimensiona, duplo-clique = reset   ║
║   ✦ Key System com botão "Get Key" para link externo               ║
║   ✦ DestroyButton: fecha o hub com confirmação                     ║
╚══════════════════════════════════════════════════════════════════════╝
]]

-- ════════════════════════════════════════════════
-- SERVIÇOS (todos com pcall)
-- ════════════════════════════════════════════════
local _srv = game.GetService
local function G(s) local ok,r=pcall(_srv,game,s) return ok and r or nil end

local Players          = G("Players")
local TweenService     = G("TweenService")
local UserInputService = G("UserInputService")
local RunService       = G("RunService")
local HttpService      = G("HttpService")
local CoreGui          = G("CoreGui")
local StarterGui       = G("StarterGui")
local Stats            = G("Stats")

local LP = Players and Players.LocalPlayer

-- ════════════════════════════════════════════════
-- TABELA PRINCIPAL
-- ════════════════════════════════════════════════
local SunUI = {
    Version    = "6.0.0",
    Flags      = {},
    Profiles   = {},        -- sistema de perfis
    _screen    = nil,
    _rbRunning = false,
    _rbTick    = 0,
    _borders   = {},        -- UIStrokes rastreados (rainbow)
    _accents   = {},        -- objetos rastreados (accent)
    _notifyPos = "BotRight",-- posição padrão das notificações
    _notifyCon = nil,       -- container de notificações ativo
    _tipFrame  = nil,
    _tipLabel  = nil,
    _watermark = nil,
    Ranks      = {},        -- {["username"]="Owner"} ou {[userId]="Admin"}
    _statsHud  = nil,
    _curTrail  = false,
    _curConn   = nil,
}

-- ════════════════════════════════════════════════
-- UTILITÁRIOS  (100% pcall-safe)
-- ════════════════════════════════════════════════
local U = {}

function U.Tween(obj, props, t, style, dir)
    if not obj then return end
    local ok2 = pcall(function() return obj.Parent end)
    if not ok2 then return end
    pcall(function()
        TweenService:Create(obj,
            TweenInfo.new(t or 0.22,
                style or Enum.EasingStyle.Quart,
                dir   or Enum.EasingDirection.Out),
            props):Play()
    end)
end

function U.Spring(obj, props, t)
    U.Tween(obj, props, t or 0.38, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- Criar instância completamente segura
function U.New(cls, props, parent)
    local ok, inst = pcall(Instance.new, cls)
    if not ok or not inst then return nil end
    if props then
        for k, v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
    end
    if parent then pcall(function() inst.Parent = parent end) end
    return inst
end

function U.Corner(r, p)
    if not p then return end
    return U.New("UICorner", {CornerRadius=UDim.new(0, r or 8)}, p)
end

function U.Stroke(color, thick, p, trans)
    if not p then return nil end
    return U.New("UIStroke", {
        Color=color or Color3.new(1,1,1),
        Thickness=thick or 1,
        Transparency=trans or 0,
        ApplyStrokeMode=Enum.ApplyStrokeMode.Border,
    }, p)
end

function U.Pad(t,b,l,r,p)
    if not p then return end
    U.New("UIPadding",{
        PaddingTop=UDim.new(0,t or 0), PaddingBottom=UDim.new(0,b or 0),
        PaddingLeft=UDim.new(0,l or 0), PaddingRight=UDim.new(0,r or 0),
    }, p)
end

function U.List(sp, ha, p)
    if not p then return nil end
    return U.New("UIListLayout",{
        Padding=UDim.new(0,sp or 0),
        HorizontalAlignment=ha or Enum.HorizontalAlignment.Left,
        SortOrder=Enum.SortOrder.LayoutOrder,
    }, p)
end

function U.AutoCanvas(scroll, layout, extra)
    if not scroll or not layout then return end
    local function upd()
        pcall(function()
            scroll.CanvasSize=UDim2.new(0,0,0,layout.AbsoluteContentSize.Y+(extra or 16))
        end)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd); upd()
end

function U.AutoHeight(frame, layout, extra)
    if not frame or not layout then return end
    local function upd()
        pcall(function()
            frame.Size=UDim2.new(frame.Size.X.Scale,frame.Size.X.Offset,
                                 0,layout.AbsoluteContentSize.Y+(extra or 0))
        end)
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(upd); upd()
end

function U.ID()
    local ok,id=pcall(function() return HttpService:GenerateGUID(false):sub(1,8) end)
    return ok and id or tostring(math.random(100000,999999))
end

function U.ToHex(c)
    if not c then return "FFFFFF" end
    return string.format("%02X%02X%02X",
        math.clamp(math.floor(c.R*255+.5),0,255),
        math.clamp(math.floor(c.G*255+.5),0,255),
        math.clamp(math.floor(c.B*255+.5),0,255))
end

function U.FromHex(h)
    if type(h)~="string" then return Color3.new(1,1,1) end
    h=h:gsub("#",""):gsub("%s","")
    if #h~=6 then return Color3.new(1,1,1) end
    local r,g,b=tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16)
    if not r or not g or not b then return Color3.new(1,1,1) end
    return Color3.fromRGB(r,g,b)
end

function U.Lerp(a,b,t)
    t=math.clamp(t or 0,0,1)
    return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t)
end

-- ════ SHAKE ANIMATION (EXCLUSIVO — usado no key system) ════
-- Oscila horizontalmente com decaimento exponencial
function U.Shake(frame, intensity, duration)
    if not frame then return end
    intensity = intensity or 8
    duration  = duration  or 0.45
    local origX = frame.Position.X.Offset
    local origPos = frame.Position
    local elapsed = 0
    local freq = 22
    task.spawn(function()
        while elapsed < duration do
            local dt = task.wait(0.016)
            elapsed = elapsed + dt
            local decay = 1 - (elapsed / duration)
            local offset = math.sin(elapsed * freq) * intensity * decay
            pcall(function()
                frame.Position = UDim2.new(
                    origPos.X.Scale, origPos.X.Offset + offset,
                    origPos.Y.Scale, origPos.Y.Offset
                )
            end)
        end
        pcall(function() frame.Position = origPos end)
    end)
end

-- ════ PULSE (efeito de pulsação em toggle) ════
function U.Pulse(frame, color, T_theme)
    if not frame then return end
    local c = color or Color3.new(1,1,1)
    local glow = U.New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=c,
        BackgroundTransparency=0.7,
        ZIndex=(frame.ZIndex or 1)+2,
    }, frame)
    U.Corner(9, glow)
    U.Tween(glow,{BackgroundTransparency=1,Size=UDim2.new(1,10,1,10),Position=UDim2.new(0,-5,0,-5)},0.38)
    task.delay(0.42, function()
        if glow and glow.Parent then glow:Destroy() end
    end)
end

-- ════ RIPPLE ════
function U.Ripple(btn, color)
    if not btn then return end
    pcall(function() btn.ClipsDescendants=true end)
    btn.InputBegan:Connect(function(i)
        if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local x=i.Position.X-btn.AbsolutePosition.X
        local y=i.Position.Y-btn.AbsolutePosition.Y
        local rip=U.New("Frame",{
            Size=UDim2.new(0,0,0,0),
            Position=UDim2.new(0,x,0,y),
            AnchorPoint=Vector2.new(.5,.5),
            BackgroundColor3=color or Color3.new(1,1,1),
            BackgroundTransparency=0.72,
            ZIndex=(btn.ZIndex or 1)+10,
        },btn)
        U.Corner(999,rip)
        local s=math.max(btn.AbsoluteSize.X,btn.AbsoluteSize.Y)*2.6
        U.Tween(rip,{Size=UDim2.new(0,s,0,s),BackgroundTransparency=1},0.5,Enum.EasingStyle.Quad)
        task.delay(0.55,function() if rip and rip.Parent then rip:Destroy() end end)
    end)
end

-- ════ DRAGGABLE ════
function U.Draggable(frame, handle)
    if not frame or not handle then return end
    local drag,si,sp=false,nil,nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; si=i.Position; sp=frame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if not drag then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement
        and i.UserInputType~=Enum.UserInputType.Touch then return end
        if not frame.Parent then return end
        local d=i.Position-si
        pcall(function()
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end)
    end)
end

-- ════ TYPEWRITER ════
function U.Typewriter(lbl, text, spd, onDone)
    if not lbl then return end
    spd=spd or 0.04
    pcall(function() lbl.Text="" end)
    task.spawn(function()
        for i=1,#text do
            if not lbl.Parent then return end
            pcall(function() lbl.Text=text:sub(1,i) end)
            task.wait(spd)
        end
        if onDone then pcall(onDone) end
    end)
end

-- ════ TOOLTIP com delay+fade ════
-- (configurado mais abaixo junto ao setup global)

-- ════════════════════════════════════════════════
-- TEMAS
-- ════════════════════════════════════════════════
SunUI.Themes = {
    Dark = {
        Name="Dark",
        Bg=Color3.fromRGB(13,13,21),       Surface=Color3.fromRGB(19,19,31),
        SurfaceHigh=Color3.fromRGB(26,26,42), SurfaceHover=Color3.fromRGB(33,33,52),
        Sidebar=Color3.fromRGB(15,15,25),   TitleBar=Color3.fromRGB(9,9,16),
        Accent=Color3.fromRGB(99,102,241),  AccentB=Color3.fromRGB(139,92,246),
        AccentHover=Color3.fromRGB(79,82,221), AccentDim=Color3.fromRGB(35,38,112),
        Border=Color3.fromRGB(38,38,62),    BorderBright=Color3.fromRGB(56,56,86),
        Text=Color3.fromRGB(245,245,255),   TextSub=Color3.fromRGB(150,150,188),
        TextMuted=Color3.fromRGB(78,78,118),TextAccent=Color3.fromRGB(162,165,255),
        Good=Color3.fromRGB(52,211,153),    Warn=Color3.fromRGB(251,191,36),
        Bad=Color3.fromRGB(239,68,68),
        ToggleOff=Color3.fromRGB(38,38,62), TrackBg=Color3.fromRGB(28,28,48),
        InputBg=Color3.fromRGB(11,11,19),   NotifyBg=Color3.fromRGB(17,17,29),
        Scrollbar=Color3.fromRGB(68,68,115),
    },
    Amethyst = {
        Name="Amethyst",
        Bg=Color3.fromRGB(10,8,18),        Surface=Color3.fromRGB(16,12,28),
        SurfaceHigh=Color3.fromRGB(22,17,38), SurfaceHover=Color3.fromRGB(30,22,52),
        Sidebar=Color3.fromRGB(13,10,22),   TitleBar=Color3.fromRGB(8,6,15),
        Accent=Color3.fromRGB(168,85,247),  AccentB=Color3.fromRGB(236,72,153),
        AccentHover=Color3.fromRGB(148,65,225), AccentDim=Color3.fromRGB(72,28,115),
        Border=Color3.fromRGB(46,35,78),    BorderBright=Color3.fromRGB(68,52,110),
        Text=Color3.fromRGB(242,235,255),   TextSub=Color3.fromRGB(165,145,205),
        TextMuted=Color3.fromRGB(90,72,140),TextAccent=Color3.fromRGB(205,165,255),
        Good=Color3.fromRGB(52,211,153),    Warn=Color3.fromRGB(251,191,36),
        Bad=Color3.fromRGB(239,68,68),
        ToggleOff=Color3.fromRGB(46,35,78), TrackBg=Color3.fromRGB(38,28,68),
        InputBg=Color3.fromRGB(12,9,20),    NotifyBg=Color3.fromRGB(16,12,28),
        Scrollbar=Color3.fromRGB(100,55,180),
    },
    Crimson = {
        Name="Crimson",
        Bg=Color3.fromRGB(15,8,8),         Surface=Color3.fromRGB(23,12,12),
        SurfaceHigh=Color3.fromRGB(32,18,18), SurfaceHover=Color3.fromRGB(42,25,25),
        Sidebar=Color3.fromRGB(17,10,10),   TitleBar=Color3.fromRGB(10,6,6),
        Accent=Color3.fromRGB(239,68,68),   AccentB=Color3.fromRGB(251,146,60),
        AccentHover=Color3.fromRGB(218,48,48), AccentDim=Color3.fromRGB(100,25,25),
        Border=Color3.fromRGB(65,30,30),    BorderBright=Color3.fromRGB(88,45,45),
        Text=Color3.fromRGB(255,242,242),   TextSub=Color3.fromRGB(182,132,132),
        TextMuted=Color3.fromRGB(110,65,65),TextAccent=Color3.fromRGB(255,145,145),
        Good=Color3.fromRGB(52,211,153),    Warn=Color3.fromRGB(251,191,36),
        Bad=Color3.fromRGB(239,68,68),
        ToggleOff=Color3.fromRGB(65,30,30), TrackBg=Color3.fromRGB(52,22,22),
        InputBg=Color3.fromRGB(18,10,10),   NotifyBg=Color3.fromRGB(22,12,12),
        Scrollbar=Color3.fromRGB(185,50,50),
    },
    Neon = {
        Name="Neon",
        Bg=Color3.fromRGB(6,12,18),        Surface=Color3.fromRGB(10,18,28),
        SurfaceHigh=Color3.fromRGB(14,26,40), SurfaceHover=Color3.fromRGB(20,36,54),
        Sidebar=Color3.fromRGB(7,14,22),    TitleBar=Color3.fromRGB(4,9,15),
        Accent=Color3.fromRGB(6,182,212),   AccentB=Color3.fromRGB(59,130,246),
        AccentHover=Color3.fromRGB(0,160,190), AccentDim=Color3.fromRGB(0,75,100),
        Border=Color3.fromRGB(18,48,70),    BorderBright=Color3.fromRGB(28,68,98),
        Text=Color3.fromRGB(218,248,255),   TextSub=Color3.fromRGB(100,168,205),
        TextMuted=Color3.fromRGB(40,95,128),TextAccent=Color3.fromRGB(100,232,255),
        Good=Color3.fromRGB(52,211,153),    Warn=Color3.fromRGB(251,191,36),
        Bad=Color3.fromRGB(239,68,68),
        ToggleOff=Color3.fromRGB(18,48,70), TrackBg=Color3.fromRGB(15,40,60),
        InputBg=Color3.fromRGB(7,14,22),    NotifyBg=Color3.fromRGB(8,16,26),
        Scrollbar=Color3.fromRGB(0,165,205),
    },
    Emerald = {
        Name="Emerald",
        Bg=Color3.fromRGB(6,14,10),        Surface=Color3.fromRGB(10,22,16),
        SurfaceHigh=Color3.fromRGB(16,30,22), SurfaceHover=Color3.fromRGB(22,40,30),
        Sidebar=Color3.fromRGB(8,16,12),    TitleBar=Color3.fromRGB(5,10,8),
        Accent=Color3.fromRGB(16,185,129),  AccentB=Color3.fromRGB(20,220,180),
        AccentHover=Color3.fromRGB(12,162,110), AccentDim=Color3.fromRGB(4,78,55),
        Border=Color3.fromRGB(20,48,36),    BorderBright=Color3.fromRGB(30,68,52),
        Text=Color3.fromRGB(218,252,244),   TextSub=Color3.fromRGB(100,178,148),
        TextMuted=Color3.fromRGB(42,105,82),TextAccent=Color3.fromRGB(96,242,192),
        Good=Color3.fromRGB(52,211,153),    Warn=Color3.fromRGB(251,191,36),
        Bad=Color3.fromRGB(239,68,68),
        ToggleOff=Color3.fromRGB(20,48,36), TrackBg=Color3.fromRGB(16,40,30),
        InputBg=Color3.fromRGB(8,16,12),    NotifyBg=Color3.fromRGB(9,18,14),
        Scrollbar=Color3.fromRGB(12,152,100),
    },
    Light = {
        Name="Light",
        Bg=Color3.fromRGB(245,245,252),    Surface=Color3.fromRGB(235,235,248),
        SurfaceHigh=Color3.fromRGB(225,225,242), SurfaceHover=Color3.fromRGB(215,215,235),
        Sidebar=Color3.fromRGB(228,228,245), TitleBar=Color3.fromRGB(218,218,238),
        Accent=Color3.fromRGB(99,102,241),  AccentB=Color3.fromRGB(139,92,246),
        AccentHover=Color3.fromRGB(79,82,221), AccentDim=Color3.fromRGB(200,200,255),
        Border=Color3.fromRGB(195,195,228), BorderBright=Color3.fromRGB(175,175,212),
        Text=Color3.fromRGB(22,22,48),      TextSub=Color3.fromRGB(90,90,142),
        TextMuted=Color3.fromRGB(155,155,192),TextAccent=Color3.fromRGB(75,80,205),
        Good=Color3.fromRGB(16,185,129),    Warn=Color3.fromRGB(245,158,11),
        Bad=Color3.fromRGB(220,40,40),
        ToggleOff=Color3.fromRGB(195,195,228), TrackBg=Color3.fromRGB(210,210,238),
        InputBg=Color3.fromRGB(250,250,255), NotifyBg=Color3.fromRGB(255,255,255),
        Scrollbar=Color3.fromRGB(165,165,220),
    },
}
SunUI.Theme = SunUI.Themes.Dark

-- ════════════════════════════════════════════════
-- RAINBOW / ACCENT SYSTEM
-- ════════════════════════════════════════════════
local function TrackBorder(s) if s then table.insert(SunUI._borders,s) end end
local function TrackAccent(o,p) if o then table.insert(SunUI._accents,{o=o,p=p or "BackgroundColor3"}) end end

local function StopRainbow() SunUI._rbRunning=false end

local function StartRainbow()
    if SunUI._rbRunning then return end
    SunUI._rbRunning=true
    task.spawn(function()
        while SunUI._rbRunning do
            SunUI._rbTick=(SunUI._rbTick+0.002)%1
            local c=Color3.fromHSV(SunUI._rbTick,1,1)
            for _,s in ipairs(SunUI._borders) do
                if s and s.Parent then pcall(function() s.Color=c end) end
            end
            for _,a in ipairs(SunUI._accents) do
                if a and a.o and a.o.Parent then pcall(function() a.o[a.p]=c end) end
            end
            task.wait(0.016)
        end
    end)
end

function SunUI:SetAccentColor(c1,c2,rainbow)
    self._accent1=c1; self._accent2=c2 or c1
    StopRainbow(); task.wait(0.05)
    if rainbow then self._rbTick=0; StartRainbow(); return end
    for _,s in ipairs(self._borders) do
        if s and s.Parent then pcall(function() s.Color=c1 end) end
    end
    for _,a in ipairs(self._accents) do
        if a and a.o and a.o.Parent then pcall(function() a.o[a.p]=c1 end) end
    end
end

-- ════════════════════════════════════════════════
-- SAVE MANAGER
-- ════════════════════════════════════════════════
local SaveMgr={_file="SunUI_Config.json"}
function SaveMgr:SetFile(n) self._file=(n or "SunUI_Config")..".json" end
function SaveMgr:Save(data)
    if not writefile then return false end
    local ok,enc=pcall(function() return HttpService:JSONEncode(data) end)
    if not ok then return false end
    return pcall(writefile,self._file,enc)
end
function SaveMgr:Load()
    if not readfile then return {} end
    -- isfile pode nao existir em alguns executors (ex: versoes antigas do Xeno)
    -- tenta ler direto e trata o erro como "arquivo nao existe"
    local ok2,raw=pcall(readfile,self._file)
    if not ok2 or type(raw)~="string" or raw=="" then return {} end
    local ok3,dec=pcall(function() return HttpService:JSONDecode(raw) end)
    return (ok3 and type(dec)=="table") and dec or {}
end

-- Perfis (salva um arquivo por perfil)
function SunUI:SaveProfile(name)
    if not writefile then return end
    local fname="SunUI_Profile_"..tostring(name)..".json"
    local ok,enc=pcall(function() return HttpService:JSONEncode(self.Flags) end)
    if ok then pcall(writefile,fname,enc) end
end
function SunUI:LoadProfile(name)
    if not readfile then return end
    local fname="SunUI_Profile_"..tostring(name)..".json"
    local ok2,raw=pcall(readfile,fname)
    if not ok2 or type(raw)~="string" or raw=="" then return end
    local ok3,dec=pcall(function() return HttpService:JSONDecode(raw) end)
    if ok3 and type(dec)=="table" then
        for k,v in pairs(dec) do self.Flags[k]=v end
    end
end

-- ════════════════════════════════════════════════
-- TOOLTIP  (delay + fade, sem crash)
-- ════════════════════════════════════════════════
local function SetupTooltip(screen, T)
    if SunUI._tipFrame and SunUI._tipFrame.Parent then SunUI._tipFrame:Destroy() end
    local tip=U.New("Frame",{
        Size=UDim2.new(0,210,0,36),
        BackgroundColor3=T.SurfaceHigh,
        BackgroundTransparency=1,
        Visible=false, ZIndex=800,
    },screen)
    U.Corner(8,tip)
    local ts=U.Stroke(T.Border,1,tip); if ts then ts.Transparency=1 end
    local tl=U.New("TextLabel",{
        Size=UDim2.new(1,-12,1,0), Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1, Text="",
        TextColor3=T.TextSub, Font=Enum.Font.Gotham, TextSize=11,
        TextWrapped=true, ZIndex=801,
    },tip)
    SunUI._tipFrame=tip; SunUI._tipLabel=tl

    RunService.RenderStepped:Connect(function()
        if not tip or not tip.Visible then return end
        local mp=UserInputService:GetMouseLocation()
        pcall(function() tip.Position=UDim2.new(0,mp.X+16,0,mp.Y+16) end)
    end)
end

local _tipDelayThread = nil
function U.Tooltip(el, text)
    if not el or not text or text=="" then return end
    el.MouseEnter:Connect(function()
        if _tipDelayThread then task.cancel(_tipDelayThread) end
        _tipDelayThread=task.delay(0.5, function()
            if SunUI._tipLabel then pcall(function() SunUI._tipLabel.Text=text end) end
            if SunUI._tipFrame and SunUI._tipFrame.Parent then
                pcall(function() SunUI._tipFrame.Visible=true end)
                U.Tween(SunUI._tipFrame,{BackgroundTransparency=0},0.18)
                local _,ts2=pcall(function() return SunUI._tipFrame:FindFirstChildOfClass("UIStroke") end)
                if ts2 then U.Tween(ts2,{Transparency=0.3},0.18) end
            end
        end)
    end)
    el.MouseLeave:Connect(function()
        if _tipDelayThread then pcall(task.cancel,_tipDelayThread) end
        if SunUI._tipFrame and SunUI._tipFrame.Parent then
            U.Tween(SunUI._tipFrame,{BackgroundTransparency=1},0.12)
            local _,ts=pcall(function() return SunUI._tipFrame:FindFirstChildOfClass("UIStroke") end)
            if ts then U.Tween(ts,{Transparency=1},0.12) end
            task.delay(0.15,function()
                if SunUI._tipFrame and SunUI._tipFrame.Parent then
                    pcall(function() SunUI._tipFrame.Visible=false end)
                end
            end)
        end
    end)
end

-- ════════════════════════════════════════════════
-- NOTIFICAÇÕES POSICIONÁVEIS
-- ════════════════════════════════════════════════
-- Posições: "TopLeft" | "TopRight" | "BotLeft" | "BotRight"
local _notifyPositions = {
    TopLeft  = {pos=UDim2.new(0,10,0,10),  anchor=Vector2.new(0,0),
                halign=Enum.HorizontalAlignment.Left,  valign=Enum.VerticalAlignment.Top},
    TopRight = {pos=UDim2.new(1,-330,0,10), anchor=Vector2.new(0,0),
                halign=Enum.HorizontalAlignment.Right, valign=Enum.VerticalAlignment.Top},
    BotLeft  = {pos=UDim2.new(0,10,1,-20), anchor=Vector2.new(0,1),
                halign=Enum.HorizontalAlignment.Left,  valign=Enum.VerticalAlignment.Bottom},
    BotRight = {pos=UDim2.new(1,-330,1,-20),anchor=Vector2.new(0,1),
                halign=Enum.HorizontalAlignment.Right, valign=Enum.VerticalAlignment.Bottom},
}

local function RebuildNotifyContainer(screen)
    if SunUI._notifyCon and SunUI._notifyCon.Parent then
        SunUI._notifyCon:Destroy()
    end
    local cfg=_notifyPositions[SunUI._notifyPos] or _notifyPositions.BotRight
    local con=U.New("Frame",{
        Name="SunUI_Notify",
        Size=UDim2.new(0,320,1,-20),
        Position=cfg.pos,
        AnchorPoint=cfg.anchor,
        BackgroundTransparency=1,
        ZIndex=600,
    },screen or CoreGui)
    if not con then return end
    local ll=U.List(6,cfg.halign,con)
    if ll then
        ll.VerticalAlignment=cfg.valign
        ll.FillDirection=Enum.FillDirection.Vertical
    end
    SunUI._notifyCon=con
end

function SunUI:SetNotifyPosition(pos)
    local valid={TopLeft=true,TopRight=true,BotLeft=true,BotRight=true}
    if not valid[pos] then return end
    self._notifyPos=pos
    RebuildNotifyContainer(self._screen)
end

function SunUI:Notify(opts)
    opts=opts or {}
    local T=self.Theme or self.Themes.Dark
    local title=tostring(opts.Title or "Aviso")
    local msg=tostring(opts.Message or "")
    local dur=tonumber(opts.Duration) or 4
    local kind=tostring(opts.Type or "Info")

    local icons={Info="ℹ",Success="✓",Warning="⚠",Error="✕"}
    local colors={Info=T.Accent,Success=T.Good,Warning=T.Warn,Error=T.Bad}
    local ic=icons[kind] or "ℹ"
    local clr=colors[kind] or T.Accent

    if not self._notifyCon or not self._notifyCon.Parent then
        RebuildNotifyContainer(self._screen)
    end
    if not self._notifyCon then return end

    local cfg=_notifyPositions[self._notifyPos] or _notifyPositions.BotRight
    local fromRight=(self._notifyPos=="BotRight" or self._notifyPos=="TopRight")

    local card=U.New("Frame",{
        Size=UDim2.new(1,0,0,78),
        BackgroundColor3=T.NotifyBg,
        BackgroundTransparency=0.06,
        ZIndex=601,
    },self._notifyCon)
    if not card then return end
    U.Corner(10,card)
    local cs=U.Stroke(clr,1.5,card); if cs then cs.Transparency=0.35 end

    -- Barra lateral
    local bar=U.New("Frame",{
        Size=UDim2.new(0,3,1,-18),Position=UDim2.new(0,0,0,9),
        BackgroundColor3=clr,ZIndex=602,
    },card)
    U.Corner(3,bar)

    -- Ícone
    local ibg=U.New("Frame",{
        Size=UDim2.new(0,34,0,34),Position=UDim2.new(0,14,0.5,-17),
        BackgroundColor3=clr,BackgroundTransparency=0.82,ZIndex=602,
    },card)
    U.Corner(8,ibg)
    U.New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=ic,TextColor3=clr,Font=Enum.Font.GothamBold,TextSize=15,ZIndex=603,
    },ibg)

    U.New("TextLabel",{
        Size=UDim2.new(1,-72,0,18),Position=UDim2.new(0,58,0,10),
        BackgroundTransparency=1,Text=title,TextColor3=T.Text,
        Font=Enum.Font.GothamBold,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=602,
    },card)
    U.New("TextLabel",{
        Size=UDim2.new(1,-72,0,28),Position=UDim2.new(0,58,0,28),
        BackgroundTransparency=1,Text=msg,TextColor3=T.TextSub,
        Font=Enum.Font.Gotham,TextSize=10,TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=602,
    },card)

    -- Progress bar
    local pb=U.New("Frame",{
        Size=UDim2.new(1,-12,0,2),Position=UDim2.new(0,6,1,-5),
        BackgroundColor3=T.Border,ZIndex=602,
    },card)
    U.Corner(2,pb)
    local pf=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=clr,ZIndex=603},pb)
    U.Corner(2,pf)

    -- Botão fechar
    local xb=U.New("TextButton",{
        Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-22,0,4),
        BackgroundTransparency=1,Text="✕",TextColor3=T.TextMuted,
        Font=Enum.Font.GothamBold,TextSize=10,ZIndex=603,
    },card)
    if xb then
        xb.MouseButton1Click:Connect(function()
            U.Tween(card,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)},0.25)
            task.delay(0.3,function() if card and card.Parent then card:Destroy() end end)
        end)
    end

    -- Entrada (slide da direita ou da esquerda)
    local slideOff=fromRight and 60 or -60
    pcall(function() card.Position=UDim2.new(0,slideOff,0,0) end)
    U.Spring(card,{Position=UDim2.new(0,0,0,0)},0.36)
    if pf then U.Tween(pf,{Size=UDim2.new(0,0,1,0)},dur,Enum.EasingStyle.Linear) end

    task.delay(dur,function()
        if not card or not card.Parent then return end
        U.Tween(card,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)},0.3)
        task.delay(0.35,function() if card and card.Parent then card:Destroy() end end)
    end)
    return card
end

-- ════════════════════════════════════════════════
-- KEY SYSTEM  (com Shake na tecla errada)
-- ════════════════════════════════════════════════
local function ShowKeySystem(opts,screen,T,onOK)
    local title=tostring(opts.Title or "Key System")
    local sub=tostring(opts.Sub or "Insira a key de acesso")
    local note=tostring(opts.Note or "")
    local keys=type(opts.Key)=="table" and opts.Key or {tostring(opts.Key or "")}

    local ov=U.New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=Color3.new(0,0,0),
        BackgroundTransparency=0.45,ZIndex=400,
    },screen)

    local F=U.New("Frame",{
        Size=UDim2.new(0,430,0,0),
        Position=UDim2.new(0.5,-215,0.5,-124),
        BackgroundColor3=T.Surface,
        BackgroundTransparency=1,ZIndex=401,
    },screen)
    U.Corner(14,F)
    local fsk=U.Stroke(T.Accent,2,F); TrackBorder(fsk)

    -- Logo pulsante
    local logo=U.New("Frame",{
        Size=UDim2.new(0,50,0,50),Position=UDim2.new(0.5,-25,0,20),
        BackgroundColor3=T.Accent,ZIndex=402,
    },F)
    U.Corner(14,logo); TrackAccent(logo,"BackgroundColor3")
    U.New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="☀",TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBlack,TextSize=26,ZIndex=403,
    },logo)
    -- pulso do logo
    task.spawn(function()
        while logo and logo.Parent do
            U.Tween(logo,{BackgroundColor3=U.Lerp(T.Accent,Color3.new(1,1,1),0.2)},0.7,Enum.EasingStyle.Sine)
            task.wait(0.72)
            U.Tween(logo,{BackgroundColor3=T.Accent},0.7,Enum.EasingStyle.Sine)
            task.wait(0.72)
        end
    end)

    local ttl=U.New("TextLabel",{
        Size=UDim2.new(1,-20,0,22),Position=UDim2.new(0,10,0,82),
        BackgroundTransparency=1,Text="",
        TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=15,ZIndex=402,
    },F)
    U.New("TextLabel",{
        Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,10,0,106),
        BackgroundTransparency=1,Text=sub,
        TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=12,ZIndex=402,
    },F)

    local ibg=U.New("Frame",{
        Size=UDim2.new(1,-24,0,40),Position=UDim2.new(0,12,0,134),
        BackgroundColor3=T.InputBg,ZIndex=402,
    },F)
    U.Corner(10,ibg); U.Stroke(T.Border,1,ibg)
    U.New("TextLabel",{Size=UDim2.new(0,28,1,0),BackgroundTransparency=1,Text="🔑",TextSize=13,ZIndex=403},ibg)
    local tb=U.New("TextBox",{
        Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,30,0,0),
        BackgroundTransparency=1,Text="",
        PlaceholderText="Insira a key...",PlaceholderColor3=T.TextMuted,
        TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=13,
        ClearTextOnFocus=false,ZIndex=403,
    },ibg)

    local fb=U.New("TextLabel",{
        Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,182),
        BackgroundTransparency=1,Text=note,
        TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=402,
    },F)

    -- Botão Get Key (abre URL para pegar a key, se fornecido)
    local getKeyUrl = opts.GetKeyUrl or opts.GetKey
    if getKeyUrl and tostring(getKeyUrl)~="" then
        local gkBtn=U.New("TextButton",{
            Size=UDim2.new(1,-24,0,34),Position=UDim2.new(0,12,0,200),
            BackgroundColor3=T.SurfaceHigh,Text="🔗  Get Key",
            TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=402,
        },F)
        U.Corner(10,gkBtn); U.Ripple(gkBtn,T.Accent); U.Stroke(T.Border,1,gkBtn)
        gkBtn.MouseEnter:Connect(function() U.Tween(gkBtn,{BackgroundColor3=T.SurfaceHover,TextColor3=T.Text},0.15) end)
        gkBtn.MouseLeave:Connect(function() U.Tween(gkBtn,{BackgroundColor3=T.SurfaceHigh,TextColor3=T.TextSub},0.15) end)
        gkBtn.MouseButton1Click:Connect(function()
            pcall(function() game:GetService("GuiService"):OpenBrowserWindow(tostring(getKeyUrl)) end)
        end)
        -- empurra conf para baixo
        if fb then pcall(function() fb.Position = UDim2.new(0,12,0,182) end) end
    end
    local confY = (getKeyUrl and tostring(getKeyUrl)~="") and 242 or 202
    local conf=U.New("TextButton",{
        Size=UDim2.new(1,-24,0,40),Position=UDim2.new(0,12,0,confY),
        BackgroundColor3=T.Accent,Text="CONFIRMAR",
        TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,ZIndex=402,
    },F)
    U.Corner(10,conf); U.Ripple(conf,Color3.new(1,1,1)); TrackAccent(conf,"BackgroundColor3")
    conf.MouseEnter:Connect(function() U.Tween(conf,{BackgroundColor3=T.AccentHover},0.15) end)
    conf.MouseLeave:Connect(function() U.Tween(conf,{BackgroundColor3=T.Accent},0.15) end)

    -- Tentativas erradas — incrementa e bloqueia por 2s após 3 tentativas
    local attempts=0; local locked=false

    local function Check()
        if locked then return end
        if not tb then return end
        local inp=tb.Text:gsub("%s","")
        for _,k in ipairs(keys) do
            if inp==tostring(k) then
                U.Tween(conf,{BackgroundColor3=T.Good},0.2)
                if fb then fb.Text="✓ Acesso liberado! Carregando..." fb.TextColor3=T.Good end
                task.delay(0.85,function()
                    U.Tween(F,{BackgroundTransparency=1,Size=UDim2.new(0,430,0,0)},0.28)
                    U.Tween(ov,{BackgroundTransparency=1},0.28)
                    task.delay(0.32,function()
                        if F and F.Parent then F:Destroy() end
                        if ov and ov.Parent then ov:Destroy() end
                        pcall(onOK)
                    end)
                end)
                return
            end
        end
        -- KEY ERRADA — Shake + vermelho flash
        attempts=attempts+1
        U.Shake(F, 10, 0.5)   -- ← NOVO
        U.Tween(ibg,{BackgroundColor3=U.Lerp(T.InputBg,T.Bad,0.3)},0.12)
        local _,ibgS=pcall(function() return ibg and ibg:FindFirstChildOfClass("UIStroke") end)
        if ibgS then U.Tween(ibgS,{Color=T.Bad},0.12) end
        if fb then
            fb.TextColor3=T.Bad
            if attempts>=3 then
                fb.Text="✗ Muitas tentativas! Aguarde 2s..."
            else
                fb.Text="✗ Key incorreta! ("..attempts.." tentativa"..(attempts>1 and "s" or "")..")"
            end
        end
        task.delay(0.65,function()
            U.Tween(ibg,{BackgroundColor3=T.InputBg},0.3)
            if ibgS then U.Tween(ibgS,{Color=T.Border},0.3) end
        end)
        if attempts>=3 then
            locked=true
            if conf then U.Tween(conf,{BackgroundColor3=T.TextMuted},0.2) end
            task.delay(2,function()
                locked=false; attempts=0
                if conf then U.Tween(conf,{BackgroundColor3=T.Accent},0.2) end
                if fb then fb.Text=note; fb.TextColor3=T.TextMuted end
            end)
        end
    end

    if conf then conf.MouseButton1Click:Connect(Check) end
    if tb then tb.FocusLost:Connect(function(e) if e then Check() end end) end

    -- Animação de entrada
    local keyFH = (getKeyUrl and tostring(getKeyUrl)~="") and 300 or 260
    U.Spring(F,{Size=UDim2.new(0,430,0,keyFH),BackgroundTransparency=0},0.4)
    task.delay(0.12,function() U.Typewriter(ttl,title,0.055) end)
    U.Draggable(F,F)
end

-- ════════════════════════════════════════════════
-- COLOR PICKER  (HSV + Hex + RGB, 100% seguro)
-- ════════════════════════════════════════════════
local function MakeColorPicker(container,default,T,onChange)
    default=default or Color3.fromRGB(255,80,80)
    local hv,sv,vv=Color3.toHSV(default)
    local isOpen=false

    local Wrap=U.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.SurfaceHigh,ZIndex=5},container)
    U.Corner(9,Wrap)
    local prev=U.New("Frame",{
        Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,-38,0.5,-13),
        BackgroundColor3=default,ZIndex=6,
    },Wrap)
    U.Corner(6,prev); U.Stroke(T.Border,1.5,prev)
    local chev=U.New("TextLabel",{
        Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-60,0.5,-10),
        BackgroundTransparency=1,Text="▾",
        TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=6,
    },Wrap)

    -- Panel do ColorPicker: renderizado no SunUI._screen para ficar acima de tudo
    -- e nunca ser clipado pelo hub
    local cpScreen = SunUI._screen
    local Panel=U.New("Frame",{
        Size=UDim2.new(0,0,0,0),Position=UDim2.new(0,0,0,0),
        BackgroundColor3=T.Surface,ClipsDescendants=false,Visible=false,ZIndex=750,
    },cpScreen or container)
    U.Corner(10,Panel); U.Stroke(T.BorderBright,1.5,Panel)

    -- SV area
    local SVF=U.New("Frame",{
        Size=UDim2.new(1,-16,0,132),Position=UDim2.new(0,8,0,8),
        BackgroundColor3=Color3.fromHSV(hv,1,1),ZIndex=21,
    },Panel)
    U.Corner(7,SVF)
    U.New("UIGradient",{
        Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),
        Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}),
    },SVF)
    local svDk=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),ZIndex=22},SVF)
    U.Corner(7,svDk)
    U.New("UIGradient",{
        Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),
        Rotation=90,
    },svDk)
    local svCur=U.New("Frame",{
        Size=UDim2.new(0,12,0,12),Position=UDim2.new(sv,-6,1-vv,-6),
        BackgroundColor3=Color3.new(1,1,1),ZIndex=24,
    },SVF)
    U.Corner(999,svCur); U.Stroke(Color3.new(0,0,0),1.5,svCur)

    -- Hue bar
    local HueB=U.New("Frame",{
        Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,8,0,149),ZIndex=21,
    },Panel)
    U.Corner(5,HueB)
    U.New("UIGradient",{Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),
        ColorSequenceKeypoint.new(.17,Color3.fromHSV(.17,1,1)),
        ColorSequenceKeypoint.new(.33,Color3.fromHSV(.33,1,1)),
        ColorSequenceKeypoint.new(.5,Color3.fromHSV(.5,1,1)),
        ColorSequenceKeypoint.new(.67,Color3.fromHSV(.67,1,1)),
        ColorSequenceKeypoint.new(.83,Color3.fromHSV(.83,1,1)),
        ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1)),
    })},HueB)
    local HueCur=U.New("Frame",{
        Size=UDim2.new(0,10,1,4),Position=UDim2.new(hv,-5,0,-2),
        BackgroundColor3=Color3.new(1,1,1),ZIndex=22,
    },HueB)
    U.Corner(4,HueCur); U.Stroke(Color3.new(0,0,0),1,HueCur)

    -- Hex input
    local hexBg=U.New("Frame",{
        Size=UDim2.new(1,-16,0,28),Position=UDim2.new(0,8,0,172),
        BackgroundColor3=T.InputBg,ZIndex=21,
    },Panel)
    U.Corner(7,hexBg); U.Stroke(T.Border,1,hexBg)
    U.New("TextLabel",{
        Size=UDim2.new(0,22,1,0),BackgroundTransparency=1,
        Text="#",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=22,
    },hexBg)
    local hexTB=U.New("TextBox",{
        Size=UDim2.new(1,-30,1,0),Position=UDim2.new(0,24,0,0),
        BackgroundTransparency=1,Text=U.ToHex(default),
        PlaceholderText="FF0000",PlaceholderColor3=T.TextMuted,
        TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,
        ClearTextOnFocus=false,ZIndex=22,
    },hexBg)

    -- RGB label
    local rgbL=U.New("TextLabel",{
        Size=UDim2.new(1,-16,0,15),Position=UDim2.new(0,8,0,208),
        BackgroundTransparency=1,
        Text=string.format("R:%d  G:%d  B:%d",
            math.floor(default.R*255),math.floor(default.G*255),math.floor(default.B*255)),
        TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=21,
    },Panel)

    local PANEL_H=232

    local function UpdCol()
        local c=Color3.fromHSV(hv,sv,vv)
        if prev then pcall(function() prev.BackgroundColor3=c end) end
        if SVF then pcall(function() SVF.BackgroundColor3=Color3.fromHSV(hv,1,1) end) end
        if svCur then pcall(function() svCur.Position=UDim2.new(sv,-6,1-vv,-6) end) end
        if HueCur then pcall(function() HueCur.Position=UDim2.new(hv,-5,0,-2) end) end
        if hexTB then pcall(function() hexTB.Text=U.ToHex(c) end) end
        if rgbL then
            pcall(function()
                rgbL.Text=string.format("R:%d  G:%d  B:%d",
                    math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
            end)
        end
        pcall(onChange,c)
    end

    -- SV drag
    local svDrag=false
    local svHit=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=25},SVF)
    svHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if not svDrag or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        if not SVF or not SVF.Parent then return end
        local aw,ah=SVF.AbsoluteSize.X,SVF.AbsoluteSize.Y
        if aw<=0 or ah<=0 then return end
        sv=math.clamp((i.Position.X-SVF.AbsolutePosition.X)/aw,0,1)
        vv=1-math.clamp((i.Position.Y-SVF.AbsolutePosition.Y)/ah,0,1)
        UpdCol()
    end)

    -- Hue drag
    local hueDrag=false
    local hueHit=U.New("TextButton",{Size=UDim2.new(1,0,3,0),Position=UDim2.new(0,0,-1,0),BackgroundTransparency=1,Text="",ZIndex=23},HueB)
    hueHit.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if not hueDrag or i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        if not HueB or not HueB.Parent then return end
        local aw=HueB.AbsoluteSize.X; if aw<=0 then return end
        hv=math.clamp((i.Position.X-HueB.AbsolutePosition.X)/aw,0,1)
        UpdCol()
    end)

    if hexTB then
        hexTB.FocusLost:Connect(function()
            local c=U.FromHex(hexTB.Text)
            hv,sv,vv=Color3.toHSV(c); UpdCol()
        end)
    end

    -- Toggle open — Panel flutua na screen, posicionado sob o Wrap
    local PANEL_W = 0 -- calculado em runtime
    local openBtn=U.New("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,Text="",ZIndex=7},Wrap)
    local function PositionPanel()
        if not Wrap or not Wrap.Parent then return end
        local abs = Wrap.AbsolutePosition
        local absW = Wrap.AbsoluteSize.X
        pcall(function()
            Panel.Size = UDim2.new(0,absW,0,0)
            Panel.Position = UDim2.new(0, abs.X, 0, abs.Y + 44 + 4)
        end)
    end
    openBtn.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        if isOpen then
            PositionPanel()
            Panel.Visible=true
            U.Tween(Panel,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,PANEL_H)},0.24,Enum.EasingStyle.Quart)
            U.Tween(chev,{Rotation=180},0.2)
        else
            U.Tween(Panel,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,0)},0.22)
            U.Tween(chev,{Rotation=0},0.2)
            task.delay(0.24,function() if Panel and Panel.Parent then Panel.Visible=false end end)
        end
    end)

    local Obj={}
    function Obj:Get() return Color3.fromHSV(hv,sv,vv) end
    function Obj:Set(c)
        if type(c)~="userdata" then return end
        hv,sv,vv=Color3.toHSV(c); UpdCol()
    end
    return Obj
end

-- ════════════════════════════════════════════════
-- ANIMAÇÃO DE INTRO
-- ════════════════════════════════════════════════
local function PlayIntro(screen,T,title,onDone)
    -- Intro: overlay semitransparente (não tela cheia preta sólida)
    local overlay=U.New("Frame",{
        Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.fromRGB(4,4,10),
        BackgroundTransparency=0.28,ZIndex=900,
    },screen)
    -- sem Corner no overlay para cobrir a tela toda (sem borda cortada no topo)

    local logoBox=U.New("Frame",{
        Size=UDim2.new(0,52,0,52),
        Position=UDim2.new(0.5,-26,0.5,-40),
        BackgroundColor3=T.Accent,BackgroundTransparency=1,ZIndex=901,
    },screen)
    U.Corner(18,logoBox); TrackAccent(logoBox,"BackgroundColor3")
    U.New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="☀",TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBlack,TextSize=38,ZIndex=902,
    },logoBox)

    local titLbl=U.New("TextLabel",{
        Size=UDim2.new(0,380,0,32),
        Position=UDim2.new(0.5,-190,0.5,18),
        BackgroundTransparency=1,Text="",
        TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=20,ZIndex=901,
    },screen)
    local subLbl=U.New("TextLabel",{
        Size=UDim2.new(0,380,0,18),
        Position=UDim2.new(0.5,-190,0.5,50),
        BackgroundTransparency=1,Text="Carregando...",
        TextColor3=Color3.fromRGB(160,160,200),Font=Enum.Font.Gotham,
        TextSize=12,TextTransparency=1,ZIndex=901,
    },screen)

    -- linha accent animada
    local aline=U.New("Frame",{
        Size=UDim2.new(0,0,0,2),
        Position=UDim2.new(0.5,0,0.5,16),
        AnchorPoint=Vector2.new(0.5,0),
        BackgroundColor3=T.Accent,ZIndex=901,
    },screen)
    TrackAccent(aline,"BackgroundColor3")

    -- Partículas
    local parts={}
    for i=1,10 do
        local px,py=math.random(60,580),math.random(60,380)
        local sz=math.random(2,5)
        local p=U.New("Frame",{
            Size=UDim2.new(0,sz,0,sz),Position=UDim2.new(0,px,0,py),
            BackgroundColor3=T.Accent,BackgroundTransparency=1,
            ZIndex=901,Rotation=math.random(0,60),
        },screen)
        U.Corner(2,p); table.insert(parts,p)
    end

    task.spawn(function()
        task.wait(0.1)
        U.Spring(logoBox,{BackgroundTransparency=0},0.45)
        task.wait(0.28)
        for i,p in ipairs(parts) do
            task.delay(i*0.03,function()
                if p and p.Parent then
                    U.Tween(p,{BackgroundTransparency=0.45},0.25)
                    task.delay(0.9,function()
                        if p and p.Parent then U.Tween(p,{BackgroundTransparency=1},0.4) end
                    end)
                end
            end)
        end
        task.wait(0.1)
        U.Tween(titLbl,{TextTransparency=0},0.18)
        U.Typewriter(titLbl,title,0.048,function()
            if subLbl then U.Tween(subLbl,{TextTransparency=0},0.28) end
            U.Tween(aline,{Size=UDim2.new(0,math.min(#title*14,380),0,2)},0.4,Enum.EasingStyle.Quart)
        end)
        task.wait(1.1)
        -- saída
        U.Tween(logoBox,{Position=UDim2.new(0.5,-36,-0.18,-36),BackgroundTransparency=1},0.45,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        U.Tween(titLbl,{TextTransparency=1},0.35)
        U.Tween(subLbl,{TextTransparency=1},0.3)
        U.Tween(aline,{Size=UDim2.new(0,0,0,2)},0.3)
        for _,p in ipairs(parts) do if p and p.Parent then U.Tween(p,{BackgroundTransparency=1},0.25) end end
        U.Tween(overlay,{BackgroundTransparency=1},0.48)
        task.wait(0.55)
        for _,p in ipairs(parts) do pcall(function() if p and p.Parent then p:Destroy() end end) end
        for _,o in ipairs({logoBox,titLbl,subLbl,aline,overlay}) do
            pcall(function() if o and o.Parent then o:Destroy() end end)
        end
        pcall(onDone)
    end)
end

-- ════════════════════════════════════════════════
-- BACKGROUND MANAGER
-- ════════════════════════════════════════════════
local function MakeBgManager(container,T,onApply)
    local saved={}
    if readfile then
        pcall(function()
            local raw=readfile("SunUI_Backgrounds.json")
            if type(raw)=="string" and raw~="" then
                local ok,dec=pcall(function() return HttpService:JSONDecode(raw) end)
                if ok and type(dec)=="table" then saved=dec end
            end
        end)
    end
    local function Persist()
        if not writefile then return end
        pcall(function() writefile("SunUI_Backgrounds.json",HttpService:JSONEncode(saved)) end)
    end

    -- Row: input de link
    local inputRow=U.New("Frame",{Size=UDim2.new(1,0,0,64),BackgroundColor3=T.SurfaceHigh,ZIndex=4},container)
    U.Corner(9,inputRow)
    U.New("TextLabel",{
        Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,5),
        BackgroundTransparency=1,Text="Background – Asset ID (número)",
        TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    },inputRow)
    U.New("TextLabel",{
        Size=UDim2.new(1,-16,0,11),Position=UDim2.new(0,10,0,19),
        BackgroundTransparency=1,Text="Digite o Asset ID numérico (ex: 6023426952)",
        TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    },inputRow)
    local iArea=U.New("Frame",{
        Size=UDim2.new(1,-52,0,26),Position=UDim2.new(0,10,0,36),
        BackgroundColor3=T.InputBg,ZIndex=5,
    },inputRow)
    U.Corner(7,iArea); local iS=U.Stroke(T.Border,1,iArea)
    local iTB=U.New("TextBox",{
        Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),
        BackgroundTransparency=1,Text="",PlaceholderText="ex: 6023426952",
        PlaceholderColor3=T.TextMuted,TextColor3=T.Text,
        Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=false,ZIndex=6,
    },iArea)
    if iTB then
        iTB.Focused:Connect(function() if iS then U.Tween(iS,{Color=T.Accent},0.15) end end)
        iTB.FocusLost:Connect(function() if iS then U.Tween(iS,{Color=T.Border},0.15) end end)
    end
    local applyBtn=U.New("TextButton",{
        Size=UDim2.new(0,36,0,26),Position=UDim2.new(1,-46,0,36),
        BackgroundColor3=T.Accent,Text="✓",
        TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,ZIndex=5,
    },inputRow)
    U.Corner(7,applyBtn); TrackAccent(applyBtn,"BackgroundColor3")

    local function ApplyBg(idOrUrl)
        if not idOrUrl or idOrUrl=="" then return end
        local img
        if idOrUrl:match("^%d+$") then img="rbxassetid://"..idOrUrl
        elseif idOrUrl:match("^rbxassetid://") then img=idOrUrl
        else img=idOrUrl end
        pcall(onApply,img)
        for i,s in ipairs(saved) do if s==idOrUrl then table.remove(saved,i) break end end
        table.insert(saved,1,idOrUrl); if #saved>12 then table.remove(saved) end
        Persist()
    end
    if applyBtn then applyBtn.MouseButton1Click:Connect(function() if iTB then ApplyBg(iTB.Text) end end) end
    if iTB then iTB.FocusLost:Connect(function(e) if e then ApplyBg(iTB.Text) end end) end

    -- Row: backgrounds salvos
    local sOpen=false; local sSel="--"
    local savedRow=U.New("Frame",{Size=UDim2.new(1,0,0,58),BackgroundColor3=T.SurfaceHigh,ZIndex=4},container)
    U.Corner(9,savedRow)
    U.New("TextLabel",{
        Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,5),
        BackgroundTransparency=1,Text="Backgrounds Salvos",
        TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    },savedRow)
    U.New("TextLabel",{
        Size=UDim2.new(1,-16,0,10),Position=UDim2.new(0,10,0,20),
        BackgroundTransparency=1,Text="Selecione um background utilizado anteriormente",
        TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    },savedRow)
    local sF=U.New("Frame",{Size=UDim2.new(1,-20,0,24),Position=UDim2.new(0,10,0,32),BackgroundColor3=T.Surface,ZIndex=5},savedRow)
    U.Corner(7,sF); U.Stroke(T.Border,1,sF)
    local sLbl=U.New("TextLabel",{Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Text="--",TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},sF)
    U.New("TextLabel",{Size=UDim2.new(0,16,1,0),Position=UDim2.new(1,-18,0,0),BackgroundTransparency=1,Text="▾",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=6},sF)
    local sList=U.New("Frame",{Size=UDim2.new(1,-20,0,0),Position=UDim2.new(0,10,0,60),BackgroundColor3=T.Surface,ClipsDescendants=true,ZIndex=10},savedRow)
    U.Corner(8,sList); U.Stroke(T.Border,1,sList)
    local sLL=U.List(2,Enum.HorizontalAlignment.Center,sList); U.Pad(3,3,5,5,sList)

    local function RebuildSaved()
        if not sList or not sList.Parent then return end
        pcall(function()
            for _,ch in ipairs(sList:GetChildren()) do
                if ch:IsA("TextButton") then ch:Destroy() end
            end
        end)
        for _,s in ipairs(saved) do
            local sb=U.New("TextButton",{Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Surface,Text="",ZIndex=11},sList)
            U.Corner(6,sb)
            U.New("TextLabel",{Size=UDim2.new(1,-6,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text=tostring(s):sub(1,34),TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},sb)
            sb.MouseEnter:Connect(function() U.Tween(sb,{BackgroundColor3=T.SurfaceHover},0.1) end)
            sb.MouseLeave:Connect(function() U.Tween(sb,{BackgroundColor3=T.Surface},0.1) end)
            sb.MouseButton1Click:Connect(function()
                sSel=s; if sLbl then sLbl.Text=tostring(s):sub(1,30) end
                sOpen=false
                U.Tween(savedRow,{Size=UDim2.new(1,0,0,58)},0.22)
                U.Tween(sList,{Size=UDim2.new(1,-20,0,0)},0.22)
                task.delay(0.25,function() if sList then sList.Visible=false end end)
                ApplyBg(s)
            end)
        end
    end

    local sHit=U.New("TextButton",{Size=UDim2.new(1,-20,0,24),Position=UDim2.new(0,10,0,32),BackgroundTransparency=1,Text="",ZIndex=7},savedRow)
    sHit.MouseButton1Click:Connect(function()
        sOpen=not sOpen; local h=math.min(#saved*26+8,132)
        sList.Visible=sOpen
        if sOpen then RebuildSaved(); U.Tween(savedRow,{Size=UDim2.new(1,0,0,58+h)},0.24,Enum.EasingStyle.Quart); U.Tween(sList,{Size=UDim2.new(1,-20,0,h)},0.24,Enum.EasingStyle.Quart)
        else U.Tween(savedRow,{Size=UDim2.new(1,0,0,58)},0.22); U.Tween(sList,{Size=UDim2.new(1,-20,0,0)},0.22); task.delay(0.25,function() if sList then sList.Visible=false end end) end
    end)

    -- Remove background atual
    local remBtn=U.New("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.SurfaceHigh,Text="",ZIndex=4},container)
    U.Corner(9,remBtn); U.Ripple(remBtn,T.Bad)
    local remIb=U.New("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,10,0.5,-15),BackgroundColor3=U.Lerp(T.Bad,Color3.new(0,0,0),0.65),ZIndex=5},remBtn)
    U.Corner(8,remIb)
    U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="✕",TextColor3=T.Bad,Font=Enum.Font.GothamBold,TextSize=14,ZIndex=6},remIb)
    U.New("TextLabel",{Size=UDim2.new(1,-52,0,18),Position=UDim2.new(0,50,0,6),BackgroundTransparency=1,Text="Remover Background Atual",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},remBtn)
    U.New("TextLabel",{Size=UDim2.new(1,-52,0,14),Position=UDim2.new(0,50,0,25),BackgroundTransparency=1,Text="Limpa a imagem de fundo da janela",TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},remBtn)
    remBtn.MouseEnter:Connect(function() U.Tween(remBtn,{BackgroundColor3=T.SurfaceHover},0.15) end)
    remBtn.MouseLeave:Connect(function() U.Tween(remBtn,{BackgroundColor3=T.SurfaceHigh},0.15) end)
    remBtn.MouseButton1Click:Connect(function() pcall(onApply,"") end)

    -- Deletar da lista
    local delBtn=U.New("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.SurfaceHigh,Text="",ZIndex=4},container)
    U.Corner(9,delBtn); U.Ripple(delBtn,T.Warn)
    local delIb=U.New("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,10,0.5,-15),BackgroundColor3=U.Lerp(T.Warn,Color3.new(0,0,0),0.65),ZIndex=5},delBtn)
    U.Corner(8,delIb)
    U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="🗑",TextColor3=T.Warn,Font=Enum.Font.GothamBold,TextSize=13,ZIndex=6},delIb)
    U.New("TextLabel",{Size=UDim2.new(1,-52,0,18),Position=UDim2.new(0,50,0,6),BackgroundTransparency=1,Text="Deletar da Lista",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},delBtn)
    U.New("TextLabel",{Size=UDim2.new(1,-52,0,14),Position=UDim2.new(0,50,0,25),BackgroundTransparency=1,Text="Remove o selecionado dos backgrounds salvos",TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},delBtn)
    delBtn.MouseEnter:Connect(function() U.Tween(delBtn,{BackgroundColor3=T.SurfaceHover},0.15) end)
    delBtn.MouseLeave:Connect(function() U.Tween(delBtn,{BackgroundColor3=T.SurfaceHigh},0.15) end)
    delBtn.MouseButton1Click:Connect(function()
        if sSel=="--" then return end
        for i,s in ipairs(saved) do if s==sSel then table.remove(saved,i) break end end
        Persist(); sSel="--"; if sLbl then sLbl.Text="--" end
    end)
end

-- ════════════════════════════════════════════════
-- WATERMARK FLUTUANTE
-- ════════════════════════════════════════════════
function SunUI:SetWatermark(opts)
    opts=opts or {}
    local text=tostring(opts.Text or "SunUI")
    local pos=opts.Position or UDim2.new(0,8,0,8)
    local T=self.Theme or self.Themes.Dark

    if self._watermark and self._watermark.Parent then self._watermark:Destroy() end
    local screen=self._screen
    if not screen then return end

    local wm=U.New("Frame",{
        Size=UDim2.new(0,0,0,28),
        Position=pos,
        BackgroundColor3=T.SurfaceHigh,
        BackgroundTransparency=0.1,
        ZIndex=200,
    },screen)
    U.Corner(8,wm)
    local wmS=U.Stroke(T.Accent,1.5,wm); TrackBorder(wmS)
    U.Pad(0,0,10,10,wm)
    local wmL=U.New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text=text,TextColor3=T.Text,
        Font=Enum.Font.GothamBold,TextSize=12,ZIndex=201,
    },wm)
    -- Autosize
    task.spawn(function()
        task.wait(0.05)
        if wmL and wm and wm.Parent then
            local tw=wmL.TextBounds.X+24
            U.Tween(wm,{Size=UDim2.new(0,tw,0,28)},0.22)
        end
    end)
    U.Draggable(wm,wm)
    self._watermark=wm
    return {
        Set=function(_,t)
            if wmL then pcall(function() wmL.Text=tostring(t) end) end
            task.spawn(function()
                task.wait(0.05)
                if wmL and wm and wm.Parent then
                    U.Tween(wm,{Size=UDim2.new(0,wmL.TextBounds.X+24,0,28)},0.15)
                end
            end)
        end,
        Hide=function()
            if wm and wm.Parent then
                U.Tween(wm,{BackgroundTransparency=1},0.18)
                task.delay(0.2,function() if wm and wm.Parent then wm.Visible=false end end)
            end
        end,
        Show=function(_,newText)
            if wm and wm.Parent then
                if newText and wmL then pcall(function() wmL.Text=tostring(newText) end) end
                wm.Visible=true; wm.BackgroundTransparency=0.1
                U.Tween(wm,{BackgroundTransparency=0.1},0.18)
            end
        end,
    }
end

-- ════════════════════════════════════════════════
-- STATS WIDGET  (Ping / FPS / Players)
-- ════════════════════════════════════════════════
function SunUI:CreateStatsWidget(opts)
    opts=opts or {}
    local T=self.Theme or self.Themes.Dark
    local pos=opts.Position or UDim2.new(1,-120,0,8)
    local screen=self._screen
    if not screen then return {} end

    if self._statsHud and self._statsHud.Parent then self._statsHud:Destroy() end

    local frame=U.New("Frame",{
        Size=UDim2.new(0,112,0,68),
        Position=pos,
        BackgroundColor3=T.SurfaceHigh,
        BackgroundTransparency=0.1,ZIndex=200,
    },screen)
    U.Corner(9,frame)
    local fs=U.Stroke(T.Accent,1.5,frame); TrackBorder(fs)
    U.Draggable(frame,frame)

    -- Header
    local hdr=U.New("Frame",{Size=UDim2.new(1,0,0,18),BackgroundColor3=T.Accent,ZIndex=201},frame)
    U.Corner(9,hdr); TrackAccent(hdr,"BackgroundColor3")
    -- Mask bottom corners of header
    local hdrMask=U.New("Frame",{Size=UDim2.new(1,0,0,9),Position=UDim2.new(0,0,1,-9),BackgroundColor3=T.Accent,ZIndex=201},hdr)
    if hdrMask then TrackAccent(hdrMask,"BackgroundColor3") end
    U.New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="☀ STATS",TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBold,TextSize=9,ZIndex=202,
    },hdr)

    local function StatRow(y,icon,id)
        local row=U.New("Frame",{
            Size=UDim2.new(1,-8,0,14),Position=UDim2.new(0,4,0,y),
            BackgroundTransparency=1,ZIndex=201,
        },frame)
        U.New("TextLabel",{
            Size=UDim2.new(0,16,1,0),BackgroundTransparency=1,
            Text=icon,TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=202,
        },row)
        local val=U.New("TextLabel",{
            Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,18,0,0),
            BackgroundTransparency=1,Text="--",
            TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=10,
            TextXAlignment=Enum.TextXAlignment.Right,ZIndex=202,
        },row)
        return val
    end

    local fpsLbl   = StatRow(20,"⚡","fps")
    local pingLbl  = StatRow(36,"📶","ping")
    local plyrLbl  = StatRow(52,"👥","players")

    -- Update loop
    local lastTime=tick(); local frameCount=0; local fps=0
    local conn=RunService.RenderStepped:Connect(function()
        frameCount=frameCount+1
        local now=tick()
        local dt=now-lastTime
        if dt>=0.5 then
            fps=math.floor(frameCount/dt+0.5); frameCount=0; lastTime=now
        end
        -- Ping
        local ping=0
        if Stats then
            pcall(function() ping=math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue()) end)
        end
        -- Players
        local pc=0
        pcall(function() pc=#Players:GetPlayers() end)

        -- Colorir FPS
        local fpsClr
        if fps>=55 then fpsClr=T.Good
        elseif fps>=30 then fpsClr=T.Warn
        else fpsClr=T.Bad end

        if fpsLbl  then pcall(function() fpsLbl.Text=fps.." FPS"; fpsLbl.TextColor3=fpsClr end) end
        if pingLbl then pcall(function() pingLbl.Text=ping.." ms" end) end
        if plyrLbl then pcall(function() plyrLbl.Text=pc.." online" end) end
    end)

    self._statsHud=frame
    return {
        Frame=frame,
        Hide=function()
            -- Pausa o loop mas não destrói — permite reativar
            if frame and frame.Parent then
                U.Tween(frame,{BackgroundTransparency=1},0.15)
                task.delay(0.18,function() if frame and frame.Parent then frame.Visible=false end end)
            end
        end,
        Show=function()
            if frame and frame.Parent then
                frame.Visible=true
                U.Tween(frame,{BackgroundTransparency=0.1},0.18)
            end
        end,
        Destroy=function()
            pcall(function() conn:Disconnect() end)
            if frame and frame.Parent then frame:Destroy() end
        end,
    }
end

-- ════════════════════════════════════════════════
-- CURSOR TRAIL
-- ════════════════════════════════════════════════
function SunUI:EnableCursorTrail(opts)
    opts=opts or {}
    local T=self.Theme or self.Themes.Dark
    local color=opts.Color or T.Accent
    local size=opts.Size or 6
    local life=opts.Life or 0.4
    local screen=self._screen
    if not screen then return end
    if self._curConn then pcall(function() self._curConn:Disconnect() end) end
    self._curTrail=true

    local function Spawn(x,y)
        local p=U.New("Frame",{
            Size=UDim2.new(0,size,0,size),
            Position=UDim2.new(0,x-size/2,0,y-size/2),
            BackgroundColor3=color,
            BackgroundTransparency=0.4,
            ZIndex=900,
        },screen)
        U.Corner(999,p); TrackAccent(p,"BackgroundColor3")
        U.Tween(p,{BackgroundTransparency=1,Size=UDim2.new(0,size*1.8,0,size*1.8)},life,Enum.EasingStyle.Quad)
        task.delay(life+0.05,function() if p and p.Parent then p:Destroy() end end)
    end

    local lastPos=Vector2.new(-999,-999)
    self._curConn=UserInputService.InputChanged:Connect(function(i)
        if not self._curTrail then return end
        if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
        local mp=Vector2.new(i.Position.X,i.Position.Y)
        if (mp-lastPos).Magnitude>8 then
            Spawn(mp.X,mp.Y); lastPos=mp
        end
    end)
end

function SunUI:DisableCursorTrail()
    self._curTrail=false
    if self._curConn then pcall(function() self._curConn:Disconnect() end) end
end

-- ════════════════════════════════════════════════
-- CRIAR JANELA — PONTO DE ENTRADA
-- ════════════════════════════════════════════════
function SunUI:CreateWindow(opts)
    opts=opts or {}

    -- ── Resolver tema
    local T
    if type(opts.Theme)=="table" then T=opts.Theme
    elseif opts.Theme and self.Themes[opts.Theme] then T=self.Themes[opts.Theme]
    else T=self.Themes.Dark end
    if opts.AccentColor then
        local base=T; T={}
        for k,v in pairs(base) do T[k]=v end
        T.Accent=opts.AccentColor; T.AccentB=opts.AccentColor2 or opts.AccentColor
        T.AccentHover=U.Lerp(opts.AccentColor,Color3.new(0,0,0),0.15)
        T.AccentDim=U.Lerp(opts.AccentColor,Color3.new(0,0,0),0.55)
    end
    self.Theme=T
    self._accent1=T.Accent; self._accent2=T.AccentB

    -- ── Opções
    local title=tostring(opts.Title or "SunUI")
    local subtitle=tostring(opts.Subtitle or "")
    local version=opts.Version
    local toggleKey=opts.ToggleKey or Enum.KeyCode.RightShift
    local W=tonumber(opts.Width) or 720
    local H=tonumber(opts.Height) or 500
    local rainbow=opts.RainbowBorder==true
    local showIntro=opts.Intro~=false
    local keyOpts=opts.KeySystem
    local discordUrl=opts.DiscordUrl
    local notifyPos=opts.NotifyPosition or "BotRight"

    self._notifyPos=notifyPos
    SaveMgr:SetFile(tostring(opts.ConfigFile or "SunUI_Config"))

    -- Limpar instância anterior (tenta nos três containers possíveis)
    for _,_n in ipairs({"SunUI_6_0","SunUI_5_5","SunUI_5_4","SunUI_5_3","SunUI_5_2","SunUI_5_1"}) do
        pcall(function() CoreGui[_n]:Destroy() end)
        if LP then pcall(function() LP.PlayerGui[_n]:Destroy() end) end
        if gethui then pcall(function() gethui()[_n]:Destroy() end) end
    end

    -- Reset tracking
    self._borders={}; self._accents={}
    self._rbRunning=false; self._notifyCon=nil
    self._tipFrame=nil; self._tipLabel=nil

    -- ── ScreenGui — ordem de tentativas:
    -- 1. gethui()         (Xeno, Fluxus, Delta)
    -- 2. cloneref CoreGui (Synapse X, KRNL)
    -- 3. CoreGui direto   (outros)
    -- 4. PlayerGui        (fallback universal)
    local Screen
    local GUI_NAME = "SunUI_6_0"

    -- Tentativa 1: gethui() — método preferido no Xeno
    if not Screen and type(gethui) == "function" then
        pcall(function()
            local hui = gethui()
            Screen = Instance.new("ScreenGui")
            Screen.Name = GUI_NAME
            Screen.ResetOnSpawn = false
            Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Screen.Parent = hui
        end)
        if Screen and not Screen.Parent then Screen = nil end
    end

    -- Tentativa 2: cloneref(CoreGui) — Synapse X / KRNL
    if not Screen and type(cloneref) == "function" then
        pcall(function()
            local safeCore = cloneref(game:GetService("CoreGui"))
            Screen = Instance.new("ScreenGui")
            Screen.Name = GUI_NAME
            Screen.ResetOnSpawn = false
            Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Screen.Parent = safeCore
        end)
        if Screen and not Screen.Parent then Screen = nil end
    end

    -- Tentativa 3: CoreGui direto
    if not Screen then
        pcall(function()
            Screen = Instance.new("ScreenGui")
            Screen.Name = GUI_NAME
            Screen.ResetOnSpawn = false
            Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Screen.Parent = CoreGui
        end)
        if Screen and not Screen.Parent then Screen = nil end
    end

    -- Tentativa 4: PlayerGui (fallback universal)
    if not Screen then
        pcall(function()
            local pg = LP and LP:WaitForChild("PlayerGui", 5)
            if not pg then return end
            Screen = Instance.new("ScreenGui")
            Screen.Name = GUI_NAME
            Screen.ResetOnSpawn = false
            Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            Screen.Parent = pg
        end)
    end

    if not Screen then return {} end

    -- protect_gui — tenta todos os métodos conhecidos
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(Screen) end end)
    pcall(function() if protect_gui then protect_gui(Screen) end end)
    -- gethui() ja eh seguro por natureza no Xeno (nao precisa de protect)

    self._screen=Screen
    SetupTooltip(Screen,T)
    RebuildNotifyContainer(Screen)

    -- ── Sombra (referência local para hide/show no toggle)
    local Shadow=U.New("ImageLabel",{
        AnchorPoint=Vector2.new(0.5,0.5),
        Size=UDim2.new(0,W+110,0,H+110),
        Position=UDim2.new(0.5,0,0.5,0),
        BackgroundTransparency=1,
        Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0),
        ImageTransparency=0.45,
        ScaleType=Enum.ScaleType.Slice,
        SliceCenter=Rect.new(49,49,450,450),
        ZIndex=0,
    },Screen)

    -- ── Main frame — wrapper com borda arredondada + inner com clip
    -- O wrapper tem Corner+Stroke e NÃO clipsa (para borda aparecer corretamente)
    -- O Inner dentro dele clipsa o conteúdo
    local MainWrap=U.New("Frame",{
        Name="MainWrap",
        Size=UDim2.new(0,W,0,0),
        Position=UDim2.new(0.5,-W/2,0.5,-H/2),
        BackgroundColor3=T.Bg,
        ClipsDescendants=false,ZIndex=1,
    },Screen)
    U.Corner(12,MainWrap)
    local mainStroke=U.Stroke(T.Accent,2,MainWrap); TrackBorder(mainStroke)
    -- Main interno (com clip para conteúdo não vazar)
    local Main=U.New("Frame",{
        Name="Main",
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=T.Bg,
        ClipsDescendants=true,ZIndex=1,
    },MainWrap)
    U.Corner(12,Main)

    -- Background image
    local BgImg=U.New("ImageLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Image="",ImageTransparency=0.45,
        ScaleType=Enum.ScaleType.Crop,ZIndex=0,
    },Main)
    local BgOv=U.New("Frame",{
        Size=UDim2.new(1,0,1,0),
        BackgroundColor3=T.Bg,BackgroundTransparency=0.1,ZIndex=0,
    },Main)
    local function SetBg(imgId)
        if not BgImg then return end
        local hasImg = imgId and imgId~=""
        pcall(function() BgImg.Image=imgId or "" end)
        pcall(function() BgOv.BackgroundTransparency=hasImg and 0.55 or 0 end)
    end

    -- Versão guardada para usar na titlebar

    -- ── Titlebar
    local TH=48
    local TBar=U.New("Frame",{
        Size=UDim2.new(1,0,0,TH),BackgroundColor3=T.TitleBar,ZIndex=5,
    },Main)
    local topLine=U.New("Frame",{
        Size=UDim2.new(1,0,0,2),BackgroundColor3=T.Accent,ZIndex=6,
    },TBar)
    TrackAccent(topLine,"BackgroundColor3")
    U.New("Frame",{
        Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),
        BackgroundColor3=T.Border,ZIndex=5,
    },TBar)

    -- Logo
    local logoF=U.New("Frame",{
        Size=UDim2.new(0,32,0,32),Position=UDim2.new(0,12,0.5,-16),
        BackgroundColor3=T.Accent,ZIndex=7,
    },TBar)
    U.Corner(8,logoF); TrackAccent(logoF,"BackgroundColor3")
    U.New("TextLabel",{
        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
        Text="☀",TextColor3=Color3.new(1,1,1),
        Font=Enum.Font.GothamBlack,TextSize=17,ZIndex=8,
    },logoF)

    local titleLbl=U.New("TextLabel",{
        Size=UDim2.new(0,230,0,20),Position=UDim2.new(0,52,0,8),
        BackgroundTransparency=1,Text=title,
        TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,
    },TBar)
    U.New("TextLabel",{
        Size=UDim2.new(0,180,0,14),Position=UDim2.new(0,52,0,26),
        BackgroundTransparency=1,
        Text=(subtitle~="") and subtitle or "",
        TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,
    },TBar)
    -- Versão abaixo do subtítulo na titlebar
    if version then
        local verStr = "v"..tostring(version):gsub("^v","")
        local verLbl=U.New("TextLabel",{
            Size=UDim2.new(0,120,0,12),
            Position=UDim2.new(0,52,0,(subtitle~="") and 34 or 26),
            BackgroundTransparency=1,
            Text=verStr,
            TextColor3=T.Accent,Font=Enum.Font.GothamBold,TextSize=9,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,
        },TBar)
        TrackAccent(verLbl,"TextColor3")
    end

    -- Dropdown de tema na titlebar
    local themeNames={}
    for k in pairs(self.Themes) do table.insert(themeNames,k) end
    table.sort(themeNames)
    local themeOpen=false
    local themeBtnF=U.New("Frame",{
        Size=UDim2.new(0,100,0,26),Position=UDim2.new(1,-272,0.5,-13),
        BackgroundColor3=T.Surface,ZIndex=7,
    },TBar)
    U.Corner(8,themeBtnF); U.Stroke(T.Border,1,themeBtnF)
    local themeLbl=U.New("TextLabel",{
        Size=UDim2.new(1,-18,1,0),Position=UDim2.new(0,6,0,0),
        BackgroundTransparency=1,Text=T.Name or "Dark",
        TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=10,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8,
    },themeBtnF)
    U.New("TextLabel",{
        Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-16,0,0),
        BackgroundTransparency=1,Text="▾",TextColor3=T.TextMuted,
        Font=Enum.Font.GothamBold,TextSize=10,ZIndex=8,
    },themeBtnF)
    local themeDD=U.New("Frame",{
        Size=UDim2.new(0,100,0,0),Position=UDim2.new(1,-272,0,TH+2),
        BackgroundColor3=T.Surface,ClipsDescendants=true,ZIndex=200,
    },Main)
    U.Corner(8,themeDD); U.Stroke(T.Border,1,themeDD)
    local tddL=U.List(2,Enum.HorizontalAlignment.Center,themeDD); U.Pad(3,3,4,4,themeDD)
    for _,tn in ipairs(themeNames) do
        local tb2=U.New("TextButton",{
            Size=UDim2.new(1,0,0,24),BackgroundColor3=T.Surface,
            Text=tn,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,ZIndex=51,
        },themeDD)
        U.Corner(6,tb2)
        tb2.MouseEnter:Connect(function() U.Tween(tb2,{BackgroundColor3=T.SurfaceHover},0.1) end)
        tb2.MouseLeave:Connect(function() U.Tween(tb2,{BackgroundColor3=T.Surface},0.1) end)
        tb2.MouseButton1Click:Connect(function()
            themeOpen=false
            U.Tween(themeDD,{Size=UDim2.new(0,100,0,0)},0.22)
            task.delay(0.25,function() if themeDD then themeDD.Visible=false end end)
            if themeLbl then themeLbl.Text=tn end
            -- Aplica tema na hora (recria a janela com novo tema)
            local newT = SunUI.Themes[tn]
            if newT then
                -- Atualiza cor de fundo principal
                pcall(function() Main.BackgroundColor3 = newT.Bg end)
                pcall(function() TBar.BackgroundColor3 = newT.TitleBar end)
                pcall(function() Side.BackgroundColor3 = newT.Sidebar end)
                pcall(function() Content.BackgroundColor3 = newT.Surface end)
                pcall(function() SearchBar.BackgroundColor3 = newT.SurfaceHigh end)
                -- Atualiza accent tracking
                SunUI.Theme = newT
                for _,s in ipairs(SunUI._borders) do
                    if s and s.Parent then pcall(function() s.Color = newT.Accent end) end
                end
                for _,a in ipairs(SunUI._accents) do
                    if a and a.o and a.o.Parent then pcall(function() a.o[a.p] = newT.Accent end) end
                end
            end
            self:Notify({Title="Tema: "..tn,Message="Tema aplicado!",Type="Success",Duration=2})
        end)
    end
    local themeTotal=#themeNames*26+6
    local themeTrigger=U.New("TextButton",{
        Size=UDim2.new(0,100,0,26),Position=UDim2.new(1,-272,0.5,-13),
        BackgroundTransparency=1,Text="",ZIndex=9,
    },TBar)
    themeTrigger.MouseButton1Click:Connect(function()
        themeOpen=not themeOpen
        if themeOpen then
            themeDD.Visible=true
            U.Tween(themeDD,{Size=UDim2.new(0,100,0,themeTotal)},0.24,Enum.EasingStyle.Quart)
        else
            U.Tween(themeDD,{Size=UDim2.new(0,100,0,0)},0.22)
            task.delay(0.25,function() if themeDD and themeDD.Parent then themeDD.Visible=false end end)
        end
    end)

    -- Botões controle (✕ ─)
    local minimized=false
    local function CtrlBtn(ico,bg,xOff,cb,tip)
        local b=U.New("TextButton",{
            Size=UDim2.new(0,26,0,26),Position=UDim2.new(1,xOff,0.5,-13),
            BackgroundColor3=bg,BackgroundTransparency=0.35,
            Text=ico,TextColor3=Color3.new(1,1,1),
            Font=Enum.Font.GothamBold,TextSize=11,ZIndex=8,
        },TBar)
        U.Corner(999,b)
        b.MouseEnter:Connect(function() U.Tween(b,{BackgroundTransparency=0},0.12) end)
        b.MouseLeave:Connect(function() U.Tween(b,{BackgroundTransparency=0.35},0.12) end)
        b.MouseButton1Click:Connect(function() pcall(cb) end)
        if tip then U.Tooltip(b,tip) end
        return b
    end
    CtrlBtn("✕",Color3.fromRGB(220,50,50),-14,function()
        SaveMgr:Save(SunUI.Flags); StopRainbow()
        U.Tween(MainWrap,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.28)
        if Shadow then U.Tween(Shadow,{ImageTransparency=1},0.22) end
        task.delay(0.32,function() if Screen and Screen.Parent then Screen:Destroy() end end)
    end,"Fechar")
    CtrlBtn("─",T.Border,-46,function()
        minimized=not minimized
        U.Tween(MainWrap,{Size=minimized and UDim2.new(0,W,0,TH) or UDim2.new(0,W,0,H)},0.28,Enum.EasingStyle.Quart)
    end,"Minimizar")

    U.Draggable(MainWrap,TBar)

    -- ── Resize handle (3 pontinhos canto inferior direito)
    local resizeBtn=U.New("TextButton",{
        Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-20,1,-20),
        BackgroundTransparency=1,Text="⋮",
        TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=14,
        ZIndex=10,AnchorPoint=Vector2.new(1,1),
    },Main)
    -- Resize drag logic: arrastar = redimensiona | duplo clique = reset
    local resizing=false; local rsStart=nil; local rsW=W; local rsH=H
    local _lastClickTime=0
    if resizeBtn then
        resizeBtn.MouseEnter:Connect(function()
            U.Tween(resizeBtn,{TextColor3=T.Accent,BackgroundTransparency=0.1},0.12)
        end)
        resizeBtn.MouseLeave:Connect(function()
            if not resizing then U.Tween(resizeBtn,{TextColor3=T.TextMuted,BackgroundTransparency=0.4},0.12) end
        end)
        resizeBtn.InputBegan:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then
                local now=tick()
                if now - _lastClickTime < 0.35 then
                    -- Duplo clique: reset tamanho padrão
                    resizing=false
                    U.Spring(MainWrap,{Size=UDim2.new(0,W,0,H)},0.38)
                    pcall(function() MainWrap.Position=UDim2.new(0.5,-W/2,0.5,-H/2) end)
                    if Shadow then U.Tween(Shadow,{Size=UDim2.new(0,W+110,0,H+110)},0.3) end
                    _lastClickTime=0; return
                end
                _lastClickTime=now
                resizing=true
                rsStart=i.Position
                rsW=MainWrap.AbsoluteSize.X; rsH=MainWrap.AbsoluteSize.Y
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType==Enum.UserInputType.MouseButton1 then resizing=false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if not resizing then return end
            if i.UserInputType~=Enum.UserInputType.MouseMovement then return end
            local dx=i.Position.X-rsStart.X
            local dy=i.Position.Y-rsStart.Y
            local nW=math.clamp(rsW+dx, 420, 900)
            local nH=math.clamp(rsH+dy, 320, 680)
            pcall(function()
                MainWrap.Size=UDim2.new(0,nW,0,nH)
                MainWrap.Position=UDim2.new(0.5,-nW/2,0.5,-nH/2)
                if Shadow then Shadow.Size=UDim2.new(0,nW+110,0,nH+110) end
            end)
        end)
    end

    -- ── Sidebar
    local SW=158
    local Side=U.New("Frame",{
        Size=UDim2.new(0,SW,1,-TH),Position=UDim2.new(0,0,0,TH),
        BackgroundColor3=T.Sidebar,ZIndex=3,
    },Main)
    U.New("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,ZIndex=4},Side)

    -- Avatar
    local avRing=U.New("Frame",{Size=UDim2.new(0,40,0,40),Position=UDim2.new(0,10,0,10),BackgroundColor3=T.Accent,ZIndex=4},Side)
    U.Corner(999,avRing); TrackAccent(avRing,"BackgroundColor3")
    local avImg=U.New("ImageLabel",{
        Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),
        BackgroundColor3=T.SurfaceHigh,
        Image="https://www.roblox.com/headshot-thumbnail/image?userId="..tostring(LP.UserId).."&width=150&height=150&format=png",
        ZIndex=5,
    },avRing)
    U.Corner(999,avImg)
    U.New("TextLabel",{
        Size=UDim2.new(1,-58,0,16),Position=UDim2.new(0,58,0,12),
        BackgroundTransparency=1,Text=LP.DisplayName,
        TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=11,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    },Side)
    -- Rank label: rank system — define SunUI.Ranks = {["username"]="Owner"} antes de CreateWindow
    local rankName = "SunUI v6.0"
    if SunUI.Ranks and type(SunUI.Ranks)=="table" then
        local r = SunUI.Ranks[LP.Name] or SunUI.Ranks[tostring(LP.UserId)]
        if r then rankName = tostring(r) end
    end
    U.New("TextLabel",{
        Size=UDim2.new(1,-58,0,12),Position=UDim2.new(0,58,0,29),
        BackgroundTransparency=1,Text=rankName,
        TextColor3=T.Accent,Font=Enum.Font.GothamBold,TextSize=9,
        TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
    },Side)
    U.New("Frame",{Size=UDim2.new(1,-14,0,1),Position=UDim2.new(0,7,0,58),BackgroundColor3=T.Border,ZIndex=4},Side)

    -- Scroll de abas
    local SideScroll=U.New("ScrollingFrame",{
        Size=UDim2.new(1,0,1,-64),Position=UDim2.new(0,0,0,62),
        BackgroundTransparency=1,ScrollBarThickness=2,
        ScrollBarImageColor3=T.Scrollbar,ZIndex=4,
    },Side)
    local SideList=U.List(2,Enum.HorizontalAlignment.Center,SideScroll)
    U.Pad(4,8,5,5,SideScroll); U.AutoCanvas(SideScroll,SideList,10)

    -- Discord button
    if discordUrl then
        local dcB=U.New("TextButton",{
            Size=UDim2.new(1,-12,0,28),Position=UDim2.new(0,6,1,-34),
            BackgroundColor3=Color3.fromRGB(88,101,242),
            Text="⌁ Discord",TextColor3=Color3.new(1,1,1),
            Font=Enum.Font.GothamBold,TextSize=11,ZIndex=5,
        },Side)
        U.Corner(8,dcB); U.Ripple(dcB,Color3.new(1,1,1))
        dcB.MouseButton1Click:Connect(function()
            pcall(function() game:GetService("GuiService"):OpenBrowserWindow(discordUrl) end)
        end)
    end

    -- ── Content
    local Content=U.New("Frame",{
        Size=UDim2.new(1,-SW,1,-TH),Position=UDim2.new(0,SW,0,TH),
        BackgroundColor3=T.Surface,ClipsDescendants=false,ZIndex=2,
    },Main)
    local SBH=44
    local SearchBar=U.New("Frame",{
        Size=UDim2.new(1,0,0,SBH),BackgroundColor3=T.SurfaceHigh,ZIndex=4,
    },Content)
    U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,ZIndex=4},SearchBar)
    U.New("TextLabel",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,12,0.5,-9),BackgroundTransparency=1,Text="🔍",TextSize=14,ZIndex=5},SearchBar)
    local SearchTB=U.New("TextBox",{
        Size=UDim2.new(1,-80,1,0),Position=UDim2.new(0,32,0,0),
        BackgroundTransparency=1,Text="",
        PlaceholderText="Pesquisar elementos...",PlaceholderColor3=T.TextMuted,
        TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,
        TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=5,
    },SearchBar)
    local searchResLbl=U.New("TextLabel",{
        Size=UDim2.new(0,68,1,0),Position=UDim2.new(1,-72,0,0),
        BackgroundTransparency=1,Text="",
        TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,ZIndex=5,
    },SearchBar)

    local PageHolder=U.New("Frame",{
        Name="Pages",
        Size=UDim2.new(1,0,1,-SBH),Position=UDim2.new(0,0,0,SBH),
        BackgroundTransparency=1,ClipsDescendants=false,ZIndex=3,
    },Content)

    -- ════════════════════════════════════════
    -- WIN OBJECT
    -- ════════════════════════════════════════
    local Win={_tabs={},_active=nil,_searchItems={},_T=T,_screen=Screen}

    -- Toggle visibilidade (anima MainWrap que contém tudo)
    local _guiVisible = true
    UserInputService.InputBegan:Connect(function(inp,gpe)
        if gpe then return end
        if inp.KeyCode==toggleKey then
            if not MainWrap or not MainWrap.Parent then return end
            _guiVisible = not _guiVisible
            if not _guiVisible then
                -- FECHAR
                U.Tween(MainWrap,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},0.24)
                if Shadow then U.Tween(Shadow,{ImageTransparency=1},0.2) end
                task.delay(0.28,function()
                    if MainWrap and MainWrap.Parent then MainWrap.Visible=false end
                    if Shadow then Shadow.Visible=false end
                end)
            else
                -- ABRIR
                if Shadow then Shadow.Visible=true; Shadow.ImageTransparency=0.45 end
                MainWrap.Visible=true
                MainWrap.BackgroundTransparency=1
                MainWrap.Size=UDim2.new(0,W,0,0)
                U.Spring(MainWrap,{Size=UDim2.new(0,W,0,H),BackgroundTransparency=0},0.38)
            end
        end
    end)

    -- Busca global
    if SearchTB then
        SearchTB:GetPropertyChangedSignal("Text"):Connect(function()
            local q=SearchTB.Text:lower():match("^%s*(.-)%s*$")
            local n=0
            for _,item in ipairs(Win._searchItems) do
                if item.el and item.el.Parent then
                    local show=(q=="" or item.name:lower():find(q,1,true))
                    pcall(function() item.el.Visible=show and true or false end)
                    if show then n=n+1 end
                end
            end
            if searchResLbl then
                searchResLbl.Text=(q~="") and (n.." resultado(s)") or ""
            end
        end)
    end

    -- Auto-save
    task.spawn(function()
        while Screen and Screen.Parent do
            task.wait(55)
            SaveMgr:Save(SunUI.Flags)
        end
    end)

    if rainbow then self._rbTick=0; StartRainbow() end

    -- ── Win methods
    function Win:Notify(o) return SunUI:Notify(o) end
    function Win:EnableAutoSave()
        local sv=SaveMgr:Load()
        if type(sv)=="table" then for k,v in pairs(sv) do SunUI.Flags[k]=v end end
        SunUI:Notify({Title="Config restaurada",Message="Valores carregados!",Type="Success"})
    end
    function Win:SetNotifyPosition(p) SunUI:SetNotifyPosition(p) end
    function Win:Watermark(o) return SunUI:SetWatermark(o) end
    function Win:StatsWidget(o) return SunUI:CreateStatsWidget(o) end
    function Win:EnableCursorTrail(o) SunUI:EnableCursorTrail(o) end
    function Win:DisableCursorTrail() SunUI:DisableCursorTrail() end

    -- ── TAB
    function Win:Tab(name, icon, badgeCount)
        icon=icon or "◆"
        local tabName=tostring(name)

        local Btn=U.New("TextButton",{
            Name="Tab_"..tabName,
            Size=UDim2.new(1,0,0,42),
            BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,
            Text="",ZIndex=5,
        },SideScroll)
        U.Corner(8,Btn)

        local acLine=U.New("Frame",{
            Size=UDim2.new(0,3,0,24),Position=UDim2.new(0,0,0.5,-12),
            BackgroundColor3=T.Accent,BackgroundTransparency=1,ZIndex=6,
        },Btn)
        U.Corner(3,acLine); TrackAccent(acLine,"BackgroundColor3")

        local iBox=U.New("Frame",{
            Size=UDim2.new(0,26,0,26),Position=UDim2.new(0,8,0.5,-13),
            BackgroundColor3=T.SurfaceHigh,BackgroundTransparency=0.4,ZIndex=6,
        },Btn)
        U.Corner(7,iBox)
        local iLbl=U.New("TextLabel",{
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            Text=icon,TextColor3=T.TextMuted,
            Font=Enum.Font.GothamBold,TextSize=13,ZIndex=7,
        },iBox)
        local nLbl=U.New("TextLabel",{
            Size=UDim2.new(1,-50,1,0),Position=UDim2.new(0,42,0,0),
            BackgroundTransparency=1,Text=tabName,
            TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=12,
            TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6,
        },Btn)

        -- Badge de contador na aba
        local badgeF=nil
        if badgeCount and badgeCount>0 then
            badgeF=U.New("Frame",{
                Size=UDim2.new(0,18,0,14),Position=UDim2.new(1,-20,0.5,-7),
                BackgroundColor3=T.Bad,ZIndex=8,
            },Btn)
            U.Corner(999,badgeF)
            U.New("TextLabel",{
                Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                Text=tostring(badgeCount),TextColor3=Color3.new(1,1,1),
                Font=Enum.Font.GothamBold,TextSize=9,ZIndex=9,
            },badgeF)
        end

        local Page=U.New("ScrollingFrame",{
            Name="Page_"..tabName,
            Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
            ScrollBarThickness=3,ScrollBarImageColor3=T.Scrollbar,
            Visible=false,ZIndex=3,ClipsDescendants=false,
        },PageHolder)
        local PLayout=U.List(5,Enum.HorizontalAlignment.Center,Page)
        U.Pad(10,10,10,10,Page); U.AutoCanvas(Page,PLayout,10)

        local function Activate()
            for n,tab in pairs(Win._tabs) do
                local active=(n==tabName)
                if active and not tab.Page.Visible then
                    tab.Page.Visible=true
                    pcall(function() tab.Page.Position=UDim2.new(0.05,0,0,0) end)
                    U.Tween(tab.Page,{Position=UDim2.new(0,0,0,0)},0.2,Enum.EasingStyle.Quart)
                elseif not active then
                    tab.Page.Visible=false
                    pcall(function() tab.Page.Position=UDim2.new(0,0,0,0) end)
                end
                U.Tween(tab.Btn,{
                    BackgroundColor3=active and T.SurfaceHover or Color3.new(0,0,0),
                    BackgroundTransparency=active and 0.55 or 1,
                },0.18)
                U.Tween(tab.acLine,{BackgroundTransparency=active and 0 or 1},0.18)
                U.Tween(tab.nLbl,{TextColor3=active and T.Text or T.TextSub},0.15)
                pcall(function()
                    tab.nLbl.Font=active and Enum.Font.GothamBold or Enum.Font.Gotham
                end)
                U.Tween(tab.iLbl,{TextColor3=active and T.TextAccent or T.TextMuted},0.15)
                U.Tween(tab.iBox,{
                    BackgroundColor3=active and T.AccentDim or T.SurfaceHigh,
                    BackgroundTransparency=active and 0.1 or 0.4,
                },0.15)
            end
            Win._active=tabName
        end

        Btn.MouseButton1Click:Connect(Activate)
        Btn.MouseEnter:Connect(function() if Win._active~=tabName then U.Tween(Btn,{BackgroundTransparency=0.85},0.12) end end)
        Btn.MouseLeave:Connect(function() if Win._active~=tabName then U.Tween(Btn,{BackgroundTransparency=1},0.12) end end)

        Win._tabs[tabName]={Btn=Btn,Page=Page,acLine=acLine,nLbl=nLbl,iLbl=iLbl,iBox=iBox}
        if not Win._active then Activate() end

        -- ══════════════════════════════════════
        -- TAB OBJECT
        -- ══════════════════════════════════════
        local Tab={_page=Page,_T=T}

        function Tab:SetBadge(n)
            if not badgeF or not badgeF.Parent then return end
            if n and n>0 then
                pcall(function() badgeF.Visible=true end)
                local _,lbl=pcall(function() return badgeF:FindFirstChildOfClass("TextLabel") end)
                if lbl then pcall(function() lbl.Text=tostring(n) end) end
            else pcall(function() badgeF.Visible=false end) end
        end

        function Tab:Section(secName)
            secName=tostring(secName or "")
            local SWrap=U.New("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,ZIndex=3,ClipsDescendants=false},Page)
            local SL=U.List(3,Enum.HorizontalAlignment.Center,SWrap); U.AutoHeight(SWrap,SL,4)
            local SHead=U.New("Frame",{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,ZIndex=3},SWrap)
            U.New("TextLabel",{
                Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),
                BackgroundTransparency=1,Text=secName:upper(),
                TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=9,
                TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4,
            },SHead)
            U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,ZIndex=3},SHead)

            local Sec={}

            local function Card(h)
                local c=U.New("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=T.SurfaceHigh,ZIndex=4},SWrap)
                U.Corner(9,c); return c
            end
            local function RS(nm,el)
                table.insert(Win._searchItems,{name=tostring(nm),el=el})
            end

            -- ═══ TOGGLE ══════════════════
            function Sec:Toggle(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Toggle"); local desc=opts.Desc
                local def=opts.Default==true; local cb=type(opts.Callback)=="function" and opts.Callback or function()end
                local fid=tostring(opts.Flag or U.ID()); local tip=tostring(opts.Tooltip or "")
                local state=def; SunUI.Flags[fid]=state

                local c=Card(desc and 54 or 44)
                local ib=U.New("Frame",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,10,0.5,-14),BackgroundColor3=state and T.AccentDim or T.TrackBg,ZIndex=5},c)
                U.Corner(7,ib)
                local il=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="◈",TextColor3=state and T.TextAccent or T.TextMuted,Font=Enum.Font.GothamBold,TextSize=13,ZIndex=6},ib)
                U.New("TextLabel",{
                    Size=UDim2.new(1,-96,0,desc and 18 or 28),Position=UDim2.new(0,48,0,desc and 7 or 8),
                    BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,
                    Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5,
                },c)
                if desc then U.New("TextLabel",{Size=UDim2.new(1,-96,0,14),Position=UDim2.new(0,48,0,26),BackgroundTransparency=1,Text=tostring(desc),TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c) end
                local Track=U.New("Frame",{Size=UDim2.new(0,44,0,24),Position=UDim2.new(1,-56,0.5,-12),BackgroundColor3=state and T.Accent or T.ToggleOff,ZIndex=5},c)
                U.Corner(999,Track)
                local Knob=U.New("Frame",{Size=UDim2.new(0,18,0,18),Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9),BackgroundColor3=Color3.new(1,1,1),ZIndex=6},Track)
                U.Corner(999,Knob)
                local hit=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8},c)
                U.Ripple(hit,T.Accent); if tip~="" then U.Tooltip(c,tip) end
                local deps={}
                local function Apply(val)
                    state=val==true; SunUI.Flags[fid]=state
                    U.Tween(Track,{BackgroundColor3=state and T.Accent or T.ToggleOff},0.2)
                    U.Tween(Knob,{Position=state and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)},0.2)
                    U.Tween(ib,{BackgroundColor3=state and T.AccentDim or T.TrackBg},0.2)
                    U.Tween(il,{TextColor3=state and T.TextAccent or T.TextMuted},0.2)
                    if state then U.Pulse(c,T.Accent) end  -- ← pulse ao ativar
                    for _,d in pairs(deps) do
                        if d.el and d.el.Parent then
                            pcall(function() d.el.Visible=d.inv and not state or state end)
                        end
                    end
                    pcall(cb,state)
                end
                hit.MouseButton1Click:Connect(function() Apply(not state) end)
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},0.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},0.15) end)
                RS(lbl,c)
                local Obj={_element=c}
                function Obj:Set(v) Apply(v==true) end
                function Obj:Get() return state end
                function Obj:Toggle() Apply(not state) end
                function Obj:AddDep(el,inv)
                    local tgt=(type(el)=="table" and el._element) or el
                    table.insert(deps,{el=tgt,inv=inv==true})
                    pcall(function() tgt.Visible=state end)
                end
                return Obj
            end

            -- ═══ SLIDER ══════════════════
            function Sec:Slider(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Slider"); local desc=opts.Desc
                local mn=tonumber(opts.Min) or 0; local mx=tonumber(opts.Max) or 100
                local def=math.clamp(tonumber(opts.Default) or mn,mn,mx)
                local suf=tostring(opts.Suffix or ""); local step=tonumber(opts.Step) or 1
                local cb=type(opts.Callback)=="function" and opts.Callback or function()end
                local fid=tostring(opts.Flag or U.ID()); local tip=tostring(opts.Tooltip or "")
                local value=def; SunUI.Flags[fid]=value
                local cH=desc and 58 or 50
                local c=Card(cH)
                U.New("TextLabel",{Size=UDim2.new(0.6,0,0,desc and 18 or 26),Position=UDim2.new(0,10,0,desc and 6 or 7),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                if desc then U.New("TextLabel",{Size=UDim2.new(0.6,0,0,13),Position=UDim2.new(0,10,0,24),BackgroundTransparency=1,Text=tostring(desc),TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c) end
                local vBox=U.New("Frame",{Size=UDim2.new(0,56,0,24),Position=UDim2.new(1,-66,0,desc and 6 or 7),BackgroundColor3=T.Surface,ZIndex=5},c)
                U.Corner(7,vBox); U.Stroke(T.Border,1,vBox)
                local vLbl=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=tostring(value)..suf,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=6},vBox)
                local tY=desc and 42 or 34
                local TBg=U.New("Frame",{Size=UDim2.new(1,-20,0,5),Position=UDim2.new(0,10,0,tY),BackgroundColor3=T.TrackBg,ZIndex=5},c)
                U.Corner(4,TBg)
                local pct=(mx>mn) and (value-mn)/(mx-mn) or 0
                local Fill=U.New("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=T.Accent,ZIndex=6},TBg)
                U.Corner(4,Fill); TrackAccent(Fill,"BackgroundColor3")
                local SKnob=U.New("Frame",{Size=UDim2.new(0,14,0,14),Position=UDim2.new(pct,-7,0.5,-7),BackgroundColor3=Color3.new(1,1,1),ZIndex=7},TBg)
                U.Corner(999,SKnob); local sk=U.Stroke(T.Accent,2,SKnob); TrackBorder(sk)
                local hitBox=U.New("TextButton",{Size=UDim2.new(1,0,2,0),Position=UDim2.new(0,0,-0.5,0),BackgroundTransparency=1,Text="",ZIndex=8},TBg)
                if tip~="" then U.Tooltip(c,tip) end
                local sDrag=false
                local function UpdX(x)
                    if not TBg or not TBg.Parent then return end
                    local aw=TBg.AbsoluteSize.X; if aw<=0 then return end
                    local rel=math.clamp((x-TBg.AbsolutePosition.X)/aw,0,1)
                    value=math.floor((mn+(mx-mn)*rel)/step+0.5)*step
                    value=math.clamp(value,mn,mx); SunUI.Flags[fid]=value
                    local r=(mx>mn) and (value-mn)/(mx-mn) or 0
                    pcall(function() vLbl.Text=tostring(value)..suf end)
                    U.Tween(Fill,{Size=UDim2.new(r,0,1,0)},0.05)
                    U.Tween(SKnob,{Position=UDim2.new(r,-7,0.5,-7)},0.05)
                    pcall(cb,value)
                end
                hitBox.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sDrag=true; UpdX(UserInputService:GetMouseLocation().X) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then sDrag=false end end)
                UserInputService.InputChanged:Connect(function(i) if sDrag and i.UserInputType==Enum.UserInputType.MouseMovement then UpdX(i.Position.X) end end)
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},0.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},0.15) end)
                RS(lbl,c)
                local Obj={_element=c}
                function Obj:Set(v)
                    local raw=tonumber(v)
                    -- Animação de erro: valor nil ou fora do range
                    if raw==nil or raw<mn or raw>mx then
                        -- Flash vermelho no vBox + shake suave no card
                        local _,vbS=pcall(function() return vBox and vBox:FindFirstChildOfClass("UIStroke") end)
                        U.Tween(vBox,{BackgroundColor3=U.Lerp(T.InputBg or T.Surface,T.Bad,0.35)},0.12)
                        if vbS then U.Tween(vbS,{Color=T.Bad},0.12) end
                        if vLbl then pcall(function() vLbl.TextColor3=T.Bad end) end
                        U.Shake(c,5,0.35)
                        task.delay(0.65,function()
                            U.Tween(vBox,{BackgroundColor3=T.Surface},0.28)
                            if vbS then U.Tween(vbS,{Color=T.Border},0.28) end
                            if vLbl then pcall(function() vLbl.TextColor3=T.Text end) end
                        end)
                        -- clamp mesmo assim para não quebrar
                        if raw==nil then return end
                        raw=math.clamp(raw,mn,mx)
                    end
                    value=math.floor(raw/step+0.5)*step; value=math.clamp(value,mn,mx)
                    SunUI.Flags[fid]=value
                    local r=(mx>mn) and (value-mn)/(mx-mn) or 0
                    pcall(function() vLbl.Text=tostring(value)..suf end)
                    U.Tween(Fill,{Size=UDim2.new(r,0,1,0)},0.22)
                    U.Tween(SKnob,{Position=UDim2.new(r,-7,0.5,-7)},0.22)
                    pcall(cb,value)
                end
                function Obj:Get() return value end
                return Obj
            end

            -- ═══ BUTTON (com cooldown + confirmação destrutiva) ═══
            function Sec:Button(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Botão"); local desc=opts.Desc
                local icon=tostring(opts.Icon or "▶")
                local cb=type(opts.Callback)=="function" and opts.Callback or function()end
                local tip=tostring(opts.Tooltip or ""); local cooldown=tonumber(opts.Cooldown) or 0
                local confirm=opts.Confirm==true
                local confirmText=tostring(opts.ConfirmText or "Tem certeza? Essa ação não pode ser desfeita.")
                local cH=desc and 52 or 44
                local c=U.New("TextButton",{Size=UDim2.new(1,0,0,cH),BackgroundColor3=T.SurfaceHigh,Text="",ZIndex=4},SWrap)
                U.Corner(9,c); U.Ripple(c,T.Accent)

                -- Ícone
                local ibColor=confirm and U.Lerp(T.Bad,Color3.new(0,0,0),0.55) or T.AccentDim
                local ib=U.New("Frame",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,10,0.5,-14),BackgroundColor3=ibColor,ZIndex=5},c)
                U.Corner(7,ib)
                if not confirm then TrackAccent(ib,"BackgroundColor3") end
                U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,
                    TextColor3=confirm and T.Bad or T.TextAccent,Font=Enum.Font.GothamBold,TextSize=13,ZIndex=6},ib)

                local mainLbl=U.New("TextLabel",{Size=UDim2.new(1,-92,0,desc and 18 or 28),
                    Position=UDim2.new(0,48,0,desc and 7 or 8),BackgroundTransparency=1,Text=lbl,
                    TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                if desc then
                    U.New("TextLabel",{Size=UDim2.new(1,-92,0,14),Position=UDim2.new(0,48,0,26),
                        BackgroundTransparency=1,Text=tostring(desc),TextColor3=T.TextMuted,
                        Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                end
                U.New("TextLabel",{Size=UDim2.new(0,22,1,0),Position=UDim2.new(1,-24,0,0),
                    BackgroundTransparency=1,Text="›",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=20,ZIndex=5},c)

                -- Cooldown bar
                local cdBar=nil
                if cooldown>0 then
                    local cdTrack=U.New("Frame",{Size=UDim2.new(1,-20,0,2),Position=UDim2.new(0,10,1,-4),BackgroundColor3=T.TrackBg,ZIndex=5},c)
                    U.Corner(2,cdTrack)
                    cdBar=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=T.Accent,ZIndex=6},cdTrack)
                    U.Corner(2,cdBar); TrackAccent(cdBar,"BackgroundColor3")
                end

                if tip~="" then U.Tooltip(c,tip) end

                -- ── Popup de confirmação (criado inline, z-alto, não bloqueia outros elementos)
                local function ShowConfirm(onYes)
                    local screen=SunUI._screen
                    if not screen then pcall(onYes); return end

                    -- overlay escurecido
                    local ov=U.New("Frame",{
                        Size=UDim2.new(1,0,1,0),
                        BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,ZIndex=700,
                    },screen)

                    -- popup frame
                    local pop=U.New("Frame",{
                        Size=UDim2.new(0,340,0,0),
                        Position=UDim2.new(0.5,-170,0.5,-72),
                        BackgroundColor3=T.Surface,BackgroundTransparency=1,ZIndex=701,
                    },screen)
                    U.Corner(12,pop)
                    local popS=U.Stroke(T.Bad,1.8,pop); if popS then popS.Transparency=0.4 end

                    -- ícone de aviso
                    local warnF=U.New("Frame",{
                        Size=UDim2.new(0,40,0,40),Position=UDim2.new(0.5,-20,0,18),
                        BackgroundColor3=U.Lerp(T.Bad,Color3.new(0,0,0),0.6),ZIndex=702,
                    },pop)
                    U.Corner(999,warnF)
                    U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                        Text="⚠",TextColor3=T.Bad,Font=Enum.Font.GothamBold,TextSize=22,ZIndex=703},warnF)

                    U.New("TextLabel",{
                        Size=UDim2.new(1,-24,0,18),Position=UDim2.new(0,12,0,66),
                        BackgroundTransparency=1,Text="Confirmação Necessária",
                        TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,ZIndex=702,
                    },pop)
                    U.New("TextLabel",{
                        Size=UDim2.new(1,-24,0,34),Position=UDim2.new(0,12,0,87),
                        BackgroundTransparency=1,Text=confirmText,
                        TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=10,
                        TextWrapped=true,ZIndex=702,
                    },pop)

                    -- botões Sim/Não
                    local btnRow=U.New("Frame",{
                        Size=UDim2.new(1,-24,0,34),Position=UDim2.new(0,12,0,130),
                        BackgroundTransparency=1,ZIndex=702,
                    },pop)
                    local noBtn=U.New("TextButton",{
                        Size=UDim2.new(0.48,0,1,0),BackgroundColor3=T.SurfaceHigh,
                        Text="✕  Cancelar",TextColor3=T.TextSub,
                        Font=Enum.Font.GothamBold,TextSize=11,ZIndex=703,
                    },btnRow)
                    U.Corner(8,noBtn); if noBtn then U.Ripple(noBtn,T.TextMuted) end
                    local yesBtn=U.New("TextButton",{
                        Size=UDim2.new(0.48,0,1,0),Position=UDim2.new(0.52,0,0,0),
                        BackgroundColor3=T.Bad,Text="✓  Confirmar",TextColor3=Color3.new(1,1,1),
                        Font=Enum.Font.GothamBold,TextSize=11,ZIndex=703,
                    },btnRow)
                    U.Corner(8,yesBtn); if yesBtn then U.Ripple(yesBtn,Color3.new(1,1,1)) end

                    local function ClosePopup()
                        U.Tween(pop,{BackgroundTransparency=1,Size=UDim2.new(0,340,0,0)},0.22)
                        U.Tween(ov,{BackgroundTransparency=1},0.22)
                        task.delay(0.26,function()
                            if pop and pop.Parent then pop:Destroy() end
                            if ov and ov.Parent then ov:Destroy() end
                        end)
                    end

                    if noBtn then
                        noBtn.MouseButton1Click:Connect(ClosePopup)
                        noBtn.MouseEnter:Connect(function() U.Tween(noBtn,{BackgroundColor3=T.SurfaceHover},0.12) end)
                        noBtn.MouseLeave:Connect(function() U.Tween(noBtn,{BackgroundColor3=T.SurfaceHigh},0.12) end)
                    end
                    if yesBtn then
                        yesBtn.MouseButton1Click:Connect(function()
                            ClosePopup(); task.spawn(function() pcall(onYes) end)
                        end)
                        yesBtn.MouseEnter:Connect(function() U.Tween(yesBtn,{BackgroundColor3=U.Lerp(T.Bad,Color3.new(1,1,1),0.15)},0.12) end)
                        yesBtn.MouseLeave:Connect(function() U.Tween(yesBtn,{BackgroundColor3=T.Bad},0.12) end)
                    end

                    -- Entrada com spring
                    U.Spring(pop,{Size=UDim2.new(0,340,0,176),BackgroundTransparency=0},0.38)
                    U.Draggable(pop,pop)
                end

                local onCD=false
                c.MouseEnter:Connect(function() if not onCD then U.Tween(c,{BackgroundColor3=T.SurfaceHover},0.15) end end)
                c.MouseLeave:Connect(function() if not onCD then U.Tween(c,{BackgroundColor3=T.SurfaceHigh},0.15) end end)

                local function Execute()
                    if onCD then return end
                    task.spawn(function() pcall(cb) end)
                    if cooldown>0 and cdBar then
                        onCD=true
                        U.Tween(c,{BackgroundColor3=T.AccentDim},0.1)
                        pcall(function() cdBar.Size=UDim2.new(1,0,1,0) end)
                        U.Tween(cdBar,{Size=UDim2.new(0,0,1,0)},cooldown,Enum.EasingStyle.Linear)
                        task.delay(cooldown,function()
                            onCD=false
                            U.Tween(c,{BackgroundColor3=T.SurfaceHigh},0.2)
                        end)
                    end
                end

                c.MouseButton1Up:Connect(function()
                    if onCD then return end
                    if confirm then
                        ShowConfirm(Execute)
                    else
                        U.Tween(c,{BackgroundColor3=T.SurfaceHover},0.15)
                        Execute()
                    end
                end)
                RS(lbl,c)
                return {_element=c}
            end

            -- ═══ DROPDOWN ════════════════
            function Sec:Dropdown(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Dropdown")
                local options=type(opts.Options)=="table" and opts.Options or {}
                local def=opts.Default; local cb=type(opts.Callback)=="function" and opts.Callback or function()end
                local fid=tostring(opts.Flag or U.ID()); local multi=opts.Multi==true
                local tip=tostring(opts.Tooltip or "")
                local selected=(not multi) and (def or options[1]) or nil
                local multiSel=multi and (type(def)=="table" and def or {}) or {}
                SunUI.Flags[fid]=multi and multiSel or selected
                local isOpen=false; local iH=30
                local Wrap=U.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.SurfaceHigh,ZIndex=6},SWrap)
                U.Corner(9,Wrap)
                U.New("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},Wrap)
                local selF=U.New("Frame",{Size=UDim2.new(0,120,0,28),Position=UDim2.new(1,-132,0.5,-14),BackgroundColor3=T.Surface,ZIndex=7},Wrap)
                U.Corner(7,selF); U.Stroke(T.Border,1,selF)
                local selLbl=U.New("TextLabel",{Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,7,0,0),BackgroundTransparency=1,Text=multi and (#multiSel.." sel.") or tostring(selected or "Selecionar"),TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=8},selF)
                local arrow=U.New("TextLabel",{Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-16,0,0),BackgroundTransparency=1,Text="▾",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=8},selF)
                local listH=#options*(iH+2)+42
                -- ListF flutua na screen para não ser cortado pelo hub ou ScrollingFrame
                local ddScreen = SunUI._screen
                local ListF=U.New("Frame",{Size=UDim2.new(0,0,0,0),Position=UDim2.new(0,0,0,0),BackgroundColor3=T.Surface,ClipsDescendants=true,ZIndex=750,Visible=false},ddScreen or Wrap)
                U.Corner(9,ListF); U.Stroke(T.Accent,1.5,ListF); U.List(2,Enum.HorizontalAlignment.Center,ListF); U.Pad(4,4,5,5,ListF)
                -- search interno
                local sBg=U.New("Frame",{Size=UDim2.new(1,-10,0,26),BackgroundColor3=T.InputBg,ZIndex=13},ListF)
                U.Corner(6,sBg); U.Stroke(T.BorderBright,1,sBg)
                U.New("TextLabel",{Size=UDim2.new(0,18,1,0),BackgroundTransparency=1,Text="🔍",TextSize=10,ZIndex=14},sBg)
                local sTB2=U.New("TextBox",{Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,18,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Filtrar...",PlaceholderColor3=T.TextMuted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=10,ClearTextOnFocus=false,ZIndex=14},sBg)
                local optObjs={}
                for _,opt in ipairs(options) do
                    local ob=U.New("TextButton",{Size=UDim2.new(1,0,0,iH),BackgroundColor3=T.Surface,Text="",ZIndex=13},ListF)
                    U.Corner(6,ob)
                    local otxt=U.New("TextLabel",{Size=UDim2.new(1,-36,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=tostring(opt),TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14},ob)
                    local chk=U.New("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(1,-24,0.5,-8),BackgroundColor3=T.TrackBg,ZIndex=14},ob)
                    U.Corner(5,chk)
                    local cm=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="✓",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=9,Visible=false,ZIndex=15},chk)
                    local function RefChk()
                        local on=multi and (table.find(multiSel,opt)~=nil) or (selected==opt)
                        U.Tween(chk,{BackgroundColor3=on and T.Accent or T.TrackBg},0.15)
                        pcall(function() cm.Visible=on end)
                        U.Tween(otxt,{TextColor3=on and T.Text or T.TextSub},0.15)
                    end
                    RefChk(); table.insert(optObjs,{btn=ob,val=opt,ref=RefChk})
                    ob.MouseEnter:Connect(function() U.Tween(ob,{BackgroundColor3=T.SurfaceHover},0.1) end)
                    ob.MouseLeave:Connect(function() U.Tween(ob,{BackgroundColor3=T.Surface},0.1) end)
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            local idx=table.find(multiSel,opt)
                            if idx then table.remove(multiSel,idx) else table.insert(multiSel,opt) end
                            SunUI.Flags[fid]=multiSel
                            if selLbl then selLbl.Text=#multiSel.." sel." end
                            pcall(cb,multiSel)
                        else
                            selected=opt; SunUI.Flags[fid]=opt
                            if selLbl then selLbl.Text=tostring(opt) end
                            pcall(cb,opt)
                            isOpen=false
                            U.Tween(ListF,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,0)},0.22)
                            U.Tween(arrow,{Rotation=0},0.2)
                            task.delay(0.26,function() if ListF and ListF.Parent then ListF.Visible=false end end)
                        end
                        for _,o in ipairs(optObjs) do o.ref() end
                    end)
                end
                if sTB2 then
                    sTB2:GetPropertyChangedSignal("Text"):Connect(function()
                        local q=sTB2.Text:lower()
                        for _,o in ipairs(optObjs) do
                            if o.btn and o.btn.Parent then
                                pcall(function() o.btn.Visible=(q=="" or tostring(o.val):lower():find(q,1,true)) and true or false end)
                            end
                        end
                    end)
                end
                local function PosDDList()
                    if not Wrap or not Wrap.Parent then return end
                    local abs=Wrap.AbsolutePosition; local absW=Wrap.AbsoluteSize.X
                    pcall(function()
                        ListF.Position=UDim2.new(0,abs.X,0,abs.Y+44+4)
                        ListF.Size=UDim2.new(0,absW,0,0)
                    end)
                end
                local hitBtn=U.New("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,Text="",ZIndex=9},Wrap)
                hitBtn.MouseButton1Click:Connect(function()
                    isOpen=not isOpen
                    if isOpen then
                        PosDDList()
                        ListF.Visible=true
                        U.Tween(ListF,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,listH)},0.24,Enum.EasingStyle.Quart)
                        U.Tween(arrow,{Rotation=180},0.2)
                    else
                        U.Tween(ListF,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,0)},0.22)
                        U.Tween(arrow,{Rotation=0},0.2)
                        task.delay(0.26,function() if ListF and ListF.Parent then ListF.Visible=false end end)
                    end
                end)
                if tip~="" then U.Tooltip(Wrap,tip) end
                Wrap.MouseEnter:Connect(function() if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHover},0.15) end end)
                Wrap.MouseLeave:Connect(function() if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHigh},0.15) end end)
                RS(lbl,Wrap)
                local Obj={_element=Wrap}
                function Obj:Set(v)
                    if multi then multiSel=type(v)=="table" and v or {v}; SunUI.Flags[fid]=multiSel; if selLbl then selLbl.Text=#multiSel.." sel." end
                    else selected=v; SunUI.Flags[fid]=v; if selLbl then selLbl.Text=tostring(v) end end
                    for _,o in ipairs(optObjs) do o.ref() end; pcall(cb,SunUI.Flags[fid])
                end
                function Obj:Get() return SunUI.Flags[fid] end
                function Obj:Refresh(newList)
                    options=newList or {}
                    for _,o in ipairs(optObjs) do if o.btn and o.btn.Parent then o.btn:Destroy() end end
                    optObjs={}
                    for _,opt in ipairs(options) do
                        local ob2=U.New("TextButton",{Size=UDim2.new(1,0,0,iH),BackgroundColor3=T.Surface,Text=tostring(opt),TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,ZIndex=13},ListF)
                        U.Corner(6,ob2)
                        ob2.MouseButton1Click:Connect(function() selected=opt; SunUI.Flags[fid]=opt; if selLbl then selLbl.Text=tostring(opt) end; pcall(cb,opt) end)
                        table.insert(optObjs,{btn=ob2,val=opt,ref=function()end})
                    end
                    listH=#options*(iH+2)+42
                end
                return Obj
            end


            -- ═══ PLAYER DROPDOWN ════════════
            -- Lista de players do servidor com avatar, DisplayName e @username
            function Sec:PlayerDropdown(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Selecionar Player")
                local multi=opts.Multi==true
                local cb=type(opts.Callback)=="function" and opts.Callback or function()end
                local fid=tostring(opts.Flag or U.ID())
                local tip=tostring(opts.Tooltip or "")
                local includeLocal=opts.IncludeLocal~=false  -- inclui o proprio player por padrão
                local autoUpdate=opts.AutoUpdate~=false       -- atualiza quando player entra/sai

                local selected=nil
                local multiSel={}
                SunUI.Flags[fid]=multi and multiSel or selected

                local isOpen=false
                local ITEM_H=48  -- altura de cada item (comporta avatar + 2 linhas de texto)
                local MAX_VISIBLE=5 -- máx visíveis antes de scrollar

                -- ── Header do componente
                local Wrap=U.New("Frame",{
                    Size=UDim2.new(1,0,0,44),
                    BackgroundColor3=T.SurfaceHigh,ZIndex=6,
                },SWrap)
                U.Corner(9,Wrap)

                -- Ícone de pessoas
                local hIco=U.New("Frame",{
                    Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,10,0.5,-14),
                    BackgroundColor3=T.AccentDim,ZIndex=7,
                },Wrap)
                U.Corner(7,hIco); TrackAccent(hIco,"BackgroundColor3")
                U.New("TextLabel",{
                    Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                    Text="👥",Font=Enum.Font.GothamBold,TextSize=13,ZIndex=8,
                },hIco)

                U.New("TextLabel",{
                    Size=UDim2.new(0.44,0,1,0),Position=UDim2.new(0,46,0,0),
                    BackgroundTransparency=1,Text=lbl,
                    TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,
                    TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7,
                },Wrap)

                -- Preview do selecionado (avatar mini + nome)
                local prevF=U.New("Frame",{
                    Size=UDim2.new(0,130,0,32),Position=UDim2.new(1,-142,0.5,-16),
                    BackgroundColor3=T.Surface,ZIndex=7,
                },Wrap)
                U.Corner(8,prevF); U.Stroke(T.Border,1,prevF)

                local prevAvatar=U.New("ImageLabel",{
                    Size=UDim2.new(0,24,0,24),Position=UDim2.new(0,4,0.5,-12),
                    BackgroundColor3=T.SurfaceHover,BackgroundTransparency=0,
                    Image="",ZIndex=8,
                },prevF)
                U.Corner(999,prevAvatar)

                local prevName=U.New("TextLabel",{
                    Size=UDim2.new(1,-36,0,16),Position=UDim2.new(0,32,0,4),
                    BackgroundTransparency=1,
                    Text=multi and "Nenhum" or "Selecionar",
                    TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=10,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=8,
                },prevF)
                local prevUser=U.New("TextLabel",{
                    Size=UDim2.new(1,-36,0,12),Position=UDim2.new(0,32,0,20),
                    BackgroundTransparency=1,Text="",
                    TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=8,
                    TextXAlignment=Enum.TextXAlignment.Left,
                    TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=8,
                },prevF)

                local arrow=U.New("TextLabel",{
                    Size=UDim2.new(0,14,1,0),Position=UDim2.new(1,-16,0,0),
                    BackgroundTransparency=1,Text="▾",
                    TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=8,
                },Wrap)

                -- ── Lista dropdown (flutua na screen para não ser clipada)
                local pdScreen = SunUI._screen
                local ListF=U.New("Frame",{
                    Size=UDim2.new(0,0,0,0),
                    Position=UDim2.new(0,0,0,0),
                    BackgroundColor3=T.Surface,
                    ClipsDescendants=true,
                    Visible=false,ZIndex=750,
                },pdScreen or Wrap)
                U.Corner(10,ListF); U.Stroke(T.Accent,1.5,ListF)

                -- Search bar
                local sBg=U.New("Frame",{
                    Size=UDim2.new(1,-10,0,28),
                    BackgroundColor3=T.InputBg,ZIndex=21,
                },ListF)
                U.Corner(7,sBg)
                U.New("TextLabel",{
                    Size=UDim2.new(0,22,1,0),BackgroundTransparency=1,
                    Text="🔍",TextSize=11,ZIndex=22,
                },sBg)
                local sTB=U.New("TextBox",{
                    Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,22,0,0),
                    BackgroundTransparency=1,Text="",
                    PlaceholderText="Buscar jogador...",
                    PlaceholderColor3=T.TextMuted,
                    TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,
                    ClearTextOnFocus=false,ZIndex=22,
                },sBg)

                -- Scroll com lista de players
                local scroll=U.New("ScrollingFrame",{
                    Size=UDim2.new(1,0,1,-36),Position=UDim2.new(0,0,0,36),
                    BackgroundTransparency=1,
                    ScrollBarThickness=3,ScrollBarImageColor3=T.Scrollbar,
                    ZIndex=21,
                },ListF)
                local scrollL=U.List(2,Enum.HorizontalAlignment.Center,scroll)
                U.Pad(4,4,5,5,scroll)
                U.AutoCanvas(scroll,scrollL,8)

                -- ── Funções de estado
                local itemObjs={}  -- {player, btn, avatarImg, nameL, userL, chk, chkMark}

                local function GetAvatarUrl(userId)
                    return "https://www.roblox.com/headshot-thumbnail/image?userId="
                        ..tostring(userId).."&width=150&height=150&format=png"
                end

                local function UpdatePreview()
                    if multi then
                        if #multiSel==0 then
                            if prevAvatar then pcall(function() prevAvatar.Image="" end) end
                            if prevName then pcall(function() prevName.Text="Nenhum" end) end
                            if prevUser then pcall(function() prevUser.Text="" end) end
                        else
                            local p=multiSel[1]
                            if prevAvatar then pcall(function() prevAvatar.Image=GetAvatarUrl(p.UserId) end) end
                            if prevName then pcall(function() prevName.Text=p.DisplayName..(#multiSel>1 and " +"..tostring(#multiSel-1) or "") end) end
                            if prevUser then pcall(function() prevUser.Text="@"..p.Name end) end
                        end
                    else
                        if selected then
                            if prevAvatar then pcall(function() prevAvatar.Image=GetAvatarUrl(selected.UserId) end) end
                            if prevName then pcall(function() prevName.Text=selected.DisplayName end) end
                            if prevUser then pcall(function() prevUser.Text="@"..selected.Name end) end
                        else
                            if prevAvatar then pcall(function() prevAvatar.Image="" end) end
                            if prevName then pcall(function() prevName.Text="Selecionar" end) end
                            if prevUser then pcall(function() prevUser.Text="" end) end
                        end
                    end
                end

                local function IsSelected(p)
                    if multi then return table.find(multiSel,p)~=nil
                    else return selected==p end
                end

                local function RefreshAllChecks()
                    for _,item in ipairs(itemObjs) do
                        local on=IsSelected(item.player)
                        if item.chk then U.Tween(item.chk,{BackgroundColor3=on and T.Accent or T.TrackBg},0.12) end
                        if item.chkMark then pcall(function() item.chkMark.Visible=on end) end
                        if item.nameL then U.Tween(item.nameL,{TextColor3=on and T.Text or T.TextSub},0.12) end
                        if item.btn then U.Tween(item.btn,{BackgroundColor3=on and T.SurfaceHover or T.Surface},0.12) end
                    end
                end

                -- Constrói um item de player
                local function MakeItem(player)
                    local btn=U.New("TextButton",{
                        Size=UDim2.new(1,0,0,ITEM_H),
                        BackgroundColor3=T.Surface,Text="",ZIndex=22,
                    },scroll)
                    if not btn then return end
                    U.Corner(8,btn)

                    -- Avatar com borda colorida se selecionado
                    local avRing=U.New("Frame",{
                        Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,8,0.5,-18),
                        BackgroundColor3=T.Border,ZIndex=23,
                    },btn)
                    U.Corner(999,avRing)
                    local avImg=U.New("ImageLabel",{
                        Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),
                        BackgroundColor3=T.SurfaceHigh,
                        Image=GetAvatarUrl(player.UserId),
                        ZIndex=24,
                    },avRing)
                    U.Corner(999,avImg)

                    -- DisplayName (negrito)
                    local nameL=U.New("TextLabel",{
                        Size=UDim2.new(1,-88,0,18),Position=UDim2.new(0,52,0,8),
                        BackgroundTransparency=1,
                        Text=player.DisplayName,
                        TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=12,
                        TextXAlignment=Enum.TextXAlignment.Left,
                        TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=23,
                    },btn)

                    -- @username
                    local userL=U.New("TextLabel",{
                        Size=UDim2.new(1,-88,0,14),Position=UDim2.new(0,52,0,27),
                        BackgroundTransparency=1,
                        Text="@"..player.Name,
                        TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,
                        TextXAlignment=Enum.TextXAlignment.Left,
                        TextTruncate=Enum.TextTruncate.AtEnd,ZIndex=23,
                    },btn)

                    -- Checkmark
                    local chk=U.New("Frame",{
                        Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-28,0.5,-10),
                        BackgroundColor3=T.TrackBg,ZIndex=23,
                    },btn)
                    U.Corner(6,chk)
                    local chkMark=U.New("TextLabel",{
                        Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,
                        Text="✓",TextColor3=Color3.new(1,1,1),
                        Font=Enum.Font.GothamBold,TextSize=10,
                        Visible=false,ZIndex=24,
                    },chk)

                    -- Linha separadora sutil
                    U.New("Frame",{
                        Size=UDim2.new(1,-12,0,1),Position=UDim2.new(0,6,1,-1),
                        BackgroundColor3=T.Border,BackgroundTransparency=0.5,ZIndex=22,
                    },btn)

                    -- Hover
                    btn.MouseEnter:Connect(function()
                        if not IsSelected(player) then U.Tween(btn,{BackgroundColor3=T.SurfaceHover},0.1) end
                        -- Highlight do anel do avatar com cor accent
                        U.Tween(avRing,{BackgroundColor3=T.Accent},0.12)
                    end)
                    btn.MouseLeave:Connect(function()
                        if not IsSelected(player) then U.Tween(btn,{BackgroundColor3=T.Surface},0.1) end
                        U.Tween(avRing,{BackgroundColor3=T.Border},0.12)
                    end)

                    btn.MouseButton1Click:Connect(function()
                        if multi then
                            local idx=table.find(multiSel,player)
                            if idx then table.remove(multiSel,idx)
                            else table.insert(multiSel,player) end
                            SunUI.Flags[fid]=multiSel
                            RefreshAllChecks(); UpdatePreview()
                            pcall(cb, multiSel)
                        else
                            selected=player
                            SunUI.Flags[fid]=player
                            RefreshAllChecks(); UpdatePreview()
                            pcall(cb, player)
                            -- fechar ao selecionar (single)
                            isOpen=false
                            U.Tween(ListF,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,0)},0.22)
                            U.Tween(arrow,{Rotation=0},0.2)
                            task.delay(0.26,function()
                                if ListF then pcall(function() ListF.Visible=false end) end
                            end)
                        end
                    end)

                    local obj={player=player,btn=btn,avRing=avRing,avImg=avImg,
                               nameL=nameL,userL=userL,chk=chk,chkMark=chkMark}
                    table.insert(itemObjs,obj)
                    return obj
                end

                -- Popula lista com players atuais
                local function BuildList()
                    -- Limpar itens existentes
                    for _,item in ipairs(itemObjs) do
                        if item.btn and item.btn.Parent then
                            pcall(function() item.btn:Destroy() end)
                        end
                    end
                    itemObjs={}
                    -- Validar seleções (player pode ter saído)
                    if not multi and selected then
                        if not selected.Parent then selected=nil; SunUI.Flags[fid]=nil end
                    end
                    if multi then
                        for i=#multiSel,1,-1 do
                            if not multiSel[i].Parent then table.remove(multiSel,i) end
                        end
                    end
                    local plist={}
                    pcall(function() plist=Players:GetPlayers() end)
                    for _,p in ipairs(plist) do
                        if includeLocal or p~=LP then
                            MakeItem(p)
                        end
                    end
                    RefreshAllChecks(); UpdatePreview()
                    return #itemObjs
                end

                -- Filtro de busca
                if sTB then
                    sTB:GetPropertyChangedSignal("Text"):Connect(function()
                        local q=sTB.Text:lower():gsub("^%s*(.-)%s*$","%1")
                        local vis=0
                        for _,item in ipairs(itemObjs) do
                            if item.btn and item.btn.Parent then
                                local match=(q==""
                                    or item.player.Name:lower():find(q,1,true)
                                    or item.player.DisplayName:lower():find(q,1,true))
                                pcall(function() item.btn.Visible=match and true or false end)
                                if match then vis=vis+1 end
                            end
                        end
                    end)
                end

                -- Trigger de abrir/fechar
                local hitBtn=U.New("TextButton",{
                    Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,Text="",ZIndex=9,
                },Wrap)
                local function PosPDList(listH)
                    if not Wrap or not Wrap.Parent then return end
                    local abs=Wrap.AbsolutePosition; local absW=Wrap.AbsoluteSize.X
                    pcall(function()
                        ListF.Position=UDim2.new(0,abs.X,0,abs.Y+44+4)
                        ListF.Size=UDim2.new(0,absW,0,0)
                    end)
                end
                hitBtn.MouseButton1Click:Connect(function()
                    isOpen=not isOpen
                    if isOpen then
                        local count=BuildList()
                        local visItems=math.min(count,MAX_VISIBLE)
                        local listH=visItems*ITEM_H+38+8
                        PosPDList(listH)
                        ListF.Visible=true
                        U.Tween(ListF,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,listH)},0.26,Enum.EasingStyle.Quart)
                        U.Tween(arrow,{Rotation=180},0.22)
                    else
                        U.Tween(ListF,{Size=UDim2.new(0,Wrap.AbsoluteSize.X,0,0)},0.22)
                        U.Tween(arrow,{Rotation=0},0.2)
                        task.delay(0.26,function()
                            if ListF then pcall(function() ListF.Visible=false end) end
                        end)
                    end
                end)

                -- Hover no header
                Wrap.MouseEnter:Connect(function()
                    if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHover},0.15) end
                end)
                Wrap.MouseLeave:Connect(function()
                    if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHigh},0.15) end
                end)

                -- Auto-update quando player entra/sai
                if autoUpdate then
                    local conAdd, conRem
                    pcall(function()
                        conAdd=Players.PlayerAdded:Connect(function()
                            if isOpen then BuildList() end
                        end)
                        conRem=Players.PlayerRemoving:Connect(function()
                            if isOpen then BuildList() end
                            -- limpa seleção se o player saiu
                            if not multi and selected and not selected.Parent then
                                selected=nil; SunUI.Flags[fid]=nil; UpdatePreview()
                            end
                            if multi then
                                for i=#multiSel,1,-1 do
                                    if not multiSel[i].Parent then table.remove(multiSel,i) end
                                end
                                SunUI.Flags[fid]=multiSel; UpdatePreview()
                            end
                        end)
                    end)
                end

                if tip~="" then U.Tooltip(Wrap,tip) end
                RS(lbl,Wrap)

                -- ── Objeto retornado
                local Obj={_element=Wrap}
                function Obj:Get()
                    return SunUI.Flags[fid]
                end
                function Obj:GetName()
                    if multi then
                        local names={}
                        for _,p in ipairs(multiSel) do table.insert(names,p.Name) end
                        return names
                    end
                    return selected and selected.Name or nil
                end
                function Obj:Clear()
                    selected=nil; multiSel={}
                    SunUI.Flags[fid]=multi and multiSel or nil
                    RefreshAllChecks(); UpdatePreview()
                end
                function Obj:Refresh()
                    if isOpen then BuildList() end
                end
                return Obj
            end

            -- ═══ KEYBIND ═════════════════
            function Sec:Keybind(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Keybind"); local def=opts.Default or Enum.KeyCode.Unknown
                local onp=type(opts.OnPress)=="function" and opts.OnPress or function()end
                local fid=tostring(opts.Flag or U.ID()); local mode=tostring(opts.Mode or "Toggle")
                local tip=tostring(opts.Tooltip or "")
                local key=def; local listening=false; SunUI.Flags[fid]=key
                local c=Card(44)
                U.New("TextLabel",{Size=UDim2.new(0.52,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                U.New("TextLabel",{Size=UDim2.new(0,50,0,14),Position=UDim2.new(1,-162,0.5,-7),BackgroundTransparency=1,Text="["..mode.."]",TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,ZIndex=5},c)
                local kF=U.New("Frame",{Size=UDim2.new(0,80,0,26),Position=UDim2.new(1,-90,0.5,-13),BackgroundColor3=T.Surface,ZIndex=5},c)
                U.Corner(7,kF); U.Stroke(T.Border,1,kF)
                local kLbl=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=key.Name,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=10,ZIndex=6},kF)
                local hit=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7},c)
                hit.MouseButton1Click:Connect(function()
                    listening=true; if kLbl then kLbl.Text="..." end
                    U.Tween(kF,{BackgroundColor3=T.AccentDim},0.15)
                end)
                UserInputService.InputBegan:Connect(function(inp,gpe)
                    if listening and inp.UserInputType==Enum.UserInputType.Keyboard then
                        listening=false; key=inp.KeyCode; SunUI.Flags[fid]=key
                        if kLbl then kLbl.Text=key.Name end
                        U.Tween(kF,{BackgroundColor3=T.Surface},0.15); return
                    end
                    if not gpe and inp.KeyCode==key and not listening then
                        if mode=="Hold" then pcall(onp,true)
                        elseif mode=="Toggle" then pcall(onp) end
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.KeyCode==key and mode=="Hold" then pcall(onp,false) end
                end)
                if tip~="" then U.Tooltip(c,tip) end
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},0.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},0.15) end)
                RS(lbl,c)
                local Obj={_element=c}
                function Obj:Get() return key end
                return Obj
            end

            -- ═══ TEXTBOX ═════════════════
            function Sec:TextBox(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Input"); local ph=tostring(opts.Placeholder or "Digite...")
                local def=tostring(opts.Default or ""); local oc=type(opts.OnChanged)=="function" and opts.OnChanged or nil
                local os2=type(opts.OnSubmit)=="function" and opts.OnSubmit or function()end
                local fid=tostring(opts.Flag or U.ID()); local tip=tostring(opts.Tooltip or ""); local num=opts.Numeric==true
                SunUI.Flags[fid]=def
                local c=Card(52)
                U.New("TextLabel",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,Text=lbl,TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                local ibg=U.New("Frame",{Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,0,20),BackgroundColor3=T.InputBg,ZIndex=5},c)
                U.Corner(7,ibg); local ibgS=U.Stroke(T.Border,1,ibg)
                local tb4=U.New("TextBox",{Size=UDim2.new(1,-16,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=def,PlaceholderText=ph,PlaceholderColor3=T.TextMuted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=6},ibg)
                if tip~="" then U.Tooltip(c,tip) end
                if tb4 then
                    tb4.Focused:Connect(function() if ibgS then U.Tween(ibgS,{Color=T.Accent},0.15) end; U.Tween(ibg,{BackgroundColor3=T.SurfaceHover},0.15) end)
                    tb4.FocusLost:Connect(function(e)
                        if ibgS then U.Tween(ibgS,{Color=T.Border},0.15) end; U.Tween(ibg,{BackgroundColor3=T.InputBg},0.15)
                        local v=tb4.Text; if num then local n=tonumber(v); v=tostring(n or def); pcall(function() tb4.Text=v end) end
                        SunUI.Flags[fid]=num and (tonumber(v) or def) or v; if e then pcall(os2,tb4.Text) end
                    end)
                    if oc then tb4:GetPropertyChangedSignal("Text"):Connect(function() SunUI.Flags[fid]=tb4.Text; pcall(oc,tb4.Text) end) end
                end
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},0.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},0.15) end)
                RS(lbl,c)
                local Obj={_element=c}
                function Obj:Set(v) pcall(function() tb4.Text=tostring(v) end); SunUI.Flags[fid]=v end
                function Obj:Get() return tb4 and tb4.Text or "" end
                return Obj
            end

            -- ═══ COLOR PICKER ════════════
            function Sec:ColorPicker(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Cor"); local def=opts.Default or Color3.fromRGB(255,80,80)
                local cb=type(opts.Callback)=="function" and opts.Callback or function()end
                local fid=tostring(opts.Flag or U.ID()); local tip=tostring(opts.Tooltip or "")
                SunUI.Flags[fid]=def
                local hdr=U.New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,ZIndex=4},SWrap)
                U.New("TextLabel",{Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},hdr)
                if tip~="" then U.Tooltip(hdr,tip) end
                local pw=U.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,ZIndex=4},SWrap)
                local cpObj=MakeColorPicker(pw,def,T,function(c3) SunUI.Flags[fid]=c3; pcall(cb,c3) end)
                RS(lbl,pw); return cpObj
            end

            -- ═══ LABEL ═══════════════════
            function Sec:Label(opts)
                opts=type(opts)=="string" and {Text=opts} or (opts or {})
                local text=tostring(opts.Text or ""); local col=opts.Color or T.TextSub
                local bold=opts.Bold==true; local icon=opts.Icon
                local c=Card(36)
                if icon then U.New("TextLabel",{Size=UDim2.new(0,22,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=tostring(icon),TextSize=13,ZIndex=5},c) end
                local l=U.New("TextLabel",{
                    Size=UDim2.new(1,(icon and -40 or -20),1,0),Position=UDim2.new(0,icon and 32 or 10,0,0),
                    BackgroundTransparency=1,Text=text,TextColor3=col,
                    Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
                    TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=5,
                },c)
                local Obj={_element=c}
                function Obj:Set(v) if l then pcall(function() l.Text=tostring(v) end) end end
                function Obj:SetColor(v) if l then pcall(function() l.TextColor3=v end) end end
                return Obj
            end

            -- ═══ SEPARATOR ═══════════════
            function Sec:Separator(text)
                local f=U.New("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=4},SWrap)
                U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,0.5,0),BackgroundColor3=T.Border,ZIndex=4},f)
                if text then
                    local bg=U.New("Frame",{Size=UDim2.new(0,110,0,16),Position=UDim2.new(0.5,-55,0.5,-8),BackgroundColor3=T.Surface,ZIndex=5},f)
                    U.New("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text=tostring(text),TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,ZIndex=6},bg)
                end
                return {_element=f}
            end

            -- ═══ PROGRESS BAR ════════════
            function Sec:ProgressBar(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Progresso"); local mn=tonumber(opts.Min) or 0
                local mx=tonumber(opts.Max) or 100; local def=math.clamp(tonumber(opts.Default) or 0,mn,mx)
                local suf=tostring(opts.Suffix or "%"); local value=def
                local c=Card(44)
                U.New("TextLabel",{Size=UDim2.new(0.6,0,0,16),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                local pLbl=U.New("TextLabel",{Size=UDim2.new(0.4,0,0,16),Position=UDim2.new(0.6,0,0,5),BackgroundTransparency=1,Text=tostring(value)..suf,TextColor3=T.TextAccent,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5},c)
                local trk=U.New("Frame",{Size=UDim2.new(1,-20,0,7),Position=UDim2.new(0,10,0,27),BackgroundColor3=T.TrackBg,ZIndex=5},c)
                U.Corner(4,trk)
                local rel=(mx>mn) and (value-mn)/(mx-mn) or 0
                local fi=U.New("Frame",{Size=UDim2.new(rel,0,1,0),BackgroundColor3=T.Accent,ZIndex=6},trk)
                U.Corner(4,fi); TrackAccent(fi,"BackgroundColor3")
                local Obj={_element=c}
                function Obj:Set(v)
                    value=math.clamp(tonumber(v) or mn,mn,mx); if pLbl then pcall(function() pLbl.Text=tostring(value)..suf end) end
                    local r=(mx>mn) and (value-mn)/(mx-mn) or 0; U.Tween(fi,{Size=UDim2.new(r,0,1,0)},0.3)
                end
                function Obj:Get() return value end
                return Obj
            end

            -- ═══ TOGGLE+SLIDER ═══════════
            function Sec:ToggleSlider(opts)
                local t=self:Toggle({Name=opts.Name,Desc=opts.Desc,Default=opts.TDefault,Flag=opts.TFlag,Callback=opts.TCallback,Tooltip=opts.Tooltip})
                local s=self:Slider({Name=opts.SName or ((opts.Name or "").." Amount"),Min=opts.Min,Max=opts.Max,Default=opts.SDefault,Suffix=opts.Suffix,Step=opts.Step,Flag=opts.SFlag,Callback=opts.SCallback})
                return t,s
            end

            -- ═══ ACCENT PICKER ═══════════
            function Sec:AccentPicker(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Cor do Hub"); local tip=tostring(opts.Tooltip or "")
                local c=Card(44)
                U.New("TextLabel",{Size=UDim2.new(0.44,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                local presets={Color3.fromRGB(99,102,241),Color3.fromRGB(168,85,247),Color3.fromRGB(239,68,68),Color3.fromRGB(6,182,212),Color3.fromRGB(16,185,129),Color3.fromRGB(251,191,36),Color3.fromRGB(249,115,22),Color3.fromRGB(236,72,153)}
                local px=172
                for _,pc in ipairs(presets) do
                    local pb=U.New("Frame",{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,px,0.5,-8),BackgroundColor3=pc,ZIndex=5},c)
                    U.Corner(999,pb)
                    local ph2=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=6},pb)
                    ph2.MouseButton1Click:Connect(function() SunUI:SetAccentColor(pc) end)
                    pb.MouseEnter:Connect(function() U.Tween(pb,{Size=UDim2.new(0,20,0,20),Position=UDim2.new(0,px-2,0.5,-10)},0.1) end)
                    pb.MouseLeave:Connect(function() U.Tween(pb,{Size=UDim2.new(0,16,0,16),Position=UDim2.new(0,px,0.5,-8)},0.1) end)
                    px=px+19
                end
                local rbBtn=U.New("TextButton",{
                    Size=UDim2.new(0,48,0,22),Position=UDim2.new(1,-56,0.5,-11),
                    BackgroundColor3=T.Surface,Text="🌈 RGB",TextColor3=T.Text,
                    Font=Enum.Font.GothamBold,TextSize=8,ZIndex=6,
                },c)
                U.Corner(7,rbBtn); U.Stroke(T.Border,1,rbBtn)
                rbBtn.MouseButton1Click:Connect(function()
                    SunUI._rbRunning=false; task.wait(0.05)
                    SunUI._rbTick=0; StartRainbow()
                end)
                if tip~="" then U.Tooltip(c,tip) end
                return {_element=c}
            end

            -- ═══ PROFILE MANAGER ═════════
            function Sec:ProfileManager(opts)
                opts=opts or {}
                local hdr=U.New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,ZIndex=4},SWrap)
                U.New("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text="PERFIS DE CONFIGURAÇÃO",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},hdr)
                U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,ZIndex=3},hdr)

                -- Input do nome do perfil
                local pRow=U.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.SurfaceHigh,ZIndex=4},SWrap)
                U.Corner(9,pRow)
                U.New("TextLabel",{Size=UDim2.new(1,-16,0,14),Position=UDim2.new(0,10,0,4),BackgroundTransparency=1,Text="Nome do Perfil",TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},pRow)
                local pIA=U.New("Frame",{Size=UDim2.new(1,-96,0,24),Position=UDim2.new(0,10,0,18),BackgroundColor3=T.InputBg,ZIndex=5},pRow)
                U.Corner(7,pIA); U.Stroke(T.Border,1,pIA)
                local pTB=U.New("TextBox",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text="",PlaceholderText="ex: PvP Config",PlaceholderColor3=T.TextMuted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=false,ZIndex=6},pIA)

                local saveBtn=U.New("TextButton",{
                    Size=UDim2.new(0,36,0,24),Position=UDim2.new(1,-84,0,18),
                    BackgroundColor3=T.Accent,Text="💾",TextColor3=Color3.new(1,1,1),
                    Font=Enum.Font.GothamBold,TextSize=12,ZIndex=5,
                },pRow)
                U.Corner(7,saveBtn); TrackAccent(saveBtn,"BackgroundColor3")
                local loadBtn=U.New("TextButton",{
                    Size=UDim2.new(0,36,0,24),Position=UDim2.new(1,-44,0,18),
                    BackgroundColor3=T.Good,Text="↺",TextColor3=Color3.new(1,1,1),
                    Font=Enum.Font.GothamBold,TextSize=14,ZIndex=5,
                },pRow)
                U.Corner(7,loadBtn)

                saveBtn.MouseButton1Click:Connect(function()
                    if not pTB or pTB.Text=="" then
                        SunUI:Notify({Title="Perfil",Message="Digite um nome para o perfil!",Type="Warning"})
                        return
                    end
                    SunUI:SaveProfile(pTB.Text)
                    SunUI:Notify({Title="Perfil salvo!",Message="Perfil '"..pTB.Text.."' salvo com sucesso.",Type="Success"})
                end)
                loadBtn.MouseButton1Click:Connect(function()
                    if not pTB or pTB.Text=="" then
                        SunUI:Notify({Title="Perfil",Message="Digite o nome do perfil a carregar!",Type="Warning"})
                        return
                    end
                    SunUI:LoadProfile(pTB.Text)
                    SunUI:Notify({Title="Perfil carregado!",Message="Perfil '"..pTB.Text.."' restaurado.",Type="Success"})
                end)
                return {_element=pRow}
            end

            -- ═══ BACKGROUND MANAGER ══════
            function Sec:BackgroundManager()
                local hdr2=U.New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,ZIndex=4},SWrap)
                U.New("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text="IMAGEM DE FUNDO",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},hdr2)
                U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,ZIndex=3},hdr2)
                local bgC=U.New("Frame",{Size=UDim2.new(1,0,0,0),BackgroundTransparency=1,ZIndex=4},SWrap)
                local bcl=U.List(4,Enum.HorizontalAlignment.Center,bgC); U.AutoHeight(bgC,bcl,4)
                MakeBgManager(bgC,T,SetBg)
                return {_element=bgC}
            end

                        -- ═══ DESTROY BUTTON ══════════
            function Sec:DestroyButton(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Fechar Hub")
                local desc=opts.Desc
                local confirmText=tostring(opts.ConfirmText or "Isso irá fechar o hub completamente. Tem certeza?")
                local c=U.New("TextButton",{Size=UDim2.new(1,0,0,desc and 52 or 44),BackgroundColor3=T.SurfaceHigh,Text="",ZIndex=4},SWrap)
                U.Corner(9,c); U.Ripple(c,T.Bad)
                local ib=U.New("Frame",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(0,10,0.5,-14),BackgroundColor3=U.Lerp(T.Bad,Color3.new(0,0,0),0.6),ZIndex=5},c)
                U.Corner(7,ib)
                U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="⏻",TextColor3=T.Bad,Font=Enum.Font.GothamBold,TextSize=13,ZIndex=6},ib)
                U.New("TextLabel",{Size=UDim2.new(1,-92,0,desc and 18 or 28),Position=UDim2.new(0,48,0,desc and 7 or 8),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                if desc then U.New("TextLabel",{Size=UDim2.new(1,-92,0,14),Position=UDim2.new(0,48,0,26),BackgroundTransparency=1,Text=tostring(desc),TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c) end
                U.New("TextLabel",{Size=UDim2.new(0,22,1,0),Position=UDim2.new(1,-24,0,0),BackgroundTransparency=1,Text="›",TextColor3=T.Bad,Font=Enum.Font.GothamBold,TextSize=20,ZIndex=5},c)
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=U.Lerp(T.SurfaceHigh,T.Bad,0.08)},0.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},0.15) end)
                c.MouseButton1Up:Connect(function()
                    local s2=SunUI._screen
                    if not s2 then StopRainbow(); if Screen and Screen.Parent then Screen:Destroy() end; return end
                    local ov2=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.55,ZIndex=700},s2)
                    local pop2=U.New("Frame",{Size=UDim2.new(0,340,0,0),Position=UDim2.new(0.5,-170,0.5,-76),BackgroundColor3=T.Surface,BackgroundTransparency=1,ZIndex=701},s2)
                    U.Corner(12,pop2); U.Stroke(T.Bad,1.8,pop2)
                    U.New("TextLabel",{Size=UDim2.new(1,-20,0,22),Position=UDim2.new(0,10,0,14),BackgroundTransparency=1,Text="⏻  "..lbl,TextColor3=T.Bad,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=702},pop2)
                    U.New("TextLabel",{Size=UDim2.new(1,-20,0,40),Position=UDim2.new(0,10,0,40),BackgroundTransparency=1,Text=confirmText,TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=702},pop2)
                    local yB=U.New("TextButton",{Size=UDim2.new(0,120,0,34),Position=UDim2.new(0,10,0,112),BackgroundColor3=T.Bad,Text="Confirmar",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=12,ZIndex=702},pop2)
                    U.Corner(8,yB); U.Ripple(yB,Color3.new(1,1,1))
                    local nB=U.New("TextButton",{Size=UDim2.new(0,100,0,34),Position=UDim2.new(1,-112,0,112),BackgroundColor3=T.Surface,Text="Cancelar",TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=702},pop2)
                    U.Corner(8,nB); U.Stroke(T.Border,1,nB)
                    nB.MouseButton1Click:Connect(function()
                        U.Tween(pop2,{BackgroundTransparency=1,Size=UDim2.new(0,340,0,0)},0.22)
                        U.Tween(ov2,{BackgroundTransparency=1},0.22)
                        task.delay(0.26,function()
                            if pop2 and pop2.Parent then pop2:Destroy() end
                            if ov2 and ov2.Parent then ov2:Destroy() end
                        end)
                    end)
                    yB.MouseButton1Click:Connect(function()
                        if ov2 and ov2.Parent then ov2:Destroy() end
                        if pop2 and pop2.Parent then pop2:Destroy() end
                        SaveMgr:Save(SunUI.Flags); StopRainbow()
                        task.delay(0.08,function()
                            if Screen and Screen.Parent then Screen:Destroy() end
                        end)
                    end)
                    U.Spring(pop2,{Size=UDim2.new(0,340,0,156),BackgroundTransparency=0},0.36)
                    U.Draggable(pop2,pop2)
                end)
                RS(lbl,c)
                return {_element=c}
            end

            -- ═══ NOTIFY POSITION PICKER ══
            function Sec:NotifyPositionPicker(opts)
                opts=opts or {}
                local lbl=tostring(opts.Name or "Posição das Notificações")
                local positions={"TopLeft","TopRight","BotLeft","BotRight"}
                local icons2={TopLeft="↖",TopRight="↗",BotLeft="↙",BotRight="↘"}
                local c=Card(44)
                U.New("TextLabel",{Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                local px2=255
                for _,pos in ipairs(positions) do
                    local pb2=U.New("TextButton",{
                        Size=UDim2.new(0,34,0,26),Position=UDim2.new(0,px2,0.5,-13),
                        BackgroundColor3=(SunUI._notifyPos==pos) and T.AccentDim or T.Surface,
                        Text=icons2[pos].." "..pos:sub(1,3),
                        TextColor3=T.TextSub,Font=Enum.Font.GothamBold,TextSize=8,ZIndex=6,
                    },c)
                    U.Corner(7,pb2); U.Stroke(T.Border,1,pb2)
                    pb2.MouseButton1Click:Connect(function()
                        SunUI:SetNotifyPosition(pos)
                        SunUI:Notify({Title="Notificações",Message="Posição alterada: "..pos,Type="Info",Duration=2})
                        pcall(function()
                            for _,ch in ipairs(c:GetChildren()) do
                                if ch:IsA("TextButton") then U.Tween(ch,{BackgroundColor3=T.Surface},0.15) end
                            end
                        end)
                        U.Tween(pb2,{BackgroundColor3=T.AccentDim},0.15)
                    end)
                    px2=px2+38
                end
                return {_element=c}
            end

            return Sec
        end -- Tab:Section
        return Tab
    end -- Win:Tab

    -- ── Abrir janela (com typewriter no título)
    local function OpenMain()
        Main.BackgroundTransparency=1; Main.Size=UDim2.new(0,W,0,0)
        U.Spring(Main,{Size=UDim2.new(0,W,0,H),BackgroundTransparency=0},0.42)
        if titleLbl then
            titleLbl.Text=""
            task.delay(0.2,function() U.Typewriter(titleLbl,title,0.038) end)
        end
    end

    local function AfterKey() Main.Visible=true; OpenMain() end

    if showIntro then
        Main.Visible=false
        PlayIntro(Screen,T,title,function()
            if keyOpts then ShowKeySystem(keyOpts,Screen,T,AfterKey)
            else AfterKey() end
        end)
    elseif keyOpts then
        Main.Visible=false
        ShowKeySystem(keyOpts,Screen,T,AfterKey)
    else
        OpenMain()
    end

    return Win
end

-- ════════════════════════════════════════════════
-- API PÚBLICA EXTRA
-- ════════════════════════════════════════════════
function SunUI:SetFlag(k,v) self.Flags[k]=v end
function SunUI:GetFlag(k) return self.Flags[k] end
function SunUI:SaveConfig() return SaveMgr:Save(self.Flags) end
function SunUI:LoadConfig() return SaveMgr:Load() end

return SunUI
