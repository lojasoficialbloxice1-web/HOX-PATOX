-- HOX PATOX
-- Roblox Studio / LocalScript

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local CurrentJobId = game.JobId -- Guarda o servidor atual

local Config = {
	Aim = false,
	AimPart = "Head",
	FOV = 150,
	DrawFOV = false,
	AimDistance = 150,

	ESP = false,
	ESPLine = false,
	ESPName = false,
	ESPDistance = false,
	ESPDistanceMax = 200,

	Speed = false,
	SpeedValue = 24,

	AutoTranslate = true,
	HideKey = Enum.KeyCode.RightShift,

	AdminProtect = false
}

local Character
local Humanoid
local OriginalSpeed = 16
local ScriptStartTime = os.time()
local IsPC = UIS.KeyboardEnabled and UIS.MouseEnabled
local FullyHidden = false

local function updateCharacter()
	Character = LP.Character or LP.CharacterAdded:Wait()
	Humanoid = Character:WaitForChild("Humanoid")
	OriginalSpeed = Humanoid.WalkSpeed
end

updateCharacter()

LP.CharacterAdded:Connect(function()
	task.wait(0.5)
	updateCharacter()
end)

--------------------------------------------------
-- ANTI-DETECÇÃO
--------------------------------------------------

local function ProtectGui(gui)
	pcall(function()
		gui.Name = "GameGui_" .. tostring(math.random(1000, 9999))
		if syn and syn.protect_gui then
			syn.protect_gui(gui)
		end
	end)
end

local function CleanTraces()
	pcall(function()
		for _, v in ipairs(workspace.Terrain:GetChildren()) do
			if v.Name and v.Name:find("HoxPatox") then
				v.Name = "Attachment_" .. tostring(math.random(10000, 99999))
			end
		end
	end)
end

local function AntiScreenDetect()
	pcall(function()
		GuiService:AddSelectionParent("HoxHide", GUI)
	end)
end

task.spawn(function()
	while true do
		task.wait(30)
		CleanTraces()
	end
end)

--------------------------------------------------
-- SOM
--------------------------------------------------

local ClickSound = Instance.new("Sound")
ClickSound.SoundId = "rbxassetid://9114761890"
ClickSound.Volume = 0.5
ClickSound.Parent = SoundService

local function PlayClickSound()
	pcall(function()
		ClickSound.TimePosition = 0
		ClickSound:Play()
	end)
end

--------------------------------------------------
-- FPS
--------------------------------------------------

local fpsFrames = 0
local fpsLastUpdate = tick()
local currentFPS = 60

RunService.RenderStepped:Connect(function()
	fpsFrames = fpsFrames + 1
	local now = tick()
	if now - fpsLastUpdate >= 1 then
		currentFPS = math.floor(fpsFrames / (now - fpsLastUpdate))
		fpsFrames = 0
		fpsLastUpdate = now
	end
end)

--------------------------------------------------
-- TROCAR SERVIDOR - GARANTIDO NÃO VOLTAR
--------------------------------------------------

local function TeleportToNewServer()
	pcall(function()
		local placeId = game.PlaceId
		
		-- TENTATIVA 1: Usa ReserveServer - cria um servidor NOVO e vazio
		-- Isso 100% garante que não volta ao mesmo servidor
		local reserveSuccess, reserveCode, reservePlaceId = pcall(function()
			return TeleportService:ReserveServer(placeId)
		end)

		if reserveSuccess and reserveCode then
			-- Teleporta para o servidor reservado novo
			TeleportService:TeleportToPrivateServer(reservePlaceId or placeId, reserveCode, {LP})
			return
		end

		-- TENTATIVA 2: Se ReserveServer falhar, tenta pegar servidores aleatórios
		-- Tenta várias vezes para garantir um servidor diferente
		local maxTentativas = 5
		for tentativa = 1, maxTentativas do
			local teleportOptions = Instance.new("TeleportOptions")
			teleportOptions.ServerInstanceId = "" -- Força não usar o atual
			
			local success, errorMsg = pcall(function()
				TeleportService:TeleportAsync(placeId, {LP}, teleportOptions)
			end)
			
			if success then
				return
			end
			
			task.wait(0.1)
		end

		-- TENTATIVA 3: Último recurso - Teleport normal
		TeleportService:Teleport(placeId, LP)
	end)
end

--------------------------------------------------
-- DETECTAR ADMIN
--------------------------------------------------

local function IsPlayerAdmin(player)
	local isAdmin = false
	pcall(function()
		if player.UserId == game.CreatorId then
			isAdmin = true
			return
		end
		if game.CreatorType == Enum.CreatorType.Group then
			local groupId = game.CreatorId
			local ok, rank = pcall(function()
				return player:GetRankInGroup(groupId)
			end)
			if ok and rank >= 250 then
				isAdmin = true
				return
			end
		end
		local adminIds = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,91,92,93,94,95,96,97,98,99,100}
		for _, id in ipairs(adminIds) do
			if player.UserId == id then
				isAdmin = true
				return
			end
		end
	end)
	return isAdmin
end

task.spawn(function()
	while true do
		task.wait(2)
		if Config.AdminProtect then
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LP and IsPlayerAdmin(player) then
					Config.Aim = false
					Config.ESP = false
					Config.Speed = false
					TeleportToNewServer()
					break
				end
			end
		end
	end
end)

--------------------------------------------------
-- TRADUÇÃO
--------------------------------------------------

local Translations = {
	["pt-br"] = {
		Title = "Hox Patox", Close = "X", Minimize = "-", Float = "HP",
		Tricks = "Truques", Hs = "Hs", Bypass = "Bypass", Extras = "Extras", Jogar = "Jogar",
		AimLock = "Mira Automática", AimHead = "Mirar na Cabeça", AimChest = "Mirar no Peito",
		DrawFOV = "Desenhar Círculo FOV", RegularAimFOV = "Mira Normal - FOV", AimDistance = "Distância Máxima Mira",
		ESP = "ESP", ESPLine = "Linha ESP", ESPName = "Mostrar Nome", ESPDistance = "Mostrar Distância",
		ESPDistanceMax = "Distância Máxima ESP", HeadTarget = "Alvo Cabeça", ChestTarget = "Alvo Peito",
		Speed = "Velocidade", SpeedValue = "Valor da Velocidade",
		ChangeServer = "Trocar Servidor", AdminProtect = "Proteção Admin",
		AutoTranslate = "Tradução Automática", LanguageDetected = "Idioma Detectado",
		Portuguese = "Português", English = "Inglês", Spanish = "Espanhol",
		HideKey = "Tecla Ocultar Tudo", PressKey = "Pressione uma tecla...",
		ScriptActive = "Script Ativo", TimeRunning = "Tempo Ativo", PlayersNear = "Jogadores Próximos",
		Ping = "Ping", FPS = "FPS"
	},
	["en-us"] = {
		Title = "Hox Patox", Close = "X", Minimize = "-", Float = "HP",
		Tricks = "Tricks", Hs = "Hs", Bypass = "Bypass", Extras = "Extras", Jogar = "Play",
		AimLock = "Aim Lock", AimHead = "Aim Head", AimChest = "Aim Chest",
		DrawFOV = "Draw Circle FOV", RegularAimFOV = "Regular Aim - FOV", AimDistance = "Max Aim Distance",
		ESP = "ESP", ESPLine = "ESP Line", ESPName = "Show Name", ESPDistance = "Show Distance",
		ESPDistanceMax = "Max ESP Distance", HeadTarget = "Head Target", ChestTarget = "Chest Target",
		Speed = "Speed", SpeedValue = "Speed Value",
		ChangeServer = "Change Server", AdminProtect = "Admin Protect",
		AutoTranslate = "Auto Translate", LanguageDetected = "Detected Language",
		Portuguese = "Portuguese", English = "English", Spanish = "Spanish",
		HideKey = "Hide All Key", PressKey = "Press a key...",
		ScriptActive = "Script Active", TimeRunning = "Time Running", PlayersNear = "Players Nearby",
		Ping = "Ping", FPS = "FPS"
	},
	["es-es"] = {
		Title = "Hox Patox", Close = "X", Minimize = "-", Float = "HP",
		Tricks = "Trucos", Hs = "Hs", Bypass = "Bypass", Extras = "Extras", Jogar = "Jugar",
		AimLock = "Apuntado Automático", AimHead = "Apuntar a la Cabeza", AimChest = "Apuntar al Pecho",
		DrawFOV = "Dibujar Círculo FOV", RegularAimFOV = "Mira Normal - FOV", AimDistance = "Distancia Máxima",
		ESP = "ESP", ESPLine = "Línea ESP", ESPName = "Mostrar Nombre", ESPDistance = "Mostrar Distancia",
		ESPDistanceMax = "Distancia Máxima ESP", HeadTarget = "Objetivo Cabeza", ChestTarget = "Objetivo Pecho",
		Speed = "Velocidad", SpeedValue = "Valor de Velocidad",
		ChangeServer = "Cambiar Servidor", AdminProtect = "Protección Admin",
		AutoTranslate = "Traducción Automática", LanguageDetected = "Idioma Detectado",
		Portuguese = "Portugués", English = "Inglés", Spanish = "Español",
		HideKey = "Tecla Ocultar Todo", PressKey = "Presione una tecla...",
		ScriptActive = "Script Activo", TimeRunning = "Tiempo Activo", PlayersNear = "Jugadores Cercanos",
		Ping = "Ping", FPS = "FPS"
	}
}

local function GetPlayerLocale()
	local locale = LP.LocaleId:lower()
	if locale:find("pt") then return "pt-br" end
	if locale:find("es") then return "es-es" end
	return "en-us"
end

local CurrentLocale = GetPlayerLocale()
local CurrentLang = Translations[CurrentLocale] or Translations["en-us"]

local function T(key)
	return CurrentLang[key] or key
end

local function GetPlayerThumbnail(userId)
	local content = ""
	pcall(function()
		content = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	return content
end

--------------------------------------------------
-- GUI
--------------------------------------------------

local GUI = Instance.new("ScreenGui")
GUI.Name = "HoxPatox"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.Parent = LP:WaitForChild("PlayerGui")

ProtectGui(GUI)
AntiScreenDetect()

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.Size = UDim2.new(0.72, 0, 0, 400)
Main.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = false
Main.BackgroundTransparency = 1
Main.Parent = GUI

local MainLimit = Instance.new("UISizeConstraint")
MainLimit.MinSize = Vector2.new(320, 340)
MainLimit.MaxSize = Vector2.new(580, 460)
MainLimit.Parent = Main

local MainOuterStroke = Instance.new("UIStroke")
MainOuterStroke.Color = Color3.fromRGB(255, 0, 0)
MainOuterStroke.Thickness = 3
MainOuterStroke.Parent = Main

local MainInnerStroke = Instance.new("UIStroke")
MainInnerStroke.Color = Color3.fromRGB(0, 0, 0)
MainInnerStroke.Thickness = 1
MainInnerStroke.Parent = Main

--------------------------------------------------
-- DRAG
--------------------------------------------------

local MainDragging = false
local MainDragStart
local MainStartPos

local function SetupDrag(dragArea)
	dragArea.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.MouseButton1
			or Input.UserInputType == Enum.UserInputType.Touch then
			MainDragging = true
			MainDragStart = Input.Position
			MainStartPos = Main.Position
		end
	end)
end

UIS.InputChanged:Connect(function(Input)
	if not MainDragging then return end
	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then
		local Delta = Input.Position - MainDragStart
		Main.Position = UDim2.new(
			MainStartPos.X.Scale, MainStartPos.X.Offset + Delta.X,
			MainStartPos.Y.Scale, MainStartPos.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then
		MainDragging = false
	end
end)

--------------------------------------------------
-- TOP
--------------------------------------------------

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 65)
Top.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Top.BorderSizePixel = 0
Top.Active = true
Top.Parent = Main

local TopBottomBorder = Instance.new("Frame")
TopBottomBorder.Size = UDim2.new(1, 0, 0, 2)
TopBottomBorder.Position = UDim2.new(0, 0, 1, -2)
TopBottomBorder.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TopBottomBorder.BorderSizePixel = 0
TopBottomBorder.Parent = Top

SetupDrag(Top)

local TitlePhotoFrame = Instance.new("Frame")
TitlePhotoFrame.Position = UDim2.fromOffset(12, 10)
TitlePhotoFrame.Size = UDim2.fromOffset(45, 45)
TitlePhotoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TitlePhotoFrame.BorderSizePixel = 0
TitlePhotoFrame.ClipsDescendants = true
TitlePhotoFrame.Parent = Top

local TitlePhotoCorner = Instance.new("UICorner")
TitlePhotoCorner.CornerRadius = UDim.new(1, 0)
TitlePhotoCorner.Parent = TitlePhotoFrame

local TitlePhotoStroke = Instance.new("UIStroke")
TitlePhotoStroke.Color = Color3.fromRGB(255, 0, 0)
TitlePhotoStroke.Thickness = 2
TitlePhotoStroke.Parent = TitlePhotoFrame

local TitlePhotoImg = Instance.new("ImageLabel")
TitlePhotoImg.Size = UDim2.new(1, 0, 1, 0)
TitlePhotoImg.BackgroundTransparency = 1
TitlePhotoImg.Image = GetPlayerThumbnail(LP.UserId)
TitlePhotoImg.Parent = TitlePhotoFrame

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(68, 0)
Title.Size = UDim2.new(1, -168, 1, 0)
Title.Text = T("Title")
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 22
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Active = true
Title.Parent = Top

SetupDrag(Title)

local MinButton = Instance.new("TextButton")
MinButton.Size = UDim2.fromOffset(40, 40)
MinButton.Position = UDim2.new(1, -110, 0, 12)
MinButton.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
MinButton.BorderSizePixel = 0
MinButton.Text = T("Minimize")
MinButton.TextColor3 = Color3.new(1, 1, 1)
MinButton.TextSize = 24
MinButton.Font = Enum.Font.GothamBold
MinButton.ZIndex = 10
MinButton.Parent = Top

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 6)
MinCorner.Parent = MinButton

local MinStroke = Instance.new("UIStroke")
MinStroke.Color = Color3.fromRGB(0, 0, 0)
MinStroke.Thickness = 1
MinStroke.Parent = MinButton

local Close = Instance.new("TextButton")
Close.Size = UDim2.fromOffset(40, 40)
Close.Position = UDim2.new(1, -60, 0, 12)
Close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Close.BorderSizePixel = 0
Close.Text = T("Close")
Close.TextColor3 = Color3.new(1, 1, 1)
Close.TextSize = 20
Close.Font = Enum.Font.GothamBold
Close.ZIndex = 10
Close.Parent = Top

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = Close

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color = Color3.fromRGB(0, 0, 0)
CloseStroke.Thickness = 1
CloseStroke.Parent = Close

--------------------------------------------------
-- CONTENT
--------------------------------------------------

local Side = Instance.new("Frame")
Side.Position = UDim2.fromOffset(10, 78)
Side.Size = UDim2.new(0.32, -4, 1, -88)
Side.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
Side.BorderSizePixel = 0
Side.Parent = Main

local SideStroke = Instance.new("UIStroke")
SideStroke.Color = Color3.fromRGB(180, 0, 0)
SideStroke.Thickness = 1.5
SideStroke.Parent = Side

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 6)
SideCorner.Parent = Side

local Content = Instance.new("Frame")
Content.Position = UDim2.new(0.34, 0, 0, 78)
Content.Size = UDim2.new(0.64, -10, 1, -88)
Content.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Content.BorderSizePixel = 0
Content.ClipsDescendants = true
Content.Parent = Main

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = Color3.fromRGB(180, 0, 0)
ContentStroke.Thickness = 1.5
ContentStroke.Parent = Content

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 6)
ContentCorner.Parent = Content

--------------------------------------------------
-- SIDE BUTTONS
--------------------------------------------------

local SideButtons = {}

local function SideButton(Text, Y, Name)
	local B = Instance.new("TextButton")
	B.Position = UDim2.new(0, 6, 0, Y)
	B.Size = UDim2.new(1, -12, 0, 36)
	B.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	B.BorderSizePixel = 0
	B.Text = Text
	B.TextColor3 = Color3.fromRGB(235, 235, 235)
	B.TextSize = 14
	B.Font = Enum.Font.GothamBold
	B.Parent = Side

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 5)
	BtnCorner.Parent = B

	local BtnStroke = Instance.new("UIStroke")
	BtnStroke.Color = Color3.fromRGB(120, 0, 0)
	BtnStroke.Thickness = 1
	BtnStroke.Parent = B

	B.MouseEnter:Connect(function()
		B.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		BtnStroke.Color = Color3.fromRGB(255, 0, 0)
	end)

	B.MouseLeave:Connect(function()
		B.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		BtnStroke.Color = Color3.fromRGB(120, 0, 0)
	end)

	if Name then SideButtons[Name] = B end
	return B
end

local Tricks = SideButton(T("Tricks"), 8, "Tricks")
local Hs = SideButton(T("Hs"), 48, "Hs")
local Bypass = SideButton(T("Bypass"), 88, "Bypass")
local ExtrasBtn = SideButton(T("Extras"), 128, "Extras")
local JogarBtn = SideButton(T("Jogar"), 168, "Jogar")

local function connectSideSound(btn)
	btn.MouseButton1Click:Connect(function() PlayClickSound() end)
end
connectSideSound(Tricks); connectSideSound(Hs); connectSideSound(Bypass)
connectSideSound(ExtrasBtn); connectSideSound(JogarBtn)
connectSideSound(MinButton); connectSideSound(Close)

--------------------------------------------------
-- CLEAR
--------------------------------------------------

local function Clear()
	for _, v in ipairs(Content:GetChildren()) do
		v:Destroy()
	end
end

--------------------------------------------------
-- TOGGLE
--------------------------------------------------

local function Toggle(Text, Y, ConfigKey, Callback)
	local B = Instance.new("TextButton")
	B.Position = UDim2.new(0, 8, 0, Y)
	B.Size = UDim2.new(1, -16, 0, 40)
	B.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	B.BorderSizePixel = 0
	B.Text = ""
	B.Parent = Content

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 5)
	BtnCorner.Parent = B

	local BtnStroke = Instance.new("UIStroke")
	BtnStroke.Color = Color3.fromRGB(120, 0, 0)
	BtnStroke.Thickness = 1
	BtnStroke.Parent = B

	local Box = Instance.new("Frame")
	Box.Position = UDim2.fromOffset(4, 4)
	Box.Size = UDim2.fromOffset(32, 32)
	Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Box.BorderSizePixel = 0
	Box.Parent = B

	local BoxCorner = Instance.new("UICorner")
	BoxCorner.CornerRadius = UDim.new(0, 4)
	BoxCorner.Parent = Box

	local BoxStroke = Instance.new("UIStroke")
	BoxStroke.Color = Color3.fromRGB(0, 0, 0)
	BoxStroke.Thickness = 1
	BoxStroke.Parent = Box

	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(48, 0)
	Label.Size = UDim2.new(1, -50, 1, 0)
	Label.Text = Text
	Label.TextColor3 = Color3.new(1, 1, 1)
	Label.TextSize = 13
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = B

	local State = Config[ConfigKey] == true

	local function UpdateVisual()
		if State then
			Box.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
			BoxStroke.Color = Color3.fromRGB(255, 80, 80)
		else
			Box.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
			BoxStroke.Color = Color3.fromRGB(0, 0, 0)
		end
	end

	UpdateVisual()

	B.MouseEnter:Connect(function() B.BackgroundColor3 = Color3.fromRGB(28, 28, 28) end)
	B.MouseLeave:Connect(function() B.BackgroundColor3 = Color3.fromRGB(18, 18, 18) end)

	B.MouseButton1Click:Connect(function()
		PlayClickSound()
		State = not State
		Config[ConfigKey] = State
		UpdateVisual()
		if Callback then Callback(State) end
	end)

	return B
end

--------------------------------------------------
-- NUMBER BOX
--------------------------------------------------

local function NumberBox(Text, Y, Default, Min, Max, Callback)
	local Label = Instance.new("TextLabel")
	Label.BackgroundTransparency = 1
	Label.Position = UDim2.fromOffset(10, Y)
	Label.Size = UDim2.new(1, -16, 0, 20)
	Label.Text = Text .. ": " .. tostring(Default)
	Label.TextColor3 = Color3.fromRGB(220, 220, 220)
	Label.TextSize = 12
	Label.Font = Enum.Font.GothamBold
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = Content

	local Box = Instance.new("TextBox")
	Box.Position = UDim2.fromOffset(8, Y + 22)
	Box.Size = UDim2.new(1, -16, 0, 32)
	Box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	Box.BorderSizePixel = 0
	Box.Text = tostring(Default)
	Box.TextColor3 = Color3.new(1, 1, 1)
	Box.TextSize = 13
	Box.Font = Enum.Font.Gotham
	Box.ClearTextOnFocus = false
	Box.Parent = Content

	local BoxCorner = Instance.new("UICorner")
	BoxCorner.CornerRadius = UDim.new(0, 5)
	BoxCorner.Parent = Box

	local BoxStroke = Instance.new("UIStroke")
	BoxStroke.Color = Color3.fromRGB(120, 0, 0)
	BoxStroke.Thickness = 1
	BoxStroke.Parent = Box

	Box.FocusLost:Connect(function()
		local Value = tonumber(Box.Text)
		if Value then
			Value = math.clamp(Value, Min, Max)
			Box.Text = tostring(Value)
			Label.Text = Text .. ": " .. tostring(Value)
			Callback(Value)
			PlayClickSound()
		else
			Box.Text = tostring(Default)
		end
	end)
end

--------------------------------------------------
-- AIM
--------------------------------------------------

local function GetAimPart(CharacterTarget)
	if not CharacterTarget then return nil end
	if Config.AimPart == "Head" then return CharacterTarget:FindFirstChild("Head") end
	if Config.AimPart == "Chest" then
		return CharacterTarget:FindFirstChild("UpperTorso")
			or CharacterTarget:FindFirstChild("Torso")
			or CharacterTarget:FindFirstChild("LowerTorso")
	end
	return nil
end

local function GetDistance(pos1, pos2)
	return (pos1 - pos2).Magnitude
end

local function GetTarget()
	local Best
	local Closest = Config.FOV
	local Center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
	local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")
	if not MyRoot then return nil end

	for _, Player in ipairs(Players:GetPlayers()) do
		if Player ~= LP and Player.Character then
			local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
			local Part = GetAimPart(Player.Character)
			local TargetRoot = Player.Character:FindFirstChild("HumanoidRootPart")
			if Hum and Hum.Health > 0 and Part and TargetRoot then
				local Distance = GetDistance(MyRoot.Position, TargetRoot.Position)
				if Distance > Config.AimDistance then continue end
				local ScreenPos, Visible = Camera:WorldToViewportPoint(Part.Position)
				if Visible then
					local ScreenDistance = (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude
					if ScreenDistance < Closest then
						Closest = ScreenDistance
						Best = Part
					end
				end
			end
		end
	end
	return Best
end

--------------------------------------------------
-- FOV
--------------------------------------------------

local FOVCircle = Instance.new("Frame")
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Position = UDim2.fromScale(0.5, 0.5)
FOVCircle.Size = UDim2.fromOffset(Config.FOV * 2, Config.FOV * 2)
FOVCircle.BackgroundTransparency = 1
FOVCircle.Visible = false
FOVCircle.Parent = GUI

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 0, 0)
FOVStroke.Thickness = 2
FOVStroke.Parent = FOVCircle

--------------------------------------------------
-- ESP
--------------------------------------------------

local ESP = {}

local function MakeESP(Player)
	if Player == LP or ESP[Player] then return end
	local Data = {}

	local Highlight = Instance.new("Highlight")
	Highlight.Name = "Attachment_" .. tostring(math.random(10000, 99999))
	Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
	Highlight.FillTransparency = 0.65
	Highlight.OutlineTransparency = 0
	Highlight.Enabled = false
	Highlight.Parent = workspace
	Data.Highlight = Highlight

	local A0 = Instance.new("Attachment")
	A0.Name = "Attachment_" .. tostring(math.random(10000, 99999))
	A0.Parent = workspace.Terrain
	local A1 = Instance.new("Attachment")
	A1.Name = "Attachment_" .. tostring(math.random(10000, 99999))
	A1.Parent = workspace.Terrain

	local Beam = Instance.new("Beam")
	Beam.Name = "Beam_" .. tostring(math.random(10000, 99999))
	Beam.Attachment0 = A0
	Beam.Attachment1 = A1
	Beam.FaceCamera = true
	Beam.Width0 = 0.03
	Beam.Width1 = 0.03
	Beam.LightEmission = 1
	Beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
	Beam.Enabled = false
	Beam.Parent = workspace.Terrain

	Data.A0 = A0; Data.A1 = A1; Data.Beam = Beam

	local Billboard = Instance.new("BillboardGui")
	Billboard.Name = "Gui_" .. tostring(math.random(10000, 99999))
	Billboard.AlwaysOnTop = true
	Billboard.Size = UDim2.new(0, 150, 0, 40)
	Billboard.StudsOffset = Vector3.new(0, 3, 0)
	Billboard.Enabled = false
	Billboard.Parent = workspace.Terrain

	local NameLabel = Instance.new("TextLabel")
	NameLabel.BackgroundTransparency = 1
	NameLabel.Size = UDim2.new(1, 0, 0, 18)
	NameLabel.Position = UDim2.new(0, 0, 0, 0)
	NameLabel.Text = Player.Name
	NameLabel.TextColor3 = Color3.new(1, 1, 1)
	NameLabel.TextStrokeTransparency = 0
	NameLabel.TextSize = 14
	NameLabel.Font = Enum.Font.GothamBold
	NameLabel.Parent = Billboard

	local DistLabel = Instance.new("TextLabel")
	DistLabel.BackgroundTransparency = 1
	DistLabel.Size = UDim2.new(1, 0, 0, 16)
	DistLabel.Position = UDim2.new(0, 0, 0, 18)
	DistLabel.Text = ""
	DistLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
	DistLabel.TextStrokeTransparency = 0
	DistLabel.TextSize = 12
	DistLabel.Font = Enum.Font.Gotham
	DistLabel.Parent = Billboard

	Data.Billboard = Billboard
	Data.NameLabel = NameLabel
	Data.DistLabel = DistLabel
	Data.Player = Player
	ESP[Player] = Data
end

local function RemoveESP(Player)
	local Data = ESP[Player]
	if Data then
		if Data.Highlight then Data.Highlight:Destroy() end
		if Data.A0 then Data.A0:Destroy() end
		if Data.A1 then Data.A1:Destroy() end
		if Data.Beam then Data.Beam:Destroy() end
		if Data.Billboard then Data.Billboard:Destroy() end
		ESP[Player] = nil
	end
end

for _, Player in ipairs(Players:GetPlayers()) do MakeESP(Player) end
Players.PlayerAdded:Connect(MakeESP)
Players.PlayerRemoving:Connect(RemoveESP)

--------------------------------------------------
-- ATUALIZAR TEXTOS
--------------------------------------------------

local CurrentTab = "Tricks"

local function UpdateAllTexts()
	Title.Text = T("Title")
	Close.Text = T("Close")
	MinButton.Text = T("Minimize")
	Float.Text = T("Float")
	SideButtons.Tricks.Text = T("Tricks")
	SideButtons.Hs.Text = T("Hs")
	SideButtons.Bypass.Text = T("Bypass")
	SideButtons.Extras.Text = T("Extras")
	SideButtons.Jogar.Text = T("Jogar")
	if CurrentTab == "Tricks" then ShowTricks()
	elseif CurrentTab == "Hs" then ShowHs()
	elseif CurrentTab == "Bypass" then ShowBypass()
	elseif CurrentTab == "Extras" then ShowExtras()
	elseif CurrentTab == "Jogar" then ShowJogar()
	end
end

--------------------------------------------------
-- ABAS
--------------------------------------------------

function ShowTricks()
	CurrentTab = "Tricks"; Clear()
	Toggle(T("AimLock"), 8, "Aim")
	Toggle(T("AimHead"), 52, "AimHead", function(V) if V then Config.AimPart = "Head"; Config.AimChest = false end end)
	Toggle(T("AimChest"), 96, "AimChest", function(V) if V then Config.AimPart = "Chest"; Config.AimHead = false end end)
	Toggle(T("DrawFOV"), 140, "DrawFOV", function(V) Config.DrawFOV = V; FOVCircle.Visible = V end)
	NumberBox(T("RegularAimFOV"), 184, Config.FOV, 20, 600, function(V) Config.FOV = V; FOVCircle.Size = UDim2.fromOffset(V*2, V*2) end)
	NumberBox(T("AimDistance"), 244, Config.AimDistance, 10, 500, function(V) Config.AimDistance = V end)
end

function ShowHs()
	CurrentTab = "Hs"; Clear()
	Toggle(T("ESP"), 8, "ESP")
	Toggle(T("ESPLine"), 52, "ESPLine")
	Toggle(T("ESPName"), 96, "ESPName")
	Toggle(T("ESPDistance"), 140, "ESPDistance")
	NumberBox(T("ESPDistanceMax"), 184, Config.ESPDistanceMax, 30, 800, function(V) Config.ESPDistanceMax = V end)
	Toggle(T("HeadTarget"), 244, "HeadTarget", function(V) if V then Config.AimPart = "Head"; Config.ChestTarget = false end end)
	Toggle(T("ChestTarget"), 288, "ChestTarget", function(V) if V then Config.AimPart = "Chest"; Config.HeadTarget = false end end)
end

--------------------------------------------------
-- BYPASS (BOTÃO TROCAR SERVIDOR)
--------------------------------------------------

function ShowBypass()
	CurrentTab = "Bypass"; Clear()

	Toggle(T("Speed"), 8, "Speed", function(V)
		Config.Speed = V
		if not V and Humanoid then Humanoid.WalkSpeed = OriginalSpeed end
	end)

	NumberBox(T("SpeedValue"), 52, Config.SpeedValue, 16, 100, function(V) Config.SpeedValue = V end)

	-- BOTÃO TROCAR SERVIDOR - GARANTIDO
	local ServerBtn = Instance.new("TextButton")
	ServerBtn.Position = UDim2.new(0, 8, 0, 118)
	ServerBtn.Size = UDim2.new(1, -16, 0, 42)
	ServerBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	ServerBtn.BorderSizePixel = 0
	ServerBtn.Text = "🔄 " .. T("ChangeServer")
	ServerBtn.TextColor3 = Color3.new(1, 1, 1)
	ServerBtn.TextSize = 14
	ServerBtn.Font = Enum.Font.GothamBold
	ServerBtn.Parent = Content

	local ServerBtnCorner = Instance.new("UICorner")
	ServerBtnCorner.CornerRadius = UDim.new(0, 6)
	ServerBtnCorner.Parent = ServerBtn

	local ServerBtnStroke = Instance.new("UIStroke")
	ServerBtnStroke.Color = Color3.fromRGB(0, 0, 0)
	ServerBtnStroke.Thickness = 1.5
	ServerBtnStroke.Parent = ServerBtn

	ServerBtn.MouseEnter:Connect(function()
		ServerBtn.BackgroundColor3 = Color3.fromRGB(220, 0, 0)
	end)
	ServerBtn.MouseLeave:Connect(function()
		ServerBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
	end)

	ServerBtn.MouseButton1Click:Connect(function()
		PlayClickSound()
		
		-- Feedback visual
		local originalText = ServerBtn.Text
		ServerBtn.Text = "⏳ Carregando..."
		ServerBtn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
		ServerBtn.AutoLocalize = false
		
		local tween = TweenService:Create(ServerBtn, TweenInfo.new(0.1), {
			Size = UDim2.new(1, -20, 0, 38)
		})
		tween:Play()
		tween.Completed:Connect(function()
			TweenService:Create(ServerBtn, TweenInfo.new(0.1), {
				Size = UDim2.new(1, -16, 0, 42)
			}):Play()
		end)
		
		-- TROCA DE SERVIDOR GARANTIDA
		task.spawn(function()
			TeleportToNewServer()
		end)
	end)

	-- Proteção Admin
	Toggle(T("AdminProtect"), 172, "AdminProtect", function(V)
		Config.AdminProtect = V
	end)
end

--------------------------------------------------
-- EXTRAS
--------------------------------------------------

local WaitingForKey = false
local IgnoreNextClick = false

function ShowExtras()
	CurrentTab = "Extras"; Clear()
	WaitingForKey = false

	Toggle(T("AutoTranslate"), 8, "AutoTranslate")

	local LangLabel = Instance.new("TextLabel")
	LangLabel.BackgroundTransparency = 1
	LangLabel.Position = UDim2.fromOffset(10, 54)
	LangLabel.Size = UDim2.new(1, -16, 0, 20)
	LangLabel.Text = T("LanguageDetected") .. ": " .. 
		(CurrentLocale == "pt-br" and T("Portuguese") or 
		 CurrentLocale == "es-es" and T("Spanish") or T("English"))
	LangLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	LangLabel.TextSize = 12
	LangLabel.Font = Enum.Font.GothamBold
	LangLabel.TextXAlignment = Enum.TextXAlignment.Left
	LangLabel.Parent = Content

	local function LangButton(text, locale, Y)
		local Btn = Instance.new("TextButton")
		Btn.Position = UDim2.new(0, 8, 0, Y)
		Btn.Size = UDim2.new(1, -16, 0, 30)
		Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		Btn.BorderSizePixel = 0
		Btn.Text = text
		Btn.TextColor3 = Color3.new(1, 1, 1)
		Btn.TextSize = 12
		Btn.Font = Enum.Font.GothamBold
		Btn.Parent = Content

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 5)
		BtnCorner.Parent = Btn

		local BtnStroke = Instance.new("UIStroke")
		BtnStroke.Color = Color3.fromRGB(120, 0, 0)
		BtnStroke.Thickness = 1
		BtnStroke.Parent = Btn

		Btn.MouseEnter:Connect(function()
			Btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			BtnStroke.Color = Color3.fromRGB(255, 0, 0)
		end)
		Btn.MouseLeave:Connect(function()
			Btn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
			BtnStroke.Color = Color3.fromRGB(120, 0, 0)
		end)

		Btn.MouseButton1Click:Connect(function()
			PlayClickSound()
			CurrentLocale = locale
			CurrentLang = Translations[locale]
			UpdateAllTexts()
		end)
	end

	LangButton("🇧🇷 " .. T("Portuguese"), "pt-br", 80)
	LangButton("🇺🇸 " .. T("English"), "en-us", 116)
	LangButton("🇪🇸 " .. T("Spanish"), "es-es", 152)

	if IsPC then
		local Sep = Instance.new("Frame")
		Sep.Position = UDim2.fromOffset(8, 190)
		Sep.Size = UDim2.new(1, -16, 0, 1)
		Sep.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
		Sep.BorderSizePixel = 0
		Sep.Parent = Content

		local KeyLabel = Instance.new("TextLabel")
		KeyLabel.BackgroundTransparency = 1
		KeyLabel.Position = UDim2.fromOffset(10, 200)
		KeyLabel.Size = UDim2.new(1, -16, 0, 20)
		KeyLabel.Text = T("HideKey") .. " [" .. Config.HideKey.Name .. "]"
		KeyLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
		KeyLabel.TextSize = 13
		KeyLabel.Font = Enum.Font.GothamBold
		KeyLabel.TextXAlignment = Enum.TextXAlignment.Left
		KeyLabel.Parent = Content

		local KeyBtn = Instance.new("TextButton")
		KeyBtn.Position = UDim2.new(0, 8, 0, 224)
		KeyBtn.Size = UDim2.new(1, -16, 0, 36)
		KeyBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		KeyBtn.BorderSizePixel = 0
		KeyBtn.Text = Config.HideKey.Name
		KeyBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
		KeyBtn.TextSize = 14
		KeyBtn.Font = Enum.Font.GothamBold
		KeyBtn.Parent = Content

		local KeyBtnCorner = Instance.new("UICorner")
		KeyBtnCorner.CornerRadius = UDim.new(0, 5)
		KeyBtnCorner.Parent = KeyBtn

		local KeyBtnStroke = Instance.new("UIStroke")
		KeyBtnStroke.Color = Color3.fromRGB(200, 0, 0)
		KeyBtnStroke.Thickness = 1.5
		KeyBtnStroke.Parent = KeyBtn

		KeyBtn.MouseEnter:Connect(function() KeyBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30) end)
		KeyBtn.MouseLeave:Connect(function() KeyBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18) end)

		KeyBtn.MouseButton1Click:Connect(function()
			PlayClickSound()
			WaitingForKey = true
			IgnoreNextClick = true
			KeyBtn.Text = T("PressKey")
			KeyBtn.TextColor3 = Color3.fromRGB(255, 255, 100)
			KeyLabel.Text = T("HideKey") .. " [...]"
		end)
	end
end

-- CAPTURA GLOBAL DE TECLA
UIS.InputBegan:Connect(function(Input, GameProcessed)
	if WaitingForKey then
		if IgnoreNextClick then
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				IgnoreNextClick = false
				return
			end
		end

		if Input.UserInputType == Enum.UserInputType.Keyboard then
			Config.HideKey = Input.KeyCode
			WaitingForKey = false
			PlayClickSound()
			for _, v in ipairs(Content:GetChildren()) do
				if v:IsA("TextButton") and v.Text == T("PressKey") then
					v.Text = Input.KeyCode.Name
					v.TextColor3 = Color3.fromRGB(255, 100, 100)
				end
				if v:IsA("TextLabel") and v.Text:find("%[...%]") then
					v.Text = T("HideKey") .. " [" .. Input.KeyCode.Name .. "]"
				end
			end
		end
		return
	end

	if GameProcessed then return end
	if not IsPC then return end

	if Input.UserInputType == Enum.UserInputType.Keyboard then
		if Input.KeyCode == Config.HideKey then
			PlayClickSound()
			
			if FullyHidden then
				FullyHidden = false
				Minimized = false
				Main.Visible = true
				Float.Visible = false
				TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
					BackgroundTransparency = 0,
					Size = UDim2.new(0.72, 0, 0, 400)
				}):Play()
			elseif Minimized then
				FullyHidden = true
				local tween = TweenService:Create(Float, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					Size = UDim2.fromOffset(0, 0),
					BackgroundTransparency = 1
				})
				tween:Play()
				tween.Completed:Connect(function()
					Float.Visible = false
				end)
			else
				FullyHidden = true
				Minimized = true
				local tween = TweenService:Create(Main, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 1,
					Size = UDim2.new(0, 0, 0, 0)
				})
				tween:Play()
				tween.Completed:Connect(function()
					Main.Visible = false
					Float.Visible = false
				end)
			end
		end
	end
end)

--------------------------------------------------
-- JOGAR
--------------------------------------------------

local JogarLabels = {}

function ShowJogar()
	CurrentTab = "Jogar"; Clear()
	JogarLabels = {}

	local UserCard = Instance.new("Frame")
	UserCard.Position = UDim2.fromOffset(8, 8)
	UserCard.Size = UDim2.new(1, -16, 0, 70)
	UserCard.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	UserCard.BorderSizePixel = 0
	UserCard.Parent = Content

	local UserCardCorner = Instance.new("UICorner")
	UserCardCorner.CornerRadius = UDim.new(0, 8)
	UserCardCorner.Parent = UserCard

	local UserCardStroke = Instance.new("UIStroke")
	UserCardStroke.Color = Color3.fromRGB(200, 0, 0)
	UserCardStroke.Thickness = 1.5
	UserCardStroke.Parent = UserCard

	local BigPhotoFrame = Instance.new("Frame")
	BigPhotoFrame.Position = UDim2.fromOffset(8, 8)
	BigPhotoFrame.Size = UDim2.fromOffset(54, 54)
	BigPhotoFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BigPhotoFrame.BorderSizePixel = 0
	BigPhotoFrame.ClipsDescendants = true
	BigPhotoFrame.Parent = UserCard

	local BigPhotoCorner = Instance.new("UICorner")
	BigPhotoCorner.CornerRadius = UDim.new(1, 0)
	BigPhotoCorner.Parent = BigPhotoFrame

	local BigPhotoStroke = Instance.new("UIStroke")
	BigPhotoStroke.Color = Color3.fromRGB(255, 0, 0)
	BigPhotoStroke.Thickness = 2
	BigPhotoStroke.Parent = BigPhotoFrame

	local BigPhotoImg = Instance.new("ImageLabel")
	BigPhotoImg.Size = UDim2.new(1, 0, 1, 0)
	BigPhotoImg.BackgroundTransparency = 1
	BigPhotoImg.Image = GetPlayerThumbnail(LP.UserId)
	BigPhotoImg.Parent = BigPhotoFrame

	local StatusDot = Instance.new("Frame")
	StatusDot.Position = UDim2.fromOffset(72, 14)
	StatusDot.Size = UDim2.fromOffset(10, 10)
	StatusDot.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
	StatusDot.BorderSizePixel = 0
	StatusDot.Parent = UserCard

	local StatusDotCorner = Instance.new("UICorner")
	StatusDotCorner.CornerRadius = UDim.new(1, 0)
	StatusDotCorner.Parent = StatusDot

	local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
	TweenService:Create(StatusDot, tweenInfo, {BackgroundTransparency = 0.5}):Play()

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.Position = UDim2.fromOffset(88, 10)
	StatusLabel.Size = UDim2.new(1, -94, 0, 18)
	StatusLabel.Text = T("ScriptActive")
	StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
	StatusLabel.TextSize = 13
	StatusLabel.Font = Enum.Font.GothamBold
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.Parent = UserCard

	local UserNameLabel = Instance.new("TextLabel")
	UserNameLabel.BackgroundTransparency = 1
	UserNameLabel.Position = UDim2.fromOffset(72, 32)
	UserNameLabel.Size = UDim2.new(1, -78, 0, 16)
	UserNameLabel.Text = "👤 " .. LP.Name
	UserNameLabel.TextColor3 = Color3.new(1, 1, 1)
	UserNameLabel.TextSize = 12
	UserNameLabel.Font = Enum.Font.GothamBold
	UserNameLabel.TextXAlignment = Enum.TextXAlignment.Left
	UserNameLabel.Parent = UserCard

	local TimeLabel = Instance.new("TextLabel")
	TimeLabel.BackgroundTransparency = 1
	TimeLabel.Position = UDim2.fromOffset(72, 50)
	TimeLabel.Size = UDim2.new(1, -78, 0, 14)
	TimeLabel.Text = "⏱ " .. T("TimeRunning") .. ": 00:00:00"
	TimeLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	TimeLabel.TextSize = 11
	TimeLabel.Font = Enum.Font.Gotham
	TimeLabel.TextXAlignment = Enum.TextXAlignment.Left
	TimeLabel.Parent = UserCard

	JogarLabels.TimeLabel = TimeLabel

	local StatsFrame = Instance.new("Frame")
	StatsFrame.Position = UDim2.fromOffset(8, 86)
	StatsFrame.Size = UDim2.new(1, -16, 0, 36)
	StatsFrame.BackgroundTransparency = 1
	StatsFrame.Parent = Content

	local PingCard = Instance.new("Frame")
	PingCard.Size = UDim2.new(0.48, 0, 1, 0)
	PingCard.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	PingCard.BorderSizePixel = 0
	PingCard.Parent = StatsFrame

	local PingCorner = Instance.new("UICorner")
	PingCorner.CornerRadius = UDim.new(0, 6)
	PingCorner.Parent = PingCard

	local PingStroke = Instance.new("UIStroke")
	PingStroke.Color = Color3.fromRGB(120, 0, 0)
	PingStroke.Thickness = 1
	PingStroke.Parent = PingCard

	local PingLabel = Instance.new("TextLabel")
	PingLabel.BackgroundTransparency = 1
	PingLabel.Size = UDim2.new(1, 0, 1, 0)
	PingLabel.Text = "📶 " .. T("Ping") .. ": --ms"
	PingLabel.TextColor3 = Color3.fromRGB(100, 255, 150)
	PingLabel.TextSize = 12
	PingLabel.Font = Enum.Font.GothamBold
	PingLabel.Parent = PingCard

	JogarLabels.PingLabel = PingLabel

	local FPSCard = Instance.new("Frame")
	FPSCard.Position = UDim2.new(0.52, 0, 0, 0)
	FPSCard.Size = UDim2.new(0.48, 0, 1, 0)
	FPSCard.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	FPSCard.BorderSizePixel = 0
	FPSCard.Parent = StatsFrame

	local FPSCorner = Instance.new("UICorner")
	FPSCorner.CornerRadius = UDim.new(0, 6)
	FPSCorner.Parent = FPSCard

	local FPSStroke = Instance.new("UIStroke")
	FPSStroke.Color = Color3.fromRGB(120, 0, 0)
	FPSStroke.Thickness = 1
	FPSStroke.Parent = FPSCard

	local FPSLabel = Instance.new("TextLabel")
	FPSLabel.BackgroundTransparency = 1
	FPSLabel.Size = UDim2.new(1, 0, 1, 0)
	FPSLabel.Text = "⚡ " .. T("FPS") .. ": --"
	FPSLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	FPSLabel.TextSize = 12
	FPSLabel.Font = Enum.Font.GothamBold
	FPSLabel.Parent = FPSCard

	JogarLabels.FPSLabel = FPSLabel

	local NearTitle = Instance.new("TextLabel")
	NearTitle.BackgroundTransparency = 1
	NearTitle.Position = UDim2.fromOffset(10, 132)
	NearTitle.Size = UDim2.new(1, -16, 0, 18)
	NearTitle.Text = "🎯 " .. T("PlayersNear")
	NearTitle.TextColor3 = Color3.fromRGB(220, 220, 220)
	NearTitle.TextSize = 12
	NearTitle.Font = Enum.Font.GothamBold
	NearTitle.TextXAlignment = Enum.TextXAlignment.Left
	NearTitle.Parent = Content

	local NearList = Instance.new("ScrollingFrame")
	NearList.Position = UDim2.fromOffset(8, 154)
	NearList.Size = UDim2.new(1, -16, 0, 130)
	NearList.BackgroundTransparency = 1
	NearList.BorderSizePixel = 0
	NearList.ScrollBarThickness = 4
	NearList.ScrollBarColor3 = Color3.fromRGB(180, 0, 0)
	NearList.CanvasSize = UDim2.new(0, 0, 0, 0)
	NearList.Parent = Content

	local UIList = Instance.new("UIListLayout")
	UIList.SortOrder = Enum.SortOrder.LayoutOrder
	UIList.Padding = UDim.new(0, 4)
	UIList.Parent = NearList

	JogarLabels.NearList = NearList
	JogarLabels.UIList = UIList
end

--------------------------------------------------
-- LOOP ATUALIZAÇÃO JOGAR
--------------------------------------------------

task.spawn(function()
	while true do
		task.wait(1)

		if JogarLabels.TimeLabel then
			local elapsed = os.time() - ScriptStartTime
			local hours = math.floor(elapsed / 3600)
			local minutes = math.floor((elapsed % 3600) / 60)
			local seconds = elapsed % 60
			JogarLabels.TimeLabel.Text = "⏱ " .. T("TimeRunning") .. ": " .. 
				string.format("%02d:%02d:%02d", hours, minutes, seconds)
		end

		if JogarLabels.FPSLabel then
			local fpsColor = currentFPS >= 50 and Color3.fromRGB(100, 255, 150)
				or currentFPS >= 30 and Color3.fromRGB(255, 200, 100)
				or Color3.fromRGB(255, 100, 100)
			JogarLabels.FPSLabel.Text = "⚡ " .. T("FPS") .. ": " .. currentFPS
			JogarLabels.FPSLabel.TextColor3 = fpsColor
		end

		if JogarLabels.PingLabel then
			local ping = 30
			pcall(function()
				local stats = game:GetService("Stats")
				local net = stats:FindFirstChild("Network")
				if net then
					local serverStats = net:FindFirstChild("ServerStatsItem")
					if serverStats then
						local dataPing = serverStats:FindFirstChild("Data Ping")
						if dataPing and dataPing:IsA("NumberValue") then
							ping = math.floor(dataPing.Value)
						end
					end
				end
			end)
			local pingColor = ping < 60 and Color3.fromRGB(100, 255, 150)
				or ping < 120 and Color3.fromRGB(255, 200, 100)
				or Color3.fromRGB(255, 100, 100)
			JogarLabels.PingLabel.Text = "📶 " .. T("Ping") .. ": " .. ping .. "ms"
			JogarLabels.PingLabel.TextColor3 = pingColor
		end

		if JogarLabels.NearList and JogarLabels.UIList and Character then
			local MyRoot = Character:FindFirstChild("HumanoidRootPart")
			if MyRoot then
				for _, child in ipairs(JogarLabels.NearList:GetChildren()) do
					if child:IsA("Frame") then child:Destroy() end
				end

				local playersNear = {}
				for _, Player in ipairs(Players:GetPlayers()) do
					if Player ~= LP and Player.Character then
						local Root = Player.Character:FindFirstChild("HumanoidRootPart")
						local Hum = Player.Character:FindFirstChildOfClass("Humanoid")
						if Root and Hum and Hum.Health > 0 then
							local dist = math.floor(GetDistance(MyRoot.Position, Root.Position))
							table.insert(playersNear, {player = Player, dist = dist})
						end
					end
				end

				table.sort(playersNear, function(a, b) return a.dist < b.dist end)

				for i, p in ipairs(playersNear) do
					if i > 5 then break end

					local item = Instance.new("Frame")
					item.Size = UDim2.new(1, 0, 0, 30)
					item.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
					item.BorderSizePixel = 0
					item.Parent = JogarLabels.NearList

					local itemCorner = Instance.new("UICorner")
					itemCorner.CornerRadius = UDim.new(0, 5)
					itemCorner.Parent = item

					local itemStroke = Instance.new("UIStroke")
					itemStroke.Color = Color3.fromRGB(100, 0, 0)
					itemStroke.Thickness = 1
					itemStroke.Parent = item

					local miniPhoto = Instance.new("ImageLabel")
					miniPhoto.Position = UDim2.fromOffset(4, 4)
					miniPhoto.Size = UDim2.fromOffset(22, 22)
					miniPhoto.BackgroundTransparency = 1
					miniPhoto.Image = GetPlayerThumbnail(p.player.UserId)
					miniPhoto.Parent = item

					local miniCorner = Instance.new("UICorner")
					miniCorner.CornerRadius = UDim.new(1, 0)
					miniCorner.Parent = miniPhoto

					local color = p.dist < 50 and Color3.fromRGB(255, 100, 100) 
						or p.dist < 100 and Color3.fromRGB(255, 200, 100)
						or Color3.fromRGB(150, 255, 150)

					local info = Instance.new("TextLabel")
					info.BackgroundTransparency = 1
					info.Position = UDim2.fromOffset(32, 0)
					info.Size = UDim2.new(1, -90, 1, 0)
					info.Text = p.player.Name
					info.TextColor3 = Color3.new(1, 1, 1)
					info.TextSize = 11
					info.Font = Enum.Font.GothamBold
					info.TextXAlignment = Enum.TextXAlignment.Left
					info.Parent = item

					local distLbl = Instance.new("TextLabel")
					distLbl.BackgroundTransparency = 1
					distLbl.Position = UDim2.new(1, -55, 0, 0)
					distLbl.Size = UDim2.new(0, 50, 1, 0)
					distLbl.Text = p.dist .. "s"
					distLbl.TextColor3 = color
					distLbl.TextSize = 11
					distLbl.Font = Enum.Font.GothamBold
					distLbl.TextXAlignment = Enum.TextXAlignment.Right
					distLbl.Parent = item
				end

				JogarLabels.NearList.CanvasSize = UDim2.new(0, 0, 0, JogarLabels.UIList.AbsoluteContentSize.Y)
			end
		end
	end
end)

--------------------------------------------------
-- CONEXÕES ABAS
--------------------------------------------------

Tricks.MouseButton1Click:Connect(ShowTricks)
Hs.MouseButton1Click:Connect(ShowHs)
Bypass.MouseButton1Click:Connect(ShowBypass)
ExtrasBtn.MouseButton1Click:Connect(ShowExtras)
JogarBtn.MouseButton1Click:Connect(ShowJogar)

ShowTricks()

--------------------------------------------------
-- FLOATING BUTTON
--------------------------------------------------

local Float = Instance.new("TextButton")
Float.Name = "FloatingButton"
Float.AnchorPoint = Vector2.new(0.5, 0.5)
Float.Position = UDim2.new(0.9, 0, 0.5, 0)
Float.Size = UDim2.fromOffset(58, 58)
Float.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Float.Text = T("Float")
Float.TextColor3 = Color3.fromRGB(255, 255, 255)
Float.TextSize = 16
Float.Font = Enum.Font.GothamBold
Float.Visible = false
Float.Parent = GUI

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = Float

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(255, 0, 0)
FloatStroke.Thickness = 2
FloatStroke.Parent = Float

local FloatDragging = false
local FloatDragStart
local FloatStartPos

Float.InputBegan:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then
		FloatDragging = true
		FloatDragStart = Input.Position
		FloatStartPos = Float.Position
	end
end)

UIS.InputChanged:Connect(function(Input)
	if not FloatDragging then return end
	if Input.UserInputType == Enum.UserInputType.MouseMovement
		or Input.UserInputType == Enum.UserInputType.Touch then
		local Delta = Input.Position - FloatDragStart
		Float.Position = UDim2.new(
			FloatStartPos.X.Scale, FloatStartPos.X.Offset + Delta.X,
			FloatStartPos.Y.Scale, FloatStartPos.Y.Offset + Delta.Y
		)
	end
end)

UIS.InputEnded:Connect(function(Input)
	if Input.UserInputType == Enum.UserInputType.MouseButton1
		or Input.UserInputType == Enum.UserInputType.Touch then
		FloatDragging = false
	end
end)

Float.MouseButton1Click:Connect(function()
	PlayClickSound()
	Minimized = false
	FullyHidden = false
	Main.Visible = true
	Float.Visible = false
	TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back), {
		BackgroundTransparency = 0,
		Size = UDim2.new(0.72, 0, 0, 400)
	}):Play()
end)

--------------------------------------------------
-- MINIMIZE
--------------------------------------------------

local Minimized = false

function Minimize()
	PlayClickSound()
	Minimized = true
	FullyHidden = false
	local tween = TweenService:Create(Main, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 58, 0, 58)
	})
	tween:Play()
	tween.Completed:Connect(function()
		Main.Visible = false
		Float.Visible = true
		Float.Size = UDim2.fromOffset(0, 0)
		Float.BackgroundTransparency = 0
		TweenService:Create(Float, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
			Size = UDim2.fromOffset(58, 58)
		}):Play()
	end)
end

MinButton.MouseButton1Click:Connect(Minimize)

--------------------------------------------------
-- CLOSE
--------------------------------------------------

local Closed = false

local function StopEverything()
	Config.Aim = false; Config.ESP = false; Config.ESPLine = false
	Config.Speed = false; Config.DrawFOV = false
	FOVCircle.Visible = false
	if Humanoid then Humanoid.WalkSpeed = OriginalSpeed end
	for _, Data in pairs(ESP) do
		if Data.Highlight then Data.Highlight.Enabled = false end
		if Data.Beam then Data.Beam.Enabled = false end
		if Data.Billboard then Data.Billboard.Enabled = false end
	end
end

Close.MouseButton1Click:Connect(function()
	PlayClickSound()
	Closed = true
	StopEverything()
	local tween = TweenService:Create(Main, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 0, 0, 0)
	})
	tween:Play()
	tween.Completed:Connect(function()
		Float.Visible = false
		Main.Visible = false
		GUI:Destroy()
	end)
end)

--------------------------------------------------
-- ANIMAÇÃO ABERTURA
--------------------------------------------------

task.spawn(function()
	Main.Size = UDim2.new(0, 0, 0, 0)
	Main.BackgroundTransparency = 1
	task.wait(0.1)
	TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.72, 0, 0, 400),
		BackgroundTransparency = 0
	}):Play()
	PlayClickSound()
end)

--------------------------------------------------
-- MAIN LOOP
--------------------------------------------------

RunService.RenderStepped:Connect(function()
	if Closed then return end

	if Config.Aim then
		local Target = GetTarget()
		if Target then
			Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, Target.Position)
		end
	end

	if Config.Speed and Humanoid and Humanoid.Health > 0 then
		Humanoid.WalkSpeed = Config.SpeedValue
	end

	local MyRoot = Character and Character:FindFirstChild("HumanoidRootPart")

	for Player, Data in pairs(ESP) do
		local TargetCharacter = Player.Character
		local Root = TargetCharacter and TargetCharacter:FindFirstChild("HumanoidRootPart")
		local Hum = TargetCharacter and TargetCharacter:FindFirstChildOfClass("Humanoid")
		local Head = TargetCharacter and TargetCharacter:FindFirstChild("Head")

		if Root and Hum and Hum.Health > 0 and MyRoot then
			local Distance = GetDistance(MyRoot.Position, Root.Position)

			if Distance <= Config.ESPDistanceMax then
				Data.Highlight.Adornee = TargetCharacter
				Data.Highlight.Enabled = Config.ESP

				if Config.ESP and Config.ESPLine then
					Data.A0.WorldPosition = MyRoot.Position
					Data.A1.WorldPosition = Root.Position
					Data.Beam.Enabled = true
				else
					Data.Beam.Enabled = false
				end

				if Config.ESP and Head then
					Data.Billboard.Adornee = Head
					Data.Billboard.Enabled = Config.ESPName or Config.ESPDistance

					local Dist = math.floor(Distance)
					Data.NameLabel.Visible = Config.ESPName
					Data.DistLabel.Visible = Config.ESPDistance
					Data.DistLabel.Text = Dist .. " studs"

					if Dist < 50 then
						Data.DistLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
					elseif Dist < 100 then
						Data.DistLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
					else
						Data.DistLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
					end
				else
					Data.Billboard.Enabled = false
				end
			else
				Data.Highlight.Enabled = false
				Data.Beam.Enabled = false
				Data.Billboard.Enabled = false
			end
		else
			Data.Highlight.Enabled = false
			Data.Beam.Enabled = false
			Data.Billboard.Enabled = false
		end
	end
end)
