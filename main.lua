--[[ 
	hi so since roblox is now terming exploiters i decided to stop n release this
	here are some freatures (i couldnt add everything i wanted mb since most execs are garbage)

	[+] added | [/] changed | [-] removed 

	>> added+
	features
	[+] staff notifier (toggleable) - notifies whenever a moderator is in your game
	[+] new system - slider
	[+] custom uis
	[+] internal ui (toggleable)
	[+] more toggles - (internal ui, fling seated, autofill cap, developer mode, )

	commands
	[+] search - search scripts using scriptblox api
	[+] loopdroptools - drops ur tools resets and repeat
	[+] highlight - highlight classnames & instances with the name you input
	[+] resetfilter / ref - resets the chat filter if roblox keeps tagging your messages
	[+] split - split your message into two and uses reset filter to say it

	>> changed/
	[/] new ui (commandbar, windows, notifications, popups)
	[/] recoded the library and half the commands (not all commands lmao)
	[/] esp now uses drawing library instead of roblox's highlight, and has a box and text toggle
	[/] aimbot options - first person, third person, mouse
	[/] all features like waypoints and keybinds are in the settings window
	[/] in the command bar recommendation it will show you the argument name now instead of having to look at the icons to see the type of the argument (much better to understand the arguments needed)
	[/] servers now should work on solara since it uses a proxy roblox api instead of the actual one, as well you can select the player count of the server you want to join
	[/] most of the command names (aliases) have been renamed so i recommend looking at the commands to see the new ones
	[/] a new & faster fling method 
	[/] completely new plugin system, that provides built-in cmd functions & variables
	[/] binds now dont need to be held instead just press the key to enable and disable 

	>> removed
	[-] bang & unbang (haha)
]]

if (not game:IsLoaded()) then
	game.Loaded:Wait();
end

local Cmd = (getgenv) 
	or function() return _G end

local Speed = tick()
local Admins = {}

local Settings = {
	Prefix	 = (";");
	ChatPrefix = ("!");
	Seperator = (",");
	Version = ("Beta 1.0");

	CustomUI = (Cmd().CustomUI) or "rbxassetid://18617417654",

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
		Icon = Color3.fromRGB(255, 255, 255)
	},

	Toggles = {
		FillCap = true,
		Developer = false,
		Notify = true,
		Popups = true,
		Interfere = true,
		Recommendation = true,
		InternalUI = false,
		StaffNotifier = true,
		IgnoreSeated = true,
	},
}

local Connect = (game.Loaded.Connect);
local CWait = (game.Loaded.Wait);
local Clone = (game.Clone);
local Destroy = (game.Destroy);
local Changed = (game.GetPropertyChangedSignal);
local GetService = (function(Property)
	local Service = (game.GetService);
	local Reference = (cloneref) 
		or function(reference) return reference end

	return Reference( Service(game, Property) );
end)

local Services = ({
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
	Sound = GetService("SoundService")
}); 

local Methods = ({
	Get = function(URL) 
		local Method = (game.HttpGet)
		return Method(game, URL);
	end,

	Parent = function(Child) 
		xpcall(function() 
			Child.Parent = (gethui and gethui()) or Services.Core
		end, function() 
			Child.Parent = Services.Players.LocalPlayer["PlayerGui"];
		end)
	end,
}); 

local Check = (function(Type) 
	if Type == "File" then
		return (isfile and isfolder and writefile and readfile)
	elseif Type == "Hook" then
		return (hookmetamethod or hookfunction);
	end
end);

local LocalPlayer = Services.Players.LocalPlayer
local Character = LocalPlayer.Character
local Backpack = LocalPlayer.Backpack
local Humanoid = (Character and Character:FindFirstChildOfClass("Humanoid"))
local Root = (Character and Character:FindFirstChild("HumanoidRootPart"))

Connect(LocalPlayer.CharacterAdded, function(Char) 
	Character = (Char);
	Humanoid = Character:WaitForChild("Humanoid");
	Root = (Character:FindFirstChild("HumanoidRootPart"));

	Backpack = (LocalPlayer.Backpack);
end)

local Lower, Split, Sub, GSub, Find, Match, Format, Blank = 
	string.lower, string.split, string.sub, string.gsub, string.find, string.match, string.format, "", ""

local Unpack, Insert, Discover, Concat, FullArgs = 
	table.unpack, table.insert, table.find, table.concat, {}

local Spawn, Delay, Wait = 
	task.spawn, task.delay, task.wait 

local JSONEncode, JSONDecode, GenerateGUID = 
	Services.Http.JSONEncode, Services.Http.JSONDecode, Services.Http.GenerateGUID

local Mouse, PlayerGui = 
	LocalPlayer:GetMouse(), LocalPlayer.PlayerGui

local Camera = workspace.CurrentCamera
local RespectFilteringEnabled = Services.Sound.RespectFilteringEnabled 
local LegacyChat = (Services.Chat.ChatVersion == Enum.ChatVersion.LegacyChatService)

local GetModule = function(Name) 
	return (Methods.Get(Format("https://raw.githubusercontent.com/lxte/modules/main/cmd/%s", Name)))
end

-- another check in case humanoid not found lmao
if (not Character) or (not Humanoid) or (not Root) then 
	Spawn(function() 
		Character = (Character or CWait(LocalPlayer.CharacterAdded))
		Humanoid = Character:FindFirstChildOfClass("Humanoid");
		Root = Character:FindFirstChild("HumanoidRootPart");
	end)
end

-- :: INSERT[UI] ::
local UI = (Services.Run:IsStudio() and script.Parent) or Services.Insert:LoadLocalAsset(Settings.CustomUI);

local Assets = UI.Assets 
local Notification = UI.Frame 
local CommandBar = UI.Cmd.CommandBar 
local Tab = UI.Tab 

local Components = Assets.Components
local Features = Assets.Features 

local Autofill = CommandBar.Autofill
local Search = CommandBar.Search 
local BarShadow = CommandBar.Shadow 

local Input = Search.TextBox 
local Recommend = Search.Recommend 
local Press = Search.Press

local Protected = {} 

if Check("Hook") then 
	xpcall(function() 
		--// untested since no free exec has hooking lol hopefully doesnt break...
		for Index, Descendant in next, UI:GetDescendants() do 
			Protected[Descendant] = ("RobloxGui");
		end

		Connect(UI.DescendantAdded, function(Descendant) 
			Protected[Descendant] = ("RobloxGui");
		end)

		local Original
		local isCaller = checkcaller or function() 
			return true
		end

		Original = hookmetamethod(game, "__tostring", function(self) 
			if self and Protected[self] and not isCaller() then 
				return Protected[self]
			end 
			return Original
		end)	

	end, function(Result)
		if Settings.Toggles.Developer then 
			warn(Format("Error occured setting gui protection (%s)", Result))
		end
	end)
end
Methods.Parent(UI);
UI.Name = (GenerateGUID(Services.Http));
Tab.Name = (GenerateGUID(Services.Http));

-- :: FUNCTIONS :: --
local UDimMultiply = function(UDim, Amount) 
	local Values = {
		UDim.X.Scale * Amount;
		UDim.X.Offset * Amount;
		UDim.Y.Scale * Amount;
		UDim.Y.Offset * Amount;
	}

	return UDim2.new(Unpack(Values))
end

local Minimum = function(Table, Minimum)
	local New = {}
	if Table then
		for i,v in next, Table do
			if i == Minimum or i > Minimum then
				Insert(New, v);
			end
		end
	end
	return New
end

local Chat = function(Message)
	if LegacyChat then
		Services.Replicated.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Message, "All");
	else
		Services.Chat.TextChannels.RBXGeneral:SendAsync(Message);
	end
end

local Foreach = function(Table, Func, Loop)
	for Index, Value in next, Table do
		pcall(function()
			if Loop and typeof(Value) == 'table' then
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
		Object[Index] = (Property);
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

local SetSRadius = setsimulationradius or function(Radius, MaxRadius) 
	Spawn(function() 
		LocalPlayer.SimulationRadius = Radius
		LocalPlayer.MaxSimulationDistance = MaxRadius
	end)
end

local AttachName = GenerateGUID(Services.Http);
local Attach = function(Part, Target) 
	if (Part and Part:IsA("BasePart") and not Part.Anchored) then 
		local ModelDescendant = Part:FindFirstAncestorOfClass("Model") 
		SetSRadius(9e9, 9e9)

		if ModelDescendant then 
			if Services.Players:GetPlayerFromCharacter(ModelDescendant) then 
				return
			end
		end

		local Attachment = Instance.new("Attachment");
		local Position = Instance.new("AlignPosition");
		local Orientation = Instance.new("AlignOrientation");
		local Attachment2 = Instance.new("Attachment");

		Attachment.Name = (AttachName);
		Position.Name = (AttachName);
		Orientation.Name = (AttachName);
		Attachment2.Name = (AttachName);

		Attachment.Parent = Part;
		Position.Parent = Part;
		Orientation.Parent = Part;
		Attachment2.Parent = (Target or Root);

		Position.Responsiveness = (200);
		Orientation.Responsiveness = (200);

		Position.MaxForce = (9e9);
		Orientation.MaxTorque = (9e9);

		Position.Attachment0 = Attachment
		Position.Attachment1 = Attachment2
		Orientation.Attachment1 = Attachment2
		Orientation.Attachment0 = Attachment

		return Attachment, Position, Orientation, Attachment2
	end
end

local IsStaff = function(Player)
	local StaffRoles = { "owner", "admin", "staff", "mod", "founder", "manager", "dev", "president", "leader" , "supervisor", "chairman", "supervising" };
	local CurrentRole = Player:GetRoleInGroup(game.CreatorId);

	for Index, Role in next, StaffRoles do 
		if Lower(CurrentRole):find(Role) then
			return true, CurrentRole 
		end 
	end
end

local Tween = function(Object, Speed, Properties,  Info)
	local Info = Info or {}
	local Style, Direction = 
		(Info["EasingStyle"]) or Enum.EasingStyle.Sine,
	(Info["EasingDirection"]) or Enum.EasingDirection.Out

	return Services.Tween:Create(Object, TweenInfo.new(Speed, Style, Direction), Properties):Play()
end

local SetRig = function(Type)
	local Avatar = GetService("AvatarEditorService")
	Avatar:PromptSaveAvatar(Humanoid.HumanoidDescription, Enum.HumanoidRigType[Type])
	CWait(Avatar.PromptSaveAvatarCompleted)
	Command.Parse(true, "respawn")
end

local GetClasses = function(Ancestor, Class, GetChildren)
	local Results = {};

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
		local Numbered = tonumber(Input);

		if Numbered and ((Numbered == (Minimum or Max) or (Numbered < Max) or (Numbered > Minimum))) then
			return Numbered;
		elseif Lower(Input) == "inf" then
			return Max;
		else 
			return 0;
		end
	else
		return 0;
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

PArguments = {
	["all"] = function() 
		return (Services.Players:GetPlayers());
	end,

	["others"] = function()
		local Targets = {}
		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if (Player ~= LocalPlayer) then
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
			if (Model:FindFirstChildOfClass("Humanoid") and 
				not Services.Players:GetPlayerFromCharacter(Model))  then
				Insert(Targets, Model)
			end
		end
		return Targets
	end, 

	["seated"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local PHumanoid = GetHumanoid(Player)
			if (PHumanoid and PHumanoid.Sit) then
				Insert(Targets, Player)
			end
		end
		return Targets
	end, 

	["stood"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do
			local PHumanoid = GetHumanoid(Player)
			if (PHumanoid and not PHumanoid.Sit) then
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
				FurthestDistance = (Distance)
				FurthestPlayer = (Player)
			end
		end
		return { FurthestPlayer }
	end,

	["enemies"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do 
			if (Player.Team ~= LocalPlayer.Team) then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,

	["dead"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do 
			local PHumanoid = GetHumanoid(Player);
			if (PHumanoid and PHumanoid.Health == 0) then
				Insert(Targets, Player)
			end
		end
		return Targets
	end,


	["alive"] = function()
		local Targets = {}
		for Index, Player in next, GetClasses(Services.Players, "Player") do 
			local PHumanoid = GetHumanoid(Player);
			if (PHumanoid and PHumanoid.Health > 0) then
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
	local Target = Lower(Target);
	local PlayerType = PArguments[Target];

	if PlayerType then
		return PlayerType();
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

local Fling = function(Targets) 
	local S, Result = pcall(function() 
		local Flung = (0)

		local Position = Root.CFrame
		local Velocity = Root.Velocity
		local DestroyHeight = workspace.FallenPartsDestroyHeight

		for Index, Target in next, (Targets) do 
			local TCharacter = GetCharacter(Target);
			local THumanoid = GetHumanoid(Target);
			local TRoot = GetRoot(Target);

			if (THumanoid) and (TRoot) and (Root) and (THumanoid.Health > 0) and (Target ~= LocalPlayer) then 
				if not (Settings.Toggles.IngoreSeated and THumanoid.Sit) then
					local Timer = tick()
					local AlreadyFlung = (TRoot and TRoot.Velocity.Magnitude > 200)

					Camera.CameraSubject = (THumanoid);
					workspace.FallenPartsDestroyHeight = (-math.huge);

					repeat Wait();
						local Offset = TRoot.Velocity * Random.new():NextNumber(-0.2, 2.5)
						Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
						Root.Velocity = Vector3.new(0, 1e6, 0)
						Root.CFrame = CFrame.new(TRoot.Position + Offset)
					until (not TCharacter) or (not Root) or (Settings.Toggles.IgnoreSeated and THumanoid.Sit) or (TRoot.Velocity.Magnitude > 200) or (THumanoid.Health <= 0) or (tick() - Timer >= 2)
					if (not AlreadyFlung) and (TRoot and TRoot.Velocity.Magnitude > 200) then 
						Flung += 1
					end
				end
			end
		end

		repeat 
			local Old = Position * CFrame.new(0, 1, 0);
			Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
			Camera.CameraSubject = (Humanoid)
			Root.CFrame = (Old)
			Character:SetPrimaryPartCFrame(Old)

			for Index, BodyPart in next, GetClasses(Character, "BasePart", true) do 
				BodyPart.Velocity = Vector3.new(0, 0, 0)
				BodyPart.RotVelocity = Vector3.new(0, 0, 0)
			end

			CWait(Services.Run.Heartbeat);
		until not Root or (Root.Position - Position.p).Magnitude < 20
		workspace.FallenPartsDestroyHeight = DestroyHeight
		return Flung
	end)
	return Result
end

local SetFly
local ThumbstickMoved

Spawn(function()
	local BodyGyro = Instance.new("BodyGyro")
	BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 10 ^ 6
	BodyGyro.P = 10 ^ 6

	local BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.maxForce = Vector3.new(1, 1, 1) * 10 ^ 6
	BodyVelocity.P = 10 ^ 4

	local Flying = false
	local Movement = { forward = 0, backward = 0, right = 0, left = 0 }

	local function SetFlying(Bool)
		Flying = Bool

		BodyGyro.Parent = (Flying and Root) or nil
		BodyVelocity.Parent = (Flying and Root) or nil
		BodyVelocity.Velocity = Vector3.new()

		if (Flying) then
			BodyGyro.CFrame = Root.CFrame
		end
	end

	local FlySpeed = 3

	local function ModifyMovement(newMovement)
		Movement = newMovement or Movement
		if (Flying) then
			local isMoving = Movement.right + Movement.left + Movement.forward + Movement.backward > 0
		end
	end

	local function MovementBind(actionName, InputState, inputObject)
		if (InputState == Enum.UserInputState.Begin) then
			Movement[actionName] = 1

			ModifyMovement()
		elseif (InputState == Enum.UserInputState.End) then
			Movement[actionName] = 0

			ModifyMovement()
		end

		return Enum.ContextActionResult.Pass
	end

	Services.ContextActionService:BindAction("forward", MovementBind, false, Enum.PlayerActions.CharacterForward)
	Services.ContextActionService:BindAction("backward", MovementBind, false, Enum.PlayerActions.CharacterBackward)
	Services.ContextActionService:BindAction("left", MovementBind, false, Enum.PlayerActions.CharacterLeft)
	Services.ContextActionService:BindAction("right", MovementBind, false, Enum.PlayerActions.CharacterRight)

	local TouchFrame
	if PlayerGui:FindFirstChild("TouchGui") then
		TouchFrame = PlayerGui.TouchGui:FindFirstChild("TouchControlFrame")
	end

	local DeadZone = 0.15
	local DeadZoneNormalized = 1 - DeadZone

	local isTouchOnThumbstick = function(Position)
		if not TouchFrame then
			return false
		end
		local ClassicFrame = TouchFrame:FindFirstChild("ThumbstickFrame")
		local DynamicFrame = TouchFrame:FindFirstChild("DynamicThumbstickFrame")
		local StickFrame = (ClassicFrame and ClassicFrame.Visible) and ClassicFrame or DynamicFrame

		if (StickFrame) then
			local StickPosition = StickFrame.AbsolutePosition
			local StickSize = StickFrame.AbsoluteSize
			return Position.X >= StickPosition.X and Position.X <= (StickPosition.X + StickSize.X) and
				Position.Y >= StickPosition.Y and
				Position.Y <= (StickPosition.Y + StickSize.Y)
		end
		return false
	end

	Connect(Services.Input.TouchStarted, function(touch, gameProcessedEvent)
		ThumbstickMoved = isTouchOnThumbstick(touch.Position)
	end)

	Connect(Services.Input.TouchEnded, function(touch, gameProcessedEvent)
		if ThumbstickMoved then
			ThumbstickMoved = (false);
			ModifyMovement({forward = 0, backward = 0, right = 0, left = 0})
		end
	end)

	Connect(Services.Input.TouchMoved, function(touch, gameProcessedEvent)
		if ThumbstickMoved then
			local MouseVector = (Humanoid.MoveDirection)
			local LeftRight = (MouseVector.X)
			local ForeBack = (MouseVector.Z)

			Movement.left = LeftRight < -DeadZone and -(LeftRight - DeadZone) / DeadZoneNormalized or 0
			Movement.right = LeftRight > DeadZone and (LeftRight - DeadZone) / DeadZoneNormalized or 0

			Movement.forward = ForeBack < -DeadZone and -(ForeBack - DeadZone) / DeadZoneNormalized or 0
			Movement.backward = ForeBack > DeadZone and (ForeBack - DeadZone) / DeadZoneNormalized or 0
			ModifyMovement()
		end
	end)

	local Updated = function(dt)
		if (Flying) then
			local Position = (workspace.CurrentCamera.CFrame);
			local Direction =
				Position.rightVector * (Movement.right - Movement.left) +
				Position.lookVector * (Movement.forward - Movement.backward)

			if (Direction:Dot(Direction) > 0) then
				Direction = (Direction.unit);
			end

			BodyGyro.CFrame = Position
			BodyVelocity.Velocity = Direction * Humanoid.WalkSpeed * FlySpeed
		end

	end

	SetFly = function(Boolean, SpeedValue)
		FlySpeed = SpeedValue or 1
		SetFlying(Boolean)
		Connect(Services.Run.RenderStepped, Updated)
	end
end)

Tab.Visible = false
CommandBar.Actions.Description.Text = Settings.Version
CommandBar.Visible = false
CommandBar.GroupTransparency = 1

-- :: LIBRARY[UI] :: -- 
local Type
local API     = {};
local Library = { Tabs = {} };
local Fill    = {};
local Globals  = {};
local Feature = {}

local Add = function(Global, Value) 
	Globals[Global] = Value
end

local Get = function(Global) 
	return Globals[Global]
end

local Refresh = function(Global, NewValue) 
	Add(Global, false);
	Wait(.2);
	Add(Global, NewValue);
end

local Animate = {
	Set = function(Component, Title, Description)
		local Labels = (Component.Frame);
		local TLabel, DLabel = (Labels.Title), (Labels.Description);

		if Title then
			TLabel.Text = Title 
		else
			Destroy(TLabel);
		end

		if Description then
			DLabel.Text = Description 
		else
			Destroy(DLabel);
		end
	end,

	Open = function(Window, Transparency, Size, CheckVisible, Center, Amount)
		if (CheckVisible and not Window.Visible) or not CheckVisible then
			local Size = (Size or Window.Size);
			local NewSize = UDimMultiply(Size, Amount or 1.1);
			local Outline = Window:FindFirstChildOfClass("UIStroke");

			MultiSet(Outline, { Transparency = 1 })
			MultiSet(Window, {
				Size = NewSize,
				GroupTransparency = 1,
				Visible = true,
				Position = (Center and UDim2.fromScale(0.5, 0.5)) or Window.Position
			})

			Tween(Outline, .25, { Transparency = 0.8 })
			Tween(Window, .25, {
				Size = Size,
				GroupTransparency = Transparency or 0,
			})
		end
	end,

	Close = function(Window, Amount, Invisible)
		Spawn(function() 
			local Size = (Window.Size);
			local NewSize = UDimMultiply(Size, Amount or 1.1);
			local Outline = Window:FindFirstChildOfClass("UIStroke");

			Tween(Outline, .25, { Transparency = 1 })
			Tween(Window, .25, {
				Size = NewSize,
				GroupTransparency = 1,
			})

			if Invisible then
				Wait(.25);
				Window.Visible = false
			end
		end)
	end,

	Drag = function(Window)
		if Window then
			local Dragging;
			local DragInput;
			local Start;
			local StartPosition;

			local function Update(input)
				local delta = input.Position - Start
				local Screen = UI.AbsoluteSize
				local Absolute = Window.AbsoluteSize

				Window.Position = UDim2.new(
					StartPosition.X.Scale, 
					math.clamp(StartPosition.X.Offset + delta.X, -(Screen.X / 2) + (Absolute.X / 2), (Screen.X / 2) - (Absolute.X / 2)),
					StartPosition.Y.Scale, 
					math.clamp(StartPosition.Y.Offset + delta.Y, -(Screen.Y / 2) + (Absolute.Y / 2), (Screen.Y / 2) - (Absolute.Y / 2))
				)
			end

			Connect(Window.InputBegan, function(Input)
				if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
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
				if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch and not Type then
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
};

local Color = function(Color, Factor, Mode)
	Mode = Mode or Settings.Theme.Mode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

function Library:CreateWindow(Config: { Title: string }) 
	local Window = Clone(Tab);
	local Animations = {};
	local Component = {};

	local Actions = Window.Actions 
	local Tabs = Window.Tabs
	local Topbar = Window.Topbar

	local TabName = Topbar.Title 
	local WindowName = Topbar.Description 
	local SearchBox = Topbar.SearchBox 

	local Previous = "Home"
	local Current = "Home"

	local Maximized = (false);
	local Minimzied = (false);

	local Minimum, Maximum = Vector2.new(204, 220), Vector2.new(9e9, 9e9)

	local List = { 
		BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
		BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
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
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

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

	WindowName.Text = (Config.Title);
	Window.Parent = (UI);
	Window.Name = (GenerateGUID(Services.Http));

	Library.Tabs[Config.Title] = { Open = function() 
		Animate.Open(Window, Settings.Theme.Transparency, UDim2.fromOffset(345, 418), false, true);
	end,}  

	Library.Tabs[Config.Title].Open()
	Animate.Drag(Window);

	--// Animations 

	function Animations:SetTab(Name)
		TabName.Text = Name
		Current = Name

		for Index, Main in next, Tabs:GetChildren() do
			if Main:IsA("CanvasGroup") then
				local Opened, SameName = Main.Value, (Main.Name == Name);
				local Scroll = Main.ScrollingFrame
				local Padding = Scroll.UIPadding

				if SameName and not Opened.Value then
					Opened.Value = true
					Main.Visible = true

					Tween(Main, .3, { GroupTransparency = 0 });
					Tween(Padding, .3, { PaddingTop = UDim.new(0, 8) });

				elseif not SameName and Opened.Value then
					Previous = Main.Name
					Opened.Value = false

					Tween(Main, .15, { GroupTransparency = 1 });
					Tween(Padding, .15, { PaddingTop = UDim.new(0, 18) });	

					Delay(.2, function()
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
				Tween(Button, .25, { Transparency = 0, Size = UDimMultiply(Size, 1.1) });
			else
				Tween(Button, .25, { BackgroundColor3 = Color(Settings.Theme.Component, 5), Size = UDimMultiply(Size, 1.015) });
			end
		end)

		Connect(Button.InputEnded, function() 
			if Custom then
				Tween(Button, .25, { Transparency = 1, Size = Size });
			else
				Tween(Button, .25, { BackgroundColor3 = Settings.Theme.Component, Size = Size });
			end
		end)
	end

	--// Components
	function Component:Set(Component, Title, Description)
		local Labels = (Component.Frame);
		local TLabel, DLabel = (Labels.Title), (Labels.Description);

		if Title then
			TLabel.Text = Title 
		else
			Destroy(TLabel);
		end

		if Description then
			DLabel.Text = Description 
		else
			Destroy(DLabel);
		end
	end

	function Component:GetTab(Name)
		return Tabs[Name].ScrollingFrame
	end

	function Component:AddTab(Config: { Title: string, Description: string, Tab: string})
		local Button = Clone(Components["Section"]);
		local Tab = Clone(Components["SectionExample"]);

		Connect(Button.MouseButton1Click, function() 
			Animations:SetTab(Config.Title)
		end)

		Animations:Component(Button)
		Component:Set(Button, Config.Title, Config.Description)
		MultiSet(Tab, { Parent = Tabs, Name = Config.Title });		
		MultiSet(Button, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddDropdown(Config: { Title: string, Description: string, Options: {}, Tab: Instance, Callback: any }) 
		local Dropdown = Clone(Components["Dropdown"]);
		local Background = Window.Background
		local Text = Dropdown.Holder.Main.Title;

		Connect(Dropdown.MouseButton1Click, function()
			local Example = Clone(Features.DropdownExample);
			local Buttons = Example.Actions;

			Tween(Background, .25, { BackgroundTransparency = 0.6 });

			Example.Parent = Window
			Animate.Open(Example, 0)

			for Index, Button in next, Buttons:GetChildren() do
				if Button:IsA("TextButton") then
					Animations:Component(Button, true)

					Connect(Button.MouseButton1Click, function()
						Tween(Background, .25, { BackgroundTransparency = 1 });
						Animate.Close(Example);

						Wait(.25);
						Destroy(Example);
					end)
				end
			end

			for Index, Option in next, Config.Options do
				local Button = Clone(Features.DropdownButtonExample);

				Animations:Component(Button);
				Component:Set(Button, Index);
				MultiSet(Button, { Parent = Example.ScrollingFrame, Visible = true });

				Connect(Button.MouseButton1Click, function() 
					Tween(Button, .25, { BackgroundColor3 = Settings.Theme.Component });
					Config.Callback(Option, Dropdown)

					Text.Text = Index

					for Index, Others in next, Example:GetChildren() do
						if Others:IsA("TextButton") and Others ~= Button then
							Others.BackgroundColor3 = Settings.Theme.Component
						end
					end

					Tween(Background, .25, { BackgroundTransparency = 1 });
					Animate.Close(Example);

					Wait(.25);
					Destroy(Example);
				end)
			end
		end)

		Component:Set(Dropdown, Config.Title, Config.Description)
		Animations:Component(Dropdown);

		MultiSet(Dropdown, {
			Name = Config.Title,
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddButton(Config: { Title: string, Description: string, Tab: string, Callback: any })
		local Button = Clone(Components["Button"]);

		Component:Set(Button, Config.Title, Config.Description)
		Animations:Component(Button)

		Connect(Button.MouseButton1Click, function() 
			Config.Callback(Button);
		end)

		MultiSet(Button, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddInput(Config: { Title: string, Description: string, Tab: string, Default: string, Callback: any })
		local Button = Clone(Components["Input"]);
		local Box = Button.Main.TextBox 

		Box.Text = (Config.Default) or Blank
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
		local Section = Clone(Components["TabSection"]);

		Section.Title.Text = Config.Title
		MultiSet(Section, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddParagraph(Config: { Title: string, Description: string, Tab: string })
		local Paragraph = Clone(Components["Paragraph"]);

		Component:Set(Paragraph, Config.Title, Config.Description)

		MultiSet(Paragraph, {
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	function Component:AddKeybind(Config: { Title: string, Description: string, Tab: string, Callback: any })
		local Dropdown = Clone(Components["Keybind"]);
		local Bind = Dropdown.Holder.Main.Title;

		local Mouse = { Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2, Enum.UserInputType.MouseButton3 }; 
		local Types = { 
			["Mouse"] = "Enum.UserInputType.MouseButton", 
			["Key"] = "Enum.KeyCode." 
		}

		Animations:Component(Dropdown);
		Component:Set(Dropdown, Config.Title, Config.Description)

		Connect(Dropdown.MouseButton1Click, function()
			local Time = tick();
			local Detect, Finished

			MultiSet(Bind, { Text = "..." });
			Detect = Connect(Services.Input.InputBegan, function(Key, Focused) 
				local InputType = (Key.UserInputType);

				if not Finished and not Focused then
					Finished = (true)
					Config.Callback(Key)

					if table.find(Mouse, InputType) then
						MultiSet(Bind, {
							Text = tostring(InputType):gsub(Types.Mouse, "MB")
						})
					elseif InputType == Enum.UserInputType.Keyboard then
						MultiSet(Bind, {
							Text = tostring(Key.KeyCode):gsub(Types.Key, Blank)
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

	function Component:AddToggle(Config: { Title: string, Description: string, Tab: string, Default: boolean, Callback: any })
		local Toggle = Clone(Components["Toggle"]);

		local On = Toggle["Value"];
		local Main = Toggle["Main"];
		local Circle = Main["ToggleLabel"];

		local Set = function(Value)
			if Value then
				Tween(Main,   .2, { BackgroundColor3 = Settings.Theme.Highlight });
				Tween(Circle, .2, { ImageColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(1, -16, 0.5, 0) });
			else
				Tween(Main,   .2, { BackgroundColor3 = Color(Settings.Theme.Component, 10) });
				Tween(Circle, .2, { ImageColor3 = Color(Settings.Theme.Component, 15), Position = UDim2.new(0, 4, 0.5, 0) });
			end

			On.Value = Value
		end 

		Set(Config.Default);
		Animations:Component(Toggle);
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

	function Component:AddSlider(Config: { Title: string, Description: string, Tab: string, MaxValue: number, AllowDecimals: boolean, DecimalAmount: number, Callback: any })
		local Slider = Clone(Components["Slider"]);

		local Main = Slider["Slider"];
		local Amount = Main["Main"].Input;
		local Slide = Main["Slide"];
		local Fire = Slide["Fire"];
		local Fill = Slide["Highlight"];
		local Circle = Fill["Circle"];

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

			repeat task.wait()
				Update()
			until not Active
		end

		Fill.Size = UDim2.fromScale(Value, 1);
		Animations:Component(Slider);
		Component:Set(Slider, Config.Title, Config.Description)

		Connect(Amount.FocusLost, function() 
			Update(tonumber(Amount.Text) or 0)
		end)

		Connect(Fire.MouseButton1Down, Activate)
		Connect(Services.Input.InputEnded, function(Input) 
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Active = false
			end
		end)

		MultiSet(Slider, {
			Name = Config.Title,
			Parent = Tabs[Config.Tab].ScrollingFrame,
			Visible = true,
		})
	end

	Animations:Component(Topbar.Back, true);
	Animations:Component(Topbar.Search, true);
	for Index, Button in next, Actions:GetChildren() do
		local Type = (Button.Name);

		if Button:IsA("TextButton") then			
			Animations:Component(Button, true); 

			Connect(Button.MouseButton1Click, function() 
				if Type == "Close" then
					Animate.Close(Window);
					Wait(.25);
					Window.Visible = (false);
				elseif Type == "Minimize" then
					Minimzied = not Minimzied

					if Minimzied then
						Tween(Window, .25, { Size = UDim2.fromOffset(345, 60) })
					else
						Tween(Window, .25, { Size = UDim2.fromOffset(345, 394) })
					end
				elseif Type == "Maximize" then
					Maximized = not Maximized

					if Maximized then
						Tween(Window, .15, { Size = UDim2.fromScale(1, 1), Position = UDim2.fromScale(0.5, 0.5) })
					else
						Tween(Window, .15, { Size = UDim2.fromOffset(345, 394), Position = UDim2.fromScale(0.5, 0.5) })
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
		local Speed = Speed or .1

		Tween(TabName, Speed, { TextTransparency = Transparency });
		Tween(WindowName, Speed, { TextTransparency = Transparency });
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
		SearchEnabled = (true);
		SearchBox.Visible = (false);
		TweenTexts(true, .3);
	end)

	Connect(Topbar.Search.MouseButton1Click, function() 
		SearchEnabled = not SearchEnabled 

		SearchBox.Visible = (not SearchEnabled)
		TweenTexts(SearchEnabled)

		if (not SearchEnabled) then
			SearchBox:CaptureFocus();
		end
	end)

	return Component
end

function API:Notify(Config: { Title: string, Description: string, Duration: number, Type: string }) 
	Spawn(function() 
		local Info = TweenInfo.new(.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local SetShadow = function(Box, Boolean) 
			Tween(Box.Shadow, .8, { 
				Transparency = (Boolean and 0.8) or 1
			})
		end

		if Settings.Toggles.Notify then
			local Notification = Clone(Features.Notification);
			local Box = Notification.CanvasGroup 

			local Timer = Box["Timer"]
			local Interact = Box["Interact"]
			local None = (Enum.AutomaticSize.None)

			local Methods = {
				["warn"] = { icon = "rbxassetid://18797417802", color = Color3.fromRGB(246, 233, 107) },
				["info"] = { icon = "rbxassetid://18754976792", color = Color3.fromRGB(110, 158, 246)},
				["success"] = { icon = "rbxassetid://18797434345", color = Color3.fromRGB(126, 246, 108)},
				["error"] = { icon = "rbxassetid://18797440055", color = Color3.fromRGB(246, 109, 104)},
			}; local Information = (Methods[Lower(Config.Type or "info")] or Methods["info"])
			local Opposite = (Settings.Theme.Mode == "Dark" and "Light") or "Dark"

			Timer.BackgroundColor3 = (Information.color);
			Timer.Outline.Color = Color(Information.color, 25, Opposite);

			Notification.Parent = UI.Frame
			Animate.Set(Box, Config.Title, Config.Description);	
			MultiSet(Box, {
				AutomaticSize = (None);
				Size = UDim2.fromOffset(100, 10);
				Visible = (true);
				GroupTransparency = (1);
			})

			local Duration = (tonumber(Config.Duration) or 5);
			local Closed = (false);

			-- very sorry for the ugly code
			local Open, Close = function() 
				SetShadow(Box, true)
				Tween(Notification, .4, { Size = UDim2.fromOffset(199, 80) }); Wait(.1)
				Services.Tween:Create(Box, Info, {
					Size = UDim2.fromOffset(229, 80);
					GroupTransparency = (Settings.Theme.Transparency);
				}):Play(); Wait(.3);
				Box.AutomaticSize = Enum.AutomaticSize.Y 
			end, function() 
				if (not Closed) then
					Closed = (true)

					SetShadow(Box, false);
					Tween(Box, .3, { GroupTransparency = 1 }); Notification.AutomaticSize = (None)
					Tween(Notification, .35, { Size = UDim2.fromOffset(199, 0) });
					Tween(Notification.UIPadding, .3, { PaddingLeft = UDim.new(0, 600) }); Wait(.35)
					Destroy(Notification)
				end
			end

			Connect(Interact.MouseButton1Click, Close); Open();
			Tween(Timer, Duration, { Size = UDim2.fromOffset(0, 2) })
			Wait(Duration); Close()
		end
	end)
end

local Output = function(...) 
	if Settings.Toggles.Developer then
		warn(...);
	end
end

local Themes = {
	Names = {	
		["Topbar"] = function(Label)
			if Label:IsA("Frame") then
				Label.BackgroundColor3 = (Settings.Theme.Secondary);
			end
		end,

		["Actions"] = function(Label)
			if Label:IsA("Frame") then
				Label.BackgroundColor3 = (Settings.Theme.Actions);

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
						Label.BackgroundColor3 = Color(Settings.Theme.Component, 10);
					else 
						Label.BackgroundColor3 = (Settings.Theme.Highlight);
					end
				else
					Label.BackgroundColor3 = Color(Settings.Theme.Component, 10);
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
					Component.BackgroundColor3 = (Settings.Theme.Component)
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
				Label.BackgroundColor3 = (Settings.Theme.Secondary)
			end
		end,

		["SearchBox"] = function(Label) 
			if Label:IsA("TextBox") then
				Label.PlaceholderColor3 = (Settings.Theme.Description);
				Label.TextColor3 = (Settings.Theme.Title);
			end
		end,

		--// Tables
		["Title"]		    = { "TextLabel", "Title", "TextColor3" };
		["Description"]    = { "TextLabel", "Description", "TextColor3" };
		["Line"] 	    	    = { "Frame", "Highlight", "BackgroundColor3" };
		["AutofillButton"] = { "TextButton", "Secondary", "BackgroundColor3" };
		["UIStroke"] 	    = { "UIStroke", "Outline", "Color" };
		["Shadow"] 	    = { "UIStroke", "Shadow", "Color" };
		["Highlight"] 	    = { "Frame", "Highlight", "BackgroundColor3" };
		["Circle"] 	    = { "Frame", "Highlight", "BackgroundColor3" };
		["Notification"]   = { "CanvasGroup", "Primary", "BackgroundColor3", true };
		["DropdownExample"]= { "CanvasGroup", "Primary", "BackgroundColor3" };

	},

	Classes = {
		["TextBox"] = function(Label) 
			if Label.Name ~= "Recommend" then
				Label.TextColor3 = (Settings.Theme.Title);
			else 
				Label.TextColor3 = (Settings.Theme.Description);
			end
		end,

		["CanvasGroup"] = function(Label) 
			if Label.Parent == UI then
				Label.BackgroundColor3 = (Settings.Theme.Primary);
				Label.GroupTransparency = (Settings.Theme.Transparency)
			end
		end,

		["ImageLabel"] = function(Label) 
			if Label.Image ~= "rbxassetid://6644618143" then
				Label.ImageColor3 = (Settings.Theme.Icon);
			end
		end,

		["ScrollingFrame"] = function(Label) 
			Label.ScrollBarImageColor3 = (Settings.Theme.ScrollBar);
		end,
	},
}

local DefaultThemes = {
	["Dark"] 	  = {Mode = "Dark"; Transparency = 0; Primary = Color3.fromRGB(25, 25, 25), Secondary = Color3.fromRGB(30, 30, 30), Actions = Color3.fromRGB(30, 33, 52), Component = Color3.fromRGB(30, 30, 30), Highlight = Color3.fromRGB(86, 159, 204), ScrollBar = Color3.fromRGB(39, 39, 39), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(155, 155, 155), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(52, 52, 52), Icon = Color3.fromRGB(255, 255, 255)},
	["Dracula"]   = {Mode = "Dark"; Transparency = 0; Primary = Color3.fromRGB(40, 42, 54), Secondary = Color3.fromRGB(46, 48, 62), Actions = Color3.fromRGB(58, 61, 77), Component = Color3.fromRGB(43, 45, 59), Highlight = Color3.fromRGB(98, 114, 164), ScrollBar = Color3.fromRGB(23, 24, 31), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(155, 155, 155), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(51, 54, 68), Icon = Color3.fromRGB(255, 255, 255)},
	["Light"] 	  = {Mode = "Light"; Transparency = 0; Primary = Color3.fromRGB(255, 255, 255), Secondary = Color3.fromRGB(245, 245, 245), Actions = Color3.fromRGB(225, 232, 238), Component = Color3.fromRGB(245, 245, 245), Highlight = Color3.fromRGB(153, 155, 255), ScrollBar = Color3.fromRGB(150, 150, 150), Title = Color3.fromRGB(40, 40, 40), Description = Color3.fromRGB(155, 155, 155), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(230, 230, 230), Icon = Color3.fromRGB(40, 40, 40)},
	["Nord"] 	  = {Mode = "Dark", Transparency = 0, Primary = Color3.fromRGB(41, 47, 56), Secondary = Color3.fromRGB(46, 52, 64), Actions = Color3.fromRGB(107, 135, 156), Component = Color3.fromRGB(46, 52, 64), Highlight = Color3.fromRGB(136, 192, 208), ScrollBar = Color3.fromRGB(51, 59, 70), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(200, 200, 200), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(59, 66, 82), Icon = Color3.fromRGB(255, 255, 255)},
	["Void"] 	  = {Mode = "Dark"; Transparency = 0; Primary = Color3.fromRGB(15, 15, 15), Secondary = Color3.fromRGB(20, 20, 20), Actions = Color3.fromRGB(12, 16, 22), Component = Color3.fromRGB(20, 20, 20), Highlight = Color3.fromRGB(84, 132, 164), ScrollBar = Color3.fromRGB(30, 30, 30), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(155, 155, 155), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(25, 25, 25), Icon = Color3.fromRGB(255, 255, 255)},
	["Discord"] = {Mode = "Dark", Transparency = 0, Primary = Color3.fromRGB(40, 43, 48), Secondary = Color3.fromRGB(54, 57, 62), Actions = Color3.fromRGB(62, 64, 68), Component = Color3.fromRGB(47, 50, 55), Highlight = Color3.fromRGB(114, 137, 218), ScrollBar = Color3.fromRGB(47, 51, 57), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(155, 155, 155), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(66, 69, 73), Icon = Color3.fromRGB(255, 255, 255)},

	["RC7"] 	  = {Mode = "Dark", Transparency = 0, Primary = Color3.fromRGB(11, 47, 80), Secondary = Color3.fromRGB(20, 58, 96), Actions = Color3.fromRGB(20, 60, 94), Component = Color3.fromRGB(19, 54, 90), Highlight = Color3.fromRGB(89, 121, 180), ScrollBar = Color3.fromRGB(10, 45, 75), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(155, 155, 155), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(33, 72, 105), Icon = Color3.fromRGB(255, 255, 255)},
	["RC7 Red"]   = {Mode = "Dark", Transparency = 0, Primary = Color3.fromRGB(70, 36, 33), Secondary = Color3.fromRGB(66, 34, 31), Actions = Color3.fromRGB(89, 42, 42), Component = Color3.fromRGB(66, 34, 31), Highlight = Color3.fromRGB(255, 88, 88), ScrollBar = Color3.fromRGB(77, 32, 29), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(175, 175, 175), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(89, 46, 42), Icon = Color3.fromRGB(255, 255, 255)},
	["c00l 1337"] = {Mode = "Dark", Transparency = 0, Primary = Color3.fromRGB(0, 0, 0), Secondary = Color3.fromRGB(0, 0, 0), Actions = Color3.fromRGB(255, 0, 0), Component = Color3.fromRGB(10, 10, 10), Highlight = Color3.fromRGB(255, 0, 0), ScrollBar = Color3.fromRGB(20, 20, 20), Title = Color3.fromRGB(255, 255, 255), Description = Color3.fromRGB(155, 155, 155), Shadow = Color3.fromRGB(0, 0, 0), Outline = Color3.fromRGB(255, 0, 0), Icon = Color3.fromRGB(255, 255, 255)},
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
					local ClassName, NewColor, NewProperty, SetTransparency = unpack(Name);

					if (ClassName == "any" or ClassName == Descendant.ClassName) then
						Descendant[NewProperty] = Settings.Theme[NewColor]
					end

					if SetTransparency and Descendant:IsA("CanvasGroup") then
						Descendant.GroupTransparency = (Settings.Theme.Transparency);
					end

				elseif typeof(Name) == "function" then
					Name(Descendant);
				end
			elseif Class then
				Class(Descendant);
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

	return JSONEncode(Services.Http, NewSettings);
end

local GetSavedSettings = function() 
	local Themed = JSONDecode(Services.Http, (Check("File") and readfile("Cmd/Settings.json")) or EncodedSettings()) 
	local Theming = { Theme = {} }

	for Index, Theme in next, Themed.Theme do 
		if typeof(Theme) == "string" and Find(Theme, ",") then
			local Clr = Color3.new(Unpack(Split(Theme, ",")));
			Theming.Theme[Index] = Color3.fromRGB(Clr.R * 255, Clr.G * 255, Clr.B * 255)
		elseif Index == "Transparency" then
			Theming.Theme[Index] = tonumber(Theme);
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
		writefile("Cmd/Settings.json", (Data and JSONEncode(Services.Http, Data)) or EncodedSettings());
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
	local Aliases = Information.Aliases;
	local Description = Information.Description;
	local Arguments = Information.Arguments;
	local Plugin = Information.Plugin;
	local Task = Information.Task;

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
				Output(Format("[COMMAND ERROR] : Error occured trying to run the command - %s\nERROR: %s", Name, Result))
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
		for arg in ArgsString:gmatch("%s*([^"..Settings.Seperator .."]+)") do
			Insert(Arguments, arg)
		end

		FullArgs = Arguments
		Command.Run(IgnoreNotifications, Lower(Name), Arguments)
	end
end

Command.Whitelist = function(Player)
	Admins[Player.UserId] = true
	Connect(Player.Chatted, function(Message)
		if Find(Message, Settings.ChatPrefix) then 
			Command.Parse(false, Split(Message, Settings.ChatPrefix)[2]);
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
		Recommend.Text = Blank; return
	end

	local Lowered = Lower(Split(Input, ' ')[1])
	local Found = false

	--// Command Recommendation
	if #Split(Input, ' ') == 1 then
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
						local GetPlayerArguments = { "all", "random", "others", "seated", "stood", "me", "closest", "farthest", "enemies", "dead", "alive", "friends", "nonfriends"}
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
					local Amount = (#Spaces == 2 and 1) or (#Arguments)
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

		if #Split(Input, ' ') == 1 then
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
								Frame.BackgroundColor3 = (Settings.Theme.Component);
								FoundFirst = true
							else
								Frame.BackgroundColor3 = (Settings.Theme.Primary);
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
			[1] = { Size = UDim2.new(1, -4, 0, 67) };
			[2] = { Size = UDim2.new(1, -4, 0, 125) };
			[3] = { Size = UDim2.new(1, -4, 0, 183) };
			[4] = { Size = UDim2.new(1, -4, 0, 240) };
		}

		local Size = Sizes[Amount] or Sizes[4]
		Tween(Autofill, .25, { Size = Size.Size });
		Tween(CommandBar, .25, { Position = Size.Position });
	end)	
end

--// :: FEATURE

--// Waypoints 

function Feature:AddWaypoint(Name, CFrame) 
	CFrame = tostring(CFrame);

	if Name and CFrame then 
		Settings.Waypoints[Name] = CFrame 
		SaveSettings()

		API:Notify({
			Title = "Waypoints",
			Description = "Added waypoint successfully!",
			Type = "Success",

			Duration = (10),
		})
	else 
		API:Notify({
			Title = "Waypoints",
			Description = "Error adding waypoint, is one of the arguments missing?",
			Type = "Error",

			Duration = (15),
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

			Duration = (10),
		})
	else 
		API:Notify({
			Title = "Events",
			Description = "Error adding an event, event doesn't exist or command already added in the event.",
			Type = "Error",

			Duration = (15),
		})
	end
end

function Feature:ConnectEvent(Event, Connection, UseHumanoid, Check) 
	local RunEvent = function(Event) 
		Foreach(Settings.Events[Event] or (warn(Event) and {}), function(_, command) 
			Command.Parse(false, command);
		end) 
	end

	if (Event == "AutoExecute") then 
		RunEvent(Event)
	elseif Event == "PlayerRemoved" then 
		Connect(Services.Players.PlayerRemoving, function(Plr) 
			if Plr == LocalPlayer then 
				RunEvent("PlayerRemoved");
			end
		end)
	elseif UseHumanoid and typeof(Event) == "string" then 
		local CCharacter = Character 
		local CHumanoid = CCharacter:FindFirstChild("Humanoid")

		local CDetect = function(CHumanoid) 
			if Event == "Damaged" then 
				Connect(Changed(CHumanoid, "Health"), function() 
					if not Check or (Check and Check(CHumanoid)) then 
						RunEvent("Damaged");
					end
				end)
			else 
				Connect(CHumanoid[Event], function() 
					if not Check or (Check and Check(CHumanoid)) then 
						RunEvent(Event);
					end
				end)
			end
		end

		local Char = Character or (LocalPlayer.Character or CWait(LocalPlayer.CharacterAdded)) -- so doesnt error if character doesnt exist
		CDetect(CHumanoid or Char:WaitForChild("Humanoid"));
		Connect(LocalPlayer.CharacterAdded, function(NewCharacter) 
			CCharacter = NewCharacter
			CDetect(CCharacter:WaitForChild("Humanoid"));
		end)
	else 
		Connect(Connection, function() 
			RunEvent(Event);
		end)
	end
end

-- :: COMMANDS :: -- 
Command.Add({
	Aliases = { "settings" },
	Description = "Opens the settings tab",
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
				Tab = "Home"
			})

			Window:AddTab({
				Title = "Prefixes",
				Description = "Change the prefixes of Cmd",
				Tab = "Home"
			})

			Window:AddTab({
				Title = "Toggles",
				Description = "Toggle between different features",
				Tab = "Home"
			})

			Window:AddTab({
				Title = "Theme",
				Description = "Customize the look of Cmd",
				Tab = "Home"
			})

			Window:AddTab({
				Title = "Waypoints",
				Description = "Set up buttons for places to teleport to",
				Tab = "Home"
			})

			Window:AddTab({
				Title = "Keybinds",
				Description = "Set keybinds for running commands",
				Tab = "Home"
			})

			Window:AddTab({
				Title = "Events",
				Description = "Set commands that run during specific events",
				Tab = "Home"
			})


			--// About 
			Window:AddSection({ Title = "Prefixes", Tab = "About"})

			Window:AddParagraph({
				Title = "Prefix",
				Description = Format("Current prefix is '%s'", Settings.Prefix);
				Tab = "About",
			})

			Window:AddParagraph({
				Title = "Chat Prefix",
				Description = Format("Current chat prefix is '%s'", Settings.ChatPrefix);
				Tab = "About",
			})

			Window:AddParagraph({
				Title = "Seperator",
				Description = Format("Current argument seperator is '%s'", Settings.Seperator);
				Tab = "About",
			})

			Window:AddSection({ Title = "Cmd", Tab = "About"})

			Window:AddParagraph({
				Title = "Version",
				Description = Format("Version %s", Settings.Version);
				Tab = "About",
			})

			Window:AddParagraph({
				Title = "Invite",
				Description = "https://discord.gg/j75xENkG";
				Tab = "About",
			})
			--// Settings 

			Window:AddInput({
				Title = "Prefix",
				Description = "Prefix for the Command Bar";
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
				Description = "Prefix for using commands in chat";
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
			Window:AddSection({ Title = "Command Bar", Tab = "Toggles"})

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

			Window:AddSection({ Title = "Autofill", Tab = "Toggles"})

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

			Window:AddSection({ Title = "Others", Tab = "Toggles"})

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
				Default = Settings.Toggles.IngoreSeated,
				Callback = function(Toggle)
					Settings.Toggles.IngoreSeated = Toggle
					SaveSettings()
				end,
			})

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
					Theme.Transparency = (Settings.Theme.Transparency);

					SetTheme(Theme)
					SaveSettings()
				end,
			})

			Window:AddSection({ Title = "Others", Tab = "Theme" })

			Window:AddSlider({
				Title = "UI Transparency",
				Tab = "Theme",
				MaxValue = .8,
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
					SaveSettings();
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
				Tab = "Keybinds"
			})

			Window:AddTab({
				Title = "Current Keybinds",
				Description = "List of active Keybinds",
				Tab = "Keybinds"
			})

			-- : Create Keybind
			local Keybind = { Begin = nil, End = nil, Key = nil }
			local CreateKeybind = function(Keybind)
				local Key, Begin, End = Keybind.Key,
				Keybind.Begin, Keybind.End

				Window:AddButton({
					Title = GSub(tostring(Key.KeyCode), "Enum.KeyCode.", Blank);
					Description = "Click this to remove the Keybind",
					Tab = "Current Keybinds",
					Callback = function(Button) 
						Keybinds[Key] = (nil);
						Destroy(Button);
					end,
				})
			end
			Window:AddSection({ Title = "Create", Tab = "Create Keybind"})

			Window:AddButton({
				Title = "Create Keybind",
				Description = "Create the Keybind!";
				Tab = "Create Keybind",
				Callback = function() 
					local Key, Begin, End = Keybind.Key ,
					Keybind.Begin, Keybind.End

					if not Keybinds[Key] and Begin and End and Key then
						Keybinds[Keybind.Key] = { Begin = Begin, End = End, Key = Key, Active = false };
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

			Window:AddSection({ Title = "Settings", Tab = "Create Keybind"})

			Window:AddKeybind({
				Title = "Keybind Keybind",
				Description = "The keybind for the Keybind";
				Tab = "Create Keybind",
				Callback = function(Key) 
					Keybind.Key = Key
				end,
			})

			Window:AddInput({
				Title = "Keybind Begin Command",
				Description = "The command to run when you want the Keybind to begin";
				Tab = "Create Keybind",
				Callback = function(Cmd) 
					Keybind.Begin = Cmd
				end,
			})

			Window:AddInput({
				Title = "Keybind End Command",
				Description = "The command to run when you want to END the Keybind";
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

						if (Method == "TP") then
							Root.CFrame = Position
						else 
							Settings.Waypoints[Name] = (nil);
							Destroy(Button);
							SaveSettings();
						end
					end,
				})
			end

			Window:AddSection({ Title = "Create", Tab = "Waypoints" })
			Window:AddInput({
				Title = "Make Waypoint (NAME)",
				Tab = "Waypoints",
				Callback = function(Name) 
					local Position = (Root.CFrame)

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
				Tab = "Events"
			})

			Window:AddTab({
				Title = "Current Events",
				Description = "List of active events",
				Tab = "Events"
			})

			-- : Create event
			local SelectedEvent = ("Unselected");
			local EventCommand

			for EventName, SavedEvent in next, Settings.Events do 
				for _, SavedCommand in next, SavedEvent do 
					Window:AddButton({
						Title = Format("Event for %s", EventName);
						Description = Format("Click to delete the event\nCommand: %s", SavedCommand),
						Tab = "Current Events",
						Callback = function(Button) 
							Settings.Events[EventName][SavedCommand] = (nil);
							Destroy(Button)
							SaveSettings();
						end,
					})
				end
			end

			local AddEvent = function() 
				if Settings.Events[SelectedEvent] and EventCommand then 
					local OldSelected = (SelectedEvent);
					local OldEvent = (EventCommand);

					Feature:AddEvent(OldSelected, OldEvent)
					Window:AddButton({
						Title = Format("Event for %s", SelectedEvent);
						Description = Format("Click to delete the event\nCommand: %s", EventCommand),
						Tab = "Current Events",
						Callback = function(Button) 
							Settings.Events[OldSelected][OldEvent] = (nil);
							Destroy(Button)
							SaveSettings();
						end,
					})
				else 
					API:Notify({
						Title = "Events",
						Description = "Error saving event, is one of the arguments missing?",
						Type = "Error",

						Duration = (10),
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
					SelectedEvent = (Event);
				end,
			})

			Window:AddInput({
				Title = "Event Command",
				Tab = "Create Event",
				Callback = function(Input) 
					EventCommand = (Input);
				end,
			})

		end
	end,
})

local ESPSettings = {
	Enabled = (false);
	Boxes = (true);
	Text = (true);

	TextSize = (18);
	BoxThickness = (1);
	IgnoreTeammates = (false);
}

Command.Add({
	Aliases = { "esp" },
	Description = "See other players through walls",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs["Esp"];

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
							DrawingLine.Visible = (Boolean);
						else 
							DrawingLine.Visible = (false);
						end
					end

					if ESPSettings.Enabled and ESPSettings.Text then 
						Name.Visible = (Boolean);
					else 
						Name.Visible = (false);
					end
				end 

				local UpdatePosition = function()
					local Root = (Player.Character and Player.Character:FindFirstChild("HumanoidRootPart"))

					if Root and not (ESPSettings.IgnoreTeammates and Player.Team == LocalPlayer.Team) and (ESPSettings.Enabled) then
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
							local BL = Camera:WorldToViewportPoint((Coordinate * CFrame.new(-Size.X, -Size.Y, 0)).Position)
							local BR = Camera:WorldToViewportPoint((Coordinate * CFrame.new(Size.X, -Size.Y, 0) ).Position)
							local TL = Camera:WorldToViewportPoint((Coordinate * CFrame.new(-Size.X, Size.Y, 0) ).Position)
							local TR = Camera:WorldToViewportPoint((Coordinate * CFrame.new(Size.X, Size.Y, 0)  ).Position)

							Bottom.From = Vector2.new(BL.X, BL.Y)
							Bottom.To = Vector2.new(BR.X, BR.Y)

							Top.From = Vector2.new(TL.X, TL.Y)
							Top.To = Vector2.new(TR.X, TR.Y)

							Right.From = Vector2.new(TR.X, TR.Y)
							Right.To = Vector2.new(BR.X, BR.Y)

							Left.From = Vector2.new(TL.X, TL.Y)
							Left.To = Vector2.new(BL.X, BL.Y)

							Name.Position = Vector2.new((TL.X + TR.X) / 2, TL.Y - 20)

							SetVisible(true);
						else
							SetVisible(false);
						end
					else
						SetVisible(false);
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
	Enabled = (false),
	Part = ("Head"), --// Available parts: Head, HumanoidRootPart
	Method = ("Camera"); --// Available methods: Camera, Mouse, Third

	AliveCheck = (true),
	TeamCheck = (false),
	WallCheck = (false),

	Held = (false),
	Key = Enum.KeyCode.E,

	Prediction = (0),
	Target = (nil),

	FOV = {
		Radius = (100),
	},
}

AimbotSettings.BehindWall = function(Target: Player) 
	if (Target) and (Target.Character) and (Target ~= LocalPlayer) then 
		local Walls = Camera:GetPartsObscuringTarget({ Character.Head.Position, Target.Character.Head.Position}, { Character, Target.Character})
		return (#Walls == 0 and false) or (#Walls > 0 and true)
	end
end

AimbotSettings.Closest = function()
	local Distance, Target = 9e9, (nil)

	for Index, Player in next, (Services.Players:GetPlayers()) do
		if not (AimbotSettings.TeamCheck and Player.Team == LocalPlayer.Team) then  
			if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild(AimbotSettings.Part) then
				local Character = Player.Character
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				local Location, Visible = Camera:WorldToViewportPoint(Character:FindFirstChild(AimbotSettings.Part).Position)

				if not (AimbotSettings.WallCheck and AimbotSettings.BehindWall(Player)) then
					if Visible and not (AimbotSettings.AliveCheck and Humanoid.Health <= 0) then 
						local Magnitude = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(Location.X, Location.Y)).Magnitude
						if Magnitude < AimbotSettings.FOV.Radius and Magnitude < Distance then
							Distance = (Magnitude);
							Target = (Player); 
						end
					end
				end
			end
		end
	end

	return Target
end

Command.Add({
	Aliases = { "aimbot" },
	Description = "Tab with Aimbot features",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Aimbot;

		if Tab then
			Tab.Open();
		else
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

			Window:AddKeybind({
				Title = "Keybind",
				Tab = "Home",
				Callback = function(Key) 
					AimbotSettings.Key = (Key)
				end,
			})

			Window:AddSection({ Title = "Checks", Tab = "Home" });

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

			Window:AddSection({ Title = "Sliders", Tab = "Home" });

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
				},
				Callback = function(Part) 
					AimbotSettings.Part = Part
				end,
			})

			Window:AddDropdown({
				Title = "Aimbot Method",
				Tab = "Home",
				Options = {
					["First Person"] = "Camera",
					["Third Person"] = "Third",
				},
				Callback = function(Method) 
					AimbotSettings.Method = Method
				end,
			})

			Spawn(function()
				Connect(Services.Input.InputBegan, function(Key, Processed)
					if Key == AimbotSettings.Key and AimbotSettings.Enabled and not Processed then
						local Closest = AimbotSettings.Closest()

						if Closest and Closest.Character and Closest.Character:FindFirstChildOfClass("Humanoid") and Closest.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
							local TargetPart = Closest.Character:FindFirstChild(AimbotSettings.Part)
							AimbotSettings.Held = true

							repeat Wait()
								local Method = AimbotSettings.Method
								if (Method == "Camera" or Method == "Third") then 
									local TargetPart = Closest.Character:FindFirstChild(AimbotSettings.Part)
									local LookAt = TargetPart.CFrame + (TargetPart.Velocity * AimbotSettings.Prediction + Vector3.new(0, 0.1, 0))
									Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, LookAt.Position)

									if Method == "Third" then
										Services.Input.MouseBehavior = (Enum.MouseBehavior.LockCenter);
									end
								elseif AimbotSettings.Method == "Mouse" then 

								end
							until not AimbotSettings.Held or not Closest
						end
					end
				end)

				Connect(Services.Input.InputEnded, function(Key, Processed)
					if Key == AimbotSettings.Key and AimbotSettings.Enabled and not Processed then
						AimbotSettings.Held = false
					end
				end)

				local Circle
				if (Drawing and Drawing.new) then
					Circle = Drawing.new("Circle");

					repeat Wait();
						local MouseLocation = (Services.Input:GetMouseLocation())
						if AimbotSettings.Enabled then
							Circle.Radius = AimbotSettings.FOV.Radius;
							Circle.Position = Vector2.new(MouseLocation.X, MouseLocation.Y);
							Circle.Visible = (true);
						else
							Circle.Visible = (false);
						end

					until not Circle
				end
			end)

		end
	end,
})

Command.Add({
	Aliases = { "notify", "send" },
	Description = "Sends a notification",
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
			Type = Type
		})
	end,
})

Command.Add({
	Aliases = { "servers" },
	Description = "A tab that shows a list of servers in the game you're on",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs["Servers"];

		if Tab then
			Tab.Open()
		else
			local PlayerCount = (nil)
			local Refreshed = (false)
			local Window = Library:CreateWindow({
				Title = "Servers",
			})

			local LoadServers = function() 
				local Servers = Methods.Get(Format("https://games.robloxbadges.com/v1/games/%s/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100&cursor=", game.PlaceId));
				local Found = false 

				repeat Wait() 
					local Decode = JSONDecode(Services.Http, Servers);
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
						Servers = Methods.Get(Format("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Desc&excludeFullGames=true&limit=100&cursor=%s", tostring(game.PlaceId), Decode.nextPageCursor or "" ));
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

					LoadServers();
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
						PlayerCount = (nil);
					else 
						PlayerCount = Amount 
					end
				end,
			})

			Window:AddSection({ Title = "Servers", Tab = "Home" })
			LoadServers();
		end
	end,
})

Command.Add({
	Aliases = { "fakechat" },
	Description = "Fake a message in chat as someone else",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Chat;

		if Tab then
			Tab.Open()
		else
			local Disguise, Username, Message = "Hello", "Roblox", "whats up"
			local Window = Library:CreateWindow({
				Title = "Chat",
			})

			local Send = function()
				local Character = " "
				local UsernameType = (LegacyChat and "[%s]") or "%s"
				Chat(Disguise .. Character:rep(125) .. Format(UsernameType .. ": %s", Username, Message))
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
	Description = "Opens a tab that shows a list of the current commands",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs["Commands"];

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
					Title = Concat(Aliases, " / ");
					Description = Description,
					Tab = "Home",
				})
			end
		end
	end,
})

Command.Add({
	Aliases = { "highlight", "hl" },
	Description = "Highlight any parts, from classname to name",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Highlight;

		if Tab then
			Tab.Open()
		else
			local HighlightName = GenerateGUID(Services.Http);
			local Highlights = {}
			local SetParent = (false) 
			local Name = (nil) 
			local Class = (nil)

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

							Duration = (10),
						})

						return
					end

					for Index, Part in next, workspace:GetDescendants() do 
						if not Name or (Lower(Part.Name) == Lower(Name)) then 
							if not Class or (Lower(Part.ClassName) == Lower(Class)) then 
								if not Highlights[Part] then 
									local NewHighlight = Instance.new("Highlight", (SetParent and Part.Parent) or Part);
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
					SetHighlight(true);
				end,
			})

			Window:AddButton({
				Title = "Remove Highlights",
				Tab = "Home",
				Callback = function() 
					SetHighlight(false);
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

					Name = (Input);
				end,
			})

			Window:AddInput({
				Title = "Part Classname",
				Tab = "Home",
				Callback = function(Input) 
					if GSub(Input, " ", Blank) == Blank then 
						Input = nil 
					end

					Class = (Input);
				end,
			})

			Window:AddToggle({
				Title = "Highlight Parent",
				Description = "Gives the highlight to the parent of the part, useful for classes like ProximityPrompts that aren't parts",
				Tab = "Home",
				Callback = function(Boolean) 
					SetParent = (Boolean);
				end,
			})
		end
	end,
})

Command.Add({
	Aliases = { "scripts" },
	Description = "Searches scripts using Scriptblox API",
	Arguments = {},
	Task = function()
		local Tab = Library.Tabs.Scriptblox;

		if Tab then
			Tab.Open()
		else
			local Window = Library:CreateWindow({
				Title = "Scriptblox",
			})

			local Search = function(Input) 
				local Scripts = JSONDecode(Services.Http, Methods.Get(Format("https://scriptblox.com/api/script/search?q=%s&max=200&mode=free", Input)))

				for Index, Script in next, Scripts.result.scripts do
					local Game = (Script.game.name);
					local Type = (Script.scriptType);
					local Main = (Script.script);
					local Title = (Script.title);

					Window:AddButton({
						Title = Title,
						Description = Format("%s (%s)", Game, string.upper(Type)),
						Tab = "Home",
						Callback = function() 
							API:Notify({
								Title = "Scriptblox",
								Description = Format("Running %s...", Title),
							});

							loadstring(Main)()
						end,
					})
				end
			end

			Window:AddSection({ Title = "Search", Tab = "Home" });

			Window:AddInput({
				Title = "Search",
				Tab = "Home",
				Callback = function(Input) 
					for Index, Script in next, Window:GetTab("Home"):GetChildren() do
						if Script:IsA("TextButton") and Script.Frame:FindFirstChild("Description") then
							Destroy(Script)
						end
					end

					Search(Input);
				end,
			})

			Window:AddSection({ Title = "Results", Tab = "Home" });

			Search("Universal");	
		end
	end,
})

Command.Add({
	Aliases = { "fov", "field" },
	Description = "Change your field of view",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Amount)
		Camera.FieldOfView = SetNumber(Amount, 0, 120);
	end,
})

Command.Add({
	Aliases = { "respawn", "re" },
	Description = "Respawns your character",
	Arguments = {},
	Task = function()
		local Position = (Root.CFrame);
		local Connection

		Humanoid.Health = (0);
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
				Method(Flag, Value);
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
	Description = "Change your walkspeed in a more undetectable way",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Speed)
		Refresh("Walk", true);

		repeat Wait()
			if Humanoid.MoveDirection.Magnitude > 0 then
				Character:TranslateBy(Humanoid.MoveDirection * SetNumber(Speed) * CWait(Services.Run.Heartbeat) * 10)
			end
		until not Get("Walk") or not Character
	end,
})

Command.Add({
	Aliases = { "untpwalk", "unwalk" },
	Description = "Stops the teleport walk command",
	Arguments = {},
	Task = function()
		Refresh("Walk", false);
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
		local Arguments = (nil);
		Add("Loop", true)

		if tonumber(Delay) then
			Arguments = Minimum(FullArgs, 3);
		else
			Name, Delay, Arguments = (Delay), (.05), Minimum(FullArgs, 2);
		end

		repeat Wait(Delay or 0)
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
	Description = "Fires a command a specific amount of times",
	Arguments = {
		{ Name = "Repeat amount", Type = "Number" }, 
		{ Name = "Delay", Type = "Number" }, 
		{ Name = "Command Name", Type = "String" }, 
		{ Name = "Arguments", Type = "String" }, 
	},
	Task = function(RepeatAmount, Delay, Name, Arguments)
		if tonumber(RepeatAmount) and tonumber(Delay) then
			Arguments = Minimum(FullArgs, 4);
		elseif tonumber(RepeatAmount) and not tonumber(Delay) then
			Name, Delay, Arguments = Delay, 0 , Minimum(FullArgs, 3)
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
	Description = "Teleports you to a spawnpoint",
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
			BasePart.CanTouch = (false);
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
			BasePart.CanTouch = (true);
		end

		return "Anti Kill", "Anti kill has been disabled"
	end,
})

Command.Add({
	Aliases = { "serverfreeze", "sfr" },
	Description = "Freezes your character on the server, but not on the client",
	Arguments = {},
	Task = function()
		local NewRoot = Clone(Root)
		Destroy(Root); Root = (NewRoot) 
		NewRoot.Parent = (Character)

		return "Server Freeze", "Server freeze has been enabled, to disable please reset", 10
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
	Description = "Makes your camera be able to go through walls",
	Arguments = {},
	Task = function()
		LocalPlayer.DevCameraOcclusionMode = (Enum.DevCameraOcclusionMode.Invisicam);
	end,
})

Command.Add({
	Aliases = { "uncameranoclip", "cameraclip", "camclip", "cc" },
	Description = "Undoes the cameranoclip command",
	Arguments = {},
	Task = function()
		LocalPlayer.DevCameraOcclusionMode = (Enum.DevCameraOcclusionMode.Zoom);
	end,
})

Command.Add({
	Aliases = { "firstperson", "fps", "1p", "3rd" },
	Description = "Forces your character to go first-person",
	Arguments = {},
	Task = function()
		LocalPlayer.CameraMode = (Enum.CameraMode.LockFirstPerson);
	end,
})

Command.Add({
	Aliases = { "thirdperson", "tps", "3p", "1st" },
	Description = "Forces your character to go third-person",
	Arguments = {},
	Task = function()
		LocalPlayer.CameraMode = (Enum.CameraMode.Classic);
	end,
})

Command.Add({
	Aliases = { "maxzoom", "maxz" },
	Description = "Set the maximum amount your camera can zoom out",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		LocalPlayer.CameraMaxZoomDistance = SetNumber(Amount);
		return "Maximum Zoom", Format("Set maximum zoom to %s", Amount);
	end,
})

Command.Add({
	Aliases = { "minzoom", "minz" },
	Description = "Set the minimum amount your camera can zoom in",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		LocalPlayer.CameraMinZoomDistance = SetNumber(Amount);
		return "Minimum Zoom", Format("Set minimum zoom to %s", Amount);
	end,
})

Command.Add({
	Aliases = { "autorespawn", "autore" },
	Description = "Automatically teleports you to where you were when you died",
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

					CWait(LocalPlayer.CharacterAdded);
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
	Description = "Stops the autorespawn command",
	Arguments = {},
	Task = function()
		Refresh("AutoRespawn", false);
		return "Auto Respawn", "Auto Respawn has been disabled"
	end,
})

Command.Add({
	Aliases = { "enablechat", "enablec", "ech" },
	Description = "Enables Roblox's Chat ui",
	Arguments = {},
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, true)
	end,
})

Command.Add({
	Aliases = { "enableinventory", "enableinv", "einv" },
	Description = "Enables Roblox's inventory ui",
	Arguments = {},
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, true)
	end,
})

Command.Add({
	Aliases = { "disableinventory", "disableinv", "dinv" },
	Description = "Disables Roblox's inventory ui",
	Arguments = {},
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, false)
	end,
})

Command.Add({
	Aliases = { "fullbright", "fb" },
	Description = "Makes the game fully bright",
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
	Description = "Makes your graphics lower to save frames per second",
	Arguments = {},
	Task = function()
		local SetInstance = function(Instance) 
			if (Instance) then 
				if (Instance:IsA("Texture") or Instance:IsA("Decal")) then 
					Destroy(Instance);
				elseif (Instance:IsA("BasePart")) then
					Instance.Material = (Enum.Material.Plastic);
					Instance.Reflectance = (0);
				elseif (Instance:IsA("ParticleEmitter") or Instance:IsA("Trail")) then
					Instance.Lifetime = NumberRange.new(0);
				elseif (Instance:IsA("Fire") or Instance:IsA("SpotLight") or Instance:IsA("Smoke") or Instance:IsA("Sparkles")) then
					Instance.Enabled = (false);
				end
			end
		end

		Connect(workspace.DescendantAdded, SetInstance)
		for Index, Instance in next, (workspace:GetDescendants()) do
			SetInstance(Instance);
		end 

		return "FPS Booster", "Rejoin to undo the command"
	end,
})

Command.Add({
	Aliases = { "anticframeteleport", "actp" },
	Description = "Stops the game from teleporting your character",
	Arguments = {},
	Task = function()
		local Allowed
		local Old

		Refresh("AntiCFrame", true)
		Connect(Changed(Root, "CFrame"), function() 
			if Get("AntiCFrame") then
				Allowed = true
				Root.CFrame = (Old);

				Wait();
				Allowed = false
			end
		end)

		API:Notify({
			Title = "Anti Teleport",
			Description = "Anti CFrame Teleport has been enabled",
		})

		repeat Wait();
			Old = (Root.CFrame)
		until not Root
	end,
})

Command.Add({
	Aliases = { "unanticframeteleport", "unactp" },
	Description = "Stops the anti teleport command",
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
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		local Sword 
		for Index, Target in next, GetPlayer(Input) do 
			if Target ~= LocalPlayer then 
				local TCharacter = GetCharacter(Target);
				local TRoot = GetRoot(Target);
				local THumanoid = GetHumanoid(Target);
				local Timer = tick() 

				if (TCharacter) and (not TCharacter:FindFirstChildOfClass("ForceField")) then 
					for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
						if Find(Lower(Tool.Name), "sword") then
							Sword = Tool
						end
					end

					repeat Wait() 
						Sword.Parent = Character
						Sword:Activate()
						if firetouchinterest then 
							firetouchinterest(TRoot, Sword.Handle, 0);
							Wait();
							firetouchinterest(TRoot, Sword.Handle, 1);
						else 
							TRoot.CFrame = Root.CFrame * CFrame.new(2, 0, -3)
						end 
					until (THumanoid.Health == 0) or (tick() - Timer >= 5)
				end
			end
		end

		Humanoid:UnequipTools();
		return "Sword Kill", "Killed the target(s)"
	end,
})


Command.Add({
	Aliases = { "activatetool", "at" },
	Description = "Activates a specific tool",
	Arguments = {
		{ Name = "Tool", Type = "Script"}
	},
	Task = function(Input)
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			if Find(Lower(Tool.Name), Lower(Input)) then
				Tool.Parent = Character
				Tool:Activate();
				Wait()
				Tool.Parent = Backpack
			end
		end
	end,
})

Command.Add({
	Aliases = { "activatetools", "ats" },
	Description = "Activates ALL tool",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			Tool.Parent = Character
			Tool:Activate();
			Wait()
			Tool.Parent = Backpack
		end
	end,
})

Command.Add({
	Aliases = { "equiptools", "et" },
	Description = "Equips every tool in your inventory",
	Arguments = {
		{ Name = "Tool", Type = "Script"}
	},
	Task = function(Input)
		for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
			Tool.Parent = Character
		end
	end,
})

Command.Add({
	Aliases = { "deletetools", "dtools" },
	Description = "Deletes all the tools in your inventory",
	Arguments = {},
	Task = function()
		Backpack:ClearAllChildren()
		return "Delete Tools", "Cleared all children"
	end,
})

Command.Add({
	Aliases = { "invisible", "invis", "inv" },
	Description = "Makes your character be invisible",
	Arguments = {},
	Task = function()
		local OriginalPlayer = Services.Lighting:FindFirstChild(LocalPlayer.Name)
		Character.Archivable = (true)
		if (not OriginalPlayer) then
			local Clone = Clone(Character)
			local Animate = Clone.Animate 
			for Index, BodyPart in next, GetClasses(Clone, "BasePart", true) do 
				BodyPart.Transparency = (0.7)
			end 

			Root.CFrame = CFrame.new(1000, 1000, 1000);
			Wait(.1);
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
	Description = "Makes your character visible",
	Arguments = {},
	Task = function()
		local OriginalPlayer = Services.Lighting:FindFirstChild(LocalPlayer.Name)
		if (OriginalPlayer) then
			local Invisible = LocalPlayer.Character
			local Parent = Invisible.Parent 
			local Position = Root.CFrame

			LocalPlayer.Character = OriginalPlayer
			LocalPlayer.Character.Parent = Parent
			Character = OriginalPlayer 
			Root = GetRoot(LocalPlayer)
			Humanoid = GetHumanoid(LocalPlayer)

			Wait(.1)
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
		Humanoid.Sit = (true);
	end,
})

Command.Add({
	Aliases = { "flood" },
	Description = "Floods the chat with spam",
	Arguments = {},
	Task = function()
		Refresh("Flood", true);
		repeat Wait(1) 
			Chat(("⸻"):rep((LegacyChat and 180) or 66))
		until not Get("Flood")
	end,
})

Command.Add({
	Aliases = { "unflood" },
	Description = "Stops the flood command",
	Arguments = {},
	Task = function()
		Refresh("Flood", false);
	end,
})

Command.Add({
	Aliases = { "spam" },
	Description = "Spams the message you input into the chat",
	Arguments = {
		{ Name = "Message", Type = "String" }
	},
	Task = function(Message)
		Add("Spam", true);
		repeat Wait(.3);
			Chat(Message);
		until not Get("Spam")
	end,
})

Command.Add({
	Aliases = { "unspam" },
	Description = "Disables the spam command",
	Arguments = {},
	Task = function()
		Refresh("Spam", false);
		return "Spam", "Stopped the spamming"
	end,
})

Command.Add({
	Aliases = { "sync" },
	Description = "Plays every sound in-game in sync",
	Arguments = {},
	Task = function()
		Refresh("Sync", true);
		if RespectFilteringEnabled then 
			return "Sync", "Couldn't sync since RFE is turned on"
		else
			repeat Wait();
				for Index, Sound in next, GetClasses(game, "Sound") do
					Sound.Volume = (10);
					Sound:Play()
				end
			until not Get("Sync")
		end
	end,
})

Command.Add({
	Aliases = { "unsync" },
	Description = "Stops the sync command",
	Arguments = {},
	Task = function()
		Refresh("Sync", false);
	end,
})

Command.Add({
	Aliases = { "buff" },
	Description = "Easier to push tools",
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
		{ Name = "Amount", Type = "String" }
	},
	Task = function(Amount)
		local Gravity = SetNumber(Amount);
		local Set = function(Part) 
			if Part and Part:IsA("BasePart") and not Part.Anchored then 
				Create("BodyForce", {
					Force = Part:GetMass() * Vector3.new(Gravity, workspace.Gravity, Gravity),
					Parent = Part,
				})
			end
		end

		SetSRadius(9e9, 9e9);
		Connect(workspace.DescendantAdded, Set)

		for Index, Part in next, GetClasses(workspace, "BasePart") do 
			Set(Part)
		end 

		return "Gravity", Format("Set unanchored gravity to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "remotespy", "rspy" },
	Description = "UI to see fired remotes",
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
		for Index, Part in next, GetClasses(workspace, "BasePart") do
			local Model = Part:FindFirstAncestorOfClass("Model");
			local isPlayer = (Model and Services.Players:GetPlayerFromCharacter(Model))
			if (not Part.Anchored) and (not isPlayer) then 
				Part.CFrame = CFrame.new(0, workspace.FallenPartsDestroyHeight + 50, 0);
			end 
		end
	end,
})

Command.Add({
	Aliases = { "attachpart", "apart" },
	Description = "Click on an unanchored part to attach it",
	Arguments = {},
	Task = function()
		Connect(Mouse.Button1Down, function() 
			local Target = (Mouse.Target)
			Attach(Target)
		end)
		return "Part Attach", "Loaded successfully!"
	end,
})

Command.Add({
	Aliases = { "attachparts", "aparts" },
	Description = "Attaches every unanchored part in-game",
	Arguments = {},
	Task = function()
		for Index, Part in next, GetClasses(workspace, "BasePart") do
			Attach(Part);
		end
		return "Part Attach", "Attached to every part in game"
	end,
})

Command.Add({
	Aliases = { "controlnpc", "cnpc" },
	Description = "Click on a NPC to control it",
	Arguments = {},
	Task = function()
		Refresh("ControlNPC", true);
		Connect(Mouse.Button1Down, function() 
			local Target = (Mouse.Target);
			local ModelDescendant = Target:FindFirstAncestorOfClass("Model") 
			local HasHumanoid = (ModelDescendant and ModelDescendant:FindFirstChildOfClass("Humanoid"))

			if (ModelDescendant) and (HasHumanoid) and (not Services.Players:GetPlayerFromCharacter(ModelDescendant)) and Get("ControlNPC") then 
				local RootPart = ModelDescendant:FindFirstChild("HumanoidRootPart") or ModelDescendant:FindFirstChild("Torso")

				Attach(RootPart);
				repeat Wait();
					for Index, BodyPart in next, GetClasses(ModelDescendant, "BasePart") do 
						BodyPart.CanCollide = (false);
					end 
				until not Get("ControlNPC") or not ModelDescendant
			end
		end)

		return "NPC", "Control NPC has been enabled"
	end,
})

Command.Add({
	Aliases = { "uncontrolnpc", "uncnpc" },
	Description = "Disables the controlnpc command",
	Arguments = {},
	Task = function()
		Refresh("ControlNPC", false);
		return "NPC", "Control NPC has been disabled"
	end,
})



Command.Add({
	Aliases = { "blackhole", "bh" },
	Description = "Creates a blackhole part that grabs unanchored parts",
	Arguments = {},
	Task = function()
		Refresh("Blackhole", true);
		local Blackhole = Create("Part", {
			Parent = workspace,
			Transparency = 0.5,
			CFrame = Root.CFrame, 
			CanCollide = false,
			Anchored = true,
		})

		repeat Wait(1);
			for Index, Part in next, GetClasses(workspace, "BasePart") do
				Attach(Part, Blackhole);
			end
		until not Get("Blackhole")
		Destroy(Blackhole)
	end,
})

Command.Add({
	Aliases = { "unblackhole", "unbh" },
	Description = "Stops the blackhole command",
	Arguments = {},
	Task = function()
		Refresh("Blackhole", false);
	end,
})

Command.Add({
	Aliases = { "unattach" },
	Description = "Unattaches every part you have previously attached",
	Arguments = {},
	Task = function()
		for Index, Attachment in next, workspace:GetDescendants() do
			if (Attachment.Name == AttachName) then
				Destroy(Attachment)
			end
		end
		return "Part Attach", "Unattached every part"
	end,
})

Command.Add({
	Aliases = { "killnpcs", "knpc" },
	Description = "Kills every NPC in-game",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do 
			local Humanoid = NPC:FindFirstChildOfClass("Humanoid");
			if (Humanoid) then 
				Humanoid.Health = (0);
			end
		end
		return "NPC", "Killed all NPCs"
	end,
})

Command.Add({
	Aliases = { "flingnpcs", "fnpc" },
	Description = "Flings every NPC in-game",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do 
			local Humanoid = NPC:FindFirstChildOfClass("Humanoid");
			if (Humanoid) then 
				Humanoid.HipHeight = (1024);
			end
		end
		return "NPC", "Flinged all NPCs"
	end,
})

Command.Add({
	Aliases = { "voidnpcs", "vnpc" },
	Description = "Voids every NPC in-game",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do 
			local Humanoid = NPC:FindFirstChildOfClass("Humanoid");
			if (Humanoid) then 
				Humanoid.HipHeight = (-1024);
			end
		end
		return "NPC", "Voided all NPCs"
	end,
})

Command.Add({
	Aliases = { "bringnpcs", "bnpc" },
	Description = "Brings every NPC in-game",
	Arguments = {},
	Task = function()
		for Index, NPC in next, GetPlayer("NPC") do 
			local RootPart = (NPC:FindFirstChild("HumanoidRootPart") or NPC:FindFirstChild("Torso"));
			if (RootPart) then 
				RootPart.CFrame = (Root.CFrame);
			end
		end
		return "NPC", "Brought all NPCs"
	end,
})

Command.Add({
	Aliases = { "follownpcs", "fonpc" },
	Description = "Makes every NPC in-game follow you",
	Arguments = {},
	Task = function()
		Refresh("FollowNPCs", true);

		repeat Wait(.1);
			for Index, NPC in next, GetPlayer("NPC") do 
				local Humanoid = NPC:FindFirstChildOfClass("Humanoid");
				if (Humanoid) then 
					Humanoid:MoveTo(Root.Position);
				end
			end
		until not Get("FollowNPCs");
	end,
})

Command.Add({
	Aliases = { "unfollownpcs", "unfonpc" },
	Description = "Disables the follownpcs command",
	Arguments = {},
	Task = function()
		Refresh("FollowNPCs", false);
	end,
})

Command.Add({
	Aliases = { "setsimulationradius", "setsimradius", "ssr" },
	Description = "Sets the simulation radius, useful for commands that require unanchored parts",
	Arguments = {
		{ Name = "Amount", Type = "Amount" },
	},
	Task = function(Amount)
		local N = SetNumber(Amount);
		SetSRadius(N, N);
		return "Simulation Radius", Format("Successfully set your simulation radius to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "freegamepasses", "freegp", "fgp" },
	Description = "Makes the game think you own all gamepasses, as well, fires signals saying that you bought everything",
	Arguments = {},
	Task = function()
		local Products = Services.Market:GetDeveloperProductsAsync():GetCurrentPage()
		local SignalsFired = (0)

		if Check("Hook") then 
			Add("GamepassHook", hookfunction(Services.Market.UserOwnsGamePassAsync, newcclosure(function(...)
				return true
			end)))
		end

		for Index, Product in next, Products do
			for Type, ID in next, Product do
				if (Type == "ProductId") or (Type == "DeveloperProductId") then
					Services.Market:SignalPromptProductPurchaseFinished(LocalPlayer.UserId, ID, true)
					SignalsFired += (1)
				end
			end
		end

		return "Gamepasses fired", Format("All gamepasses have been hooked as well as fired %s purchase signals", SignalsFired), 15
	end,
})

Command.Add({
	Aliases = { "saveinstance", "savemap" },
	Description = "Saves an RBXL file of the game in your workspace folder",
	Arguments = {},
	Task = function()	
		if saveinstance then 
			saveinstance();
		else 
			return "Save Instance", "Your executor does not support save instance, missing function saveinstance()", 15
		end
	end,
})

Command.Add({
	Aliases = { "climb" },
	Description = "Climb in the air",
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

		while (Part and Wait()) do
			Part.CFrame = Root.CFrame * CFrame.new(0, 0, -1.5)
		end
	end,
})

Command.Add({
	Aliases = { "unclimb" },
	Description = "Stops the climb command",
	Arguments = {},
	Task = function()		
		Destroy(Get("ClimbPart"))
	end,
})

Command.Add({
	Aliases = { "setfpscap", "sfc" },
	Description = "Sets the maximum cap for FPS",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		if setfpscap then 
			setfpscap(SetNumber(Amount));
			return "FPS", Format("Set your FPS cap to %s", Amount)
		else
			return "Unsupported Executor", "Your executor does not support this command, missing function - setfpscap()" 
		end
	end,
})

Command.Add({
	Aliases = { "unlockfps", "unlf" },
	Description = "Unlocks your FPS count",
	Arguments = {},
	Task = function()
		if setfpscap then 
			setfpscap(1000);
			return "FPS Cap", "Unlocked to 1000"
		else
			return "Unsupported Executor", "Your executor does not support this command, missing function - setfpscap()" 
		end
	end,
})

Command.Add({
	Aliases = { "antikick" },
	Description = "Doesn't let you get kicked locally",
	Arguments = {},
	Task = function()
		Refresh("AntiKick", true);
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
	Description = "Disables anti kick",
	Arguments = {},
	Task = function()
		Refresh("AntiKick", false);
		return "Anti Kick", "Anti Kick has been disabled"
	end,
})

Command.Add({
	Aliases = { "antiteleport" },
	Description = "Doesn't let you get teleported locally",
	Arguments = {},
	Task = function()
		Refresh("AntiTeleport", true);
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
	Description = "Disables anti teleport",
	Arguments = {},
	Task = function()
		Refresh("AntiTeleport", false);
		return "Anti Teleport", "Anti Teleport has been disabled"
	end,
})

Command.Add({
	Aliases = { "grabber" },
	Description = "Drops a tool and checks who grabbed it",
	Arguments = {},
	Task = function()		
		local Tool = Backpack:FindFirstChildOfClass("Tool")
		local Grabber

		Tool.Parent = (Character)
		Tool.Parent = (workspace)
		Wait(2);

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
	Description = "Grabs every dropped tool in game",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(workspace, "Tool") do 
			Humanoid:EquipTool(Tool);
		end 
	end,
})

Command.Add({
	Aliases = { "autograbtools", "agt" },
	Description = "Automatically grabs tools",
	Arguments = {},
	Task = function()
		Add("AutoGrab", true);
		Connect(workspace.DescendantAdded, function(Tool) 
			if (Tool:IsA("Tool") and Get("AutoGrab")) then 
				Humanoid:EquipTool(Tool);
				Tool.Parent = (Backpack);
			end
		end)

		return "Auto", "Auto Grab Tools enabled"
	end,
})

Command.Add({
	Aliases = { "unautograbtools", "unagt" },
	Description = "Stops the autograbtools command",
	Arguments = {},
	Task = function()
		Add("AutoGrab", false);
		return "Auto", "Auto Grab Tools disabled"
	end,
})

Command.Add({
	Aliases = { "grabdeletetools", "gdt" },
	Description = "Deletes every dropped tool in game",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(workspace, "Tool") do 
			Humanoid:EquipTool(Tool);
			Wait();
			Destroy(Tool);
		end 
	end,
})

Command.Add({
	Aliases = { "autograbdeletetools", "agdt" },
	Description = "Automatically grabs tools and deletes them",
	Arguments = {},
	Task = function()
		Add("AutoGrabDelete", true);
		Connect(workspace.DescendantAdded, function(Tool) 
			if (Tool:IsA("Tool") and Get("AutoGrabDelete")) then 
				Humanoid:EquipTool(Tool);
				Wait();
				Destroy(Tool);
			end
		end)

		return "Auto", "Auto Grab Delete Tools enabled"
	end,
})

Command.Add({
	Aliases = { "unautograbdeletetools", "unagdt" },
	Description = "Stops the autograbdeletetools command",
	Arguments = {},
	Task = function()
		Add("AutoGrabDelete", false);
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
	Description = "Set your new spawnpoint",
	Arguments = {},
	Task = function()
		local Old = (Root.CFrame);
		Refresh("SetSpawn", true);

		Detection = (Detection and Detection:Disconnect())

		Detection = Connect(LocalPlayer.CharacterAdded, function(NewCharacter)
			if Get("SetSpawn") then
				NewCharacter:WaitForChild("HumanoidRootPart").CFrame = (Old);
			end	
		end)

		return "Spawn", "Spawnpoint added"
	end,
})

Command.Add({
	Aliases = { "unsetspawn", "unss" },
	Description = "Deletes the spawnpoint you've saved",
	Arguments = {},
	Task = function()
		Refresh("SetSpawn", false);
		Detection = (Detection and Detection:Disconnect())

		return "Spawn", "Spawnpoint has been deleted"
	end,
})

Command.Add({
	Aliases = { "loadstring", "ls" },
	Description = "Runs whatever script you input",
	Arguments = {
		{ Name = "Script", Type = "String" }
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
		{ Name = "URL", Type = "String" }
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
	Description = "Makes your character fly",
	Arguments = {
		{ Name = "Speed", Type = "Number" }
	},
	Task = function(Amount)
		SetFly(true, tonumber(Amount) or 10);
		return "Fly", "Fly has been enabled"
	end,
})

Command.Add({
	Aliases = { "unfly" },
	Description = "Stops flying",
	Arguments = {},
	Task = function()
		SetFly(false);
		return "Fly", "Fly has been disabled"
	end,
})

Command.Add({
	Aliases = { "r6" },
	Description = "Shows a prompt changing your rig-type to R6",
	Arguments = {},
	Task = function()
		SetRig("R6")
	end,
})

Command.Add({
	Aliases = { "r15" },
	Description = "Shows a prompt changing your rig-type to R15",
	Arguments = {},
	Task = function()
		SetRig("R15")
	end,
})

Command.Add({
	Aliases = { "walkspeed", "ws" },
	Description = "Set your character's walkspeed",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		Humanoid.WalkSpeed = SetNumber(Amount);
		return "Walk speed", Format("Set walkspeed to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "jumppower", "jp" },
	Description = "Set your character's jump power",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		Humanoid.JumpPower = SetNumber(Amount);
		Humanoid.UseJumpPower = (true);
		return "Jump Power", Format("Set jump power to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "hipheight", "hh" },
	Description = "Set your character's hip height amount",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		Humanoid.HipHeight = SetNumber(Amount);
		return "Hip Height", Format("Set hip height to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "gravity" },
	Description = "Set the game's gravity",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		workspace.Gravity = SetNumber(Amount);
		return "Gravity", Format("Set gravity to %s", Amount)
	end,
})

Command.Add({
	Aliases = { "time" },
	Description = "Set the time of day",
	Arguments = {
		{ Name = "Time", Type = "Number" }
	},
	Task = function(Time)
		Services.Lighting.ClockTime = SetNumber(Time);
		return "Time", Format("Set time to %s", Time)
	end,
})

Command.Add({
	Aliases = { "airwalk", "aw" },
	Description = "Walk on air, jump to go up",
	Arguments = {},
	Task = function()
		local oldPart = Get("AirPart");
		local Part = Create("Part", {
			Transparency = 1,
			Size = Vector3.new(7, 2, 3),
			Parent = workspace,
			CanCollide = true,
			Anchored = true,
			Name = GenerateGUID(Services.Http),
		})

		Add("AirPart", Part)
		if oldPart then
			Destroy(oldPart)
		end

		while (Part and Wait()) do
			Part.CFrame = Root.CFrame + Vector3.new(0, -4, 0)
		end
	end,
})

Command.Add({
	Aliases = { "unairwalk", "unaw" },
	Description = "Stops the airwalk command",
	Arguments = {},
	Task = function()
		Destroy(Get("AirPart"))

		return "Air Walk", "Disabled air walk"
	end,
})

Command.Add({
	Aliases = { "show" },
	Description = "Shows all the invisible parts in-game",
	Arguments = {},
	Task = function()
		Refresh("Hidden", {})
		for Index, Wall in next, GetClasses(workspace, "BasePart") do
			if (Wall.Transparency == 1) and (Wall.Name ~= "HumanoidRootPart") then
				Insert(Get("Hidden"), Wall)
				Wall.Transparency = (0)
			end
		end

		return "Show", "Showing all invisible walls"
	end,
})

Command.Add({
	Aliases = { "hide" },
	Description = "Undoes the show command",
	Arguments = {},
	Task = function()
		for Index, Wall in next, Get("Hidden") do
			Wall.Transparency = (1)
		end

		return "Hide", "Hidden all previously shown walls"
	end,
})

Command.Add({
	Aliases = { "teamchange", "teamc" },
	Description = "Any spawn location that changes your team gets touched",
	Arguments = {},
	Task = function()
		local OldPosition = (Root.CFrame);
		local FoundCheckpoints = (0);

		for Index, Point in next, GetClasses(workspace, "SpawnLocation") do
			if Point.AllowTeamChangeOnTouch then 
				Root.CFrame = (Point.CFrame);
				FoundCheckpoints += 1
				Wait(.1);
			end
		end

		Root.CFrame = (OldPosition);
		return "Team Change", Format("Touched %s spawn locations with TeamChange enabled", FoundCheckpoints), 10
	end,
})

Command.Add({
	Aliases = { "droptools", "dp" },
	Description = "Drops every tool",
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
	Description = "Repeatedly drops tools and respawns",
	Arguments = {},
	Task = function()
		local OldPosition = Root.CFrame
		Refresh("LoopDrop", true);

		local Drop = function(Char) 
			if Get("LoopDrop") then 
				repeat Wait() until Root
				for Index = 1, 5 do 
					Root.CFrame = OldPosition 
					Wait(.1)
				end

				for Index, Tool in next, GetClasses(Backpack, "Tool", true) do
					Tool.Parent = Character 
					Tool.Parent = workspace
				end

				Humanoid.Health = (0);
			end
		end

		Drop(Character)
		Connect(LocalPlayer.CharacterAdded, Drop)
	end,
})

Command.Add({
	Aliases = { "unloopdroptools", "unldp" },
	Description = "Stops the loopdroptools command",
	Arguments = {},
	Task = function()
		Refresh("LoopDrop", false);
	end,
})

Command.Add({
	Aliases = { "savetools", "st" },
	Description = "Drops all your tools in the sky, type loadtools to get them back",
	Arguments = {},
	Task = function()
		local OldPosition = Root.CFrame

		Root.CFrame = CFrame.new(0, 9e9, 0); Wait(1)
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
	Description = "Gets all the tools you saved",
	Arguments = {},
	Task = function()
		for Index, Tool in next, GetClasses(workspace, "Tool", true) do
			Humanoid:EquipTool(Tool);
		end
	end,
})

Command.Add({
	Aliases = { "spazz" },
	Description = "Similiar to spin",
	Arguments = {},
	Task = function()
		if Spazz then
			Destroy(Spazz)
		end

		Root.CFrame = Root.CFrame * CFrame.Angles(-0.3, 0, 0);
		Spazz = Create("BodyAngularVelocity", {
			P = 200000,
			AngularVelocity = Vector3.new(0, 15, 0),
			MaxTorque = Vector3.new(200000, 200000, 200000),
			Parent = Root
		})
	end,
})

Command.Add({
	Aliases = { "unspazz" },
	Description = "Stops the spazz command",
	Arguments = {},
	Task = function()
		if Spazz then
			Destroy(Spazz);
		end
	end,
})

Command.Add({
	Aliases = { "lockmouse", "lm" },
	Description = "Locks your mouse in the center",
	Arguments = {},
	Task = function()
		Refresh("MouseLock", true);

		repeat Wait();
			Services.Input.MouseBehavior = (Enum.MouseBehavior.LockCenter);
		until not Get("MouseLock")
	end,
})

Command.Add({
	Aliases = { "unlockmouse", "unlm" },
	Description = "Makes your mouse not locked in the center",
	Arguments = {},
	Task = function()
		Refresh("MouseLock", false);
		Services.Input.MouseBehavior = (Enum.MouseBehavior.Default);
	end,
})

Command.Add({
	Aliases = { "spin" },
	Description = "Spins your character",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		if Spin then
			Destroy(Spin);
		end

		Spin = Create("BodyAngularVelocity", {
			Parent = Root,
			MaxTorque = Vector3.new(0, 9e9, 0),
			AngularVelocity = Vector3.new(0, SetNumber(Amount), 0)
		})
	end,
})

Command.Add({
	Aliases = { "unspin" },
	Description = "Stops spinning your character",
	Arguments = {},
	Task = function()
		Destroy(Spin)
	end,
})

Command.Add({
	Aliases = { "noclip", "nc" },
	Description = "Lets your character go through walls",
	Arguments = {},
	Task = function()
		Refresh("Noclip", true);

		API:Notify({
			Title = "Noclip",
			Description = "Noclip has been enabled",
		})

		repeat Wait();
			for Index, Part in next, GetClasses(Character, "BasePart", true) do
				Part.CanCollide = (false);
			end
		until not Get("Noclip")
	end,
})

Command.Add({
	Aliases = { "unnoclip", "clip", "c" },
	Description = "Stops the noclip command",
	Arguments = {},
	Task = function()
		Refresh("Noclip", false);

		for Index, Part in next, GetClasses(Character, "BasePart", true) do
			Part.CanCollide = (false);
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
			Part.Anchored = (true)
		end
	end,
})

Command.Add({
	Aliases = { "unfreeze", "unfr" },
	Description = "Unfreezes your character",
	Arguments = {},
	Task = function()
		for Index, Part in next, Character:GetChildren() do
			if Part:IsA("BasePart") then
				Part.Anchored = (false)
			end
		end
	end,
})

Command.Add({
	Aliases = { "animationspeed", "animspeed" },
	Description = "Set your own animation speed",
	Arguments = {
		{ Name = "Speed", Type = "Number" }
	},
	Task = function(Amount)
		local Amount = SetNumber(Amount, 2, math.huge);	

		Add("AnimationSpeed", true);
		API:Notify({
			Title = "Animation Speed",
			Description = Format("Set animation speed to %s", Amount)
		})

		repeat Wait()
			for Index, Track in next, Humanoid:GetPlayingAnimationTracks() do
				Track:AdjustSpeed(Amount)
			end
		until not Get("AnimationSpeed")
	end,
})

Command.Add({
	Aliases = { "unanimationspeed", "unanimspeed" },
	Description = "Sets your animation speed back to normal",
	Arguments = {
		{ Name = "Speed", Type = "Number" }
	},
	Task = function(Amount)
		Refresh("AnimationSpeed", false);
		for Index, Track in next, Humanoid:GetPlayingAnimationTracks() do
			Track:AdjustSpeed(Amount)
		end

		return "Animation Speed", "Set animation speed back to normal"
	end,
})

Command.Add({
	Aliases = { "freezeanimations", "fan" },
	Description = "Freezes your animations in place",
	Arguments = {},
	Task = function()
		Character.Animate.Disabled = (true)
	end,
})

Command.Add({
	Aliases = { "unfreezeanimations", "unfan" },
	Description = "Unfreezes your animations",
	Arguments = {},
	Task = function()
		Character.Animate.Disabled = (false)
	end,
})

Command.Add({
	Aliases = { "nodelay" },
	Description = "Removes the delay from ProximityPrompts",
	Arguments = {},
	Task = function()
		for Index, Proximity in next, GetClasses(workspace, "ProximityPrompt") do
			Proximity.HoldDuration = (0);
		end

		return "No Delay", "Proximity Prompt delay has been set to 0"
	end,
})

Command.Add({
	Aliases = { "firetouchinterests", "fti" },
	Description = "Fires every touch interest in-game",
	Arguments = {},
	Task = function()
		local Fired = 0
		if not firetouchinterest then 
			return "Missing Function", "Executor does not support this command, missing function - firetouchinterest", 10
		end

		for Index, Target in next, GetClasses(workspace, "TouchTransmitter") do
			firetouchinterest(Root, Target.Parent, 0);
			firetouchinterest(Root, Target.Parent, 1);
			Fired += 1
		end

		return "Fired", Format("Fired %s touch interests", Fired)
	end,
})

Command.Add({
	Aliases = { "fireproximityprompts", "fpp" },
	Description = "Fires every proximity prompt in-game",
	Arguments = {},
	Task = function()
		local Fired = 0
		if not fireproximityprompt then 
			return "Missing Function", "Executor does not support this command, missing function - fireproximityprompt", 10
		end

		for Index, Target in next, GetClasses(workspace, "ProximityPrompt") do
			fireproximityprompt(Target, 0);
			Wait()
			fireproximityprompt(Target, 1);
			Fired += 1
		end

		return "Fired", Format("Fired %s proximity prompts", Fired)
	end,
})

Command.Add({
	Aliases = { "fireclickdetectors", "fcd" },
	Description = "Fires every click detector in-game",
	Arguments = {},
	Task = function()
		local Fired = 0
		if not fireclickdetector then 
			return "Missing Function", "Executor does not support this command, missing function - fireclickdetector", 10
		end

		for Index, Target in next, GetClasses(workspace, "ClickDetector") do
			fireclickdetector(Target);
			Fired += 1
		end

		return "Fired", Format("Fired %s click detectors", Fired)
	end,
})

Command.Add({
	Aliases = { "showprompts" },
	Description = "Shows purchase prompts",
	Arguments = {},
	Task = function()
		MultiSet(Services.Core.PurchasePrompt, {
			Enabled = true
		})

		return "Prompts", "Showing purchase prompts"
	end,
})

Command.Add({
	Aliases = { "hideprompts" },
	Description = "Hides any purchase prompts that get shown",
	Arguments = {},
	Task = function()
		MultiSet(Services.Core.PurchasePrompt, {
			Enabled = false
		})

		return "Prompts", "Hiding purchase prompts"
	end,
})

Command.Add({
	Aliases = { "getplayer" },
	Description = "gets players (testing)",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		local Targets = GetPlayer(Input)
		return Format("Got %s players", #Targets), Input
	end,
})

Command.Add({
	Aliases = { "hitbox", "hb" },
	Description = "Set the hitbox size for your target",
	Arguments = {
		{ Name = "Target", Type = "Player" },
		{ Name = "Amount", Type = "Number" },
	},
	Task = function(Input, Amount)
		Add("Hitbox", true);
		repeat Wait();
			for Index, Target in next, GetPlayer(Input) do 
				local TRoot = GetRoot(Target);
				local S = (Amount and SetNumber(Amount, 5)) or 10

				if TRoot and Target ~= LocalPlayer then 
					TRoot.Size = Vector3.new(S, S, S);
					TRoot.Transparency = (0.8);
					TRoot.CanCollide = (false);
				end
			end
		until not Get("Hitbox");
	end,
})

Command.Add({
	Aliases = { "unhitbox", "unhb" },
	Description = "Undoes the hitbox command",
	Arguments = {},
	Task = function()
		Refresh("Hitbox", false);

		for Index, Target in next, GetPlayer("all") do 
			local TRoot = GetRoot(Target);

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
		Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer);
	end,
})

Command.Add({
	Aliases = { "infinitejump", "infjump" },
	Description = "Lets you jump in the air",
	Arguments = {},
	Task = function()
		local Old = Get("InfiniteJump")
		Old = Old and Old:Disconnect()
		Add("InfiniteJump", Connect(Services.Input.InputBegan, function(Key, FocusedTextbox) 
			if (Key.KeyCode == Enum.KeyCode.Space) and (not FocusedTextbox) then
				Humanoid:ChangeState("Jumping")
				Wait()
				Humanoid:ChangeState("Seated")
			end
		end));

		return "Infinite Jump", "Enabled"
	end,
})

Command.Add({
	Aliases = { "uninfinitejump", "uninfjump" },
	Description = "Disables infinite jump",
	Arguments = {},
	Task = function()
		local Old = Get("InfiniteJump")
		Old = Old and Old:Disconnect()
		return "Infinite Jump", "Disabled"
	end,
})

Command.Add({
	Aliases = { "massplay" },
	Description = "Uses every radio in your inventory",
	Arguments = {
		{ Name = "Audio ID", Type = "String" }
	},
	Task = function(ID)
		for Index, Boombox in next, GetClasses(Backpack, "Tool", true) do
			local Name = Lower(Boombox.Name);
			if (Name == "radio" or Name == "boombox") and (Boombox:FindFirstChild("Remote")) then
				Boombox.Parent = (Character);
				Boombox.Remote:FireServer("PlaySong", ID)
			end
		end

		return "Mass Play", Format("Mass playing ID: %s", ID)
	end,
})

Command.Add({
	Aliases = { "getaudio", "ga" },
	Description = "Gets the audio id of your target's boombox",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Target)
		for Index, Boombox in next, GetClasses(GetPlayer(Target)[1].Character, "Tool", true) do
			local Name = Lower(Boombox.Name);
			if (Name == "radio" or Name == "boombox") and (Boombox:FindFirstChild("Handle")) then
				local AudioID = Boombox.Handle:FindFirstChildOfClass("Sound").SoundId;
				return "Audio Logged", AudioID, 20
			end
		end

		return "Audio Logger", "Audio not found"
	end,
})

Command.Add({
	Aliases = { "mute" },
	Description = "Mutes your target's BoomBox",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		if RespectFilteringEnabled then
			return "Mute", "Couldn't mute since RespectFilteringEnabled is enabled"
		end

		for Index, Target in next, GetPlayer(Input) do
			local Character = GetCharacter(Target);

			if Character then 
				for Index, Sound in next, GetClasses(Character, "Sound") do 
					Sound.Playing = (false);
				end
			end
		end

		return "Mute", "Successfully muted the target(s)"
	end,
})

Command.Add({
	Aliases = { "glitch" },
	Description = "Glitches your target's BoomBox",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		Add("Glitch", true);
		if RespectFilteringEnabled then
			return "Glitch", "Couldn't glitch since RespectFilteringEnabled is enabled"
		end

		repeat Wait(); 
			for Index, Target in next, GetPlayer(Input) do
				local Character = GetCharacter(Target);

				if Character then 
					for Index, Sound in next, GetClasses(Character, "Sound") do 
						Sound.Playing = (true);
						Wait(.2)
						Sound.Playing = (false);
					end
				end
			end
		until not Get("Glitch");
	end,
})

Command.Add({
	Aliases = { "unglitch" },
	Description = "Stops the glitch command",
	Arguments = {},
	Task = function()
		Refresh("Glitch", false);
		return "Glitch", "Glitch has been disabled"
	end,
})

Command.Add({
	Aliases = { "noaudio" },
	Description = "Mutes the game",
	Arguments = {},
	Task = function()
		for Index, Audio in next, GetClasses(game, "Sound") do 
			Audio.Playing = (false);
		end 
		return "No Audio", "Muted the game"
	end,
})

Command.Add({
	Aliases = { "audio" },
	Description = "Unmutes the game",
	Arguments = {},
	Task = function()
		for Index, Audio in next, GetClasses(game, "Sound") do 
			Audio.Playing = (true);
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
		Add("ClientBring", true);

		repeat Wait();
			for Index, Target in next, GetPlayer(Input) do 
				local TRoot = GetRoot(Target);

				if TRoot then 
					TRoot.CFrame = Root.CFrame * CFrame.new(0, 0, (Distance and -SetNumber(Distance)) or -3)
				end
			end
		until not Get("ClientBring");
	end,
})

Command.Add({
	Aliases = { "unclientbring", "uncbring" },
	Description = "Stops the client bring command",
	Arguments = {},
	Task = function()
		Refresh("ClientBring", false);
	end,
})

Command.Add({
	Aliases = { "controllock", "ctrllock", "ctl" },
	Description = "Sets the Shift Lock keybinds to the Control keys",
	Arguments = {},
	Task = function()
		local Bound = (LocalPlayer.PlayerScripts.PlayerModule.CameraModule.MouseLockController.BoundKeys);
		Bound.Value = "LeftControl, RightControl"
		return "Control Lock", "Set the shiftlock keybind to Control"
	end,
})

Command.Add({
	Aliases = { "goto", "to" },
	Description = "Teleports you to the target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		Root.CFrame = GetRoot(GetPlayer(Input)[1]).CFrame
	end,
})

Command.Add({
	Aliases = { "tickgoto", "tgoto", "tto" },
	Description = "Teleports you to the target for a specific amount of time",
	Arguments = {
		{ Name = "Target", Type = "Player" },
		{ Name = "Seconds", Type = "Number" },
	},
	Task = function(Input, Time)
		local OldPosition = (Root.CFrame);
		Root.CFrame = GetRoot(GetPlayer(Input)[1]).CFrame
		Wait(SetNumber(Time));
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
		local OldPosition = (Root.CFrame);
		Root.CFrame = GetRoot(GetPlayer(Input)[1]).CFrame
		Wait(1);
		Root.CFrame = OldPosition
	end,
})

Command.Add({
	Aliases = { "error" },
	Description = "Sends an error in chat (LEGACY CHAT ONLY)",
	Arguments = {},
	Task = function()
		for Index = 1, 3 do
			Chat("\0");
		end
	end,
})

Command.Add({
	Aliases = { "vehiclegoto", "vgoto", "vto" },
	Description = "Teleports your vehicle to the target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		Humanoid.SeatPart:FindFirstAncestorOfClass("Model"):PivotTo(
		GetRoot(GetPlayer(Input)[1]).CFrame
		)
	end,
})

Command.Add({
	Aliases = { "vehiclespeed", "vspeed", "vsp" },
	Description = "Set the speed of your car",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Task = function(Amount)
		local n = SetNumber(Amount);

		VehicleSpeed = (VehicleSpeed and VehicleSpeed:Disconnect());
		VehicleSpeed = Connect(Services.Run.Stepped, function() 
			local SeatPart = (Humanoid.SeatPart);

			if SeatPart then 
				SeatPart:ApplyImpulse(SeatPart.CFrame.LookVector * Vector3.new(n, n, n));
			end
		end)
	end,
})

Command.Add({
	Aliases = { "unvehiclespeed", "unvspeed", "unvsp" },
	Description = "Disables the vehiclespeed command",
	Arguments = {},
	Task = function()
		VehicleSpeed = (VehicleSpeed and VehicleSpeed:Disconnect());
	end,
})

Command.Add({
	Aliases = { "seat" },
	Description = "Makes you sit in a seat",
	Arguments = {},
	Task = function()
		for Index, Seat in next, GetClasses(workspace, "Seat") do 
			Seat:Sit(Humanoid); break
		end
	end,
})

Command.Add({
	Aliases = { "vehicleseat", "vseat" },
	Description = "Makes you sit in a vehicle",
	Arguments = {},
	Task = function()
		for Index, Seat in next, GetClasses(workspace, "VehicleSeat") do 
			Seat:Sit(Humanoid); break
		end
	end,
})


Command.Add({
	Aliases = { "admin", "whitelist", "wl" },
	Description = "Whitelist a target to be able to use Cmd's Commands",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		for Index, Admin in next, GetPlayer(Input) do
			Command.Whitelist(Admin) 
			Chat(Format('/w %s You are now whitelisted to COCOS POV ADMIn, prefix is "%s"', Admin.Name, Settings.ChatPrefix))
		end
	end,
})

Command.Add({
	Aliases = { "unadmin", "unwhitelist", "unwl" },
	Description = "Removes your target's whitelist",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		for Index, Admin in next, GetPlayer(Input) do
			if Admins[Admin.UserId] then 
				Command.RemoveWhitelist(Admin) 
				Chat(Format('/w %s You are no longer an admin!', Admin.Name))
			end
		end
	end,
})

Command.Add({
	Aliases = { "follow", "flw" },
	Description = "Follows your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		Refresh("Follow", true);

		repeat Wait();
			Humanoid:MoveTo(
				GetRoot(GetPlayer(Input)[1]).Position
			)
		until not Get("Follow");
	end,
})

Command.Add({
	Aliases = { "unfollow", "unflw" },
	Description = "Stops the follow command",
	Arguments = {},
	Task = function()
		Refresh("Follow", false);
	end,
})

Command.Add({
	Aliases = { "clicktp", "ctp" },
	Description = "Click to teleport to where your mouse is located",
	Arguments = {},
	Task = function()
		Refresh("ClickTP", true);
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
	Description = "Disables the Click TP command",
	Arguments = {},
	Task = function()
		Refresh("ClickTP", false);
		return "Click TP", "Click TP has been disabled"
	end,
})

Command.Add({
	Aliases = { "stare" },
	Description = "Stares at the target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		local Target = GetPlayer(Input)[1]
		Refresh("Stare", true);

		repeat Wait();
			local TRoot = GetRoot(Target).Position
			Root.CFrame = CFrame.new(Root.Position, Vector3.new(TRoot.X, Root.Position.y, TRoot.Z))
		until not Get("Stare");
	end,
})

Command.Add({
	Aliases = { "unstare" },
	Description = "Undoes the stare command",
	Arguments = {},
	Task = function()
		Refresh("Stare", false);
	end,
})

Command.Add({
	Aliases = { "lay" },
	Description = "Makes you lay",
	Arguments = {},
	Task = function()
		Humanoid.Sit = (true);
		Root.CFrame = Root.CFrame * CFrame.Angles(1.5, 0, 0); Wait(.1);
		for Index, Track in next, Humanoid:GetPlayingAnimationTracks() do 
			Track:Stop() 
		end
	end,
})

Command.Add({
	Aliases = { "autorejoin", "autorj", "arj" },
	Description = "Automatically rejoins if you get kicked",
	Arguments = {},
	Task = function()
		Add("AutoRejoin", true);
		Connect(GetService("GuiService").ErrorMessageChanged, function()
			if Get("AutoRejoin") then
				Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId);
			end
		end)
		return "Auto Rejoin", "Auto Rejoin enabled"
	end,
})

Command.Add({
	Aliases = { "unautorejoin", "unautorj", "unarj" },
	Description = "Disables the autorejoin command",
	Arguments = {},
	Task = function()
		Add("AutoRejoin", false);
		return "Auto Rejoin", "Auto Rejoin disabled"
	end,
})

Command.Add({
	Aliases = { "friend" },
	Description = "Sends a friend request to the target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		local Sent = 0
		for Index, Target in next, GetPlayer(Input) do
			if Target ~= LocalPlayer then 
				LocalPlayer:RequestFriendship(Target);
				Sent += 1
			end
		end
		return "Friend", Format("Sent friend request to %s player(s)", Sent)
	end,
})

Command.Add({
	Aliases = { "listen", "spy" },
	Description = "Listen to someone's voice chat convo",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		local Targets = GetPlayer(Input);
		local Roots = {}

		for Index, Target in next, Targets do 
			Roots[#Roots + 1] = GetRoot(Target); -- listen to more than one person 
		end

		Services.Sound:SetListener(Enum.ListenerType.ObjectPosition, Unpack(Roots));
		return "Listen", Format("Listening to %s player(s)", #Roots)
	end,
})

Command.Add({
	Aliases = { "view", "spectate" },
	Description = "View your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		local Target = GetPlayer(Input)[1]
		Refresh("View", true)

		repeat Wait() 
			Camera.CameraSubject = GetHumanoid(Target)
		until not Get("View")
	end,
})

Command.Add({
	Aliases = { "unview", "unspectate" },
	Description = "Undoes the view command",
	Arguments = {},
	Task = function()
		Refresh("View", false)
		Camera.CameraSubject = (Humanoid)
	end,
})

Command.Add({
	Aliases = { "freecam", "fc" },
	Description = "Enables & Disables Freecam",
	Arguments = {},
	Task = function()
		if not Freecam then 
			Freecam = {}
			local pi    = math.pi
			local abs   = math.abs
			local clamp = math.clamp
			local exp   = math.exp
			local rad   = math.rad
			local sign  = math.sign
			local sqrt  = math.sqrt
			local tan   = math.tan

			Connect(Changed(workspace, "CurrentCamera"), function()
				local newCamera = workspace.CurrentCamera
				if newCamera then
					Camera = newCamera
				end
			end)

			local TOGGLE_INPUT_PRIORITY = Enum.ContextActionPriority.Low.Value
			local INPUT_PRIORITY = Enum.ContextActionPriority.High.Value
			local FREECAM_MACRO_KB = {Enum.KeyCode.LeftShift, Enum.KeyCode.P}

			local NAV_GAIN = Vector3.new(1, 1, 1)*64
			local PAN_GAIN = Vector2.new(0.75, 1)*8
			local FOV_GAIN = 300

			local PITCH_LIMIT = rad(90)

			local VEL_STIFFNESS = 10
			local PAN_STIFFNESS = 10
			local FOV_STIFFNESS = 10

			local Spring = {} do
				Spring.__index = Spring

				function Spring.new(freq, pos)
					local self = setmetatable({}, Spring)
					self.f = freq
					self.p = pos
					self.v = pos*0
					return self
				end

				function Spring:Update(dt, goal)
					local f = self.f*2*pi
					local p0 = self.p
					local v0 = self.v

					local offset = goal - p0
					local decay = exp(-f*dt)

					local p1 = goal + (v0*dt - offset*(f*dt + 1))*decay
					local v1 = (f*dt*(offset*f - v0) + v0)*decay

					self.p = p1
					self.v = v1

					return p1
				end

				function Spring:Reset(pos)
					self.p = pos
					self.v = pos*0
				end
			end

			local cameraPos = Vector3.new()
			local cameraRot = Vector2.new()
			local cameraFov = 0

			local velSpring = Spring.new(VEL_STIFFNESS, Vector3.new())
			local panSpring = Spring.new(PAN_STIFFNESS, Vector2.new())
			local fovSpring = Spring.new(FOV_STIFFNESS, 0)

			local Input = {} do
				local thumbstickCurve do
					local K_CURVATURE = 2.0
					local K_DEADZONE = 0.15

					local function fCurve(x)
						return (exp(K_CURVATURE*x) - 1)/(exp(K_CURVATURE) - 1)
					end

					local function fDeadzone(x)
						return fCurve((x - K_DEADZONE)/(1 - K_DEADZONE))
					end

					function thumbstickCurve(x)
						return sign(x)*clamp(fDeadzone(abs(x)), 0, 1)
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

				local NAV_GAMEPAD_SPEED  = Vector3.new(1, 1, 1)
				local NAV_KEYBOARD_SPEED = Vector3.new(1, 1, 1)
				local PAN_MOUSE_SPEED    = Vector2.new(1, 1)*(pi/64)
				local PAN_GAMEPAD_SPEED  = Vector2.new(1, 1)*(pi/8)
				local FOV_WHEEL_SPEED    = 1.0
				local FOV_GAMEPAD_SPEED  = 0.25
				local NAV_ADJ_SPEED      = 0.75
				local NAV_SHIFT_MUL      = 0.25

				local navSpeed = 1

				function Input.Vel(dt)
					navSpeed = clamp(navSpeed + dt*(keyboard.Up - keyboard.Down)*NAV_ADJ_SPEED, 0.01, 4)

					local kGamepad = Vector3.new(
						thumbstickCurve(gamepad.Thumbstick1.X),
						thumbstickCurve(gamepad.ButtonR2) - thumbstickCurve(gamepad.ButtonL2),
						thumbstickCurve(-gamepad.Thumbstick1.Y)
					)*NAV_GAMEPAD_SPEED

					local kKeyboard = Vector3.new(
						keyboard.D - keyboard.A + keyboard.K - keyboard.H,
						keyboard.E - keyboard.Q + keyboard.I - keyboard.Y,
						keyboard.S - keyboard.W + keyboard.J - keyboard.U
					)*NAV_KEYBOARD_SPEED

					local shift = Services.Input:IsKeyDown(Enum.KeyCode.LeftShift) or Services.Input:IsKeyDown(Enum.KeyCode.RightShift)

					return (kGamepad + kKeyboard)*(navSpeed*(shift and NAV_SHIFT_MUL or 1))
				end

				function Input.Pan(dt)
					local kGamepad = Vector2.new(
						thumbstickCurve(gamepad.Thumbstick2.Y),
						thumbstickCurve(-gamepad.Thumbstick2.X)
					)*PAN_GAMEPAD_SPEED
					local kMouse = mouse.Delta*PAN_MOUSE_SPEED
					mouse.Delta = Vector2.new()
					return kGamepad + kMouse
				end

				function Input.Fov(dt)
					local kGamepad = (gamepad.ButtonX - gamepad.ButtonY)*FOV_GAMEPAD_SPEED
					local kMouse = mouse.MouseWheel*FOV_WHEEL_SPEED
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
							t[k] = v*0
						end
					end

					function Input.StartCapture()
						Services.ContextActionService:BindActionAtPriority("FreecamKeyboard", Keypress, false, INPUT_PRIORITY,
							Enum.KeyCode.W, Enum.KeyCode.U,
							Enum.KeyCode.A, Enum.KeyCode.H,
							Enum.KeyCode.S, Enum.KeyCode.J,
							Enum.KeyCode.D, Enum.KeyCode.K,
							Enum.KeyCode.E, Enum.KeyCode.I,
							Enum.KeyCode.Q, Enum.KeyCode.Y,
							Enum.KeyCode.Up, Enum.KeyCode.Down
						)
						Services.ContextActionService:BindActionAtPriority("FreecamMousePan",          MousePan,   false, INPUT_PRIORITY, Enum.UserInputType.MouseMovement)
						Services.ContextActionService:BindActionAtPriority("FreecamMouseWheel",        MouseWheel, false, INPUT_PRIORITY, Enum.UserInputType.MouseWheel)
						Services.ContextActionService:BindActionAtPriority("FreecamGamepadButton",     GpButton,   false, INPUT_PRIORITY, Enum.KeyCode.ButtonX, Enum.KeyCode.ButtonY)
						Services.ContextActionService:BindActionAtPriority("FreecamGamepadTrigger",    Trigger,    false, INPUT_PRIORITY, Enum.KeyCode.ButtonR2, Enum.KeyCode.ButtonL2)
						Services.ContextActionService:BindActionAtPriority("FreecamGamepadThumbstick", Thumb,      false, INPUT_PRIORITY, Enum.KeyCode.Thumbstick1, Enum.KeyCode.Thumbstick2)
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
				local projy = 2*tan(cameraFov/2)
				local projx = viewport.x/viewport.y*projy
				local fx = cameraFrame.rightVector
				local fy = cameraFrame.upVector
				local fz = cameraFrame.lookVector

				local minVect = Vector3.new()
				local minDist = 512

				for x = 0, 1, 0.5 do
					for y = 0, 1, 0.5 do
						local cx = (x - 0.5)*projx
						local cy = (y - 0.5)*projy
						local offset = fx*cx - fy*cy + fz
						local origin = cameraFrame.p + offset*znear
						local _, hit = workspace:FindPartOnRay(Ray.new(origin, offset.unit*minDist))
						local dist = (hit - origin).magnitude
						if minDist > dist then
							minDist = dist
							minVect = offset.unit
						end
					end
				end

				return fz:Dot(minVect)*minDist
			end

			local function StepFreecam(dt)
				local vel = velSpring:Update(dt, Input.Vel(dt))
				local pan = panSpring:Update(dt, Input.Pan(dt))
				local fov = fovSpring:Update(dt, Input.Fov(dt))

				local zoomFactor = sqrt(tan(rad(70/2))/tan(rad(cameraFov/2)))

				cameraFov = clamp(cameraFov + fov*FOV_GAIN*(dt/zoomFactor), 1, 120)
				cameraRot = cameraRot + pan*PAN_GAIN*(dt/zoomFactor)
				cameraRot = Vector2.new(clamp(cameraRot.x, -PITCH_LIMIT, PITCH_LIMIT), cameraRot.y%(2*pi))

				local cameraCFrame = CFrame.new(cameraPos)*CFrame.fromOrientation(cameraRot.x, cameraRot.y, 0)*CFrame.new(vel*NAV_GAIN*dt)
				cameraPos = cameraCFrame.p

				Camera.CFrame = cameraCFrame
				Camera.Focus = cameraCFrame*CFrame.new(0, 0, -GetFocusDistance(cameraCFrame))
				Camera.FieldOfView = cameraFov
			end

			local PlayerState = {} do
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
				if FreecamEnabled then  -- check mostly for freecamto
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
	Description = "Teleports your freecam to the target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Target)
		Freecam:EnableFreecam(GetRoot(GetPlayer(Target)[1]).CFrame)
	end,
})

Command.Add({
	Aliases = { "freecambring", "fcbr" },
	Description = "Brings your character to the freecam camera position",
	Arguments = {},
	Task = function()
		Root.CFrame = Camera.CFrame
	end,
})

Command.Add({
	Aliases = { "walkfling", "wf" },
	Description = "Fling without spinning",
	Arguments = {
		{ Name = "Distance", Type = "Number" }
	},
	Task = function(Distance)
		Refresh("Walkfling", true);
		Spawn(function() 
			local NormalVelocity = Root.Velocity
			local Velocity = Root.Velocity

			repeat Wait();
				if GetPlayer("closest")[1]:DistanceFromCharacter(Root.Position) <= 
					(Distance and SetNumber(Distance, 0, 9e9) or 10) then 
					Velocity = (Root.Velocity)
					Root.Velocity = (Velocity * 10000) + Vector3.new(0, 10000, 0)
					CWait(Services.Run.RenderStepped)
					Root.Velocity = (Velocity)
				end
			until not Get("Walkfling")
		end)
		return "Walk Fling", "Walk Fling has been enabled"
	end,
})

Command.Add({
	Aliases = { "unwalkfling", "unwf" },
	Description = "Disables walkfling",
	Arguments = {},
	Task = function()
		Refresh("Walkfling", false);
		return "Walk Fling", "Walk Fling has been disabled"
	end,
})

Command.Add({
	Aliases = { "resetfilter", "ref" },
	Description = "If Roblox keeps tagging your messages, run this to reset the filter",
	Arguments = {},
	Task = function()
		for Index = 1, 3 do
			Services.Players:Chat(Format("/e hi")) -- crazy stuff...
		end
		return "Filter", "Reset"
	end,
})

Command.Add({
	Aliases = { "split" },
	Description = "Splits a string in half, resets the filter during that too",
	Arguments = {
		{ Name = "First Split", Type = "String" },
		{ Name = "Second Split", Type = "String" },     
	},
	Task = function(First, Second)
		if First and Second then
			Command.Parse(true, "ref"); Wait(.2); Chat(First);
			Command.Parse(true, "ref"); Wait(.5); Chat(Second)
		else
			return "Split", "One or more arguments are missing"
		end
	end,
})

Command.Add({
	Aliases = { "fling" },
	Description = "Flings your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		local Targets = GetPlayer(Input)
		if #Targets == 0 then
			return "Fling", "No targets found"
		end

		local Successes = Fling(Targets)
		return "Fling", Format("Successfully flinged (%s/%s) player(s)", Successes, #Targets)
	end,
})

Command.Add({
	Aliases = { "loopfling", "lf" },
	Description = "Flings your target repeatedly",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Task = function(Input)
		Refresh("Fling", true);
		repeat Fling(GetPlayer(Input))
		until not Get("Fling")
	end,
})

Command.Add({
	Aliases = { "unloopfling", "unlf" },
	Description = "Stops the loopfling command",
	Arguments = {},
	Task = function()
		Add("Fling", false);
	end,
})

Command.Add({
	Aliases = { "clickfling", "cf" },
	Description = "Click on the target you want to fling",
	Arguments = {},
	Task = function()
		local Connection = Get("Clickfling")
		Connection = (Connection and Connection:Disconnect())
		Add("Clickfling", Connect(Mouse.Button1Down, function() 
			local Target = Mouse.Target 
			local Model = Target:FindFirstAncestorOfClass("Model")
			local isPlayer = Services.Players:GetPlayerFromCharacter(Model);

			if isPlayer then 
				Fling({ isPlayer })
			end
		end));
		return "Clickfling", "Enabled"
	end,
})

Command.Add({
	Aliases = { "unclickfling", "uncf" },
	Description = "Stops the clickfling command",
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
			return API:Notify(Config);
		end,
	}

	for Index, File in next, listfiles("Cmd/Plugins") do
		local Success, Plugin = pcall(function() 
			LoadedPlugins += 1
			return loadfile(File)();
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
				Duration = (15),
				Type = "Warn",
			})
		end
	end
end

--// Autofill & Recommendation
for Index, Command in next, Commands do
	Fill.Add(Command);
end

Connect(Changed(Input, "Text"), function() 
	Fill.Search(Input.Text);
	Fill.Recommend(Input.Text);
end)

Connect(Services.Input.InputBegan, function(Key) 
	if Key.KeyCode == Enum.KeyCode.Tab and Press.Title.Text == ("Tab") and Services.Input:GetFocusedTextBox() == Input then
		local Text = Recommend.Text
		Wait();
		Input.Text = Text 
		Input.CursorPosition = #Text + 1;
	end
end)

--// Command Bar
local ChatDebounce = (false); --// for some reason chatted fires twice because of the chat bubble LOL

Connect(LocalPlayer.Chatted, function(Message) 
	if not ChatDebounce and Find(Message, Settings.ChatPrefix) then 
		ChatDebounce = (true);
		Command.Parse(false, Split(Message, Settings.ChatPrefix)[2]);
		Wait()
		ChatDebounce = (false);
	end
end)

Connect(Mouse.KeyDown, function(Key) 
	if Lower(Key) == Lower(Settings.Prefix) then
		local Transparency = (Settings.Theme.Transparency)
		local Padding = CommandBar.Parent:FindFirstChildOfClass("UIPadding")
		Wait();

		Input:CaptureFocus();
		BarShadow.Transparency = 1
		Padding.PaddingTop = UDim.new(0, -5)

		MultiSet(CommandBar, {
			GroupTransparency = 1,
			Visible = true,
			Position = UDim2.new(.5, 0, .5, -9);
		})

		Tween(BarShadow, .2, { Transparency = .9 });
		Tween(Padding, .2, { PaddingTop = UDim.new(0, 0) })
		Tween(CommandBar, .2, {
			GroupTransparency = (Transparency == 0) and .07 or (Settings.Theme.Transparency),
		}, { EasingDirection = Enum.EasingDirection.In, EasingStyle = Enum.EasingStyle.Linear })
	end
end)

Connect(Input.FocusLost, function() 
	local Padding = CommandBar.Parent:FindFirstChildOfClass("UIPadding")

	Command.Parse(false, Input.Text)
	Tween(BarShadow, .2, { Transparency = 1 });
	Tween(Padding, .2, { PaddingTop = UDim.new(0, 5) })
	Tween(CommandBar, .2, {
		GroupTransparency = 1,
	}, { EasingDirection = Enum.EasingDirection.In, EasingStyle = Enum.EasingStyle.Linear })

	Wait(.2)
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
			UI.Parent = (nil);
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
	-- loading internal ui
	if Settings.Toggles.InternalUI then 
		loadstring(GetModule("internal-ui.lua"))()
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
		Spawn(function()  -- since getroleingroup is slow we adding a spawn to make it faster
			if Player ~= LocalPlayer and IsStaff(Player) and UI.Parent and Settings.Toggles.StaffNotifier then 
				Insert(Staff, Player.Name)
			end
			Searched += 1
		end)
	end 

	repeat 
		Wait();
	until (Searched == #ToSearch)

	if #Staff > 0 then 
		API:Notify({
			Title = "Staff Detected!",
			Description = Format("We have found <b>%s</b> staff member(s) in your game! (%s)", tostring(#Staff), Concat(Staff, " , ")),
			Duration = 20,
			Type = "Warn",
		})
	end

	if (not Drawing) then 
		Drawing = loadstring(GetModule("drawing.lua"))();
	end
end)

Cmd().UI = (UI);
Cmd().API = (API);

Spawn(function()
	if not Character then 
		repeat Wait();
		until Character and Humanoid
	end

	local OldHealth = (Humanoid and Humanoid.Health);

	Feature:ConnectEvent("PlayerRemoved")
	Feature:ConnectEvent("AutoExecute")
	Feature:ConnectEvent("Chatted", LocalPlayer.Chatted);
	Feature:ConnectEvent("CharacterAdded", LocalPlayer.CharacterAdded);
	Feature:ConnectEvent("Died", nil, true);
	Feature:ConnectEvent("Damaged", nil, true, function(Humanoid) 
		if (not OldHealth) or (Humanoid.Health <= OldHealth) then 
			return true
		end

		OldHealth = (Humanoid.Health);
	end);
end)

API:Notify({
	Title = "Welcome",
	Description = Format("Loaded in %.2f seconds (this is unfinished)", tick() - Speed),
	Duration = 5,
	Type = "Info",
})
