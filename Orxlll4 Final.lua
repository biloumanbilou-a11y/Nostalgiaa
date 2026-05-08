local Players = game:GetService("Players")
local HttpService=game:GetService("HttpService")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local TeleportService=game:GetService("TeleportService")
local plr=Players.LocalPlayer
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local UIS=game:GetService("UserInputService")
local PPS=game:GetService("ProximityPromptService")
local CoreGui=game:GetService("CoreGui")
local TCS=game:GetService("TextChatService")
local Lighting=game:GetService("Lighting")

-- WHITELIST
local WHITELIST = {
    "bilelbjr",
    "A4nsmkk",
    "eyup_1303",
    "Deniz_lebon",
}
local function isWhitelisted()
    local name = plr.Name:lower()
    for _, u in ipairs(WHITELIST) do
        if u:lower() == name then return true end
    end
    return false
end
if not isWhitelisted() then
    error("❌ Accès refusé : " .. plr.Name .. " n'est pas dans la whitelist.")
end
if typeof(gethui)=="function" then
    local ok, result = pcall(gethui)
    if ok then
        GuiParent = result
    else
        GuiParent = CoreGui
    end
else
    GuiParent = CoreGui
end

local pos1=Vector3.new(-352.98,-7,74.30)
local pos2=Vector3.new(-352.98,-6.49,45.76)
local s1={CFrame.new(-370.810913,-7.00000334,41.2687263,0.99984771,1.22364419e-09,0.0174523517,-6.54859778e-10,1,-3.2596418e-08,-0.0174523517,3.25800258e-08,0.99984771),CFrame.new(-336.355286,-5.10107088,17.2327671,-0.999883354,-2.76150569e-08,0.0152716246,-2.88224964e-08,1,-7.88441525e-08,-0.0152716246,-7.9275118e-08,-0.999883354)}
local s2={CFrame.new(-354.782867,-7.00000334,92.8209305,-0.999997616,-1.11891862e-09,-0.00218066527,-1.11958298e-09,1,3.03415071e-10,0.00218066527,3.05855785e-10,-0.999997616),CFrame.new(-336.942902,-5.10106993,99.3276443,0.999914348,-3.63984611e-08,0.0130875716,3.67094941e-08,1,-2.35254749e-08,-0.0130875716,2.40038975e-08,0.999914348)}
local CONFIG_FILE = "antiscam_config.json"
local function loadConfig()
	pcall(function()
		if readfile then
			local ok, data = pcall(function() return readfile(CONFIG_FILE) end)
			if ok and data and data ~= "" then
				local ok2, parsed = pcall(function() return HttpService:JSONDecode(data) end)
				if ok2 and type(parsed) == "table" then
					for k, v in pairs(parsed) do
						_G.AntiScamSave[k] = v
					end
				end
			end
		end
	end)
end
local function saveConfig()
	pcall(function()
		if writefile then
			local ok, data = pcall(function() return HttpService:JSONEncode(_G.AntiScamSave) end)
			if ok then writefile(CONFIG_FILE, data) end
		end
	end)
end
_G.AntiScamSave=_G.AntiScamSave or {
	autoPotion=false,autoSpam=false,autoPush=false,halfTP=false,speedBoost=false,
	autoTPOpen=false,autoKick=false,
	speedAnti=false,esp=false,spam=false,server=false,
	walkSpeedOn=false,autoSpamOn=false,
	protectorOn=false,protAutoKick=false,
	espPlayer=false,espBrainrot=false,espBase=false,espAllow=false,
}
loadConfig()
local Save=_G.AntiScamSave
_G._tpDoneEvent = _G._tpDoneEvent or Instance.new("BindableEvent")
_G._spamEvent = _G._spamEvent or Instance.new("BindableEvent")
if GuiParent:FindFirstChild("NostalgiaaGui") then GuiParent:FindFirstChild("NostalgiaaGui"):Destroy() end
local sg=Instance.new("ScreenGui")
sg.Name="NostalgiaaGui"
sg.ResetOnSpawn=false
sg.Parent=GuiParent
local UIState = {
    moreOptions=false,
    esp=false,
    speed=false,
    spam=false
}
local SavedPositions = {
    speedFrame = UDim2.new(0,10,0.45,0),
    espFrame   = UDim2.new(1,-160,0.12,0),
    spamFrame  = UDim2.new(0,10,0.6,0),
    pvpFrame   = UDim2.new(0.5,-93,0.12,0),
}
local boostCC=nil
local origLighting={
	GlobalShadows=Lighting.GlobalShadows,
	FogEnd=Lighting.FogEnd,FogStart=Lighting.FogStart,
	Brightness=Lighting.Brightness,ClockTime=Lighting.ClockTime,
	Ambient=Lighting.Ambient,OutdoorAmbient=Lighting.OutdoorAmbient,
}
local function ativarBoost()
	settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
	local terrain=workspace:FindFirstChildOfClass("Terrain")
	if terrain then terrain.WaterWaveSize=0 terrain.WaterWaveSpeed=0 terrain.WaterReflectance=0 pcall(function() terrain.Decoration=false end) end
	local function limparObj(obj)
		if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then obj.Enabled=false
		elseif obj:IsA("BasePart") then obj.CastShadow=false end
	end
	task.spawn(function()
		local desc=workspace:GetDescendants()
		for i=1,#desc do
			limparObj(desc[i])
			if i%200==0 then task.wait() end
		end
	end)
	boosterConn=workspace.DescendantAdded:Connect(function(obj) task.defer(limparObj,obj) end)
end
task.spawn(function() task.wait(1) ativarBoost() end)
local function getChar()
	return plr.Character and plr.Character.Parent and plr.Character
end
local function getRoot()
	local c=getChar()
	return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
	local c=getChar()
	return c and c:FindFirstChildOfClass("Humanoid")
end
local function getCarpet() local bp=plr:FindFirstChild("Backpack") return bp and bp:FindFirstChild("Flying Carpet") end
local function equipCarpet() local c=getCarpet() local h=getHum() if c and h then h:EquipTool(c) task.wait(0.15) end end
local speedConn = nil
local IsStealing = false
local _stealingCFrame = false  
local speedAntiConn = nil
local speedAntiValue = 28
local speedAntiOn = false
local function applySpeedAnti()
	if speedAntiConn then speedAntiConn:Disconnect() speedAntiConn=nil end
	local _saDt=0
	speedAntiConn=RunService.RenderStepped:Connect(function(dt)
		_saDt+=dt
		if _saDt<0.016 then return end
		_saDt=0
		if _stealingCFrame then return end
		local c=plr.Character if not c then return end
		local hrp=c:FindFirstChild("HumanoidRootPart")
		local h=c:FindFirstChildOfClass("Humanoid")
		if not hrp or not h then return end
		if h.MoveDirection.Magnitude>0 then
			hrp.AssemblyLinearVelocity=Vector3.new(h.MoveDirection.X*speedAntiValue,hrp.AssemblyLinearVelocity.Y,h.MoveDirection.Z*speedAntiValue)
		end
	end)
end
local function removeSpeedAnti()
	if speedAntiConn then speedAntiConn:Disconnect() speedAntiConn=nil end
end
local function ResetToWork()
	local flags={{"GameNetPVHeaderRotationalVelocityZeroCutoffExponent","-5000"},{"LargeReplicatorWrite5","true"},{"LargeReplicatorEnabled9","true"},{"S2PhysicsSenderRate","15000"},{"MaxDataPacketPerSend","2147483647"},{"PhysicsSenderMaxBandwidthBps","20000"},{"WorldStepMax","30"},{"MaxAcceptableUpdateDelay","1"},{"LargeReplicatorSerializeWrite4","true"}}
	for _,d in ipairs(flags) do pcall(function() if setfflag then setfflag(d[1],d[2]) end end) end
	local char=getChar()
	if not char then
		return
	end
	local h=char:FindFirstChildOfClass("Humanoid")
	if h then
		pcall(function() h:ChangeState(Enum.HumanoidStateType.Dead) end)
	end
	pcall(function()
		char:ClearAllChildren()
		local f=Instance.new("Model",workspace)
		plr.Character=f
		task.wait(0.15)
		plr.Character=char
		f:Destroy()
	end)
end
-- Reset au demarrage
task.spawn(function()
    task.wait(1)
    ResetToWork()
end)
local boosterConn=nil

local function makeDraggableWithChild(parentFrame, childFrame, handle)
	local drag=false local dx=0 local dy=0
	local lastParentPos = parentFrame.Position
	local lastChildPos = childFrame.Position
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			drag=true dx=i.Position.X-parentFrame.AbsolutePosition.X dy=i.Position.Y-parentFrame.AbsolutePosition.Y
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local vp=workspace.CurrentCamera.ViewportSize
			local newParentPos = UDim2.new(0,math.clamp(i.Position.X-dx,0,vp.X-parentFrame.AbsoluteSize.X),0,math.clamp(i.Position.Y-dy,0,vp.Y-parentFrame.AbsoluteSize.Y))
			local offset = newParentPos - lastParentPos
			parentFrame.Position = newParentPos
			childFrame.Position = childFrame.Position + offset
			lastParentPos = newParentPos
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
	end)
end
local function makeDraggable(frame,handle)
	local drag=false local dx=0 local dy=0
	handle.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			drag=true dx=i.Position.X-frame.AbsolutePosition.X dy=i.Position.Y-frame.AbsolutePosition.Y
		end
	end)
	UIS.InputChanged:Connect(function(i)
		if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local vp=workspace.CurrentCamera.ViewportSize
			frame.Position=UDim2.new(0,math.clamp(i.Position.X-dx,0,vp.X-frame.AbsoluteSize.X),0,math.clamp(i.Position.Y-dy,0,vp.Y-frame.AbsoluteSize.Y))
		end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
	end)
end
local C_BG      = Color3.fromRGB(20, 14, 18)
local C_ROW     = Color3.fromRGB(30, 22, 28)
local C_STROKE  = Color3.fromRGB(251, 207, 232)
local C_PURPLE  = Color3.fromRGB(251, 207, 232)
local C_WHITE   = Color3.fromRGB(250, 245, 248)
local C_GREY    = Color3.fromRGB(140, 120, 130)
local C_PILLOFF = Color3.fromRGB(45, 32, 40)
local FULL_H=240
local MINI_H=34
local minimized=false
local mf=Instance.new("Frame")
mf.Name="MainFrame"
mf.Size=UDim2.new(0,200,0,FULL_H)
mf.Position=UDim2.new(0,10,0.12,0)
mf.BackgroundColor3=C_BG
mf.BackgroundTransparency=0.67
mf.BorderSizePixel=0
mf.Active=true
mf.ClipsDescendants=true
mf.Parent=sg
Instance.new("UICorner",mf).CornerRadius=UDim.new(0,16)
local bs=Instance.new("UIStroke",mf)
bs.Thickness=2 bs.Color=C_STROKE bs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local topbar=Instance.new("Frame")
topbar.Size=UDim2.new(1,0,0,MINI_H)
topbar.BackgroundTransparency=1
topbar.BorderSizePixel=0
topbar.Parent=mf
local titleLbl=Instance.new("TextLabel")
titleLbl.Size=UDim2.new(1,-44,1,0)
titleLbl.Position=UDim2.new(0,14,0,0)
titleLbl.BackgroundTransparency=1
titleLbl.Text="Nostalgiaa"
titleLbl.TextColor3=C_WHITE
titleLbl.TextSize=15
titleLbl.Font=Enum.Font.GothamBlack
titleLbl.TextXAlignment=Enum.TextXAlignment.Left
titleLbl.Parent=topbar
-- Shimmer rose sur le titre
local _tsP=Instance.new("UIGradient",titleLbl)
_tsP.Color=ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(200,150,170)),ColorSequenceKeypoint.new(0.4,Color3.fromRGB(255,220,235)),ColorSequenceKeypoint.new(0.6,Color3.fromRGB(255,220,235)),ColorSequenceKeypoint.new(1,Color3.fromRGB(200,150,170))})
task.spawn(function() local t=0 while titleLbl.Parent do task.wait(0.04) t=(t+2)%360 _tsP.Rotation=t end end)
local topDivider=Instance.new("Frame")
topDivider.Size=UDim2.new(1,-20,0,1)
topDivider.Position=UDim2.new(0,10,1,-1)
topDivider.BackgroundColor3=C_STROKE
topDivider.BackgroundTransparency=0.4
topDivider.BorderSizePixel=0
topDivider.Parent=topbar
local topLogo=Instance.new("ImageLabel")
topLogo.Size=UDim2.new(0,0,0,0)
topLogo.BackgroundTransparency=1
topLogo.Image="rbxassetid://89639741577878"
topLogo.Parent=topbar
local minBtn=Instance.new("TextButton")
minBtn.Size=UDim2.new(0,28,0,28)
minBtn.Position=UDim2.new(1,-36,0.5,-14)
minBtn.BackgroundColor3=C_ROW
minBtn.Text="-"
minBtn.TextColor3=C_WHITE
minBtn.TextSize=16
minBtn.Font=Enum.Font.GothamBold
minBtn.BorderSizePixel=0
minBtn.Parent=topbar
Instance.new("UICorner",minBtn).CornerRadius=UDim.new(0,8)
local content=Instance.new("Frame")
content.Size=UDim2.new(1,0,1,-MINI_H)
content.Position=UDim2.new(0,0,0,MINI_H)
content.BackgroundTransparency=1
content.ClipsDescendants=true
content.Parent=mf
local contentLayout=Instance.new("UIListLayout")
contentLayout.Padding=UDim.new(0,5)
contentLayout.SortOrder=Enum.SortOrder.LayoutOrder
contentLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
contentLayout.Parent=content
local contentPad=Instance.new("UIPadding")
contentPad.PaddingTop=UDim.new(0,8) contentPad.PaddingLeft=UDim.new(0,8)
contentPad.PaddingRight=UDim.new(0,8) contentPad.PaddingBottom=UDim.new(0,8)
contentPad.Parent=content
local function lbl(parent,txt,size,pos,col,fs,font,xa)
	local l=Instance.new("TextLabel") l.Size=size l.Position=pos l.BackgroundTransparency=1 l.Text=txt l.TextColor3=col or C_WHITE l.TextSize=fs or 12 l.Font=font or Enum.Font.GothamBold if xa then l.TextXAlignment=xa end l.Parent=parent return l
end
local _mkToggleOrder=0
local function mkToggle(txt,pos,saveKey,cb)
	_mkToggleOrder=_mkToggleOrder+1
	local cont=Instance.new("Frame")
	cont.Size=UDim2.new(1,0,0,36)
	cont.BackgroundColor3=C_ROW
	cont.BackgroundTransparency=0.25
	cont.BorderSizePixel=0
	cont.LayoutOrder=_mkToggleOrder
	cont.Parent=content
	Instance.new("UICorner",cont).CornerRadius=UDim.new(0,10)
	local tlbl=Instance.new("TextLabel")
	tlbl.Size=UDim2.new(1,-60,1,0) tlbl.Position=UDim2.new(0,12,0,0)
	tlbl.BackgroundTransparency=1 tlbl.Text=txt
	tlbl.TextColor3=C_WHITE tlbl.TextSize=12
	tlbl.Font=Enum.Font.GothamBold tlbl.TextXAlignment=Enum.TextXAlignment.Left
	tlbl.ZIndex=2 tlbl.Parent=cont
	local pill=Instance.new("Frame")
	pill.Size=UDim2.new(0,40,0,22) pill.Position=UDim2.new(1,-48,0.5,-11)
	pill.BackgroundColor3=C_PILLOFF pill.BorderSizePixel=0 pill.ZIndex=2 pill.Parent=cont
	Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
	local dot=Instance.new("Frame")
	dot.Size=UDim2.new(0,16,0,16) dot.Position=UDim2.new(0,3,0.5,-8)
	dot.BackgroundColor3=C_GREY dot.BorderSizePixel=0 dot.ZIndex=3 dot.Parent=pill
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	local on=Save[saveKey] or false
	if on then
		dot.Position=UDim2.new(1,-19,0.5,-8)
		pill.BackgroundColor3=C_PURPLE
		dot.BackgroundColor3=C_WHITE
	end
	local ca=Instance.new("TextButton")
	ca.Size=UDim2.new(1,0,1,0) ca.BackgroundTransparency=1 ca.Text="" ca.ZIndex=10 ca.Parent=cont
	ca.MouseButton1Click:Connect(function()
		on=not on Save[saveKey]=on
		TweenService:Create(dot,TweenInfo.new(0.12),{Position=on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
		TweenService:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=on and C_PURPLE or C_PILLOFF}):Play()
		TweenService:Create(dot,TweenInfo.new(0.12),{BackgroundColor3=on and C_WHITE or C_GREY}):Play()
		cb(on)
		saveConfig()
	end)
	task.spawn(function() cb(on) end)
end
local function mkBtn(txt,pos,col)
	_mkToggleOrder=_mkToggleOrder+1
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,0,0,38) b.LayoutOrder=_mkToggleOrder
	b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=13
	b.TextColor3=C_WHITE
	b.BackgroundColor3=col or C_ROW
	b.BackgroundTransparency=0.25
	b.BorderSizePixel=0 b.Parent=content
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,12)
	return b
end
makeDraggable(mf,topbar)
mkToggle("Giant Potion",UDim2.new(0,8,0,40),"autoPotion",function(s) _G.AutoPotion=s end)
-- Auto TP on Open supprimé sur demande utilisateur

local sideMenu=Instance.new("Frame")
sideMenu.Name="SideMenu"
sideMenu.Size=UDim2.new(0,185,0,280)
sideMenu.Position=UDim2.new(0,220,0,80)
sideMenu.BackgroundColor3=C_BG
sideMenu.BackgroundTransparency=0.67
sideMenu.BorderSizePixel=0
sideMenu.Visible=false
sideMenu.Active=true
sideMenu.ClipsDescendants=true
sideMenu.Parent=sg
Instance.new("UICorner",sideMenu).CornerRadius=UDim.new(0,16)
local sideStroke=Instance.new("UIStroke",sideMenu)
sideStroke.Thickness=2 sideStroke.Color=C_STROKE sideStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local function repositionSideMenu()
	local vp=workspace.CurrentCamera.ViewportSize
	local mfPos=mf.AbsolutePosition
	local mfSize=mf.AbsoluteSize
	local smW=185
	local smH=280
	local xRight=mfPos.X+mfSize.X+6
	local xLeft=mfPos.X-smW-6
	local x = xRight+smW<=vp.X and xRight or (xLeft>=0 and xLeft or mfPos.X)
	local y = math.clamp(mfPos.Y, 0, vp.Y-smH)
	sideMenu.Position=UDim2.new(0,x,0,y)
end
local sideTop=Instance.new("Frame")
sideTop.Size=UDim2.new(1,0,0,38)
sideTop.BackgroundTransparency=1
sideTop.BorderSizePixel=0
sideTop.Parent=sideMenu
local sideTitle=Instance.new("TextLabel")
sideTitle.Size=UDim2.new(1,-20,1,0)
sideTitle.Position=UDim2.new(0,14,0,0)
sideTitle.BackgroundTransparency=1
sideTitle.Text="Menu"
sideTitle.TextColor3=C_WHITE
sideTitle.TextSize=15
sideTitle.Font=Enum.Font.GothamBlack
sideTitle.TextXAlignment=Enum.TextXAlignment.Left
sideTitle.Parent=sideTop
local sDivD=Instance.new("Frame")
sDivD.Size=UDim2.new(1,-20,0,1) sDivD.Position=UDim2.new(0,10,1,-1)
sDivD.BackgroundColor3=C_STROKE sDivD.BackgroundTransparency=0.4 sDivD.BorderSizePixel=0 sDivD.Parent=sideTop
local sideContent=Instance.new("Frame")
sideContent.Size=UDim2.new(1,0,1,-38)
sideContent.Position=UDim2.new(0,0,0,38)
sideContent.BackgroundTransparency=1
sideContent.Parent=sideMenu
local sideLayout=Instance.new("UIListLayout")
sideLayout.Padding=UDim.new(0,7) sideLayout.SortOrder=Enum.SortOrder.LayoutOrder
sideLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center sideLayout.Parent=sideContent
local sidePad=Instance.new("UIPadding")
sidePad.PaddingTop=UDim.new(0,8) sidePad.PaddingLeft=UDim.new(0,10)
sidePad.PaddingRight=UDim.new(0,10) sidePad.PaddingBottom=UDim.new(0,10) sidePad.Parent=sideContent
local function mkSideToggle(txt,saveKey,cb)
	local cont=Instance.new("Frame")
	cont.Size=UDim2.new(1,0,0,42)
	cont.BackgroundColor3=C_ROW
	cont.BackgroundTransparency=0.25
	cont.BorderSizePixel=0 cont.Parent=sideContent
	Instance.new("UICorner",cont).CornerRadius=UDim.new(0,12)
	local tlbl2=Instance.new("TextLabel")
	tlbl2.Size=UDim2.new(1,-64,1,0) tlbl2.Position=UDim2.new(0,14,0,0)
	tlbl2.BackgroundTransparency=1 tlbl2.Text=txt
	tlbl2.TextColor3=C_WHITE tlbl2.TextSize=13
	tlbl2.Font=Enum.Font.GothamBold tlbl2.TextXAlignment=Enum.TextXAlignment.Left
	tlbl2.ZIndex=2 tlbl2.Parent=cont
	local pill2=Instance.new("Frame")
	pill2.Size=UDim2.new(0,46,0,26) pill2.Position=UDim2.new(1,-54,0.5,-13)
	pill2.BackgroundColor3=C_PILLOFF pill2.BorderSizePixel=0 pill2.ZIndex=2 pill2.Parent=cont
	Instance.new("UICorner",pill2).CornerRadius=UDim.new(1,0)
	local dot2=Instance.new("Frame")
	dot2.Size=UDim2.new(0,20,0,20) dot2.Position=UDim2.new(0,3,0.5,-10)
	dot2.BackgroundColor3=C_GREY dot2.BorderSizePixel=0 dot2.ZIndex=3 dot2.Parent=pill2
	Instance.new("UICorner",dot2).CornerRadius=UDim.new(1,0)
	local on=Save[saveKey] or false
	if on then
		dot2.Position=UDim2.new(1,-23,0.5,-10)
		pill2.BackgroundColor3=C_PURPLE
		dot2.BackgroundColor3=C_WHITE
	end
	local ca2=Instance.new("TextButton")
	ca2.Size=UDim2.new(1,0,1,0) ca2.BackgroundTransparency=1 ca2.Text="" ca2.ZIndex=10 ca2.Parent=cont
	ca2.MouseButton1Click:Connect(function()
		on=not on Save[saveKey]=on
		TweenService:Create(dot2,TweenInfo.new(0.12),{Position=on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}):Play()
		TweenService:Create(pill2,TweenInfo.new(0.12),{BackgroundColor3=on and C_PURPLE or C_PILLOFF}):Play()
		TweenService:Create(dot2,TweenInfo.new(0.12),{BackgroundColor3=on and C_WHITE or C_GREY}):Play()
		cb(on)
		saveConfig()
	end)
	task.spawn(function() cb(on) end)
end
local BOOSTER_FULL_H = 115
local BOOSTER_MINI_H = 34
local speedMinimized = false
local speedFrame=Instance.new("Frame")
speedFrame.Name="Booster"
speedFrame.Size=UDim2.new(0,185,0,BOOSTER_FULL_H)
speedFrame.Position=SavedPositions.speedFrame
speedFrame.BackgroundColor3=C_BG
speedFrame.BackgroundTransparency=0.67
speedFrame.BorderSizePixel=0
speedFrame.Visible=false
speedFrame.Active=true
speedFrame.ClipsDescendants=true
speedFrame.Parent=sg
Instance.new("UICorner",speedFrame).CornerRadius=UDim.new(0,16)
local speedStroke=Instance.new("UIStroke",speedFrame)
speedStroke.Thickness=2 speedStroke.Color=C_STROKE speedStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local speedTop=Instance.new("Frame")
speedTop.Size=UDim2.new(1,0,0,BOOSTER_MINI_H)
speedTop.BackgroundTransparency=1
speedTop.BorderSizePixel=0
speedTop.Parent=speedFrame
local speedTitle=Instance.new("TextLabel")
speedTitle.Size=UDim2.new(1,-44,1,0)
speedTitle.Position=UDim2.new(0,14,0,0)
speedTitle.BackgroundTransparency=1
speedTitle.Text="Booster"
speedTitle.TextColor3=C_WHITE
speedTitle.TextSize=15
speedTitle.Font=Enum.Font.GothamBlack
speedTitle.TextXAlignment=Enum.TextXAlignment.Left
speedTitle.Parent=speedTop
local sDivA=Instance.new("Frame")
sDivA.Size=UDim2.new(1,-20,0,1) sDivA.Position=UDim2.new(0,10,1,-1)
sDivA.BackgroundColor3=C_STROKE sDivA.BackgroundTransparency=0.4 sDivA.BorderSizePixel=0 sDivA.Parent=speedTop
local speedMinBtn=Instance.new("TextButton")
speedMinBtn.Size=UDim2.new(0,28,0,28)
speedMinBtn.Position=UDim2.new(1,-36,0.5,-14)
speedMinBtn.BackgroundColor3=C_ROW
speedMinBtn.Text="-" speedMinBtn.TextColor3=C_WHITE
speedMinBtn.TextSize=16 speedMinBtn.Font=Enum.Font.GothamBold
speedMinBtn.BorderSizePixel=0 speedMinBtn.Parent=speedTop
Instance.new("UICorner",speedMinBtn).CornerRadius=UDim.new(0,8)
speedMinBtn.MouseButton1Click:Connect(function()
	speedMinimized=not speedMinimized
	speedFrame.Size=UDim2.new(0,185,0,speedMinimized and BOOSTER_MINI_H or BOOSTER_FULL_H)
	speedMinBtn.Text=speedMinimized and "+" or "-"
end)
local speedScroll=Instance.new("ScrollingFrame")
speedScroll.Size=UDim2.new(1,0,1,-BOOSTER_MINI_H)
speedScroll.Position=UDim2.new(0,0,0,BOOSTER_MINI_H)
speedScroll.BackgroundTransparency=1
speedScroll.BorderSizePixel=0
speedScroll.ScrollBarThickness=4
speedScroll.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
speedScroll.ScrollBarImageTransparency=0
speedScroll.CanvasSize=UDim2.new(0,0,0,0)
speedScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
speedScroll.ScrollingDirection=Enum.ScrollingDirection.Y
speedScroll.Parent=speedFrame
local speedContent=Instance.new("Frame")
speedContent.Size=UDim2.new(1,0,0,0)
speedContent.AutomaticSize=Enum.AutomaticSize.Y
speedContent.BackgroundTransparency=1
speedContent.Parent=speedScroll
local speedLayoutInner=Instance.new("UIListLayout")
speedLayoutInner.Padding=UDim.new(0,6) speedLayoutInner.SortOrder=Enum.SortOrder.LayoutOrder
speedLayoutInner.HorizontalAlignment=Enum.HorizontalAlignment.Center speedLayoutInner.Parent=speedContent
local speedPadInner=Instance.new("UIPadding")
speedPadInner.PaddingTop=UDim.new(0,8) speedPadInner.PaddingLeft=UDim.new(0,10)
speedPadInner.PaddingRight=UDim.new(0,10) speedPadInner.PaddingBottom=UDim.new(0,10) speedPadInner.Parent=speedContent
local function mkBoosterToggleRow(parent, labelTxt, initOn, onToggle)
	local row=Instance.new("Frame")
	row.Size=UDim2.new(1,0,0,42)
	row.BackgroundColor3=C_ROW
	row.BackgroundTransparency=0.25
	row.BorderSizePixel=0
	row.Parent=parent
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
	local lbTxt=Instance.new("TextLabel")
	lbTxt.Size=UDim2.new(1,-64,1,0) lbTxt.Position=UDim2.new(0,14,0,0)
	lbTxt.BackgroundTransparency=1 lbTxt.Text=labelTxt
	lbTxt.TextColor3=C_WHITE lbTxt.TextSize=13 lbTxt.Font=Enum.Font.GothamBold
	lbTxt.TextXAlignment=Enum.TextXAlignment.Left lbTxt.ZIndex=2 lbTxt.Parent=row
	local pill=Instance.new("Frame")
	pill.Size=UDim2.new(0,46,0,26) pill.Position=UDim2.new(1,-54,0.5,-13)
	pill.BackgroundColor3=initOn and C_PURPLE or C_PILLOFF
	pill.BorderSizePixel=0 pill.ZIndex=2 pill.Parent=row
	Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
	local dot=Instance.new("Frame")
	dot.Size=UDim2.new(0,20,0,20)
	dot.Position=initOn and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)
	dot.BackgroundColor3=initOn and C_WHITE or C_GREY
	dot.BorderSizePixel=0 dot.ZIndex=3 dot.Parent=pill
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	local on=initOn
	local btn=Instance.new("TextButton")
	btn.Size=UDim2.new(1,0,1,0) btn.BackgroundTransparency=1 btn.Text="" btn.ZIndex=10 btn.Parent=row
	btn.MouseButton1Click:Connect(function()
		on=not on
		TweenService:Create(dot,TweenInfo.new(0.12),{Position=on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}):Play()
		TweenService:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=on and C_PURPLE or C_PILLOFF}):Play()
		TweenService:Create(dot,TweenInfo.new(0.12),{BackgroundColor3=on and C_WHITE or C_GREY}):Play()
		onToggle(on)
	end)
	return row, function() return on end
end
local function mkSliderRowWithInput(parent, labelTxt, minVal, maxVal, initVal, onChange)
	local row=Instance.new("Frame")
	row.Size=UDim2.new(1,0,0,58)
	row.BackgroundColor3=C_ROW
	row.BackgroundTransparency=0.25
	row.BorderSizePixel=0
	row.Parent=parent
	Instance.new("UICorner",row).CornerRadius=UDim.new(0,12)
	local lbTxt=Instance.new("TextLabel")
	lbTxt.Size=UDim2.new(1,-70,0,22) lbTxt.Position=UDim2.new(0,14,0,4)
	lbTxt.BackgroundTransparency=1 lbTxt.Text=labelTxt
	lbTxt.TextColor3=C_WHITE lbTxt.TextSize=13 lbTxt.Font=Enum.Font.GothamBold
	lbTxt.TextXAlignment=Enum.TextXAlignment.Left lbTxt.Parent=row
	local inputBox=Instance.new("TextBox")
	inputBox.Size=UDim2.new(0,52,0,22) inputBox.Position=UDim2.new(1,-62,0,4)
	inputBox.BackgroundColor3=Color3.fromRGB(30,34,50) inputBox.BorderSizePixel=0
	inputBox.Text=tostring(initVal) inputBox.TextColor3=C_WHITE
	inputBox.Font=Enum.Font.GothamBold inputBox.TextSize=13
	inputBox.TextXAlignment=Enum.TextXAlignment.Center inputBox.ClearTextOnFocus=true inputBox.Parent=row
	Instance.new("UICorner",inputBox).CornerRadius=UDim.new(0,6)
	local ibStroke=Instance.new("UIStroke",inputBox) ibStroke.Color=C_STROKE ibStroke.Thickness=1
	local track=Instance.new("Frame")
	track.Size=UDim2.new(1,-28,0,8) track.Position=UDim2.new(0,14,0,38)
	track.BackgroundColor3=Color3.fromRGB(55,60,85) track.BorderSizePixel=0 track.Parent=row
	Instance.new("UICorner",track).CornerRadius=UDim.new(1,0)
	local pct=(initVal-minVal)/(maxVal-minVal)
	local fill=Instance.new("Frame")
	fill.Size=UDim2.new(pct,0,1,0) fill.BackgroundColor3=C_PURPLE fill.BorderSizePixel=0 fill.Parent=track
	Instance.new("UICorner",fill).CornerRadius=UDim.new(1,0)
	local knob=Instance.new("Frame")
	knob.Size=UDim2.new(0,18,0,18) knob.AnchorPoint=Vector2.new(0.5,0.5)
	knob.Position=UDim2.new(pct,0,0.5,0)
	knob.BackgroundColor3=C_WHITE knob.BorderSizePixel=0 knob.ZIndex=4 knob.Parent=track
	Instance.new("UICorner",knob).CornerRadius=UDim.new(1,0)
	local curVal=initVal
	local function setVal(v)
		v=math.clamp(math.floor(v+0.5),minVal,maxVal) curVal=v
		local p2=(v-minVal)/(maxVal-minVal)
		fill.Size=UDim2.new(p2,0,1,0) knob.Position=UDim2.new(p2,0,0.5,0)
		inputBox.Text=tostring(v)
		onChange(v)
	end
	local dragging=false
	local slBtn=Instance.new("TextButton")
	slBtn.Size=UDim2.new(1,0,1,0) slBtn.BackgroundTransparency=1 slBtn.Text="" slBtn.ZIndex=3 slBtn.Parent=track
	slBtn.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local abs=track.AbsolutePosition local sz=track.AbsoluteSize
			setVal(minVal+math.clamp((i.Position.X-abs.X)/sz.X,0,1)*(maxVal-minVal))
		end
	end)
	track.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			local abs=track.AbsolutePosition local sz=track.AbsoluteSize
			setVal(minVal+math.clamp((i.Position.X-abs.X)/sz.X,0,1)*(maxVal-minVal))
		end
	end)
	inputBox.FocusLost:Connect(function()
		local v=tonumber(inputBox.Text)
		if v then setVal(v) else inputBox.Text=tostring(curVal) end
	end)
	return row
end
local _antiDieConns = {}
local _antiDieActive = true
local function _antiDieApply()
	for _,c in ipairs(_antiDieConns) do pcall(function() c:Disconnect() end) end
	_antiDieConns = {}
	if not _antiDieActive then return end
	local char = plr.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	pcall(function() hum.BreakJointsOnDeath = false end)
	pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false) end)
	table.insert(_antiDieConns, hum:GetPropertyChangedSignal("Health"):Connect(function()
		if not _antiDieActive then return end
		pcall(function() if hum.Health <= 0 then hum.Health = hum.MaxHealth end end)
	end))
end
local function _antiDiePause()
	_antiDieActive = false
	for _,c in ipairs(_antiDieConns) do pcall(function() c:Disconnect() end) end
	_antiDieConns = {}
	local char = plr.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function() hum.BreakJointsOnDeath = true end)
			pcall(function() hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true) end)
		end
	end
end
local function _antiDieResume()
	_antiDieActive = true
	_antiDieApply()
end
plr.CharacterAdded:Connect(function()
	task.wait(0.3)
	_antiDieApply()
end)
task.spawn(function() task.wait(1) _antiDieApply() end)
mkBoosterToggleRow(speedContent, "Walk Speed", Save.walkSpeedOn or false, function(on)
	speedAntiOn=on
	Save.walkSpeedOn=on
	saveConfig()
	if on then applySpeedAnti() else removeSpeedAnti() end
end)
mkSliderRowWithInput(speedContent, "Walk Speed", 1, 500, speedAntiValue, function(v)
	speedAntiValue=v
	if speedAntiOn then applySpeedAnti() end
end)
local espFrame=Instance.new("Frame")
espFrame.Name="ESPFrame"
espFrame.Size=UDim2.new(0,185,0,200)
espFrame.Position=SavedPositions.espFrame
espFrame.BackgroundColor3=C_BG
espFrame.BackgroundTransparency=0.67
espFrame.BorderSizePixel=0
espFrame.Visible=false
espFrame.Active=true
espFrame.ClipsDescendants=true
espFrame.Parent=sg
Instance.new("UICorner",espFrame).CornerRadius=UDim.new(0,16)
local espStroke=Instance.new("UIStroke",espFrame)
espStroke.Thickness=2 espStroke.Color=C_STROKE espStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local espTop=Instance.new("Frame")
espTop.Size=UDim2.new(1,0,0,38)
espTop.BackgroundTransparency=1
espTop.BorderSizePixel=0
espTop.Parent=espFrame
local espTitle=Instance.new("TextLabel")
espTitle.Size=UDim2.new(1,-44,1,0)
espTitle.Position=UDim2.new(0,14,0,0)
espTitle.BackgroundTransparency=1
espTitle.Text="ESP"
espTitle.TextColor3=C_WHITE
espTitle.TextSize=15
espTitle.Font=Enum.Font.GothamBlack
espTitle.TextXAlignment=Enum.TextXAlignment.Left
espTitle.Parent=espTop
local sDivB=Instance.new("Frame")
sDivB.Size=UDim2.new(1,-20,0,1) sDivB.Position=UDim2.new(0,10,1,-1)
sDivB.BackgroundColor3=C_STROKE sDivB.BackgroundTransparency=0.4 sDivB.BorderSizePixel=0 sDivB.Parent=espTop
local espMinBtn=Instance.new("TextButton")
espMinBtn.Size=UDim2.new(0,28,0,28)
espMinBtn.Position=UDim2.new(1,-36,0.5,-14)
espMinBtn.BackgroundColor3=C_ROW
espMinBtn.Text="-" espMinBtn.TextColor3=C_WHITE
espMinBtn.TextSize=16 espMinBtn.Font=Enum.Font.GothamBold
espMinBtn.BorderSizePixel=0 espMinBtn.Parent=espTop
Instance.new("UICorner",espMinBtn).CornerRadius=UDim.new(0,8)
local espFullH=160 local espMiniH=34 local espMinimized=false
espMinBtn.MouseButton1Click:Connect(function()
	espMinimized=not espMinimized
	espFrame.Size=UDim2.new(0,185,0,espMinimized and espMiniH or espFullH)
	espMinBtn.Text=espMinimized and "+" or "-"
end)
local espScroll=Instance.new("ScrollingFrame")
espScroll.Size=UDim2.new(1,0,1,-38)
espScroll.Position=UDim2.new(0,0,0,38)
espScroll.BackgroundTransparency=1
espScroll.BorderSizePixel=0
espScroll.ScrollBarThickness=4
espScroll.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
espScroll.ScrollBarImageTransparency=0
espScroll.CanvasSize=UDim2.new(0,0,0,0)
espScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
espScroll.ScrollingDirection=Enum.ScrollingDirection.Y
espScroll.Parent=espFrame
local espCont=Instance.new("Frame")
espCont.Size=UDim2.new(1,0,0,0)
espCont.AutomaticSize=Enum.AutomaticSize.Y
espCont.BackgroundTransparency=1
espCont.Parent=espScroll
local espLayout=Instance.new("UIListLayout")
espLayout.Padding=UDim.new(0,7) espLayout.SortOrder=Enum.SortOrder.LayoutOrder
espLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center espLayout.Parent=espCont
local espPad2=Instance.new("UIPadding")
espPad2.PaddingTop=UDim.new(0,8) espPad2.PaddingLeft=UDim.new(0,10)
espPad2.PaddingRight=UDim.new(0,10) espPad2.PaddingBottom=UDim.new(0,10) espPad2.Parent=espCont
local spamFrame=Instance.new("Frame")
spamFrame.Name="SpamFrame"
spamFrame.Size=UDim2.new(0,185,0,165)
spamFrame.Position=SavedPositions.spamFrame
spamFrame.BackgroundColor3=C_BG
spamFrame.BackgroundTransparency=0.67
spamFrame.BorderSizePixel=0
spamFrame.Visible=false
spamFrame.Active=true
spamFrame.ClipsDescendants=true
spamFrame.Parent=sg
Instance.new("UICorner",spamFrame).CornerRadius=UDim.new(0,16)
local spamStroke=Instance.new("UIStroke",spamFrame)
spamStroke.Thickness=2 spamStroke.Color=C_STROKE spamStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local spamTop=Instance.new("Frame")
spamTop.Size=UDim2.new(1,0,0,38)
spamTop.BackgroundTransparency=1
spamTop.BorderSizePixel=0
spamTop.Parent=spamFrame
local spamTitle=Instance.new("TextLabel")
spamTitle.Size=UDim2.new(1,-44,1,0)
spamTitle.Position=UDim2.new(0,14,0,0)
spamTitle.BackgroundTransparency=1
spamTitle.Text="Spam"
spamTitle.TextColor3=C_WHITE
spamTitle.TextSize=15
spamTitle.Font=Enum.Font.GothamBlack
spamTitle.TextXAlignment=Enum.TextXAlignment.Left
spamTitle.Parent=spamTop
local sDivC=Instance.new("Frame")
sDivC.Size=UDim2.new(1,-20,0,1) sDivC.Position=UDim2.new(0,10,1,-1)
sDivC.BackgroundColor3=C_STROKE sDivC.BackgroundTransparency=0.4 sDivC.BorderSizePixel=0 sDivC.Parent=spamTop
local spamMinBtn=Instance.new("TextButton")
spamMinBtn.Size=UDim2.new(0,28,0,28)
spamMinBtn.Position=UDim2.new(1,-36,0.5,-14)
spamMinBtn.BackgroundColor3=C_ROW
spamMinBtn.Text="-" spamMinBtn.TextColor3=C_WHITE
spamMinBtn.TextSize=16 spamMinBtn.Font=Enum.Font.GothamBold
spamMinBtn.BorderSizePixel=0 spamMinBtn.Parent=spamTop
Instance.new("UICorner",spamMinBtn).CornerRadius=UDim.new(0,8)
local spamFullH=200 local spamMiniH=34 local spamMinimized=false
spamMinBtn.MouseButton1Click:Connect(function()
	spamMinimized=not spamMinimized
	spamFrame.Size=UDim2.new(0,185,0,spamMinimized and spamMiniH or spamFullH)
	spamMinBtn.Text=spamMinimized and "+" or "-"
end)
local spamScroll=Instance.new("ScrollingFrame")
spamScroll.Size=UDim2.new(1,0,1,-38)
spamScroll.Position=UDim2.new(0,0,0,38)
spamScroll.BackgroundTransparency=1
spamScroll.BorderSizePixel=0
spamScroll.ScrollBarThickness=4
spamScroll.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
spamScroll.ScrollBarImageTransparency=0
spamScroll.CanvasSize=UDim2.new(0,0,0,0)
spamScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
spamScroll.ScrollingDirection=Enum.ScrollingDirection.Y
spamScroll.Parent=spamFrame
local spamCont=Instance.new("Frame")
spamCont.Size=UDim2.new(1,0,0,0)
spamCont.AutomaticSize=Enum.AutomaticSize.Y
spamCont.BackgroundTransparency=1
spamCont.Parent=spamScroll
local spamLayout=Instance.new("UIListLayout")
spamLayout.Padding=UDim.new(0,7)
spamLayout.SortOrder=Enum.SortOrder.LayoutOrder
spamLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
spamLayout.Parent=spamCont
local spamPad=Instance.new("UIPadding")
spamPad.PaddingTop=UDim.new(0,8) spamPad.PaddingLeft=UDim.new(0,10)
spamPad.PaddingRight=UDim.new(0,10) spamPad.PaddingBottom=UDim.new(0,10)
spamPad.Parent=spamCont
mkSideToggle("Booster","speedAnti",function(on)
	UIState.speed = on
	if on then
		local vp=workspace.CurrentCamera.ViewportSize
		local h=speedFrame.AbsoluteSize.Y
		speedFrame.Position=UDim2.new(0,10,0,math.clamp(mf.AbsolutePosition.Y+mf.AbsoluteSize.Y+8,0,vp.Y-h))
	end
	speedFrame.Visible = on
	if on then speedAntiOn=false removeSpeedAnti() end
end)
mkSideToggle("ESP","esp",function(on)
	UIState.esp = on
	if on then
		local vp=workspace.CurrentCamera.ViewportSize
		local w=espFrame.AbsoluteSize.X local h=espFrame.AbsoluteSize.Y
		espFrame.Position=UDim2.new(0,math.clamp(vp.X-w-10,0,vp.X-w),0,math.clamp(mf.AbsolutePosition.Y,0,vp.Y-h))
	end
	espFrame.Visible = on
end)
mkSideToggle("Spam","spam",function(on)
	UIState.spam = on
	if on then
		local vp=workspace.CurrentCamera.ViewportSize
		local w=spamFrame.AbsoluteSize.X local h=spamFrame.AbsoluteSize.Y
		local x=math.clamp(vp.X-w-10,0,vp.X-w)
		local y=math.clamp(mf.AbsolutePosition.Y+mf.AbsoluteSize.Y+8,0,vp.Y-h)
		spamFrame.Position=UDim2.new(0,x,0,y)
	end
	spamFrame.Visible = on
end)
local serverFullH=190 local serverMiniH=34 local serverMinimized=false
local serverFrame=Instance.new("Frame")
serverFrame.Name="ServerFrame"
serverFrame.Size=UDim2.new(0,185,0,serverFullH)
serverFrame.Position=UDim2.new(0,220,0,80)
serverFrame.BackgroundColor3=C_BG
serverFrame.BackgroundTransparency=0.67
serverFrame.BorderSizePixel=0
serverFrame.Visible=false
serverFrame.Active=true
serverFrame.ClipsDescendants=true
serverFrame.Parent=sg
Instance.new("UICorner",serverFrame).CornerRadius=UDim.new(0,16)
local serverStroke=Instance.new("UIStroke",serverFrame)
serverStroke.Thickness=2 serverStroke.Color=C_STROKE serverStroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
local serverTop=Instance.new("Frame")
serverTop.Size=UDim2.new(1,0,0,serverMiniH)
serverTop.BackgroundTransparency=1
serverTop.BorderSizePixel=0 serverTop.Parent=serverFrame
local serverTitle=Instance.new("TextLabel")
serverTitle.Size=UDim2.new(1,-44,1,0) serverTitle.Position=UDim2.new(0,14,0,0)
serverTitle.BackgroundTransparency=1 serverTitle.Text="Servidor"
serverTitle.TextColor3=C_WHITE serverTitle.TextSize=15
serverTitle.Font=Enum.Font.GothamBlack serverTitle.TextXAlignment=Enum.TextXAlignment.Left serverTitle.Parent=serverTop
local srvDiv=Instance.new("Frame")
srvDiv.Size=UDim2.new(1,-20,0,1) srvDiv.Position=UDim2.new(0,10,1,-1)
srvDiv.BackgroundColor3=C_STROKE srvDiv.BackgroundTransparency=0.4 srvDiv.BorderSizePixel=0 srvDiv.Parent=serverTop
local serverMinBtn=Instance.new("TextButton")
serverMinBtn.Size=UDim2.new(0,28,0,28) serverMinBtn.Position=UDim2.new(1,-36,0.5,-14)
serverMinBtn.BackgroundColor3=C_ROW serverMinBtn.Text="-"
serverMinBtn.TextColor3=C_WHITE serverMinBtn.TextSize=16
serverMinBtn.Font=Enum.Font.GothamBold serverMinBtn.BorderSizePixel=0 serverMinBtn.Parent=serverTop
Instance.new("UICorner",serverMinBtn).CornerRadius=UDim.new(0,8)
serverMinBtn.MouseButton1Click:Connect(function()
	serverMinimized=not serverMinimized
	serverFrame.Size=UDim2.new(0,185,0,serverMinimized and serverMiniH or serverFullH)
	serverMinBtn.Text=serverMinimized and "+" or "-"
end)
local serverScroll=Instance.new("ScrollingFrame")
serverScroll.Size=UDim2.new(1,0,1,-serverMiniH)
serverScroll.Position=UDim2.new(0,0,0,serverMiniH)
serverScroll.BackgroundTransparency=1
serverScroll.BorderSizePixel=0
serverScroll.ScrollBarThickness=4
serverScroll.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
serverScroll.ScrollBarImageTransparency=0
serverScroll.CanvasSize=UDim2.new(0,0,0,0)
serverScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
serverScroll.ScrollingDirection=Enum.ScrollingDirection.Y
serverScroll.Parent=serverFrame
local serverCont=Instance.new("Frame")
serverCont.Size=UDim2.new(1,0,0,0)
serverCont.AutomaticSize=Enum.AutomaticSize.Y
serverCont.BackgroundTransparency=1 serverCont.Parent=serverScroll
local serverLayout=Instance.new("UIListLayout")
serverLayout.Padding=UDim.new(0,8) serverLayout.SortOrder=Enum.SortOrder.LayoutOrder
serverLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center serverLayout.Parent=serverCont
local serverPad=Instance.new("UIPadding")
serverPad.PaddingTop=UDim.new(0,10) serverPad.PaddingLeft=UDim.new(0,10)
serverPad.PaddingRight=UDim.new(0,10) serverPad.PaddingBottom=UDim.new(0,10) serverPad.Parent=serverCont
local function mkServerBtn(txt,cb)
	local b=Instance.new("TextButton")
	b.Size=UDim2.new(1,0,0,46)
	b.BackgroundColor3=C_ROW
	b.BackgroundTransparency=0.25
	b.Text=txt b.Font=Enum.Font.GothamBold b.TextSize=14
	b.TextColor3=C_WHITE
	b.BorderSizePixel=0 b.Parent=serverCont
	Instance.new("UICorner",b).CornerRadius=UDim.new(0,14)
	local bStroke=Instance.new("UIStroke",b)
	bStroke.Thickness=2 bStroke.Color=C_STROKE
	b.MouseButton1Click:Connect(cb)
	b.MouseButton1Click:Connect(function()
		TweenService:Create(b,TweenInfo.new(0.08),{BackgroundColor3=Color3.fromRGB(70,75,110)}):Play()
		task.delay(0.15,function() TweenService:Create(b,TweenInfo.new(0.12),{BackgroundColor3=C_ROW}):Play() end)
	end)
	return b
end
mkServerBtn("Rejoin Server",function()
	TeleportService:Teleport(game.PlaceId, plr)
end)
mkServerBtn("Kick Self",function()
	plr:Kick("Kicked by script")
end)
mkServerBtn("Force Reset",function()
	ResetToWork()
end)
do
	local cont=Instance.new("Frame")
	cont.Size=UDim2.new(1,0,0,42)
	cont.BackgroundColor3=C_ROW
	cont.BackgroundTransparency=0.25
	cont.BorderSizePixel=0 cont.Parent=serverCont
	Instance.new("UICorner",cont).CornerRadius=UDim.new(0,12)
	local tlbl=Instance.new("TextLabel")
	tlbl.Size=UDim2.new(1,-60,1,0) tlbl.Position=UDim2.new(0,12,0,0)
	tlbl.BackgroundTransparency=1 tlbl.Text="Auto Kick"
	tlbl.TextColor3=C_WHITE tlbl.TextSize=13
	tlbl.Font=Enum.Font.GothamBold tlbl.TextXAlignment=Enum.TextXAlignment.Left
	tlbl.ZIndex=2 tlbl.Parent=cont
	local pill=Instance.new("Frame")
	pill.Size=UDim2.new(0,40,0,22) pill.Position=UDim2.new(1,-48,0.5,-11)
	pill.BackgroundColor3=Save.autoKick and C_PURPLE or C_PILLOFF
	pill.BorderSizePixel=0 pill.ZIndex=2 pill.Parent=cont
	Instance.new("UICorner",pill).CornerRadius=UDim.new(1,0)
	local dot=Instance.new("Frame")
	dot.Size=UDim2.new(0,16,0,16)
	dot.Position=Save.autoKick and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
	dot.BackgroundColor3=Save.autoKick and C_WHITE or C_GREY
	dot.BorderSizePixel=0 dot.ZIndex=3 dot.Parent=pill
	Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
	local ca=Instance.new("TextButton")
	ca.Size=UDim2.new(1,0,1,0) ca.BackgroundTransparency=1 ca.Text="" ca.ZIndex=10 ca.Parent=cont
	local _AKplr2=plr
	local _AKPlayerGui2=plr:WaitForChild("PlayerGui")
	local _akEnabled2=Save.autoKick or false
	local _akConns2={}
	local _akKeyword2="you stole"
	local function _akHasKw2(t) return typeof(t)=="string" and string.find(string.lower(t),_akKeyword2)~=nil end
	local function _akKick2() pcall(function() _AKplr2:Kick("You stole brainrot!") end) end
	local function _akWatch2(gui)
		if not _akEnabled2 then return end
		for _,obj in ipairs(gui:GetDescendants()) do
			if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
				if _akHasKw2(obj.Text) and _akEnabled2 then _akKick2() return end
				table.insert(_akConns2,obj:GetPropertyChangedSignal("Text"):Connect(function()
					if _akEnabled2 and _akHasKw2(obj.Text) then _akKick2() end
				end))
			end
		end
		table.insert(_akConns2,gui.DescendantAdded:Connect(function(d)
			if not _akEnabled2 then return end
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				if _akHasKw2(d.Text) then _akKick2() end
				table.insert(_akConns2,d:GetPropertyChangedSignal("Text"):Connect(function()
					if _akEnabled2 and _akHasKw2(d.Text) then _akKick2() end
				end))
			end
		end))
	end
	local function setAK(on)
		_akEnabled2=on Save.autoKick=on saveConfig()
		TweenService:Create(dot,TweenInfo.new(0.12),{Position=on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
		TweenService:Create(pill,TweenInfo.new(0.12),{BackgroundColor3=on and C_PURPLE or C_PILLOFF}):Play()
		TweenService:Create(dot,TweenInfo.new(0.12),{BackgroundColor3=on and C_WHITE or C_GREY}):Play()
		if on then
			for _,g in ipairs(_AKPlayerGui2:GetChildren()) do _akWatch2(g) end
			table.insert(_akConns2,_AKPlayerGui2.ChildAdded:Connect(function(g) _akWatch2(g) end))
		else
			for _,c in ipairs(_akConns2) do pcall(function() c:Disconnect() end) end
			_akConns2={}
		end
	end
	ca.MouseButton1Click:Connect(function() setAK(not _akEnabled2) end)
	if _akEnabled2 then task.spawn(function() setAK(true) end) end
end
makeDraggable(serverFrame,serverTop)
mkSideToggle("Server","server",function(on)
	if on then
		local vp=workspace.CurrentCamera.ViewportSize
		local mfPos=mf.AbsolutePosition local mfSz=mf.AbsoluteSize
		local smW=185 local smH=serverFullH
		local xRight=mfPos.X+mfSz.X+sideMenu.AbsoluteSize.X+12
		local x=math.clamp(xRight,0,vp.X-smW)
		local y=math.clamp(mfPos.Y,0,vp.Y-smH)
		serverFrame.Position=UDim2.new(0,x,0,y)
	end
	serverFrame.Visible=on
end)
local _protectorActive = false
local _protectorScanConns = {}
local PROT_FULL_H = 130
local PROT_MINI_H = 38
local protMinimized = false
local protFrame = Instance.new("Frame")
protFrame.Name = "ProtectorFrame"
protFrame.Size = UDim2.new(0, 210, 0, PROT_FULL_H)
protFrame.Position = UDim2.new(1, -230, 0.12, 0)
protFrame.BackgroundColor3 = C_BG
protFrame.BackgroundTransparency = 0.67
protFrame.BorderSizePixel = 0
protFrame.Visible = false
protFrame.Active = true
protFrame.ClipsDescendants = true
protFrame.Parent = sg
Instance.new("UICorner", protFrame).CornerRadius = UDim.new(0, 16)
local protBorderStroke = Instance.new("UIStroke", protFrame)
protBorderStroke.Thickness = 1.5
protBorderStroke.Color = C_STROKE
protBorderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local protTop = Instance.new("Frame")
protTop.Size = UDim2.new(1, 0, 0, PROT_MINI_H)
protTop.BackgroundTransparency = 1
protTop.BorderSizePixel = 0
protTop.Parent = protFrame
local protTitleLbl = Instance.new("TextLabel")
protTitleLbl.Size = UDim2.new(1, -44, 1, 0)
protTitleLbl.Position = UDim2.new(0, 14, 0, 0)
protTitleLbl.BackgroundTransparency = 1
protTitleLbl.Text = "Protector"
protTitleLbl.TextColor3 = C_WHITE
protTitleLbl.TextSize = 15
protTitleLbl.Font = Enum.Font.GothamBlack
protTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
protTitleLbl.Parent = protTop
local protDivider = Instance.new("Frame")
protDivider.Size = UDim2.new(1, -20, 0, 1)
protDivider.Position = UDim2.new(0, 10, 1, -1)
protDivider.BackgroundColor3 = C_STROKE
protDivider.BackgroundTransparency = 0.4
protDivider.BorderSizePixel = 0
protDivider.Parent = protTop
local protMinBtn = Instance.new("TextButton")
protMinBtn.Size = UDim2.new(0, 28, 0, 28)
protMinBtn.Position = UDim2.new(1, -36, 0.5, -14)
protMinBtn.BackgroundColor3 = C_ROW
protMinBtn.Text = "-"
protMinBtn.TextColor3 = C_WHITE
protMinBtn.TextSize = 16
protMinBtn.Font = Enum.Font.GothamBold
protMinBtn.BorderSizePixel = 0
protMinBtn.Parent = protTop
Instance.new("UICorner", protMinBtn).CornerRadius = UDim.new(0, 8)
protMinBtn.MouseButton1Click:Connect(function()
	protMinimized = not protMinimized
	protFrame.Size = UDim2.new(0, 210, 0, protMinimized and PROT_MINI_H or PROT_FULL_H)
	protMinBtn.Text = protMinimized and "+" or "-"
end)
local protCont = Instance.new("Frame")
protCont.Size = UDim2.new(1, 0, 1, -PROT_MINI_H)
protCont.Position = UDim2.new(0, 0, 0, PROT_MINI_H)
protCont.BackgroundTransparency = 1
protCont.ClipsDescendants = true
protCont.Parent = protFrame
local protContLayout = Instance.new("UIListLayout")
protContLayout.Padding = UDim.new(0, 6)
protContLayout.SortOrder = Enum.SortOrder.LayoutOrder
protContLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
protContLayout.Parent = protCont
local protContPad = Instance.new("UIPadding")
protContPad.PaddingTop = UDim.new(0, 8)
protContPad.PaddingLeft = UDim.new(0, 10)
protContPad.PaddingRight = UDim.new(0, 10)
protContPad.PaddingBottom = UDim.new(0, 8)
protContPad.Parent = protCont
local function protMkToggle(txt, getOn, setOn)
	local cont = Instance.new("Frame")
	cont.Size = UDim2.new(1, 0, 0, 36)
	cont.BackgroundColor3 = C_ROW
	cont.BackgroundTransparency = 0.25
	cont.BorderSizePixel = 0
	cont.Parent = protCont
	Instance.new("UICorner", cont).CornerRadius = UDim.new(0, 10)
	local tlbl = Instance.new("TextLabel")
	tlbl.Size = UDim2.new(1, -60, 1, 0)
	tlbl.Position = UDim2.new(0, 12, 0, 0)
	tlbl.BackgroundTransparency = 1
	tlbl.Text = txt
	tlbl.TextColor3 = C_WHITE
	tlbl.TextSize = 12
	tlbl.Font = Enum.Font.GothamBold
	tlbl.TextXAlignment = Enum.TextXAlignment.Left
	tlbl.ZIndex = 2
	tlbl.Parent = cont
	local pill = Instance.new("Frame")
	pill.Size = UDim2.new(0, 40, 0, 22)
	pill.Position = UDim2.new(1, -48, 0.5, -11)
	pill.BackgroundColor3 = getOn() and C_PURPLE or C_PILLOFF
	pill.BorderSizePixel = 0
	pill.ZIndex = 2
	pill.Parent = cont
	Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0, 16, 0, 16)
	dot.Position = getOn() and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	dot.BackgroundColor3 = getOn() and C_WHITE or C_GREY
	dot.BorderSizePixel = 0
	dot.ZIndex = 3
	dot.Parent = pill
	Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
	local ca = Instance.new("TextButton")
	ca.Size = UDim2.new(1, 0, 1, 0)
	ca.BackgroundTransparency = 1
	ca.Text = ""
	ca.ZIndex = 10
	ca.Parent = cont
	ca.MouseButton1Click:Connect(function()
		local on = setOn()
		TweenService:Create(dot, TweenInfo.new(0.12), {Position = on and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)}):Play()
		TweenService:Create(pill, TweenInfo.new(0.12), {BackgroundColor3 = on and C_PURPLE or C_PILLOFF}):Play()
		TweenService:Create(dot, TweenInfo.new(0.12), {BackgroundColor3 = on and C_WHITE or C_GREY}):Play()
	end)
end
makeDraggable(protFrame, protTop)
local _protCmds = {"balloon","tiny","ragdoll","morph","jumpscare","jail","rocket","inverse"}
local _protCooldown = {}
local function sendProtCmd(targetPlayer, cmd)
	if not targetPlayer or not targetPlayer.Character then return end
	local remote = _G._ProtAdminRemote
	if not remote then return end
	pcall(function()
		remote:InvokeServer("f888ee6e-c86d-46e1-93d7-0639d6635d42", targetPlayer, cmd)
	end)
end
local _protCmdList = {"balloon","rocket","jail"}
local _protAutoKick = Save.protAutoKick or false
local function protOnSteal()
	local now = tick()
	local hrp = getRoot()
	if not hrp then return end
	local myPos = hrp.Position
	local closestPlayer = nil
	local closestDist = math.huge
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= plr and p.Character then
			local phrp = p.Character:FindFirstChild("HumanoidRootPart")
			if phrp then
				local dist = (phrp.Position - myPos).Magnitude
				if dist < closestDist then
					closestDist = dist
					closestPlayer = p
				end
			end
		end
	end
	if not closestPlayer then return end
	local cd = _protCooldown[closestPlayer.Name] or 0
	if now - cd < 0.5 then return end
	_protCooldown[closestPlayer.Name] = now
	task.spawn(function()
		for _, cmd in ipairs(_protCmdList) do
			task.spawn(sendProtCmd, closestPlayer, cmd)
		end
		if _protAutoKick then
			pcall(function() plr:Kick("Protected") end)
		end
	end)
end
local function protStartMonitor()
	for _, c in ipairs(_protectorScanConns) do pcall(function() c:Disconnect() end) end
	_protectorScanConns = {}
	local pg = plr:WaitForChild("PlayerGui")
	local function chkTxt(t) return type(t) == "string" and string.find(t, "Someone is stealing your") ~= nil end
	local function watchObj(v)
		if not (v:IsA("TextLabel") or v:IsA("TextButton") or v:IsA("TextBox")) then return end
		if chkTxt(v.Text) then task.spawn(protOnSteal) return end
		table.insert(_protectorScanConns, v:GetPropertyChangedSignal("Text"):Connect(function()
			if _protectorActive and chkTxt(v.Text) then task.spawn(protOnSteal) end
		end))
	end
	for _, v in ipairs(pg:GetDescendants()) do watchObj(v) end
	table.insert(_protectorScanConns, pg.DescendantAdded:Connect(function(d)
		if not _protectorActive then return end
		watchObj(d)
	end))
end
local function protStopMonitor()
	for _, c in ipairs(_protectorScanConns) do pcall(function() c:Disconnect() end) end
	_protectorScanConns = {}
end
_protectorActive = Save.protectorOn or false
protMkToggle("Base Protector",
	function() return _protectorActive end,
	function()
		_protectorActive = not _protectorActive
		Save.protectorOn = _protectorActive
		saveConfig()
		if _protectorActive then
			protStartMonitor()
		else
			protStopMonitor()
		end
		return _protectorActive
	end
)
protMkToggle("Auto Kick",
	function() return _protAutoKick end,
	function()
		_protAutoKick = not _protAutoKick
		Save.protAutoKick = _protAutoKick
		saveConfig()
		return _protAutoKick
	end
)
if _protectorActive then task.spawn(protStartMonitor) end
local function _layoutGuisAround()
	local vp = workspace.CurrentCamera.ViewportSize
	local mfPos = mf.AbsolutePosition
	local mfSz  = mf.AbsoluteSize
	do
		local h = speedFrame.AbsoluteSize.Y
		speedFrame.Position = UDim2.new(0, 10, 0, math.clamp(mfPos.Y + mfSz.Y + 8, 0, vp.Y - h))
	end
	do
		local w = espFrame.AbsoluteSize.X
		local h = espFrame.AbsoluteSize.Y
		espFrame.Position = UDim2.new(0, math.clamp(vp.X - w - 10, 0, vp.X - w), 0, math.clamp(mfPos.Y, 0, vp.Y - h))
	end
	do
		local w = spamFrame.AbsoluteSize.X
		local h = spamFrame.AbsoluteSize.Y
		local x = math.clamp(vp.X - w - 10, 0, vp.X - w)
		local y = math.clamp(mfPos.Y + mfSz.Y + 8, 0, vp.Y - h)
		spamFrame.Position = UDim2.new(0, x, 0, y)
	end
	do
		local smW = sideMenu.AbsoluteSize.X > 0 and sideMenu.AbsoluteSize.X or 185
		local xRight = mfPos.X + mfSz.X + smW + 12
		serverFrame.Position = UDim2.new(0, math.clamp(xRight, 0, vp.X - 210), 0, math.clamp(mfPos.Y, 0, vp.Y - serverFullH))
	end
	do
		local w = 210
		local h = PROT_FULL_H
		local sx = math.clamp(vp.X - spamFrame.AbsoluteSize.X - 10, 0, vp.X - spamFrame.AbsoluteSize.X)
		local sy = spamFrame.AbsolutePosition.Y + spamFrame.AbsoluteSize.Y + 8
		protFrame.Position = UDim2.new(0, math.clamp(sx, 0, vp.X - w), 0, math.clamp(sy, 0, vp.Y - h))
	end
end
local semiTP = false
local activateBtn=mkBtn("Activate (Reset)",UDim2.new(0,8,0,114),C_ROW)
activateBtn.MouseButton1Click:Connect(function()
	activateBtn.Text="Activating..."
	semiTP=true
	task.spawn(function()
		_antiDiePause()
		task.wait(0.3)
		ResetToWork()
		task.wait(0.5)
		_antiDieResume()
		activateBtn.Text="Activate (Reset)"
	end)
end)
local executeBtn=mkBtn("Execute (F)",UDim2.new(0,8,0,152),C_PURPLE)
executeBtn.MouseButton1Click:Connect(function()
	executeBtn.Text="Executing..."
	if _G._doStart then
		task.spawn(_G._doStart)
	end
	task.delay(1.5,function() if executeBtn and executeBtn.Parent then executeBtn.Text="Execute (F)" end end)
end)
local function getEnemyPlot()
	local plots = workspace:FindFirstChild("Plots")
	if not plots then return nil end
	local base = _G._getCachedBase and _G._getCachedBase() or "left"
	local enemyPos = base == "left" and pos2 or pos1
	local closest = nil
	local closestDist = math.huge
	for _, plot in ipairs(plots:GetChildren()) do
		local dist = (plot:GetPivot().Position - enemyPos).Magnitude
		if dist < closestDist then
			closestDist = dist
			closest = plot
		end
	end
	return closest
end
_G._getEnemyPlot = getEnemyPlot
local unlockFrame = Instance.new("Frame")
unlockFrame.Name = "UnlockFrame"
unlockFrame.Size = UDim2.new(0, 88, 0, 50)
unlockFrame.Position = UDim2.new(0.5, -44, 1, -160)
unlockFrame.BackgroundColor3 = C_BG
unlockFrame.BackgroundTransparency = 0.67
unlockFrame.BorderSizePixel = 0
unlockFrame.Visible = false
unlockFrame.Active = true
unlockFrame.ZIndex = 10
unlockFrame.Parent = sg
Instance.new("UICorner", unlockFrame).CornerRadius = UDim.new(0, 12)
local unlockStroke = Instance.new("UIStroke", unlockFrame)
unlockStroke.Thickness = 1.5
unlockStroke.Color = C_STROKE
unlockStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
local unlockLayout = Instance.new("UIListLayout")
unlockLayout.FillDirection = Enum.FillDirection.Horizontal
unlockLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
unlockLayout.VerticalAlignment = Enum.VerticalAlignment.Center
unlockLayout.Padding = UDim.new(0, 6)
unlockLayout.SortOrder = Enum.SortOrder.LayoutOrder
unlockLayout.Parent = unlockFrame
local unlockPad = Instance.new("UIPadding")
unlockPad.PaddingLeft = UDim.new(0, 8)
unlockPad.PaddingRight = UDim.new(0, 8)
unlockPad.Parent = unlockFrame
makeDraggable(unlockFrame, unlockFrame)
local function mkUnlockBtn(num, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 34, 0, 34)
	b.BackgroundColor3 = C_ROW
	b.BackgroundTransparency = 0.1
	b.BorderSizePixel = 0
	b.Text = tostring(num)
	b.TextColor3 = C_WHITE
	b.Font = Enum.Font.GothamBlack
	b.TextSize = 16
	b.LayoutOrder = num
	b.Parent = unlockFrame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	b.MouseButton1Click:Connect(function()
		TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = C_PURPLE}):Play()
		task.delay(0.2, function() TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = C_ROW}):Play() end)
		cb()
	end)
	return b
end
local function buildUnlockGui()
	for _, c in ipairs(unlockFrame:GetChildren()) do
		if c:IsA("TextButton") then c:Destroy() end
	end
	task.spawn(function()
		for _ = 1, 20 do
			if _G._getCachedBase then break end
			task.wait(0.3)
		end
		local plot = getEnemyPlot()
		for _ = 1, 10 do
			if plot then break end
			task.wait(0.5)
			plot = getEnemyPlot()
		end
		if not plot then return end
		local unlock = plot:FindFirstChild("Unlock")
		local laser  = plot:FindFirstChild("LaserHitbox")
		if not unlock or not laser then return end
		local floors = {
			{name = "Main",        idx = 1},
			{name = "SecondFloor", idx = 2},
			{name = "ThirdFloor",  idx = 3},
		}
		local btnCount = 0
		for _, f in ipairs(floors) do
			local laserPart = laser:FindFirstChild(f.name)
			if not laserPart then continue end
			btnCount = btnCount + 1
			local targetPos = laserPart:IsA("BasePart") and laserPart.Position or laserPart:GetPivot().Position
			mkUnlockBtn(f.idx, function()
				local closest = nil
				local shortest = math.huge
				for _, d in ipairs(unlock:GetDescendants()) do
					if d:IsA("ProximityPrompt") and d.Name == "UnlockBase" then
						local part = d.Parent
						if part and part:IsA("BasePart") then
							local dist = (part.Position - targetPos).Magnitude
							if dist < shortest then
								shortest = dist
								closest = d
							end
						end
					end
				end
				if closest then
					local oldDist = closest.MaxActivationDistance
					pcall(function()
						closest.HoldDuration = 0
						closest.MaxActivationDistance = math.huge
						closest.RequiresLineOfSight = false
						closest.Exclusivity = Enum.ProximityPromptExclusivity.AlwaysShow
					end)
					task.wait(0.05)
					pcall(function() if fireproximityprompt then fireproximityprompt(closest) end end)
					task.wait(0.5)
					pcall(function() closest.MaxActivationDistance = oldDist end)
				end
			end)
		end
		if btnCount == 0 then return end
		local w = btnCount * 34 + (btnCount - 1) * 6 + 16
		unlockFrame.Size = UDim2.new(0, w, 0, 50)
		laser.ChildAdded:Connect(function()
			if unlockFrame.Visible then
				task.wait(0.1)
				buildUnlockGui()
			end
		end)
	end)
end
Players.PlayerAdded:Connect(function()
	if unlockFrame.Visible then
		task.wait(1)
		buildUnlockGui()
	end
end)

makeDraggableWithChild(mf, sideMenu, topbar)
makeDraggable(speedFrame, speedTop)
makeDraggable(espFrame, espTop)
makeDraggable(spamFrame, spamTop)
local holdTask=nil local isHold=false
PPS.PromptButtonHoldBegan:Connect(function(p,pl)
	if pl~=plr then return end
	isHold=true if holdTask then task.cancel(holdTask) end
end)
PPS.PromptButtonHoldEnded:Connect(function(p,pl)
	if pl~=plr then return end
	isHold=false if holdTask then task.cancel(holdTask) end
end)
local animals={} local promptCache={} local StealProgress=0 local RADIUS=200
local function isMyBase(n)
	local p=workspace.Plots:FindFirstChild(n) if not p then return false end
	local s=p:FindFirstChild("PlotSign") return s and s:FindFirstChild("YourBase") and s.YourBase.Enabled
end
PPS.PromptTriggered:Connect(function(p,pl)
	if pl~=plr then return end
	if IsStealing then return end
	if _stealingCFrame then return end
	local plotParent = p.Parent
	while plotParent and plotParent ~= workspace do
		local plots = workspace:FindFirstChild("Plots")
		if plots and plots:FindFirstChild(plotParent.Name) then
			if isMyBase(plotParent.Name) then return end
			break
		end
		plotParent = plotParent.Parent
	end
	local promptPos = p.Parent and p.Parent:IsA("BasePart") and p.Parent.Position
		or p.Parent and p.Parent.Parent and p.Parent.Parent:IsA("Model") and p.Parent.Parent:GetPivot().Position
	if promptPos then
		local dp1=(promptPos-pos1).Magnitude
		local dp2=(promptPos-pos2).Magnitude
		if dp1>150 and dp2>150 then return end
	end
	local r=getRoot() if not r then return end
	if _stealingCFrame then return end
	IsStealing=true
	task.spawn(function()
		equipCarpet()
		local d1=(r.Position-pos1).Magnitude local d2=(r.Position-pos2).Magnitude
		local targetPos = d1<d2 and pos1 or pos2
		r.CFrame = CFrame.new(targetPos)
		if _G.AutoPotion then
			local bp=plr:FindFirstChild("Backpack")
			if bp then local pot=bp:FindFirstChild("Giant Potion") if pot and getHum() then getHum():EquipTool(pot) task.wait(0.1) pcall(function() pot:Activate() end) end end
		end
		local a, prompt
		for i=1,20 do
			a=nearestAnimal()
			prompt=a and findPrompt(a)
			if prompt then break end
			RunService.Heartbeat:Wait()
		end
		pcall(function() if fireproximityprompt and prompt then fireproximityprompt(prompt) end end)
		local r2=getRoot()
		if r2 then
			local dd1=(r2.Position-pos1).Magnitude local dd2=(r2.Position-pos2).Magnitude
			r2.CFrame=CFrame.new(dd1<dd2 and pos1 or pos2)
		end
		isHold=false
		IsStealing=false
	end)
end)
local function scanPlot(plot)
	if not plot or not plot:IsA("Model") or isMyBase(plot.Name) then return end
	local pods=plot:FindFirstChild("AnimalPodiums") if not pods then return end
	for _,pod in ipairs(pods:GetChildren()) do
		if pod:IsA("Model") and pod:FindFirstChild("Base") then
			table.insert(animals,{plot=plot.Name,slot=pod.Name,pos=pod:GetPivot().Position,uid=plot.Name.."_"..pod.Name})
		end
	end
end
local function initScanner()
	task.wait(2)
	local plots=workspace:WaitForChild("Plots",10)
	if not plots then return end
	for _,p in ipairs(plots:GetChildren()) do scanPlot(p) end
	plots.ChildAdded:Connect(scanPlot)
	task.spawn(function()
		while task.wait(5) do
			table.clear(animals)
			local currentPlots=workspace:FindFirstChild("Plots")
			if currentPlots then
				for _,p in ipairs(currentPlots:GetChildren()) do scanPlot(p) end
			end
		end
	end)
end
local function findPrompt(a)
	local c=promptCache[a.uid] if c and c.Parent then return c end
	local plot=workspace.Plots:FindFirstChild(a.plot)
	local pod=plot and plot.AnimalPodiums:FindFirstChild(a.slot)
	local pr=pod and pod.Base.Spawn.PromptAttachment:FindFirstChildOfClass("ProximityPrompt")
	if pr then promptCache[a.uid]=pr end
	return pr
end

-- Système cache amélioré (scan en avance)
local allAnimalsCache = {}

local function scanSinglePlot(plot)
	local pName = plot.Name
	local podiums = plot:FindFirstChild("AnimalPodiums")
	if not podiums then return end
	for _, pod in ipairs(podiums:GetChildren()) do
		local base = pod:FindFirstChild("Base")
		local spawn = base and base:FindFirstChild("Spawn")
		local att = spawn and spawn:FindFirstChild("PromptAttachment")
		local pr = att and att:FindFirstChildOfClass("ProximityPrompt")
		if pr and pr.ActionText == "Steal" then
			local worldPos = spawn.Position
			table.insert(allAnimalsCache, {
				uid = pName .. "_" .. pod.Name,
				plot = pName,
				slot = pod.Name,
				worldPosition = worldPos,
				prompt = pr,
			})
		end
	end
end

-- Scanner init (tourne en parallèle)
task.spawn(function()
	task.wait(2)
	local plots = workspace:WaitForChild("Plots", 10)
	if not plots then return end
	for _, plot in ipairs(plots:GetChildren()) do
		pcall(scanSinglePlot, plot)
	end
	plots.ChildAdded:Connect(function(plot) pcall(scanSinglePlot, plot) end)
	-- Refresh toutes les 5s
	task.spawn(function()
		while task.wait(5) do
			table.clear(allAnimalsCache)
			table.clear(promptCache)
			for _, plot in ipairs(plots:GetChildren()) do
				pcall(scanSinglePlot, plot)
			end
		end
	end)
end)

local function nearestAnimal()
	local r=getRoot() if not r then return nil end
	local n,d=nil,math.huge
	-- Priorité au cache amélioré
	if #allAnimalsCache > 0 then
		for _, a in ipairs(allAnimalsCache) do
			if a.worldPosition then
				local dist=(r.Position - a.worldPosition).Magnitude
				if dist < d then d=dist n=a end
			end
		end
		if n then return n end
	end
	-- Fallback sur l'ancien système
	for _,a in ipairs(animals) do
		local dist=(r.Position-a.pos).Magnitude
		if dist<d and dist<=RADIUS then d=dist n=a end
	end
	return n
end

local function findBestPrompt()
	local a = nearestAnimal()
	if not a then return nil end
	-- Si l'animal vient du cache amélioré, utiliser le prompt direct
	if a.prompt and a.prompt.Parent then return a.prompt end
	return findPrompt(a)
end
local function useGiantPotion()
	if _G.AutoPotion then
		local c = plr.Character
		local bp = plr:FindFirstChild("Backpack")
		if not c or not bp then return end
		local pot = bp:FindFirstChild("Giant Potion")
		if not pot then return end
		pot.Parent = c
		pcall(function() pot:Activate() end)
		_G.PotionActive = true
		task.spawn(function()
			task.wait(0.15)
			local hum = c:FindFirstChildOfClass("Humanoid")
			if hum then hum:UnequipTools() end
			if pot and pot.Parent == c then pot.Parent = bp end
			task.wait(5)
			_G.PotionActive = false
		end)
	end
end


-- =============================================
-- INJECTION FUN_HUB SEMI TP : helpers + Teleport()
-- =============================================
local _funHub = {}

-- FFlags du fun_hub
local _fflags = {
	GameNetPVHeaderRotationalVelocityZeroCutoffExponent = -5000,
	LargeReplicatorWrite5 = true,
	LargeReplicatorEnabled9 = true,
	AngularVelociryLimit = 360,
	TimestepArbiterVelocityCriteriaThresholdTwoDt = 2147483646,
	S2PhysicsSenderRate = 15000,
	DisableDPIScale = true,
	MaxDataPacketPerSend = 2147483647,
	PhysicsSenderMaxBandwidthBps = 20000,
	TimestepArbiterHumanoidLinearVelThreshold = 21,
	MaxMissedWorldStepsRemembered = -2147483648,
	PlayerHumanoidPropertyUpdateRestrict = true,
	SimDefaultHumanoidTimestepMultiplier = 0,
	StreamJobNOUVolumeLengthCap = 2147483647,
	DebugSendDistInSteps = -2147483648,
	GameNetDontSendRedundantNumTimes = 1,
	CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent = 1,
	CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth = 1,
	LargeReplicatorSerializeRead3 = true,
	ReplicationFocusNouExtentsSizeCutoffForPauseStuds = 2147483647,
	CheckPVCachedVelThresholdPercent = 10,
	CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth = 1,
	GameNetDontSendRedundantDeltaPositionMillionth = 1,
	InterpolationFrameVelocityThresholdMillionth = 5,
	StreamJobNOUVolumeCap = 2147483647,
	InterpolationFrameRotVelocityThresholdMillionth = 5,
	CheckPVCachedRotVelThresholdPercent = 10,
	WorldStepMax = 30,
	InterpolationFramePositionThresholdMillionth = 5,
	TimestepArbiterHumanoidTurningVelThreshold = 1,
	SimOwnedNOUCountThresholdMillionth = 2147483647,
	GameNetPVHeaderLinearVelocityZeroCutoffExponent = -5000,
	NextGenReplicatorEnabledWrite4 = true,
	TimestepArbiterOmegaThou = 1073741823,
	MaxAcceptableUpdateDelay = 1,
	LargeReplicatorSerializeWrite4 = true
}

local function _setfflags()
	for k, v in pairs(_fflags) do
		pcall(function()
			if setfflag then setfflag(k, tostring(v)) end
		end)
	end
end

local function _teleportHRP(position)
	local character = plr.Character or plr.CharacterAdded:Wait()
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end
	hrp.AssemblyLinearVelocity = Vector3.zero
	hrp.CFrame = CFrame.new(position)
end

local function _equipGrappleForTP()
	local char = plr.Character
	local backpack = plr:FindFirstChild("Backpack")
	if not char or not backpack then return end
	for _, tool in ipairs(char:GetChildren()) do
		if tool:IsA("Tool") then
			tool.Parent = backpack
		end
	end
	local carpet = backpack:FindFirstChild("Flying Carpet")
	if carpet then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then hum:EquipTool(carpet) end
	end
end

local function _getMyPlot()
	local ok, PlotController = pcall(require, game.ReplicatedStorage.Controllers.PlotController)
	if ok and PlotController then
		local ok2, myPlot = pcall(function() return PlotController:GetMyPlot().PlotModel end)
		if ok2 then return myPlot end
	end
	return nil
end

local function _runStealLogic()
	local function g() return plr.Character or plr.CharacterAdded:Wait() end
	local function h() return g():WaitForChild("HumanoidRootPart", 5) end
	local j = h()
	local function m(n)
		local o = n.Parent
		if o:IsA("BasePart") then return o end
		if o:IsA("Model") then return o.PrimaryPart or o:FindFirstChildWhichIsA("BasePart") end
		if o:IsA("Attachment") then return o.Parent end
		return o:FindFirstChildWhichIsA("BasePart", true)
	end
	local function p()
		local q, r = nil, math.huge
		local s = workspace:FindFirstChild("Plots")
		if not s then return nil end
		for _, t in pairs(s:GetDescendants()) do
			if t:IsA("ProximityPrompt") and t.Enabled and t.ActionText == "Steal" then
				local u = m(t)
				if u then
					local v = (j.Position - u.Position).Magnitude
					if v < r then r = v; q = t end
				end
			end
		end
		return q
	end
	local function w(x)
		if not x or not x:IsDescendantOf(workspace) then return end
		x.MaxActivationDistance = 9e9
		x.RequiresLineOfSight = false
		x.ClickablePrompt = true
		-- Spam 12 fois avec les 2 méthodes pour garantir le grab avec Giant Potion
		for i = 1, 12 do
			pcall(function() fireproximityprompt(x, 9e9, 0.01) end)
			pcall(function()
				x:InputHoldBegin()
				task.wait(0.01)
				x:InputHoldEnd()
			end)
			task.wait(0.04)
		end
	end
	-- Cherche le prompt jusqu'à 15 fois
	local z
	for i = 1, 15 do
		z = p()
		if z then break end
		task.wait(0.05)
	end
	if z then w(z) end
end

-- Fonction Teleport (semi TP) extraite du fun_hub
local _funhubDebounce = false
local function _funhubTeleport()
	if _funhubDebounce then return end
	_funhubDebounce = true

	local MyPlot = _getMyPlot()
	if not MyPlot then
		_funhubDebounce = false
		return
	end

	-- setfflags x10 (sans le système Auto Giant Potion / Auto Grabber qui dépend du fun_hub)
	for i = 1, 10 do
		_setfflags()
	end

	local char = plr.Character
	if not char then _funhubDebounce = false return end
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then _funhubDebounce = false return end

	if MyPlot:GetAttribute("Order") == 2 then
		_equipGrappleForTP()
		hrp.CFrame = MyPlot.Spawn.CFrame
		task.wait(0.11)
		_teleportHRP(Vector3.new(-368.18, -6.97, 69.17))
		task.wait(0.11)
		_teleportHRP(Vector3.new(-335.650, -5.103, 100.070))
		task.wait(0.11)
		_teleportHRP(Vector3.new(-351.980, -7.002, 75.540))
		-- Giant Potion seulement si toggle activé
		if _G.AutoPotion then
			local bp = plr:FindFirstChild("Backpack")
			local potion = bp and bp:FindFirstChild("Giant Potion")
			if potion then
				potion.Parent = plr.Character
				pcall(function() potion:Activate() end)
				-- Attendre que le joueur soit réellement géant (vérifier le scale)
				local waited = 0
				repeat
					task.wait(0.1)
					waited = waited + 0.1
					local char = plr.Character
					local scale = char and char:FindFirstChild("BodyHeightScale")
					if scale and scale.Value > 1.5 then break end
				until waited >= 2
			end
		end
		_runStealLogic()
		_equipGrappleForTP()
		hrp.CFrame = MyPlot.Spawn.CFrame
		task.wait(0.11)
		_teleportHRP(Vector3.new(-368.18, -7.02, 42.17))
		task.wait(0.11)
		_teleportHRP(Vector3.new(-336.110, -5.037, 19.840))
		task.wait(0.11)
		_teleportHRP(Vector3.new(-352.860, -7.002, 44.180))
		-- Giant Potion seulement si toggle activé
		if _G.AutoPotion then
			local bp = plr:FindFirstChild("Backpack")
			local potion = bp and bp:FindFirstChild("Giant Potion")
			if potion then
				potion.Parent = plr.Character
				pcall(function() potion:Activate() end)
				-- Attendre que le joueur soit réellement géant
				local waited = 0
				repeat
					task.wait(0.1)
					waited = waited + 0.1
					local char = plr.Character
					local scale = char and char:FindFirstChild("BodyHeightScale")
					if scale and scale.Value > 1.5 then break end
				until waited >= 2
			end
		end
		_runStealLogic()
	end

	task.delay(1.5, function() _funhubDebounce = false end)
end

-- Expose globalement pour que les boutons puissent l'appeler
_G.NostalgiaaSemiTP = _funhubTeleport
-- =============================================

local function steal(seq)
	if IsStealing then return end
	IsStealing=true StealProgress=0
	task.spawn(function()
		local outerPrompt = nil
		pcall(function()
			local t=tick() local done=false
			while tick()-t<1.3 do
				StealProgress=(tick()-t)/1.3
				if StealProgress>=0.73 and not done then
					done=true
					local r=getRoot()
					if r then
						_stealingCFrame=true
						equipCarpet()
						r.CFrame = seq[1]
						task.wait(0.1)
						r.CFrame = seq[2]
						task.wait(0.2)
						local a, prompt
						for i=1,12 do
							a=nearestAnimal()
							prompt=a and findPrompt(a)
							if prompt then break end
							task.wait(0.08)
						end
						outerPrompt = prompt
						local r2=getRoot()
						if r2 then
							local d1=(r2.Position-pos1).Magnitude
							local d2=(r2.Position-pos2).Magnitude
							r2.CFrame=CFrame.new(d1<d2 and pos1 or pos2)
						end
						_stealingCFrame=false
					end
				end
				task.wait(0.02)
			end
			StealProgress=1
			-- Grab amélioré : logique instaFirePrompt (fireproximityprompt + InputHoldBegin)
			if _G.AutoPotion then task.spawn(useGiantPotion) end
			if outerPrompt and outerPrompt.Parent then
				task.spawn(function()
					pcall(function()
						fireproximityprompt(outerPrompt, 10000)
						outerPrompt:InputHoldBegin()
						task.wait(0.04)
						outerPrompt:InputHoldEnd()
					end)
				end)
			end
			task.wait(0.010)
			_G._spamEvent:Fire()
			task.wait(0.2)
			_G._tpDoneEvent:Fire()
		end)
		_stealingCFrame=false
		IsStealing=false StealProgress=0
	end)
end

local function stealInstant(seq)
	if IsStealing then return end
	IsStealing=true StealProgress=0
	task.spawn(function()
		local outerPrompt = nil
		pcall(function()
			local r=getRoot()
			if r then
				_stealingCFrame=true
				equipCarpet()
				r.CFrame=seq[1]
				r.CFrame=seq[2]
				task.wait(0.2)
				local a, prompt
				for i=1,12 do
					a=nearestAnimal()
					prompt=a and findPrompt(a)
					if prompt then break end
					task.wait(0.08)
				end
				outerPrompt = prompt
				local r2=getRoot()
				if r2 then
					local d1=(r2.Position-pos1).Magnitude local d2=(r2.Position-pos2).Magnitude
					r2.CFrame=CFrame.new(d1<d2 and pos1 or pos2)
				end
				_stealingCFrame=false
			end
			StealProgress=1
			if _G.AutoPotion then task.spawn(useGiantPotion) end
			if outerPrompt and outerPrompt.Parent then
				task.spawn(function()
					pcall(function()
						fireproximityprompt(outerPrompt, 10000)
						outerPrompt:InputHoldBegin()
						task.wait(0.04)
						outerPrompt:InputHoldEnd()
					end)
				end)
			end
			task.wait(0.010)
			_G._spamEvent:Fire()
			task.wait(0.2)
			_G._tpDoneEvent:Fire()
		end)
		_stealingCFrame=false
		IsStealing=false StealProgress=0
	end)
end
local function doStartFull()
	if IsStealing then return end
	IsStealing = true
	StealProgress = 0

	task.spawn(function()
		pcall(function()
			local base = _G._getCachedBase and _G._getCachedBase() or "left"
			local seq = base == "left" and s1 or s2

			local t = tick()
			local done = false

			while tick() - t < 1.3 do
				StealProgress = (tick() - t) / 1.3

				if StealProgress >= 0.73 and not done then
					done = true

					local r = getRoot()
					if r then
						equipCarpet()
						task.wait(0.05)

						if base == "left" then
							r.CFrame = CFrame.new(-352.858124,-7.210645,114.063774,0.015708,0,0.999877,0,1,0,-0.999877,0,0.015708)
						else
							r.CFrame = CFrame.new(-352.831604,-7.171166,7.104904,0.011781,0,0.999931,0,1,0,-0.999931,0,0.011781)
						end

						RunService.Heartbeat:Wait()
						RunService.Heartbeat:Wait()
						task.wait(0.05)

						local r2
						for i = 1, 10 do
							r2 = getRoot()
							if r2 then break end
							RunService.Heartbeat:Wait()
						end

						if r2 then
							equipCarpet()
							task.wait(0.08)

							r2.CFrame = seq[1]

							RunService.Heartbeat:Wait()
							RunService.Heartbeat:Wait()
							task.wait(0.1)

							local r3
							for i = 1, 5 do
								r3 = getRoot()
								if r3 then break end
								RunService.Heartbeat:Wait()
							end

							if r3 then
								r3.CFrame = seq[2]
							end

							RunService.Heartbeat:Wait()
							task.wait(0.05)

							task.wait(0.1)

							local a, prompt
							for i = 1, 8 do
								a = nearestAnimal()
								prompt = a and findPrompt(a)
								if prompt then break end
								task.wait(0.08)
							end

							removeSpeedAnti()

							-- AUTO GRAB AMÉLIORÉ : cache scanner + retry + spam + patch distance
							local bestPrompt = nil
							for i = 1, 20 do
								bestPrompt = findBestPrompt()
								if bestPrompt then break end
								task.wait(0.05)
							end

							if bestPrompt then
								-- Patch distance pour grab de loin
								pcall(function() bestPrompt.MaxActivationDistance = 9e9 end)
								pcall(function() bestPrompt.RequiresLineOfSight = false end)
								-- Spam 8 fois pour garantir le grab
								for i = 1, 8 do
									if fireproximityprompt then
										pcall(function() fireproximityprompt(bestPrompt) end)
									else
										pcall(function() bestPrompt:InputHoldBegin() end)
										task.wait(0.01)
										pcall(function() bestPrompt:InputHoldEnd() end)
									end
									task.wait(0.03)
								end
							end

							task.wait(0.12)

							local r4 = getRoot()
							if r4 then
								local d1 = (r4.Position - pos1).Magnitude
								local d2 = (r4.Position - pos2).Magnitude
								local target = (d1 < d2 and pos1 or pos2)
								-- Reset velocity avant TP pour éviter le tremblement
								r4.AssemblyLinearVelocity = Vector3.zero
								r4.AssemblyAngularVelocity = Vector3.zero
								r4.CFrame = CFrame.new(target)

								if speedAntiOn then
									applySpeedAnti()
								end

								if _G.AutoPotion then
									useGiantPotion()
								end
							end
						end
					end
				end

				task.wait(0.02)
			end

			StealProgress = 1
			task.wait(0.01)

			if _G._spamEvent then
				_G._spamEvent:Fire()
			end

			task.wait(0.2)

			if _G._tpDoneEvent then
				_G._tpDoneEvent:Fire()
			end
		end)

		IsStealing = false
		StealProgress = 0
	end)
end


PPS.PromptTriggered:Connect(function(prompt, player)
	if player ~= plr then return end

	if not prompt.ActionText or not string.find(string.lower(prompt.ActionText), "steal") then return end

	local r = getRoot()
	if not r then return end

	equipCarpet()

	local d1 = (r.Position - pos1).Magnitude
	local d2 = (r.Position - pos2).Magnitude
	local target = (d1 < d2 and pos1 or pos2)

	for i = 1, 6 do
		r.CFrame = CFrame.new(target)
		RunService.Heartbeat:Wait()
	end

	if speedAntiOn then applySpeedAnti() end

	if _G.AutoPotion then
		useGiantPotion()
	end
end)
local executeFull2Btn = mkBtn("Execute Full", UDim2.new(0,8,0,0), Color3.fromRGB(90,40,180))
executeFull2Btn.MouseButton1Click:Connect(function()
	executeFull2Btn.Text = "Executing..."
	task.spawn(doStartFull)
	task.delay(2, function()
		if executeFull2Btn and executeFull2Btn.Parent then
			executeFull2Btn.Text = "Execute Full"
		end
	end)
end)

minBtn.MouseButton1Click:Connect(function()
	minimized=not minimized
	if minimized then
		minBtn.Text="+"
		content.Visible=false
		executeBtn.Parent=mf
		executeBtn.Position=UDim2.new(0,10,0,MINI_H+6)
		executeBtn.Size=UDim2.new(1,-20,0,38)
		executeFull2Btn.Parent=mf
		executeFull2Btn.Position=UDim2.new(0,10,0,MINI_H+50)
		executeFull2Btn.Size=UDim2.new(1,-20,0,34)
		mf.Size=UDim2.new(0,200,0,MINI_H+90)
	else
		minBtn.Text="-"
		executeBtn.Parent=content
		executeBtn.Size=UDim2.new(1,0,0,38)
		executeFull2Btn.Parent=content
		executeFull2Btn.Size=UDim2.new(1,0,0,34)
		content.Visible=true
		mf.Size=UDim2.new(0,200,0,FULL_H)
	end
end)
local function doLeft()
	local r=getRoot() if not r then return end
	steal(s1)
end
local function doRight()
	local r=getRoot() if not r then return end
	steal(s2)
end
local cachedBase = nil
local function detectAndCache()
	local plots=workspace:FindFirstChild("Plots")
	if not plots then
		return
	end
	if not plots:GetChildren() then
		return
	end
	for _,plot in ipairs(plots:GetChildren()) do
		local s=plot:FindFirstChild("PlotSign")
		if s and s:FindFirstChild("YourBase") and s.YourBase.Enabled then
			local plotPos=plot:GetPivot().Position
			local d1=(plotPos-pos1).Magnitude
			local d2=(plotPos-pos2).Magnitude
			cachedBase = d1<d2 and "left" or "right"
			return
		end
	end
end
local function detectBase()
	if cachedBase then return cachedBase end
	detectAndCache()
	return cachedBase or "left"
end
task.spawn(function() task.wait(2) detectAndCache() end)
plr.CharacterAdded:Connect(function()
	cachedBase=nil
	task.wait(1)
	detectAndCache()
end)
local function doStart()
	local base=cachedBase or detectBase()
	if base=="left" then
		doLeft()
	else
		doRight()
	end
end
_G._doStart = doStart
_G._getCachedBase = function() return cachedBase or detectBase() end
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode==Enum.KeyCode.F then
		task.spawn(doStart)
	end
end)
RunService.Heartbeat:Connect(function()
	if math.abs(StealProgress - _lastBarProgress) > 0.01 then
		_lastBarProgress = StealProgress
		fill.Size = UDim2.new(StealProgress, 0, 1, 0)
	end
end)
task.spawn(initScanner)
task.spawn(function() task.wait(0.1)
	local function mkESPToggle(txt,ypos,saveKey,cb)
		local cont=Instance.new("Frame")
		cont.Size=UDim2.new(1,0,0,42)
		cont.BackgroundColor3=C_ROW
		cont.BackgroundTransparency=0.25
		cont.BorderSizePixel=0 cont.Parent=espCont
		Instance.new("UICorner",cont).CornerRadius=UDim.new(0,12)
		local lbl2=Instance.new("TextLabel")
		lbl2.Size=UDim2.new(1,-64,1,0) lbl2.Position=UDim2.new(0,14,0,0)
		lbl2.BackgroundTransparency=1 lbl2.Text=txt
		lbl2.TextColor3=C_WHITE lbl2.TextSize=13
		lbl2.Font=Enum.Font.GothamBold lbl2.TextXAlignment=Enum.TextXAlignment.Left
		lbl2.ZIndex=2 lbl2.Parent=cont
		local pill3=Instance.new("Frame")
		pill3.Size=UDim2.new(0,46,0,26) pill3.Position=UDim2.new(1,-54,0.5,-13)
		pill3.BackgroundColor3=C_PILLOFF pill3.BorderSizePixel=0 pill3.ZIndex=2 pill3.Parent=cont
		Instance.new("UICorner",pill3).CornerRadius=UDim.new(1,0)
		local dot3=Instance.new("Frame")
		dot3.Size=UDim2.new(0,20,0,20) dot3.Position=UDim2.new(0,3,0.5,-10)
		dot3.BackgroundColor3=C_GREY dot3.BorderSizePixel=0 dot3.ZIndex=3 dot3.Parent=pill3
		Instance.new("UICorner",dot3).CornerRadius=UDim.new(1,0)
		local on = Save[saveKey] or false
		if on then
			pill3.BackgroundColor3=C_PURPLE
			dot3.Position=UDim2.new(1,-23,0.5,-10)
			dot3.BackgroundColor3=C_WHITE
			task.spawn(function() cb(true) end)
		end
		local ca3=Instance.new("TextButton")
		ca3.Size=UDim2.new(1,0,1,0) ca3.BackgroundTransparency=1 ca3.Text="" ca3.ZIndex=10 ca3.Parent=cont
		ca3.MouseButton1Click:Connect(function()
			on=not on
			Save[saveKey]=on
			saveConfig()
			TweenService:Create(dot3,TweenInfo.new(0.12),{Position=on and UDim2.new(1,-23,0.5,-10) or UDim2.new(0,3,0.5,-10)}):Play()
			TweenService:Create(pill3,TweenInfo.new(0.12),{BackgroundColor3=on and C_PURPLE or C_PILLOFF}):Play()
			TweenService:Create(dot3,TweenInfo.new(0.12),{BackgroundColor3=on and C_WHITE or C_GREY}):Play()
			cb(on)
		end)
	end
	local playerESPConns={}
	local playerHL={}
	local rainbowConn=nil
	local rainbowHue=0
	mkESPToggle("Player ESP",4,"espPlayer",function(enabled)
		if enabled then
			rainbowConn=true
			task.spawn(function()
				while rainbowConn do
					rainbowHue=(rainbowHue+6)%360
					local c=Color3.fromHSV(rainbowHue/360,1,1)
					for _,hl in pairs(playerHL) do
						if hl and hl.Parent then
							hl.FillColor=c
							hl.OutlineColor=c
						end
					end
					task.wait(0.1)
				end
			end)
			local function addESP(p)
				if p==plr then return end
				local function onChar(char)
					task.wait(0.3)
					if playerHL[p] then pcall(function() playerHL[p]:Destroy() end) end
					local hl=Instance.new("Highlight")
					hl.FillTransparency=0.5
					hl.OutlineTransparency=0
					hl.Adornee=char hl.Parent=char
					playerHL[p]=hl
					local head=char:FindFirstChild("Head")
					if head then
						local bb=Instance.new("BillboardGui")
						bb.Name="ESPPlayerName" bb.Size=UDim2.new(0,100,0,30)
						bb.StudsOffset=Vector3.new(0,2.5,0)
						bb.AlwaysOnTop=true bb.Adornee=head bb.Parent=char
						local nl=Instance.new("TextLabel")
						nl.Size=UDim2.new(1,0,1,0) nl.BackgroundTransparency=1
						nl.Text=p.Name nl.TextSize=12 nl.Font=Enum.Font.GothamBold
						nl.TextStrokeTransparency=0 nl.TextColor3=C_WHITE nl.Parent=bb
					end
				end
				if p.Character then onChar(p.Character) end
				local cc=p.CharacterAdded:Connect(onChar)
				playerESPConns[p]=cc
			end
			for _,p in ipairs(Players:GetPlayers()) do addESP(p) end
			playerESPConns["added"]=Players.PlayerAdded:Connect(addESP)
		else
			if rainbowConn then rainbowConn=nil end
			for _,cc in pairs(playerESPConns) do pcall(function() cc:Disconnect() end) end
			playerESPConns={}
			for _,hl in pairs(playerHL) do pcall(function() if hl and hl.Parent then hl:Destroy() end end) end
			playerHL={}
			for _,p in ipairs(Players:GetPlayers()) do
				if p.Character then
					local bb=p.Character:FindFirstChild("ESPPlayerName")
					if bb then bb:Destroy() end
					for _,d in ipairs(p.Character:GetDescendants()) do
						if d:IsA("Highlight") then d:Destroy() end
					end
				end
			end
		end
	end)
	local brainrotESPConn=nil
	local brainrotESPActive=false
	local brainrotHL={}
	mkESPToggle("Brainrot ESP",44,"espBrainrot",function(enabled)
		if enabled then
			brainrotESPActive=true
			local function scanBrainrots()
				local plots=workspace:FindFirstChild("Plots")
				if not plots or not plots:GetChildren() then return end
				for _,plot in ipairs(plots:GetChildren()) do
					if plot:IsA("Model") then
						for _,br in ipairs(plot:GetChildren()) do
							if br:IsA("Model") and br:FindFirstChildOfClass("Humanoid") and not brainrotHL[br] then
								local hl=Instance.new("Highlight")
								hl.FillColor=Color3.fromRGB(255,0,0)
								hl.OutlineColor=Color3.fromRGB(255,100,100)
								hl.FillTransparency=0.6 hl.OutlineTransparency=0.2
								hl.Adornee=br hl.Parent=br
								brainrotHL[br]=hl
								local pp=br.PrimaryPart or br:FindFirstChildWhichIsA("BasePart")
								if pp then
									local bb=Instance.new("BillboardGui")
									bb.Name="ESPBrainrotName" bb.Size=UDim2.new(0,120,0,30)
									bb.StudsOffset=Vector3.new(0,3,0)
									bb.AlwaysOnTop=true bb.Adornee=pp bb.Parent=br
									local nl=Instance.new("TextLabel")
									nl.Size=UDim2.new(1,0,1,0) nl.BackgroundTransparency=1
									nl.Text=br.Name nl.TextColor3=Color3.fromRGB(255,255,255)
									nl.TextSize=11 nl.Font=Enum.Font.GothamBold
									nl.TextStrokeTransparency=0 nl.Parent=bb
								end
							end
						end
					end
				end
			end
			brainrotESPConn=task.spawn(function()
				while task.wait(2) do
					if not brainrotESPActive then break end
					pcall(scanBrainrots)
				end
			end)
		else
			brainrotESPActive=false
			brainrotESPConn=nil
			for br,hl in pairs(brainrotHL) do
				pcall(function()
					if hl and hl.Parent then hl:Destroy() end
					local bb=br:FindFirstChild("ESPBrainrotName")
					if bb then bb:Destroy() end
				end)
			end
			brainrotHL={}
		end
	end)
	local baseEspInstances={}
	local baseEspThread=nil
	local function createBaseESP(plot, mainPart)
		local key=plot.Name
		if baseEspInstances[key] then
			baseEspInstances[key]:Destroy()
		end
		local bb=Instance.new("BillboardGui")
		bb.Name="AntiScamBaseESP_"..key
		bb.Size=UDim2.new(0,70,0,30)
		bb.StudsOffset=Vector3.new(0,5,0)
		bb.AlwaysOnTop=true
		bb.Adornee=mainPart
		bb.MaxDistance=1000
		bb.Parent=plot
		local label=Instance.new("TextLabel")
		label.Size=UDim2.new(1,0,1,0)
		label.BackgroundTransparency=1
		label.TextScaled=true
		label.Font=Enum.Font.GothamBlack
		label.TextColor3=Color3.fromRGB(255,255,0)
		label.TextStrokeTransparency=0
		label.TextStrokeColor3=Color3.new(0,0,0)
		label.Parent=bb
		baseEspInstances[key]=bb
		return bb
	end
	local function updateBaseESP()
		local plots=workspace:FindFirstChild("Plots")
		if not plots then return end
		for _,plot in ipairs(plots:GetChildren()) do
			local purchases=plot:FindFirstChild("Purchases")
			local plotBlock=purchases and purchases:FindFirstChild("PlotBlock")
			local mainPart=plotBlock and plotBlock:FindFirstChild("Main")
			local key=plot.Name
			local bb=baseEspInstances[key]
			local timeLabel=mainPart
				and mainPart:FindFirstChild("BillboardGui")
				and mainPart.BillboardGui:FindFirstChild("RemainingTime")
			if timeLabel and mainPart then
				bb=bb or createBaseESP(plot,mainPart)
				local label=bb:FindFirstChildWhichIsA("TextLabel")
				if label then
					label.Text=timeLabel.Text
				end
			elseif bb then
				bb:Destroy()
				baseEspInstances[key]=nil
			end
		end
	end
	mkESPToggle("Base ESP",84,"espBase",function(enabled)
		if enabled then
			baseEspThread=true
			task.spawn(function()
				while baseEspThread do
					pcall(updateBaseESP)
					task.wait(1)
				end
			end)
		else
			baseEspThread=nil
			for key,bb in pairs(baseEspInstances) do
				pcall(function() if bb and bb.Parent then bb:Destroy() end end)
				baseEspInstances[key]=nil
			end
		end
	end)
	local friendEspInstances={}
	local friendEspEnabled=false
	local function createFriendESP(fp, mainPart)
		local key=fp:GetDebugId()
		if friendEspInstances[key] then
			friendEspInstances[key]:Destroy()
		end
		local bb=Instance.new("BillboardGui")
		bb.Name="FriendESP_"..key
		bb.Size=UDim2.new(0,130,0,38)
		bb.StudsOffset=Vector3.new(0,5,0)
		bb.AlwaysOnTop=true
		bb.Adornee=mainPart
		bb.MaxDistance=1000
		bb.Parent=fp
		local badge=Instance.new("Frame")
		badge.Name="Badge"
		badge.Size=UDim2.new(1,0,1,0)
		badge.BackgroundColor3=Color3.fromRGB(15,15,15)
		badge.BackgroundTransparency=0.15
		badge.BorderSizePixel=0
		badge.Parent=bb
		Instance.new("UICorner",badge).CornerRadius=UDim.new(0,8)
		local stroke=Instance.new("UIStroke",badge)
		stroke.Name="BadgeStroke"
		stroke.Thickness=2
		stroke.Color=Color3.fromRGB(140,0,255)
		local icon=Instance.new("TextLabel")
		icon.Name="Icon"
		icon.Size=UDim2.new(0,28,1,0)
		icon.Position=UDim2.new(0,4,0,0)
		icon.BackgroundTransparency=1
		icon.Text="🔒"
		icon.TextColor3=Color3.fromRGB(255,80,80)
		icon.TextSize=20
		icon.Font=Enum.Font.GothamBlack
		icon.TextXAlignment=Enum.TextXAlignment.Center
		icon.TextStrokeTransparency=0
		icon.TextStrokeColor3=Color3.fromRGB(0,0,0)
		icon.Parent=badge
		local label=Instance.new("TextLabel")
		label.Name="StatusLabel"
		label.Size=UDim2.new(1,-36,1,0)
		label.Position=UDim2.new(0,34,0,0)
		label.BackgroundTransparency=1
		label.Text="DISALLOWED"
		label.TextColor3=Color3.fromRGB(255,80,80)
		label.TextSize=13
		label.Font=Enum.Font.GothamBlack
		label.TextXAlignment=Enum.TextXAlignment.Left
		label.TextStrokeTransparency=0
		label.TextStrokeColor3=Color3.fromRGB(0,0,0)
		label.Parent=badge
		friendEspInstances[key]=bb
		return bb
	end
	local function updateFriendESP()
		local plots=workspace:FindFirstChild("Plots")
		if not plots then return end
		local cam=workspace.CurrentCamera
		local root=getRoot()
		for _,plot in ipairs(plots:GetChildren()) do
			if not plot:IsA("Model") then continue end
			for _,fp in ipairs(plot:GetDescendants()) do
				if not (fp:IsA("Model") and fp.Name=="FriendPanel") then continue end
				local main=fp:FindFirstChild("Main") or fp:FindFirstChildWhichIsA("BasePart")
				if not main then continue end
				if root and (cam.CFrame.Position-main.Position).Magnitude>300 then continue end
				local prompt
				prompt=fp:FindFirstChildWhichIsA("ProximityPrompt",true)
				local key=fp:GetDebugId()
				local bb=friendEspInstances[key]
				if prompt and main then
					bb=bb or createFriendESP(fp,main)
					local badge=bb:FindFirstChild("Badge")
					if badge then
						local icon=badge:FindFirstChild("Icon")
						local label=badge:FindFirstChild("StatusLabel")
						local stroke=badge:FindFirstChild("BadgeStroke")
						local objectText=prompt.ObjectText or ""
						if objectText:lower():find("disallow") then
							if label then label.Text="ALLOWED" label.TextColor3=Color3.fromRGB(80,255,120) end
							if icon  then icon.Text="🔓" icon.TextColor3=Color3.fromRGB(80,255,120) end
							if stroke then stroke.Color=Color3.fromRGB(80,255,120) end
							badge.BackgroundColor3=Color3.fromRGB(10,30,15)
						else
							if label then label.Text="DISALLOWED" label.TextColor3=Color3.fromRGB(255,80,80) end
							if icon  then icon.Text="🔒" icon.TextColor3=Color3.fromRGB(255,80,80) end
							if stroke then stroke.Color=Color3.fromRGB(140,0,255) end
							badge.BackgroundColor3=Color3.fromRGB(30,10,10)
						end
					end
				elseif bb then
					bb:Destroy()
					friendEspInstances[key]=nil
				end
			end
		end
	end
	mkESPToggle("Allow ESP",124,"espAllow",function(enabled)
		friendEspEnabled=enabled
		if enabled then
			pcall(updateFriendESP)
			task.spawn(function()
				while task.wait(1) and friendEspEnabled do
					pcall(updateFriendESP)
				end
			end)
		else
			for key,bb in pairs(friendEspInstances) do
				pcall(function() if bb and bb.Parent then bb:Destroy() end end)
				friendEspInstances[key]=nil
			end
		end
	end)
end)
task.spawn(function() task.wait(0.1)
	local _eu      = plr
	local _TS2     = TweenService
	local _AdminRemote = nil
	local _LastPunishTime = {}
	local _comandos = {"balloon","tiny","ragdoll","morph","jumpscare","rocket","inverse","jail"}

	local function _initRemoteSystem()
		task.spawn(function()
			if not _eu.Character then _eu.CharacterAdded:Wait() end
			task.wait(1)
			
			local packages = ReplicatedStorage:FindFirstChild("Packages")
			if not packages then return end
			
			local net = packages:FindFirstChild("Net")
			if not net then return end
			
			local children = net:GetChildren()
			local byIdx = {}
			local byName = {}
			
			for i, obj in ipairs(children) do
				byIdx[i] = obj
				byName[obj.Name] = i
			end
			
			local anchorIdx = byName["RF/a0e78691-cb9b-4efc-ac08-9c06fea70059"]
			if anchorIdx then
				local actual = byIdx[anchorIdx + 1]
				if actual then
					_AdminRemote = actual
					_G._ProtAdminRemote = actual
				end
			end
		end)
	end

	local function _getClosest()
		local myChar = _eu.Character
		if not myChar then return nil end
		local hrp = myChar:FindFirstChild("HumanoidRootPart")
		if not hrp then return nil end
		local myPos = hrp.Position
		local closest, minDist = nil, math.huge
		for _, p in ipairs(Players:GetPlayers()) do
			if p ~= _eu and p.Character then
				local phrp = p.Character:FindFirstChild("HumanoidRootPart")
				if phrp then
					local dist = (phrp.Position - myPos).Magnitude
					if dist < minDist then minDist=dist closest=p end
				end
			end
		end
		return closest
	end

	local function _fireAdmin(...)
		if not _AdminRemote then return end
		local args = {...}
		pcall(function()
			_AdminRemote:InvokeServer(unpack(args))
		end)
	end

	local function _punishPlayer(target, mode)
		if not _AdminRemote then return end
		if not target or target == _eu then return end
		if not target.Character then return end
		
		local uid = target.UserId
		if _LastPunishTime[uid] and tick() - _LastPunishTime[uid] < 2 then return end
		_LastPunishTime[uid] = tick()
		
		for _, cmd in ipairs(_comandos) do
			task.spawn(_fireAdmin, "f888ee6e-c86d-46e1-93d7-0639d6635d42", target, cmd)
		end
	end

	local _spamRunning = false

	local function _doSpam()
		if _spamRunning then return end
		local alvo = _getClosest()
		if not alvo then return end
		_spamRunning = true
		task.spawn(function()
			_punishPlayer(alvo, "kick")
			_spamRunning = false
		end)
	end

	_initRemoteSystem()

	local _autoSpamOn = false

	local _selectedPlayer = nil
	local _playerBtns = {}

	local autoRow = Instance.new("Frame")
	autoRow.Size = UDim2.new(1, 0, 0, 42)
	autoRow.BackgroundColor3 = C_ROW
	autoRow.BackgroundTransparency = 0.05
	autoRow.BorderSizePixel = 0
	autoRow.LayoutOrder = 1
	autoRow.Parent = spamCont
	Instance.new("UICorner", autoRow).CornerRadius = UDim.new(0,12)
	local autoLbl = Instance.new("TextLabel")
	autoLbl.Size = UDim2.new(1, -64, 1, 0)
	autoLbl.Position = UDim2.new(0, 14, 0, 0)
	autoLbl.BackgroundTransparency = 1
	autoLbl.Text = "Auto Spam"
	autoLbl.TextColor3 = C_WHITE
	autoLbl.Font = Enum.Font.GothamBold
	autoLbl.TextSize = 13
	autoLbl.TextXAlignment = Enum.TextXAlignment.Left
	autoLbl.Parent = autoRow
	local autoPill = Instance.new("Frame")
	autoPill.Size = UDim2.new(0, 46, 0, 26)
	autoPill.Position = UDim2.new(1, -54, 0.5, -13)
	autoPill.BackgroundColor3 = C_PILLOFF
	autoPill.BorderSizePixel = 0
	autoPill.Parent = autoRow
	Instance.new("UICorner", autoPill).CornerRadius = UDim.new(1,0)
	local autoDot = Instance.new("Frame")
	autoDot.Size = UDim2.new(0, 20, 0, 20)
	autoDot.Position = UDim2.new(0, 3, 0.5, -10)
	autoDot.BackgroundColor3 = C_GREY
	autoDot.BorderSizePixel = 0
	autoDot.Parent = autoPill
	Instance.new("UICorner", autoDot).CornerRadius = UDim.new(1,0)
	local autoCa = Instance.new("TextButton")
	autoCa.Size = UDim2.new(1, 0, 1, 0)
	autoCa.BackgroundTransparency = 1
	autoCa.Text = ""
	autoCa.ZIndex = 5
	autoCa.Parent = autoRow
	autoCa.MouseButton1Click:Connect(function()
		_autoSpamOn = not _autoSpamOn
		Save.autoSpamOn = _autoSpamOn
		saveConfig()
		if _autoSpamOn then
			_TS2:Create(autoPill, TweenInfo.new(0.12), {BackgroundColor3=C_PURPLE}):Play()
			_TS2:Create(autoDot, TweenInfo.new(0.12), {Position=UDim2.new(1,-23,0.5,-10), BackgroundColor3=C_WHITE}):Play()
		else
			_TS2:Create(autoPill, TweenInfo.new(0.12), {BackgroundColor3=C_PILLOFF}):Play()
			_TS2:Create(autoDot, TweenInfo.new(0.12), {Position=UDim2.new(0,3,0.5,-10), BackgroundColor3=C_GREY}):Play()
		end
	end)
	if Save.autoSpamOn then
		_autoSpamOn = true
		autoPill.BackgroundColor3 = C_PURPLE
		autoDot.Position = UDim2.new(1,-23,0.5,-10)
		autoDot.BackgroundColor3 = C_WHITE
	end

	local manualBtn = Instance.new("TextButton")
	manualBtn.Size = UDim2.new(1, 0, 0, 42)
	manualBtn.BackgroundColor3 = C_ROW
	manualBtn.BackgroundTransparency = 0.05
	manualBtn.BorderSizePixel = 0
	manualBtn.LayoutOrder = 2
	manualBtn.Text = "Manual"
	manualBtn.TextColor3 = C_WHITE
	manualBtn.Font = Enum.Font.GothamBold
	manualBtn.TextSize = 13
	manualBtn.AutoButtonColor = false
	manualBtn.Parent = spamCont
	Instance.new("UICorner", manualBtn).CornerRadius = UDim.new(0,12)
	manualBtn.MouseButton1Click:Connect(function()
		_TS2:Create(manualBtn, TweenInfo.new(0.08), {BackgroundColor3=Color3.fromRGB(70,75,110)}):Play()
		task.delay(0.15, function()
			_TS2:Create(manualBtn, TweenInfo.new(0.15), {BackgroundColor3=C_ROW}):Play()
		end)

		local function _doSpamTarget()
			local alvo = _selectedPlayer or _getClosest()
			if not alvo or alvo == _eu then return end
			if not alvo.Character then return end
			local uid = alvo.UserId
			if _LastPunishTime[uid] and tick()-_LastPunishTime[uid] < 2 then return end
			_LastPunishTime[uid] = tick()
			for _, cmd in ipairs(_comandos) do
				task.spawn(_fireAdmin, "f888ee6e-c86d-46e1-93d7-0639d6635d42", alvo, cmd)
			end
		end
		task.spawn(_doSpamTarget)
	end)

	local selToggleRow = Instance.new("Frame")
	selToggleRow.Size = UDim2.new(1, 0, 0, 42)
	selToggleRow.BackgroundColor3 = C_ROW
	selToggleRow.BackgroundTransparency = 0.05
	selToggleRow.BorderSizePixel = 0
	selToggleRow.LayoutOrder = 3
	selToggleRow.Parent = spamCont
	Instance.new("UICorner", selToggleRow).CornerRadius = UDim.new(0,12)
	local selLbl = Instance.new("TextLabel")
	selLbl.Size = UDim2.new(1, -64, 1, 0)
	selLbl.Position = UDim2.new(0, 14, 0, 0)
	selLbl.BackgroundTransparency = 1
	selLbl.Text = "Select Player"
	selLbl.TextColor3 = C_WHITE
	selLbl.Font = Enum.Font.GothamBold
	selLbl.TextSize = 13
	selLbl.TextXAlignment = Enum.TextXAlignment.Left
	selLbl.Parent = selToggleRow
	local selPill = Instance.new("Frame")
	selPill.Size = UDim2.new(0, 46, 0, 26)
	selPill.Position = UDim2.new(1, -54, 0.5, -13)
	selPill.BackgroundColor3 = C_PILLOFF
	selPill.BorderSizePixel = 0
	selPill.Parent = selToggleRow
	Instance.new("UICorner", selPill).CornerRadius = UDim.new(1,0)
	local selDot = Instance.new("Frame")
	selDot.Size = UDim2.new(0, 20, 0, 20)
	selDot.Position = UDim2.new(0, 3, 0.5, -10)
	selDot.BackgroundColor3 = C_GREY
	selDot.BorderSizePixel = 0
	selDot.Parent = selPill
	Instance.new("UICorner", selDot).CornerRadius = UDim.new(1,0)

	local playerListOpen = false
	local playerListFrame = Instance.new("Frame")
	playerListFrame.Name = "SelectPlayerGui"
	playerListFrame.Size = UDim2.new(0, 160, 0, 0)
	playerListFrame.AutomaticSize = Enum.AutomaticSize.Y
	playerListFrame.BackgroundColor3 = Color3.fromRGB(30, 33, 52)
	playerListFrame.BackgroundTransparency = 0.1
	playerListFrame.BorderSizePixel = 0
	playerListFrame.ClipsDescendants = false
	playerListFrame.Visible = false
	playerListFrame.Active = true
	playerListFrame.Parent = sg
	Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 14)
	local plStroke = Instance.new("UIStroke", playerListFrame)
	plStroke.Thickness = 1.5 plStroke.Color = C_STROKE plStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

	local plTop = Instance.new("Frame")
	plTop.Size = UDim2.new(1, 0, 0, 30)
	plTop.BackgroundTransparency = 1
	plTop.BorderSizePixel = 0
	plTop.Parent = playerListFrame
	local plTitle = Instance.new("TextLabel")
	plTitle.Size = UDim2.new(1, -10, 1, 0)
	plTitle.Position = UDim2.new(0, 10, 0, 0)
	plTitle.BackgroundTransparency = 1
	plTitle.Text = "Select Player"
	plTitle.TextColor3 = C_WHITE
	plTitle.TextSize = 12
	plTitle.Font = Enum.Font.GothamBlack
	plTitle.TextXAlignment = Enum.TextXAlignment.Left
	plTitle.Parent = plTop
	local plDiv = Instance.new("Frame")
	plDiv.Size = UDim2.new(1, -14, 0, 1)
	plDiv.Position = UDim2.new(0, 7, 1, -1)
	plDiv.BackgroundColor3 = C_STROKE
	plDiv.BackgroundTransparency = 0.4
	plDiv.BorderSizePixel = 0
	plDiv.Parent = plTop

	local plScroll = Instance.new("ScrollingFrame")
	plScroll.Size = UDim2.new(1, 0, 0, 160)
	plScroll.Position = UDim2.new(0, 0, 0, 30)
	plScroll.BackgroundTransparency = 1
	plScroll.BorderSizePixel = 0
	plScroll.ScrollBarThickness = 4
	plScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
	plScroll.ScrollBarImageTransparency = 0
	plScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	plScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	plScroll.ScrollingDirection = Enum.ScrollingDirection.Y
	plScroll.Parent = playerListFrame
	local plLayout = Instance.new("UIListLayout")
	plLayout.Padding = UDim.new(0, 4)
	plLayout.SortOrder = Enum.SortOrder.LayoutOrder
	plLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	plLayout.Parent = plScroll
	local plPad = Instance.new("UIPadding")
	plPad.PaddingTop = UDim.new(0, 5) plPad.PaddingBottom = UDim.new(0, 5)
	plPad.PaddingLeft = UDim.new(0, 5) plPad.PaddingRight = UDim.new(0, 5)
	plPad.Parent = plScroll

	local function repositionPlayerList()
		local vp = workspace.CurrentCamera.ViewportSize
		local sfPos = spamFrame.AbsolutePosition
		local sfSz = spamFrame.AbsoluteSize
		local plW = 160
		local xRight = sfPos.X + sfSz.X + 6
		local xLeft  = sfPos.X - plW - 6
		local x = (xRight + plW <= vp.X) and xRight or xLeft
		local y = math.clamp(sfPos.Y, 0, vp.Y - playerListFrame.AbsoluteSize.Y)
		playerListFrame.Position = UDim2.new(0, x, 0, y)
	end

	local function clearSelections()
		_selectedPlayer = nil
		for _, d in pairs(_playerBtns) do
			if d.btn and d.btn.Parent then
				_TS2:Create(d.btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(58,63,90), BackgroundTransparency=0}):Play()
				_TS2:Create(d.lbl, TweenInfo.new(0.1), {TextColor3=C_WHITE}):Play()
			end
		end
	end

	local function createSelBtn(p)
		if _playerBtns[p] then return end
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, 30)
		btn.BackgroundColor3 = Color3.fromRGB(58, 63, 90)
		btn.BackgroundTransparency = 0
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ZIndex = 3
		btn.Parent = plScroll
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
		local av = Instance.new("ImageLabel")
		av.Size = UDim2.new(0, 20, 0, 20)
		av.Position = UDim2.new(0, 5, 0.5, -10)
		av.BackgroundTransparency = 1
		av.ZIndex = 4
		av.Image = "https://www.roblox.com/headshot-thumbnail/image?userId="..p.UserId.."&width=48&height=48&format=png"
		av.Parent = btn
		Instance.new("UICorner", av).CornerRadius = UDim.new(1, 0)
		local nl = Instance.new("TextLabel")
		nl.Size = UDim2.new(1, -32, 1, 0)
		nl.Position = UDim2.new(0, 28, 0, 0)
		nl.BackgroundTransparency = 1
		nl.ZIndex = 4
		nl.Text = p.Name
		nl.TextColor3 = C_WHITE
		nl.Font = Enum.Font.Gotham
		nl.TextSize = 11
		nl.TextXAlignment = Enum.TextXAlignment.Left
		nl.TextTruncate = Enum.TextTruncate.AtEnd
		nl.Parent = btn
		_playerBtns[p] = {btn=btn, lbl=nl}
		btn.MouseButton1Click:Connect(function()
			local data = _playerBtns[p]
			if not data then return end
			if _selectedPlayer == p then
				_selectedPlayer = nil
				_TS2:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=Color3.fromRGB(58,63,90), BackgroundTransparency=0}):Play()
				_TS2:Create(nl, TweenInfo.new(0.1), {TextColor3=C_WHITE}):Play()
			else
				clearSelections()
				_selectedPlayer = p
				_TS2:Create(btn, TweenInfo.new(0.1), {BackgroundColor3=C_PURPLE, BackgroundTransparency=0}):Play()
				_TS2:Create(nl, TweenInfo.new(0.1), {TextColor3=Color3.fromRGB(200, 170, 255)}):Play()
			end
		end)
	end

	local function removeSelBtn(p)
		if _playerBtns[p] then
			pcall(function() _playerBtns[p].btn:Destroy() end)
			_playerBtns[p] = nil
			if _selectedPlayer == p then _selectedPlayer = nil end
		end
	end

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= _eu then createSelBtn(p) end
	end
	Players.PlayerAdded:Connect(function(p)
		task.wait(0.5)
		if p ~= _eu then createSelBtn(p) end
	end)
	Players.PlayerRemoving:Connect(removeSelBtn)

	local selCa = Instance.new("TextButton")
	selCa.Size = UDim2.new(1, 0, 1, 0)
	selCa.BackgroundTransparency = 1
	selCa.Text = ""
	selCa.ZIndex = 5
	selCa.Parent = selToggleRow
	selCa.MouseButton1Click:Connect(function()
		playerListOpen = not playerListOpen
		if playerListOpen then
			repositionPlayerList()
			playerListFrame.Visible = true
			_TS2:Create(selPill, TweenInfo.new(0.12), {BackgroundColor3=C_PURPLE}):Play()
			_TS2:Create(selDot, TweenInfo.new(0.12), {Position=UDim2.new(1,-23,0.5,-10), BackgroundColor3=C_WHITE}):Play()
		else
			playerListFrame.Visible = false
			_TS2:Create(selPill, TweenInfo.new(0.12), {BackgroundColor3=C_PILLOFF}):Play()
			_TS2:Create(selDot, TweenInfo.new(0.12), {Position=UDim2.new(0,3,0.5,-10), BackgroundColor3=C_GREY}):Play()
		end
	end)

	_G._spamEvent.Event:Connect(function()
		if _autoSpamOn then
			local alvo = _selectedPlayer or _getClosest()
			if alvo then _punishPlayer(alvo, "spam") end
		end
	end)
	_G._tpDoneEvent.Event:Connect(function()
		if _autoSpamOn then
			local alvo = _selectedPlayer or _getClosest()
			if alvo then _punishPlayer(alvo, "tpdone") end
		end
	end)
end)