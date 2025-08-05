--| cmd -> 1.1 beta
--| 07/14/25
--| github.com/lxte/cmd

if not game:IsLoaded() then
	game.Loaded:Wait()
end

local Cmd = getgenv or function()
	return _G
end

local Speed, Admins = tick(), {}
local Settings = {
	Prefix = ";",
	ChatPrefix = "!",
	Seperator = ",",
	Version = "Beta 1.1",

	CustomUI = Cmd().CustomUI or "rbxassetid://18617417654",

	Waypoints = {},
	Events = {
		["AutoExecute"] = {},
		["Chatted"] = {},
		["CharacterAdded"] = {},
		["Died"] = {},
		["Damaged"] = {},
		["PlayerRemoved"] = {},
	},

	Theme = {
		Mode = "Dark",
		Transparency = 0,

		-- Frames:
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(20, 20, 20),
		Actions = Color3.fromRGB(12, 16, 22),
		Component = Color3.fromRGB(20, 20, 20),
		Highlight = Color3.fromRGB(84, 132, 164),
		ScrollBar = Color3.fromRGB(30, 30, 30),

		-- Text:
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),

		-- Outlines:
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(25, 25, 25),

		-- Image:
		Icon = Color3.fromRGB(255, 255, 255),
	},

	Toggles = {
		FillCap = true,
		Developer = false,
		Notify = true,
		Popups = true,
		RemoveCommandBars = false,
		Recommendation = true,
		InternalUI = false,
		StaffNotifier = true,
		IgnoreSeated = true,
		UnsureVulnDetector = false,
	},
}

local Connect = game.Loaded.Connect
local CWait = game.Loaded.Wait
local Clone = game.Clone
local Destroy = game.Destroy
local Changed = game.GetPropertyChangedSignal
local GetService = function(Property)
	local Service = game.GetService
	local Reference = cloneref or function(Reference)
		return Reference
	end

	return Reference(Service(game, Property))
end

local Services = {
	Players = GetService("Players"),
	Lighting = GetService("Lighting"),
	Core = GetService("CoreGui"),
	Teams = GetService("CoreGui"),
	Insert = GetService("InsertService"),
	Http = GetService("HttpService"),
	Run = GetService("RunService"),
	Input = GetService("UserInputService"),
	Tween = GetService("TweenService"),
	Teleport = GetService("TeleportService"),
	Chat = GetService("TextChatService"),
	Replicated = GetService("ReplicatedStorage"),
	Market = GetService("MarketplaceService"),
	Starter = GetService("StarterGui"),
	ContextActionService = GetService("ContextActionService"),
	Sound = GetService("SoundService"),
	AssetService = GetService("AssetService"),
}

local Vuln = {
	Keywords = { "destroy", "delete", "remove", "clear", "dispose" },
	Blocked = { "RemoveStat", "Clear" },
	FoundRemotes = {},
}

local Methods = {
	Get = function(URL)
		local Method = game.HttpGet
		return Method(game, URL)
	end,

	Parent = function(Child)
		xpcall(function()
			Child.Parent = (gethui and gethui()) or Services.Core
		end, function()
			Child.Parent = PlayerGui
		end)
	end,

	Check = function()
		local LocalPlayer = Services.Players.LocalPlayer
        	local Backpack = LocalPlayer:WaitForChild("Backpack")
        	local Character = LocalPlayer.Character or CWait(LocalPlayer.CharacterAdded)

		if Services.Replicated:FindFirstChild("DeleteCar") then
			return true
		elseif Character:FindFirstChild("HandlessSegway") then
			return true
		elseif Backpack:FindFirstChild("Building Tools") then
			return true
		else
			for _, Descendant in next, game:GetDescendants() do
				if
					(Descendant:IsA("RemoteEvent") or Descendant:IsA("UnreliableRemoteEvent"))
					and (not table.find(Vuln.Blocked, Descendant.Name))
				then
					local HasKeyword = false

					for _, Keyword in next, Vuln.Keywords do
						local Found = string.lower(Descendant.Name):find(Keyword)

						if Found then
							HasKeyword = true
							break
						end
					end

					if HasKeyword then
						if Descendant.Name == "DestroySegway" or Settings.Toggles.UnsureVulnDetector then
							table.insert(Vuln.FoundRemotes, Descendant)
						end	
					end
				end
			end

			if #Vuln.FoundRemotes > 0 then
				return true
			end
		end
	end,

	Destroy = function(Part)
		local Keywords = { "destroy", "delete", "remove", "clear", "dispose" }
		local LocalPlayer = Services.Players.LocalPlayer

		if Services.Replicated:FindFirstChild("DeleteCar") then
			Services.Replicated.DeleteCar:FireServer(Part)
		elseif Services.Replicated:FindFirstChild("GuiHandler") then
			Services.Replicated.GuiHandler:FireServer(false, Part)
		elseif LocalPlayer.Backpack:FindFirstChild("Building Tools") then
			local ArgumentTable = { [1] = "Remove", [2] = { [1] = Part } }
			LocalPlayer.Backpack
				:FindFirstChild("Building Tools").SyncAPI.ServerEndpoint
				:InvokeServer(Unpack(ArgumentTable))
		else
			local Arguments = (function()
				local Return = {}

				for Index = 1, 10 do
					Return[Index] = Part
				end

				return Return
			end)()

			for Remote, Ignore in next, Vuln.FoundRemotes do
				if Ignore.Name == "DestroySegway" then
					Ignore:FireServer(Part, { Value = Part })
				else
					Ignore:FireServer(table.unpack(Arguments))
				end
			end
		end
	end,
}

local LocalPlayer = Services.Players.LocalPlayer
local Character = LocalPlayer.Character
local Backpack = LocalPlayer:WaitForChild("Backpack")
local Humanoid = (Character and Character:FindFirstChildOfClass("Humanoid"))
local Root = (Character and Character:FindFirstChild("HumanoidRootPart"))

Connect(LocalPlayer.CharacterAdded, function(Char)
	Character = Char
	Humanoid = Character:WaitForChild("Humanoid")
	Root = (Character:FindFirstChild("HumanoidRootPart"))
	Backpack = LocalPlayer.Backpack
end)

local Lower, Split, Sub, GSub, Find, Match, Format, Blank =
	string.lower, string.split, string.sub, string.gsub, string.find, string.match, string.format, "", ""

local Unpack, Insert, Discover, Concat, Remove, FullArgs =
	table.unpack, table.insert, table.find, table.concat, table.remove, {}

local Spawn, Delay, Wait = task.spawn, task.delay, task.wait

local JSONEncode, JSONDecode, GenerateGUID =
	Services.Http.JSONEncode, Services.Http.JSONDecode, Services.Http.GenerateGUID

local Mouse, PlayerGui = LocalPlayer.GetMouse(LocalPlayer), LocalPlayer.PlayerGui

local Camera = workspace.CurrentCamera
local RespectFilteringEnabled = Services.Sound.RespectFilteringEnabled

local GetModule = function(Name)
	return (Methods.Get(Format("https://raw.githubusercontent.com/lxte/modules/main/cmd/%s", Name)))
end

local Check = function(Type)
	if Type == "File" then
		return (isfile and isfolder and writefile and readfile)
	elseif Type == "Hook" then
		return (hookmetamethod or hookfunction)
	end
end

-- another check in case humanoid not found lmao
if (not Character) or (not Humanoid) or (not Root) then
	Spawn(function()
		Character = (Character or CWait(LocalPlayer.CharacterAdded))
		Humanoid = Character:FindFirstChildOfClass("Humanoid")
		Root = Character:FindFirstChild("HumanoidRootPart")
	end)
end

-- :: INSERT[UI] :: --
local UI = (Services.Run:IsStudio() and script.Parent) or Services.Insert:LoadLocalAsset(Settings.CustomUI)

local Assets = UI.Assets
local Notification = UI.Frame
local CommandBar = UI.Cmd.CommandBar
local Tab = UI.Tab
local Button = UI.OpenButton

local Components = Assets.Components
local Features = Assets.Features

local Autofill = CommandBar.Autofill
local Search = CommandBar.Search
local BarShadow = CommandBar.Shadow

local Input = Search.TextBox
local Recommend = Search.Recommend
local Press = Search.Press

Methods.Parent(UI)
UI.Name = (GenerateGUID(Services.Http))
Tab.Name = (GenerateGUID(Services.Http))

-- :: FUNCTIONS :: --
local UDimMultiply = function(UDim, Amount)
	local Values = {
		UDim.X.Scale * Amount,
		UDim.X.Offset * Amount,
		UDim.Y.Scale * Amount,
		UDim.Y.Offset * Amount,
	}

	return UDim2.new(Unpack(Values))
end

local Minimum = function(Table, Minimum)
	local New = {}

	if Table then
		for i, v in next, Table do
			if i == Minimum or i > Minimum then
				Insert(New, v)
			end
		end
	end

	return New
end

local ConnectMessaged = function(Target: Player, Function: (string) -> ())
	if Target and Function and UI then
		Connect(Services.Chat.MessageReceived, function(Message)
			local TextSource = Message.TextSource

			if TextSource then
				local Player = Services.Players:GetPlayerByUserId(TextSource.UserId)

				if Player == Target then
					Function(Message.Text)
				end
			end
		end)
	end
end

local StringToInstance = function(String)
	local Path = Split(String, ".")
	local Current = game

	if Path[1] == "workspace" then
		Current = Services.Workspace
	end

	Remove(Path, 1)

	for Index, Child in next, Path do
		Current = Current[Child]
	end

	return Current
end

Spoof = function(Instance, Property, Value)
	local Hook

	if not Check("Hook") then
		return
	end

	Hook = hookmetamethod(game, "__index", newcclosure(function(self, Key)
		if self == Instance and Key == Property then
			return Value
		end

		return Hook(self, Key)
	end))
end

local Chat = function(Message)
	Services.Chat.TextChannels.RBXGeneral:SendAsync(Message)
end

local Foreach = function(Table, Func, Loop)
	for Index, Value in next, Table do
		pcall(function()
			if Loop and typeof(Value) == "table" then
				for Index2, Value2 in next, Value do
					Func(Index2, Value2)
				end
			else
				Func(Index, Value)
			end
		end)
	end
end

local FindTable = function(Table, Input)
	for Index, Value in next, Table do
		if Value == Input then
			return Value
		end
	end
end

local MultiSet = function(Object, Properties)
	for Index, Property in next, Properties do
		Object[Index] = Property
	end

	return Object
end

local Create = function(ClassName, Properties, Children)
	local Object = Instance.new(ClassName)

	for i, Property in next, Properties or {} do
		Object[i] = Property
	end

	for i, Children in next, Children or {} do
		Children.Parent = Object
	end

	return Object
end

local SetSRadius = setsimulationradius
	or function(Radius, MaxRadius)
		Spawn(function()
			LocalPlayer.SimulationRadius = Radius
			LocalPlayer.MaxSimulationDistance = MaxRadius
		end)
	end

local AttachName = GenerateGUID(Services.Http)
local Attach = function(Part, Target)
	if Part and Part:IsA("BasePart") and not Part.Anchored then
		local ModelDescendant = Part:FindFirstAncestorOfClass("Model")
		SetSRadius(9e9, 9e9)

		if ModelDescendant then
			if Services.Players:GetPlayerFromCharacter(ModelDescendant) then
				return
			end
		end

		local Attachment = Instance.new("Attachment")
		local Position = Instance.new("AlignPosition")
		local Orientation = Instance.new("AlignOrientation")
		local Attachment2 = Instance.new("Attachment")

		Attachment.Name = AttachName
		Position.Name = AttachName
		Orientation.Name = AttachName
		Attachment2.Name = AttachName

		Attachment.Parent = Part
		Position.Parent = Part
		Orientation.Parent = Part
		Attachment2.Parent = (Target or Root)

		Position.Responsiveness = 200
		Orientation.Responsiveness = 200

		Position.MaxForce = 9e9
		Orientation.MaxTorque = 9e9

		Position.Attachment0 = Attachment
		Position.Attachment1 = Attachment2
		Orientation.Attachment1 = Attachment2
		Orientation.Attachment0 = Attachment

		Part.CanCollide = false

		return Attachment, Position, Orientation, Attachment2
	end
end

local Bring = function(Part, Target)
	if Part and Part:IsA("BasePart") and not Part.Anchored then
		local ModelDescendant = Part:FindFirstAncestorOfClass("Model")
		local OldCollide = Part.CanCollide
		SetSRadius(9e9, 9e9)

		if ModelDescendant then
			if Services.Players:GetPlayerFromCharacter(ModelDescendant) then
				return
			end
		end

		local Attachment = Instance.new("Attachment")
		local Position = Instance.new("AlignPosition")
		local Torque = Instance.new("Torque")
		local Attachment2 = Instance.new("Attachment")

		Attachment.Parent = Part
		Position.Parent = Part
		Torque.Parent = Part
		Attachment2.Parent = (Target or Root)

		Position.Responsiveness = 200
		Position.MaxForce = 9e9
		Position.MaxVelocity = 9e9
		Torque.Torque = Vector3.new(9e9, 9e9, 9e9)

		Position.Attachment0 = Attachment
		Position.Attachment1 = Attachment2
		Position.Attachment1 = Attachment2
		Position.Attachment0 = Attachment

		Part.CanCollide = false

		Delay(1, function()
			Destroy(Attachment);
            Destroy(Position);
            Destroy(Torque);
            Destroy(Attachment2);
			Part.CanCollide = OldCollide
		end)
	end
end

local IsStaff = function(Player)
	local StaffRoles = {
		"owner",
		"admin",
		"staff",
		"mod",
		"founder",
		"manager",
		"dev",
		"president",
		"leader",
		"supervisor",
		"chairman",
		"supervising",
	}

	local CurrentRole = Player:GetRoleInGroup(game.CreatorId)

	for Index, Role in next, StaffRoles do
		if Lower(CurrentRole):find(Role) then
			return true, CurrentRole
		end
	end
end

local Tween = function(Object, Speed, Properties, Info)
	local Info = Info or {}
	local Style, Direction =
		Info["EasingStyle"] or Enum.EasingStyle.Sine, Info["EasingDirection"] or Enum.EasingDirection.Out

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetRig = function(Type)
	local Avatar = GetService("AvatarEditorService")
	Avatar:PromptSaveAvatar(Humanoid.HumanoidDescription, Enum.HumanoidRigType[Type])
	CWait(Avatar.PromptSaveAvatarCompleted)
	Command.Parse(true, "respawn")
end

local GetClasses = function(Ancestor, Class, GetChildren)
	local Results = {}

	for Index, Descendant in next, (GetChildren and Ancestor:GetChildren()) or Ancestor:GetDescendants() do
		if Descendant:IsA(Class) then
			Insert(Results, Descendant)
		end
	end

	return Results
end

local SetNumber = function(Input, Minimum, Max)
	Minimum = tonumber(Minimum) or -math.huge
	Max = tonumber(Max) or math.huge

	if Input then
		local Numbered = tonumber(Input)

		if Numbered and (Numbered == (Minimum or Max) or (Numbered < Max) or (Numbered > Minimum)) then
			return Numbered
		elseif Lower(Input) == "inf" then
			return Max
		else
			return 0
		end
	else
		return 0
	end
end

local GetCharacter = function(Player)
	return (Player and Player.Character)
end

local GetRoot = function(Player)
	local Char = GetCharacter(Player)
	return (Char and Char:FindFirstChild("HumanoidRootPart"))
end

local GetHumanoid = function(Player)
	local Char = GetCharacter(Player)
	return (Char and Char:FindFirstChildOfClass("Humanoid"))
end

local PlayerArguments = {
	["all"] = function()
		return (Services.Players:GetPlayers())
	end,

	["others"] = function()
		local Targets = {}
		Foreach(Services.Players:GetPlayers(), function(Index, Player)
			if Player ~= LocalPlayer then
				Insert(Targets, Player)
			end
		end)
		return Targets
	end,

	["me"] = function()
		return { LocalPlayer }
	end,

	["random"] = function()
		local Amount = Services.Players:GetPlayers()
		return { Amount[math.random(1, #Amount)] }
	end,

	["npc"] = function()
		local Targets = {}
		for Index, Model in next, GetClasses(workspace, "Model") do
			if Model:FindFirstChildOfClass("Humanoid") and not Services.Players:GetPlayerFromCharacter(Model) then
				Insert(Targets, Model)
			end
		end
		return Targets
	end,

	["seated"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local PHumanoid = GetHumanoid(Player)
			if PHumanoid and PHumanoid.Sit then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,

	["stood"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local PHumanoid = GetHumanoid(Player)
			if PHumanoid and not PHumanoid.Sit then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,

	["closest"] = function()
		local Targets = {}
		local ClosestDistance = 9e9
		local ClosestPlayer
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local Distance = Player:DistanceFromCharacter(Root.Position)
			if (Player ~= LocalPlayer) and (Distance < ClosestDistance) then
				ClosestDistance = Distance
				ClosestPlayer = Player
			end
		end
		return { ClosestPlayer }
	end,

	["farthest"] = function()
		local Targets = {}
		local FurthestDistance, FurthestPlayer = 0, nil
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local Distance = Player:DistanceFromCharacter(Root.Position)
			if (Player ~= LocalPlayer) and (Distance > FurthestDistance) then
				FurthestDistance = Distance
				FurthestPlayer = Player
			end
		end
		return { FurthestPlayer }
	end,

	["enemies"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			if Player.Team ~= LocalPlayer.Team then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,

	["dead"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local PHumanoid = GetHumanoid(Player)
			if PHumanoid and PHumanoid.Health == 0 then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,

	["alive"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local PHumanoid = GetHumanoid(Player)
			if PHumanoid and PHumanoid.Health > 0 then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,

	["friends"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			if (Player:IsFriendsWith(LocalPlayer.UserId)) and (LocalPlayer ~= Player) then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,

	["nonfriends"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			if (not Player:IsFriendsWith(LocalPlayer.UserId)) and (LocalPlayer ~= Player) then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,
}

local GetPlayer = function(Target)
	local Target = Lower(Target)
	local PlayerType = PlayerArguments[Target]

	if PlayerType then
		return PlayerType()
	else
		local Specific = {}
		Foreach(Services.Players:GetPlayers(), function(Index, Player)
			local Name, Display = Lower(Player.Name), Lower(Player.DisplayName)
			if Sub(Name, 1, #Target) == Target then
				Insert(Specific, Player)
			elseif Sub(Display, 1, #Target) == Target then
				Insert(Specific, Player)
			end
		end)
		return Specific
	end
end

local Fling = function(Targets: { Player })
	local Flinged = 0

	if not (Character and Humanoid and Root) then
		return
	end

	local Loop = function(TargetRoot, _Character, _Humanoid)
		local Duration = 2
		local Start = tick()

		repeat Wait()
			local Magnitude = TargetRoot.Velocity.Magnitude
			local Direction = _Humanoid and _Humanoid.MoveDirection or Vector3.zero

			local PredictionOffset = Direction * (Magnitude / Random.new():NextNumber(0, 2.5)) - Vector3.new(0, 0.2, 0)
			local TargetCFrame = CFrame.new(TargetRoot.Position)
			local PredictedCFrame = TargetCFrame * CFrame.new(PredictionOffset)

			Root.CFrame = PredictedCFrame
			Character:SetPrimaryPartCFrame(PredictedCFrame)
			Root.Velocity = Vector3.new(1, 2, 1) * 9e9
			Root.RotVelocity = Vector3.new(1, 2, 1) * 9e9
		until not TargetRoot
			or (TargetRoot.Velocity.Magnitude > 500)
			or not _Character
			or not _Humanoid
			or (tick() - Start >= Duration)

		if TargetRoot and (TargetRoot.Velocity.Magnitude > 500) then
			Flinged += 1
		end
	end

	local OriginalPos = Root.CFrame * CFrame.new(0, 1, 0)
	local OldHeight = workspace.FallenPartsDestroyHeight
	local BodyVelocity = Instance.new("BodyVelocity")

	workspace.FallenPartsDestroyHeight = 1 / 0
	BodyVelocity.Velocity = Vector3.new(1, 1, 1) * 9e9
	BodyVelocity.MaxForce = Vector3.new(10, 10, 10) * 9e9
	BodyVelocity.Parent = Root

	for _, TargetPlayer in next, Targets do
		local _Character = TargetPlayer.Character
		local _Humanoid = _Character and _Character:FindFirstChildOfClass("Humanoid")
		local _RootPart = _Humanoid and _Humanoid.RootPart

		if _Character and _RootPart then
			Camera.CameraSubject = _RootPart
			Loop(_RootPart, _Character, _Humanoid)
		end
	end

	Destroy(BodyVelocity);

	repeat Wait()
		Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
		Camera.CameraSubject = Humanoid

		Root.Velocity = Vector3.new()
		Root.RotVelocity = Vector3.new()

		for _, Part in next, GetClasses(Character, "BasePart") do
			Part.Velocity = Vector3.new()
			Part.RotVelocity = Vector3.new()
		end

		Root.CFrame = OriginalPos
		Character:SetPrimaryPartCFrame(OriginalPos)
		Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
	until (Root.Velocity.Magnitude < 10) and (Root.Position - OriginalPos.Position).Magnitude < 10

	workspace.FallenPartsDestroyHeight = OldHeight
	return Flinged
end

local SetFly
local ThumbstickMoved

Spawn(function()
	local Movement = { forward = 0, backward = 0, right = 0, left = 0 }
	local FlySpeed = 3
	local DeadZone = 0.15
	local DeadZoneNormalized = 1 - DeadZone
	local Flying = false

	local TouchGui = PlayerGui:FindFirstChild("TouchGui")
	local TouchFrame = TouchGui and TouchGui:FindFirstChild("TouchControlFrame")

	local BodyGyro = Instance.new("BodyGyro")
	local BodyVelocity = Instance.new("BodyVelocity")

	BodyVelocity.MaxForce = Vector3.new(1, 1, 1) * 10 ^ 6
	BodyGyro.MaxTorque = Vector3.new(1, 1, 1) * 10 ^ 6
	BodyGyro.P = 10 ^ 6
	BodyVelocity.P = 10 ^ 4

	local SetFlying = function(Bool)
		Flying = Bool

		BodyGyro.Parent = (Flying and Root) or nil
		BodyVelocity.Parent = (Flying and Root) or nil
		BodyVelocity.Velocity = Vector3.new()

		if Flying then
			BodyGyro.CFrame = Root.CFrame
		end
	end

	local Modify = function(New)
		Movement = New or Movement
		if Flying then
			local isMoving = Movement.right + Movement.left + Movement.forward + Movement.backward > 0
		end
	end

	local MovementBind = function(Action, State, Object)
		if State == Enum.UserInputState.Begin then
			Movement[Action] = 1
		elseif State == Enum.UserInputState.End then
			Movement[Action] = 0
		end

		Modify()
		return Enum.ContextActionResult.Pass
	end

	local isTouchOnThumbstick = function(Position)
		if not TouchFrame then
			return false
		end

		local ClassicFrame = TouchFrame:FindFirstChild("ThumbstickFrame")
		local DynamicFrame = TouchFrame:FindFirstChild("DynamicThumbstickFrame")
		local StickFrame = (ClassicFrame and ClassicFrame.Visible) and ClassicFrame or DynamicFrame

		if StickFrame then
			local StickPosition = StickFrame.AbsolutePosition
			local StickSize = StickFrame.AbsoluteSize
			return Position.X >= StickPosition.X
				and Position.X <= (StickPosition.X + StickSize.X)
				and Position.Y >= StickPosition.Y
				and Position.Y <= (StickPosition.Y + StickSize.Y)
		end
		return false
	end

	local Updated = function()
		if Flying then
			local Position = workspace.CurrentCamera.CFrame
			local Direction = Position.rightVector * (Movement.right - Movement.left)
				+ Position.lookVector * (Movement.forward - Movement.backward)

			if Direction:Dot(Direction) > 0 then
				Direction = Direction.unit
			end

			BodyGyro.CFrame = Position
			BodyVelocity.Velocity = Direction * Humanoid.WalkSpeed * FlySpeed
		end
	end

	Connect(Services.Input.TouchStarted, function(touch, gameProcessedEvent)
		ThumbstickMoved = isTouchOnThumbstick(touch.Position)
	end)

	Connect(Services.Input.TouchEnded, function(touch, gameProcessedEvent)
		if ThumbstickMoved then
			ThumbstickMoved = false
			Modify({ forward = 0, backward = 0, right = 0, left = 0 })
		end
	end)

	Connect(Services.Input.TouchMoved, function(touch, gameProcessedEvent)
		if ThumbstickMoved then
			local MouseVector = Humanoid.MoveDirection
			local LeftRight = MouseVector.X
			local ForeBack = MouseVector.Z

			Movement.left = LeftRight < -DeadZone and -(LeftRight - DeadZone) / DeadZoneNormalized or 0
			Movement.right = LeftRight > DeadZone and (LeftRight - DeadZone) / DeadZoneNormalized or 0

			Movement.forward = ForeBack < -DeadZone and -(ForeBack - DeadZone) / DeadZoneNormalized or 0
			Movement.backward = ForeBack > DeadZone and (ForeBack - DeadZone) / DeadZoneNormalized or 0
			Modify()
		end
	end)

	SetFly = function(Boolean, SpeedValue)
		FlySpeed = SpeedValue or 1
		SetFlying(Boolean)
		Connect(Services.Run.RenderStepped, Updated)
	end

	Services.ContextActionService:BindAction("forward", MovementBind, false, Enum.PlayerActions.CharacterForward)
	Services.ContextActionService:BindAction("backward", MovementBind, false, Enum.PlayerActions.CharacterBackward)
	Services.ContextActionService:BindAction("left", MovementBind, false, Enum.PlayerActions.CharacterLeft)
	Services.ContextActionService:BindAction("right", MovementBind, false, Enum.PlayerActions.CharacterRight)
end)


Tab.Visible = false
CommandBar.Actions.Description.Text = Settings.Version
CommandBar.Visible = false
CommandBar.GroupTransparency = 1

-- :: LIBRARY[UI] :: --
local Type
local API = {}
local Library = { Tabs = {} }
local Fill = {}
local Globals = {}
local Feature = {}

local Add = function(Global, Value)
	Globals[Global] = Value
end

local Get = function(Global)
	return Globals[Global]
end

local Refresh = function(Global, NewValue)
	Add(Global, false); Wait(0.2)
	Add(Global, NewValue)
end

local Animate = {
	Set = function(Component, Title, Description)
		local Labels = Component.Frame
		local TLabel, DLabel = Labels.Title, Labels.Description

		if Title then
			TLabel.Text = Title
		else
			Destroy(TLabel)
		end

		if Description then
			DLabel.Text = Description
		else
			Destroy(DLabel)
		end
	end,

	Open = function(Window, Transparency, Size, CheckVisible, Center, Amount)
		if (CheckVisible and not Window.Visible) or not CheckVisible then
			local Size = (Size or Window.Size)
			local NewSize = UDimMultiply(Size, Amount or 1.1)
			local Outline = Window:FindFirstChildOfClass("UIStroke")

			MultiSet(Outline, { Transparency = 1 })
			MultiSet(Window, {
				Size = NewSize,
				GroupTransparency = 1,
				Visible = true,
				Position = (Center and UDim2.fromScale(0.5, 0.5)) or Window.Position,
			})

			Tween(Outline, 0.25, { Transparency = 0.8 })
			Tween(Window, 0.25, {
				Size = Size,
				GroupTransparency = Transparency or 0,
			})
		end
	end,

	Close = function(Window, Amount, Invisible)
		Spawn(function()
			local Size = Window.Size
			local NewSize = UDimMultiply(Size, Amount or 1.1)
			local Outline = Window:FindFirstChildOfClass("UIStroke")

			Tween(Outline, 0.25, { Transparency = 1 })
			Tween(Window, 0.25, {
				Size = NewSize,
				GroupTransparency = 1,
			})

			if Invisible then
				Wait(0.25)
				Window.Visible = false
			end
		end)
	end,

	Drag = function(Window, UseAlternative, AllowOffScreen)
		if Window then
			local Dragging
			local DragInput
			local Start
			local StartPosition

			if
				not UseAlternative
				and Discover({ Enum.Platform.IOS, Enum.Platform.Android }, Services.Input:GetPlatform())
			then
				AllowOffScreen = true
			end

			local function Update(Input)
				local Delta = Input.Position - Start
				local Screen = UI.AbsoluteSize
				local Absolute = Window.AbsoluteSize

				local PosX, PosY

				if AllowOffScreen then
					PosX = StartPosition.X.Offset + Delta.X
					PosY = StartPosition.Y.Offset + Delta.Y
				else
					PosX = math.clamp(
						StartPosition.X.Offset + Delta.X,
						-(Screen.X / 2) + (Absolute.X / 2),
						(Screen.X / 2) - (Absolute.X / 2)
					)

					PosY = (function()
						if UseAlternative then
							return math.clamp(StartPosition.Y.Offset + Delta.Y, 0, Screen.Y - Absolute.Y)
						else
							return math.clamp(
								StartPosition.Y.Offset + Delta.Y,
								-(Screen.Y / 2) + (Absolute.Y / 2),
								(Screen.Y / 2) - (Absolute.Y / 2)
							)
						end
					end)()
				end

				Window.Position = UDim2.new(StartPosition.X.Scale, PosX, StartPosition.Y.Scale, PosY)
			end

			Connect(Window.InputBegan, function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseButton1
					or Input.UserInputType == Enum.UserInputType.Touch and not Type
				then
					Dragging = true
					Start = Input.Position
					StartPosition = Window.Position

					Connect(Input.Changed, function()
						if Input.UserInputState == Enum.UserInputState.End then
							Dragging = false
						end
					end)
				end
			end)

			Connect(Window.InputChanged, function(Input)
				if
					Input.UserInputType == Enum.UserInputType.MouseMovement
					or Input.UserInputType == Enum.UserInputType.Touch and not Type
				then
					DragInput = Input
				end
			end)

			Connect(Services.Input.InputChanged, function(Input)
				if Input == DragInput and Dragging and not Type then
					Update(Input)
				end
			end)
		end
	end,
}

local Color = function(Color, Factor, Mode)
	Mode = Mode or Settings.Theme.Mode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

function Library:CreateWindow(Config: { Title: string })
	local Window = Clone(Tab)
	local Animations = {}
	local Component = {}

	local Actions = Window.Actions
	local Tabs = Window.Tabs
	local Topbar = Window.Topbar

	local TabName = Topbar.Title
	local WindowName = Topbar.Description
	local SearchBox = Topbar.SearchBox

	local Previous = "Home"
	local Current = "Home"

	local Maximized = false
	local Minimzied = false

	local Minimum, Maximum = Vector2.new(204, 220), Vector2.new(9e9, 9e9)

	local List = {
		BottomLeft = { X = Vector2.new(-1, 0), Y = Vector2.new(0, 1) },
		BottomRight = { X = Vector2.new(1, 0), Y = Vector2.new(0, 1) },
	}

	Spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Window and Window:FindFirstChild("Background") then
			local Positions = Window:FindFirstChild("Background")

			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Mouse.X, Mouse.Y)
						Size = Window.AbsoluteSize
						UIPos = Window.Position
					end
				end)

				Connect(Types.InputEnded, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = nil
					end
				end)
			end
		end

		local Resize = function(Delta)
			if Type and MousePos and Size and UIPos and Window:FindFirstChild("Background")[Type.Name] == Type then
				local Mode = List[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(
					math.clamp(NewSize.X, Minimum.X, Maximum.X),
					math.clamp(NewSize.Y, Minimum.Y, Maximum.Y)
				)

				local AnchorOffset = Vector2.new(Window.AnchorPoint.X * Size.X, Window.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Window.AnchorPoint.X * NewSize.X, Window.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Window.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)

				local NewPosition = UDim2.new(
					UIPos.X.Scale,
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Window.Position = NewPosition
			end
		end

		Connect(Mouse.Move, function()
			if Type then
				pcall(function()
					Resize(Vector2.new(Mouse.X, Mouse.Y) - MousePos)
				end)
			end
		end)
	end)

	WindowName.Text = Config.Title
	Window.Parent = UI
	Window.Name = (GenerateGUID(Services.Http))

	Library.Tabs[Config.Title] = {
		Open = function()
			Animate.Open(Window, Settings.Theme.Transparency, UDim2.fromOffset(345, 418), false, true)
		end,
	}

	Library.Tabs[Config.Title].Open()
	Animate.Drag(Window)

	--// Animations

	function Animations:SetTab(Name)
		TabName.Text = Name
		Current = Name

		for Index, Main in next, Tabs:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name)
				local Scroll = Main.ScrollingFrame
				local Padding = Scroll.UIPadding

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, 0.3, { GroupTransparency = 0 })
					Tween(Padding, 0.3, { PaddingTop = UDim.new(0, 8) })
				elseif not SameName and Opened.Value then
					Previous = Main.Name
					Opened.Value = false

					Tween(Main, 0.15, { GroupTransparency = 1 })
					Tween(Padding, 0.15, { PaddingTop = UDim.new(0, 18) })

					Delay(0.2, function()
						Main.Visible = false
					end)
				end
			end
		end
	end

	function Animations:Component(Button, Custom)
		local Size = Button.Size

		Connect(Button.InputBegan, function()
			if Custom then
				Tween(Button, 0.25, { Transparency = 0, Size = UDimMultiply(Size, 1.1) })
			else
				Tween(
					Button,
					0.25,
					{ BackgroundColor3 = Color(Settings.Theme.Component, 5), Size = UDimMultiply(Size, 1.015) }
				)
			end
		end)

		Connect(Button.InputEnded, function()
			if Custom then
				Tween(Button, 0.25, { Transparency = 1, Size = Size })
			else
				Tween(Button, 0.25, { BackgroundColor3 = Settings.Theme.Component, Size = Size })
			end
		end)
	end

	--// Components
	function Component:Set(Component, Title, Description)
		local Labels = Component.Frame
		local TLabel, DLabel = Labels.Title, Labels.Description

		if Title then
			TLabel.Text = Title
		else
			Destroy(TLabel)
		end

		if Description then
			DLabel.Text = Description
		else
			Destroy(DLabel)
		end
	end

	function Component:GetTab(Name)
		return Tabs[Name].ScrollingFrame
	end

	function Component:AddTab(Config: { Title: string, Description: string, Tab: string })
		local Button = Clone(Components["Section"])
		local Tab = Clone(Components["SectionExample"])

		Connect(Button.MouseButton1Click, function()
			Animations:SetTab(Config.Title)
		end)

		Animations:Component(Button)
		Component:Set(Button, Config.Title, Config.Description)
		MultiSet(Tab, { Parent = Tabs, Name = Config.Title })
		MultiSet(Button, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddDropdown(
		Config: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any }
	)
		local Dropdown = Clone(Components["Dropdown"])
		local Background = Window.Background
		local Text = Dropdown.Holder.Main.Title

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Features.DropdownExample)
			local Buttons = Example.Actions

			Tween(Background, 0.25, { BackgroundTransparency = 0.6 })

			Example.Parent = Window
			Animate.Open(Example, 0)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					Connect(Button.MouseButton1Click, function()
						Tween(Background, 0.25, { BackgroundTransparency = 1 })
						Animate.Close(Example)

						Wait(0.25)
						Destroy(Example)
					end)
				end
			end

			for Index, Option in next, Config.Options do
				local Button = Clone(Features.DropdownButtonExample)

				Animations:Component(Button)
				Component:Set(Button, Index)
				MultiSet(Button, { Parent = Example.ScrollingFrame, Visible = true })

				Connect(Button.MouseButton1Click, function()
					Tween(Button, 0.25, { BackgroundColor3 = Settings.Theme.Component })
					Config.Callback(Option, Dropdown)

					Text.Text = Index

					for Index, Others in next, Example:GetChildren() do
						if Others:IsA("TextButton") and Others ~= Button then
							Others.BackgroundColor3 = Settings.Theme.Component
						end
					end

					Tween(Background, 0.25, { BackgroundTransparency = 1 })
					Animate.Close(Example)

					Wait(0.25)
					Destroy(Example)
				end)
			end
		end)

		Component:Set(Dropdown, Config.Title, Config.Description)
		Animations:Component(Dropdown)

		MultiSet(Dropdown, {
			Name = Config.Title,
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddButton(Config: { Title: string, Description: string, Tab: string, Callback: any })
		local Button = Clone(Components["Button"])

		Component:Set(Button, Config.Title, Config.Description)
		Animations:Component(Button)

		Connect(Button.MouseButton1Click, function()
			Config.Callback(Button)
		end)

		MultiSet(Button, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddInput(
		Config: { Title: string, Description: string, Tab: string, Default: string, Callback: any }
	)
		local Button = Clone(Components["Input"])
		local Box = Button.Main.TextBox

		Box.Text = Config.Default or Blank
		Component:Set(Button, Config.Title, Config.Description)
		Animations:Component(Button)

		Connect(Button.MouseButton1Click, function()
			Box:CaptureFocus()
		end)

		Connect(Box.FocusLost, function()
			Config.Callback(Box.Text)
			Box.PlaceholderText = Box.Text
		end)

		MultiSet(Button, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddSection(Config: { Title: string, Tab: string })
		local Section = Clone(Components["TabSection"])

		Section.Title.Text = Config.Title
		MultiSet(Section, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddParagraph(Config: { Title: string, Description: string, Tab: string })
		local Paragraph = Clone(Components["Paragraph"])

		Component:Set(Paragraph, Config.Title, Config.Description)

		MultiSet(Paragraph, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})

		return Paragraph
	end

	function Component:AddKeybind(Config: { Title: string, Description: string, Tab: string, Callback: any })
		local Dropdown = Clone(Components["Keybind"])
		local Bind = Dropdown.Holder.Main.Title

		local Mouse =
			{ Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }
		local Types = {
			["Mouse"] = "Enum.UserInputType.MouseButton",
			["Key"] = "Enum.KeyCode.",
		}

		Animations:Component(Dropdown)
		Component:Set(Dropdown, Config.Title, Config.Description)

		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick()
			local Detect, Finished

			MultiSet(Bind, { Text = "..." })
			Detect = Connect(Services.Input.InputBegan, function(Key, Focused)
				local InputType = Key.UserInputType

				if not Finished and not Focused then
					Finished = true
					Config.Callback(Key)

					if Discover(Mouse, InputType) then
						MultiSet(Bind, {
							Text = tostring(InputType):gsub(Types.Mouse, "MB"),
						})
					elseif InputType == Enum.UserInputType.Keyboard then
						MultiSet(Bind, {
							Text = tostring(Key.KeyCode):gsub(Types.Key, Blank),
						})
					end
				end
			end)
		end)

		MultiSet(Dropdown, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddToggle(
		Config: { Title: string, Description: string, Tab: string, Default: boolean, Callback: any }
	)
		local Toggle = Clone(Components["Toggle"])

		local On = Toggle["Value"]
		local Main = Toggle["Main"]
		local Circle = Main["ToggleLabel"]

		local Set = function(Value)
			if Value then
				Tween(Main, 0.2, { BackgroundColor3 = Settings.Theme.Highlight })
				Tween(
					Circle,
					0.2,
					{ ImageColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) }
				)
			else
				Tween(Main, 0.2, { BackgroundColor3 = Color(Settings.Theme.Component, 10) })
				Tween(
					Circle,
					0.2,
					{ ImageColor3 = Color(Settings.Theme.Component, 15), Position = UDim2.new(0, 4, 0.5, 0) }
				)
			end

			On.Value = Value
		end

		Set(Config.Default)
		Animations:Component(Toggle)
		Component:Set(Toggle, Config.Title, Config.Description)

		Connect(Toggle.MouseButton1Click, function()
			local Value = not On.Value

			Set(Value)
			Config.Callback(Value)
		end)

		MultiSet(Toggle, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddSlider(Config: {
		Title: string,
		Description: string,
		Tab: string,
		MaxValue: number,
		AllowDecimals: boolean,
		DecimalAmount: number,
		Callback: any,
	})
		local Slider = Clone(Components["Slider"])

		local Main = Slider["Slider"]
		local Amount = Main["Main"].Input
		local Slide = Main["Slide"]
		local Fire = Slide["Fire"]
		local Fill = Slide["Highlight"]
		local Circle = Fill["Circle"]

		local Active = false
		local Value = 0

		local SetNumber = function(Number)
			if Config.AllowDecimals then
				local Power = 10 ^ (Config.DecimalAmount or 2)
				Number = math.floor(Number * Power + 0.5) / Power
			else
				Number = math.round(Number)
			end

			return Number
		end

		local Update = function(Number)
			local Scale = (Mouse.X - Slide.AbsolutePosition.X) / Slide.AbsoluteSize.X
			Scale = (Scale > 1 and 1) or (Scale < 0 and 0) or Scale

			if Number then
				Number = (Number > Config.MaxValue and Config.MaxValue) or (Number < 0 and 0) or Number
			end

			Value = SetNumber(Number or (Scale * Config.MaxValue))
			Amount.Text = Value
			Fill.Size = UDim2.fromScale((Number and Number / Config.MaxValue) or Scale, 1)
			Config.Callback(Value)
		end

		local Activate = function()
			Active = true

			repeat
				Wait()
				Update()
			until not Active
		end

		Fill.Size = UDim2.fromScale(Value, 1)
		Animations:Component(Slider)
		Component:Set(Slider, Config.Title, Config.Description)

		Connect(Amount.FocusLost, function()
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input)
			if
				Input.UserInputType == Enum.UserInputType.MouseButton1
				or Input.UserInputType == Enum.UserInputType.Touch
			then
				Active = false
			end
		end)

		MultiSet(Slider, {
			Name = Config.Title,
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	Animations:Component(Topbar.Back, true)
	Animations:Component(Topbar.Search, true)
	for Index, Button in next, Actions:GetChildren() do
		local Type = Button.Name

		if Button:IsA("GuiButton") then
			Animations:Component(Button, true)

			Connect(Button.MouseButton1Click, function()
				if Type == "Close" then
					Animate.Close(Window)
					Wait(0.25)
					Window.Visible = false
				elseif Type == "Minimize" then
					Minimzied = not Minimzied

					if Minimzied then
						Tween(Window, 0.25, { Size = UDim2.fromOffset(345, 60) })
					else
						Tween(Window, 0.25, { Size = UDim2.fromOffset(345, 394) })
					end
				elseif Type == "Maximize" then
					Maximized = not Maximized

					if Maximized then
						Tween(Window, 0.15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5) })
					else
						Tween(Window, 0.15, { Size = UDim2.fromOffset(345, 394), Position = UDim2.fromScale(0.5, 0.5) })
					end
				end
			end)
		end
	end

	Animations:SetTab("Home")
	Connect(Topbar.Back.MouseButton1Click, function()
		Animations:SetTab(Previous or "Home")
		Previous = nil
	end)

	local SearchEnabled = true
	local TweenTexts = function(Bool, Speed)
		local Transparency = (Bool and 0) or 1
		local Speed = Speed or 0.1

		Tween(TabName, Speed, { TextTransparency = Transparency })
		Tween(WindowName, Speed, { TextTransparency = Transparency })
	end

	Connect(Changed(SearchBox, "Text"), function()
		for Index, Button in next, Tabs[Current].ScrollingFrame:GetChildren() do
			if Button:FindFirstChild("Frame") then
				local Title = Button.Frame.Title
				Button.Visible = Lower(Title.Text):find(Lower(SearchBox.Text))
			end
		end
	end)

	Connect(SearchBox.FocusLost, function()
		SearchEnabled = true
		SearchBox.Visible = false
		TweenTexts(true, 0.3)
	end)

	Connect(Topbar.Search.MouseButton1Click, function()
		SearchEnabled = not SearchEnabled

		SearchBox.Visible = not SearchEnabled
		TweenTexts(SearchEnabled)

		if not SearchEnabled then
			SearchBox:CaptureFocus()
		end
	end)

	return Component
end

function API:Notify(Config: { Title: string, Description: string, Duration: number, Type: string })
	Spawn(function()
		local Info = TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local SetShadow = function(Box, Boolean)
			Tween(Box.Shadow, 0.8, {
				Transparency = (Boolean and 0.8) or 1,
			})
		end

		if Settings.Toggles.Notify then
			local Notification = Clone(Features.Notification)
			local Box = Notification.CanvasGroup

			local Timer = Box["Timer"]
			local Interact = Box["Interact"]
			local None = Enum.AutomaticSize.None

			local Methods = {
				["warn"] = { icon = "rbxassetid://18797417802", color = Color3.fromRGB(246, 233, 107) },
				["info"] = { icon = "rbxassetid://18754976792", color = Color3.fromRGB(110, 158, 246) },
				["success"] = { icon = "rbxassetid://18797434345", color = Color3.fromRGB(126, 246, 108) },
				["error"] = { icon = "rbxassetid://18797440055", color = Color3.fromRGB(246, 109, 104) },
			}

			local Information = (Methods[Lower(Config.Type or "info")] or Methods["info"])
			local Opposite = (Settings.Theme.Mode == "Dark" and "Light") or "Dark"

			Timer.BackgroundColor3 = Information.color
			Timer.Outline.Color = Color(Information.color, 25, Opposite)

			Notification.Parent = UI.Frame
			Animate.Set(Box, Config.Title, Config.Description)
			MultiSet(Box, {
				AutomaticSize = None,
				Size = UDim2.fromOffset(100, 10),
				Visible = true,
				GroupTransparency = 1,
			})

			local Duration = (tonumber(Config.Duration) or 5)
			local Closed = false

			-- very sorry for the ugly code
			local Open, Close =
				function()
					SetShadow(Box, true)
					Tween(Notification, 0.4, { Size = UDim2.fromOffset(199, 80) })
					Wait(0.1)
					Services.Tween
						:Create(Box, Info, {
							Size = UDim2.fromOffset(229, 80),
							GroupTransparency = Settings.Theme.Transparency,
						})
						:Play()
					Wait(0.3)
					Box.AutomaticSize = Enum.AutomaticSize.Y
				end, function()
					if not Closed then
						Closed = true

						SetShadow(Box, false)
						Tween(Box, 0.3, { GroupTransparency = 1 })
						Notification.AutomaticSize = None
						Tween(Notification, 0.35, { Size = UDim2.fromOffset(199, 0) })
						Tween(Notification.UIPadding, 0.3, { PaddingLeft = UDim.new(0, 600) })
						Wait(0.35)
						Destroy(Notification)
					end
				end

			Connect(Interact.MouseButton1Click, Close)
			Open()
			Tween(Timer, Duration, { Size = UDim2.fromOffset(0, 2) })
			Wait(Duration)
			Close()
		end
	end)
end

local Output = function(...)
	if Settings.Toggles.Developer then
		warn(...)
	end
end

local Themes = {
	Names = {
		["Topbar"] = function(Label)
			if Label:IsA("Frame") then
				Label.BackgroundColor3 = Settings.Theme.Secondary
			end
		end,

		["OpenButton"] = function(Label)
			if Label:IsA("TextButton") and Label.Parent == UI then
				Label.BackgroundColor3 = Settings.Theme.Primary
				Label.TextColor3 = Settings.Theme.Title
			end
		end,

		["Actions"] = function(Label)
			if Label:IsA("Frame") then
				Label.BackgroundColor3 = Settings.Theme.Actions

				for Index, Button in next, Label:GetChildren() do
					if Button:IsA("TextButton") then
						Button.BackgroundColor3 = Color(Settings.Theme.Actions, 2)
					end
				end
			end
		end,

		["Main"] = function(Label)
			if Label:IsA("Frame") or Label:IsA("CanvasGroup") then
				if Label.Parent:FindFirstChild("Value") then
					local Toggle = Label.Parent.Value
					local Circle = Label:FindFirstChild("ToggleLabel")

					if not Toggle.Value then
						Circle.ImageColor3 = Color(Settings.Theme.Component, 15)
						Label.BackgroundColor3 = Color(Settings.Theme.Component, 10)
					else
						Label.BackgroundColor3 = Settings.Theme.Highlight
					end
				else
					Label.BackgroundColor3 = Color(Settings.Theme.Component, 10)
				end
			end
		end,

		["Frame"] = function(Label)
			if Label:IsA("Frame") and Label:FindFirstChild("Title") then
				local Component = Label.Parent
				local Mode = Settings.Theme.Mode
				if Component.Name == "Paragraph" then
					Component.BackgroundColor3 = Color(Settings.Theme.Component, 2, "Light")
				else
					Component.BackgroundColor3 = Settings.Theme.Component
				end
			end
		end,

		["Slide"] = function(Label)
			if Label:IsA("Frame") then
				Label.BackgroundColor3 = Color(Settings.Theme.Component, 10)
			end
		end,

		["Point"] = function(Label)
			if Label:IsA("Frame") then
				Label.BackgroundColor3 = Color(Settings.Theme.Component, 15)
			end
		end,

		["Press"] = function(Label)
			if Label:IsA("Frame") then
				Label.BackgroundColor3 = Color(Settings.Theme.Secondary, 5)
			end
		end,

		["Back"] = function(Label)
			if Label:IsA("TextButton") then
				Label.BackgroundColor3 = Color(Settings.Theme.Secondary, 5)
			end
		end,

		["Search"] = function(Label)
			if Label:IsA("TextButton") then
				Label.BackgroundColor3 = Color(Settings.Theme.Secondary, 5)
			elseif Label:IsA("Frame") then
				Label.BackgroundColor3 = Settings.Theme.Secondary
			end
		end,

		["SearchBox"] = function(Label)
			if Label:IsA("TextBox") then
				Label.PlaceholderColor3 = Settings.Theme.Description
				Label.TextColor3 = Settings.Theme.Title
			end
		end,

		--// Tables
		["Title"] = { "TextLabel", "Title", "TextColor3" },
		["Description"] = { "TextLabel", "Description", "TextColor3" },
		["Line"] = { "Frame", "Highlight", "BackgroundColor3" },
		["AutofillButton"] = { "TextButton", "Secondary", "BackgroundColor3" },
		["UIStroke"] = { "UIStroke", "Outline", "Color" },
		["Shadow"] = { "UIStroke", "Shadow", "Color" },
		["Highlight"] = { "Frame", "Highlight", "BackgroundColor3" },
		["Circle"] = { "Frame", "Highlight", "BackgroundColor3" },
		["Notification"] = { "CanvasGroup", "Primary", "BackgroundColor3", true },
		["DropdownExample"] = { "CanvasGroup", "Primary", "BackgroundColor3" },
	},

	Classes = {
		["TextBox"] = function(Label)
			if Label.Name ~= "Recommend" then
				Label.TextColor3 = Settings.Theme.Title
			else
				Label.TextColor3 = Settings.Theme.Description
			end
		end,

		["CanvasGroup"] = function(Label)
			if Label.Parent == UI then
				Label.BackgroundColor3 = Settings.Theme.Primary
				Label.GroupTransparency = Settings.Theme.Transparency
			end
		end,

		["ImageLabel"] = function(Label)
			if Label.Image ~= "rbxassetid://6644618143" then
				Label.ImageColor3 = Settings.Theme.Icon
			end
		end,

		["ScrollingFrame"] = function(Label)
			Label.ScrollBarImageColor3 = Settings.Theme.ScrollBar
		end,
	},
}

local DefaultThemes = {
	["Dark"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(25, 25, 25),
		Secondary = Color3.fromRGB(30, 30, 30),
		Actions = Color3.fromRGB(30, 33, 52),
		Component = Color3.fromRGB(30, 30, 30),
		Highlight = Color3.fromRGB(86, 159, 204),
		ScrollBar = Color3.fromRGB(39, 39, 39),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(52, 52, 52),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["Dracula"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(40, 42, 54),
		Secondary = Color3.fromRGB(46, 48, 62),
		Actions = Color3.fromRGB(58, 61, 77),
		Component = Color3.fromRGB(43, 45, 59),
		Highlight = Color3.fromRGB(98, 114, 164),
		ScrollBar = Color3.fromRGB(23, 24, 31),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(51, 54, 68),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["Latte"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(45, 36, 36),
		Secondary = Color3.fromRGB(53, 42, 42),
		Actions = Color3.fromRGB(65, 52, 52),
		Component = Color3.fromRGB(53, 42, 42),
		Highlight = Color3.fromRGB(207, 101, 109),
		ScrollBar = Color3.fromRGB(23, 24, 31),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(65, 52, 52),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["Light"] = {
		Mode = "Light",
		Transparency = 0,
		Primary = Color3.fromRGB(255, 255, 255),
		Secondary = Color3.fromRGB(245, 245, 245),
		Actions = Color3.fromRGB(225, 232, 238),
		Component = Color3.fromRGB(245, 245, 245),
		Highlight = Color3.fromRGB(153, 155, 255),
		ScrollBar = Color3.fromRGB(150, 150, 150),
		Title = Color3.fromRGB(40, 40, 40),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(230, 230, 230),
		Icon = Color3.fromRGB(40, 40, 40),
	},

	["Nord"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(41, 47, 56),
		Secondary = Color3.fromRGB(46, 52, 64),
		Actions = Color3.fromRGB(107, 135, 156),
		Component = Color3.fromRGB(46, 52, 64),
		Highlight = Color3.fromRGB(136, 192, 208),
		ScrollBar = Color3.fromRGB(51, 59, 70),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(200, 200, 200),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(59, 66, 82),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["Void"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(15, 15, 15),
		Secondary = Color3.fromRGB(20, 20, 20),
		Actions = Color3.fromRGB(12, 16, 22),
		Component = Color3.fromRGB(20, 20, 20),
		Highlight = Color3.fromRGB(84, 132, 164),
		ScrollBar = Color3.fromRGB(30, 30, 30),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(25, 25, 25),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["Discord"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(40, 43, 48),
		Secondary = Color3.fromRGB(54, 57, 62),
		Actions = Color3.fromRGB(62, 64, 68),
		Component = Color3.fromRGB(47, 50, 55),
		Highlight = Color3.fromRGB(114, 137, 218),
		ScrollBar = Color3.fromRGB(47, 51, 57),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(66, 69, 73),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["RC7"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(11, 47, 80),
		Secondary = Color3.fromRGB(20, 58, 96),
		Actions = Color3.fromRGB(20, 60, 94),
		Component = Color3.fromRGB(19, 54, 90),
		Highlight = Color3.fromRGB(89, 121, 180),
		ScrollBar = Color3.fromRGB(10, 45, 75),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(33, 72, 105),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["RC7 Red"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(70, 36, 33),
		Secondary = Color3.fromRGB(66, 34, 31),
		Actions = Color3.fromRGB(89, 42, 42),
		Component = Color3.fromRGB(66, 34, 31),
		Highlight = Color3.fromRGB(255, 88, 88),
		ScrollBar = Color3.fromRGB(77, 32, 29),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(175, 175, 175),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(89, 46, 42),
		Icon = Color3.fromRGB(255, 255, 255),
	},

	["c00l 1337"] = {
		Mode = "Dark",
		Transparency = 0,
		Primary = Color3.fromRGB(0, 0, 0),
		Secondary = Color3.fromRGB(0, 0, 0),
		Actions = Color3.fromRGB(255, 0, 0),
		Component = Color3.fromRGB(10, 10, 10),
		Highlight = Color3.fromRGB(255, 0, 0),
		ScrollBar = Color3.fromRGB(20, 20, 20),
		Title = Color3.fromRGB(255, 255, 255),
		Description = Color3.fromRGB(155, 155, 155),
		Shadow = Color3.fromRGB(0, 0, 0),
		Outline = Color3.fromRGB(255, 0, 0),
		Icon = Color3.fromRGB(255, 255, 255),
	},
}

local SetTheme = function(Table)
	Settings.Theme = Table or Settings.Theme
	CommandBar.BackgroundColor3 = Settings.Theme.Primary

	for Index, Descendant in next, UI:GetDescendants() do
		xpcall(function()
			local Name = Themes.Names[Descendant.Name]
			local Class = Themes.Classes[Descendant.ClassName]

			if Name then
				if typeof(Name) == "table" then
					local ClassName, NewColor, NewProperty, SetTransparency = unpack(Name)

					if ClassName == "any" or ClassName == Descendant.ClassName then
						Descendant[NewProperty] = Settings.Theme[NewColor]
					end

					if SetTransparency and Descendant:IsA("CanvasGroup") then
						Descendant.GroupTransparency = Settings.Theme.Transparency
					end
				elseif typeof(Name) == "function" then
					Name(Descendant)
				end
			elseif Class then
				Class(Descendant)
			end
		end, function(Result)
			Output("An error occured trying to load", Descendant, " error:", Result)
		end)
	end
end

-- :: IMPORTANT :: --

local EncodedSettings = function()
	local NewSettings = { Theme = {} }

	for Index, Theme in next, Settings.Theme do
		if typeof(Theme) == "Color3" then
			NewSettings.Theme[Index] = tostring(Theme)
		else
			NewSettings.Theme[Index] = tostring(Theme)
		end
	end

	for Index, Theme in next, Settings do
		if Index ~= "Theme" then
			NewSettings[Index] = Theme
		end
	end

	return JSONEncode(Services.Http, NewSettings)
end

local GetSavedSettings = function()
	local Themed = JSONDecode(Services.Http, (Check("File") and readfile("Cmd/Settings.json")) or EncodedSettings())
	local Theming = { Theme = {} }

	for Index, Theme in next, Themed.Theme do
		if typeof(Theme) == "string" and Find(Theme, ",") then
			local Clr = Color3.new(Unpack(Split(Theme, ",")))
			Theming.Theme[Index] = Color3.fromRGB(Clr.R * 255, Clr.G * 255, Clr.B * 255)
		elseif Index == "Transparency" then
			Theming.Theme[Index] = tonumber(Theme)
		elseif Index == "Mode" then
			Theming.Theme["Mode"] = tostring(Theme)
		end
	end

	for Index, Theme in next, Themed do
		if Index ~= "Theme" then
			Theming[Index] = Theme
		end
	end

	return Theming
end

local SaveSettings = function()
	if Check("File") then
		writefile("Cmd/Settings.json", EncodedSettings())
	end
end

local UpdateSettings = function(Data)
	if Check("File") then
		writefile("Cmd/Settings.json", (Data and JSONEncode(Services.Http, Data)) or EncodedSettings())
	end
end

local SetSetting = function(Table, Config, Data)
	local S = (Table and Settings[Table]) or Settings
	S[Config] = Data
	UpdateSettings()
end

-- :: LIBRARY[CMD] :: --
local Command = {}
local Commands = {}

Command.Add = function(Information)
	local Aliases = Information.Aliases
	local Description = Information.Description
	local Arguments = Information.Arguments
	local Plugin = Information.Plugin
	local Task = Information.Task

	for Index, Value in next, Aliases do
		Index = Lower(Value)
	end

	Commands[Lower(Aliases[1])] = { Aliases, Description, Arguments, Plugin, Task }
end

Command.Find = function(Input)
	for Index, Table in next, Commands do
		local Aliases = Table[1]
		local Found = FindTable(Aliases, Input)

		if Found then
			return Table
		end
	end
end

Command.Run = function(IgnoreNotifications, Name, Callbacks)
	Spawn(function()
		local Table = Command.Find(Name)

		if Table and Name ~= Blank then
			local Callback = Table[5]

			xpcall(function()
				local Title, Description, Duration, Type = Callback(Unpack(Callbacks))
				if Title and Description and not IgnoreNotifications then
					API:Notify({
						Title = Title,
						Description = Description,
						Type = "Info",
						Duration = Duration or 5,
					})
				end
			end, function(Result)
				Output(
					Format("[COMMAND ERROR] : Error occured trying to run the command - %s\nERROR: %s", Name, Result)
				)
			end)
		elseif Name ~= Blank then
			API:Notify({
				Title = "Command not found!",
				Description = Format("<b>%s</b> is not a valid command", Name),
				Type = "Error",
				Duration = 5,
			})
		end
	end)
end

Command.Parse = function(IgnoreNotifications, Input)
	local Name, ArgsString = GSub(Input, Settings.Prefix, Blank):match("^%s*([^%s]+)%s*(.*)$")

	if Name then
		local Arguments = {}
		for arg in ArgsString:gmatch("%s*([^" .. Settings.Seperator .. "]+)") do
			Insert(Arguments, arg)
		end

		FullArgs = Arguments
		Command.Run(IgnoreNotifications, Lower(Name), Arguments)
	end
end

Command.Whitelist = function(Player)
	Admins[Player.UserId] = true
	ConnectMessaged(Player, function(Message)
		if Find(Message, Settings.ChatPrefix) then
			Command.Parse(false, Split(Message, Settings.ChatPrefix)[2])
		end
	end)
end

Command.RemoveWhitelist = function(Player)
	Admins[Player.UserId] = false
end

-- :: LIBRARY[AUTOFILL] :: --
Fill.Add = function(Table)
	local Aliases, Description, Arguments, Plugin, Callback = Unpack(Table)
	local Button = Clone(Autofill.Example)
	local Labels = Button.Frame

	local Arg = Concat(Aliases, " / ")

	Labels.Title.Text = Arg
	Labels.Description.Text = Description

	MultiSet(Button, {
		Parent = Autofill,
		Visible = true,
		Name = "AutofillButton",
	})
end

Fill.Recommend = function(Input)
	if (not Settings.Toggles.Recommendation) or (#Input == 0) then
		Recommend.Text = Blank
		return
	end

	local Lowered = Lower(Split(Input, " ")[1])
	local Found = false

	--// Command Recommendation
	if #Split(Input, " ") == 1 then
		for Index, Table in Commands do
			for Index, Name in Table[1] do
				if (Find(Sub(Name, 1, #Lowered), Lower(Lowered)) or Name == Lowered) and not Found then
					Press.Title.Text = "Tab"
					Recommend.Text = GSub(Name, Lowered, Split(Input, " ")[1])
					Found = true
				end
			end
		end
	end

	if #Split(Input, " ") > 1 and UI.Parent then
		local Command = Command.Find(Lowered)
		if Command then
			local Arguments = Command[3]
			local New = Split(Input, " ")

			if #Arguments > 0 then
				if Arguments[#New - 1] and Arguments[#New - 1].Type == "Player" then
					local PlayerFound = false
					local Player = New[#New]

					--// Display Name Recommendation

					for Index, Plr in next, Services.Players:GetPlayers() do
						if Find(Sub(Lower(Plr.DisplayName), 1, #Player), Lower(Player)) then
							local Name = Format(" %s", GSub(Lower(Plr.DisplayName), Lower(Player), Player))
							Recommend.Text = Sub(Input, 1, #Input - #Player - 1) .. Name
							Found = true
							PlayerFound = true
						end
					end

					--// Username Recommendation

					if not PlayerFound then
						for Index, Plr in next, Services.Players:GetPlayers() do
							if Find(Sub(Lower(Plr.Name), 1, #Player), Lower(Player)) then
								local Name = Format(" %s", GSub(Lower(Plr.Name), Lower(Player), Player))
								Recommend.Text = Sub(Input, 1, #Input - #Player - 1) .. Name
								Found = true
								PlayerFound = true
							end
						end
					end

					--// Player Argument Recommendation

					if not PlayerFound then
						local GetPlayerArguments = {
							"all",
							"random",
							"others",
							"seated",
							"stood",
							"me",
							"closest",
							"farthest",
							"enemies",
							"dead",
							"alive",
							"friends",
							"nonfriends",
						}

						for Index, Arg in next, GetPlayerArguments do
							if Find(Sub(Arg, 1, #Player), Lower(Player)) then
								local Name = Format(" %s", GSub(Lower(Arg), Lower(Player), Player))
								Recommend.Text = Sub(Input, 1, #Input - #Player - 1) .. Name
								Found = true
								PlayerFound = true
							end
						end
					end
				end
			end
		end
	end

	if not Found then
		local Amount = #Input
		local Spaces = Split(Input, " ")
		local Arguments = Split(Input, Settings.Seperator)

		local Cmd, Args = false, false
		local Check = (Sub(Input, Amount - 1) == Format("%s ", Settings.Seperator))

		if #Spaces >= 1 then
			if Check or (#Spaces == 2 and Sub(Input, Amount) == " ") then
				for Index, Table in Commands do
					for Index, Name in Table[1] do
						if Lower(Name) == Lower(Spaces[1]) then
							Cmd = Name
							Args = Table[3]

							break
						end
					end
				end

				if Cmd then
					local Amount = (#Spaces == 2 and 1) or #Arguments
					local Argument = Args[Amount]

					if Argument then
						Recommend.Text = Format("%s%s", Input, Lower(Argument.Name))
						Press.Title.Text = "Enter"
						Found = true
					end
				end
			end
		end
	end

	if not Found then
		Press.Title.Text = "Enter"
		Recommend.Text = Blank
	end
end

Fill.Search = function(Input)
	Spawn(function()
		local Lowered = GSub(Lower(Split(Input, " ")[1]), Settings.Prefix, Blank)
		local FoundFirst = false
		local Amount = 0
		local Found = false

		if #Split(Input, " ") == 1 then
			for Index, Table in Commands do
				for Index, Name in Table[1] do
					if Find(Sub(Name, 1, #Lowered), Lower(Lowered)) or Name == Lowered then
						Press.Title.Text = "Tab"
						Recommend.Text = GSub(Name, Lowered, Split(Input, " ")[1])
						Found = true
					end
				end
			end
		end

		for Index, Frame in next, Autofill:GetChildren() do
			if Frame.Name == "AutofillButton" then
				if (not Settings.Toggles.FillCap) or (Amount < 4) then
					local Commands = Frame.Frame.Title
					local FrameFound = false

					for Index, Name in Split(Commands.Text, " / ") do
						if (Find(Sub(Name, 1, #Lowered), Lower(Lowered)) or Name == Lowered) and not FrameFound then
							FrameFound = true
							Amount += 1

							if not FoundFirst then
								Frame.BackgroundColor3 = Settings.Theme.Component
								FoundFirst = true
							else
								Frame.BackgroundColor3 = Settings.Theme.Primary
							end
						end
					end

					Frame.Visible = FrameFound
				else
					Frame.Visible = false
				end
			end
		end

		-- Resizing Command Bar
		local Sizes = {
			[1] = { Size = UDim2.new(1, -4, 0, 67) },
			[2] = { Size = UDim2.new(1, -4, 0, 125) },
			[3] = { Size = UDim2.new(1, -4, 0, 183) },
			[4] = { Size = UDim2.new(1, -4, 0, 240) },
		}

		local Size = Sizes[Amount] or Sizes[4]
		Tween(Autofill, 0.25, { Size = Size.Size })
		Tween(CommandBar, 0.25, { Position = Size.Position })
	end)
end

--// :: FEATURE

--// Waypoints

function Feature:AddWaypoint(Name, CFrame)
	CFrame = tostring(CFrame)

	if Name and CFrame then
		Settings.Waypoints[Name] = CFrame
		SaveSettings()

		API:Notify({
			Title = "Waypoints",
			Description = "Added waypoint successfully!",
			Type = "Success",

			Duration = 10,
		})
	else
		API:Notify({
			Title = "Waypoints",
			Description = "Error adding waypoint, is one of the arguments missing?",
			Type = "Error",

			Duration = 15,
		})
	end
end

--// Events
function Feature:AddEvent(Event, Command)
	local info = Settings.Events[Event]

	if info and not info[Command] then
		info[Command] = Command
		SaveSettings()

		API:Notify({
			Title = "Events",
			Description = "Added event successfully",
			Type = "Success",

			Duration = 10,
		})
	else
		API:Notify({
			Title = "Events",
			Description = "Error adding an event, event doesn't exist or command already added in the event.",
			Type = "Error",

			Duration = 15,
		})
	end
end

function Feature:ConnectEvent(Event, Connection, UseHumanoid, Check)
	local RunEvent = function(Event)
		Foreach(Settings.Events[Event] or (Output(Event) and {}), function(_, Command)
			Command.Parse(false, Command)
		end)
	end

	if Event == "AutoExecute" then
		RunEvent(Event)
	elseif Event == "PlayerRemoved" then
		Connect(Services.Players.PlayerRemoving, function(Plr)
			if Plr == LocalPlayer then
				RunEvent("PlayerRemoved")
			end
		end)
	elseif UseHumanoid and typeof(Event) == "string" then
		local CCharacter = Character
		local CHumanoid = CCharacter:FindFirstChild("Humanoid")

		local CDetect = function(CHumanoid)
			if Event == "Damaged" then
				Connect(Changed(CHumanoid, "Health"), function()
					if not Check or (Check and Check(CHumanoid)) then
						RunEvent("Damaged")
					end
				end)
			else
				Connect(CHumanoid[Event], function()
					if not Check or (Check and Check(CHumanoid)) then
						RunEvent(Event)
					end
				end)
			end
		end

		local Char = Character or (LocalPlayer.Character or CWait(LocalPlayer.CharacterAdded)) -- so doesnt error if character doesnt exist
		CDetect(CHumanoid or Char:WaitForChild("Humanoid"))
		Connect(LocalPlayer.CharacterAdded, function(NewCharacter)
			CCharacter = NewCharacter
			CDetect(CCharacter:WaitForChild("Humanoid"))
		end)
	else
		Connect(Connection, function()
			RunEvent(Event)
		end)
	end
end

-- :: COMMANDS :: --
Command.Add({
	Aliases = { "settings" },
	Description = "Opens the Settings Tab that includes options like Waypoints, Events, Themes, Toggles and MORE",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Settings

		if Tab then
			Tab.Open()
		else
			local Keybinds = {}
			local Window = Library:CreateWindow({
				Title = "Settings",
			})

			Window:AddTab({
				Title = "About",
				Description = "List of credits & information about Cmd",
				Tab = "Home",
			})

			Window:AddTab({
				Title = "Prefixes",
				Description = "Change the prefixes of Cmd",
				Tab = "Home",
			})

			Window:AddTab({
				Title = "Toggles",
				Description = "Toggle between different features",
				Tab = "Home",
			})

			Window:AddTab({
				Title = "Theme",
				Description = "Customize the look of Cmd",
				Tab = "Home",
			})

			Window:AddTab({
				Title = "Waypoints",
				Description = "Set up buttons for places to teleport to",
				Tab = "Home",
			})

			Window:AddTab({
				Title = "Keybinds",
				Description = "Set keybinds for running commands",
				Tab = "Home",
			})

			Window:AddTab({
				Title = "Events",
				Description = "Set commands that run during specific events",
				Tab = "Home",
			})

			--// About
			Window:AddSection({ Title = "Prefixes", Tab = "About" })

			Window:AddParagraph({
				Title = "Prefix",
				Description = Format("Current prefix is '%s'", Settings.Prefix),
				Tab = "About",
			})

			Window:AddParagraph({
				Title = "Chat Prefix",
				Description = Format("Current chat prefix is '%s'", Settings.ChatPrefix),
				Tab = "About",
			})

			Window:AddParagraph({
				Title = "Seperator",
				Description = Format("Current argument seperator is '%s'", Settings.Seperator),
				Tab = "About",
			})

			Window:AddSection({ Title = "Cmd", Tab = "About" })

			Window:AddParagraph({
				Title = "Version",
				Description = Format("Version %s", Settings.Version),
				Tab = "About",
			})

			Window:AddParagraph({
				Title = "Invite",
				Description = "Unavailable",
				Tab = "About",
			})
			--// Settings

			Window:AddInput({
				Title = "Prefix",
				Description = "Prefix for the Command Bar",
				Tab = "Prefixes",
				Default = Settings.Prefix,
				Callback = function(Key)
					if #Key == 1 then
						Settings.Prefix = Key
						SaveSettings()
					else
						API:Notify({
							Title = "Couldn't set prefix",
							Description = "Prefix character amount is bigger or smaller than 1",
							Type = "Error",
							Duration = 10,
						})
					end
				end,
			})

			Window:AddInput({
				Title = "Chat Prefix",
				Description = "Prefix for using commands in chat",
				Tab = "Prefixes",
				Default = Settings.ChatPrefix,
				Callback = function(Key)
					if #Key == 1 then
						Settings.ChatPrefix = Key
						SaveSettings()
					else
						API:Notify({
							Title = "Couldn't set prefix",
							Description = "Prefix character amount is bigger or smaller than 1",
							Type = "Error",
							Duration = 10,
						})
					end
				end,
			})

			--// Toggles
			Window:AddSection({ Title = "Command Bar", Tab = "Toggles" })

			Window:AddToggle({
				Title = "Recommendation",
				Description = "Toggle if Cmd should recommend commands",
				Tab = "Toggles",
				Default = Settings.Toggles.Recommendation,
				Callback = function(Toggle)
					Settings.Toggles.Recommendation = Toggle
					SaveSettings()
				end,
			})

			Window:AddToggle({
				Title = "Remove Admin Prompts",
				Description = "Removes other command bars that get in the way (Adonis, HD Admin, etc.)",
				Tab = "Toggles",
				Default = Settings.Toggles.RemoveCommandBars,
				Callback = function(Toggle)
					Settings.Toggles.RemoveCommandBars = Toggle
					SaveSettings()

					if Toggle then
						API:Notify({
							Title = "Success",
							Description = "Now everytime you run Cmd other admin prompts wont interfere",
							Mode = "Success",
							Duration = 5,
						})
					end
				end,
			})

			Window:AddSection({ Title = "Autofill", Tab = "Toggles" })

			Window:AddToggle({
				Title = "Autofill Cap",
				Description = "If enabled autofill will only show 4 commands that match",
				Tab = "Toggles",
				Default = Settings.Toggles.FillCap,
				Callback = function(Toggle)
					Settings.Toggles.FillCap = Toggle
					SaveSettings()
				end,
			})

			Window:AddSection({ Title = "Others", Tab = "Toggles" })

			Window:AddToggle({
				Title = "Developer Mode",
				Description = "Toggle to get more information about what's going on in console!",
				Tab = "Toggles",
				Default = Settings.Toggles.Developer,
				Callback = function(Toggle)
					Settings.Toggles.Developer = Toggle
					SaveSettings()
				end,
			})

			Window:AddToggle({
				Title = "Staff Notifier",
				Description = "Notifies all staff in the server and if a staff has joined your server",
				Tab = "Toggles",
				Default = Settings.Toggles.StaffNotifier,
				Callback = function(Toggle)
					Settings.Toggles.StaffNotifier = Toggle
					SaveSettings()
				end,
			})

			Window:AddToggle({
				Title = "Ignore Seated for Fling",
				Description = "Useful to only turn on if someone is in a car",
				Tab = "Toggles",
				Default = Settings.Toggles.IgnoreSeated,
				Callback = function(Toggle)
					Settings.Toggles.IgnoreSeated = Toggle
					SaveSettings()
				end,
			})

			Window:AddToggle({
				Title = "Unsure Vulnerability Detector",
				Description = "Searches for more vulnerable remotes in the game, but with risks of more false flags",
				Tab = "Toggles",
				Default = Settings.Toggles.UnsureVulnDetector,
				Callback = function(Toggle)
					Settings.Toggles.UnsureVulnDetector = Toggle
					SaveSettings()
				end,
			})

			Window:AddSection({ Title = "UI", Tab = "Toggles" })

			Window:AddToggle({
				Title = "Internal UI",
				Description = "If enabled when pressing LeftAlt will show an Internal UI",
				Tab = "Toggles",
				Default = Settings.Toggles.InternalUI,
				Callback = function(Toggle)
					Settings.Toggles.InternalUI = Toggle
					SaveSettings()
				end,
			})

			Window:AddToggle({
				Title = "Notifications Enabled",
				Description = "Toggle between if notifications get sent",
				Tab = "Toggles",
				Default = Settings.Toggles.Notify,
				Callback = function(Toggle)
					Settings.Toggles.Notify = Toggle
					SaveSettings()
				end,
			})

			Window:AddToggle({
				Title = "Popups Enabled",
				Description = "If disabled will just accept popups automatically",
				Tab = "Toggles",
				Default = Settings.Toggles.Popups,
				Callback = function(Toggle)
					Settings.Toggles.Popups = Toggle
					SaveSettings()
				end,
			})

			--// Themes
			Window:AddSection({ Title = "Colors", Tab = "Theme" })

			Window:AddTab({
				Title = "Create Theme",
				Description = "Create your own custom theme",
				Tab = "Theme",
			})

			Window:AddDropdown({
				Title = "Default Themes",
				Tab = "Theme",
				Options = DefaultThemes,
				Callback = function(Theme)
					Theme.Transparency = Settings.Theme.Transparency

					SetTheme(Theme)
					SaveSettings()
				end,
			})

			Window:AddSection({ Title = "Others", Tab = "Theme" })

			Window:AddSlider({
				Title = "UI Transparency",
				Tab = "Theme",
				MaxValue = 0.8,
				AllowDecimals = true,
				DecimalAmount = 2,
				Callback = function(Amount)
					Settings.Theme.Transparency = Amount
					SetTheme()
				end,
			})

			Window:AddDropdown({
				Title = "UI Mode",
				Description = "IMPORTANT: Set this up correctly so it doesn't mess up with the UI hover effects",
				Tab = "Theme",
				Options = {
					["Light Mode"] = "Light",
					["Dark Mode"] = "Dark",
				},
				Callback = function(Type)
					Settings.Theme.Mode = Type
					SetTheme()
				end,
			})

			Window:AddButton({
				Title = "Save Theme",
				Description = "Saves the theme you've created",
				Tab = "Theme",
				Callback = function()
					SaveSettings()
					API:Notify({
						Title = "Success",
						Description = "Successfully saved your theme",
						Type = "Sucess",
						Duration = 5,
					})
				end,
			})

			--// Keybinds

			Window:AddTab({
				Title = "Create Keybind",
				Description = "Create a Keybind to use",
				Tab = "Keybinds",
			})

			Window:AddTab({
				Title = "Current Keybinds",
				Description = "List of active Keybinds",
				Tab = "Keybinds",
			})

			-- : Create Keybind
			local Keybind = { Begin = nil, End = nil, Key = nil }
			local CreateKeybind = function(Keybind)
				local Key, Begin, End = Keybind.Key, Keybind.Begin, Keybind.End

				Window:AddButton({
					Title = GSub(tostring(Key.KeyCode), "Enum.KeyCode.", Blank),
					Description = "Click this to remove the Keybind",
					Tab = "Current Keybinds",
					Callback = function(Button)
						Keybinds[Key] = nil
						Destroy(Button)
					end,
				})
			end
			Window:AddSection({ Title = "Create", Tab = "Create Keybind" })

			Window:AddButton({
				Title = "Create Keybind",
				Description = "Create the Keybind!",
				Tab = "Create Keybind",
				Callback = function()
					local Key, Begin, End = Keybind.Key, Keybind.Begin, Keybind.End

					if not Keybinds[Key] and Begin and End and Key then
						Keybinds[Keybind.Key] = { Begin = Begin, End = End, Key = Key, Active = false }
						CreateKeybind(Keybinds[Keybind.Key])

						API:Notify({
							Title = "Keybind",
							Description = "Created Keybind successfully!",
							Duration = 15,
							Type = "Success",
						})
					else
						API:Notify({
							Title = "Keybind",
							Description = "Unable to make Keybind since a Keybind with the same key exists or one of the arguments is missing",
							Duration = 15,
							Type = "Error",
						})
					end
				end,
			})

			Window:AddSection({ Title = "Settings", Tab = "Create Keybind" })

			Window:AddKeybind({
				Title = "Keybind Keybind",
				Description = "The keybind for the Keybind",
				Tab = "Create Keybind",
				Callback = function(Key)
					Keybind.Key = Key
				end,
			})

			Window:AddInput({
				Title = "Keybind Begin Command",
				Description = "The command to run when you want the Keybind to begin",
				Tab = "Create Keybind",
				Callback = function(Cmd)
					Keybind.Begin = Cmd
				end,
			})

			Window:AddInput({
				Title = "Keybind End Command",
				Description = "The command to run when you want to END the Keybind",
				Tab = "Create Keybind",
				Callback = function(Cmd)
					Keybind.End = Cmd
				end,
			})

			Connect(Services.Input.InputBegan, function(Key)
				local Keybind = Keybinds[Key]

				if Keybind then
					if Keybind.Active then
						Command.Parse(true, Keybinds[Key].End)
					else
						Command.Parse(true, Keybinds[Key].Begin)
					end

					Keybind.Active = not Keybind.Active
				end
			end)

			--// Waypoints

			local AddWaypoint = function(Name, Position)
				Window:AddDropdown({
					Title = Name,
					Description = "Pick between the two options!",
					Options = {
						["Teleport to"] = "TP",
						["Remove Waypoint"] = "Remove",
					},
					Tab = "Waypoints",
					Callback = function(Method, Button)
						local Waypoint = Settings.Waypoints[Name]

						if Method == "TP" then
							Root.CFrame = Position
						else
							Settings.Waypoints[Name] = nil
							Destroy(Button)
							SaveSettings()
						end
					end,
				})
			end

			Window:AddSection({ Title = "Create", Tab = "Waypoints" })
			Window:AddInput({
				Title = "Make Waypoint (NAME)",
				Tab = "Waypoints",
				Callback = function(Name)
					local Position = Root.CFrame

					Feature:AddWaypoint(Name, Position)
					AddWaypoint(Name, Position)
				end,
			})

			Window:AddSection({ Title = "Created Waypoints", Tab = "Waypoints" })

			for WaypointName, SavedPosition in next, Settings.Waypoints do
				AddWaypoint(WaypointName, CFrame.new(Unpack(Split(SavedPosition, ","))))
			end

			--// Events

			Window:AddTab({
				Title = "Create Event",
				Description = "Create a event to fire",
				Tab = "Events",
			})

			Window:AddTab({
				Title = "Current Events",
				Description = "List of active events",
				Tab = "Events",
			})

			-- : Create event
			local SelectedEvent = "Unselected"
			local EventCommand

			for EventName, SavedEvent in next, Settings.Events do
				for _, SavedCommand in next, SavedEvent do
					Window:AddButton({
						Title = Format("Event for %s", EventName),
						Description = Format("Click to delete the event\nCommand: %s", SavedCommand),
						Tab = "Current Events",
						Callback = function(Button)
							Settings.Events[EventName][SavedCommand] = nil
							Destroy(Button)
							SaveSettings()
						end,
					})
				end
			end

			local AddEvent = function()
				if Settings.Events[SelectedEvent] and EventCommand then
					local OldSelected = SelectedEvent
					local OldEvent = EventCommand

					Feature:AddEvent(OldSelected, OldEvent)
					Window:AddButton({
						Title = Format("Event for %s", SelectedEvent),
						Description = Format("Click to delete the event\nCommand: %s", EventCommand),
						Tab = "Current Events",
						Callback = function(Button)
							Settings.Events[OldSelected][OldEvent] = nil
							Destroy(Button)
							SaveSettings()
						end,
					})
				else
					API:Notify({
						Title = "Events",
						Description = "Error saving event, is one of the arguments missing?",
						Type = "Error",

						Duration = 10,
					})
				end
			end

			Window:AddButton({
				Title = "Create Event",
				Tab = "Create Event",
				Callback = AddEvent,
			})

			Window:AddDropdown({
				Title = "Select Event",
				Tab = "Create Event",
				Options = {
					["Auto Execute"] = "AutoExecute",
					["Chatted"] = "Chatted",
					["Respawned"] = "CharacterAdded",
					["Died"] = "Died",
					["Damaged"] = "Damaged",
					["Upon Leaving"] = "PlayerRemoved",
				},
				Callback = function(Event)
					SelectedEvent = Event
				end,
			})

			Window:AddInput({
				Title = "Event Command",
				Tab = "Create Event",
				Callback = function(Input)
					EventCommand = Input
				end,
			})
		end
	end,
})

local ESPSettings = {
	Enabled = false,
	Boxes = true,
	Text = true,

	TextSize = 18,
	BoxThickness = 1,
	IgnoreTeammates = false,
}

Command.Add({
	Aliases = { "esp" },
	Description = "See other players through walls",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs["Esp"]

		if Tab then
			Tab.Open()
		else
			local Window = Library:CreateWindow({
				Title = "Esp",
			})

			Window:AddSection({ Title = "Main", Tab = "Home" })

			Window:AddToggle({
				Title = "Enabled",
				Tab = "Home",
				Default = false,
				Callback = function(Toggle)
					ESPSettings.Enabled = Toggle
				end,
			})

			Window:AddToggle({
				Title = "Hide Teammates",
				Tab = "Home",
				Default = false,
				Callback = function(Toggle)
					ESPSettings.IgnoreTeammates = Toggle
				end,
			})

			Window:AddSection({ Title = "Features", Tab = "Home" })

			Window:AddToggle({
				Title = "Boxes Enabled",
				Tab = "Home",
				Default = true,
				Callback = function(Toggle)
					ESPSettings.Boxes = Toggle
				end,
			})

			Window:AddToggle({
				Title = "Text Enabled",
				Tab = "Home",
				Default = true,
				Callback = function(Toggle)
					ESPSettings.Text = Toggle
				end,
			})

			Window:AddSection({ Title = "Customize", Tab = "Home" })

			Window:AddSlider({
				Title = "Box Thickness",
				Tab = "Home",
				MaxValue = 10,
				Callback = function(Amount)
					ESPSettings.BoxThickness = Amount
				end,
			})

			Window:AddSlider({
				Title = "Text Size",
				Tab = "Home",
				MaxValue = 25,
				Callback = function(Amount)
					ESPSettings.TextSize = Amount
				end,
			})

			local Add = function(Player)
				local Bottom = Drawing.new("Line")
				local Top = Drawing.new("Line")
				local Right = Drawing.new("Line")
				local Left = Drawing.new("Line")
				local Name = Drawing.new("Text")

				local SetVisible = function(Boolean)
					for Index, DrawingLine in next, { Bottom, Top, Right, Left } do
						if ESPSettings.Enabled and ESPSettings.Boxes then
							DrawingLine.Visible = Boolean
						else
							DrawingLine.Visible = false
						end
					end

					if ESPSettings.Enabled and ESPSettings.Text then
						Name.Visible = Boolean
					else
						Name.Visible = false
					end
				end

				local UpdatePosition = function()
					local Root = (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"))

					if
						Root
						and not (ESPSettings.IgnoreTeammates and Player.Team == LocalPlayer.Team)
						and ESPSettings.Enabled
					then
						local Root = Player.Character.HumanoidRootPart
						local _, Visible = Camera:WorldToViewportPoint(Root.Position)
						local Coordinate = Root.CFrame
						local TeamColor = Player.TeamColor.Color

						for Index, DrawingLine in next, { Bottom, Top, Right, Left } do
							DrawingLine.Color = TeamColor
							DrawingLine.Thickness = ESPSettings.BoxThickness
						end

						Name.Color = TeamColor
						Name.Size = ESPSettings.TextSize
						Name.Center = true
						Name.Outline = true
						Name.OutlineColor = Color3.new(0, 0, 0)
						Name.Text = Player.Name

						if Visible then
							local Size = Vector3.new(2, 3, 0)
							local BL =
								Camera:WorldToViewportPoint((Coordinate * CFrame.new(-Size.X, -Size.Y, 0)).Position)
							local BR =
								Camera:WorldToViewportPoint((Coordinate * CFrame.new(Size.X, -Size.Y, 0)).Position)
							local TL =
								Camera:WorldToViewportPoint((Coordinate * CFrame.new(-Size.X, Size.Y, 0)).Position)
							local TR =
								Camera:WorldToViewportPoint((Coordinate * CFrame.new(Size.X, Size.Y, 0)).Position)

							Bottom.From = Vector2.new(BL.X, BL.Y)
							Bottom.To = Vector2.new(BR.X, BR.Y)

							Top.From = Vector2.new(TL.X, TL.Y)
							Top.To = Vector2.new(TR.X, TR.Y)

							Right.From = Vector2.new(TR.X, TR.Y)
							Right.To = Vector2.new(BR.X, BR.Y)

							Left.From = Vector2.new(TL.X, TL.Y)
							Left.To = Vector2.new(BL.X, BL.Y)

							Name.Position = Vector2.new((TL.X + TR.X) / 2, TL.Y - 20)

							SetVisible(true)
						else
							SetVisible(false)
						end
					else
						SetVisible(false)
					end
				end

				Connect(Services.Run.RenderStepped, UpdatePosition)
			end

			Connect(Services.Players.PlayerAdded, Add)
			for Index, Player in next, Services.Players:GetPlayers() do
				if Player ~= LocalPlayer then
					Add(Player)
				end
			end
		end
	end,
})

local AimbotSettings = {
	Enabled = false,
	Triggerbot = false,
	Part = "Head", --// Available parts: Head, HumanoidRootPart
	Method = "Camera", --// Available methods: Camera, Mouse, Third
	RandomPart = false,

	AliveCheck = true,
	TeamCheck = false,
	WallCheck = false,

	Held = false,
	Key = Enum.KeyCode.E,

	Prediction = 0,
	AutoPrediction = false,
	Target = nil,

	FOV = {
		Radius = 100,
	},
}

AimbotSettings.BehindWall = function(Target)
	if Target and Target.Character and (Target ~= LocalPlayer) then
		local VisibleWalls = {}
		local Walls = Camera.GetPartsObscuringTarget(
			Camera,
			{ Character.Head.Position, Target.Character.Head.Position },
			{ Character, Target.Character }
		)

		for _, Wall in next, Walls do
			if Wall and Wall.IsA(Wall, "BasePart") and Wall.Transparency < 1 then
				Insert(VisibleWalls, Wall)
			end
		end

		return #VisibleWalls > 0
	end
end

AimbotSettings.Closest = function()
	local Fov_Size = AimbotSettings.FOV.Radius
	local MouseX, MouseY = Mouse.X, Mouse.Y

	local ClosestDistance = Fov_Size
	local ClosestPlayer
	local ClosestPlayerPart

	for _, Player in next, Services.Players.GetPlayers(Services.Players) do
		local Character = Player and Player.Character
		local Humanoid = Character and Character.FindFirstChild(Character, "Humanoid")
		local TargetPart = Character and Character.FindFirstChild(Character, AimbotSettings.Part)

		if Humanoid and TargetPart and Player ~= LocalPlayer then
			local Coordinates, Visible = Camera.WorldToViewportPoint(Camera, TargetPart.Position)

			if
				not (AimbotSettings.TeamCheck and Player.Team == LocalPlayer.Team)
				and not (AimbotSettings.WallCheck and AimbotSettings.BehindWall(Player))
				and not (AimbotSettings.AliveCheck and Humanoid.Health <= 0)
				and Coordinates
				and Visible
			then
				local Distance = (Vector2.new(MouseX, MouseY) - Vector2.new(Coordinates.X, Coordinates.Y)).Magnitude

				if Distance < Fov_Size and Distance < ClosestDistance then
					ClosestDistance = Distance
					ClosestPlayer = Player
					ClosestPlayerPart = TargetPart
				end
			end
		end
	end

	return ClosestPlayerPart
end

AimbotSettings.GetAutoPrediction = function()
	local DataPing = game.Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	local Prediction = math.clamp(DataPing / 1000, 0, 1) * 1.285

	return Prediction
end

AimbotSettings.GetPrediction = function(Part)
	local Prediction = AimbotSettings.AutoPrediction and AimbotSettings.GetAutoPrediction() or AimbotSettings.Prediction
	local Horizontal = Vector3.new(Part.Velocity.X, 0, Part.Velocity.Z)

	if AimbotSettings.AutoPrediction then
		local Magnitude = Horizontal.Magnitude
		local Clamped = math.clamp(Magnitude / 75, 1, 2)

		Prediction *= Clamped
	end

	return (Horizontal * Prediction + Vector3.new(0, 0.1, 0))
end

Command.Add({
	Aliases = { "aimbot" },
	Description = "Aimbot features built into Cmd",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Aimbot

		if Tab then
			Tab.Open()
		else
			local EnableAimbot
			local Window = Library:CreateWindow({
				Title = "Aimbot",
			})

			Window:AddToggle({
				Title = "Enabled",
				Tab = "Home",
				Default = false,
				Callback = function(Boolean)
					AimbotSettings.Enabled = Boolean
				end,
			})

			Window:AddDropdown({
				Title = "Aimbot Method",
				Tab = "Home",
				Options = {
					["First Person"] = "Camera",
					["Third Person"] = "Third",
					["Silent Aim"] = "Silent",
				},
				Callback = function(Method)
					AimbotSettings.Method = Method

					if Method == "Silent" then
						EnableAimbot()
						if Check("Hook") then
							API:Notify({
								Title = "Silent Aim",
								Description = "Enabled",
								Type = "Success",
							})
						else
							API:Notify({
								Title = "Silent Aim",
								Description = "Executor does not support it.",
								Type = "Error",
							})
						end
					end
				end,
			})

			Window:AddKeybind({
				Title = "Keybind",
				Tab = "Home",
				Callback = function(Key)
					AimbotSettings.Key = Key
				end,
			})

			Window:AddToggle({
				Title = "Trigger Bot Enabled",
				Tab = "Home",
				Default = false,
				Callback = function(Boolean)
					AimbotSettings.Triggerbot = Boolean
				end,
			})

			Window:AddSection({ Title = "Checks", Tab = "Home" })

			Window:AddToggle({
				Title = "Alive Check",
				Tab = "Home",
				Default = true,
				Callback = function(Boolean)
					AimbotSettings.AliveCheck = Boolean
				end,
			})

			Window:AddToggle({
				Title = "Team Check",
				Tab = "Home",
				Default = false,
				Callback = function(Boolean)
					AimbotSettings.TeamCheck = Boolean
				end,
			})

			Window:AddToggle({
				Title = "Wall Check",
				Tab = "Home",
				Default = false,
				Callback = function(Boolean)
					AimbotSettings.WallCheck = Boolean
				end,
			})

			Window:AddSection({ Title = "Sliders & Prediction", Tab = "Home" })

			Window:AddToggle({
				Title = "Auto Prediction",
				Description = "Will ignore your set prediction",
				Tab = "Home",
				Callback = function(Boolean)
					AimbotSettings.AutoPrediction = Boolean
				end,
			})

			Window:AddSlider({
				Title = "Prediction",
				Tab = "Home",
				MaxValue = 1,
				AllowDecimals = true,
				Callback = function(Amount)
					AimbotSettings.Prediction = Amount
				end,
			})

			Window:AddSlider({
				Title = "FOV Size",
				Tab = "Home",
				MaxValue = 500,
				Callback = function(Amount)
					AimbotSettings.FOV.Radius = Amount
				end,
			})

			Window:AddDropdown({
				Title = "Aim Part",
				Tab = "Home",
				Options = {
					["Torso"] = "HumanoidRootPart",
					["Head"] = "Head",
					["Random"] = "Random",
				},
				Callback = function(Part)
					AimbotSettings.Part = Part
					AimbotSettings.RandomPart = (Part == "Random")
				end,
			})

			Spawn(function()
				Connect(Services.Run.RenderStepped, function()
					if AimbotSettings.RandomPart then
						local Available = { "Head", "HumanoidRootPart" }
						AimbotSettings.Part = Available[math.random(1, #Available)]
					end

					if AimbotSettings.Triggerbot then
						local Target = (function()
							local Target = Mouse.Target
							local Character = Target and Target:FindFirstAncestorOfClass("Model")
							local Player = Character and Services.Players:GetPlayerFromCharacter(Character)

							if Player and Player ~= LocalPlayer then
								return Player
							end
						end)()

						if Target and not (AimbotSettings.TeamCheck and Target.Team == LocalPlayer.Team) then
							mouse1click()
						end
					end
				end)

				Connect(Services.Input.InputBegan, function(Key, Processed)
					if Key == AimbotSettings.Key and AimbotSettings.Enabled and not Processed then
						local TargetPart = AimbotSettings.Closest()
						local Method = AimbotSettings.Method

						if TargetPart then
							AimbotSettings.Held = true

							repeat
								Wait()
								if (Method == "Camera" or Method == "Third") and TargetPart then
									local LookAt = TargetPart.CFrame + AimbotSettings.GetPrediction(TargetPart)

									if TargetPart.Position.Y > -100 then
										Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, LookAt.Position)
									end

									if Method == "Third" then
										Services.Input.MouseBehavior = Enum.MouseBehavior.LockCenter
									end
								end
							until not AimbotSettings.Held or not TargetPart
						end
					end
				end)

				Connect(Services.Input.InputEnded, function(Key, Processed)
					if Key == AimbotSettings.Key and AimbotSettings.Enabled and not Processed then
						AimbotSettings.Held = false
					end
				end)

				Spawn(function()
					local Circle
					if Drawing and Drawing.new then
						Circle = Drawing.new("Circle")

						repeat
							Wait()
							local MouseLocation = (Services.Input:GetMouseLocation())
							if AimbotSettings.Enabled then
								Circle.Radius = AimbotSettings.FOV.Radius
								Circle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y)
								Circle.Visible = true
							else
								Circle.Visible = false
							end

						until not Circle
					end
				end)

				local Enabled = false
				EnableAimbot = function()
					if not Enabled and Check("Hook") then
						Enabled = true

						local OldNamecall
						OldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
							local Method = getnamecallmethod()

							if
								not checkcaller()
								and string.find(string.lower(Method), "ray")
								and AimbotSettings.Enabled
								and AimbotSettings.Method == "Silent"
							then
								if
									Method == "FindPartOnRay"
									or Method == "FindPartOnRayWithIgnoreList"
									or Method == "FindPartOnRayWithWhitelist"
								then
									local ClosestRoot = AimbotSettings.Closest()

									if ClosestRoot then
										local Args = { ... }
										local Origin = Args[1].Origin
										local Direction = Args[1].Direction

										if Direction.Magnitude > 50 then
											Args[1] = Ray.new(Origin, (ClosestRoot.Position - Origin).Unit * 500)
										end

										return OldNamecall(self, table.unpack(Args))
									end
								elseif Method == "Raycast" then
									local ClosestRoot = AimbotSettings.Closest()

									if ClosestRoot then
										local Args = { ... }
										local Direction = Args[2]

										if Direction.Magnitude > 50 then
											Args[2] = (ClosestRoot.Position - Origin).Unit * 500
										end

										return OldNamecall(self, table.unpack(Args))
									end
								end
							end

							return OldNamecall(self, ...)
						end)
					end
				end
			end)
		end
	end,
})

Command.Add({
	Aliases = { "notify", "send" },
	Description = "Sends a notification (mostly testing)",
	Arguments = {
		{ Name = "Title", Type = "String" },
		{ Name = "Description", Type = "String" },
		{ Name = "Duration", Type = "Number" },
		{ Name = "Type", Type = "String" },
	},
	Task = function(Title, Description, Duration, Type)
		API:Notify({
			Title = Title,
			Description = Description,
			Duration = SetNumber(Duration),
			Type = Type,
		})
	end,
})

Command.Add({
	Aliases = { "servers" },
	Description = "Displays a list of servers for the game you're in",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs["Servers"]

		if Tab then
			Tab.Open()
		else
			local PlayerCount = nil
			local Refreshed = false
			local Window = Library:CreateWindow({
				Title = "Servers",
			})

			local LoadServers = function()
				local Servers = Methods.Get(
					Format(
						"https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100&cursor=",
						game.PlaceId
					)
				)
				local Found = false

				repeat
					Wait()
					local Decode = JSONDecode(Services.Http, Servers)
					for Index, Server in next, Decode.data do
						if typeof(Server) == "table" and (not PlayerCount or Server.playing == PlayerCount) then
							Found = true

							Window:AddButton({
								Title = Server.id,
								Description = Format("Playing: %s\nPing: %s", Server.playing, Server.ping),
								Tab = "Home",
								Callback = function()
									Services.Teleport:TeleportToPlaceInstance(game.PlaceId, Server.id, LocalPlayer)
								end,
							})
						end
					end

					if not Decode.nextPageCursor and not Found then
						API:Notify({
							Title = "Could not find server",
							Description = "Try a different player count!",
							Duration = 5,
							Type = "Error",
						})

						Found = true
					end

					if not Found then
						Servers = Methods.Get(
							Format(
								"https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100&cursor=%s",
								tostring(game.PlaceId),
								Decode.nextPageCursor or ""
							)
						)
					end
				until Found or Refreshed

				Refreshed = false
			end

			Window:AddSection({ Title = "Settings", Tab = "Home" })

			Window:AddButton({
				Title = "Refresh",
				Tab = "Home",
				Callback = function()
					for Index, Server in next, Window:GetTab("Home"):GetChildren() do
						if Server:IsA("TextButton") and Server.Frame.Title.Text:find("-") then
							Destroy(Server)
						end
					end

					LoadServers()
					Refreshed = true
				end,
			})

			Window:AddSlider({
				Title = "Player Count",
				Description = "(Set to 0 if you want to show all servers)",
				Tab = "Home",
				MaxValue = Services.Players.MaxPlayers,
				Callback = function(Amount)
					if Amount == 0 then
						PlayerCount = nil
					else
						PlayerCount = Amount
					end
				end,
			})

			Window:AddSection({ Title = "Servers", Tab = "Home" })
			LoadServers()
		end
	end,
})

Command.Add({
	Aliases = { "chatlogs", "logs" },
	Description = "Displays player messages",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs["Chat Logs"]

		if Tab then
			Tab.Open()
		else
			local LayoutOrder = 100000
			local Messages = {}
			local Window = Library:CreateWindow({
				Title = "Chat Logs",
			})

			Window:AddSection({ Title = "Settings", Tab = "Home" })

			Window:AddButton({
				Title = "Clear Messages",
				Tab = "Home",
				Callback = function()
					LayoutOrder = 100000
					for _, Message in next, Messages do
						Destroy(Message)
					end
				end,
			})

			Window:AddSection({ Title = "Logs", Tab = "Home" })

			local Detect = function(Player)
				ConnectMessaged(Player, function(Message)
					local Paragraph = Window:AddParagraph({
						Title = Format("%s (@%s)", Player.DisplayName, Player.Name),
						Description = Message,
						Tab = "Home",
					})

					LayoutOrder -= 1
					Paragraph.LayoutOrder = LayoutOrder
					Insert(Messages, Paragraph)
				end)
			end

			Connect(Services.Players.PlayerAdded, Detect)
			for _, Player in next, Services.Players:GetPlayers() do
				Detect(Player)
			end
		end
	end,
})

Command.Add({
	Aliases = { "gameinfo", "game", "info" },
	Description = "Displays information about the game you're in (general info and subplaces)",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Game

		if Tab then
			Tab.Open()
		else
			local Window = Library:CreateWindow({
				Title = "Game",
			})

			-- Tabs
			Window:AddTab({
				Title = "Regular Data",
				Description = "Shows game title, description, etc.",
				Tab = "Home",
			})

			Window:AddTab({
				Title = "Game's Subplaces",
				Description = "Shows all the other subplaces this game owns (hidden games)",
				Tab = "Home",
			})

			-- Universe Id
			local UniverseData =
				Methods.Get(Format("https://apis.roblox.com/universes/v1/places/%d/universe", game.PlaceId))
			local Decoded = UniverseData and JSONDecode(Services.Http, UniverseData)
			local UniverseId = Decoded and Decoded.universeId

			-- Regular Data
			local Data = Methods.Get(Format("https://games.roblox.com/v1/games?universeIds=%d", UniverseId))
			local DecodedData = Data and JSONDecode(Services.Http, Data)

			for Name, Info in next, DecodedData.data[1] or {} do
				if typeof(Info) == "table" then
					local String = ""
					local Added = 0

					for Name, Value in next, Info do
						if typeof(Name) == "number" then
							Name = ""
						else
							Name ..= ": "
						end

						Added += 1
						String ..= Format("%s%s%s", Name, tostring(Value), (Added == #Info and "") or "\n")
					end

					Info = String
				end

				Info = tostring(Info)
				if Info == "" then
					Info = "empty (no information)"
				end

				Window:AddParagraph({
					Title = Name:sub(1, 1):upper() .. Name:sub(2),
					Description = Info,
					Tab = "Regular Data",
				})
			end

			-- Subplaces
			local SubplacePages = Services.AssetService:GetGamePlacesAsync()
			local Subplaces = {}

			repeat
				for _, Place in SubplacePages:GetCurrentPage() do
					Insert(Subplaces, Place)
				end

				if SubplacePages.IsFinished then
					break
				end

				SubplacePages:AdvanceToNextPageAsync()
			until false

			for _, Place in next, Subplaces do
				if Place.PlaceId ~= game.PlaceId then
					Window:AddButton({
						Title = Place.Name,
						Description = Format("PlaceId: %d\nClick to join subplace", Place.PlaceId),
						Tab = "Game's Subplaces",
						Callback = function()
							Services.Teleport:Teleport(Place.PlaceId, LocalPlayer)
						end,
					})
				end
			end
		end
	end,
})

Command.Add({
	Aliases = { "fakechat" },
	Description = "Send a chat message impersonating another user",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Chat

		if Tab then
			Tab.Open()
		else
			local Disguise, Username, Message = "Hello", "Roblox", "whats up"
			local Window = Library:CreateWindow({
				Title = "Chat",
			})

			local Send = function()
				local Character = " "
				Chat(Disguise .. Character:rep(125) .. Format("%s" .. ": %s", Username, Message))
			end

			Window:AddButton({
				Title = "Send",
				Tab = "Home",
				Callback = Send,
			})

			Window:AddInput({
				Title = "Disguise Text",
				Tab = "Home",
				Default = "Hello",
				Callback = function(Input)
					Disguise = Input
				end,
			})

			Window:AddInput({
				Title = "Player",
				Tab = "Home",
				Default = "Roblox",
				Callback = function(Input)
					Username = Input
				end,
			})

			Window:AddInput({
				Title = "Message",
				Tab = "Home",
				Default = "whats up",
				Callback = function(Input)
					Message = Input
				end,
			})
		end
	end,
})

Command.Add({
	Aliases = { "cmds", "commands" },
	Description = "Displays all the commands Cmd has",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs["Commands"]

		if Tab then
			Tab.Open()
		else
			local Window = Library:CreateWindow({
				Title = "Commands",
			})

			for Index, Command in next, Commands do
				local Aliases, Description, Arguments = Unpack(Command)
				local Args = "Arguments: "

				Window:AddParagraph({
					Title = Concat(Aliases, " / "),
					Description = Description,
					Tab = "Home",
				})
			end
		end
	end,
})

Command.Add({
	Aliases = { "httpspy", "http" },
	Description = "Displays all HTTP requests from other scripts",
	Arguments = {},
	Task = function()
		if not Check("Hook") then
			return "Http Spy", "Your executor doesn't support hooking, this command won't work."
		end

		local Tab = Library.Tabs["Http"]

		if Tab then
			Tab.Open()
		else
			local Window = Library:CreateWindow({
				Title = "Http",
			})

			local LogFunction = function(Func, Name)
				local Old = Func
				Old = hookfunction(Func, function(self, Url, ...)
					if Name and Url then
						Window:AddButton({
							Title = Name,
							Description = Url,
							Tab = "Home",
							Callback = function()
								setclipboard(Url)
								API:Notify({
									Title = "Http Spy",
									Description = "URL Copied",
								})
							end,
						})
					end

					return Old(self, Url, ...)
				end)
			end

			LogFunction(game.HttpGet, "HttpGet Request")
			LogFunction(game.HttpPost, "HttpPost Request")
			LogFunction(request, "Request")

			return "Http Spy", "Enabled"
		end
	end,
})

Command.Add({
	Aliases = { "highlight", "hl" },
	Description = "Highlight any object, from its Class (object type) to Name",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Highlight

		if Tab then
			Tab.Open()
		else
			local HighlightName = GenerateGUID(Services.Http)
			local Highlights = {}
			local SetParent = false
			local Name = nil
			local Class = nil

			local Window = Library:CreateWindow({
				Title = "Highlight",
			})

			local SetHighlight = function(Show)
				if Show then
					if not Name and not Class then
						API:Notify({
							Title = "Highlighter",
							Description = "Unable to set highlight since class nor name have been set (Must have at least one set)",
							Type = "Error",

							Duration = 10,
						})

						return
					end

					for Index, Part in next, workspace:GetDescendants() do
						if not Name or (Lower(Part.Name) == Lower(Name)) then
							if not Class or (Lower(Part.ClassName) == Lower(Class)) then
								if not Highlights[Part] then
									local NewHighlight = Instance.new("Highlight", (SetParent and Part.Parent) or Part)
									Highlights[Part] = NewHighlight
								end
							end
						end
					end
				else
					for Index, Highlight in next, Highlights do
						Destroy(Highlight)
					end

					Highlights = {}
				end
			end

			Window:AddSection({ Title = "Actions", Tab = "Home" })

			Window:AddButton({
				Title = "Add Highlight",
				Tab = "Home",
				Callback = function()
					SetHighlight(true)
				end,
			})

			Window:AddButton({
				Title = "Remove Highlights",
				Tab = "Home",
				Callback = function()
					SetHighlight(false)
				end,
			})

			Window:AddSection({ Title = "Settings", Tab = "Home" })

			Window:AddInput({
				Title = "Part Name",
				Tab = "Home",
				Callback = function(Input)
					if GSub(Input, " ", Blank) == Blank then
						Input = nil
					end

					Name = Input
				end,
			})

			Window:AddInput({
				Title = "Part Classname",
				Tab = "Home",
				Callback = function(Input)
					if GSub(Input, " ", Blank) == Blank then
						Input = nil
					end

					Class = Input
				end,
			})

			Window:AddToggle({
				Title = "Highlight Parent",
				Description = "Gives the highlight to the parent of the part, useful for classes like ProximityPrompts that aren't parts",
				Tab = "Home",
				Callback = function(Boolean)
					SetParent = Boolean
				end,
			})
		end
	end,
})

Command.Add({
	Aliases = { "scripts" },
	Description = "Searches scripts using Scriptblox",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Scriptblox

		if Tab then
			Tab.Open()
		else
			local Window = Library:CreateWindow({
				Title = "Scriptblox",
			})

			local Search = function(Input)
				local Scripts = JSONDecode(
					Services.Http,
					Methods.Get(Format("https://scriptblox.com/api/script/search?q=%s&max=200&mode=free", Input))
				)

				for Index, Script in next, Scripts.result.scripts do
					local Game = Script.game.name
					local Type = Script.scriptType
					local Main = Script.script
					local Title = Script.title

					Window:AddButton({
						Title = Title,
						Description = Format("%s (%s)", Game, string.upper(Type)),
						Tab = "Home",
						Callback = function()
							API:Notify({
								Title = "Scriptblox",
								Description = Format("Running %s...", Title),
							})

							loadstring(Main)()
						end,
					})
				end
			end

			Window:AddSection({ Title = "Search", Tab = "Home" })

			Window:AddInput({
				Title = "Search",
				Tab = "Home",
				Callback = function(Input)
					for Index, Script in next, Window:GetTab("Home"):GetChildren() do
						if Script:IsA("TextButton") and Script.Frame:FindFirstChild("Description") then
							Destroy(Script)
						end
					end

					Search(Input)
				end,
			})

			Window:AddSection({ Title = "Results", Tab = "Home" })

			Search("Universal")
		end
	end,
})

Command.Add({
	Aliases = { "fov", "field" },
	Description = "Changes your Field of View",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		Camera.FieldOfView = SetNumber(Amount, 0, 120)
	end,
})

Command.Add({
	Aliases = { "respawn", "re" },
	Description = "Respawns your character and places you in the same spot",
	Arguments = {},
	Task = function()
		local Position = Root.CFrame
		local Connection

		Humanoid.Health = 0
		Connection = Connect(LocalPlayer.CharacterAdded, function(Char)
			Char:WaitForChild("HumanoidRootPart").CFrame = Position
			Connection:Disconnect()
		end)
	end,
})

Command.Add({
	Aliases = { "setfflag", "setff" },
	Description = "Set a fast flag",
	Arguments = {
		{ Name = "Flag", Type = "String" },
		{ Name = "Value", Type = "String" },
	},
	Task = function(Flag, Value)
		if Flag or Value then
			local Method = setfflag or function(flag, value)
				game:DefineFastFlag(flag, value)
			end

			local Success, Result = pcall(function()
				Method(Flag, Value)
			end)

			if Success then
				return "Set Fast Flag", Format("Set %s's value to %s", Flag, Value)
			else
				return "Error occured setting fast flag", Result, 10
			end
		end
	end,
})

Command.Add({
	Aliases = { "tpwalk", "walk" },
	Description = "Change your walkspeed (more undetectable)",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Speed)
		Refresh("Walk", true)

		repeat
			Wait()
			if Humanoid.MoveDirection.Magnitude > 0 then
				Character:TranslateBy(Humanoid.MoveDirection * SetNumber(Speed) * CWait(Services.Run.Heartbeat) * 10)
			end
		until not Get("Walk") or not Character
	end,
})

Command.Add({
	Aliases = { "untpwalk", "unwalk" },
	Description = "Stops the tpwalk command",
	Arguments = {},
	Task = function()
		Refresh("Walk", false)
	end,
})

Command.Add({
	Aliases = { "loop" },
	Description = "Repeatedly fire a command",
	Arguments = {
		{ Name = "Optional Delay", Type = "Number" },
		{ Name = "Command Name", Type = "String" },
		{ Name = "Arguments", Type = "String" },
	},
	Task = function(Delay, Name, Argumemts)
		local Arguments = nil
		Add("Loop", true)

		if tonumber(Delay) then
			Arguments = Minimum(FullArgs, 3)
		else
			Name, Delay, Arguments = Delay, 0.05, Minimum(FullArgs, 2)
		end

		repeat
			Wait(Delay or 0)
			Command.Run(true, Name, Arguments)
		until not Get("Loop")
	end,
})

Command.Add({
	Aliases = { "unloop" },
	Description = "Stops all the commands that are being repeated",
	Arguments = {},
	Task = function()
		Refresh("Loop", false)
		return "Loop", "Every looped command has been disabled"
	end,
})

Command.Add({
	Aliases = { "repeat" },
	Description = "Runs a command a repeated amount of times",
	Arguments = {
		{ Name = "Repeat amount", Type = "Number" },
		{ Name = "Delay", Type = "Number" },
		{ Name = "Command Name", Type = "String" },
		{ Name = "Arguments", Type = "String" },
	},
	Task = function(RepeatAmount, Delay, Name, Arguments)
		if tonumber(RepeatAmount) and tonumber(Delay) then
			Arguments = Minimum(FullArgs, 4)
		elseif tonumber(RepeatAmount) and not tonumber(Delay) then
			Name, Delay, Arguments = Delay, 0, Minimum(FullArgs, 3)
		elseif not tonumber(RepeatAmount) and not tonumber(Delay) then
			Name, RepeatAmount, Delay, Arguments = RepeatAmount, 1, 0, Minimum(FullArgs, 2)
		elseif RepeatAmount and Delay then
			Name, RepeatAmount, Delay, Arguments = RepeatAmount, 1, 0, Minimum(FullArgs, 2)
		end

		local Amount = tonumber(RepeatAmount) or 1
		for Index = 1, Amount do
			Command.Run(true, Name, Arguments or {})
			Wait(Delay or 0)
		end
		return Name, Format("Repeated %s times", Amount)
	end,
})

Command.Add({
	Aliases = { "tospawn", "ts" },
	Description = "Teleports you to a SpawnPoint",
	Arguments = {},
	Task = function()
		for Index, Point in next, GetClasses(workspace, "SpawnLocation") do
			Root.CFrame = Point.CFrame * CFrame.new(0, 5, 0)
		end
	end,
})

Command.Add({
	Aliases = { "god", "antikill" },
	Description = "Disables every part in the game from detecting if you touched it",
	Arguments = {},
	Task = function()
		for Index, BasePart in next, GetClasses(workspace, "BasePart") do
			BasePart.CanTouch = false
		end

		return "Anti Kill", "Anti kill has been enabled"
	end,
})

Command.Add({
	Aliases = { "ungod", "unantikill" },
	Description = "Disables the god command",
	Arguments = {},
	Task = function()
		for Index, BasePart in next, GetClasses(workspace, "BasePart") do
			BasePart.CanTouch = true
		end

		return "Anti Kill", "Anti kill has been disabled"
	end,
})

Command.Add({
	Aliases = { "dex", "explorer" },
	Description = "Opens Dex Explorer - by Moon",
	Arguments = {},
	Task = function()
		loadstring(GetModule("dex.lua"))()
	end,
})

Command.Add({
	Aliases = { "cameranoclip", "camnoclip", "cnc" },
	Description = "Allows your camera to see through walls",
	Arguments = {},
	Task = function()
		LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	end,
})

Command.Add({
	Aliases = { "uncameranoclip", "cameraclip", "camclip", "cc" },
	Description = "Disables the camera noclip command",
	Arguments = {},
	Task = function()
		LocalPlayer.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Zoom
	end,
})

Command.Add({
	Aliases = { "firstperson", "fps", "1p", "3rd" },
	Description = "Forces your character to go first-person",
	Arguments = {},
	Task = function()
		LocalPlayer.CameraMode = Enum.CameraMode.LockFirstPerson
	end,
})

Command.Add({
	Aliases = { "thirdperson", "tps", "3p", "1st" },
	Description = "Forces your camera to be 3rd person",
	Arguments = {},
	Task = function()
		LocalPlayer.CameraMode = Enum.CameraMode.Classic
	end,
})

Command.Add({
	Aliases = { "maxzoom", "maxz" },
	Description = "Set the max amount your camera can zoom out",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		LocalPlayer.CameraMaxZoomDistance = SetNumber(Amount)
		return "Maximum Zoom", Format("Set maximum zoom to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "minzoom", "minz" },
	Description = "Set the min amount your camera can zoom in",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		LocalPlayer.CameraMinZoomDistance = SetNumber(Amount)
		return "Minimum Zoom", Format("Set minimum zoom to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "autorespawn", "autore" },
	Description = "Automatically teleports you back to your death location",
	Arguments = {},
	Task = function()
		Add("AutoRespawn", true)

		local Teleport = function()
			Spawn(function()
				local Character = LocalPlayer.Character

				if Character and Get("AutoRespawn") then
					local Humanoid = Character:WaitForChild("Humanoid")
					local Pos

					Connect(Humanoid.Died, function()
						if Get("AutoRespawn") then
							Pos = Humanoid.RootPart.CFrame
						end
					end)

					CWait(LocalPlayer.CharacterAdded)
					local Root = LocalPlayer.Character:WaitForChild("HumanoidRootPart")

					Root.CFrame = (Pos or Root.CFrame)
				end
			end)
		end

		Teleport()
		Connect(LocalPlayer.CharacterAdded, Teleport)

		return "Auto Respawn", "Auto Respawn has been enabled"
	end,
})

Command.Add({
	Aliases = { "unautorespawn", "unautore" },
	Description = "Disables the autorespawn command",
	Arguments = {},
	Task = function()
		Refresh("AutoRespawn", false)
		return "Auto Respawn", "Auto Respawn has been disabled"
	end,
})

Command.Add({
	Aliases = { "fastcarts", "fastc" },
	Description = "Increases cart speed, making them go forward",
	Arguments = {},
	Task = function()
		for _, Cart in next, GetClasses(workspace, "Model", false) do
			local Button = Cart:FindFirstChild("Up")
			local ClickDetector = Button and Button:FindFirstChildOfClass("ClickDetector")

			if Button and Button:IsA("BasePart") and ClickDetector then
				Spawn(function()
					repeat
						Wait(0.05)
						fireclickdetector(ClickDetector)
					until not Button or not ClickDetector
				end)
			end
		end
	end,
})

Command.Add({
	Aliases = { "slowcarts", "slowc" },
	Description = "Decreases cart speed, making them go backwards",
	Arguments = {},
	Task = function()
		for _, Cart in next, GetClasses(workspace, "Model", false) do
			local Button = Cart:FindFirstChild("Down")
			local ClickDetector = Button and Button:FindFirstChildOfClass("ClickDetector")

			if Button and Button:IsA("BasePart") and ClickDetector then
				Spawn(function()
					repeat
						Wait(0.05)
						fireclickdetector(ClickDetector)
					until not Button or not ClickDetector
				end)
			end
		end
	end,
})

Command.Add({
	Aliases = { "enablechat", "enablec", "ech" },
	Description = "Enables the default chat UI",
	Arguments = {},
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, true)
	end,
})

Command.Add({
	Aliases = { "enableinventory", "enableinv", "einv" },
	Description = "Enables the default inventory UI",
	Arguments = {},
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, true)
	end,
})

Command.Add({
	Aliases = { "disableinventory", "disableinv", "dinv" },
	Description = "Disables the default inventory UI",
	Arguments = {},
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, false)
	end,
})

Command.Add({
	Aliases = { "fullbright", "fb" },
	Description = "Sets the game to full brightness",
	Arguments = {},
	Task = function()
		local Lighting = Services.Lighting

		MultiSet(Lighting, {
			ClockTime = 12,
			Brightness = 1,
			GlobalShadows = false,
			FogEnd = 9e9,
		})

		Connect(Changed(Lighting, "ClockTime"), function()
			Lighting.ClockTime = 12
		end)

		Connect(Changed(Lighting, "Brightness"), function()
			Lighting.Brightness = 5
		end)

		Connect(Changed(Lighting, "GlobalShadows"), function()
			Lighting.GlobalShadows = false
		end)

		Connect(Changed(Lighting, "FogEnd"), function()
			Lighting.FogEnd = 9e9
		end)

		return "Full Bright", "Full Bright has been enabled"
	end,
})

Command.Add({
	Aliases = { "fpsbooster", "fps" },
	Description = "Lowers graphics for more FPS",
	Arguments = {},
	Task = function()
		local SetInstance = function(Instance)
			if Instance then
				if Instance:IsA("Texture") or Instance:IsA("Decal") then
					Destroy(Instance)
				elseif Instance:IsA("BasePart") then
					Instance.Material = Enum.Material.Plastic
					Instance.Reflectance = 0
				elseif Instance:IsA("ParticleEmitter") or Instance:IsA("Trail") then
					Instance.Lifetime = NumberRange.new(0)
				elseif
					Instance:IsA("Fire")
					or Instance:IsA("SpotLight")
					or Instance:IsA("Smoke")
					or Instance:IsA("Sparkles")
				then
					Instance.Enabled = false
				end
			end
		end

		Connect(workspace.DescendantAdded, SetInstance)
		for Index, Instance in next, (workspace:GetDescendants()) do
			SetInstance(Instance)
		end

		return "FPS Booster", "Rejoin to undo the command"
	end,
})

Command.Add({
	Aliases = { "anticframeteleport", "actp" },
	Description = "Prevents the game from teleporting your character",
	Arguments = {},
	Task = function()
		local Allowed
		local Old

		Refresh("AntiCFrame", true)
		Connect(Changed(Root, "CFrame"), function()
			if Get("AntiCFrame") then
				Allowed = true
				Root.CFrame = Old

				Wait()
				Allowed = false
			end
		end)

		API:Notify({
			Title = "Anti Teleport",
			Description = "Anti CFrame Teleport has been enabled",
		})

		repeat
			Wait()
			Old = Root.CFrame
		until not Root
	end,
})

Command.Add({
	Aliases = { "unanticframeteleport", "unactp" },
	Description = "Disables the anticframeteleport command",
	Arguments = {},
	Task = function()
		Add("AntiCFrame", false)
		return "Anti Teleport", "Anti CFrame Teleport has been disabled"
	end,
})

Command.Add({
	Aliases = { "swordkill", "skill" },
	Description = "Kills your target using a sword",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local Sword
		for Index, Target in next, GetPlayer(Input) do
			if Target ~= LocalPlayer then
				local TCharacter = GetCharacter(Target)
				local TRoot = GetRoot(Target)
				local THumanoid = GetHumanoid(Target)
				local Timer = tick()

				if TCharacter and (not TCharacter:FindFirstChildOfClass("ForceField")) then
					for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
						if Find(Lower(Tool.Name), "sword") then
							Sword = Tool
						end
					end

					repeat
						Wait()
						Sword.Parent = Character
						Sword:Activate()
						if firetouchinterest then
							firetouchinterest(TRoot, Sword.Handle, 0)
							Wait()
							firetouchinterest(TRoot, Sword.Handle, 1)
						else
							TRoot.CFrame = Root.CFrame * CFrame.new(2, 0, -3)
						end
					until (THumanoid.Health == 0) or (tick() - Timer >= 5)
				end
			end
		end

		Humanoid:UnequipTools()
		return "Sword Kill", "Killed the target(s)"
	end,
})

Command.Add({
	Aliases = { "activatetool", "at" },
	Description = "Activates a specific tool",
	Arguments = {
		{ Name = "Tool", Type = "Script" },
	},
	Task = function(Input)
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			if Find(Lower(Tool.Name), Lower(Input)) then
				Tool.Parent = Character
				Tool:Activate()
				Wait()
				Tool.Parent = Backpack
			end
		end
	end,
})

Command.Add({
	Aliases = { "activatetools", "ats" },
	Description = "Activates every tool in your inventory",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			Tool.Parent = Character
			Tool:Activate()
			Wait()
			Tool.Parent = Backpack
		end
	end,
})

Command.Add({
	Aliases = { "equiptools", "et" },
	Description = "Equips every tool in your inventory",
	Arguments = {
		{ Name = "Tool", Type = "Script" },
	},
	Task = function(Input)
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			Tool.Parent = Character
		end
	end,
})

Command.Add({
	Aliases = { "deletetools", "dtools" },
	Description = "Removes all tools in your inventory",
	Arguments = {},
	Task = function()
		Backpack:ClearAllChildren()
		return "Delete Tools", "Cleared all children"
	end,
})

Command.Add({
	Aliases = { "spoof" },
	Description = "Spoof an instance's property",
	Arguments = {
		{ Name = "Instance PATH", Type = "String" },
		{ Name = "Propery", Type = "String" },
		{ Name = "Value", Type = "String" },
	},
	Task = function(Parent, Property, Value)
		local Instance = StringToInstance(Parent)

		if Value == "nil" then
			Value = nil
		elseif Value == "false" then
			Value = false
		end

		if Instance and Property and Value then
			Spoof(Instance, Property, Value)
			API:Notify({
				Title = "Spoofing",
				Description = Format("Spoofing %s and setting the value to %s", Property, tostring(Value)),
				Duration = 10,
				Info = "Success",
			})
		else
			API:Notify({
				Title = "Spoofing",
				Description = "One or more arguments missing when trying to spoof",
				Duration = 5,
				Info = "Error",
			})
		end
	end,
})

Command.Add({
	Aliases = { "spoofwalkspeed", "spoofws", "sws" },
	Description = "Spoofs your WalkSpeed",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		local Number = tonumber(Amount) or 16
		Spoof(GetHumanoid(LocalPlayer), "WalkSpeed", Number)
		return "Walkspeed", Format("Spoofed to %d", Number)
	end,
})

Command.Add({
	Aliases = { "spoofjumppower", "spoofjp", "sjp" },
	Description = "Spoofs your JumpPower",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		local Number = tonumber(Amount) or 16
		Spoof(GetHumanoid(LocalPlayer), "JumpPower", Number)
		return "Jump Power", Format("Spoofed to %d", Number)
	end,
})

Command.Add({
	Aliases = { "invisible", "invis", "inv" },
	Description = "Makes your character invisible",
	Arguments = {},
	Task = function()
		local OriginalPlayer = Services.Lighting:FindFirstChild(LocalPlayer.Name)
		Character.Archivable = true
		if not OriginalPlayer then
			local Clone = Clone(Character)
			local Animate = Clone.Animate
			for Index, BodyPart in next, GetClasses(Clone, "BasePart", true) do
				BodyPart.Transparency = 0.7
			end

			Root.CFrame = CFrame.new(1000, 1000, 1000)
			Wait(0.1)
			Root.Anchored = true
			Clone.Parent = Character.Parent
			Character.Parent = Services.Lighting
			LocalPlayer.Character = Clone

			Animate.Disabled = true
			Animate.Disabled = false

			Character = Clone
			Root = GetRoot(LocalPlayer)
			Humanoid = GetHumanoid(LocalPlayer)
			Camera.CameraSubject = Humanoid
		end
	end,
})

Command.Add({
	Aliases = { "visible", "vis" },
	Description = "Makes your character visible (disables invisible)",
	Arguments = {},
	Task = function()
		local OriginalPlayer = Services.Lighting:FindFirstChild(LocalPlayer.Name)
		if OriginalPlayer then
			local Invisible = LocalPlayer.Character
			local Parent = Invisible.Parent
			local Position = Root.CFrame

			LocalPlayer.Character = OriginalPlayer
			LocalPlayer.Character.Parent = Parent
			Character = OriginalPlayer
			Root = GetRoot(LocalPlayer)
			Humanoid = GetHumanoid(LocalPlayer)

			Wait(0.1)
			Root.Anchored = false
			Root.CFrame = Position
			Camera.CameraSubject = Humanoid
			Destroy(Invisible)
		end
	end,
})

Command.Add({
	Aliases = { "sit" },
	Description = "Makes you sit",
	Arguments = {},
	Task = function()
		Humanoid.Sit = true
	end,
})

Command.Add({
	Aliases = { "flood" },
	Description = "Floods the chat with spam",
	Arguments = {},
	Task = function()
		Refresh("Flood", true)
		repeat
			Wait(1)
			Chat(("⸻"):rep(50))
		until not Get("Flood")
	end,
})

Command.Add({
	Aliases = { "unflood" },
	Description = "Stops the flood command",
	Arguments = {},
	Task = function()
		Refresh("Flood", false)
	end,
})

Command.Add({
	Aliases = { "spam" },
	Description = "Spams your selected message into the chat",
	Arguments = {
		{ Name = "Message", Type = "String" },
	},
	Task = function(Message)
		Add("Spam", true)
		repeat
			Wait(0.3)
			Chat(Message)
		until not Get("Spam")
	end,
})

Command.Add({
	Aliases = { "unspam" },
	Description = "Disables the spam command",
	Arguments = {},
	Task = function()
		Refresh("Spam", false)
		return "Spam", "Stopped the spamming"
	end,
})

Command.Add({
	Aliases = { "sync" },
	Description = "Plays every sound in-game in sync",
	Arguments = {},
	Task = function()
		Refresh("Sync", true)
		if RespectFilteringEnabled then
			return "Sync", "Couldn't sync since RFE is turned on"
		else
			repeat
				Wait()
				for Index, Sound in next, GetClasses(game, "Sound") do
					Sound.Volume = 10
					Sound:Play()
				end
			until not Get("Sync")
		end
	end,
})

Command.Add({
	Aliases = { "unsync" },
	Description = "Disables the sync command",
	Arguments = {},
	Task = function()
		Refresh("Sync", false)
	end,
})

Command.Add({
	Aliases = { "buff" },
	Description = "Easier to move unanchored parts",
	Arguments = {},
	Task = function()
		for Index, BodyPart in next, GetClasses(Character, "BasePart", true) do
			BodyPart.CustomPhysicalProperties = PhysicalProperties.new(math.huge, 0.5, 0.5)
		end
		return "Buff", "Buff has been enabled"
	end,
})

Command.Add({
	Aliases = { "unbuff" },
	Description = "Disables the buff command",
	Arguments = {},
	Task = function()
		for Index, BodyPart in next, GetClasses(Character, "BasePart", true) do
			BodyPart.CustomPhysicalProperties = PhysicalProperties.new(1, 0.5, 0.5)
		end
		return "Buff", "Buff has been disabled"
	end,
})

Command.Add({
	Aliases = { "setunanchoredgravity", "sug" },
	Description = "Sets the gravity for unanchored parts",
	Arguments = {
		{ Name = "Amount", Type = "String" },
	},
	Task = function(Amount)
		local Gravity = SetNumber(Amount)
		local Set = function(Part)
			if Part and Part:IsA("BasePart") and not Part.Anchored then
				Create("BodyForce", {
					Force = Part:GetMass() * Vector3.new(Gravity, workspace.Gravity, Gravity),
					Parent = Part,
				})
			end
		end

		SetSRadius(9e9, 9e9)
		Connect(workspace.DescendantAdded, Set)

		for Index, Part in next, GetClasses(workspace, "BasePart") do
			Set(Part)
		end

		return "Gravity", Format("Set unanchored gravity to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "remotespy", "rspy" },
	Description = "UI for viewing fired remotes",
	Arguments = {},
	Task = function(Amount)
		loadstring(game:HttpGet("https://raw.githubusercontent.com/78n/SimpleSpy/main/SimpleSpySource.lua"))()
	end,
})

Command.Add({
	Aliases = { "deleteparts", "delparts" },
	Description = "Deletes every unanchored part you have network ownership over",
	Arguments = {},
	Task = function()
		local Target = Create("Part", {
			CFrame = CFrame.new(0, workspace.FallenPartsDestroyHeight + 10, 0),
			Anchored = true,
			CanCollide = false,
		})

		for Index, Part in next, GetClasses(workspace, "BasePart") do
			local Model = Part:FindFirstAncestorOfClass("Model")
			local isPlayer = (Model and Services.Players:GetPlayerFromCharacter(Model))
			if (not Part.Anchored) and not isPlayer then
				Bring(Part, Target);
			end
		end

		Destroy(Target);
	end,
})

Command.Add({
	Aliases = { "attachpart", "apart" },
	Description = "Click an unanchored part to attach it",
	Arguments = {},
	Task = function()
		Connect(Mouse.Button1Down, function()
			local Target = Mouse.Target
			Attach(Target)
		end)

		return "Part Attach", "Loaded successfully!"
	end,
})

Command.Add({
	Aliases = { "attachparts", "aparts" },
	Description = "Attaches all unanchored parts to you",
	Arguments = {},
	Task = function()
		for Index, Part in next, GetClasses(workspace, "BasePart") do
			Attach(Part)
		end
		return "Part Attach", "Attached to every part in game"
	end,
})

Command.Add({
	Aliases = { "controlnpc", "cnpc" },
	Description = "Click an NPC to start controlling it",
	Arguments = {},
	Task = function()
		Refresh("ControlNPC", true)
		Connect(Mouse.Button1Down, function()
			local Target = Mouse.Target
			local ModelDescendant = Target:FindFirstAncestorOfClass("Model")
			local HasHumanoid = (ModelDescendant and ModelDescendant:FindFirstChildOfClass("Humanoid"))

			if
				ModelDescendant
				and HasHumanoid
				and (not Services.Players:GetPlayerFromCharacter(ModelDescendant))
				and Get("ControlNPC")
			then
				local RootPart = ModelDescendant:FindFirstChild("HumanoidRootPart")
					or ModelDescendant:FindFirstChild("Torso")

				Attach(RootPart)
				repeat
					Wait()
					for Index, BodyPart in next, GetClasses(ModelDescendant, "BasePart") do
						BodyPart.CanCollide = false
					end
				until not Get("ControlNPC") or not ModelDescendant
			end
		end)

		return "NPC", "Control NPC has been enabled"
	end,
})

Command.Add({
	Aliases = { "uncontrolnpc", "uncnpc" },
	Description = "Disables the ControlNPC command",
	Arguments = {},
	Task = function()
		Refresh("ControlNPC", false)
		return "NPC", "Control NPC has been disabled"
	end,
})

Command.Add({
	Aliases = { "blackhole", "bh" },
	Description = "Creates a black hole that grabs unanchored parts",
	Arguments = {},
	Task = function()
		Refresh("Blackhole", true)
		local Blackhole = Create("Part", {
			Parent = workspace,
			Transparency = 0.5,
			CFrame = Root.CFrame,
			CanCollide = false,
			Anchored = true,
		})

		repeat
			Wait(1)
			for Index, Part in next, GetClasses(workspace, "BasePart") do
				Bring(Part, Blackhole)
			end
		until not Get("Blackhole")
		Destroy(Blackhole)
	end,
})

Command.Add({
	Aliases = { "unblackhole", "unbh" },
	Description = "Disables the blackhole command",
	Arguments = {},
	Task = function()
		Refresh("Blackhole", false)
	end,
})

Command.Add({
	Aliases = { "unattach" },
	Description = "Detaches all previously attached parts",
	Arguments = {},
	Task = function()
		for Index, Attachment in next, workspace:GetDescendants() do
			if Attachment.Name == AttachName then
				Destroy(Attachment)
			end
		end
		return "Part Attach", "Unattached every part"
	end,
})

Command.Add({
	Aliases = { "bringunanchored", "bringua", "brua" },
	Description = "Brings all unanchored parts to you or your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Player)
		local Players = GetPlayer(Player or "me")
		local Target = Players[1] or LocalPlayer

		for _, Part in next, GetClasses(workspace, "BasePart") do
			if not Part.Anchored then
				Bring(Part, GetRoot(Target))
			end
		end

		return "Unanchored", "All possible parts have been brough"
	end,
})

Command.Add({
	Aliases = { "stand" },
	Description = "Turns you into someone's stand",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Player)
		local Targets = GetPlayer(Player)
		Refresh("Stand", true)

		for _, Target in next, Targets do
			local Anim = Create("Animation", { AnimationId = "rbxassetid://3337994105" })
			local Load = GetHumanoid(LocalPlayer):LoadAnimation(Anim)

			Camera.CameraSubject = GetHumanoid(Target)
			Load:Play()
			Command.Parse(true, "airwalk")

			repeat
				Wait()
				local Root = GetRoot(Target)

				if Root then
					GetRoot(LocalPlayer).CFrame = GetRoot(Target).CFrame * CFrame.new(2.2, 1.2, 2.3)
				else
					break
				end
			until not Get("Stand") or not Target

			Load:Stop()
			Add("Stand", false)
			Command.Parse(true, "unairwalk")
			Camera.CameraSubject = GetHumanoid(LocalPlayer)
			break
		end
	end,
})

Command.Add({
	Aliases = { "unstand" },
	Description = "Disables the Stand command",
	Arguments = {},
	Task = function()
		Add("Stand", false)
	end,
})

Command.Add({
	Aliases = { "killnpcs", "knpc" },
	Description = "Kills all NPCs",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do
			local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.Health = 0
			end
		end
		return "NPC", "Killed all NPCs"
	end,
})

Command.Add({
	Aliases = { "flingnpcs", "fnpc" },
	Description = "Flings all NPCs",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do
			local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.HipHeight = 1024
			end
		end
		return "NPC", "Flinged all NPCs"
	end,
})

Command.Add({
	Aliases = { "voidnpcs", "vnpc" },
	Description = "Voids all NPCs",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do
			local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				Humanoid.HipHeight = -1024
			end
		end
		return "NPC", "Voided all NPCs"
	end,
})

Command.Add({
	Aliases = { "bringnpcs", "bnpc" },
	Description = "Brings all NPCs",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do
			local RootPart = (NPC:FindFirstChild("HumanoidRootPart") or NPC:FindFirstChild("Torso"))
			if RootPart then
				RootPart.CFrame = Root.CFrame
			end
		end
		return "NPC", "Brought all NPCs"
	end,
})

Command.Add({
	Aliases = { "follownpcs", "fonpc" },
	Description = "Makes all NPCs follow you",
	Arguments = {},
	Task = function()
		Refresh("FollowNPCs", true)

		repeat
			Wait(0.1)
			for Index, NPC in next, GetPlayer("NPC") do
				local Humanoid = NPC:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					Humanoid:MoveTo(Root.Position)
				end
			end
		until not Get("FollowNPCs")
	end,
})

Command.Add({
	Aliases = { "unfollownpcs", "unfonpc" },
	Description = "Disables the FollowNPCs command",
	Arguments = {},
	Task = function()
		Refresh("FollowNPCs", false)
	end,
})

Command.Add({
	Aliases = { "setsimulationradius", "setsimradius", "ssr" },
	Description = "Useful for commands that require unanchored parts (set to a large number)",
	Arguments = {
		{ Name = "Amount", Type = "Amount" },
	},
	Task = function(Amount)
		local N = SetNumber(Amount)
		SetSRadius(N, N)
		return "Simulation Radius", Format("Successfully set your simulation radius to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "freegamepasses", "freegp", "fgp" },
	Description = "Pretends you own every gamepass and fires signals as if you bought them all",
	Arguments = {},
	Task = function()
		local Products = Services.Market:GetDeveloperProductsAsync():GetCurrentPage()
		local SignalsFired = 0

		if Check("Hook") then
			Add(
				"GamepassHook",
				hookfunction(
					Services.Market.UserOwnsGamePassAsync,
					newcclosure(function(...)
						return true
					end)
				)
			)
		end

		for Index, Product in next, Products do
			for Type, ID in next, Product do
				if (Type == "ProductId") or (Type == "DeveloperProductId") then
					Services.Market:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, ID, true)
					SignalsFired += 1
				end
			end
		end

		return "Gamepasses fired",
			Format("All gamepasses have been hooked as well as fired %s purchase signals", SignalsFired),
			15
	end,
})

Command.Add({
	Aliases = { "saveinstance", "savemap" },
	Description = "Saves the current game as a file",
	Arguments = {},
	Task = function()
		if saveinstance then
			saveinstance()
		else
			return "Save Instance", "Your executor does not support save instance, missing function saveinstance()", 15
		end
	end,
})

Command.Add({
	Aliases = { "climb" },
	Description = "Allows you to climb in the air",
	Arguments = {},
	Task = function()
		local oldPart = Get("ClimbPart")
		local Part = Create("TrussPart", {
			Transparency = 1,
			Size = Vector3.new(2, 10, 2),
			Parent = workspace,
			CanCollide = true,
			Name = GenerateGUID(Services.Http),
		})

		Add("ClimbPart", Part)
		if oldPart then
			Destroy(oldPart)
		end

		while Part and Wait() do
			Part.CFrame = Root.CFrame * CFrame.new(0, 0, -1.5)
		end
	end,
})

Command.Add({
	Aliases = { "unclimb" },
	Description = "Disables the climb command",
	Arguments = {},
	Task = function()
		Destroy(Get("ClimbPart"))
	end,
})

Command.Add({
	Aliases = { "setfpscap", "sfc" },
	Description = "Sets the maximum FPS limit",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		if setfpscap then
			setfpscap(SetNumber(Amount))
			return "FPS", Format("Set your FPS cap to %s", Amount)
		else
			return "Unsupported Executor", "Your executor does not support this command, missing function - setfpscap()"
		end
	end,
})

Command.Add({
	Aliases = { "unlockfps", "unlf" },
	Description = "Unlocks the FPS limit (1000)",
	Arguments = {},
	Task = function()
		if setfpscap then
			setfpscap(1000)
			return "FPS Cap", "Unlocked to 1000"
		else
			return "Unsupported Executor", "Your executor does not support this command, missing function - setfpscap()"
		end
	end,
})

Command.Add({
	Aliases = { "antikick" },
	Description = "Prevents (client) scripts from kicking you",
	Arguments = {},
	Task = function()
		Refresh("AntiKick", true)
		if Check("Hook") then
			for Index, Kick in next, { LocalPlayer.Kick, LocalPlayer.kick } do
				local Call
				Call = hookfunction(Kick, function(...)
					if not Get("AntiKick") then
						return Call(...)
					end
				end)
			end

			return "Anti Kick", "Anti Kick has been enabled"
		else
			return "Unsupported Executor", "Your executor does not support hooking"
		end
	end,
})

Command.Add({
	Aliases = { "unantikick" },
	Description = "Disables AntiKick",
	Arguments = {},
	Task = function()
		Refresh("AntiKick", false)
		return "Anti Kick", "Anti Kick has been disabled"
	end,
})

Command.Add({
	Aliases = { "antiteleport" },
	Description = "Prevents you from getting teleported to other games",
	Arguments = {},
	Task = function()
		Refresh("AntiTeleport", true)
		if Check("Hook") then
			for Index, Kick in next, { Services.Http.TeleportToPlaceInstance, TeleportToPrivateServer } do
				local Call
				Call = hookfunction(Kick, function(...)
					if not Get("AntiTeleport") then
						return Call(...)
					end
				end)
			end
			return "Anti Teleport", "Anti Teleport has been enabled"
		else
			return "Unsupported Executor", "Your executor does not support hooking"
		end
	end,
})

Command.Add({
	Aliases = { "unantiteleport" },
	Description = "Disables AntiTeleport",
	Arguments = {},
	Task = function()
		Refresh("AntiTeleport", false)
		return "Anti Teleport", "Anti Teleport has been disabled"
	end,
})

Command.Add({
	Aliases = { "grabber" },
	Description = "Drops a tool and tracks who picks it up (for those using automatic tool grabbers)",
	Arguments = {},
	Task = function()
		local Tool = Backpack:FindFirstChildOfClass("Tool")
		local Grabber

		Tool.Parent = Character
		Tool.Parent = workspace
		Wait(2)

		if Tool and Tool.Parent ~= workspace then
			if Tool.Parent:IsA("Backpack") and Tool.Parent.Parent ~= LocalPlayer then
				Grabber = Tool.Parent.Parent.Name
			elseif Tool.Parent:IsA("Model") and Tool.Parent ~= LocalPlayer then
				Grabber = Tool.Parent.Name
			end
		elseif Tool.Parent == workspace then
			Humanoid:EquipTool(Tool)
		end

		if Grabber then
			return "Grabber", Format("Grabber found, username - %s", Grabber)
		else
			return "Grabber", "Could not find grabber"
		end
	end,
})

Command.Add({
	Aliases = { "grabtools", "gt" },
	Description = "Grabs all dropped tools",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(workspace, "Tool") do
			Humanoid:EquipTool(Tool)
		end
	end,
})

Command.Add({
	Aliases = { "autograbtools", "agt" },
	Description = "Automatically grabs tools",
	Arguments = {},
	Task = function()
		Add("AutoGrab", true)
		Connect(workspace.DescendantAdded, function(Tool)
			if Tool:IsA("Tool") and Get("AutoGrab") then
				Humanoid:EquipTool(Tool)
				Tool.Parent = Backpack
			end
		end)

		return "Auto", "Auto Grab Tools enabled"
	end,
})

Command.Add({
	Aliases = { "unautograbtools", "unagt" },
	Description = "Disables the AutoGrabTools command",
	Arguments = {},
	Task = function()
		Add("AutoGrab", false)
		return "Auto", "Auto Grab Tools disabled"
	end,
})

Command.Add({
	Aliases = { "grabdeletetools", "gdt" },
	Description = "Deletes all dropped tools",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(workspace, "Tool") do
			Humanoid:EquipTool(Tool)
			Wait()
			Destroy(Tool)
		end
	end,
})

Command.Add({
	Aliases = { "autograbdeletetools", "agdt" },
	Description = "Automatically deletes dropped tools",
	Arguments = {},
	Task = function()
		Add("AutoGrabDelete", true)
		Connect(workspace.DescendantAdded, function(Tool)
			if Tool:IsA("Tool") and Get("AutoGrabDelete") then
				Humanoid:EquipTool(Tool)
				Wait()
				Destroy(Tool)
			end
		end)

		return "Auto", "Auto Grab Delete Tools enabled"
	end,
})

Command.Add({
	Aliases = { "unautograbdeletetools", "unagdt" },
	Description = "Stops the AutoGrabDeleteTools command",
	Arguments = {},
	Task = function()
		Add("AutoGrabDelete", false)
		return "Auto", "Auto Grab Delete Tools disabled"
	end,
})

Command.Add({
	Aliases = { "antisit" },
	Description = "Disables sitting",
	Arguments = {},
	Task = function()
		Humanoid:SetStateEnabled("Seated", false)
		Humanoid.Sit = true
		return "Anti Sit", "Anti Sit has been enabled"
	end,
})

Command.Add({
	Aliases = { "unantisit" },
	Description = "Enables sitting",
	Arguments = {},
	Task = function()
		Humanoid:SetStateEnabled("Seated", true)
		Humanoid.Sit = false
		return "Anti Sit", "Anti Sit has been disabled"
	end,
})

Command.Add({
	Aliases = { "setspawn", "ss" },
	Description = "Sets your new spawn location",
	Arguments = {},
	Task = function()
		local Old = Root.CFrame
		Refresh("SetSpawn", true)

		Detection = (Detection and Detection:Disconnect())
		Detection = Connect(LocalPlayer.CharacterAdded, function(NewCharacter)
			if Get("SetSpawn") then
				NewCharacter:WaitForChild("HumanoidRootPart").CFrame = Old
			end
		end)

		return "Spawn", "Spawnpoint added"
	end,
})

Command.Add({
	Aliases = { "unsetspawn", "unss" },
	Description = "Deletes the spawn location you've saved",
	Arguments = {},
	Task = function()
		Refresh("SetSpawn", false)
		Detection = (Detection and Detection:Disconnect())

		return "Spawn", "Spawnpoint has been deleted"
	end,
})

Command.Add({
	Aliases = { "loadstring", "ls" },
	Description = "Runs whatever script you input",
	Arguments = {
		{ Name = "Script", Type = "String" },
	},
	Task = function(src)
		local Success, Result = pcall(function()
			loadstring(src)()
		end)

		if Success then
			return "Source", "Ran source without any errors"
		else
			return "Error occured running script", Result
		end
	end,
})

Command.Add({
	Aliases = { "url" },
	Description = "Runs the script from the URL you input",
	Arguments = {
		{ Name = "URL", Type = "String" },
	},
	Task = function(url)
		local Success, Result = pcall(function()
			loadstring(Methods.Get(url))()
		end)

		if Success then
			return "Source", "Ran source without any errors"
		else
			return "Error occured running script", Result
		end
	end,
})

Command.Add({
	Aliases = { "fly" },
	Description = "Enables your character to fly",
	Arguments = {
		{ Name = "Speed", Type = "Number" },
	},
	Task = function(Amount)
		SetFly(true, tonumber(Amount) or 10)
		return "Fly", "Fly has been enabled"
	end,
})

Command.Add({
	Aliases = { "unfly" },
	Description = "Disables the Fly command",
	Arguments = {},
	Task = function()
		SetFly(false)
		return "Fly", "Fly has been disabled"
	end,
})

Command.Add({
	Aliases = { "r6" },
	Description = "Shows a prompt changing your avatar to R6",
	Arguments = {},
	Task = function()
		SetRig("R6")
	end,
})

Command.Add({
	Aliases = { "r15" },
	Description = "Shows a prompt changing your avatar to R15",
	Arguments = {},
	Task = function()
		SetRig("R15")
	end,
})

Command.Add({
	Aliases = { "walkspeed", "ws" },
	Description = "Set your character's walkspeed (tpwalk recommended instead)",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		Humanoid.WalkSpeed = SetNumber(Amount)
		return "Walk speed", Format("Set walkspeed to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "jumppower", "jp" },
	Description = "Sets your jump power",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		Humanoid.JumpPower = SetNumber(Amount)
		Humanoid.UseJumpPower = true
		return "Jump Power", Format("Set jump power to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "hipheight", "hh" },
	Description = "Adjusts your character HipHeight",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		Humanoid.HipHeight = SetNumber(Amount)
		return "Hip Height", Format("Set hip height to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "gravity" },
	Description = "Adjusts the game's gravity (default: 196.2)",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		workspace.Gravity = SetNumber(Amount)
		return "Gravity", Format("Set gravity to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "time" },
	Description = "Set the Time of Day (0-24)",
	Arguments = {
		{ Name = "Time", Type = "Number" },
	},
	Task = function(Time)
		Services.Lighting.ClockTime = SetNumber(Time)
		return "Time", Format("Set time to %s", Time)
	end,
})

Command.Add({
	Aliases = { "airwalk", "aw" },
	Description = "Allows you to walk on air; jump to go up",
	Arguments = {},
	Task = function()
		local Old = Get("AirPart")
		local Part = Create("Part", {
			Transparency = 1,
			Size = Vector3.new(7, 2, 3),
			Parent = workspace,
			CanCollide = true,
			Anchored = true,
			Name = GenerateGUID(Services.Http),
		})

		Add("AirPart", Part)

		if Old then
			Destroy(Old)
		end

		while Part and Wait() do
			Part.CFrame = Root.CFrame + Vector3.new(0, -4, 0)
		end
	end,
})

Command.Add({
	Aliases = { "unairwalk", "unaw" },
	Description = "Disables the airwalk command",
	Arguments = {},
	Task = function()
		Destroy(Get("AirPart"))

		return "Air Walk", "Disabled air walk"
	end,
})

Command.Add({
	Aliases = { "show" },
	Description = "Reveals all invisible parts in-game",
	Arguments = {},
	Task = function()
		Refresh("Hidden", {})
		for Index, Wall in next, GetClasses(workspace, "BasePart") do
			if (Wall.Transparency == 1) and (Wall.Name ~= "HumanoidRootPart") then
				Insert(Get("Hidden"), Wall)
				Wall.Transparency = 0
			end
		end

		return "Show", "Showing all invisible walls, type unshow to hide them"
	end,
})

Command.Add({
	Aliases = { "hide" },
	Description = "Disables the Show command",
	Arguments = {},
	Task = function()
		for Index, Wall in next, Get("Hidden") do
			Wall.Transparency = 1
		end

		return "Hide", "Hidden all previously shown walls"
	end,
})

Command.Add({
	Aliases = { "teamchange", "teamc" },
	Description = "Touches any SpawnLocation that changes your team",
	Arguments = {},
	Task = function()
		local OldPosition = Root.CFrame
		local FoundCheckpoints = 0

		for Index, Point in next, GetClasses(workspace, "SpawnLocation") do
			if Point.AllowTeamChangeOnTouch then
				Root.CFrame = Point.CFrame
				FoundCheckpoints += 1
				Wait(0.1)
			end
		end

		Root.CFrame = OldPosition
		return "Team Change", Format("Touched %s spawn locations with TeamChange enabled", FoundCheckpoints), 10
	end,
})

Command.Add({
	Aliases = { "droptools", "dp" },
	Description = "Drops all tools in your inventory",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			Tool.Parent = Character
			Tool.Parent = workspace
		end
	end,
})

Command.Add({
	Aliases = { "loopdroptools", "ldp" },
	Description = "Repeatedly drops all tools in your inventory",
	Arguments = {},
	Task = function()
		local OldPosition = Root.CFrame
		Refresh("LoopDrop", true)

		local Drop = function(Char)
			if Get("LoopDrop") then
				repeat
					Wait()
				until Root
				for Index = 1, 5 do
					Root.CFrame = OldPosition
					Wait(0.1)
				end

				for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
					Tool.Parent = Character
					Tool.Parent = workspace
				end

				Humanoid.Health = 0
			end
		end

		Drop(Character)
		Connect(LocalPlayer.CharacterAdded, Drop)
	end,
})

Command.Add({
	Aliases = { "unloopdroptools", "unldp" },
	Description = "Disables the LoopDropTools command",
	Arguments = {},
	Task = function()
		Refresh("LoopDrop", false)
	end,
})

Command.Add({
	Aliases = { "savetools", "st" },
	Description = "Drops all your tools in the sky, type LoadTools to get them back",
	Arguments = {},
	Task = function()
		local OldPosition = Root.CFrame

		Root.CFrame = CFrame.new(0, 9e9, 0)
		Wait(1)
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			if Tool.CanBeDropped then
				Tool.Parent = Character
				Tool.Parent = workspace
			end
		end

		Wait(0.5)

		Root.CFrame = OldPosition
	end,
})

Command.Add({
	Aliases = { "loadtools", "lt" },
	Description = "Receives all the tools you've saved",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(workspace, "Tool", true) do
			Humanoid:EquipTool(Tool)
		end
	end,
})

Command.Add({
	Aliases = { "spazz" },
	Description = "Similiar to the spin command",
	Arguments = {},
	Task = function()
		if Spazz then
			Destroy(Spazz)
		end

		Root.CFrame = Root.CFrame * CFrame.Angles(-0.3, 0, 0)
		Spazz = Create("BodyAngularVelocity", {
			P = 200000,
			AngularVelocity = Vector3.new(0, 15, 0),
			MaxTorque = Vector3.new(200000, 200000, 200000),
			Parent = Root,
		})
	end,
})

Command.Add({
	Aliases = { "unspazz" },
	Description = "Disables the Spazz command",
	Arguments = {},
	Task = function()
		if Spazz then
			Destroy(Spazz)
		end
	end,
})

Command.Add({
	Aliases = { "lockmouse", "lm" },
	Description = "Locks your Mouse in the center",
	Arguments = {},
	Task = function()
		Refresh("MouseLock", true)

		repeat
			Wait()
			Services.Input.MouseBehavior = Enum.MouseBehavior.LockCenter
		until not Get("MouseLock")
	end,
})

Command.Add({
	Aliases = { "unlockmouse", "unlm" },
	Description = "Makes your mouse unlocked, freely movable",
	Arguments = {},
	Task = function()
		Refresh("MouseLock", false)
		Services.Input.MouseBehavior = Enum.MouseBehavior.Default
	end,
})

Command.Add({
	Aliases = { "spin" },
	Description = "Spins your character",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		if Spin then
			Destroy(Spin)
		end

		Spin = Create("BodyAngularVelocity", {
			Parent = Root,
			MaxTorque = Vector3.new(0, 9e9, 0),
			AngularVelocity = Vector3.new(0, SetNumber(Amount), 0),
		})
	end,
})

Command.Add({
	Aliases = { "unspin" },
	Description = "Disables the Spin command",
	Arguments = {},
	Task = function()
		Destroy(Spin)
	end,
})

Command.Add({
	Aliases = { "noclip", "nc" },
	Description = "Allows your character to pass through walls",
	Arguments = {},
	Task = function()
		Refresh("Noclip", true)

		API:Notify({
			Title = "Noclip",
			Description = "Noclip has been enabled",
		})

		repeat
			Wait()
			for Index, Part in next, GetClasses(Character, "BasePart", true) do
				Part.CanCollide = false
			end
		until not Get("Noclip")
	end,
})

Command.Add({
	Aliases = { "unnoclip", "clip", "c" },
	Description = "Disables the Noclip command",
	Arguments = {},
	Task = function()
		Refresh("Noclip", false)

		for Index, Part in next, GetClasses(Character, "BasePart", true) do
			Part.CanCollide = false
		end

		return "Noclip", "Noclip has been disabled"
	end,
})

Command.Add({
	Aliases = { "freeze", "fr" },
	Description = "Freezes your character",
	Arguments = {},
	Task = function()
		for Index, Part in next, GetClasses(Character, "BasePart", true) do
			Part.Anchored = true
		end
	end,
})

Command.Add({
	Aliases = { "unfreeze", "unfr" },
	Description = "Disables the freeze command",
	Arguments = {},
	Task = function()
		for Index, Part in next, Character:GetChildren() do
			if Part:IsA("BasePart") then
				Part.Anchored = false
			end
		end
	end,
})

Command.Add({
	Aliases = { "animationspeed", "animspeed" },
	Description = "Adjust your animation speed",
	Arguments = {
		{ Name = "Speed", Type = "Number" },
	},
	Task = function(Amount)
		local Amount = SetNumber(Amount, 2, math.huge)

		Add("AnimationSpeed", true)
		API:Notify({
			Title = "Animation Speed",
			Description = Format("Set animation speed to %s", Amount),
		})

		repeat
			Wait()
			for Index, Track in next, Humanoid:GetPlayingAnimationTracks() do
				Track:AdjustSpeed(Amount)
			end
		until not Get("AnimationSpeed")
	end,
})

Command.Add({
	Aliases = { "unanimationspeed", "unanimspeed" },
	Description = "Adjusts your animation speed to go back to normal",
	Arguments = {
		{ Name = "Speed", Type = "Number" },
	},
	Task = function(Amount)
		Refresh("AnimationSpeed", false)
		for Index, Track in next, Humanoid:GetPlayingAnimationTracks() do
			Track:AdjustSpeed(Amount)
		end

		return "Animation Speed", "Set animation speed back to normal"
	end,
})

Command.Add({
	Aliases = { "freezeanimations", "fan" },
	Description = "Freezes your animations",
	Arguments = {},
	Task = function()
		Character.Animate.Disabled = true
	end,
})

Command.Add({
	Aliases = { "unfreezeanimations", "unfan" },
	Description = "Disables the FreezeAnimations command",
	Arguments = {},
	Task = function()
		Character.Animate.Disabled = false
	end,
})

Command.Add({
	Aliases = { "nodelay" },
	Description = "Removes the delay from ProximityPrompts",
	Arguments = {},
	Task = function()
		for Index, Proximity in next, GetClasses(workspace, "ProximityPrompt") do
			Proximity.HoldDuration = 0
		end

		return "No Delay", "Proximity Prompt delay has been set to 0"
	end,
})

Command.Add({
	Aliases = { "firetouchinterests", "fti" },
	Description = "Fires all TouchInterests",
	Arguments = {},
	Task = function()
		local Fired = 0
		if not firetouchinterest then
			return "Missing Function",
				"Executor does not support this command, missing function - firetouchinterest",
				10
		end

		for Index, Target in next, GetClasses(workspace, "TouchTransmitter") do
			firetouchinterest(Root, Target.Parent, 0)
			firetouchinterest(Root, Target.Parent, 1)
			Fired += 1
		end

		return "Fired", Format("Fired %s touch interests", Fired)
	end,
})

Command.Add({
	Aliases = { "fireproximityprompts", "fpp" },
	Description = "Fires all ProximityPrompts",
	Arguments = {},
	Task = function()
		local Fired = 0
		if not fireproximityprompt then
			return "Missing Function",
				"Executor does not support this command, missing function - fireproximityprompt",
				10
		end

		for Index, Target in next, GetClasses(workspace, "ProximityPrompt") do
			fireproximityprompt(Target, 0)
			Wait()
			fireproximityprompt(Target, 1)
			Fired += 1
		end

		return "Fired", Format("Fired %s proximity prompts", Fired)
	end,
})

Command.Add({
	Aliases = { "fireclickdetectors", "fcd" },
	Description = "Fires all ClickDetectors",
	Arguments = {},
	Task = function()
		local Fired = 0
		if not fireclickdetector then
			return "Missing Function",
				"Executor does not support this command, missing function - fireclickdetector",
				10
		end

		for Index, Target in next, GetClasses(workspace, "ClickDetector") do
			fireclickdetector(Target)
			Fired += 1
		end

		return "Fired", Format("Fired %s click detectors", Fired)
	end,
})

Command.Add({
	Aliases = { "fireremotes", "fre" },
	Description = "Fires all Remotes",
	Arguments = {},
	Task = function()
		local Fired = 0

		for Index, Target in next, GetClasses(game, "RemoteEvents") do
			Target:FireServer()
			Fired += 1
		end

		for Index, Target in next, GetClasses(game, "UnreliableRemoteEvent") do
			Target:FireServer()
			Fired += 1
		end

		return "Fired", Format("Fired %s remotes", Fired)
	end,
})

Command.Add({
	Aliases = { "showprompts" },
	Description = "Starts showing purchase prompts",
	Arguments = {},
	Task = function()
		MultiSet(Services.Core.PurchasePrompt, {
			Enabled = true,
		})

		return "Prompts", "Showing purchase prompts"
	end,
})

Command.Add({
	Aliases = { "hideprompts" },
	Description = "Hides all purchase prompts",
	Arguments = {},
	Task = function()
		MultiSet(Services.Core.PurchasePrompt, {
			Enabled = false,
		})

		return "Prompts", "Hiding purchase prompts"
	end,
})

Command.Add({
	Aliases = { "getplayer" },
	Description = "Receives players (for testing)",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local Targets = GetPlayer(Input)
		return Format("Got %s players", #Targets), Input
	end,
})

Command.Add({
	Aliases = { "hitbox", "hb" },
	Description = "Adjust the hitbox size for your target(s)",
	Arguments = {
		{ Name = "Target", Type = "Player" },
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Input, Amount)
		Add("Hitbox", true)
		repeat
			Wait()
			for Index, Target in next, GetPlayer(Input) do
				local TRoot = GetRoot(Target)
				local S = (Amount and SetNumber(Amount, 5)) or 10

				if TRoot and Target ~= LocalPlayer then
					TRoot.Size = Vector3.new(S, S, S)
					TRoot.Transparency = 0.8
					TRoot.CanCollide = false
				end
			end
		until not Get("Hitbox")
	end,
})

Command.Add({
	Aliases = { "unhitbox", "unhb" },
	Description = "Disables the Hitbox command",
	Arguments = {},
	Task = function()
		Refresh("Hitbox", false)

		for Index, Target in next, GetPlayer("all") do
			local TRoot = GetRoot(Target)

			if TRoot then
				TRoot.Size = Vector3.new(2, 2, 1)
				TRoot.Transparency = 1
			end
		end
	end,
})

Command.Add({
	Aliases = { "rejoin", "rj" },
	Description = "Rejoins the server",
	Arguments = {},
	Task = function()
		Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
	end,
})

Command.Add({
	Aliases = { "infinitejump", "infjump" },
	Description = "Allows you to jump in air",
	Arguments = {},
	Task = function()
		local Old = Get("InfiniteJump")
		Old = Old and Old:Disconnect()
		Add(
			"InfiniteJump",
			Connect(Services.Input.InputBegan, function(Key, FocusedTextbox)
				if (Key.KeyCode == Enum.KeyCode.Space) and not FocusedTextbox then
					Humanoid:ChangeState("Jumping")
					Wait()
					Humanoid:ChangeState("Seated")
				end
			end)
		)

		return "Infinite Jump", "Enabled"
	end,
})

Command.Add({
	Aliases = { "uninfinitejump", "uninfjump" },
	Description = "Disables the InfiniteJump command",
	Arguments = {},
	Task = function()
		local Old = Get("InfiniteJump")
		Old = Old and Old:Disconnect()
		return "Infinite Jump", "Disabled"
	end,
})

Command.Add({
	Aliases = { "serverfreeze", "freezewalk" },
	Description = "Freezes your character in the server, but not on your client, allowing to kill enemies without them seeing you",
	Arguments = {},
	Task = function()
		local Root = GetRoot(LocalPlayer)
		local Character = GetCharacter(LocalPlayer)

		if GetHumanoid(LocalPlayer).RigType == Enum.HumanoidRigType.R6 then
			local Clone = Clone(Root);
			Destroy(Root);
			Clone.Parent = Character
		else
			Character.LowerTorso.Anchored = true
			Destroy(Character.LowerTorso.Root);
		end

		return "Freeze Walk", "Enabled"
	end,
})

Command.Add({
	Aliases = { "massplay" },
	Description = "Plays every radio in your inventory",
	Arguments = {
		{ Name = "Audio ID", Type = "String" },
	},
	Task = function(ID)
		for Index, Boombox in next, GetClasses(Backpack, "Tool", true) do
			local Name = Lower(Boombox.Name)
			if (Name == "radio" or Name == "boombox") and (Boombox:FindFirstChild("Remote")) then
				Boombox.Parent = Character
				Boombox.Remote:FireServer("PlaySong", ID)
			end
		end

		return "Mass Play", Format("Mass playing ID: %s", ID)
	end,
})

Command.Add({
	Aliases = { "getaudio", "ga" },
	Description = "Gets the Audio ID of the song playing in your target's boombox",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Target)
		for Index, Boombox in next, GetClasses(GetPlayer(Target)[1].Character, "Tool", true) do
			local Name = Lower(Boombox.Name)
			if (Name == "radio" or Name == "boombox") and (Boombox:FindFirstChild("Handle")) then
				local AudioID = Boombox.Handle:FindFirstChildOfClass("Sound").SoundId
				return "Audio Logged", AudioID, 20
			end
		end

		return "Audio Logger", "Audio not found"
	end,
})

Command.Add({
	Aliases = { "mute" },
	Description = "Mutes the audio on your target's boombox (serversided)",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		if RespectFilteringEnabled then
			return "Mute", "Couldn't mute since RespectFilteringEnabled is enabled"
		end

		for Index, Target in next, GetPlayer(Input) do
			local Character = GetCharacter(Target)

			if Character then
				for Index, Sound in next, GetClasses(Character, "Sound") do
					Sound.Playing = false
				end
			end
		end

		return "Mute", "Successfully muted the target(s)"
	end,
})

Command.Add({
	Aliases = { "glitch" },
	Description = "Glitches your target's boombox (serversided)",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		Add("Glitch", true)
		if RespectFilteringEnabled then
			return "Glitch", "Couldn't glitch since RespectFilteringEnabled is enabled"
		end

		repeat
			Wait()
			for Index, Target in next, GetPlayer(Input) do
				local Character = GetCharacter(Target)

				if Character then
					for Index, Sound in next, GetClasses(Character, "Sound") do
						Sound.Playing = true
						Wait(0.2)
						Sound.Playing = false
					end
				end
			end
		until not Get("Glitch")
	end,
})

Command.Add({
	Aliases = { "unglitch" },
	Description = "Disables the glitch command",
	Arguments = {},
	Task = function()
		Refresh("Glitch", false)
		return "Glitch", "Glitch has been disabled"
	end,
})

Command.Add({
	Aliases = { "noaudio" },
	Description = "Mutes the game audio",
	Arguments = {},
	Task = function()
		for Index, Audio in next, GetClasses(game, "Sound") do
			Audio.Playing = false
		end
		return "No Audio", "Muted the game"
	end,
})

Command.Add({
	Aliases = { "audio" },
	Description = "Unmutes the game audio",
	Arguments = {},
	Task = function()
		for Index, Audio in next, GetClasses(game, "Sound") do
			Audio.Playing = true
		end
		return "Audio", "Unmuted the game"
	end,
})

Command.Add({
	Aliases = { "checkrfe", "crfe" },
	Description = "Checks if RespectFilteringEnabled is enabled, helpful on commands that require it like mute and glitch",
	Arguments = {},
	Task = function()
		return "RFE", Format("RFE is set to %s", tostring(RespectFilteringEnabled))
	end,
})

Command.Add({
	Aliases = { "clientbring", "cbring" },
	Description = "Brings your target to you (clientsided)",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		Add("ClientBring", true)

		repeat
			Wait()
			for Index, Target in next, GetPlayer(Input) do
				local TRoot = GetRoot(Target)

				if TRoot then
					TRoot.CFrame = Root.CFrame * CFrame.new(0, 0, (Distance and -SetNumber(Distance)) or -3)
				end
			end
		until not Get("ClientBring")
	end,
})

Command.Add({
	Aliases = { "unclientbring", "uncbring" },
	Description = "Disables the ClientBring command",
	Arguments = {},
	Task = function()
		Refresh("ClientBring", false)
	end,
})

Command.Add({
	Aliases = { "controllock", "ctrllock", "ctl" },
	Description = "Changes the Shift Lock keybinds to use the Control keys",
	Arguments = {},
	Task = function()
		local Bound = LocalPlayer.PlayerScripts.PlayerModule.CameraModule.MouseLockController.BoundKeys
		Bound.Value = "LeftControl, RightControl"
		return "Control Lock", "Set the shiftlock keybind to Control"
	end,
})

Command.Add({
	Aliases = { "goto", "to" },
	Description = "Teleports you to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		Root.CFrame = GetRoot(GetPlayer(Input)[1]).CFrame
	end,
})

Command.Add({
	Aliases = { "tickgoto", "tgoto", "tto" },
	Description = "Teleports you to your target for a specific amount of time",
	Arguments = {
		{ Name = "Target", Type = "Player" },
		{ Name = "Seconds", Type = "Number" },
	},
	Task = function(Input, Time)
		local OldPosition = Root.CFrame
		Root.CFrame = GetRoot(GetPlayer(Input)[1]).CFrame
		Wait(SetNumber(Time))
		Root.CFrame = OldPosition
	end,
})

Command.Add({
	Aliases = { "scare" },
	Description = "Teleports you to the target for a second",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local OldPosition = Root.CFrame
		Root.CFrame = GetRoot(GetPlayer(Input)[1]).CFrame
		Wait(1)
		Root.CFrame = OldPosition
	end,
})

Command.Add({
	Aliases = { "vehiclegoto", "vgoto", "vto" },
	Description = "Teleports your vehicle to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		Humanoid.SeatPart:FindFirstAncestorOfClass("Model"):PivotTo(GetRoot(GetPlayer(Input)[1]).CFrame)
	end,
})

Command.Add({
	Aliases = { "vehiclespeed", "vspeed", "vsp" },
	Description = "Adjust your car's speed",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		local n = SetNumber(Amount)

		VehicleSpeed = (VehicleSpeed and VehicleSpeed:Disconnect())
		VehicleSpeed = Connect(Services.Run.Stepped, function()
			local SeatPart = Humanoid.SeatPart

			if SeatPart then
				SeatPart:ApplyImpulse(SeatPart.CFrame.LookVector * Vector3.new(n, n, n))
			end
		end)
	end,
})

Command.Add({
	Aliases = { "unvehiclespeed", "unvspeed", "unvsp" },
	Description = "Disables the VehicleSpeed command",
	Arguments = {},
	Task = function()
		VehicleSpeed = (VehicleSpeed and VehicleSpeed:Disconnect())
	end,
})

Command.Add({
	Aliases = { "seat" },
	Description = "Makes you sit in a Normal seat",
	Arguments = {},
	Task = function()
		for Index, Seat in next, GetClasses(workspace, "Seat") do
			Seat:Sit(Humanoid)
			break
		end
	end,
})

Command.Add({
	Aliases = { "vehicleseat", "vseat" },
	Description = "Makes you sit in a Vehicle Seat",
	Arguments = {},
	Task = function()
		for Index, Seat in next, GetClasses(workspace, "VehicleSeat") do
			Seat:Sit(Humanoid)
			break
		end
	end,
})

Command.Add({
	Aliases = { "admin", "whitelist", "wl" },
	Description = "Allows your target to use Cmd's commands (using chat)",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		for Index, Admin in next, GetPlayer(Input) do
			Command.Whitelist(Admin)
			Chat(
				Format(
					'/w %s You are now whitelisted to COCOS POV ADMIn, prefix is "%s"',
					Admin.Name,
					Settings.ChatPrefix
				)
			)
		end
	end,
})

Command.Add({
	Aliases = { "unadmin", "unwhitelist", "unwl" },
	Description = "Removes your target's whitelist",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		for Index, Admin in next, GetPlayer(Input) do
			if Admins[Admin.UserId] then
				Command.RemoveWhitelist(Admin)
				Chat(Format("/w %s You are no longer an admin!", Admin.Name))
			end
		end
	end,
})

Command.Add({
	Aliases = { "follow", "flw" },
	Description = "Automatically follows your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		Refresh("Follow", true)

		repeat
			Wait()
			Humanoid:MoveTo(GetRoot(GetPlayer(Input)[1]).Position)
		until not Get("Follow")
	end,
})

Command.Add({
	Aliases = { "unfollow", "unflw" },
	Description = "Disables the Follow command",
	Arguments = {},
	Task = function()
		Refresh("Follow", false)
	end,
})

Command.Add({
	Aliases = { "clicktp", "ctp" },
	Description = "Click to teleport to your mouse position",
	Arguments = {},
	Task = function()
		Refresh("ClickTP", true)
		Connect(Mouse.Button1Down, function()
			if Get("ClickTP") then
				Root.CFrame = Mouse.Hit * CFrame.new(0, 3, 0)
			end
		end)
		return "Click TP", "Click TP has been enabled"
	end,
})

Command.Add({
	Aliases = { "unclicktp", "unctp" },
	Description = "Disables the ClickTp command",
	Arguments = {},
	Task = function()
		Refresh("ClickTP", false)
		return "Click TP", "Click TP has been disabled"
	end,
})

Command.Add({
	Aliases = { "stare" },
	Description = "Makes your character stare at your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local Target = GetPlayer(Input)[1]
		Refresh("Stare", true)

		repeat
			Wait()
			local TRoot = GetRoot(Target).Position
			Root.CFrame = CFrame.new(Root.Position, Vector3.new(TRoot.X, Root.Position.y, TRoot.Z))
		until not Get("Stare")
	end,
})

Command.Add({
	Aliases = { "unstare" },
	Description = "Disables the Stare command",
	Arguments = {},
	Task = function()
		Refresh("Stare", false)
	end,
})

Command.Add({
	Aliases = { "lay" },
	Description = "Makes you lay",
	Arguments = {},
	Task = function()
		Humanoid.Sit = true
		Root.CFrame = Root.CFrame * CFrame.Angles(1.5, 0, 0)
		Wait(0.1)
		for Index, Track in next, Humanoid:GetPlayingAnimationTracks() do
			Track:Stop()
		end
	end,
})

Command.Add({
	Aliases = { "autorejoin", "autorj", "arj" },
	Description = "Automatically rejoins if you get KICKED",
	Arguments = {},
	Task = function()
		Add("AutoRejoin", true)
		Connect(GetService("GuiService").ErrorMessageChanged, function()
			if Get("AutoRejoin") then
				Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId)
			end
		end)
		return "Auto Rejoin", "Auto Rejoin enabled"
	end,
})

Command.Add({
	Aliases = { "unautorejoin", "unautorj", "unarj" },
	Description = "Disables the AutoRejoin command",
	Arguments = {},
	Task = function()
		Add("AutoRejoin", false)
		return "Auto Rejoin", "Auto Rejoin disabled"
	end,
})

Command.Add({
	Aliases = { "friend" },
	Description = "Sends a connection (NOT friend anymore) request to your target(s)",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local Sent = 0
		for Index, Target in next, GetPlayer(Input) do
			if Target ~= LocalPlayer then
				LocalPlayer:RequestFriendship(Target)
				Sent += 1
			end
		end
		return "Friend", Format("Sent friend request to %s player(s)", Sent)
	end,
})

Command.Add({
	Aliases = { "listen", "spy" },
	Description = "Listens to your target(s) voice chat conversation from any distance",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local Targets = GetPlayer(Input)
		local Roots = {}

		for Index, Target in next, Targets do
			Roots[#Roots + 1] = GetRoot(Target);
		end

		Services.Sound:SetListener(Enum.ListenerType.ObjectPosition, Unpack(Roots))
		return "Listen", Format("Listening to %s player(s)", #Roots)
	end,
})

Command.Add({
	Aliases = { "view", "spectate" },
	Description = "Views your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local Target = GetPlayer(Input)[1]
		Refresh("View", true)

		repeat
			Wait()
			Camera.CameraSubject = GetHumanoid(Target)
		until not Get("View")
	end,
})

Command.Add({
	Aliases = { "unview", "unspectate" },
	Description = "Disables the view command",
	Arguments = {},
	Task = function()
		Refresh("View", false)
		Camera.CameraSubject = Humanoid
	end,
})

Command.Add({
	Aliases = { "freecam", "fc" },
	Description = "Enables and Disables Freecam",
	Arguments = {},
	Task = function()
		if not Freecam then
			Freecam = {}
			local pi = math.pi
			local abs = math.abs
			local clamp = math.clamp
			local exp = math.exp
			local rad = math.rad
			local sign = math.sign
			local sqrt = math.sqrt
			local tan = math.tan

			Connect(Changed(workspace, "CurrentCamera"), function()
				local newCamera = workspace.CurrentCamera
				if newCamera then
					Camera = newCamera
				end
			end)

			local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
			local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
			local FREECAM_MACRO_KB = { Enum.KeyCode.LeftShift, Enum.KeyCode.P }

			local NAV_GAIN = Vector3.new(1, 1, 1) * 64
			local PAN_GAIN = Vector2.new(0.75, 1) * 8
			local FOV_GAIN = 300

			local PITCH_LIMIT = rad(90)

			local VEL_STIFFNESS = 10
			local PAN_STIFFNESS = 10
			local FOV_STIFFNESS = 10

			local Spring = {}
			do
				Spring.__index = Spring

				function Spring.new(freq, pos)
					local self = setmetatable({}, Spring)
					self.f = freq
					self.p = pos
					self.v = pos * 0
					return self
				end

				function Spring:Update(dt, goal)
					local f = self.f * 2 * pi
					local p0 = self.p
					local v0 = self.v

					local offset = goal - p0
					local decay = exp(-f * dt)

					local p1 = goal + (v0 * dt - offset * (f * dt + 1)) * decay
					local v1 = (f * dt * (offset * f - v0) + v0) * decay

					self.p = p1
					self.v = v1

					return p1
				end

				function Spring:Reset(pos)
					self.p = pos
					self.v = pos * 0
				end
			end

			local cameraPos = Vector3.new()
			local cameraRot = Vector2.new()
			local cameraFov = 0

			local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
			local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
			local fovSpring = Spring.new(FOV_STIFFNESS, 0)

			local Input = {}
			do
				local thumbstickCurve
				do
					local K_CURVATURE = 2.0
					local K_DEADZONE = 0.15

					local function fCurve(x)
						return (exp(K_CURVATURE * x) - 1) / (exp(K_CURVATURE) - 1)
					end

					local function fDeadzone(x)
						return fCurve((x - K_DEADZONE) / (1 - K_DEADZONE))
					end

					function thumbstickCurve(x)
						return sign(x) * clamp(fDeadzone(abs(x)), 0, 1)
					end
				end

				local gamepad = {
					ButtonX = 0,
					ButtonY = 0,
					DPadDown = 0,
					DPadUp = 0,
					ButtonL2 = 0,
					ButtonR2 = 0,
					Thumbstick1 = Vector2.new(),
					Thumbstick2 = Vector2.new(),
				}

				local keyboard = {
					W = 0,
					A = 0,
					S = 0,
					D = 0,
					E = 0,
					Q = 0,
					U = 0,
					H = 0,
					J = 0,
					K = 0,
					I = 0,
					Y = 0,
					Up = 0,
					Down = 0,
					LeftShift = 0,
					RightShift = 0,
				}

				local mouse = {
					Delta = Vector2.new(),
					MouseWheel = 0,
				}

				local NAV_GAMEPAD_SPEED = Vector3.new(1, 1, 1)
				local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
				local PAN_MOUSE_SPEED = Vector2.new(1, 1) * (pi / 64)
				local PAN_GAMEPAD_SPEED = Vector2.new(1, 1) * (pi / 8)
				local FOV_WHEEL_SPEED = 1.0
				local FOV_GAMEPAD_SPEED = 0.25
				local NAV_ADJ_SPEED = 0.75
				local NAV_SHIFT_MUL = 0.25

				local navSpeed = 1

				function Input.Vel(dt)
					navSpeed = clamp(navSpeed + dt * (keyboard.Up - keyboard.Down) * NAV_ADJ_SPEED, 0.01, 4)

					local kGamepad = Vector3.new(
						thumbstickCurve(gamepad.Thumbstick1.X),
						thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
						thumbstickCurve(-gamepad.Thumbstick1.Y)
					) * NAV_GAMEPAD_SPEED

					local kKeyboard = Vector3.new(
						keyboard.D - keyboard.A + keyboard.K - keyboard.H,
						keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
						keyboard.S - keyboard.W + keyboard.J - keyboard.U
					) * NAV_KEYBOARD_SPEED

					local shift = Services.Input:IsKeyDown(Enum.KeyCode.LeftShift)
						or Services.Input:IsKeyDown(Enum.KeyCode.RightShift)

					return (kGamepad + kKeyboard) * (navSpeed * (shift and NAV_SHIFT_MUL or 1))
				end

				function Input.Pan(dt)
					local kGamepad = Vector2.new(
						thumbstickCurve(gamepad.Thumbstick2.Y),
						thumbstickCurve(-gamepad.Thumbstick2.X)
					) * PAN_GAMEPAD_SPEED
					local kMouse = mouse.Delta * PAN_MOUSE_SPEED
					mouse.Delta = Vector2.new()
					return kGamepad + kMouse
				end

				function Input.Fov(dt)
					local kGamepad = (gamepad.ButtonX - gamepad.ButtonY) * FOV_GAMEPAD_SPEED
					local kMouse = mouse.MouseWheel * FOV_WHEEL_SPEED
					mouse.MouseWheel = 0
					return kGamepad + kMouse
				end

				do
					local function Keypress(action, state, input)
						keyboard[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
						return Enum.ContextActionResult.Sink
					end

					local function GpButton(action, state, input)
						gamepad[input.KeyCode.Name] = state == Enum.UserInputState.Begin and 1 or 0
						return Enum.ContextActionResult.Sink
					end

					local function MousePan(action, state, input)
						local delta = input.Delta
						mouse.Delta = Vector2.new(-delta.y, -delta.x)
						return Enum.ContextActionResult.Sink
					end

					local function Thumb(action, state, input)
						gamepad[input.KeyCode.Name] = input.Position
						return Enum.ContextActionResult.Sink
					end

					local function Trigger(action, state, input)
						gamepad[input.KeyCode.Name] = input.Position.z
						return Enum.ContextActionResult.Sink
					end

					local function MouseWheel(action, state, input)
						mouse[input.UserInputType.Name] = -input.Position.z
						return Enum.ContextActionResult.Sink
					end

					local function Zero(t)
						for k, v in pairs(t) do
							t[k] = v * 0
						end
					end

					function Input.StartCapture()
						Services.ContextActionService:BindActionAtPriority(
							"FreecamKeyboard",
							Keypress,
							false,
							INPUT_PRIORITY,
							Enum.KeyCode.W,
							Enum.KeyCode.U,
							Enum.KeyCode.A,
							Enum.KeyCode.H,
							Enum.KeyCode.S,
							Enum.KeyCode.J,
							Enum.KeyCode.D,
							Enum.KeyCode.K,
							Enum.KeyCode.E,
							Enum.KeyCode.I,
							Enum.KeyCode.Q,
							Enum.KeyCode.Y,
							Enum.KeyCode.Up,
							Enum.KeyCode.Down
						)
						Services.ContextActionService:BindActionAtPriority(
							"FreecamMousePan",
							MousePan,
							false,
							INPUT_PRIORITY,
							Enum.UserInputType.MouseMovement
						)
						Services.ContextActionService:BindActionAtPriority(
							"FreecamMouseWheel",
							MouseWheel,
							false,
							INPUT_PRIORITY,
							Enum.UserInputType.MouseWheel
						)
						Services.ContextActionService:BindActionAtPriority(
							"FreecamGamepadButton",
							GpButton,
							false,
							INPUT_PRIORITY,
							Enum.KeyCode.ButtonX,
							Enum.KeyCode.ButtonY
						)
						Services.ContextActionService:BindActionAtPriority(
							"FreecamGamepadTrigger",
							Trigger,
							false,
							INPUT_PRIORITY,
							Enum.KeyCode.ButtonR2,
							Enum.KeyCode.ButtonL2
						)
						Services.ContextActionService:BindActionAtPriority(
							"FreecamGamepadThumbstick",
							Thumb,
							false,
							INPUT_PRIORITY,
							Enum.KeyCode.Thumbstick1,
							Enum.KeyCode.Thumbstick2
						)
					end

					function Input.StopCapture()
						navSpeed = 1
						Zero(gamepad)
						Zero(keyboard)
						Zero(mouse)
						Services.ContextActionService:UnbindAction("FreecamKeyboard")
						Services.ContextActionService:UnbindAction("FreecamMousePan")
						Services.ContextActionService:UnbindAction("FreecamMouseWheel")
						Services.ContextActionService:UnbindAction("FreecamGamepadButton")
						Services.ContextActionService:UnbindAction("FreecamGamepadTrigger")
						Services.ContextActionService:UnbindAction("FreecamGamepadThumbstick")
					end
				end
			end

			local function GetFocusDistance(cameraFrame)
				local znear = 0.1
				local viewport = Camera.ViewportSize
				local projy = 2 * tan(cameraFov / 2)
				local projx = viewport.x / viewport.y * projy
				local fx = cameraFrame.rightVector
				local fy = cameraFrame.upVector
				local fz = cameraFrame.lookVector

				local minVect = Vector3.new()
				local minDist = 512

				for x = 0, 1, 0.5 do
					for y = 0, 1, 0.5 do
						local cx = (x - 0.5) * projx
						local cy = (y - 0.5) * projy
						local offset = fx * cx - fy * cy + fz
						local origin = cameraFrame.p + offset * znear
						local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit * minDist))
						local dist = (hit - origin).magnitude
						if minDist > dist then
							minDist = dist
							minVect = offset.unit
						end
					end
				end

				return fz:Dot(minVect) * minDist
			end

			local function StepFreecam(dt)
				local vel = velSpring:Update(dt, Input.Vel(dt))
				local pan = panSpring:Update(dt, Input.Pan(dt))
				local fov = fovSpring:Update(dt, Input.Fov(dt))

				local zoomFactor = sqrt(tan(rad(70 / 2)) / tan(rad(cameraFov / 2)))

				cameraFov = clamp(cameraFov + fov * FOV_GAIN * (dt / zoomFactor), 1, 120)
				cameraRot = cameraRot + pan * PAN_GAIN * (dt / zoomFactor)
				cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y % (2 * pi))

				local cameraCFrame = CFrame.new(cameraPos)
					* CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)
					* CFrame.new(vel * NAV_GAIN * dt)
				cameraPos = cameraCFrame.p

				Camera.CFrame = cameraCFrame
				Camera.Focus = cameraCFrame * CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
				Camera.FieldOfView = cameraFov
			end

			local PlayerState = {}
			do
				local mouseBehavior
				local mouseIconEnabled
				local cameraType
				local cameraFocus
				local cameraCFrame
				local cameraFieldOfView
				local screenGuis = {}
				local coreGuis = {
					Backpack = true,
					Chat = true,
					Health = true,
					PlayerList = true,
				}
				local setCores = {
					BadgesNotificationsActive = true,
					PointsNotificationsActive = true,
				}

				function PlayerState.Push()
					cameraFieldOfView = Camera.FieldOfView
					Camera.FieldOfView = 70

					cameraType = Camera.CameraType
					Camera.CameraType = Enum.CameraType.Custom

					cameraCFrame = Camera.CFrame
					cameraFocus = Camera.Focus

					mouseIconEnabled = Services.Input.MouseIconEnabled
					Services.Input.MouseIconEnabled = true

					mouseBehavior = Services.Input.MouseBehavior
					Services.Input.MouseBehavior = Enum.MouseBehavior.Default
				end

				function PlayerState.Pop()
					for name, isEnabled in pairs(coreGuis) do
						Services.Starter:SetCoreGuiEnabled(Enum.CoreGuiType[name], isEnabled)
					end
					for name, isEnabled in pairs(setCores) do
						Services.Starter:SetCore(name, isEnabled)
					end
					for _, gui in pairs(screenGuis) do
						if gui.Parent then
							gui.Enabled = true
						end
					end

					Camera.FieldOfView = cameraFieldOfView
					cameraFieldOfView = nil

					Camera.CameraType = cameraType
					cameraType = nil

					Camera.CFrame = cameraCFrame
					cameraCFrame = nil

					Camera.Focus = cameraFocus
					cameraFocus = nil

					Services.Input.MouseIconEnabled = mouseIconEnabled
					mouseIconEnabled = nil

					Services.Input.MouseBehavior = mouseBehavior
					mouseBehavior = nil
				end
			end

			local function StartFreecam(Position)
				local cameraCFrame = Position or Camera.CFrame
				cameraRot = Vector2.new(cameraCFrame:toEulerAnglesYXZ())
				cameraPos = cameraCFrame.p
				cameraFov = Camera.FieldOfView

				velSpring:Reset(Vector3.new())
				panSpring:Reset(Vector2.new())
				fovSpring:Reset(0)

				PlayerState.Push()
				Services.Run:BindToRenderStep("Freecam", Enum.RenderPriority.Camera.Value, StepFreecam)
				Input.StartCapture()
			end

			local function StopFreecam()
				Input.StopCapture()
				Services.Run:UnbindFromRenderStep("Freecam")
				PlayerState.Pop()
			end

			function Freecam:EnableFreecam(Position)
				if FreecamEnabled then -- check mostly for freecamto
					StopFreecam()
				end

				FreecamEnabled = true
				StartFreecam(Position)
			end

			function Freecam:StopFreecam()
				FreecamEnabled = false
				StopFreecam()
			end
		end

		if FreecamEnabled then
			Freecam:StopFreecam()
			return "Freecam", "Disabled"
		else
			Freecam:EnableFreecam()
			return "Freecam", "Enabled"
		end
	end,
})

Command.Add({
	Aliases = { "freecamto", "fcto" },
	Description = "Brings your FreeCam to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Target)
		Freecam:EnableFreecam(GetRoot(GetPlayer(Target)[1]).CFrame)
	end,
})

Command.Add({
	Aliases = { "freecambring", "fcbr" },
	Description = "Brings your character to the FreeCam camera position",
	Arguments = {},
	Task = function()
		Root.CFrame = Camera.CFrame
	end,
})

Command.Add({
	Aliases = { "walkfling", "wf" },
	Description = "Fling without spinning (less obvious)",
	Arguments = {
		{ Name = "Distance", Type = "Number" },
	},
	Task = function(Distance)
		Refresh("Walkfling", true)
		Spawn(function()
			local NormalVelocity = Root.Velocity
			local Velocity = Root.Velocity

			repeat
				Wait()
				if
					GetPlayer("closest")[1]:DistanceFromCharacter(Root.Position)
					<= (Distance and SetNumber(Distance, 0, 9e9) or 10)
				then
					Velocity = Root.Velocity
					Root.Velocity = (Velocity * 10000) + Vector3.new(0, 10000, 0)
					CWait(Services.Run.RenderStepped)
					Root.Velocity = Velocity
				end
			until not Get("Walkfling")
		end)
		return "Walk Fling", "Walk Fling has been enabled"
	end,
})

Command.Add({
	Aliases = { "unwalkfling", "unwf" },
	Description = "Disables the WalkFling command",
	Arguments = {},
	Task = function()
		Refresh("Walkfling", false)
		return "Walk Fling", "Walk Fling has been disabled"
	end,
})

Command.Add({
	Aliases = { "resetfilter", "ref" },
	Description = "Resets the chat filter if Roblox keeps tagging your messages",
	Arguments = {},
	Task = function()
		for Index = 1, 3 do
			Services.Players:Chat(Format("!clear"))
		end
		return "Filter", "Reset"
	end,
})

Command.Add({
	Aliases = { "split" },
	Description = "Splits your message and resets the filter",
	Arguments = {
		{ Name = "First Split", Type = "String" },
		{ Name = "Second Split", Type = "String" },
	},
	Task = function(First, Second)
		if First and Second then
			Command.Parse(true, "ref")
			Wait(0.2)
			Chat(First)
			Command.Parse(true, "ref")
			Wait(0.5)
			Chat(Second)
		else
			return "Split", "One or more arguments are missing"
		end
	end,
})

Command.Add({
	Aliases = { "toolfling", "toolf" },
	Description = "Flings players using tools in your inventory",
	Arguments = {},
	Task = function()
		local Tools = LocalPlayer.Backpack:GetChildren()

		if #Tools > 0 then
			local SelectedTool = Tools[math.random(1, #Tools)]

			SelectedTool.Parent = Character
			SelectedTool.GripPos = Vector3.new(0, -10000, 0)
			SelectedTool.Handle.Massless = true
		else
			return "Tool Fling", "No tool found"
		end

		return "Tool Fling", "Do not unequip the tool"
	end,
})

Command.Add({
	Aliases = { "fling" },
	Description = "Flings your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		local Targets = GetPlayer(Input)

		if #Targets == 0 then
			return "Fling", "No targets found"
		end

		local Successes = Fling(Targets)
		return "Fling", Format("Successfully flinged (%s/%s) player(s)", Successes or 0, #Targets)
	end,
})

Command.Add({
	Aliases = { "loopfling", "lf" },
	Description = "Repeatedly flings your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Task = function(Input)
		Refresh("Fling", true)
		repeat
			Fling(GetPlayer(Input))
		until not Get("Fling")
	end,
})

Command.Add({
	Aliases = { "unloopfling", "unlf" },
	Description = "Disables the LoopFling command",
	Arguments = {},
	Task = function()
		Add("Fling", false)
	end,
})

Command.Add({
	Aliases = { "clickfling", "cf" },
	Description = "Flings the target you click on",
	Arguments = {},
	Task = function()
		local Connection = Get("Clickfling")
		Connection = (Connection and Connection:Disconnect())
		Add(
			"Clickfling",
			Connect(Mouse.Button1Down, function()
				local Target = Mouse.Target
				local Model = Target:FindFirstAncestorOfClass("Model")
				local isPlayer = Services.Players:GetPlayerFromCharacter(Model)

				if isPlayer then
					Fling({ isPlayer })
				end
			end)
		)
		return "Clickfling", "Enabled"
	end,
})

Command.Add({
	Aliases = { "unclickfling", "uncf" },
	Description = "Disables the ClickFling command",
	Arguments = {},
	Task = function()
		local Connection = Get("Clickfling")
		Connection = (Connection and Connection:Disconnect())
		return "Clickfling", "Disabled"
	end,
})

-- :: SETUP :: --
if Check("File") then
	local LoadedPlugins = 0
	for Index, Folder in next, { "Cmd", "Cmd/Logs", "Cmd/Plugins" } do
		if not isfolder(Folder) then
			makefolder(Folder)
		end
	end

	Cmd().Build = {
		GetCharacter = GetCharacter,
		GetHumanoid = GetHumanoid,
		GetRoot = GetRoot,
		Chat = Chat,
		Library = Library,
		GetPlayer = GetPlayer,

		GlobalAdd = Add,
		GlobalGet = Get,
		GlobalRefresh = Refresh,

		Notify = function(Config)
			return API:Notify(Config)
		end,
	}

	for Index, File in next, listfiles("Cmd/Plugins") do
		local Success, Plugin = pcall(function()
			LoadedPlugins += 1
			return loadfile(File)()
		end)

		if Success then
			do
				for Index, PluginCommand in next, Plugin.Commands do
					Command.Add({
						Aliases = PluginCommand.Aliases or { "couldnt-get-aliases" },
						Description = PluginCommand.Description or "No description",
						Arguments = PluginCommand.Arguments or {},
						Plugin = true,
						Task = PluginCommand.Callback or function()
							return "plugin command", "this plugin does not have a callback."
						end,
					})
				end

				API:Notify({
					Title = Plugin.Name,
					Description = Plugin.Description,
					Duration = 5,
					Type = "Info",
				})
			end
		else
			API:Notify({
				Title = File,
				Description = Plugin,
				Duration = 15,
				Type = "Warn",
			})
		end
	end
end

--// Autofill & Recommendation
for Index, Command in next, Commands do
	Fill.Add(Command)
end

Connect(Changed(Input, "Text"), function()
	Fill.Search(Input.Text)
	Fill.Recommend(Input.Text)
end)

Connect(Services.Input.InputBegan, function(Key)
	if
		Key.KeyCode == Enum.KeyCode.Tab
		and Press.Title.Text == "Tab"
		and Services.Input:GetFocusedTextBox() == Input
	then
		local Text = Recommend.Text
		Wait()
		Input.Text = Text
		Input.CursorPosition = #Text + 1
	end
end)

--// Command Bar
local ChatDebounce = false
local OpenCommandBar = function()
	local Transparency = Settings.Theme.Transparency
	local Padding = CommandBar.Parent:FindFirstChildOfClass("UIPadding")
	Wait()

	Input:CaptureFocus()
	BarShadow.Transparency = 1
	Padding.PaddingTop = UDim.new(0, -5)

	MultiSet(CommandBar, {
		GroupTransparency = 1,
		Visible = true,
		Position = UDim2.new(0.5, 0, 0.5, -9),
	})

	Tween(BarShadow, 0.2, { Transparency = 0.9 })
	Tween(Padding, 0.2, { PaddingTop = UDim.new(0, 0) })
	Tween(CommandBar, 0.2, {
		GroupTransparency = (Transparency == 0) and 0.07 or Settings.Theme.Transparency,
	}, { EasingDirection = Enum.EasingDirection.In, EasingStyle = Enum.EasingStyle.Linear })
end

ConnectMessaged(LocalPlayer, function(Message)
	if not ChatDebounce and Find(Message, Settings.ChatPrefix) then
		ChatDebounce = true
		Command.Parse(false, Split(Message, Settings.ChatPrefix)[2])
		Wait()
		ChatDebounce = false
	end
end)

Connect(Mouse.KeyDown, function(Key)
	if Lower(Key) == Lower(Settings.Prefix) then
		OpenCommandBar()
	end
end)

Connect(Input.FocusLost, function()
	local Padding = CommandBar.Parent:FindFirstChildOfClass("UIPadding")

	Command.Parse(false, Input.Text)
	Tween(BarShadow, 0.2, { Transparency = 1 })
	Tween(Padding, 0.2, { PaddingTop = UDim.new(0, 5) })
	Tween(CommandBar, 0.2, {
		GroupTransparency = 1,
	}, { EasingDirection = Enum.EasingDirection.In, EasingStyle = Enum.EasingStyle.Linear })

	Wait(0.2)
	CommandBar.Visible = false
end)

do
	local Interface = Cmd().UI
	local API = Cmd().API

	if Check("File") and not isfile("Cmd/Settings.json") then
		SaveSettings()
	end

	Settings = GetSavedSettings()

	if Settings.Toggles.Developer then
		if Interface then
			Interface.Parent = nil
		end
	else
		if Interface and API then
			UI.Parent = nil
			API:Notify({
				Title = "Already loaded",
				Description = "If you would like to reload Cmd rejoin or enable Developer mode!",
				Duration = 5,
				Type = "Error",
			})

			return
		end
	end

	SetTheme()
end

Spawn(function()
	-- making opening button work
	Animate.Drag(Button, true)
	Connect(Button.MouseButton1Click, OpenCommandBar)

	-- loading internal ui
	if Settings.Toggles.InternalUI then
		loadstring(GetModule("internal-ui.lua"))()
	end

	-- remove other admin prompts
	if Settings.Toggles.RemoveCommandBars then
		Delay(2, function()
            for _, UI in next, PlayerGui:GetChildren() do
                if
                    UI.Name == "KCoreUI"
                    or UI.Name == "HDAdminGuis"
                    or UI.Name == "Essentials Client"
                    or UI.Name == "Cmdr"
                then
                    Destroy(UI);
                end
            end
        end)
	end

	-- staff notifier
	Connect(Services.Players.PlayerAdded, function(Player)
		local StaffMember, Role = IsStaff(Player)
		if StaffMember and Settings.Toggles.StaffNotifier then
			API:Notify({
				Title = "Staff Member has joined",
				Description = Format("Name: %s (@%s)\nRole: <b>%s</b>", Player.DisplayName, Player.Name, Role),
				Duration = 10,
				Type = "Warn",
			})
		end
	end)

	local Staff = {}
	local ToSearch = Services.Players:GetPlayers()
	local Searched = 0

	for Index, Player in next, ToSearch do
		Spawn(function() -- since getroleingroup is slow we adding a spawn to make it faster
			if Player ~= LocalPlayer and IsStaff(Player) and UI.Parent and Settings.Toggles.StaffNotifier then
				Insert(Staff, Player.Name)
			end
			Searched += 1
		end)
	end

	repeat
		Wait()
	until Searched == #ToSearch

	if #Staff > 0 then
		API:Notify({
			Title = "Staff Detected!",
			Description = Format(
				"We have found <b>%s</b> staff member(s) in your game! (%s)",
				tostring(#Staff),
				Concat(Staff, " , ")
			),
			Duration = 20,
			Type = "Warn",
		})
	end

	if not Drawing then
		Drawing = loadstring(GetModule("drawing.lua"))()
	end
end)

Cmd().UI = UI
Cmd().API = API

Spawn(function()
	if not Character then
		repeat
			Wait()
		until Character and Humanoid
	end

	local OldHealth = (Humanoid and Humanoid.Health)

	Feature:ConnectEvent("PlayerRemoved")
	Feature:ConnectEvent("AutoExecute")
	Feature:ConnectEvent("Chatted", LocalPlayer.Chatted)
	Feature:ConnectEvent("CharacterAdded", LocalPlayer.CharacterAdded)
	Feature:ConnectEvent("Died", nil, true)
	Feature:ConnectEvent("Damaged", nil, true, function(Humanoid)
		if (not OldHealth) or (Humanoid.Health <= OldHealth) then
			return true
		end

		OldHealth = Humanoid.Health
	end)
end)

API:Notify({
	Title = "Welcome",
	Description = Format(
		"Loaded in %.2f seconds (Version %s)\nChat Prefix: %s",
		tick() - Speed,
		Settings.Version,
		Settings.ChatPrefix
	),
	Duration = 15,
	Type = "Info",
})

if Methods.Check() then
	API:Notify({
		Title = "Possible game vulnerability found!",
		Description = "This game has a possible vulnerability where you can delete Instances, run the command <b>;vuln</b> and test if it works!",
		Duration = 15,
		Type = "Warning",
	})

	Command.Add({
		Aliases = { "vuln" },
		Description = "Exploit the game's POTENTIAL vulnerabilities",
		Arguments = {},
		Task = function()
			local Tab = Library.Tabs["Vulnerability"]

			if Tab then
				Tab.Open()
			else
				local Window = Library:CreateWindow({
					Title = "Vulnerability",
				})

				Window:AddSection({ Title = "Player", Tab = "Home" })

				Window:AddInput({
					Title = "Kill",
					Description = "Kill your target",
					Tab = "Home",
					Callback = function(Input)
						local Players = GetPlayer(Input)

						for _, Player in next, Players do
							local Character = GetCharacter(Player)

							if Character then
								Methods.Destroy(Character:FindFirstChild("Head"))
							end
						end
					end,
				})

				Window:AddInput({
					Title = "Sink",
					Description = "Sinks your target to the ground",
					Tab = "Home",
					Callback = function(Input)
						local Players = GetPlayer(Input)

						for _, Player in next, Players do
							local Root = GetRoot(Player)

							if Root then
								Methods.Destroy(Root)
							end
						end
					end,
				})

				Window:AddInput({
					Title = "Bald",
					Description = "Makes your taget bald",
					Tab = "Home",
					Callback = function(Input)
						local Players = GetPlayer(Input)

						for _, Player in next, Players do
							local Character = GetCharacter(Player)

							if Character then
								for _, Accessory in next, GetClasses(Character, "Accessory") do
									Methods.Destroy(Accessory)
								end
							end
						end
					end,
				})

				Window:AddInput({
					Title = "Fat",
					Description = "Makes your target blocky (R6 Only)",
					Tab = "Home",
					Callback = function(Input)
						local Players = GetPlayer(Input)

						for _, Player in next, Players do
							local Character = GetCharacter(Player)

							if Character then
								for _, Accessory in next, GetClasses(Character, "CharacterMesh") do
									Methods.Destroy(Accessory)
								end
							end
						end
					end,
				})

				Window:AddInput({
					Title = "Naked",
					Description = "uhh",
					Tab = "Home",
					Callback = function(Input)
						local Players = GetPlayer(Input)
						local Classes = { "Shirt", "Pants", "ShirtGraphics" }

						for _, Player in next, Players do
							local Character = GetCharacter(Player)

							if Character then
								for _, Class in next, Classes do
									for _, Accessory in next, GetClasses(Character, Class) do
										Methods.Destroy(Accessory)
									end
								end
							end
						end
					end,
				})

				Window:AddInput({
					Title = "Punish",
					Description = "Punishes the player's character",
					Tab = "Home",
					Callback = function(Input)
						local Players = GetPlayer(Input)

						for _, Player in next, Players do
							local Character = GetCharacter(Player)

							if Character then
								Methods.Destroy(Character)
							end
						end
					end,
				})
				
				Window:AddSection({ Title = "Game", Tab = "Home" })

				Window:AddButton({
					Title = "Clear Map",
					Description = "Removes Workspace",
					Tab = "Home",
					Callback = function()
						for _, Object in next, workspace:GetChildren() do
							Methods.Destroy(Object)
						end
					end,
				})

				Window:AddButton({
					Title = "Break Game",
					Description = "Breaks the game's scripts",
					Tab = "Home",
					Callback = function()
						for _, Object in next, GetClasses(game, "Script") do
							Methods.Destroy(Object)
						end
					end,
				})

				Window:AddButton({
					Title = "Building Tools",
					Description = "Breaks specific parts",
					Tab = "Home",
					Callback = function()
						local DestroyTool = Create("Tool", {
							Parent = Backpack,
							RequiresHandle = false,
							Name = "Delete",
							ToolTip = "Btools (Delete)",
							TextureId = "https://www.roblox.com/asset/?id=12223874",
							CanBeDropped = false,
						})

						local BtoolsEquipped = false
						Connect(DestroyTool.Equipped, function()
							BtoolsEquipped = true
						end)

						Connect(DestroyTool.Unequipped, function()
							BtoolsEquipped = false
						end)

						Connect(DestroyTool.Activated, function()
							local Explosion = Create("Explosion", {
								Parent = workspace,
								BlastPressure = 0,
								BlastRadius = 0,
								DestroyJointRadiusPercent = 0,
								ExplosionType = Enum.ExplosionType.NoCraters,
								Position = Mouse.Target.Position,
							})

							Methods.Destroy(Mouse.Target)
						end)
					end,
				})
			end
		end,
	})
end
