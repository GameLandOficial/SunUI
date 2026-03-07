--[[
╔══════════════════════════════════════════════════════════════════╗
║   ░██████╗██╗░░░██╗███╗░░██╗  ██╗░░░██╗██╗                     ║
║   ██╔════╝██║░░░██║████╗░██║  ██║░░░██║██║                     ║
║   ╚█████╗░██║░░░██║██╔██╗██║  ██║░░░██║██║                     ║
║   ░╚═══██╗██║░░░██║██║╚████║  ██║░░░██║██║                     ║
║   ██████╔╝╚██████╔╝██║░╚███║  ╚██████╔╝██║                     ║
║   ╚═════╝░░╚═════╝░╚═╝░░╚══╝  ░╚═════╝░╚═╝                     ║
║                                                                  ║
║   SunUI Library · v4.0 ULTIMATE · by Sun                       ║
║                                                                  ║
║   FEATURES:                                                      ║
║   ✦ Intro animada (typewriter + partículas + spring)            ║
║   ✦ Borda RGB rainbow animada OU cor customizada                ║
║   ✦ Gradiente no accent color (2 cores)                         ║
║   ✦ Mudança de cor/tema em tempo real                           ║
║   ✦ Transições suaves entre abas (fade + slide)                 ║
║   ✦ Color Picker HSV completo (hex + rgb)                       ║
║   ✦ Key System opcional e elegante                              ║
║   ✦ Badge de versão do script                                   ║
║   ✦ Borda colorida animada customizável                         ║
║   ✦ Save/Load automático de configs                             ║
║   ✦ Dependency System (igual LinoriaLib)                        ║
║   ✦ Busca global + filtro dentro de dropdowns                   ║
║   ✦ Notificações animadas com tipos                             ║
║   ✦ Multi-dropdown, Progress Bar, Keybind Hold/Toggle           ║
║   ✦ Tooltips em todos os elementos                              ║
║   ✦ Ripple effect nos botões                                    ║
║   ✦ Avatar do jogador na sidebar                                ║
║   ✦ Compatível: Synapse X, KRNL, Fluxus, Solara                ║
╚══════════════════════════════════════════════════════════════════╝
]]

-- ══════════════════════════════════════════
-- SERVIÇOS
-- ══════════════════════════════════════════
local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local HttpService      = game:GetService("HttpService")
local CoreGui          = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════════
-- TABELA PRINCIPAL
-- ══════════════════════════════════════════
local SunUI = {
    Version       = "4.0.0",
    Flags         = {},
    _screen       = nil,
    _notify       = nil,
    _tooltip      = nil,
    _rbRunning    = false,
    _rbTick       = 0,
    _allBorders   = {},
    _allAccents   = {},
    _accentColor  = nil,
    _accentColor2 = nil,
}

-- ══════════════════════════════════════════
-- UTILITÁRIOS
-- ══════════════════════════════════════════
local U = {}

function U.Tween(obj, props, t, style, dir)
    pcall(function()
        TweenService:Create(obj, TweenInfo.new(
            t     or 0.22,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out
        ), props):Play()
    end)
end
function U.Spring(obj, props, t)
    U.Tween(obj, props, t or 0.42, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end
function U.New(cls, props, par)
    local i = Instance.new(cls)
    for k,v in pairs(props or {}) do pcall(function() i[k]=v end) end
    if par then i.Parent = par end
    return i
end
function U.Corner(r,p) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p return c end
function U.Stroke(col,th,p,tr) local s=Instance.new("UIStroke") s.Color=col or Color3.new(1,1,1) s.Thickness=th or 1 s.Transparency=tr or 0 s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border s.Parent=p return s end
function U.Pad(t,b,l,r,p) local x=Instance.new("UIPadding") x.PaddingTop=UDim.new(0,t or 0) x.PaddingBottom=UDim.new(0,b or 0) x.PaddingLeft=UDim.new(0,l or 0) x.PaddingRight=UDim.new(0,r or 0) x.Parent=p return x end
function U.List(sp,ha,p) local l=Instance.new("UIListLayout") l.Padding=UDim.new(0,sp or 0) l.HorizontalAlignment=ha or Enum.HorizontalAlignment.Left l.SortOrder=Enum.SortOrder.LayoutOrder l.Parent=p return l end
function U.AutoCanvas(s,l,e) local function u() s.CanvasSize=UDim2.new(0,0,0,l.AbsoluteContentSize.Y+(e or 16)) end l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(u) u() end
function U.AutoSize(f,l,e) local function u() f.Size=UDim2.new(f.Size.X.Scale,f.Size.X.Offset,0,l.AbsoluteContentSize.Y+(e or 0)) end l:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(u) u() end
function U.ID() return HttpService:GenerateGUID(false):sub(1,8) end
function U.Hex(h) h=h:gsub("#","") if #h~=6 then return Color3.new(1,1,1) end local r=tonumber(h:sub(1,2),16) or 255 local g=tonumber(h:sub(3,4),16) or 255 local b=tonumber(h:sub(5,6),16) or 255 return Color3.fromRGB(r,g,b) end
function U.ToHex(c) return string.format("%02X%02X%02X",math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255)) end
function U.Lerp(a,b,t) return Color3.new(a.R+(b.R-a.R)*t,a.G+(b.G-a.G)*t,a.B+(b.B-a.B)*t) end

function U.Gradient(frame, cA, cB, rot)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(cA, cB)
    g.Rotation = rot or 0
    g.Parent = frame
    return g
end

function U.Draggable(frame, handle)
    local drag,si,sp=false,nil,nil
    handle=handle or frame
    handle.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true si=i.Position sp=frame.Position
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 then drag=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and i.UserInputType==Enum.UserInputType.MouseMovement then
            local d=i.Position-si
            frame.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

function U.Ripple(btn, color)
    btn.ClipsDescendants=true
    btn.InputBegan:Connect(function(i)
        if i.UserInputType~=Enum.UserInputType.MouseButton1 then return end
        local x=i.Position.X-btn.AbsolutePosition.X
        local y=i.Position.Y-btn.AbsolutePosition.Y
        local rip=U.New("Frame",{
            Size=UDim2.new(0,0,0,0), Position=UDim2.new(0,x,0,y),
            AnchorPoint=Vector2.new(.5,.5),
            BackgroundColor3=color or Color3.new(1,1,1),
            BackgroundTransparency=0.72, ZIndex=btn.ZIndex+8,
        },btn)
        U.Corner(999,rip)
        local s=math.max(btn.AbsoluteSize.X,btn.AbsoluteSize.Y)*2.5
        TweenService:Create(rip,TweenInfo.new(.5,Enum.EasingStyle.Quad),
            {Size=UDim2.new(0,s,0,s),BackgroundTransparency=1}):Play()
        task.delay(.55,function() rip:Destroy() end)
    end)
end

function U.Typewriter(lbl, text, speed, done)
    speed=speed or 0.045
    lbl.Text=""
    task.spawn(function()
        for i=1,#text do
            if not lbl.Parent then return end
            lbl.Text=text:sub(1,i)
            task.wait(speed)
        end
        if done then done() end
    end)
end

-- ══════════════════════════════════════════
-- RAINBOW / ACCENT SYSTEM
-- ══════════════════════════════════════════
local function TrackBorder(s) table.insert(SunUI._allBorders,s) end
local function TrackAccent(o,p) table.insert(SunUI._allAccents,{obj=o,prop=p or "BackgroundColor3"}) end

local function StartRainbow()
    if SunUI._rbRunning then return end
    SunUI._rbRunning=true
    task.spawn(function()
        while SunUI._rbRunning do
            SunUI._rbTick=(SunUI._rbTick+0.0025)%1
            local c1=Color3.fromHSV(SunUI._rbTick,1,1)
            for _,s in ipairs(SunUI._allBorders) do
                if s and s.Parent then s.Color=c1 end
            end
            for _,a in ipairs(SunUI._allAccents) do
                if a and a.obj and a.obj.Parent then
                    a.obj[a.prop]=c1
                end
            end
            task.wait(0.016)
        end
    end)
end

function SunUI:SetAccentColor(c1, c2, rainbow)
    self._accentColor=c1
    self._accentColor2=c2 or c1
    self._rbRunning=false
    task.wait(0.05)
    if rainbow then StartRainbow() return end
    for _,s in ipairs(self._allBorders) do if s and s.Parent then s.Color=c1 end end
    for _,a in ipairs(self._allAccents) do
        if a and a.obj and a.obj.Parent then a.obj[a.prop]=c1 end
    end
end

-- ══════════════════════════════════════════
-- TEMAS
-- ══════════════════════════════════════════
SunUI.Themes = {
    Dark={Name="Dark",Bg=Color3.fromRGB(12,12,18),Surface=Color3.fromRGB(18,18,28),SurfaceHigh=Color3.fromRGB(25,25,38),SurfaceHover=Color3.fromRGB(33,33,50),Sidebar=Color3.fromRGB(14,14,22),TitleBar=Color3.fromRGB(9,9,15),Accent=Color3.fromRGB(99,102,241),AccentB=Color3.fromRGB(139,92,246),AccentHover=Color3.fromRGB(79,82,221),AccentDim=Color3.fromRGB(40,43,130),Border=Color3.fromRGB(38,38,60),BorderBright=Color3.fromRGB(58,58,88),Text=Color3.fromRGB(242,242,255),TextSub=Color3.fromRGB(148,148,185),TextMuted=Color3.fromRGB(72,72,108),TextAccent=Color3.fromRGB(150,153,255),Good=Color3.fromRGB(52,211,153),Warn=Color3.fromRGB(251,191,36),Bad=Color3.fromRGB(239,68,68),ToggleOff=Color3.fromRGB(38,38,60),SliderTrack=Color3.fromRGB(32,32,52),InputBg=Color3.fromRGB(14,14,24),NotifyBg=Color3.fromRGB(18,18,30),ScrollBar=Color3.fromRGB(60,60,100)},
    Midnight={Name="Midnight",Bg=Color3.fromRGB(8,6,16),Surface=Color3.fromRGB(14,11,26),SurfaceHigh=Color3.fromRGB(22,17,40),SurfaceHover=Color3.fromRGB(30,24,55),Sidebar=Color3.fromRGB(10,8,20),TitleBar=Color3.fromRGB(6,5,13),Accent=Color3.fromRGB(168,85,247),AccentB=Color3.fromRGB(236,72,153),AccentHover=Color3.fromRGB(145,65,225),AccentDim=Color3.fromRGB(75,30,120),Border=Color3.fromRGB(45,35,75),BorderBright=Color3.fromRGB(65,52,105),Text=Color3.fromRGB(238,232,255),TextSub=Color3.fromRGB(160,140,200),TextMuted=Color3.fromRGB(88,72,135),TextAccent=Color3.fromRGB(200,160,255),Good=Color3.fromRGB(52,211,153),Warn=Color3.fromRGB(251,191,36),Bad=Color3.fromRGB(239,68,68),ToggleOff=Color3.fromRGB(45,35,75),SliderTrack=Color3.fromRGB(38,28,68),InputBg=Color3.fromRGB(12,9,22),NotifyBg=Color3.fromRGB(16,12,30),ScrollBar=Color3.fromRGB(90,50,160)},
    Crimson={Name="Crimson",Bg=Color3.fromRGB(14,8,8),Surface=Color3.fromRGB(22,12,12),SurfaceHigh=Color3.fromRGB(32,18,18),SurfaceHover=Color3.fromRGB(42,24,24),Sidebar=Color3.fromRGB(16,10,10),TitleBar=Color3.fromRGB(10,6,6),Accent=Color3.fromRGB(239,68,68),AccentB=Color3.fromRGB(251,146,60),AccentHover=Color3.fromRGB(215,48,48),AccentDim=Color3.fromRGB(110,28,28),Border=Color3.fromRGB(62,32,32),BorderBright=Color3.fromRGB(85,45,45),Text=Color3.fromRGB(255,240,240),TextSub=Color3.fromRGB(180,130,130),TextMuted=Color3.fromRGB(108,65,65),TextAccent=Color3.fromRGB(255,140,140),Good=Color3.fromRGB(52,211,153),Warn=Color3.fromRGB(251,191,36),Bad=Color3.fromRGB(239,68,68),ToggleOff=Color3.fromRGB(62,32,32),SliderTrack=Color3.fromRGB(52,24,24),InputBg=Color3.fromRGB(18,10,10),NotifyBg=Color3.fromRGB(22,12,12),ScrollBar=Color3.fromRGB(180,50,50)},
    Neon={Name="Neon",Bg=Color3.fromRGB(6,12,18),Surface=Color3.fromRGB(10,19,28),SurfaceHigh=Color3.fromRGB(15,28,42),SurfaceHover=Color3.fromRGB(20,38,56),Sidebar=Color3.fromRGB(7,14,22),TitleBar=Color3.fromRGB(4,9,15),Accent=Color3.fromRGB(6,182,212),AccentB=Color3.fromRGB(59,130,246),AccentHover=Color3.fromRGB(0,158,188),AccentDim=Color3.fromRGB(0,80,105),Border=Color3.fromRGB(20,50,72),BorderBright=Color3.fromRGB(30,72,100),Text=Color3.fromRGB(220,248,255),TextSub=Color3.fromRGB(100,165,200),TextMuted=Color3.fromRGB(42,95,125),TextAccent=Color3.fromRGB(100,230,255),Good=Color3.fromRGB(52,211,153),Warn=Color3.fromRGB(251,191,36),Bad=Color3.fromRGB(239,68,68),ToggleOff=Color3.fromRGB(20,50,72),SliderTrack=Color3.fromRGB(16,42,62),InputBg=Color3.fromRGB(8,16,24),NotifyBg=Color3.fromRGB(9,18,28),ScrollBar=Color3.fromRGB(0,160,200)},
    Emerald={Name="Emerald",Bg=Color3.fromRGB(7,14,11),Surface=Color3.fromRGB(12,22,17),SurfaceHigh=Color3.fromRGB(18,32,25),SurfaceHover=Color3.fromRGB(24,42,33),Sidebar=Color3.fromRGB(8,16,12),TitleBar=Color3.fromRGB(5,10,8),Accent=Color3.fromRGB(16,185,129),AccentB=Color3.fromRGB(20,220,180),AccentHover=Color3.fromRGB(12,160,110),AccentDim=Color3.fromRGB(5,80,56),Border=Color3.fromRGB(22,50,40),BorderBright=Color3.fromRGB(32,70,56),Text=Color3.fromRGB(220,252,244),TextSub=Color3.fromRGB(100,175,148),TextMuted=Color3.fromRGB(44,105,84),TextAccent=Color3.fromRGB(96,240,190),Good=Color3.fromRGB(52,211,153),Warn=Color3.fromRGB(251,191,36),Bad=Color3.fromRGB(239,68,68),ToggleOff=Color3.fromRGB(22,50,40),SliderTrack=Color3.fromRGB(18,42,33),InputBg=Color3.fromRGB(9,17,13),NotifyBg=Color3.fromRGB(10,20,15),ScrollBar=Color3.fromRGB(12,150,100)},
    Light={Name="Light",Bg=Color3.fromRGB(248,248,255),Surface=Color3.fromRGB(238,238,250),SurfaceHigh=Color3.fromRGB(228,228,244),SurfaceHover=Color3.fromRGB(218,218,238),Sidebar=Color3.fromRGB(232,232,248),TitleBar=Color3.fromRGB(222,222,242),Accent=Color3.fromRGB(99,102,241),AccentB=Color3.fromRGB(139,92,246),AccentHover=Color3.fromRGB(79,82,221),AccentDim=Color3.fromRGB(196,198,255),Border=Color3.fromRGB(200,200,232),BorderBright=Color3.fromRGB(180,180,215),Text=Color3.fromRGB(20,20,45),TextSub=Color3.fromRGB(88,88,138),TextMuted=Color3.fromRGB(152,152,190),TextAccent=Color3.fromRGB(75,78,200),Good=Color3.fromRGB(16,185,129),Warn=Color3.fromRGB(245,158,11),Bad=Color3.fromRGB(220,40,40),ToggleOff=Color3.fromRGB(200,200,228),SliderTrack=Color3.fromRGB(208,208,236),InputBg=Color3.fromRGB(252,252,255),NotifyBg=Color3.fromRGB(255,255,255),ScrollBar=Color3.fromRGB(160,162,220)},
}
SunUI.Theme = SunUI.Themes.Dark

-- ══════════════════════════════════════════
-- SAVE MANAGER
-- ══════════════════════════════════════════
local SaveMgr={_f="SunUI_Config.json"}
function SaveMgr:Set(n) self._f=(n or "SunUI_Config")..".json" end
function SaveMgr:Save(flags) if not writefile then return end local ok,d=pcall(HttpService.JSONEncode,HttpService,flags) if ok then pcall(writefile,self._f,d) end end
function SaveMgr:Load() if not(readfile and isfile) then return {} end if not isfile(self._f) then return {} end local ok,d=pcall(function() return HttpService:JSONDecode(readfile(self._f)) end) return(ok and type(d)=="table")and d or {} end

-- ══════════════════════════════════════════
-- NOTIFICAÇÕES
-- ══════════════════════════════════════════
local function SetupNotify(screen)
    if SunUI._notify then return end
    local h=U.New("Frame",{Name="SunUI_Notify",Size=UDim2.new(0,310,1,-20),Position=UDim2.new(1,-322,0,10),BackgroundTransparency=1,ZIndex=200},screen)
    local ll=U.List(8,Enum.HorizontalAlignment.Right,h)
    ll.VerticalAlignment=Enum.VerticalAlignment.Bottom
    SunUI._notify=h
end

function SunUI:Notify(opts)
    opts=opts or {}
    local T    = self.Theme
    local title= opts.Title    or "Aviso"
    local msg  = opts.Message  or ""
    local dur  = opts.Duration or 4
    local kind = opts.Type     or "Info"
    local ic   = ({Info="ℹ",Success="✓",Warning="⚠",Error="✕"})[kind] or "ℹ"
    local clr  = ({Info=T.Accent,Success=T.Good,Warning=T.Warn,Error=T.Bad})[kind] or T.Accent

    if not self._notify then SetupNotify(self._screen or CoreGui) end

    local card=U.New("Frame",{Size=UDim2.new(1,0,0,80),BackgroundColor3=T.NotifyBg,BackgroundTransparency=0.06,ZIndex=201},self._notify)
    U.Corner(11,card)
    local cs=U.Stroke(clr,1.5,card)
    cs.Transparency=0.5

    -- Barra lateral
    local bar=U.New("Frame",{Size=UDim2.new(0,3,1,-16),Position=UDim2.new(0,0,0,8),BackgroundColor3=clr,ZIndex=202},card)
    U.Corner(3,bar)

    -- Ícone
    local ibg=U.New("Frame",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,14,0.5,-18),BackgroundColor3=clr,BackgroundTransparency=0.78,ZIndex=202},card)
    U.Corner(9,ibg)
    U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=ic,TextColor3=clr,Font=Enum.Font.GothamBold,TextSize=17,ZIndex=203},ibg)

    U.New("TextLabel",{Size=UDim2.new(1,-70,0,19),Position=UDim2.new(0,60,0,10),BackgroundTransparency=1,Text=title,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},card)
    U.New("TextLabel",{Size=UDim2.new(1,-70,0,30),Position=UDim2.new(0,60,0,30),BackgroundTransparency=1,Text=msg,TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=202},card)

    -- Progress bar
    local pb=U.New("Frame",{Size=UDim2.new(1,-12,0,2),Position=UDim2.new(0,6,1,-4),BackgroundColor3=T.Border,ZIndex=202},card)
    U.Corner(2,pb)
    local pf=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=clr,ZIndex=203},pb)
    U.Corner(2,pf)

    -- Fechar
    local xb=U.New("TextButton",{Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-22,0,4),BackgroundTransparency=1,Text="✕",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=203},card)
    xb.MouseButton1Click:Connect(function()
        U.Tween(card,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)},0.25)
        task.delay(.3,function() card:Destroy() end)
    end)

    -- Entrada
    card.Position=UDim2.new(0,60,0,0)
    U.Spring(card,{Position=UDim2.new(0,0,0,0)},0.38)

    TweenService:Create(pf,TweenInfo.new(dur,Enum.EasingStyle.Linear),{Size=UDim2.new(0,0,1,0)}):Play()
    task.delay(dur,function()
        U.Tween(card,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,0)},0.3)
        task.delay(.35,function() card:Destroy() end)
    end)
    return card
end

-- ══════════════════════════════════════════
-- TOOLTIP SYSTEM
-- ══════════════════════════════════════════
local function SetupTooltip(screen, T)
    SunUI._tooltip=nil
    local tip=U.New("Frame",{Size=UDim2.new(0,190,0,34),BackgroundColor3=T.SurfaceHigh,Visible=false,ZIndex=300},screen)
    U.Corner(7,tip)
    U.Stroke(T.Border,1,tip)
    local lbl=U.New("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Text="",TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=11,TextWrapped=true,ZIndex=301},tip)
    SunUI._tooltip=tip; SunUI._tooltipLbl=lbl
    RunService.RenderStepped:Connect(function()
        if tip.Visible then
            local mp=UserInputService:GetMouseLocation()
            tip.Position=UDim2.new(0,mp.X+16,0,mp.Y+16)
        end
    end)
end

function U.Tooltip(el,text)
    if not text or text=="" then return end
    el.MouseEnter:Connect(function()
        if SunUI._tooltipLbl then SunUI._tooltipLbl.Text=text SunUI._tooltip.Visible=true end
    end)
    el.MouseLeave:Connect(function()
        if SunUI._tooltip then SunUI._tooltip.Visible=false end
    end)
end

-- ══════════════════════════════════════════
-- KEY SYSTEM
-- ══════════════════════════════════════════
local function ShowKey(opts, screen, T, onOK)
    local title  = opts.Title or "Key System"
    local sub    = opts.Sub   or "Insira a key de acesso"
    local keys   = type(opts.Key)=="table" and opts.Key or {opts.Key}
    local note   = opts.Note  or ""

    -- Overlay escuro
    local ov=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0.5,ZIndex=150},screen)

    local F=U.New("Frame",{Size=UDim2.new(0,420,0,0),Position=UDim2.new(.5,-210,.5,-130),BackgroundColor3=T.Surface,BackgroundTransparency=1,ZIndex=151},screen)
    U.Corner(14,F)
    local fStroke=U.Stroke(T.Accent,2,F)
    TrackBorder(fStroke)

    -- Logo animado
    local logo=U.New("Frame",{Size=UDim2.new(0,50,0,50),Position=UDim2.new(.5,-25,0,20),BackgroundColor3=T.Accent,ZIndex=152},F)
    U.Corner(14,logo)
    TrackAccent(logo,"BackgroundColor3")
    U.Gradient(logo,T.Accent,T.AccentB,135)
    U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="☀",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBlack,TextSize=26,ZIndex=153},logo)

    local ttl=U.New("TextLabel",{Size=UDim2.new(1,-20,0,24),Position=UDim2.new(0,10,0,80),BackgroundTransparency=1,Text="",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=16,ZIndex=152},F)
    U.New("TextLabel",{Size=UDim2.new(1,-20,0,16),Position=UDim2.new(0,10,0,104),BackgroundTransparency=1,Text=sub,TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=12,ZIndex=152},F)

    -- Input
    local ibg=U.New("Frame",{Size=UDim2.new(1,-24,0,38),Position=UDim2.new(0,12,0,132),BackgroundColor3=T.InputBg,ZIndex=152},F)
    U.Corner(10,ibg)
    U.Stroke(T.Border,1,ibg)
    local lock=U.New("TextLabel",{Size=UDim2.new(0,28,1,0),BackgroundTransparency=1,Text="🔑",TextSize=14,ZIndex=153},ibg)
    local tb=U.New("TextBox",{Size=UDim2.new(1,-40,1,0),Position=UDim2.new(0,30,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Insira a key...",PlaceholderColor3=T.TextMuted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=13,ClearTextOnFocus=false,ZIndex=153},ibg)

    local fb=U.New("TextLabel",{Size=UDim2.new(1,-24,0,14),Position=UDim2.new(0,12,0,178),BackgroundTransparency=1,Text=note,TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=152},F)

    local conf=U.New("TextButton",{Size=UDim2.new(1,-24,0,38),Position=UDim2.new(0,12,0,198),BackgroundColor3=T.Accent,Text="CONFIRMAR",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=13,ZIndex=152},F)
    U.Corner(10,conf)
    U.Ripple(conf,Color3.new(1,1,1))
    TrackAccent(conf,"BackgroundColor3")
    conf.MouseEnter:Connect(function() U.Tween(conf,{BackgroundColor3=T.AccentHover},.15) end)
    conf.MouseLeave:Connect(function() U.Tween(conf,{BackgroundColor3=T.Accent},.15) end)

    local function Check()
        local inp=tb.Text:gsub("%s","")
        for _,k in ipairs(keys) do
            if inp==tostring(k) then
                U.Tween(conf,{BackgroundColor3=T.Good},.2)
                fb.Text="✓ Acesso liberado! Carregando..."
                fb.TextColor3=T.Good
                task.delay(.9,function()
                    U.Tween(F,{BackgroundTransparency=1,Size=UDim2.new(0,420,0,0)},.3)
                    U.Tween(ov,{BackgroundTransparency=1},.3)
                    task.delay(.35,function() F:Destroy() ov:Destroy() onOK() end)
                end)
                return
            end
        end
        fb.Text="✗ Key incorreta!"
        fb.TextColor3=T.Bad
        U.Tween(ibg,{BackgroundColor3=U.Lerp(T.InputBg,T.Bad,.22)},.15)
        task.delay(.7,function() U.Tween(ibg,{BackgroundColor3=T.InputBg},.3) end)
    end
    conf.MouseButton1Click:Connect(Check)
    tb.FocusLost:Connect(function(e) if e then Check() end end)

    -- Animação de entrada
    U.Spring(F,{Size=UDim2.new(0,420,0,248),BackgroundTransparency=0},.4)
    U.Typewriter(ttl,title,.06)
    U.Draggable(F,F)
end

-- ══════════════════════════════════════════
-- COLOR PICKER COMPLETO
-- ══════════════════════════════════════════
local function MakeColorPicker(parent, default, T, onChange)
    default=default or Color3.fromRGB(255,80,80)
    local h,s,v=Color3.toHSV(default)
    local isOpen=false

    local Wrap=U.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.SurfaceHigh,ZIndex=5},parent)
    U.Corner(9,Wrap)

    local prev=U.New("Frame",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,-40,.5,-14),BackgroundColor3=default,ZIndex=6},Wrap)
    U.Corner(7,prev)
    U.Stroke(T.Border,1,prev)
    local chevron=U.New("TextLabel",{Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-60,.5,-10),BackgroundTransparency=1,Text="▾",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=6},Wrap)

    local Panel=U.New("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,5),BackgroundColor3=T.Surface,ClipsDescendants=true,Visible=false,ZIndex=20},Wrap)
    U.Corner(10,Panel)
    U.Stroke(T.BorderBright,1,Panel)

    -- SV Picker (saturação + valor)
    local SVF=U.New("Frame",{Size=UDim2.new(1,-16,0,140),Position=UDim2.new(0,8,0,8),BackgroundColor3=Color3.fromHSV(h,1,1),ZIndex=21},Panel)
    U.Corner(8,SVF)
    -- Gradiente branco→transparente
    local svGrad=U.New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.new(1,1,1)),ColorSequenceKeypoint.new(1,Color3.new(1,1,1))}),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)})},SVF)
    -- Escurecimento vertical
    local svDk=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),ZIndex=22},SVF)
    U.Corner(8,svDk)
    U.New("UIGradient",{Color=ColorSequence.new(Color3.new(0,0,0),Color3.new(0,0,0)),Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),Rotation=90},svDk)
    local svCur=U.New("Frame",{Size=UDim2.new(0,12,0,12),Position=UDim2.new(s,-6,1-v,-6),BackgroundColor3=Color3.new(1,1,1),ZIndex=24},SVF)
    U.Corner(999,svCur) U.Stroke(Color3.new(0,0,0),1.5,svCur)

    -- Hue slider
    local HueT=U.New("Frame",{Size=UDim2.new(1,-16,0,16),Position=UDim2.new(0,8,0,156),ZIndex=21},Panel)
    U.Corner(6,HueT)
    U.New("UIGradient",{Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromHSV(0,1,1)),ColorSequenceKeypoint.new(.17,Color3.fromHSV(.17,1,1)),ColorSequenceKeypoint.new(.33,Color3.fromHSV(.33,1,1)),ColorSequenceKeypoint.new(.5,Color3.fromHSV(.5,1,1)),ColorSequenceKeypoint.new(.67,Color3.fromHSV(.67,1,1)),ColorSequenceKeypoint.new(.83,Color3.fromHSV(.83,1,1)),ColorSequenceKeypoint.new(1,Color3.fromHSV(1,1,1))})},HueT)
    local HueCur=U.New("Frame",{Size=UDim2.new(0,12,1,4),Position=UDim2.new(h,-6,0,-2),BackgroundColor3=Color3.new(1,1,1),ZIndex=22},HueT)
    U.Corner(4,HueCur) U.Stroke(Color3.new(0,0,0),1,HueCur)

    -- Hex input
    local hexBg=U.New("Frame",{Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,8,0,180),BackgroundColor3=T.InputBg,ZIndex=21},Panel)
    U.Corner(7,hexBg) U.Stroke(T.Border,1,hexBg)
    U.New("TextLabel",{Size=UDim2.new(0,26,1,0),BackgroundTransparency=1,Text="#",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=22},hexBg)
    local hexTB=U.New("TextBox",{Size=UDim2.new(1,-34,1,0),Position=UDim2.new(0,28,0,0),BackgroundTransparency=1,Text=U.ToHex(default),PlaceholderText="FF0000",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=22},hexBg)

    -- RGB inputs (bônus)
    local rgbBg=U.New("Frame",{Size=UDim2.new(1,-16,0,30),Position=UDim2.new(0,8,0,218),BackgroundColor3=T.InputBg,ZIndex=21},Panel)
    U.Corner(7,rgbBg) U.Stroke(T.Border,1,rgbBg)
    local rgbLbl=U.New("TextLabel",{Size=UDim2.new(1,-12,1,0),Position=UDim2.new(0,6,0,0),BackgroundTransparency=1,Text=string.format("R:%d  G:%d  B:%d",math.floor(default.R*255),math.floor(default.G*255),math.floor(default.B*255)),TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=11,ZIndex=22},rgbBg)

    Panel.Size=UDim2.new(1,0,0,0)

    local function UpdateColor()
        local c=Color3.fromHSV(h,s,v)
        prev.BackgroundColor3=c
        SVF.BackgroundColor3=Color3.fromHSV(h,1,1)
        svCur.Position=UDim2.new(s,-6,1-v,-6)
        HueCur.Position=UDim2.new(h,-6,0,-2)
        hexTB.Text=U.ToHex(c)
        rgbLbl.Text=string.format("R:%d  G:%d  B:%d",math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255))
        if onChange then onChange(c) end
    end

    -- SV drag
    local svDrag=false
    local svH=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=25},SVF)
    svH.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then svDrag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if svDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            s=math.clamp((i.Position.X-SVF.AbsolutePosition.X)/SVF.AbsoluteSize.X,0,1)
            v=1-math.clamp((i.Position.Y-SVF.AbsolutePosition.Y)/SVF.AbsoluteSize.Y,0,1)
            UpdateColor()
        end
    end)

    -- Hue drag
    local hueDrag=false
    local hueH=U.New("TextButton",{Size=UDim2.new(1,0,2,0),Position=UDim2.new(0,0,-.5,0),BackgroundTransparency=1,Text="",ZIndex=23},HueT)
    hueH.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=true end end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then hueDrag=false end end)
    UserInputService.InputChanged:Connect(function(i)
        if hueDrag and i.UserInputType==Enum.UserInputType.MouseMovement then
            h=math.clamp((i.Position.X-HueT.AbsolutePosition.X)/HueT.AbsoluteSize.X,0,1)
            UpdateColor()
        end
    end)

    -- Hex submit
    hexTB.FocusLost:Connect(function()
        local ok,c=pcall(U.Hex,hexTB.Text)
        if ok then h,s,v=Color3.toHSV(c) UpdateColor() end
    end)

    -- Toggle picker
    local openBtn=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7},Wrap)
    openBtn.MouseButton1Click:Connect(function()
        isOpen=not isOpen
        local totalH=258
        Panel.Visible=isOpen
        if isOpen then
            U.Tween(Wrap,{Size=UDim2.new(1,0,0,44+8+totalH)},.26,Enum.EasingStyle.Quart)
            U.Tween(Panel,{Size=UDim2.new(1,0,0,totalH)},.26,Enum.EasingStyle.Quart)
            U.Tween(chevron,{Rotation=180},.2)
        else
            U.Tween(Wrap,{Size=UDim2.new(1,0,0,44)},.22)
            U.Tween(Panel,{Size=UDim2.new(1,0,0,0)},.22)
            U.Tween(chevron,{Rotation=0},.2)
            task.delay(.25,function() Panel.Visible=false end)
        end
    end)

    Wrap.MouseEnter:Connect(function() if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHover},.15) end end)
    Wrap.MouseLeave:Connect(function() if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHigh},.15) end end)

    local Obj={}
    function Obj:Get() return Color3.fromHSV(h,s,v) end
    function Obj:Set(c) h,s,v=Color3.toHSV(c) UpdateColor() end
    return Obj
end

-- ══════════════════════════════════════════
-- ANIMAÇÃO DE INTRO
-- ══════════════════════════════════════════
local function PlayIntro(screen, T, title, onDone)
    local overlay=U.New("Frame",{Size=UDim2.new(1,0,1,0),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=0,ZIndex=500},screen)

    -- Logo central
    local logoW=U.New("Frame",{Size=UDim2.new(0,80,0,80),Position=UDim2.new(.5,-40,.5,-60),BackgroundColor3=T.Accent,BackgroundTransparency=1,ZIndex=501},screen)
    U.Corner(20,logoW)
    TrackAccent(logoW,"BackgroundColor3")
    local logoLbl=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="☀",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBlack,TextSize=42,BackgroundTransparency=1,ZIndex=502},logoW)

    local titleLbl=U.New("TextLabel",{Size=UDim2.new(0,400,0,36),Position=UDim2.new(.5,-200,.5,30),BackgroundTransparency=1,Text="",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=22,ZIndex=501},screen)
    local subLbl=U.New("TextLabel",{Size=UDim2.new(0,400,0,20),Position=UDim2.new(.5,-200,.5,68),BackgroundTransparency=1,Text="",TextColor3=Color3.fromRGB(180,180,220),Font=Enum.Font.Gotham,TextSize=13,ZIndex=501},screen)

    -- Partículas simples (quadradinhos que aparecem)
    local particles={}
    for i=1,18 do
        local px=math.random(50,screen.AbsoluteSize.X-50)
        local py=math.random(50,screen.AbsoluteSize.Y-50)
        local sz=math.random(3,8)
        local p=U.New("Frame",{
            Size=UDim2.new(0,sz,0,sz),
            Position=UDim2.new(0,px,0,py),
            BackgroundColor3=T.Accent,
            BackgroundTransparency=1,
            ZIndex=501,
            Rotation=math.random(0,45),
        },screen)
        U.Corner(2,p)
        table.insert(particles,p)
    end

    -- Sequência
    task.spawn(function()
        task.wait(.1)
        -- Logo aparece
        U.Tween(logoW,{BackgroundTransparency=0,Size=UDim2.new(0,80,0,80)},.45,Enum.EasingStyle.Back)
        task.wait(.35)

        -- Partículas
        for i,p in ipairs(particles) do
            task.delay(i*0.04,function()
                U.Tween(p,{BackgroundTransparency=0.55},.3)
                task.delay(.8,function()
                    U.Tween(p,{BackgroundTransparency=1,.6})
                end)
            end)
        end

        -- Typewriter no título
        task.wait(.15)
        U.Typewriter(titleLbl,title,.05,function()
            subLbl.Text="Carregando..."
            U.Tween(subLbl,{TextTransparency=0},.3)
        end)

        task.wait(1.8)

        -- Logo vai pra cima e some
        U.Tween(logoW,{Position=UDim2.new(.5,-40,0,-100),BackgroundTransparency=1},.5,Enum.EasingStyle.Back,Enum.EasingDirection.In)
        U.Tween(titleLbl,{TextTransparency=1},.4)
        U.Tween(subLbl,{TextTransparency=1},.4)
        for _,p in ipairs(particles) do U.Tween(p,{BackgroundTransparency=1},.3) end
        U.Tween(overlay,{BackgroundTransparency=1},.5)

        task.wait(.55)
        for _,p in ipairs(particles) do pcall(function() p:Destroy() end) end
        logoW:Destroy(); titleLbl:Destroy(); subLbl:Destroy(); overlay:Destroy()
        onDone()
    end)
end

-- ══════════════════════════════════════════
-- CRIAR JANELA PRINCIPAL
-- ══════════════════════════════════════════
function SunUI:CreateWindow(opts)
    opts = opts or {}

    -- Resolver tema
    local T
    if type(opts.Theme)=="table" then
        T=opts.Theme; T.Name=T.Name or "Custom"
    elseif opts.Theme and self.Themes[opts.Theme] then
        T=self.Themes[opts.Theme]
    else
        T=self.Themes.Dark
    end
    self.Theme=T

    -- Aplicar accent customizado
    if opts.AccentColor then
        local T2=opts.AccentColor2 or opts.AccentColor
        T.Accent=opts.AccentColor; T.AccentB=T2; T.AccentHover=opts.AccentColor; T.AccentDim=U.Lerp(opts.AccentColor,Color3.new(0,0,0),.5)
    end

    local title      = opts.Title      or "SunUI"
    local subtitle   = opts.Subtitle   or "v4.0"
    local version    = opts.Version    -- ex: "v1.2.3" — aparece no canto
    local toggleKey  = opts.ToggleKey  or Enum.KeyCode.RightShift
    local W          = opts.Width      or 720
    local H          = opts.Height     or 500
    local configFile = opts.ConfigFile or "SunUI_Config"
    local rainbow    = opts.RainbowBorder or false
    local showIntro  = opts.Intro ~= false  -- true por padrão
    local keyOpts    = opts.KeySystem
    local discordURL = opts.DiscordUrl

    SaveMgr:Set(configFile)
    SunUI._allBorders={}; SunUI._allAccents={}

    -- Limpar instância anterior
    pcall(function() CoreGui.SunUI_v4:Destroy() end)

    local Screen=U.New("ScreenGui",{Name="SunUI_v4",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},CoreGui)
    if syn and syn.protect_gui then syn.protect_gui(Screen) end
    self._screen=Screen

    SetupTooltip(Screen,T)
    SetupNotify(Screen)

    -- ── BORDA EXTERIOR ANIMADA ─────────────
    -- Sombra
    U.New("ImageLabel",{
        AnchorPoint=Vector2.new(.5,.5), Size=UDim2.new(0,W+90,0,H+90),
        Position=UDim2.new(.5,0,.5,0), BackgroundTransparency=1,
        Image="rbxassetid://6014261993",
        ImageColor3=Color3.new(0,0,0), ImageTransparency=0.38,
        ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(49,49,450,450),
        ZIndex=0
    },Screen)

    -- Frame principal
    local Main=U.New("Frame",{
        Name="Main", Size=UDim2.new(0,W,0,0),
        Position=UDim2.new(.5,-W/2,.5,-H/2),
        BackgroundColor3=T.Bg, ClipsDescendants=true,
        ZIndex=1
    },Screen)
    U.Corner(13,Main)
    local mainStroke=U.Stroke(T.Accent,2,Main)
    TrackBorder(mainStroke)

    -- Badge de versão (canto superior direito da janela)
    if version then
        local vBadge=U.New("Frame",{
            Size=UDim2.new(0,0,0,20),
            Position=UDim2.new(1,-8,0,-12),
            BackgroundColor3=T.Accent, ZIndex=10
        },Main)
        U.Corner(6,vBadge)
        TrackAccent(vBadge,"BackgroundColor3")
        local vLbl=U.New("TextLabel",{
            Size=UDim2.new(1,-8,1,0), Position=UDim2.new(0,4,0,0),
            BackgroundTransparency=1, Text=version,
            TextColor3=Color3.new(1,1,1), Font=Enum.Font.GothamBold,
            TextSize=9, ZIndex=11
        },vBadge)
        task.defer(function()
            vBadge.Size=UDim2.new(0,vLbl.TextBounds.X+12,0,20)
        end)
    end

    -- ── TITLEBAR ──────────────────────────
    local TH=52
    local TBar=U.New("Frame",{Size=UDim2.new(1,0,0,TH),BackgroundColor3=T.TitleBar,ZIndex=5},Main)
    -- Linha accent no topo da titlebar
    local topLine=U.New("Frame",{Size=UDim2.new(1,0,0,2),BackgroundColor3=T.Accent,ZIndex=6},TBar)
    TrackAccent(topLine,"BackgroundColor3")
    -- Gradiente
    U.Gradient(TBar,T.TitleBar,U.Lerp(T.TitleBar,T.Surface,.4),90)
    -- Divisória inferior
    U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,ZIndex=5},TBar)

    -- Logo ☀ animado
    local logoFrame=U.New("Frame",{Size=UDim2.new(0,36,0,36),Position=UDim2.new(0,14,.5,-18),BackgroundColor3=T.Accent,ZIndex=7},TBar)
    U.Corner(10,logoFrame)
    TrackAccent(logoFrame,"BackgroundColor3")
    U.Gradient(logoFrame,T.Accent,T.AccentB,135)
    U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="☀",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBlack,TextSize=18,ZIndex=8},logoFrame)

    -- Título (typewriter ao abrir)
    local titleLbl=U.New("TextLabel",{Size=UDim2.new(0,260,0,22),Position=UDim2.new(0,60,0,8),BackgroundTransparency=1,Text=title,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},TBar)
    local subtitleLbl=U.New("TextLabel",{Size=UDim2.new(0,260,0,16),Position=UDim2.new(0,60,0,30),BackgroundTransparency=1,Text=subtitle,TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=7},TBar)

    -- Botões de controle
    local function MakeCtrl(icon, bg, xOff, cb, tip)
        local b=U.New("TextButton",{Size=UDim2.new(0,28,0,28),Position=UDim2.new(1,xOff,.5,-14),BackgroundColor3=bg,BackgroundTransparency=0.3,Text=icon,TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=11,ZIndex=8},TBar)
        U.Corner(999,b)
        b.MouseEnter:Connect(function() U.Tween(b,{BackgroundTransparency=0},.12) end)
        b.MouseLeave:Connect(function() U.Tween(b,{BackgroundTransparency=0.3},.12) end)
        b.MouseButton1Click:Connect(cb)
        if tip then U.Tooltip(b,tip) end
        return b
    end
    local minimized=false
    MakeCtrl("✕",Color3.fromRGB(220,50,50),-14,function()
        SaveMgr:Save(SunUI.Flags)
        SunUI._rbRunning=false
        U.Tween(Main,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},.3)
        task.delay(.35,function() Screen:Destroy() end)
    end,"Fechar")
    MakeCtrl("─",T.Border,-50,function()
        minimized=not minimized
        U.Tween(Main,{Size=minimized and UDim2.new(0,W,0,TH) or UDim2.new(0,W,0,H)},.3,Enum.EasingStyle.Quart)
    end,minimized and "Restaurar" or "Minimizar")

    U.Draggable(Main,TBar)

    -- ── SIDEBAR ───────────────────────────
    local SW=185
    local Side=U.New("Frame",{Size=UDim2.new(0,SW,1,-TH),Position=UDim2.new(0,0,0,TH),BackgroundColor3=T.Sidebar,ZIndex=3},Main)
    -- Divisória
    U.New("Frame",{Size=UDim2.new(0,1,1,0),Position=UDim2.new(1,0,0,0),BackgroundColor3=T.Border,ZIndex=4},Side)
    -- Linha accent na divisória
    local sideLine=U.New("Frame",{Size=UDim2.new(0,2,1,0),Position=UDim2.new(1,-1,0,0),BackgroundColor3=T.Accent,BackgroundTransparency=0.7,ZIndex=5},Side)
    TrackAccent(sideLine,"BackgroundColor3")

    -- Avatar do jogador
    local avFrame=U.New("Frame",{Size=UDim2.new(1,0,0,78),BackgroundTransparency=1,ZIndex=4},Side)
    local avRing=U.New("Frame",{Size=UDim2.new(0,46,0,46),Position=UDim2.new(0,12,.5,-23),BackgroundColor3=T.Accent,ZIndex=4},avFrame)
    U.Corner(999,avRing)
    TrackAccent(avRing,"BackgroundColor3")
    local avImg=U.New("ImageLabel",{Size=UDim2.new(1,-4,1,-4),Position=UDim2.new(0,2,0,2),BackgroundColor3=T.SurfaceHigh,Image="https://www.roblox.com/headshot-thumbnail/image?userId="..LocalPlayer.UserId.."&width=150&height=150&format=png",ZIndex=5},avRing)
    U.Corner(999,avImg)
    U.New("TextLabel",{Size=UDim2.new(1,-74,0,18),Position=UDim2.new(0,70,.5,-20),BackgroundTransparency=1,Text=LocalPlayer.Name,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},avFrame)
    U.New("TextLabel",{Size=UDim2.new(1,-74,0,14),Position=UDim2.new(0,70,.5,2),BackgroundTransparency=1,Text="SunUI v4.0",TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},avFrame)
    U.New("Frame",{Size=UDim2.new(1,-20,0,1),Position=UDim2.new(0,10,1,-1),BackgroundColor3=T.Border,ZIndex=4},avFrame)

    -- Scroll de tabs na sidebar
    local SideScroll=U.New("ScrollingFrame",{Size=UDim2.new(1,0,1,-84),Position=UDim2.new(0,0,0,80),BackgroundTransparency=1,ScrollBarThickness=2,ScrollBarImageColor3=T.ScrollBar,ZIndex=4},Side)
    local SideList=U.List(2,Enum.HorizontalAlignment.Center,SideScroll)
    U.Pad(4,6,6,6,SideScroll)
    U.AutoCanvas(SideScroll,SideList,12)

    -- Botão Discord (se fornecido)
    if discordURL then
        local dcBtn=U.New("TextButton",{
            Size=UDim2.new(1,-16,0,32),
            Position=UDim2.new(0,8,1,-40),
            BackgroundColor3=Color3.fromRGB(88,101,242),
            Text="  Discord",TextColor3=Color3.new(1,1,1),
            Font=Enum.Font.GothamBold,TextSize=12,ZIndex=5
        },Side)
        U.Corner(9,dcBtn)
        dcBtn.MouseButton1Click:Connect(function()
            -- Abrir Discord se possível
            pcall(function() game:GetService("GuiService"):OpenBrowserWindow(discordURL) end)
        end)
    end

    -- ── CONTENT ───────────────────────────
    local Content=U.New("Frame",{Size=UDim2.new(1,-SW,1,-TH),Position=UDim2.new(0,SW,0,TH),BackgroundColor3=T.Surface,ZIndex=2},Main)

    -- Header search
    local SBH=46
    local SBar=U.New("Frame",{Size=UDim2.new(1,0,0,SBH),BackgroundColor3=T.SurfaceHigh,ZIndex=4},Content)
    U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,ZIndex=4},SBar)
    U.New("TextLabel",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,14,.5,-9),BackgroundTransparency=1,Text="🔍",TextSize=15,ZIndex=5},SBar)
    local SearchTB=U.New("TextBox",{Size=UDim2.new(1,-100,1,0),Position=UDim2.new(0,36,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Pesquisar...",PlaceholderColor3=T.TextMuted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=5},SBar)

    -- Contador de resultados da busca
    local searchCount=U.New("TextLabel",{Size=UDim2.new(0,70,1,0),Position=UDim2.new(1,-80,0,0),BackgroundTransparency=1,Text="",TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,ZIndex=5},SBar)

    -- Páginas de tabs
    local PageHolder=U.New("Frame",{Name="Pages",Size=UDim2.new(1,0,1,-SBH),Position=UDim2.new(0,0,0,SBH),BackgroundTransparency=1,ClipsDescendants=true,ZIndex=3},Content)

    -- ── WIN OBJECT ─────────────────────────
    local Win={
        _tabs={}, _active=nil,
        _screen=Screen, _searchTargets={},
        _T=T,
    }

    -- Toggle visibilidade com tecla
    UserInputService.InputBegan:Connect(function(inp,gpe)
        if gpe then return end
        if inp.KeyCode==toggleKey then
            if Main.Visible then
                U.Tween(Main,{Size=UDim2.new(0,W,0,0),BackgroundTransparency=1},.25)
                task.delay(.28,function() Main.Visible=false end)
            else
                Main.Visible=true Main.BackgroundTransparency=1
                Main.Size=UDim2.new(0,W,0,0)
                U.Spring(Main,{Size=UDim2.new(0,W,0,H),BackgroundTransparency=0},.38)
            end
        end
    end)

    -- Busca global
    local searchVisible=0
    SearchTB:GetPropertyChangedSignal("Text"):Connect(function()
        local q=SearchTB.Text:lower():match("^%s*(.-)%s*$")
        local count=0
        for _,tgt in pairs(Win._searchTargets) do
            if tgt.el and tgt.el.Parent then
                local show=(q=="" or tgt.name:lower():find(q,1,true))
                tgt.el.Visible=show
                if show then count=count+1 end
            end
        end
        if q~="" then
            searchCount.Text=count.." encontrado(s)"
        else
            searchCount.Text=""
        end
    end)

    -- Auto-save
    SunUI._rbRunning=false
    if rainbow then
        SunUI._rbTick=0
        StartRainbow()
    end

    task.spawn(function()
        while Screen and Screen.Parent do
            task.wait(45)
            SaveMgr:Save(SunUI.Flags)
        end
    end)

    -- ── MÉTODOS DO WIN ────────────────────
    function Win:EnableAutoSave()
        local saved=SaveMgr:Load()
        for k,v in pairs(saved) do SunUI.Flags[k]=v end
        self:Notify({Title="Config carregada",Message="Configurações restauradas!",Type="Success"})
    end

    function Win:Notify(o)
        return SunUI:Notify(o)
    end

    function Win:SetTheme(name)
        if SunUI.Themes[name] then
            SunUI:Notify({Title="Tema: "..name,Message="Reinicie o script para aplicar o tema.",Type="Info",Duration=4})
        end
    end

    -- ── ADICIONAR ABA ─────────────────────
    function Win:Tab(name, icon)
        icon=icon or "◆"

        -- Botão na sidebar
        local Btn=U.New("TextButton",{Name="Tab_"..name,Size=UDim2.new(1,0,0,42),BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=1,Text="",ZIndex=5},SideScroll)
        U.Corner(9,Btn)

        local acBar=U.New("Frame",{Size=UDim2.new(0,3,0,26),Position=UDim2.new(0,0,.5,-13),BackgroundColor3=T.Accent,BackgroundTransparency=1,ZIndex=6},Btn)
        U.Corner(4,acBar)
        TrackAccent(acBar,"BackgroundColor3")

        local icoBox=U.New("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,10,.5,-15),BackgroundColor3=T.SurfaceHigh,BackgroundTransparency=.4,ZIndex=6},Btn)
        U.Corner(8,icoBox)
        local icoL=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,TextSize=15,Font=Enum.Font.GothamBold,TextColor3=T.TextMuted,ZIndex=7},icoBox)
        local namL=U.New("TextLabel",{Size=UDim2.new(1,-56,1,0),Position=UDim2.new(0,48,0,0),BackgroundTransparency=1,Text=name,TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=6},Btn)

        -- Página (ScrollingFrame)
        local Page=U.New("ScrollingFrame",{Name="Page_"..name,Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,ScrollBarThickness=3,ScrollBarImageColor3=T.ScrollBar,Visible=false,ZIndex=3},PageHolder)
        local PLayout=U.List(5,Enum.HorizontalAlignment.Center,Page)
        U.Pad(10,10,12,12,Page)
        U.AutoCanvas(Page,PLayout,10)

        -- Transição de aba
        local function ActivateTab()
            for n,tab in pairs(Win._tabs) do
                local on=(n==name)
                -- Transição fade + slide
                if on and not tab.Page.Visible then
                    tab.Page.Visible=true
                    tab.Page.Position=UDim2.new(0.08,0,0,0)
                    tab.Page.BackgroundTransparency=1
                    U.Tween(tab.Page,{Position=UDim2.new(0,0,0,0),BackgroundTransparency=1},.22,Enum.EasingStyle.Quart)
                elseif not on then
                    tab.Page.Visible=false
                end
                U.Tween(tab.Btn,{BackgroundColor3=on and T.SurfaceHover or Color3.new(0,0,0),BackgroundTransparency=on and 0.6 or 1},.18)
                U.Tween(tab.acBar,{BackgroundTransparency=on and 0 or 1},.18)
                U.Tween(tab.namL,{TextColor3=on and T.Text or T.TextSub,Font=on and Enum.Font.GothamBold or Enum.Font.Gotham},.15)
                U.Tween(tab.icoL,{TextColor3=on and T.TextAccent or T.TextMuted},.15)
                U.Tween(tab.icoBox,{BackgroundColor3=on and T.AccentDim or T.SurfaceHigh,BackgroundTransparency=on and .1 or .4},.15)
            end
            Win._active=name
        end

        Btn.MouseButton1Click:Connect(ActivateTab)
        Btn.MouseEnter:Connect(function()
            if Win._active~=name then U.Tween(Btn,{BackgroundTransparency=.85},.12) end
        end)
        Btn.MouseLeave:Connect(function()
            if Win._active~=name then U.Tween(Btn,{BackgroundTransparency=1},.12) end
        end)

        Win._tabs[name]={Btn=Btn,Page=Page,acBar=acBar,namL=namL,icoL=icoL,icoBox=icoBox}
        if not Win._active then ActivateTab() end

        -- ── TAB OBJECT ────────────────────
        local Tab={_page=Page,_T=T}

        function Tab:Section(secName)
            -- Wrapper da seção
            local SWrap=U.New("Frame",{Size=UDim2.new(1,0,0,10),BackgroundTransparency=1,ZIndex=3},Page)
            local SL=U.List(3,Enum.HorizontalAlignment.Center,SWrap)
            U.AutoSize(SWrap,SL,2)

            -- Header
            local SHead=U.New("Frame",{Size=UDim2.new(1,0,0,26),BackgroundTransparency=1,ZIndex=3},SWrap)
            local secLbl=U.New("TextLabel",{Size=UDim2.new(1,-8,1,0),BackgroundTransparency=1,Text=secName:upper(),TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=9,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=4},SHead)
            U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,1,-1),BackgroundColor3=T.Border,ZIndex=3},SHead)

            -- ── SEÇÃO FACTORY ─────────────
            local Sec={}

            local function Card(h, par)
                local c=U.New("Frame",{Size=UDim2.new(1,0,0,h),BackgroundColor3=T.SurfaceHigh,ZIndex=4},par or SWrap)
                U.Corner(9,c)
                return c
            end

            local function Reg(nm,el)
                table.insert(Win._searchTargets,{name=nm,el=el})
            end

            -- ═══ TOGGLE ═══════════════════
            function Sec:Toggle(opts)
                opts=opts or {}
                local lbl=opts.Name or "Toggle"
                local desc=opts.Desc
                local def=opts.Default~=nil and opts.Default or false
                local cb=opts.Callback or function() end
                local fid=opts.Flag or U.ID()
                local tip=opts.Tooltip or ""
                local H=desc and 54 or 44

                local state=def
                SunUI.Flags[fid]=state

                local c=Card(H)
                c.Name="Tog_"..lbl

                -- Ícone
                local ibg=U.New("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,10,.5,-15),BackgroundColor3=state and T.AccentDim or T.Surface,ZIndex=5},c)
                U.Corner(8,ibg)
                local ilbl=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="◈",TextSize=14,Font=Enum.Font.GothamBold,TextColor3=state and T.TextAccent or T.TextMuted,ZIndex=6},ibg)

                U.New("TextLabel",{Size=UDim2.new(1,-100,0,desc and 20 or 30),Position=UDim2.new(0,50,0,desc and 8 or 7),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                if desc then
                    U.New("TextLabel",{Size=UDim2.new(1,-100,0,16),Position=UDim2.new(0,50,0,28),BackgroundTransparency=1,Text=desc,TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                end

                -- Track animado
                local Track=U.New("Frame",{Size=UDim2.new(0,48,0,26),Position=UDim2.new(1,-60,.5,-13),BackgroundColor3=state and T.Accent or T.ToggleOff,ZIndex=5},c)
                U.Corner(999,Track)
                if state then TrackAccent(Track,"BackgroundColor3") end
                local Knob=U.New("Frame",{Size=UDim2.new(0,20,0,20),Position=state and UDim2.new(1,-23,.5,-10) or UDim2.new(0,3,.5,-10),BackgroundColor3=Color3.new(1,1,1),ZIndex=6},Track)
                U.Corner(999,Knob)
                -- Brilho no knob
                U.New("Frame",{Size=UDim2.new(1,0,.5,0),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=0.72,ZIndex=7},Knob).Parent=Knob
                U.Corner(999,Knob:FindFirstChildOfClass("Frame"))

                local hit=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=8},c)
                U.Ripple(hit,T.Accent)
                if tip~="" then U.Tooltip(c,tip) end

                local deps={}

                local function Apply(val,silent)
                    state=val; SunUI.Flags[fid]=state
                    U.Tween(Track,{BackgroundColor3=state and T.Accent or T.ToggleOff},.2)
                    U.Tween(Knob,{Position=state and UDim2.new(1,-23,.5,-10) or UDim2.new(0,3,.5,-10)},.2)
                    U.Tween(ibg,{BackgroundColor3=state and T.AccentDim or T.Surface},.2)
                    U.Tween(ilbl,{TextColor3=state and T.TextAccent or T.TextMuted},.2)
                    for _,d in pairs(deps) do
                        if d.el and d.el.Parent then
                            d.el.Visible=d.inv and not state or state
                        end
                    end
                    if not silent then task.spawn(cb,state) end
                end

                hit.MouseButton1Click:Connect(function() Apply(not state) end)
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},.15) end)
                Reg(lbl,c)

                local Obj={_element=c}
                function Obj:Set(v) Apply(v,false) end
                function Obj:Get() return state end
                function Obj:Toggle() Apply(not state) end
                function Obj:AddDep(el,inv) table.insert(deps,{el=el._element or el,inv=inv or false}) if el._element then el._element.Visible=state else el.Visible=state end end
                return Obj
            end

            -- ═══ SLIDER ═══════════════════
            function Sec:Slider(opts)
                opts=opts or {}
                local lbl=opts.Name or "Slider"
                local desc=opts.Desc
                local mn=opts.Min or 0
                local mx=opts.Max or 100
                local def=math.clamp(opts.Default or mn,mn,mx)
                local suf=opts.Suffix or ""
                local cb=opts.Callback or function() end
                local fid=opts.Flag or U.ID()
                local step=opts.Step or 1
                local tip=opts.Tooltip or ""
                local H=desc and 60 or 52

                local value=def
                SunUI.Flags[fid]=value

                local c=Card(H)
                c.Name="Sld_"..lbl

                U.New("TextLabel",{Size=UDim2.new(.65,0,0,18),Position=UDim2.new(0,10,0,desc and 7 or 6),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                if desc then
                    U.New("TextLabel",{Size=UDim2.new(.65,0,0,14),Position=UDim2.new(0,10,0,26),BackgroundTransparency=1,Text=desc,TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                end

                local vBox=U.New("Frame",{Size=UDim2.new(0,62,0,28),Position=UDim2.new(1,-72,0,desc and 7 or 6),BackgroundColor3=T.Surface,ZIndex=5},c)
                U.Corner(8,vBox) U.Stroke(T.Border,1,vBox)
                local vLbl=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=value..suf,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,ZIndex=6},vBox)

                local tY=desc and 44 or 35
                local tBg=U.New("Frame",{Size=UDim2.new(1,-20,0,6),Position=UDim2.new(0,10,0,tY),BackgroundColor3=T.SliderTrack,ZIndex=5},c)
                U.Corner(4,tBg)
                local pct=(value-mn)/(mx-mn)
                local fill=U.New("Frame",{Size=UDim2.new(pct,0,1,0),BackgroundColor3=T.Accent,ZIndex=6},tBg)
                U.Corner(4,fill)
                U.Gradient(fill,T.Accent,T.AccentB,0)
                TrackAccent(fill,"BackgroundColor3")

                local knob=U.New("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(pct,-9,.5,-9),BackgroundColor3=Color3.new(1,1,1),ZIndex=7},tBg)
                U.Corner(999,knob)
                U.Stroke(T.Accent,2,knob)
                TrackBorder(knob:FindFirstChildOfClass("UIStroke"))

                local hitBox=U.New("TextButton",{Size=UDim2.new(1,0,2,0),Position=UDim2.new(0,0,-.5,0),BackgroundTransparency=1,Text="",ZIndex=8},tBg)
                if tip~="" then U.Tooltip(c,tip) end

                local dragging=false
                local function UpdX(x)
                    local rel=math.clamp((x-tBg.AbsolutePosition.X)/tBg.AbsoluteSize.X,0,1)
                    value=math.floor((mn+(mx-mn)*rel)/step+.5)*step
                    value=math.clamp(value,mn,mx)
                    SunUI.Flags[fid]=value
                    vLbl.Text=value..suf
                    local r=(value-mn)/(mx-mn)
                    U.Tween(fill,{Size=UDim2.new(r,0,1,0)},.05)
                    U.Tween(knob,{Position=UDim2.new(r,-9,.5,-9)},.05)
                    task.spawn(cb,value)
                end
                hitBox.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true UpdX(UserInputService:GetMouseLocation().X) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and i.UserInputType==Enum.UserInputType.MouseMovement then UpdX(i.Position.X) end end)

                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},.15) end)
                Reg(lbl,c)

                local Obj={_element=c}
                function Obj:Set(v)
                    value=math.clamp(v,mn,mx); SunUI.Flags[fid]=value
                    local r=(value-mn)/(mx-mn)
                    vLbl.Text=value..suf
                    U.Tween(fill,{Size=UDim2.new(r,0,1,0)},.2)
                    U.Tween(knob,{Position=UDim2.new(r,-9,.5,-9)},.2)
                    task.spawn(cb,value)
                end
                function Obj:Get() return value end
                return Obj
            end

            -- ═══ BUTTON ═══════════════════
            function Sec:Button(opts)
                opts=opts or {}
                local lbl=opts.Name or "Botão"
                local desc=opts.Desc
                local icon=opts.Icon or "▶"
                local cb=opts.Callback or function() end
                local tip=opts.Tooltip or ""
                local H=desc and 54 or 44

                local c=U.New("TextButton",{Size=UDim2.new(1,0,0,H),BackgroundColor3=T.SurfaceHigh,Text="",ZIndex=4},SWrap)
                U.Corner(9,c)
                U.Ripple(c,T.Accent)

                local ibg=U.New("Frame",{Size=UDim2.new(0,30,0,30),Position=UDim2.new(0,10,.5,-15),BackgroundColor3=T.AccentDim,ZIndex=5},c)
                U.Corner(8,ibg)
                local iL=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=icon,TextColor3=T.TextAccent,Font=Enum.Font.GothamBold,TextSize=14,ZIndex=6},ibg)

                U.New("TextLabel",{Size=UDim2.new(1,-100,0,desc and 20 or 30),Position=UDim2.new(0,50,0,desc and 8 or 7),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                if desc then
                    U.New("TextLabel",{Size=UDim2.new(1,-100,0,16),Position=UDim2.new(0,50,0,28),BackgroundTransparency=1,Text=desc,TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                end
                U.New("TextLabel",{Size=UDim2.new(0,24,1,0),Position=UDim2.new(1,-28,0,0),BackgroundTransparency=1,Text="›",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=22,ZIndex=5},c)
                if tip~="" then U.Tooltip(c,tip) end

                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},.15) U.Tween(ibg,{BackgroundColor3=T.AccentDim},.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},.15) end)
                c.MouseButton1Down:Connect(function() U.Tween(c,{BackgroundColor3=T.AccentDim},.1) end)
                c.MouseButton1Up:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},.15) task.spawn(cb) end)
                Reg(lbl,c)
                return {_element=c}
            end

            -- ═══ DROPDOWN ═════════════════
            function Sec:Dropdown(opts)
                opts=opts or {}
                local lbl=opts.Name or "Dropdown"
                local options=opts.Options or {}
                local def=opts.Default or options[1]
                local cb=opts.Callback or function() end
                local fid=opts.Flag or U.ID()
                local multi=opts.Multi or false
                local tip=opts.Tooltip or ""

                local selected=def
                local multiSel=multi and (type(def)=="table" and def or {}) or {}
                SunUI.Flags[fid]=multi and multiSel or selected

                local isOpen=false
                local iH=32

                local Wrap=U.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundColor3=T.SurfaceHigh,ZIndex=10},SWrap)
                U.Corner(9,Wrap)

                U.New("TextLabel",{Size=UDim2.new(.52,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=11},Wrap)

                local selF=U.New("Frame",{Size=UDim2.new(0,132,0,30),Position=UDim2.new(1,-144,.5,-15),BackgroundColor3=T.Surface,ZIndex=11},Wrap)
                U.Corner(8,selF) U.Stroke(T.Border,1,selF)
                local selL=U.New("TextLabel",{Size=UDim2.new(1,-22,1,0),Position=UDim2.new(0,7,0,0),BackgroundTransparency=1,Text=multi and "0 selecionado(s)" or tostring(selected or "Selecionar"),TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=12},selF)
                local arrow=U.New("TextLabel",{Size=UDim2.new(0,18,1,0),Position=UDim2.new(1,-20,0,0),BackgroundTransparency=1,Text="▾",TextColor3=T.TextMuted,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=12},selF)

                -- Lista
                local totalH=#options*(iH+2)+44
                local ListF=U.New("Frame",{Size=UDim2.new(1,0,0,0),Position=UDim2.new(0,0,1,5),BackgroundColor3=T.Surface,ClipsDescendants=true,ZIndex=12},Wrap)
                U.Corner(9,ListF) U.Stroke(T.Border,1,ListF)
                local ll2=U.List(2,Enum.HorizontalAlignment.Center,ListF)
                U.Pad(4,4,6,6,ListF)

                -- Busca interna
                local dsBg=U.New("Frame",{Size=UDim2.new(1,-12,0,28),BackgroundColor3=T.InputBg,ZIndex=13},ListF)
                U.Corner(7,dsBg) U.Stroke(T.BorderBright,1,dsBg)
                local dsLbl=U.New("TextLabel",{Size=UDim2.new(0,20,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text="🔍",TextSize=11,ZIndex=14},dsBg)
                local dsTB=U.New("TextBox",{Size=UDim2.new(1,-26,1,0),Position=UDim2.new(0,22,0,0),BackgroundTransparency=1,Text="",PlaceholderText="Filtrar...",PlaceholderColor3=T.TextMuted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=11,ClearTextOnFocus=false,ZIndex=14},dsBg)

                local optBtns={}
                for _,opt in ipairs(options) do
                    local ob=U.New("TextButton",{Size=UDim2.new(1,0,0,iH),BackgroundColor3=T.Surface,Text="",ZIndex=13},ListF)
                    U.Corner(7,ob)
                    local otxt=U.New("TextLabel",{Size=UDim2.new(1,-38,1,0),Position=UDim2.new(0,8,0,0),BackgroundTransparency=1,Text=tostring(opt),TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=14},ob)
                    local chkF=U.New("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(1,-26,.5,-9),BackgroundColor3=T.SliderTrack,ZIndex=14},ob)
                    U.Corner(5,chkF)
                    local chkM=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="✓",TextColor3=Color3.new(1,1,1),Font=Enum.Font.GothamBold,TextSize=10,Visible=false,ZIndex=15},chkF)

                    local function RefChk()
                        local on=multi and table.find(multiSel,opt) or selected==opt
                        U.Tween(chkF,{BackgroundColor3=on and T.Accent or T.SliderTrack},.15)
                        chkM.Visible=on and true or false
                        U.Tween(otxt,{TextColor3=on and T.Text or T.TextSub},.15)
                    end
                    RefChk()
                    table.insert(optBtns,{btn=ob,lbl=opt,ref=RefChk})

                    ob.MouseEnter:Connect(function() U.Tween(ob,{BackgroundColor3=T.SurfaceHover},.1) end)
                    ob.MouseLeave:Connect(function() U.Tween(ob,{BackgroundColor3=T.Surface},.1) end)
                    ob.MouseButton1Click:Connect(function()
                        if multi then
                            local idx=table.find(multiSel,opt)
                            if idx then table.remove(multiSel,idx) else table.insert(multiSel,opt) end
                            SunUI.Flags[fid]=multiSel
                            selL.Text=#multiSel.." selecionado(s)"
                            task.spawn(cb,multiSel)
                        else
                            selected=opt; SunUI.Flags[fid]=opt; selL.Text=tostring(opt)
                            task.spawn(cb,opt)
                            isOpen=false
                            U.Tween(Wrap,{Size=UDim2.new(1,0,0,44)},.22)
                            U.Tween(ListF,{Size=UDim2.new(1,0,0,0)},.22)
                            U.Tween(arrow,{Rotation=0},.2)
                        end
                        RefChk()
                    end)
                end

                dsTB:GetPropertyChangedSignal("Text"):Connect(function()
                    local q=dsTB.Text:lower()
                    for _,o in pairs(optBtns) do
                        o.btn.Visible=(q=="" or tostring(o.lbl):lower():find(q,1,true)) and true or false
                    end
                end)

                local hitBtn=U.New("TextButton",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,Text="",ZIndex=13},Wrap)
                hitBtn.MouseButton1Click:Connect(function()
                    isOpen=not isOpen
                    U.Tween(Wrap,{Size=UDim2.new(1,0,0,isOpen and 44+5+totalH or 44)},.26,Enum.EasingStyle.Quart)
                    U.Tween(ListF,{Size=UDim2.new(1,0,0,isOpen and totalH or 0)},.26,Enum.EasingStyle.Quart)
                    U.Tween(arrow,{Rotation=isOpen and 180 or 0},.2)
                end)
                if tip~="" then U.Tooltip(Wrap,tip) end
                Wrap.MouseEnter:Connect(function() if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHover},.15) end end)
                Wrap.MouseLeave:Connect(function() if not isOpen then U.Tween(Wrap,{BackgroundColor3=T.SurfaceHigh},.15) end end)
                Reg(lbl,Wrap)

                local Obj={_element=Wrap}
                function Obj:Set(v)
                    if multi then multiSel=type(v)=="table" and v or {v}; SunUI.Flags[fid]=multiSel; selL.Text=#multiSel.." selecionado(s)"
                    else selected=v; SunUI.Flags[fid]=v; selL.Text=tostring(v) end
                    task.spawn(cb,SunUI.Flags[fid])
                    for _,o in pairs(optBtns) do o.ref() end
                end
                function Obj:Get() return SunUI.Flags[fid] end
                function Obj:Refresh(newList)
                    for _,o in pairs(optBtns) do o.btn:Destroy() end
                    optBtns={}
                    options=newList
                    for _,opt in ipairs(newList) do
                        local ob=U.New("TextButton",{Size=UDim2.new(1,0,0,iH),BackgroundColor3=T.Surface,Text=tostring(opt),TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,ZIndex=13},ListF)
                        U.Corner(7,ob)
                        ob.MouseButton1Click:Connect(function() selected=opt SunUI.Flags[fid]=opt selL.Text=tostring(opt) task.spawn(cb,opt) end)
                        table.insert(optBtns,{btn=ob,lbl=opt,ref=function()end})
                    end
                    totalH=#newList*(iH+2)+44
                end
                return Obj
            end

            -- ═══ KEYBIND ══════════════════
            function Sec:Keybind(opts)
                opts=opts or {}
                local lbl=opts.Name or "Keybind"
                local def=opts.Default or Enum.KeyCode.Unknown
                local onp=opts.OnPress or function() end
                local fid=opts.Flag or U.ID()
                local mode=opts.Mode or "Toggle"
                local tip=opts.Tooltip or ""

                local key=def; local listening=false
                SunUI.Flags[fid]=key

                local c=Card(44)
                c.Name="Kb_"..lbl

                U.New("TextLabel",{Size=UDim2.new(.55,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                U.New("TextLabel",{Size=UDim2.new(0,52,0,18),Position=UDim2.new(1,-148,.5,-9),BackgroundTransparency=1,Text="["..mode.."]",TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,ZIndex=5},c)

                local kF=U.New("Frame",{Size=UDim2.new(0,78,0,28),Position=UDim2.new(1,-90,.5,-14),BackgroundColor3=T.Surface,ZIndex=5},c)
                U.Corner(8,kF) U.Stroke(T.Border,1,kF)
                local kL=U.New("TextLabel",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text=key.Name,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=11,ZIndex=6},kF)

                local hit=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=7},c)
                hit.MouseButton1Click:Connect(function()
                    listening=true; kL.Text="..."
                    U.Tween(kF,{BackgroundColor3=T.AccentDim},.15)
                end)
                UserInputService.InputBegan:Connect(function(inp,gpe)
                    if listening and inp.UserInputType==Enum.UserInputType.Keyboard then
                        listening=false; key=inp.KeyCode; SunUI.Flags[fid]=key; kL.Text=key.Name
                        U.Tween(kF,{BackgroundColor3=T.Surface},.15); return
                    end
                    if not gpe and inp.KeyCode==key and not listening then
                        if mode=="Hold" then task.spawn(onp,true)
                        elseif mode=="Toggle" then task.spawn(onp) end
                    end
                end)
                UserInputService.InputEnded:Connect(function(inp)
                    if inp.KeyCode==key and mode=="Hold" then task.spawn(onp,false) end
                end)
                if tip~="" then U.Tooltip(c,tip) end
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},.15) end)
                Reg(lbl,c)

                local Obj={_element=c}
                function Obj:Get() return key end
                return Obj
            end

            -- ═══ TEXTBOX ══════════════════
            function Sec:TextBox(opts)
                opts=opts or {}
                local lbl=opts.Name or "Input"
                local ph=opts.Placeholder or "Digite aqui..."
                local def=opts.Default or ""
                local oc=opts.OnChanged
                local os2=opts.OnSubmit or function() end
                local fid=opts.Flag or U.ID()
                local tip=opts.Tooltip or ""
                local num=opts.Numeric or false

                SunUI.Flags[fid]=def

                local c=Card(54)
                c.Name="TB_"..lbl

                U.New("TextLabel",{Size=UDim2.new(1,-18,0,16),Position=UDim2.new(0,10,0,6),BackgroundTransparency=1,Text=lbl,TextColor3=T.TextSub,Font=Enum.Font.Gotham,TextSize=10,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                local ibg=U.New("Frame",{Size=UDim2.new(1,-20,0,28),Position=UDim2.new(0,10,0,23),BackgroundColor3=T.InputBg,ZIndex=5},c)
                U.Corner(8,ibg) U.Stroke(T.Border,1,ibg)
                local iStroke=ibg:FindFirstChildOfClass("UIStroke")
                local tb2=U.New("TextBox",{Size=UDim2.new(1,-20,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=def,PlaceholderText=ph,PlaceholderColor3=T.TextMuted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ClearTextOnFocus=false,ZIndex=6},ibg)
                if tip~="" then U.Tooltip(c,tip) end

                tb2.Focused:Connect(function()
                    U.Tween(iStroke,{Color=T.Accent},.15)
                    U.Tween(ibg,{BackgroundColor3=T.SurfaceHover},.15)
                end)
                tb2.FocusLost:Connect(function(e)
                    U.Tween(iStroke,{Color=T.Border},.15)
                    U.Tween(ibg,{BackgroundColor3=T.InputBg},.15)
                    if num then tb2.Text=tostring(tonumber(tb2.Text) or def) end
                    SunUI.Flags[fid]=num and (tonumber(tb2.Text) or def) or tb2.Text
                    if e then task.spawn(os2,tb2.Text) end
                end)
                if oc then tb2:GetPropertyChangedSignal("Text"):Connect(function() SunUI.Flags[fid]=tb2.Text task.spawn(oc,tb2.Text) end) end
                c.MouseEnter:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHover},.15) end)
                c.MouseLeave:Connect(function() U.Tween(c,{BackgroundColor3=T.SurfaceHigh},.15) end)
                Reg(lbl,c)

                local Obj={_element=c}
                function Obj:Set(v) tb2.Text=tostring(v) SunUI.Flags[fid]=v end
                function Obj:Get() return tb2.Text end
                return Obj
            end

            -- ═══ COLOR PICKER ═════════════
            function Sec:ColorPicker(opts)
                opts=opts or {}
                local lbl=opts.Name or "Cor"
                local def=opts.Default or Color3.fromRGB(255,80,80)
                local cb=opts.Callback or function() end
                local fid=opts.Flag or U.ID()
                local tip=opts.Tooltip or ""

                SunUI.Flags[fid]=def

                local hdr=U.New("Frame",{Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,ZIndex=4},SWrap)
                U.New("TextLabel",{Size=UDim2.new(.6,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},hdr)
                if tip~="" then U.Tooltip(hdr,tip) end

                local pickerWrap=U.New("Frame",{Size=UDim2.new(1,0,0,44),BackgroundTransparency=1,ZIndex=4},SWrap)

                local Obj=MakeColorPicker(pickerWrap,def,T,function(c3)
                    SunUI.Flags[fid]=c3; task.spawn(cb,c3)
                end)
                Reg(lbl,pickerWrap)
                return Obj
            end

            -- ═══ LABEL ════════════════════
            function Sec:Label(opts)
                opts=opts or {}
                local text=opts.Text or ""
                local color=opts.Color or T.TextSub
                local bold=opts.Bold or false
                local icon=opts.Icon

                local c=Card(36)
                if icon then
                    U.New("TextLabel",{Size=UDim2.new(0,24,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=icon,TextSize=14,ZIndex=5},c)
                end
                local lbl=U.New("TextLabel",{Size=UDim2.new(1,(icon and -40 or -20),1,0),Position=UDim2.new(0,icon and 34 or 10,0,0),BackgroundTransparency=1,Text=text,TextColor3=color,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,ZIndex=5},c)

                local Obj={_element=c}
                function Obj:Set(v) lbl.Text=v end
                function Obj:SetColor(v) lbl.TextColor3=v end
                return Obj
            end

            -- ═══ SEPARATOR ════════════════
            function Sec:Separator(text)
                local f=U.New("Frame",{Size=UDim2.new(1,0,0,20),BackgroundTransparency=1,ZIndex=4},SWrap)
                local line=U.New("Frame",{Size=UDim2.new(1,0,0,1),Position=UDim2.new(0,0,.5,0),BackgroundColor3=T.Border,ZIndex=4},f)
                if text then
                    local bg=U.New("Frame",{Size=UDim2.new(0,120,0,18),Position=UDim2.new(.5,-60,.5,-9),BackgroundColor3=T.Surface,ZIndex=5},f)
                    U.New("TextLabel",{Size=UDim2.new(1,-8,1,0),Position=UDim2.new(0,4,0,0),BackgroundTransparency=1,Text=text,TextColor3=T.TextMuted,Font=Enum.Font.Gotham,TextSize=10,ZIndex=6},bg)
                end
                return {_element=f}
            end

            -- ═══ PROGRESS BAR ═════════════
            function Sec:ProgressBar(opts)
                opts=opts or {}
                local lbl=opts.Name or "Progresso"
                local mn=opts.Min or 0
                local mx=opts.Max or 100
                local def=math.clamp(opts.Default or 0,mn,mx)
                local suf=opts.Suffix or "%"

                local value=def
                local c=Card(44)

                U.New("TextLabel",{Size=UDim2.new(.6,0,0,18),Position=UDim2.new(0,10,0,5),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)
                local pL=U.New("TextLabel",{Size=UDim2.new(.4,0,0,18),Position=UDim2.new(.6,0,0,5),BackgroundTransparency=1,Text=value..suf,TextColor3=T.TextAccent,Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Right,ZIndex=5},c)
                local tr=U.New("Frame",{Size=UDim2.new(1,-20,0,8),Position=UDim2.new(0,10,0,28),BackgroundColor3=T.SliderTrack,ZIndex=5},c)
                U.Corner(5,tr)
                local rel=(value-mn)/(mx-mn)
                local fi=U.New("Frame",{Size=UDim2.new(rel,0,1,0),BackgroundColor3=T.Accent,ZIndex=6},tr)
                U.Corner(5,fi) U.Gradient(fi,T.Accent,T.AccentB,0)
                TrackAccent(fi,"BackgroundColor3")

                local Obj={_element=c}
                function Obj:Set(v)
                    value=math.clamp(v,mn,mx); pL.Text=value..suf
                    U.Tween(fi,{Size=UDim2.new((value-mn)/(mx-mn),0,1,0)},.3)
                end
                function Obj:Get() return value end
                return Obj
            end

            -- ═══ TOGGLE+SLIDER ════════════
            function Sec:ToggleSlider(opts)
                local t=self:Toggle({Name=opts.Name,Desc=opts.Desc,Default=opts.TDefault,Flag=opts.TFlag,Callback=opts.TCallback,Tooltip=opts.Tooltip})
                local s=self:Slider({Name=opts.SName or opts.Name.." Amount",Min=opts.Min,Max=opts.Max,Default=opts.SDefault,Suffix=opts.Suffix,Step=opts.Step,Flag=opts.SFlag,Callback=opts.SCallback})
                return t,s
            end

            -- ═══ ACCENT PICKER (NOVO!) ════
            function Sec:AccentPicker(opts)
                opts=opts or {}
                local lbl=opts.Name or "Accent Color"
                local def=opts.Default or T.Accent
                local tip=opts.Tooltip or ""

                local c=Card(44)
                U.New("TextLabel",{Size=UDim2.new(.55,0,1,0),Position=UDim2.new(0,10,0,0),BackgroundTransparency=1,Text=lbl,TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,ZIndex=5},c)

                -- Preset colors
                local presets={
                    Color3.fromRGB(99,102,241), Color3.fromRGB(168,85,247),
                    Color3.fromRGB(239,68,68),  Color3.fromRGB(6,182,212),
                    Color3.fromRGB(16,185,129),  Color3.fromRGB(251,191,36),
                    Color3.fromRGB(249,115,22),  Color3.fromRGB(236,72,153),
                }
                local x=220
                for i,pc in ipairs(presets) do
                    local pb=U.New("Frame",{Size=UDim2.new(0,18,0,18),Position=UDim2.new(0,x,.5,-9),BackgroundColor3=pc,ZIndex=5},c)
                    U.Corner(999,pb)
                    local pHit=U.New("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundTransparency=1,Text="",ZIndex=6},pb)
                    pHit.MouseButton1Click:Connect(function()
                        SunUI:SetAccentColor(pc)
                    end)
                    pb.MouseEnter:Connect(function() U.Tween(pb,{Size=UDim2.new(0,22,0,22)},.12) end)
                    pb.MouseLeave:Connect(function() U.Tween(pb,{Size=UDim2.new(0,18,0,18)},.12) end)
                    x=x+22
                end

                -- Botão rainbow
                local rbBtn=U.New("TextButton",{Size=UDim2.new(0,58,0,26),Position=UDim2.new(1,-66,.5,-13),BackgroundColor3=T.Surface,Text="🌈 RGB",TextColor3=T.Text,Font=Enum.Font.GothamBold,TextSize=9,ZIndex=6},c)
                U.Corner(8,rbBtn) U.Stroke(T.Border,1,rbBtn)
                rbBtn.MouseButton1Click:Connect(function()
                    SunUI._rbRunning=false; task.wait(.05)
                    SunUI._rbTick=0; StartRainbow()
                end)

                if tip~="" then U.Tooltip(c,tip) end
                return {_element=c}
            end

            return Sec
        end -- Tab:Section

        return Tab
    end -- Win:Tab

    -- Animação de entrada da janela e intro
    local function OpenWindow()
        U.Spring(Main,{Size=UDim2.new(0,W,0,H),BackgroundTransparency=0},.45)
        -- Typewriter no título
        titleLbl.Text=""
        task.delay(.2,function()
            U.Typewriter(titleLbl,title,.05)
        end)
    end

    if showIntro then
        Main.Visible=false
        PlayIntro(Screen, T, title, function()
            if keyOpts then
                ShowKey(keyOpts, Screen, T, function()
                    Main.Visible=true
                    OpenWindow()
                end)
            else
                Main.Visible=true
                OpenWindow()
            end
        end)
    elseif keyOpts then
        Main.Visible=false
        ShowKey(keyOpts, Screen, T, function()
            Main.Visible=true
            OpenWindow()
        end)
    else
        OpenWindow()
    end

    return Win
end

-- ══════════════════════════════════════════
-- API EXTERNA
-- ══════════════════════════════════════════
function SunUI:SetFlag(k,v) self.Flags[k]=v end
function SunUI:GetFlag(k) return self.Flags[k] end
function SunUI:SaveConfig() SaveMgr:Save(self.Flags) end
function SunUI:LoadConfig() return SaveMgr:Load() end

return SunUI
