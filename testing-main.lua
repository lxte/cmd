--[[
	Cmd V1
	GitHub: "https://github.com/lxte/cmd";
	Main: "https://raw.githubusercontent.com/lxte/cmd/main/main.lua";
	Testing: "https://raw.githubusercontent.com/lxte/cmd/main/testing-main.lua";
]]

if not game:IsLoaded() then
	warn("Waiting for the game to load..")
	game.Loaded:Wait();
end

local Settings = {
	Prefix = ";",
	Seperator = ",",
	Player = "/",
	Version = "1.1",
	ScaleSize = 1,
	Blur = false,
	Themes = {
		Primary = Color3.fromRGB(35, 35, 35);
		Secondary = Color3.fromRGB(40, 40, 40);
		Third = Color3.fromRGB(45, 45, 45);
		Title = Color3.fromRGB(255, 255, 255);
		Description = Color3.fromRGB(200, 200, 200);
		Icon = Color3.fromRGB(255, 255, 255);
		Shadow = Color3.fromRGB(0, 0, 0);
		Outline = Color3.fromRGB(45, 45, 45);
		Transparency = 0.05,
		Mode = "Dark"
	},
	Binds = {},
}

local AutoLogger, OriginalSettings = {}, Settings 

local Options = { 
	Notifications = true,
	AntiInterfere =  false,
	Recommendation = true,
	Popups = true,
	Logging = false,
	AutoSimRadius = false,
}

local Ref = cloneref or function(ref) 
	return ref
end

local Services = {
	Players = Ref(game:GetService("Players"));
	Lighting = Ref(game:GetService("Lighting"));
	Replicated = Ref(game:GetService("ReplicatedStorage"));
	Starter = Ref(game:GetService("StarterGui"));
	Teams = Ref(game:GetService("Teams"));
	Http = Ref(game:GetService("HttpService"));
	Market = Ref(game:GetService("MarketplaceService"));
	Tween = Ref(game:GetService("TweenService"));
	Input = Ref(game:GetService("UserInputService"));
	Sound = Ref(game:GetService("SoundService"));
	Run = Ref(game:GetService("RunService"));
	Chat = Ref(game:GetService("TextChatService"));
	ContextActionService = Ref(game:GetService("ContextActionService"));
	Teleport = Ref(game:GetService("TeleportService"));
	AvatarEditor = Ref(game:GetService("AvatarEditorService"));
	StarterPlayer = Ref(game:GetService("StarterPlayer"));
	GuiService = Ref(game:GetService("GuiService"));
	InsertService = Ref(game:GetService("InsertService"));
}

local Player = Services.Players.LocalPlayer;

local Local = {
	Player = Player,
	Character = Player.Character or Player.CharacterAdded:Wait(),
	Mouse = Player:GetMouse(),
	Backpack = Player.Backpack,
	Camera = workspace.CurrentCamera,
};

newcclosure = newcclosure or function(func) 
	return coroutine.wrap(func)
end

setsimulationradius = setsimulationradius or function(Radius, MaxRadius) 
	pcall(function() 
		Local.Player.SimulationRadius = Radius
		Local.Player.MaxSimulationDistance = MaxRadius
	end)
end


local Checks = {
	File = (isfile and isfolder and writefile and readfile);
	Hook = (hookmetamethod or hookfunction);
};


local JSONEncode, JSONDecode = Services.Http.JSONEncode, Services.Http.JSONDecode
local Connect = game.Loaded.Connect
local PropertyChanged = game.GetPropertyChangedSignal
local LoadTime = tick();

local Genv = function() 
	return ((getgenv and getgenv()) or shared or _G);
end

if Genv and Genv().CmdLoaded then
	Genv().CmdPath.Parent = nil
end

Connect(Player.CharacterAdded, function(Character)
	Local.Character = Character;
	Local.Backpack = Local.Player.Backpack;
end)

xpcall(function()
	if Checks.File then
		local Folders = { "Cmd", "Cmd/Data", "Cmd/Plugins", "Cmd/Logs" }

		for Index, Check in next, Folders do
			if not isfolder(Check) then
				makefolder(Check);
			end
		end
	end

end, function(Result)
	warn(Result);
end)

-- UI [INSERT]
local Screen = nil

if Services.Run:IsStudio() then
	Screen = Local.Player.PlayerGui:WaitForChild("Screen");
else
	Screen = Services.InsertService:LoadLocalAsset("rbxassetid://17078695559");
end

local Cmd, Bar = Screen.Command, Screen.Command.Bar;
local Blurred, Lib, Example, Open, Autofill, Box, Recommend, Popup, ColorPopup, pressTab, Protection =
{},
Screen.Library,
Screen.Example,
Screen.Open,	
Cmd.Autofill,
Bar.Box,
Bar.Recommend,
Screen.Popup,
Screen.ColorPopup,
Bar.Description,
{};

xpcall(function()
	Screen.Parent = game:GetService("CoreGui");
end, function()
	Screen.Parent = (Local.Player.PlayerGui);
end)

-- Cmd [FUNCTIONS]
local Lower = string.lower;
local Split = string.split;
local Sub = string.sub;
local GSub = string.gsub;
local Find = string.find;
local Match = string.match;
local Format = string.format;
local Unpack = table.unpack;
local Insert = table.insert;
local Spawn = task.spawn;
local Delay = task.delay;
local Wait = task.wait;
local Discover = table.find;
local Concat = table.concat;
local Blank = "";

Spoof = function(Instance, Property, Value)
	local Hook;

	if not Checks.Hook then
		return;
	end

	Hook = hookmetamethod(game, "__index", newcclosure(function(self, Key)
		if self == Instance and Key == Property then
			return Value
		end

		return Hook(self, Key);
	end));
end

SetNumber = function(Input, Minimum, Max)
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

CheckIfNPC = function(Character)
	if (Character and Character.ClassName == "Model") and (Character:FindFirstChildOfClass("Humanoid") and not Services.Players:GetPlayerFromCharacter(Character)) then
		return true
	end
end

Character = function(Player)
	if not Player then return end
	local Character = Player.Character

	if Character then
		return Character
	end
end

GetRoot = function(Character)
	if not Character then return end
	local Root = Character:FindFirstChild("HumanoidRootPart")

	if Character and Root then
		return Root
	end
end

GetHumanoid = function(Character)
	if not Character then return end
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Character and Humanoid then
		return Humanoid
	end
end

FindTable = function(Table, Input)	
	for Index, Value in next, Table do
		if Value == Input then
			return Value
		end
	end
end

Foreach = function(Table, Func, Loop)
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

GetTools = function(Player)
	Player = Player or Local.Player
	local Backpack = Player.Backpack
	local Char = Character(Player)
	local Tools = {}

	Foreach({ Backpack:GetChildren(), Char:GetChildren() }, function(Index, Tool) 
		if Tool:IsA("Tool") then
			Insert(Tools, Tool)
		end	
	end, true)

	return Tools
end

HighSimulationRadius = function() 
	Spawn(function() 
		repeat Wait(1)
			setsimulationradius(100000 * 100000, 100000 * 100000) 
		until not Screen
	end)
end

Randomize = function(Characters)
	local Characters = (tonumber(Characters) or 10);
	local String = Blank

	for Index = 1, Characters do
		String = String .. string.char(math.random(75, 90))
	end

	return String or "Failed"
end

R6Check = function(Player)
	Player = Player or Local.Player
	if Player then
		if Player.Character:FindFirstChildOfClass("Humanoid").RigType == Enum.HumanoidRigType.R6 then
			return true
		end
	end
end

StringToInstance = function(String)
	local Path = Split(String, ".")
	local Current = game

	if Path[1] == "workspace" then
		Current = workspace
	end

	table.remove(Path, 1)

	for Index, Child in next, Path do
		Current = Current[Child];
	end

	return Current
end

Minimum = function(Table, Minimum)
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

Chat = function(Message)
	if Services.Chat:FindFirstChild("TextChannels") then
		Services.Chat.TextChannels.RBXGeneral:SendAsync(Message);
	else
		Services.Replicated.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(Message, "All");
	end
end

CreateInstance = function(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, Property in next, Properties or {} do
		Object[i] = Property
	end

	for i, Children in next, Children or {} do
		Children.Parent = Object
	end

	return Object
end

local Fly = nil;

Spawn(function()
	if Local.Player.PlayerScripts.PlayerModule:FindFirstChild("ControlModule") then
		local BodyGyro = Instance.new("BodyGyro")
		BodyGyro.maxTorque = Vector3.new(1, 1, 1) * 10 ^ 6
		BodyGyro.P = 10 ^ 6

		local BodyVelocity = Instance.new("BodyVelocity")
		BodyVelocity.maxForce = Vector3.new(1, 1, 1) * 10 ^ 6
		BodyVelocity.P = 10 ^ 4

		local isFlying = false
		local Movement = {forward = 0, backward = 0, right = 0, left = 0}

		local function SetFlying(flying)
			isFlying = flying
			BodyGyro.Parent = isFlying and Local.Character.HumanoidRootPart or nil
			BodyVelocity.Parent = isFlying and Local.Character.HumanoidRootPart or nil
			BodyVelocity.Velocity = Vector3.new()

			Local.Character:FindFirstChild("Animate").Disabled = isFlying

			if (isFlying) then
				BodyGyro.CFrame = Local.Character.HumanoidRootPart.CFrame
			end
		end

		local FlySpeed = 3

		local function ModifyMovement(newMovement)
			Movement = newMovement or Movement
			if (isFlying) then
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

		if (not Local.Character.Humanoid or Local.Character.Humanoid:GetState() == Enum.HumanoidStateType.Dead) then
			return
		end

		local TouchFrame = nil

		if Local.Player.PlayerGui:FindFirstChild("TouchGui") then
			TouchFrame = Local.Player.PlayerGui.TouchGui:FindFirstChild("TouchControlFrame")
		end

		local IsMovingThumbstick = false
		local DeadZone = 0.15
		local DeadZoneNormalized = 1 - DeadZone

		local function isTouchOnThumbstick(Position)
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

		Services.Input.TouchStarted:Connect(function(touch, gameProcessedEvent)
			isMovingThumbstick = isTouchOnThumbstick(touch.Position)
		end)

		Services.Input.TouchEnded:Connect(function(touch, gameProcessedEvent)
			if not isMovingThumbstick then
				return
			end
			isMovingThumbstick = false
			ModifyMovement({forward = 0, backward = 0, right = 0, left = 0})
		end)

		Services.Input.TouchMoved:Connect(function(touch, gameProcessedEvent)
			if not isMovingThumbstick then
				return
			end

			local MouseVector = Local.Player.Character.Humanoid.MoveDirection
			local LeftRight = MouseVector.X
			local ForeBack = MouseVector.Z

			Movement.left = LeftRight < -DeadZone and -(LeftRight - DeadZone) / DeadZoneNormalized or 0
			Movement.right = LeftRight > DeadZone and (LeftRight - DeadZone) / DeadZoneNormalized or 0

			Movement.forward = ForeBack < -DeadZone and -(ForeBack - DeadZone) / DeadZoneNormalized or 0
			Movement.backward = ForeBack > DeadZone and (ForeBack - DeadZone) / DeadZoneNormalized or 0
			ModifyMovement()
		end)

		local function onUpdate(dt)
			if (isFlying) then
				local cf = workspace.CurrentCamera.CFrame
				local direction =
					cf.rightVector * (Movement.right - Movement.left) +
					cf.lookVector * (Movement.forward - Movement.backward)
				if (direction:Dot(direction) > 0) then
					direction = direction.unit
				end

				BodyGyro.CFrame = cf
				BodyVelocity.Velocity = direction * Local.Character.Humanoid.WalkSpeed * FlySpeed
			end

		end

		function Fly(Boolean, SpeedValue)
			FlySpeed = SpeedValue or 1
			SetFlying(Boolean)

			Services.Run.RenderStepped:Connect(onUpdate)
		end
	end
end)

local PlayerArgs = {
	["all"] = function() 
		return Services.Players:GetPlayers()
	end,

	["others"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if Player ~= Local.Player then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end, 

	["me"] = function()
		return { Local.Player }
	end,

	["random"] = function()
		local Amount = Services.Players:GetPlayers()

		return { Amount[math.random(1, #Amount)] }
	end,

	["npc"] = function()
		local Targets = {}

		Foreach(workspace:GetDescendants(), function(Index, Model) 
			if CheckIfNPC(Model) then
				Insert(Targets, Model)
			end
		end)

		return Targets
	end, 

	["seated"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if GetHumanoid(Player.Character).Sit then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end, 

	["stood"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if not GetHumanoid(Player.Character).Sit then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["closest"] = function()
		local Targets = {}
		local ClosestDistance, ClosestPlayer = 9e9, nil

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			local Distance = Player:DistanceFromCharacter(GetRoot(Local.Character).Position)

			if Player ~= Local.Player and Distance < ClosestDistance then
				ClosestDistance = Distance
				ClosestPlayer = Player
			end
		end)

		return { ClosestPlayer }
	end,

	["farthest"] = function()
		local Targets = {}
		local FurthestDistance, FurthestPlayer = 0, nil

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			local Distance = Player:DistanceFromCharacter(GetRoot(Local.Character).Position)

			if Player ~= Local.Player and Distance > FurthestDistance then
				FurthestDistance = Distance
				FurthestPlayer = Player
			end
		end)

		return { FurthestPlayer }
	end,

	["enemies"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if Player.Team ~= Local.Player.Team then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["dead"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if GetHumanoid(Player.Character).Health == 0 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,


	["alive"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if GetHumanoid(Player.Character).Health > 0 then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["friends"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if Player:IsFriendsWith(Local.Player.UserId) and Local.Player ~= Player then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,

	["nonfriends"] = function()
		local Targets = {}

		Foreach(Services.Players:GetPlayers(), function(Index, Player) 
			if not Player:IsFriendsWith(Local.Player.UserId) and Local.Player ~= Player then
				Insert(Targets, Player)
			end
		end)

		return Targets
	end,
}

function GetPlayer(Target)
	local Target = Lower(Target);
	local Check = PlayerArgs[Target];

	if Check then
		return Check()
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

function RGB(Color, Factor, Mode)
	Mode = Mode or Settings.Themes.Mode

	if Mode == "Light" then
		return Color3.fromRGB((Color.R * 255) - Factor, (Color.G * 255) - Factor, (Color.B * 255) - Factor)
	else
		return Color3.fromRGB((Color.R * 255) + Factor, (Color.G * 255) + Factor, (Color.B * 255) + Factor)
	end
end

function StringToRGB(Item)
	local Color = nil

	if typeof(Item) == "string" then
		Color = Color3.new(Unpack(Split(Item, ",")))
	elseif typeof(Item) == "table" then
		Color = Color3.new(Unpack(Item))
	end

	return Color3.fromRGB(Color.R * 255, Color.G * 255, Color.B * 255)
end

function DivideUDim2(Value, Amount)
	local New = {
		Value.X.Scale / Amount;
		Value.X.Offset / Amount;
		Value.Y.Scale / Amount;
		Value.Y.Offset / Amount;
	}

	return UDim2.new(Unpack(New))
end

function MultiplyUDim2(Value, Amount)
	local New = {
		Value.X.Scale * Amount;
		Value.X.Offset * Amount;
		Value.Scale * Amount;
		Value.Y.Offset * Amount;
	}

	return UDim2.new(Unpack(New))
end

local Tween = function(Object, Info, Table)
	xpcall(function()
		Services.Tween:Create(Object, Info, Table):Play()
	end, function(Result)
		warn(Format("error tweening %s\n%s", Object.Name, Result))
	end)
end


Foreach({ Cmd:GetChildren(), Screen:GetChildren() }, function(Index, Canva)
	if Canva:IsA("CanvasGroup") then
		Canva.Visible = false;
	end
end, true)

-- Admin [LIBRARY]
Command = {}
Commands = {}
Admins = {}
FullArgs = {}
Command.Count = 0
Command.Toggles = {}

local Env = function() 
	return Command.Toggles
end

SetEnv = function(Name, Bool) 
	Env()[Name] = false
	Wait();
	Env()[Name] = Bool
end

-- Command [FUNCTIONS]

Methods = {}

Methods.RemoveRightGrip = function(Tool)
	Tool.Parent = Local.Character
	Tool.Parent = Local.Backpack
	Tool.Parent = Local.Character.Humanoid
	Tool.Parent = Local.Character
end

Methods.Check = function()
	if Services.Replicated:FindFirstChild("DeleteCar") then
		return true
	elseif Local.Character:FindFirstChild("HandlessSegway") then
		return true
	elseif Local.Backpack:FindFirstChild("Building Tools") then
		return true
	else
		for i, Descendant in next, game:GetDescendants() do
			if Descendant.Name == "DestroySegway" then
				return true
			end
		end
	end
end

Methods.Destroy = function(Part)
	if Services.Replicated:FindFirstChild("DeleteCar") then
		Services.Replicated.DeleteCar:FireServer(Part);

	elseif Local.Character:FindFirstChild("HandlessSegway") then
		for i, Descendant in next, game:GetDescendants() do
			if Descendant.Name == "DestroySegway" then
				Descendant:FireServer(Part, {Value = Part});
			end
		end

	elseif Services.Replicated:FindFirstChild("GuiHandler") then
		Services.Replicated.GuiHandler:FireServer(false, Part);

	elseif Local.Player.Backpack:FindFirstChild("Building Tools") then
		local ArgumentTable = { [1] = "Remove", [2] = { [1] = Part } };
		Local.Player.Backpack:FindFirstChild("Building Tools").SyncAPI.ServerEndpoint:InvokeServer(Unpack(ArgumentTable));
	end
end

local Modules = {
	Freecam = nil,
	Glass = nil,
	Bhop = nil,
	ColorPicker = nil,
}

-- Command [MODULES]
Spawn(function()
	Modules.Freecam = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/assets/freecam"))();
	Modules.ColorPicker = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/assets/colorpicker"))();
	Modules.Bhop = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/assets/bhop"))();
	Modules.Blur = loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/assets/blur"))();
end)

local PromptChangeRigType = function(RigType)
	Services.AvatarEditor:PromptSaveAvatar(GetHumanoid(Local.Character).HumanoidDescription,Enum.HumanoidRigType[RigType])
	Services.AvatarEditor.PromptSaveAvatarCompleted:Wait()
	Command.Parse("respawn")
end

local Walkfling = function(Power, Distance, Bool)
	Distance = tonumber(Distance) or 5
	SetEnv("WalkFling", Bool);

	Spawn(function()
		local HumanoidRootPart, Character, Velocity, Movel = GetRoot(Local.Character), Local.Character, nil, 0.1
		repeat
			Wait()
			if Env().WalkFling then
				while Env().WalkFling and
					not (Character and Character.Parent and HumanoidRootPart and HumanoidRootPart.Parent) do
					Services.Run.Heartbeat:Wait()
					local HumanoidRootPart, Character = GetRoot(Local.Character), Local.Character
				end

				if Env().WalkFling then
					if Unpack(GetPlayer("closest")):DistanceFromCharacter(GetRoot(Local.Character).Position) <= Distance then
						Velocity = HumanoidRootPart.Velocity
						HumanoidRootPart.Velocity = Velocity * tonumber(Power) + Vector3.new(0, tonumber(Power), 0)
						Services.Run.RenderStepped:Wait()
						if Character and Character.Parent and HumanoidRootPart and HumanoidRootPart.Parent then
							HumanoidRootPart.Velocity = Velocity
						end
						Services.Run.Stepped:Wait()
						if Character and Character.Parent and HumanoidRootPart and HumanoidRootPart.Parent then
							HumanoidRootPart.Velocity = Velocity + Vector3.new(0, Movel, 0)
							Movel = Movel * -1
						end
					end
				end
			end
		until not Env().WalkFling
	end)
end

local Fling = function(Target)
	local LocalRoot = GetRoot(Local.Character);
	local LocalHumanoid = GetHumanoid(Local.Character);
	local Old = LocalRoot.CFrame;

	pcall(function()
		Walkfling(10000, 100, true)
		local Timer = tick()

		repeat Wait()
			local Root = GetRoot(Target.Character);
			local Humanoid = GetHumanoid(Target.Character);

			local Position = Root.CFrame
			local Info = TweenInfo.new(0.12)

			Local.Camera.CameraSubject = Humanoid
			LocalHumanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

			Tween(LocalRoot, Info, { CFrame = (Root.CFrame + (Root.Velocity * math.random(1, 2.5))) }) 
			Wait(0.12)
			Tween(LocalRoot, Info, { CFrame = Position * CFrame.new(0, 1, math.random(-2, 2))})
			Wait(0.12)

		until (tick() - Timer > 3) or not Root or Root.Velocity.Magnitude > 200 or not LocalRoot or LocalHumanoid.Health == 0 or Humanoid.Sit

		Wait(0.2)
		workspace.CurrentCamera.CameraSubject = GetHumanoid(Local.Character)
		LocalRoot.CFrame = Old
		Walkfling(10000, 1000, false)
	end)
end	

-- UI [LIBRARY]
local Utils = {}
local Tweens = {}
local Tab = {}
local Library = {}
local Autofills = {}
local Utils = {}
Tweens.Info = {}

Autofills.Args = {
	["String"] = {
		Name = "String",
		Background = Color3.fromRGB(121, 255, 111),
		Outline = Color3.fromRGB(135, 255, 116),
		Icon = "http://www.roblox.com/asset/?id=6034934040"
	},

	["Player"] = {
		Name = "Player",
		Background = Color3.fromRGB(255, 107, 107),
		Outline = Color3.fromRGB(255, 116, 116),
		Icon = "http://www.roblox.com/asset/?id=6034287594"
	},

	["Number"] = {
		Name = "Number",
		Background = Color3.fromRGB(102, 171, 255),
		Outline = Color3.fromRGB(112, 145, 255),
		Icon = "rbxassetid://16798074797"
	},

	["Bool"] = {
		Name = "Bool",
		Background = Color3.fromRGB(252, 255, 98),
		Outline = Color3.fromRGB(255, 250, 103),
		Icon = "rbxassetid://7743869317"
	}
}

Tweens.AddInfo = function(Element)
	if Element and Element:IsA("CanvasGroup") then
		local Shadow = Element:FindFirstChildOfClass("UIStroke");
		local Name = Element.Name;

		if not Tweens.Info[Name] then
			Tweens.Info[Name] = { 
				Size = Element.Size, 
				Transparency = Element.GroupTransparency,
				Shadow = nil,
			}

			if Shadow then
				Tweens.Info[Name].Shadow = Shadow.Transparency 
			end
		end

		return Tweens.Info[Name]
	end
end

Tweens.Open = function(List)
	local Canvas = List.Canvas
	local Speed = List.Speed
	local Position = List.Position or UDim2.new(0.5, 0, 0.5, 0)
	local Name = Canvas.Name
	local Info = Tweens.AddInfo(Canvas)
	local Shadow = Canvas:FindFirstChildOfClass("UIStroke")

	local Size = Info.Size
	local Transparency = Settings.Themes.Transparency
	local Outline = Info.Shadow
	local New = DivideUDim2(Size, 1.1)
	local Info = TweenInfo.new(Speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	Canvas.Size = New
	Canvas.Position = Position
	Canvas.GroupTransparency = 1
	Canvas.Visible = true

	Tween(Canvas, Info, { Size = Size })
	Tween(Canvas, Info, { GroupTransparency = Transparency })

	if Shadow then
		Tween(Shadow, Info, { Transparency = Outline })
	end

	Delay(Speed, function()
		Canvas.GroupTransparency = Transparency
	end)
end

Tweens.Close = function(List)
	local Canvas = List.Canvas
	local Speed = List.Speed
	local Name = Canvas.Name
	local Info = Tweens.AddInfo(Canvas)
	local Shadow = Canvas:FindFirstChildOfClass("UIStroke")
	local Size = Info.Size
	local Transparency = Settings.Themes.Transparency
	local New = DivideUDim2(Size, 1.1)
	local Info = TweenInfo.new(Speed, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

	Tween(Canvas, Info, { Size = New })
	Tween(Canvas, Info, { GroupTransparency = 1 })

	if Shadow then
		Tween(Shadow, Info, { Transparency = 1 })
	end

	Delay(Speed, function()
		Canvas.Visible = false
	end)
end

Tab.SetPage = function(Page)
	local Tabs = Page.Parent
	local Info = TweenInfo.new(0.4)

	for Index, Tab in next, Tabs:GetChildren() do
		if Tab:IsA("Frame") then
			local Opened = Tab.Opened

			if Opened.Value and Tab ~= Page then
				Tween(Tab, Info, { Position = UDim2.new(1.5, 0, 0.5, 25) })
				Opened.Value = false
			elseif Tab == Page and not Page.Opened.Value then
				Tab.Position = UDim2.new(-0.5, 0, 0.5, 25)
				Tween(Tab, Info, { Position = UDim2.new(0.5, 0, 0.5, 25) })
				Opened.Value = true
			end
		end
	end
end

Library.Resizing = { 
	Top = { X = Vector2.new(0, 0),    Y = Vector2.new(0, -1)};
	Bottom = { X = Vector2.new(0, 0),    Y = Vector2.new(0, 1)};
	Left = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 0)};
	Right = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 0)};
	TopLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, -1)};
	TopRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, -1)};
	BottomLeft = { X = Vector2.new(-1, 0),   Y = Vector2.new(0, 1)};
	BottomRight = { X = Vector2.new(1, 0),    Y = Vector2.new(0, 1)};
}

Library.Resizable = function(Tab, Minimum, Maximum)
	Spawn(function()
		local MousePos, Size, UIPos = nil, nil, nil

		if Tab and Tab:FindFirstChild("Resizeable") then
			local Positions = Tab:FindFirstChild("Resizeable")

			for Index, Types in next, Positions:GetChildren() do
				Connect(Types.InputBegan, function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Type = Types
						MousePos = Vector2.new(Local.Mouse.X, Local.Mouse.Y)
						Size = Tab.AbsoluteSize
						UIPos = Tab.Position
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
			if Type and MousePos and Size and UIPos and Tab:FindFirstChild("Resizeable")[Type.Name] == Type then
				local Mode = Library.Resizing[Type.Name]
				local NewSize = Vector2.new(Size.X + Delta.X * Mode.X.X, Size.Y + Delta.Y * Mode.Y.Y)
				NewSize = Vector2.new(math.clamp(NewSize.X, Minimum.X, Maximum.X), math.clamp(NewSize.Y, Minimum.Y, Maximum.Y))

				local AnchorOffset = Vector2.new(Tab.AnchorPoint.X * Size.X, Tab.AnchorPoint.Y * Size.Y)
				local NewAnchorOffset = Vector2.new(Tab.AnchorPoint.X * NewSize.X, Tab.AnchorPoint.Y * NewSize.Y)
				local DeltaAnchorOffset = NewAnchorOffset - AnchorOffset

				Tab.Size = UDim2.new(0, NewSize.X, 0, NewSize.Y)

				local NewPosition = UDim2.new(
					UIPos.X.Scale, 
					UIPos.X.Offset + DeltaAnchorOffset.X * Mode.X.X,
					UIPos.Y.Scale,
					UIPos.Y.Offset + DeltaAnchorOffset.Y * Mode.Y.Y
				)
				Tab.Position = NewPosition
			end
		end

		Connect(Local.Mouse.Move, function()
			if Type then
				Resize(Vector2.new(Local.Mouse.X, Local.Mouse.Y) - MousePos)
			end
		end)
	end)
end


Library.Hover = function(Object, Speed, Color)
	Spawn(function()
		Speed = Speed or 0.3

		if Object:IsA("GuiObject") then
			local Hover = Object:FindFirstChild("HoverPadding")
			local Info = TweenInfo.new(Speed)

			Connect(Object.InputBegan, function()
				local Theme = Color or Settings.Themes.Secondary
				Object.BackgroundColor3 = Theme

				Tween(Object, Info, { BackgroundColor3 = RGB(Theme, 5)})

				if Hover then
					Tween(Hover, Info, { PaddingLeft = UDim.new(0, 5) })
				end
			end)

			Connect(Object.InputEnded, function()
				local Theme = Color or Settings.Themes.Secondary

				Tween(Object, Info, { BackgroundColor3 = Theme})

				if Hover then
					Tween(Hover, Info, { PaddingLeft = UDim.new(0, 0) })
				end
			end)
		end
	end)
end

Type = nil;

Tab.new = function(Info)
	local Title = Info.Title
	local Drag = Info.Drag
	local New = Example:Clone()
	local Top = New.Top
	local Buttons = Top.Buttons
	local Minimized = New.Minimized
	local Info = TweenInfo.new(0.3)
	local BlurTable = nil

	New.Parent = Screen
	New.TabPopup.Visible = false
	New.Visible = false
	Top.Title.Text = Title
	New.Name = Title


	if Settings.Blur then
		pcall(function() 
			Blurred[Title] = Modules.Blur.new(New, 5)
		end)
	end

	for Index, Button in next, Buttons:GetChildren() do
		Library.Hover(Button)
	end

	if Drag then
		Library.Drag(New)
	end

	Connect(PropertyChanged(New, "Visible"), function() 
		pcall(function()
			Wait(0.2);

			if Blurred[Title] and Settings.Blur and New.Visible then
				Blurred[Title].root.Parent = workspace.CurrentCamera
			end
		end)
	end)

	Connect(Buttons.Close.MouseButton1Click, function()
		pcall(function()
			Tweens.Close({ Canvas = New, Speed = 0.25 })

			if Blurred[Title] then
				Blurred[Title].root.Parent = nil
			end
		end)
	end)

	Connect(Buttons.Back.MouseButton1Click, function()
		Tab.SetPage(New.Tabs.Main)
	end)

	Connect(Buttons.Minimize.MouseButton1Click, function()
		if Minimized.Value then
			Tween(New, Info, { Size = UDim2.fromOffset(293, 367) })
		else
			Tween(New, Info, { Size = UDim2.fromOffset(293, 60) })
		end

		Minimized.Value = not Minimized.Value
	end)

	Library.Resizable(New, Vector2.new(202, 253), Vector2.new(1000, 1000))

	return New
end

Tab.Popup = function(Tab, Title)
	local Popup = Tab:FindFirstChild("TabPopup")
	local Shadow = Tab:FindFirstChild("ShadowBG")
	local InfoTween = TweenInfo.new(0.2)

	if Popup then
		local New = Popup:Clone()
		local Top = New.Top
		local Scroll = New.Main.Scroll

		New.Parent = Tab
		New.Position = UDim2.fromScale(0, 1.4)
		Top.Title.Text = Title

		Connect(Top.Buttons.Close.MouseButton1Click, function()
			Tweens.Close({
				Canvas = New,
				Speed = 0.25,
			})

			if Shadow then
				Tween(Shadow, InfoTween, { BackgroundTransparency = 1 })
			end
		end)

		return New, Scroll
	end
end

Tab.ShowPopup = function(Popup)
	local Shadow = Popup.Parent:FindFirstChild("ShadowBG")

	if Popup then
		local Info = TweenInfo.new(0.25)
		Popup.Position = UDim2.fromScale(0, 1.4)
		Popup.GroupTransparency = 1
		Popup.Visible = true

		Tweens.Open({
			Canvas = Popup,
			Speed = 0.25,
			Position = UDim2.new(0.5, 0, 0.615, 0)
		})

		if Shadow then
			Tween(Shadow, Info, { BackgroundTransparency = 0.8 })
		end
	end
end

Library.Drag = function(Canvas)
	if Canvas then
		local Dragging;
		local DragInput;
		local Start;
		local StartPosition;

		local function Update(input)
			local delta = input.Position - Start
			Canvas.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
		end

		Connect(Canvas.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch and not Type then
				Dragging = true
				Start = Input.Position
				StartPosition = Canvas.Position

				Connect(Input.Changed, function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		Connect(Canvas.InputChanged, function(Input)
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
end

Library.new = function(Object, Info)
	local Parent = Info.Parent
	local Title = Info.Title
	local Description = Info.Description
	local Default = Info.Default
	local Callback = Info.Callback
	local Item = Lib:FindFirstChild(Object)

	if Item then
		local New = Item:Clone()
		New.Parent = Parent
		New.Visible = true

		if New:IsA("GuiButton") then
			Library.Hover(New)
		end

		if Title then
			New.Content.Title.Text = Title
		else
			New.Content.Title:Destroy()
		end

		if Description then
			New.Content.Description.Text = Description
		else
			New.Content.Description:Destroy()
		end

		if Object == "Button" then
			Connect(New.MouseButton1Click, function()
				Callback()
			end)

		elseif Object == "Bind" then
			local Keybind = New.Title
			local Done, Time = false, tick()
			local Detect = nil
			local InputType = Enum.UserInputType;
			local MouseInputs = { InputType.MouseButton1, InputType.MouseButton2, InputType.MouseButton3 };

			Connect(New.MouseButton1Click, function()
				Done = false
				Keybind.Text = "..."

				Detect = Connect(Services.Input.InputBegan, function(Key)
					if table.find(MouseInputs, Key.UserInputType) and not Done then
						Callback(Key)
						Done = true
						Keybind.Text = tostring(Key.UserInputType):gsub("Enum.UserInputType.", Blank):gsub("MouseButton", "MB")
					elseif not Done then
						Done = true
						Callback(Key)
						Done = true
						Keybind.Text = tostring(Key.KeyCode):gsub("Enum.KeyCode.", Blank)
					end
				end)
			end)

			Spawn(function()
				repeat Wait() until Done or tick() - Time == 5

				if Detect then
					Detect:Disconnect()
				end
			end)

		elseif Object == "Dropdown" then
			local Options = New.Options
			local Drop = New.Drop
			local Scroll = Options.Scroll
			local DropdownOptions = Info.Options
			local Opened = Drop.Opened
			local Arrow = Drop.Arrow
			New.ZIndex = 2

			local Info = TweenInfo.new(0.25);
			Library.Hover(New);

			local Show = function() 
				local TweenSize, ArrowRotation = nil, nil

				if Opened.Value then
					TweenSize = UDim2.fromOffset(88, 0)
					ArrowRotation = 0

					Delay(0.1, function() 
						Options.Visible = false
					end)
				else
					TweenSize = UDim2.fromOffset(88, 137)
					ArrowRotation = 180

					Options.Visible = true
				end

				Tween(Options, Info, { Size = TweenSize });
				Tween(Arrow, Info, { Rotation = ArrowRotation });

				Opened.Value = not Opened.Value
			end

			Foreach(DropdownOptions, function(Index, Option)
				local Button = Lib.DropdownButton
				local Clone = Button:Clone()

				Clone.Parent = Scroll 
				Clone.Text = Index or "no name!"
				Clone.Visible = true
				Library.Hover(Clone)

				Connect(Clone.MouseButton1Click, function() 
					Drop.Text = Index

					Tween(Options, Info, { Size = UDim2.fromOffset(88, 0) });
					Tween(Arrow, Info, { Rotation = 0 });
					Callback(Option);
				end)
			end)

			Connect(Drop.MouseButton1Click, Show)
			Connect(New.MouseButton1Click, Show)

		elseif Object == "Input" then
			local TextBox = New.Box
			TextBox.Text = tostring(Default)

			Connect(New.MouseButton1Click, function()
				TextBox:CaptureFocus()
			end)

			Connect(TextBox.FocusLost, function()
				Callback(TextBox.Text)
			end)

			return TextBox

		elseif Object == "Toggle" then
			local Bool = New.On
			local Toggle = New.Toggle
			local Circle = Toggle.Circle
			local Info = TweenInfo.new(0.3)

			local Set = function(On)
				if On then
					Tween(Toggle, Info, { BackgroundColor3 = Color3.fromRGB(99, 218, 92) })
					Tween(Circle, Info, { BackgroundColor3 = Color3.fromRGB(255, 255, 255), Position = UDim2.new(0.509, 0,0.5, 0) })
				else
					Tween(Toggle, Info, { BackgroundColor3 = Settings.Themes.Outline })
					Tween(Circle, Info, { BackgroundColor3 = Settings.Themes.Secondary, Position = UDim2.new(0.089, 0,0.5, 0) })
				end

				Bool.Value = On
			end

			Set(Default)

			Connect(New.MouseButton1Click, function()
				Set(not Bool.Value)
				Callback(Bool.Value)
			end)

		elseif Object == "Label" then
			return New
		elseif Object == "Switch" then
			local NewTab = Lib.Tab:Clone()
			local Scroll = NewTab.Scroll
			local Folder = Parent

			if Folder.Name ~= "Tabs" then
				Folder = Folder:FindFirstAncestor("Tabs")
			end

			NewTab.Parent = Folder
			NewTab.Position = UDim2.new(-0.5, 0, 0.562, 0)
			NewTab.Visible = true
			NewTab.Opened.Value = false

			Connect(New.MouseButton1Click, function()
				Tab.SetPage(NewTab)
			end)

			return NewTab.Scroll, New
		end
	end
end

Library.Bar = function(Bool)
	local UI = { b = { UDim2.new(0.5, 0, 0, 0), Bar }, a = { UDim2.new(0.5, 0, 0, 80), Autofill }}

	if Bool then
		for Index, Variable in UI do
			if Variable then
				Tweens.Open({
					Canvas = Variable[2],
					Speed = 0.15,
					Position = Variable[1],
				})
			end
		end
	else
		for Index, Variable in UI do
			if Variable then
				Tweens.Close({
					Canvas = Variable[2],
					Speed = 0.15,
				})

				for Index = 1, 10 do
					pcall(function()
						Box:ReleaseFocus()
						Blurred["Bar"].root.Parent = nil
						Blurred["Autofill"].root.Parent = nil
					end)
				end
			end
		end
	end
end

Library.Theming = {
	Names = {
		["Opened"] = function(Item)
			if Item:IsA("BoolValue") then
				local Tab = Item.Parent
				Tab.BackgroundColor3 = RGB(Settings.Themes.Primary, 3)
			end
		end,

		["Dropdown"] = function(Item)
			if Item:IsA("Frame") then
				Item.BackgroundColor3 = Settings.Themes.Secondary
			end
		end,

		["Drop"] = function(Item)
			if Item:IsA("GuiButton") and Item.Parent.Name == "Dropdown" then
				Item.BackgroundColor3 = Settings.Themes.Primary
				Item.TextColor3 = Settings.Themes.Description
			end
		end,

		["DropdownButton"] = function(Item)
			if Item:IsA("GuiButton") then
				Item.BackgroundColor3 = Settings.Themes.Primary
			end
		end,

		["Options"] = function(Item)
			if Item:IsA("Frame") and Item.Parent.Name == "Dropdown" then
				Item.BackgroundColor3 = RGB(Settings.Themes.Primary, 3)
			end
		end,

		["Title"] = function(Item)
			Item.TextColor3 = Settings.Themes.Title
		end,

		["Description"] = function(Item)
			Item.TextColor3 = Settings.Themes.Description
		end,

		["Top"] = function(Item)
			Item.BackgroundColor3 = Settings.Themes.Secondary
		end,

		["Box"] = function(Item)
			Item.TextColor3 = Settings.Themes.Title
			Item.BackgroundColor3 = Settings.Themes.Outline
		end,

		["Recommend"] = function(Item)
			Box.TextColor3 = Settings.Themes.Description
		end,

		["Stroke"] = function(Item)
			Item.Color = Settings.Themes.Outline
		end,

		["Shadow"] = function(Item)
			if Item:IsA("UIStroke") then
				Item.Color = Settings.Themes.Shadow
			end
		end,

		["AutofillObject"] = function(Item)
			Item.BackgroundColor3 = Settings.Themes.Secondary
		end,

		["Buttons"] = function(Item)
			if Item:IsA("Frame") then
				for Index, Button in next, Item:GetChildren() do
					if Button:IsA("GuiButton") then
						Button.BackgroundColor3 = Settings.Themes.Secondary
					end
				end
			end
		end,

		["Decline"] = function(Item)
			Item.BackgroundColor3 = Settings.Themes.Primary
		end,

		["Line"] = function(Item)
			Item.BackgroundColor3 = Settings.Themes.Outline
		end,
	},

	Classes = {
		["CanvasGroup"] = function(Item)
			Item.BackgroundColor3 = Settings.Themes.Primary
			Item.GroupTransparency = Settings.Themes.Transparency
		end,

		["ImageLabel"] = function(Item)
			if Item.Name ~= "ColourDisplay" then
				Item.ImageColor3 = Settings.Themes.Icon
			end
		end,

		["ImageButton"] = function(Item)
			if not Autofills.Args[Item.Name] and Item.Name ~= "DarknessPicker" and Item.Name ~= "ColourWheel" then
				Item.ImageColor3 = Settings.Themes.Icon
			end
		end,

		["ScrollingFrame"] = function(Item)
			Item.ScrollBarImageColor3 = Settings.Themes.Outline
		end,
	},
}

do

	local Ignore = { "Tab", "Section", };

	for Index, Button in next, Lib:GetChildren() do
		if (Button:IsA("GuiButton") or Button:IsA("Frame")) and not Discover(Ignore, Button.Name) then
			Library.Theming.Names[Button.Name] = function(Item)	
				if Item.Parent.Name ~= "Toggle" then
					Item.BackgroundColor3 = Settings.Themes.Secondary
				end

				if Item.Name == "Toggle" and Item:IsA("GuiButton") then
					local On = Item.On
					local Toggle = Item.Toggle					
					local Circle = Toggle.Circle

					if not On.Value then
						Toggle.BackgroundColor3 = Settings.Themes.Outline
						Circle.BackgroundColor3 = Settings.Themes.Primary
					else
						Toggle.BackgroundColor3 = Color3.fromRGB(99, 218, 92)
						Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
					end
				end
			end
		end
	end
end

Library.LoadTheme = function(Table)
	if Table then
		Settings.Themes = Table
	end

	for Index, Object in next, Screen:GetDescendants() do
		if Library.Theming.Names[Object.Name] then
			local Function = Library.Theming.Names[Object.Name]
			Function(Object)

		elseif Library.Theming.Classes[Object.ClassName] then
			local Function = Library.Theming.Classes[Object.ClassName]
			Function(Object)
		end
	end
end

Library.Themes = {
	["Dark"] = function()
		local Old = Settings.Themes.Transparency

		Settings.Themes = {
			Primary = Color3.fromRGB(35, 35, 35),
			Secondary = Color3.fromRGB(40, 40, 40),
			Third = Color3.fromRGB(45, 45, 45),
			Title = Color3.fromRGB(255, 255, 255),
			Description = Color3.fromRGB(200, 200, 200),
			Icon = Color3.fromRGB(255, 255, 255),
			Shadow = Color3.fromRGB(0, 0, 0),
			Outline = Color3.fromRGB(45, 45, 45),
			Transparency = Old,
			Mode = "Dark"
		}

		Library.LoadTheme()
	end,

	["Nord"] = function()
		local Old = Settings.Themes.Transparency

		Settings.Themes = {
			Primary = Color3.fromRGB(47, 54, 66),
			Secondary = Color3.fromRGB(52, 58, 72),
			Title = Color3.fromRGB(255, 255, 255),
			Description = Color3.fromRGB(200, 200, 200),
			Icon = Color3.fromRGB(255, 255, 255),
			Shadow = Color3.fromRGB(46, 52, 64),
			Outline = Color3.fromRGB(57, 65, 80),
			Transparency = Old,
			Mode = "Dark",
		}

		Library.LoadTheme()
	end,

	["Dracula"] = function()
		local Old = Settings.Themes.Transparency

		Settings.Themes = {
			Primary = Color3.fromRGB(40, 42, 54),
			Secondary = Color3.fromRGB(44, 46, 59),
			Title = Color3.fromRGB(255, 255, 255),
			Description = Color3.fromRGB(200, 200, 200),
			Icon = Color3.fromRGB(255, 255, 255),
			Shadow = Color3.fromRGB(0, 0, 0),
			Outline = Color3.fromRGB(48, 51, 65),
			Transparency = Old,
			Mode = "Dark",
		}

		Library.LoadTheme()
	end,

	["Light"] = function()
		local Old = Settings.Themes.Transparency

		Settings.Themes = {
			Primary = Color3.fromRGB(237,237,237),
			Secondary = Color3.fromRGB(242, 242, 242),
			Title = Color3.fromRGB(85, 85, 85),
			Description = Color3.fromRGB(100, 100, 100),
			Icon = Color3.fromRGB(85, 85, 85),
			Shadow = Color3.fromRGB(176, 176, 176),
			Outline = Color3.fromRGB(222, 222, 222),
			Transparency = Old,
			Mode = "Light",
		}

		Library.LoadTheme()
	end,

	["c00lkidd"] = function()
		local Old = Settings.Themes.Transparency

		Settings.Themes = {
			Primary = Color3.fromRGB(29, 0, 2),
			Secondary = Color3.fromRGB(44, 0, 2),
			Title = Color3.fromRGB(255, 255, 255),
			Description = Color3.fromRGB(200, 200, 200),
			Icon = Color3.fromRGB(255, 255, 255),
			Shadow = Color3.fromRGB(54, 0, 1),
			Outline = Color3.fromRGB(65, 0, 2),
			Transparency = Old,
			Mode = "Dark",
		}

		Library.LoadTheme()
	end,

	["Void"] = function()
		local Old = Settings.Themes.Transparency

		Settings.Themes = {
			Primary = Color3.fromRGB(9, 9, 9),
			Secondary = Color3.fromRGB(12, 12, 12),
			Title = Color3.fromRGB(255, 255, 255),
			Description = Color3.fromRGB(200, 200, 200),
			Icon = Color3.fromRGB(255, 255, 255),
			Shadow = Color3.fromRGB(0, 0, 0),
			Outline = Color3.fromRGB(18, 18, 18),
			Transparency = Old,
			Mode = "Dark",
		}

		Library.LoadTheme()
	end,
}

Autofills.AutoSize = function(Number)
	Spawn(function()
		local Info = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local Sizes = {
			[1] = UDim2.fromOffset(460, 80),
			[2] = UDim2.fromOffset(460, 132),
			[3] = UDim2.fromOffset(460, 187),
			[4] = UDim2.fromOffset(460, 241),
		}

		if Number < 4 then
			Tween(Autofill, Info, { Size = Sizes[Number] })
		elseif Number == 4 or Number > 4 then
			Tween(Autofill, Info, { Size = Sizes[4] })
		end
	end)
end

Autofills.AddArguments = function(Frame, Arguments)
	for Index, Argument in Arguments do
		if Index and Argument then
			local Name = Argument.Name
			local Type = Argument.Type

			local Arg = Autofills.Args[Type]

			if Arg then
				local Name, Background, Outline, Icon = Arg.Name, Arg.Background, Arg.Outline, Arg.Icon
				local UI = Lib.AutofillArgument:Clone()
				UI.BackgroundColor3 = Background;
				UI.Stroke.Color = Outline;
				UI.Icon.Image = Icon;
				UI.Visible = true;
				UI.Parent = Frame;
				UI.Name = Name;
			end
		end
	end
end

Autofills.Add = function(Table)
	local Aliases = Table[1]
	local Description = Table[2]
	local Arguments = Table[3]
	local Plugin = Table[4]
	local Callback = Table[5]
	local Arg = Concat(Aliases, " / ")

	local Scroll = Autofill.Main.Scroll
	local Example = Scroll.Example
	local New = Example:Clone()
	local Content = New.Content
	local Args = New.Arguments

	Content.Title.Text = Arg
	Content.Description.Text = Description
	New.Parent = Scroll
	New.Visible = true
	New.Name = "AutofillObject"

	Autofills.AddArguments(Args, Arguments)
end

Autofills.Search = function(Input)
	Spawn(function()
		local Lowered = GSub(Lower(Split(Input, " ")[1]), Settings.Prefix, Blank)
		local Scroll = Autofill.Main.Scroll
		local FoundFirst = false
		local Amount = 0

		for Index, Frame in next, Scroll:GetChildren() do
			if Frame:IsA("Frame") and Frame.Name == "AutofillObject" then
				local Content = Frame.Content

				if Find(Lower(Content.Title.Text), Lowered) then 
					if not FoundFirst then
						Frame.BackgroundColor3 = Settings.Themes.Secondary
						FoundFirst = true
					else
						Frame.BackgroundColor3 = RGB(Settings.Themes.Primary, 3)
					end

					Amount = Amount + 1

					Frame.Visible = true
				else
					Frame.Visible = false
				end
			end
		end
		Autofills.AutoSize(Amount)
	end)
end

Utils.NotificationInfo = {
	["Information"] = {
		Color = Color3.fromRGB(111, 163, 211),
	},

	["Error"] = {
		Color = Color3.fromRGB(211, 108, 109),
	},

	["Warning"] = {
		Color = Color3.fromRGB(211, 208, 110),
	},

	["Success"] = {
		Color = Color3.fromRGB(93, 171, 93),
	},
}

Utils.Notify = function(Type, Title, Description, Duration)
	if not Options.Notifications then return end 

	Duration = tonumber(Duration) or 5
	local Notification = Screen.Notification.Example:Clone()
	local Timer = Notification.Timer
	local Top = Notification.Top
	local Info = TweenInfo.new(Duration)
	local Table = Utils.NotificationInfo[Type] or Utils.NotificationInfo.Information

	if Title then
		Top.Title.Text = Title
	end

	if Description then
		Notification.Description.Text = Description
	end

	Notification.Visible = true
	Notification.Parent = Screen.Notification
	Timer.BackgroundColor3 = Table.Color

	Tween(Timer, Info, { Size = UDim2.new(0, 0, 0, 3), Position = UDim2.new(0, 0, 0.977, 0) })
	Tweens.Open({ Canvas = Notification, Speed = 0.25 })

	Delay(Duration, function()
		Tweens.Close({ Canvas = Notification, Speed = 0.25 })
		Wait(0.3)
		Notification:Destroy()
	end)
end

Utils.Popup = function(Title, Description, Callback)
	if not Options.Popups then Callback(); return end

	local New = Popup:Clone()
	local Content = New.Content
	local Bottom = New.Top

	local Close = function()
		Tweens.Close({
			Canvas = New,
			Speed = 0.25,
		})
	end

	Content.Title.Text = Title
	Content.Description.Text = Description
	New.Parent = Screen

	for Index, Button in next, Bottom:GetChildren() do
		if Button:IsA("GuiButton") then
			if Button.Name == "Confirm" then
				Library.Hover(Button, 0.2, Button.BackgroundColor3)
			else
				Library.Hover(Button, 0.2, Settings.Themes.Primary)
			end

			Connect(Button.MouseButton1Click, function()
				if Button.Name == "Confirm" then
					Callback()
				end

				Close()
			end)
		end
	end

	Tweens.Open({
		Canvas = New,
		Speed = 0.25,
	})
end

Utils.ColorPopup = function(Callback)
	local New = ColorPopup:Clone()
	New.Parent = Screen

	local Close = function()
		Tweens.Close({
			Canvas = New,
			Speed = 0.25,
		})
	end

	Tweens.Open({
		Canvas = New,
		Speed = 0.25,
	})

	local Color = nil

	Spawn(function()
		Color = Modules.ColorPicker:Setup(New, Callback)
	end)

	for Index, Button in next, New.Buttons:GetChildren() do
		if Button:IsA("GuiButton") then
			Library.Hover(Button, 0.2, Settings.Themes.Secondary)

			Connect(Button.MouseButton1Click, function()
				Close()
				Wait(0.5)
				New:Destroy()
			end)
		end
	end
end

-- Data [FUNCS]
Data = {}
Event = {}
Events = {}

Data.Webhook = {}

Data.new = function(Name, Info)
	if Checks.File then
		writefile(Format('Cmd/Data/%s', Name), Info)
	else
		warn("Exploit doesn't support file functions")
	end
end

Data.get = function(Name)
	if Checks.File and isfile(Format('Cmd/Data/%s', Name)) then
		return readfile(Format('Cmd/Data/%s', Name))
	elseif Checks.File then
		warn(Format("Couldn't find the data called %s", Name))
	end
end

Data.GetSetting = function(Info)
	local Settings = JSONDecode(Services.Http, Data.get("Settings.json") or JSONEncode(Services.Http, Settings))

	if Settings[Info] then
		return Settings[Info]
	else
		warn(Info)
		return false
	end
end

Data.SetSetting = function(Setting, Info)
	local Decoded = JSONDecode(Services.Http, Data.get("Settings.json") or JSONEncode(Services.Http, Settings))

	if Decoded[Setting] then
		Decoded[Setting] = Info
	end

	Settings[Setting] = Info

	Data.new("Settings.json", JSONEncode(Services.Http, Decoded));
end

Data.SaveTheme = function(ThemeTable)
	Library.LoadTheme(ThemeTable)
	local Themes = {}

	for Index, Color in next, ThemeTable do
		Themes[Index] = tostring(Color)
	end

	Data.new("Themes.json", JSONEncode(Services.Http, Themes));
end

Data.AddWaypoint = function(Name, Position)
	if Name and Position then
		local Table = JSONDecode(Services.Http, Data.get("Waypoints.json"));

		if not Table[Name] then
			Table[Name] = Position
			Data.new("Waypoints.json", JSONEncode(Services.Http, Table));
			Utils.Notify("Success", "Success!", Format("Added the Waypoint '%s'", Name))
			Env().Waypoints = Table
		else
			Utils.Notify("Error", "Error trying to save waypoint", Format("There's already a waypoint with the name '%s'", Name))
		end
	else
		Utils.Notify("Error", "Error!", "One or more arguments missing trying to make Waypoint")
	end
end

Data.DeleteWaypoint = function(Name)
	if Name then
		local Table = JSONDecode(Services.Http, Data.get("Waypoints.json"))

		if Table[Name] then
			Table[Name] = nil
			Data.new("Waypoints.json", JSONEncode(Services.Http, Table));
			Utils.Notify("Success", "Success!", Format("Deleted the Waypoint '%s'", Name))
		end
	else
		Utils.Notify("Error", "Error!", "Name missing")
	end
end

Data.SetUpThemeTable = function(ThemeTable)
	local Themes = {}

	for Index, Theme in next, ThemeTable do
		if Index ~= "Transparency" and Index ~= "Mode" then
			Themes[Index] = StringToRGB(Theme)
		elseif Index == "Transparency" then
			Themes[Index] = tonumber(Theme)
		else
			Themes[Index] = Theme
		end
	end

	return Themes
end

Data.SaveAlias = function(Command, Alias) 
	if Command and Alias then
		local AliasData = JSONDecode(Services.Http, Data.get("CustomAliases.json"))
		AliasData[Alias] = Command

		Data.new("CustomAliases.json", JSONEncode(Services.Http, AliasData));
	end
end

Data.SetOption = function(OptionName, Value)
	Options[OptionName] = Value
	Data.new("Toggles.json", JSONEncode(Services.Http, Options));
end

Data.Webhook.Send = function(Webhook, Message)
	request({
		Url = Webhook,
		Method = "POST",
		Headers = {
			["content-type"] = "application/json"
		};

		Body = JSONEncode(Services.Http, {
			["content"] = Message
		});
	})
end

Event.Default =  JSONEncode(Services.Http, { ["Executed"] = {}, ["Chat"] = {}, ["Respawn"] = {}, ["Died"] = {}, ["Damaged"] = {}, ["Leaving"] = {} })

if Checks.File then
	if not Data.get("Events.json") then
		Data.new("Events.json", Event.Default);
	end
	
	if not Data.get("Settings.json") then
		Data.new("Settings.json", JSONEncode(Services.Http, Settings));
	end
	
	if not Data.get("Themes.json") then
		local Themes = {}
	
		for Index, Color in next, Settings.Themes do
			Themes[Index] = tostring(Color)
		end
	
		Data.new("Themes.json", JSONEncode(Services.Http, Themes));
	end
	
	if not Data.get("CustomAliases.json") then
		Data.new("CustomAliases.json", JSONEncode(Services.Http, {}));
	end
	
	if not Data.get("Scale.json") then
		Data.new("Scale.json", "1");
	end
	
	if not Data.get("Waypoints.json") then
		Data.new("Waypoints.json", JSONEncode(Services.Http, {}));
	end
	
	if not Data.get("Toggles.json") then
		Data.new("Toggles.json", JSONEncode(Services.Http, Options));
	end

	Spawn(function()
		Events = JSONDecode(Services.Http, Data.get("Events.json") or Event.Default)
		Settings.Themes = Data.SetUpThemeTable(JSONDecode(Services.Http, Data.get("Themes.json")));

		local Themes = Settings.Themes;
		Settings = JSONDecode(Services.Http, Data.get("Settings.json") or JSONEncode(Services.Http, Settings));
		Settings.Themes = (Themes or Settings.Themes);
		Settings.ScaleSize = (Data.get("Scale.json") or 1);
		Options = JSONDecode(Services.Http, Data.get("Toggles.json") or JSONEncode(Services.Http, Options));

		if Settings and (not Settings.Version or Settings.Version ~= OriginalSettings.Version) then
			Utils.Notify("Information", "Outdated Settings", "Since your saved settings are outdated, Cmd has reset them. Do not worry, your prefix & themes are still the same", 15)

			for Index, Setting in next, OriginalSettings do
				if Index ~= "Prefix" and Index ~= "Themes" and Index ~= "ScaleSize" and Index ~= "Blur" then
					Settings[Index] = Setting
				end
			end

			if Settings.Blur == nil then
				Settings.Blur = false
			end

			Data.new("Settings.json", JSONEncode(Services.Http, Settings));
		end
	end)
end

SetUIScale = function(Scale)
	if not tonumber(Scale) then return end
	Settings.ScaleSize = tonumber(Scale)

	for Index, UIScale in next, Screen:GetDescendants() do
		if UIScale:IsA("UIScale") and UIScale.Name == "DeviceScale" then
			UIScale.Scale = tonumber(Scale)
		end
	end

	if Checks.File then
		Data.new("Scale.json", tostring(Scale))
	end
end

-- Command [LIBRARY]
Command.Add = function(Information)
	local Aliases = Information.Aliases;
	local Description = Information.Description;
	local Arguments = Information.Arguments;
	local Plugin = Information.Plugin;
	local Task = Information.Task;

	for Index, Value in next, Aliases do
		Index = Lower(Value)
	end

	Commands[Aliases[1]] = { Aliases, Description, Arguments, Plugin, Task } 
	Command.Count = Command.Count + 1
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

Command.Run = function(Name, Callbacks)
	Spawn(function()
		local Table = Command.Find(Name)

		if Table and Name ~= Blank then
			local Callback = Table[5]

			xpcall(function() 
				Callback(Unpack(Callbacks))
			end, function(Result) 
				warn(Format("[COMMAND ERROR] : Error occured trying to run the command - %s\nERROR: %s", Name, Result))
			end)

		elseif Name ~= Blank then
			Utils.Notify("Error", "Command not found", Format("The command <b>%s</b> doesn't exist", Name), 5)
		end
	end)
end

Command.Parse = function(Input)
	if Screen.Parent then
		local Name, ArgsString = GSub(Input, Settings.Prefix, Blank):match("^%s*([^%s]+)%s*(.*)$")

		if Name then
			local Arguments = {}
			for arg in ArgsString:gmatch("%s*([^"..Settings.Seperator .."]+)") do
				Insert(Arguments, arg)
			end

			FullArgs = Arguments
			Command.Run(Lower(Name), Arguments)
		end
	end
end

Command.Whitelist = function(Player)
	Admins[Player.UserId] = true
	Connect(Player.Chatted, function(Message)
		if Admins[Player.UserId] and Match(Message, "^%p") then
			Command.Parse(Message);
		end
	end)
end

Command.RemoveWhitelist = function(Player)
	Admins[Player.UserId] = false
end

Autofills.Recommend = function(Input)
	if not Options.Recommendation then 
		Recommend.Text = Blank; return
	end

	local Lowered = Lower(Split(Input, ' ')[1])
	local Found = false

	if #Split(Input, ' ') == 1 then
		for Index, Table in Commands do
			for Index, Name in Table[1] do
				if Find(Sub(Name, 1, #Lowered), Lower(Lowered)) or Name == Lowered then
					Tween(pressTab, TweenInfo.new(0.35), { TextTransparency = 0 })
					Recommend.Text = GSub(Name, Lowered, Split(Input, " ")[1])
					Found = true
				end
			end
		end
	end

	if #Split(Input, " ") > 1 and Screen.Parent then
		local Command = Command.Find(Lowered)
		if Command then
			local Arguments = Command[3]
			local New = Split(Input, " ")

			if #Arguments > 0 then
				if Arguments[#New - 1] and Arguments[#New - 1].Type == "Player" then
					local PlayerFound = false
					local Player = New[#New]
					for Index, Plr in next, Services.Players:GetPlayers() do
						if Find(Sub(Lower(Plr.DisplayName), 1, #Player), Lower(Player)) then
							local Name = Format(" %s", GSub(Lower(Plr.DisplayName), Lower(Player), Player))
							Recommend.Text = Sub(Input, 1, #Input - #Player - 1) .. Name
							Found = true
							PlayerFound = true
						end
					end

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
		Tween(pressTab, TweenInfo.new(0.35), { TextTransparency = 1 })
		Recommend.Text = Blank
	end
end

local OldHealth = 100

Event.New = function(Name, Connection, UseHumanoid, HumanoidProperty, HumanoidCheck, ConnectionFunction) 
	if not Screen then return end 

	if Checks.File then
		Events[Name] = (JSONDecode(Services.Http, Data.get("Events.json") or "{'Name': {}}, ")[Name]) or {}
	else
		Events[Name] = {}
	end

	if Name == "Executed" then
		for Index, Cmd in next, Events[Name] do
			Command.Parse(Cmd)
		end
	elseif UseHumanoid and HumanoidProperty then
		Connect(PropertyChanged(Local.Character.Humanoid, HumanoidProperty), function() 
			if HumanoidCheck(Local.Character.Humanoid) then
				for Index, Cmd in next, Events[Name] do
					Command.Parse(Cmd)
				end
			end
		end)

		Local.Player.CharacterAdded:Connect(function(Char)
			Wait(.5);
			local Humanoid = Char:WaitForChild("Humanoid");
			OldHealth = 100

			Connect(PropertyChanged(Local.Character.Humanoid, HumanoidProperty), function() 
				if HumanoidCheck(Local.Character.Humanoid) then
					for Index, Cmd in next, Events[Name] do
						Command.Parse(Cmd)
					end
				end
			end)
		end)
	elseif ConnectionFunction then
		Connect(Connection, function(Connect) 
			if ConnectionFunction(Connect) then
				for Index, Cmd in next, Events[Name] do
					Command.Parse(Cmd);
				end
			end
		end)
	else
		Connect(Connection, function() 
			for Index, Cmd in next, Events[Name] do
				Command.Parse(Cmd);
			end
		end)
	end
end

Event.AddCommand = function(Event, Command)
	if not Screen then return end 

	if Events[Event] then
		Insert(Events[Event], Command)

		local SavedEvents = JSONDecode(Services.Http, Data.get("Events.json") or Event.Default);
		local SavedEvent = Events[Event];

		if not Discover(SavedEvent, Command) then
			SavedEvent[#SavedEvent + 1] = Command
		end

		Data.new("Events.json", JSONEncode(Services.Http, Events));
	end
end

if Checks.File then
	Events = JSONDecode(Services.Http, Data.get("Events.json") or Event.Default);
end

-- Admin [COMMANDS]

Command.Add({
	Aliases = { "tutorial" },
	Description = "Explanation on how to use Cmd",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Tutorial") then

			local Main = Tab.new({
				Title = "Tutorial",
				Drag = true
			})

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll


			Library.new("Label", { Title = "Seperating arguments for running commands", Description = "To seperate the arguments for example ;command arg1, arg2 - you need to seperate it using a ',' (comma)", Parent = MainTab })
			Library.new("Label", { Title = "Player arguments", Description = "The current arguments for getting players are - their username, their displayname, all, others, seated, stood, me, closest, farthest, *team_name, enemies, dead, alive, friends, nonfriends", Parent = MainTab })
			Library.new("Label", { Title = "Adding plugins", Description = "For a tutorial on how to add plugins visit - github.com/lxte/cmd/wiki/Plugins", Parent = MainTab })
			Library.new("Label", { Title = "Applying themes", Description = "To apply themes open the Settings tab (by using the 'settings' command), and go to the Themes section. There you can edit them.", Parent = MainTab })

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Tutorial"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "fakechat" },
	Description = "Sends a FAKE message in the chat",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("FakeChat") then

			local Main = Tab.new({
				Title = "FakeChat",
				Drag = true
			})

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll
			local Disguise, User, Text = nil, nil, nil

			local Send = function(Message, Player, FakeMessage)
				local Character = " "
				local Amount = 125

				Amount = Amount - #Local.Player.Name - #Message
				Chat(Message .. Character:rep(Amount) .. Format("[%s]: %s", Player, FakeMessage))
			end

			local Search = Library.new("Input", { 
				Title = "Your Message",
				Description = "The message that will be disguised",
				Parent = MainTab,
				Default = Blank,
				Callback = function(Message)
					Disguise = Message
					Utils.Notify("Success", "Success!", Format("Set YOUR message as %s", Message))
				end,
			})

			local Search = Library.new("Input", { 
				Title = "Player Name",
				Description = "The player's name you want to chat as",
				Parent = MainTab,
				Default = Blank,
				Callback = function(Message)
					User = Message
					Utils.Notify("Success", "Success!", Format("Set the player's name as %s", Message))
				end,
			})

			local Search = Library.new("Input", { 
				Title = "Player's message",
				Description = "The player's message you want them to say",
				Parent = MainTab,
				Default = Blank,
				Callback = function(Message)
					Text = Message
					Utils.Notify("Success", "Success!", Format("Set the text as %s", Message))
				end,
			})

			local Search = Library.new("Button", { 
				Title = "Send Message",
				Description = "Sends the fake message",
				Parent = MainTab,
				Callback = function()
					if Disguise and User and Text then
						Send(Disguise, User, Text)
					else
						Utils.Notify("Error", "Error!", "One or more arguments missing")
					end
				end,
			})

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("FakeChat"), Speed = 0.3 })
		end
	end,
})


Command.Add({
	Aliases = { "commands", "cmds" },
	Description = "See all the commands",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Commands") then

			local Main = Tab.new({
				Title = "Commands",
				Drag = true
			})

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			Tweens.Open({ Canvas = Main, Speed = 0.3 })

			local ShowResults = function(Message)
				Message = Message:lower()

				for Index, Cmd in next, MainTab:GetChildren() do
					if Cmd.Name == "Label" and Cmd:IsA("Frame") then
						local Title = Cmd.Content.Title
						Cmd.Visible = Find(Lower(Title.Text), Message)
					end
				end
			end

			local Search = Library.new("Input", { 
				Title = "Search",
				Parent = MainTab,
				Default = Blank,
				Callback = function(Message)
					ShowResults(Message)
				end,
			})

			Connect(PropertyChanged(Search, "Text"), function()
				ShowResults(Search.Text)
			end)

			for Index, Table in next, Commands do
				Wait()
				local Aliases = Table[1]
				local Description = Table[2]
				local Arguments = Table[3]
				local Plugin = Table[4]
				local Argument = Blank
				local ArgAmount = 1
				local Arg = Concat(Aliases, " / ")

				-- Argument Description

				if #Arguments > 0 then
					for Index, Arg in Arguments do
						if Index and Arg then
							local Name = Arg.Name
							local Type = Arg.Type
							local Seperate = Blank

							if ArgAmount > 1 then
								Seperate = ", "
							end

							Argument = Argument .. Format("%s%s (%s)", Seperate, Name, Type)
							ArgAmount = ArgAmount + 1
						end
					end
				end

				-- UI

				if Argument ~= Blank then
					Library.new("Label", { 
						Title = Arg, 
						Description = Format("%s\nArguments: %s", Description, Argument), 
						Parent = MainTab 
					})
				else
					Library.new("Label", { 
						Title = Arg, 
						Description = Description, 
						Parent = MainTab 
					})
				end
			end
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Commands"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "waypoints" },
	Description = "Tab that allows you to use and create waypoints",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Waypoints") then

			local Main = Tab.new({
				Title = "Waypoints",
				Drag = true
			})

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll
			local WaypointName = nil

			local Waypoints = Library.new("Switch", { 
				Title = "Waypoints",
				Description = "List of waypoints you've saved",
				Parent = MainTab,
			})

			local AddWaypoint = Library.new("Switch", { 
				Title = "Add Waypoint",
				Description = "Add a brand new waypoint",
				Parent = MainTab,
			})

			Library.new("Input", { 
				Title = "Delete Waypoint",
				Description = "Input the name of the Waypoint you'd like to delete",
				Parent = MainTab,
				Default = "WaypointName",
				Callback = function(Waypoint)
					Data.DeleteWaypoint(Waypoint)
				end,
			})

			local ShowWaypointResults = function(Message)
				Message = Message:lower()

				for Index, Waypoint in next, Waypoints:GetChildren() do
					if Waypoint.Name == "Button" and Waypoint:IsA("GuiButton") and Waypoint.Name ~= "Example" then
						local Title = Waypoint.Content.Title
						Waypoint.Visible = Find(Lower(Title.Text), Message)
					end
				end
			end

			local Search = Library.new("Input", { 
				Title = "Search",
				Parent = Waypoints,
				Default = Blank,
				Callback = function(Message)
				end,
			})

			Connect(PropertyChanged(Search, "Text"), function()
				ShowWaypointResults(Search.Text)
			end)


			local AddWayPointButton = function(WaypointTable)
				local Name, CFrame = WaypointTable[1], WaypointTable[2]


				local Waypoint = Library.new("Button", { 
					Title = Name,
					Parent = Waypoints,
					Callback = function()
						GetRoot(Local.Character).CFrame = CFrame
					end,
				})

			end

			Library.new("Input", { 
				Title = "Waypoint Name",
				Description = "Name of the waypoint you're creating",
				Parent = AddWaypoint,
				Default = Blank,
				Callback = function(Waypoint)
					WaypointName = Waypoint
					Utils.Notify("Success", "Success", Format("Waypoint name is now set to '%s'", Waypoint))
				end,
			})

			Library.new("Button", { 
				Title = "Create Waypoint",
				Description = "Create your brand new waypoint",
				Parent = AddWaypoint,
				Callback = function()
					local Root = GetRoot(Local.Character)

					if Root then
						Data.AddWaypoint(WaypointName, tostring(Root.CFrame))
						AddWayPointButton({ WaypointName, Root.CFrame })
					else
						Utils.Notify("Error", "Error", "HumanoidRootPart not found")
					end
				end,
			})

			if Checks.File then
				for Index, Waypoint in next, JSONDecode(Services.Http, Data.get("Waypoints.json")) do
					AddWayPointButton({Index, CFrame.new(Unpack(Waypoint:gsub(" ",Blank):split(",")))})
				end
			end

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Waypoints"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "servers" },
	Description = "Lists all other servers",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Servers") then

			local Main = Tab.new({
				Title = "Servers",
				Drag = true
			})

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll	
			local URL = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?limit=100"
			local ServerTable = {}
			local Info = game:GetService("HttpService"):JSONDecode(game:HttpGetAsync(URL))

			for Index, Server in next, Info.data do
				if type(Server) == "table" and Server.maxPlayers > Server.playing then
					Insert(ServerTable, {Server.ping, Server.id, Server.playing, Server.maxPlayers})
				end
			end

			for Index, Info in next, ServerTable do
				Library.new("Button", { 
					Title = tostring(Info[2]),
					Description =  Format('Ping: %s \n%s/%s Players', tostring(Info[1]), tostring(Info[3]), tostring(Info[4])),
					Parent = MainTab,
					Callback = function()
						Services.Teleport:TeleportToPlaceInstance(game.PlaceId, Info[2], Local.Player)
					end,
				})
			end

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Servers"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "bind" },
	Description = "Add a command bind",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Bind") then
			local Main = Tab.new({
				Title = "Bind",
				Drag = true
			})

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			local Binds = Library.new("Switch", { 
				Title = "Binds",
				Description = "Shows a list of all the keybinds",
				Parent = MainTab,
			})

			local AddBind = function(Table)
				local Name = Table.Name
				local Start = Table.Start
				local End = Table.End
				local KeyCode = Table.KeyCode

				if not Settings.Binds[KeyCode] then
					Settings.Binds[KeyCode] = {
						Start = Start,
						End = End,
						Nickname = Name,
					}

					local NewSwitch = Library.new("Switch", { 
						Title = Name,
						Description = "Information about this bind",
						Parent = Binds,
					})

					Library.new("Label", { 
						Title = "Input began command",
						Description = Start,
						Parent = NewSwitch,
					})

					Library.new("Label", { 
						Title = "Input ended command",
						Description = End,
						Parent = NewSwitch,
					})

					Library.new("Label", { 
						Title = "KeyCode",
						Description = tostring(KeyCode),
						Parent = NewSwitch,
					})

					Library.new("Button", { 
						Title = "Delete bind",
						Description = "Deletes the bind",
						Parent = NewSwitch,
						Callback = function()
							Utils.Popup("Confirmation", Format("Are you sure you want to remove the '%s' bind?", Name), function()
								Settings.Binds[KeyCode] = nil
								Utils.Notify("Success", "Success!", "Bind has been removed")
							end)
						end,
					})

				else
					Utils.Notify("Error", "Error!", Format("A bind already exists with this keybind! (Keybind - %s", tostring(KeyCode)))
				end
			end

			Library.new("Button", { 
				Title = "New Bind",
				Description = "Create a new command keybind!",
				Parent = MainTab,

				Callback = function()
					local Popup, Scroll = Tab.Popup(Main, "Add a new bind")

					local Info = {
						Start = false,
						End = false,
						Bind = false,
						Nickname = nil,
					}

					Tab.ShowPopup(Popup)

					Library.new("Input", { 
						Title = "Bind Name",
						Description = "The name of the bind (REQUIRED)",
						Parent = Scroll,
						Default = Blank,
						Callback = function(Nick)
							Info.Nickname = Nick
						end,
					})

					Library.new("Input", { 
						Title = "Bind Start",
						Description = "Command that runs when you begin holding the key",
						Parent = Scroll,
						Default = Blank,
						Callback = function(Cmd)
							Info.Start = Cmd
						end,
					})

					Library.new("Input", { 
						Title = "Bind End",
						Description = "Command that runs when you stop holding the selected key",
						Parent = Scroll,
						Default = Blank,
						Callback = function(Cmd)
							Info.End = Cmd
						end,
					})

					Library.new("Bind", { 
						Title = "KeyCode",
						Description = "The key (letter) that fires the commands when pressed",
						Parent = Scroll,
						Callback = function(Key)
							Info.Bind = Key
						end,
					})

					Library.new("Button", { 
						Title = "Create",
						Description = "Create the keybind!",
						Parent = Scroll,
						Callback = function()
							local Start, End, Bind, Nickname = Info.Start, Info.End, Info.Bind, Info.Nickname

							if Start and End and Bind and Nickname then
								AddBind({
									Name = Nickname,
									Start = Start,
									End = End,
									KeyCode = Bind,
								})

								Utils.Notify("Success", "Success!", "Bind made!")
							else
								Utils.Notify("Error", "Error!", "Missing one or more arguments, couldn't make bind")
							end
						end,
					})		
				end,
			})

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Bind"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "settings", "options" },
	Description = "Modify all the Settings of Cmd",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Settings") then
			local Main = Tab.new({ Title = "Settings", Drag = true })
			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			-- Tabs
			local Information = Library.new("Switch", { Title = "Information", Description = "Get info about Cmd", Parent = MainTab })
			local EventSwitch = Library.new("Switch", { Title = "Events", Description = "Run commands whenever something happens", Parent = MainTab })
			local Aliases = Library.new("Switch", { Title = "Aliases", Description = "Add custom aliases (nicknames) for commands!", Parent = MainTab })
			local Toggles = Library.new("Switch", { Title = "Toggles", Description = "Enable or Disable certain Cmd options", Parent = MainTab })	
			local Themes = Library.new("Switch", { Title = "Themes", Description = "Modify the appearance of Cmd", Parent = MainTab })	
			local Default = Library.new("Switch", { Title = "Default Themes", Description = "Default Themes on Cmd", Parent = Themes })
			local Custom = Library.new("Switch", { Title = "Custom", Description = "Make your own custom theme", Parent = Themes })

			-- Information
			Library.new("Section", { Title = "Discord", Parent = Information })

			Library.new("Label", { Title = "Join our Discord!",
				Description = "discord.com/invite/qXcMYSgQ",
				Parent = Information 
			})

			Library.new("Section", { Title = "Cmd", Parent = Information })

			Library.new("Label", { Title = "Commands loaded",
				Description = tostring(Command.Count),
				Parent = Information 
			})

			Library.new("Label", { Title = "Version",
				Description = Settings.Version,
				Parent = Information 
			})

			Library.new("Label", { Title = "Prefix",
				Description = Settings.Prefix,
				Parent = Information 
			})

			Library.new("Label", { Title = "Player Seperator",
				Description = Format("kill player1%splayer2", Settings.Player),
				Parent = Information 
			})

			Library.new("Label", { Title = "UI Scale Size",
				Description = tostring(Settings.ScaleSize),
				Parent = Information 
			})

			-- Events
			Library.new("Section", { Title = "Add Events", Parent = EventSwitch })

			local AddEventBindButton = function(EventName, Description) 
				local EventCommand = nil

				Library.new("Button", { 
					Title = EventName,
					Description = Description,
					Parent = EventSwitch,
					Callback = function()
						local Popup, Scroll = Tab.Popup(Main, "Add a new bind")
	
						Tab.ShowPopup(Popup)
	
						Library.new("Input", { 
							Title = "Command",
							Description = "The command you want to run (Arguments can be inputted too!)",
							Parent = Scroll,
							Default = Blank,
							Callback = function(Cmd)
								EventCommand = Cmd
							end,
						})
	
						
						Library.new("Button", { 
							Title = "Create",
							Description = "Create the Event!",
							Parent = Scroll,
							Callback = function()
								if EventCommand then
									Event.AddCommand(EventName, EventCommand)
									Utils.Notify("Success", "Success!", "Event command made!")
								else
									Utils.Notify("Error", "Error!", "Could not find Command")
								end
							end,
						})		
					end,
				})
			end

			AddEventBindButton("Executed", "Runs a command as soon as Cmd is executed");
			AddEventBindButton("Chat", "Runs a command as soon as you chat something");
			AddEventBindButton("Respawn", "Runs a command as soon as your character respawns");
			AddEventBindButton("Died", "Runs a command as soon as your character dies");
			AddEventBindButton("Damaged", "Runs a command as soon as your character dies");
			AddEventBindButton("Leaving", "Runs a command as soon as you're about to leave");

			Library.new("Section", { Title = "Remove Events", Parent = EventSwitch })

			local DeleteEventType, DeleteEvent = nil, nil

			Library.new("Input", { 
				Title = "Event Type",
				Description = "Example; Damaged",
				Parent = EventSwitch,
				Default = Blank,
				Callback = function(Cmd)
					DeleteEventType = Cmd
				end,
			})

			Library.new("Input", { 
				Title = "Event Command",
				Description = "Example; goto random",
				Parent = EventSwitch,
				Default = Blank,
				Callback = function(Cmd)
					DeleteEvent = Cmd
				end,
			})

			Library.new("Button", { 
				Title = "Delete",
				Description = "Delete the event",
				Parent = EventSwitch,
				Callback = function()
					local Type = Events[DeleteEventType] or {} 

					for Index, Event in next, Type do
						if Lower(Event) == Lower(DeleteEvent) then
							Type[Index] = nil
						end
					end

					Data.new("Events.json", JSONEncode(Services.Http, Events))
				end,
			})

			-- Aliases
			local CommandInputted = nil
			local AliasInputted = nil

			Library.new("Section", { Title = "Add Aliases", Parent = Aliases })

			Library.new("Input", { Title = "Command Name", Description = "The name for the command you're trying to add an alias to", Default = Blank, Parent = Aliases, Callback = function(Input) 
				CommandInputted = Input
			end})

			Library.new("Input", { Title = "Alias Name", Description = "The alias you want the command to be called", Default = Blank, Parent = Aliases, Callback = function(Input) 
				AliasInputted = Input
			end})

			Library.new("Button", { 
				Title = "Set Alias",
				Description = "Set the alias for the command",
				Parent = Aliases,
				Callback = function()
					if CommandInputted and AliasInputted and not Command.Find(AliasInputted) then
						local Cmd = Command.Find(Lower(CommandInputted))

						if Cmd and AliasInputted then
							local Aliases = Cmd[1]
							Aliases[#Aliases + 1] = Lower(AliasInputted)
							Data.SaveAlias(CommandInputted, AliasInputted)
							Utils.Notify("Success", "Success!", Format("Added alias '%s' to command '%s'", Lower(AliasInputted), CommandInputted), 10)
						else
							Utils.Notify("Error", "Error!", "Command not found, check for any spelling mistakes", 5)
						end

					else
						Utils.Notify("Error", "Error!", "One or more arguments missing OR Alias already exists", 5)
					end
				end,
			})

			Library.new("Section", { Title = "Delete Aliases", Parent = Aliases })

			Library.new("Input", { Title = "Delete Alias", Description = "Deletes the CUSTOM Alias you put", Default = Blank, Parent = Aliases, Callback = function(Input) 
				local Alias = JSONDecode(Services.Http, Data.get("CustomAliases.json"));

				if Alias then
					for Aliases, Cmd in next, Alias do
						if Aliases == Lower(Input) then
							Alias[Input] = nil
							Utils.Notify("Success", "Success", "Deleted alias successfully", 5)
						end
					end
				end

				Data.new("CustomAliases.json", JSONEncode(Services.Http, Alias));
			end})

			-- Toggles

			Library.new("Section", { Title = "Interface Options", Parent = Toggles })

			Library.new("Toggle", { Title = "Show Notifications",
				Description = "If disabled, it will not show you any notifications",
				Default = Options.Notifications,
				Parent = Toggles,
				Callback = function(Boolean)
					Data.SetOption("Notifications", Boolean)
				end,
			})

			Library.new("Toggle", { Title = "Show Popups",
				Description = "If disabled, any popups sent will be automatically accepted",
				Default = Options.Popups,
				Parent = Toggles,
				Callback = function(Boolean)
					Data.SetOption("Popups", Boolean)
				end,
			})

			Library.new("Toggle", { Title = "Command Bar Recommend",
				Description = "If enabled it will give you recommendations for commands if you type something in the Command Bar",
				Default = Options.Recommendation,
				Parent = Toggles,
				Callback = function(Boolean)
					Data.SetOption("Recommendation", Boolean)
				end,
			})

			Library.new("Toggle", { Title = "Anti Interfere",
				Description = "Any other Command Bars like Cmdr & Kohls Admin won't show",
				Default = Options.AntiInterfere,
				Parent = Toggles,
				Callback = function(Boolean)
					Data.SetOption("AntiInterfere", Boolean)
				end,
			})

			Library.new("Section", { Title = "Automatic Options", Parent = Toggles })

			Library.new("Toggle", { Title = "Automatic Logging",
				Description = "Automatically logs CHAT messages, even before you ran the logs command",
				Default = Options.Logging,
				Parent = Toggles,
				Callback = function(Boolean)
					Data.SetOption("Logging", Boolean)
				end,
			})

			Library.new("Toggle", { Title = "Automatic Simulation Radius",
				Description = "Automatically sets your simulation radius to 9e9",
				Default = Options.AutoSimRadius,
				Parent = Toggles,
				Callback = function(Boolean)
					Data.SetOption("AutoSimRadius", Boolean)
				end,
			})

			-- Themes
			Library.new("Input", { Title = "Transparency", Description = "Set transparency of the UI", Default = "0.05", Parent = Themes, Callback = function(Input) 
				local Numeral = tonumber(Input)

				if Numeral and Numeral < 0.9 then
					Settings.Themes.Transparency = Numeral
					Library.LoadTheme()
				end
			end})

			Library.new("Input", { Title = "UIScale", Description = "Set the Scale of the UI.\nDefault - 1", Default = tostring(Settings.ScaleSize), Parent = Themes, Callback = function(Input) 
				local Numeral = tonumber(Input)

				if Numeral and Numeral < 2 and Numeral > 0.2 then
					SetUIScale(Numeral)

					Utils.Notify("Success", "Success!", "Set and saved your UIScale successfully!", 15)
				else
					Utils.Notify("Error", "Error!", "Couldn't set UIScale, make sure that the value inputted is more than 0.2 and less than 2!", 15)
				end
			end})

			Library.new("Toggle", { Title = "UI Blurring",
				Description = "Blurs the background of the UI (Graphics need to be set to 8+), recommended transparency - 0.1",
				Default = Settings.Blur,
				Parent = Themes,
				Callback = function(Boolean)
					Settings.Blur = Boolean

					if Boolean then
						local Ignore = { "Command", "Library", "Notification", "Open", "Popup", "ColorPopup", "Source" }

						Foreach(Blurred, function(Index, Self) 
							if Self.owner.Visible then
								Self.root.Parent = workspace.CurrentCamera
							end
						end)

						Foreach(Screen:GetChildren(), function(Index, Child) 
							if not Discover(Ignore, Child.Name) then
								if not Blurred[Child.Name] then
									Blurred[Child.Name] = Modules.Blur.new(Child, 5)
								end

								if Child.Visible then
									Blurred[Child.Name].root.Parent = workspace.CurrentCamera
								else
									Blurred[Child.Name].root.Parent = nil
								end
							end
						end)
					else
						Foreach(Blurred, function(Index, Self) 
							Self.root.Parent = nil
						end)
					end

					Data.new("Settings.json", JSONEncode(Services.Http, Settings))
				end,
			})

			Library.new("Button", { 
				Title = "Save Theme",
				Description = "Save the current theme you have applied",
				Parent = Custom,
				Callback = function()
					Data.SaveTheme(Settings.Themes)
					Utils.Notify("Success", "Success!", "Theme has been saved", 5)
				end,
			})

			local ThemeDescriptions = {
				["Primary"] = "Changes the background color of Cmd", ["Secondary"] = "Changes the secondary color of Cmd (buttons, topbar, etc.)", ["Title"] = "Changes the Text Color of the Titles", ["Description"] = "Changes the Text Color of descriptions", ["Icon"] = "Changes the color of all icons", ["Shadow"] = "Changes the color of the outlines around Tabs, etc.", ["Outline"] = "Changes the color of outlines inside of Tabs, etc."
			}

			for Index, Theme in next, Settings.Themes do
				if Index ~= "Transparency" and Index ~= "Mode" then
					Library.new("Button", { 
						Title = Index,
						Description = ThemeDescriptions[Index] or Blank,
						Parent = Custom,
						Callback = function()
							Utils.ColorPopup(function(RGB)
								if RGB then
									Settings.Themes[Index] = RGB
									Library.LoadTheme(Settings.Themes)
								else
									Utils.Notify("Error", "Error!", "Failed to get RGB value", 5)
								end
							end)
						end,
					})
				end
			end

			for Index, Theme in Library.Themes do
				Library.new("Button", { 
					Title = Index,
					Parent = Default,
					Callback = function()
						Theme()
					end,
				})
			end

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Settings"), Speed = 0.3 })
		end
	end,
})

local ESPSettings = {
	Fill = 0.5,
	Outline = 0,
	NameTagTransparency = 0.2,
	NameTagSize = 12,
	Current = false,
	TargetsOnly = false,
}

xpcall(function()
	ESPSettings.Holder =  Instance.new("BillboardGui", game.CoreGui);
end, function()
	ESPSettings.Holder = Instance.new("BillboardGui", Local.Player.PlayerGui);
end)

ESPSettings.InfoESP = function(Target)
	Spawn(function()
		local Char = Target.Character

		if Char and not ESPSettings.Holder:FindFirstChild(Target.Name) and Target ~= Local.Player then
			local Head = Char:WaitForChild("Head");
			local Billboard = Instance.new("BillboardGui", ESPSettings.Holder);
			local InfoTag = Instance.new("TextLabel", Billboard);

			Billboard.Size = UDim2.new(0, 200, 0, 24)
			Billboard.SizeOffset = Vector2.new(0, 1)
			Billboard.AlwaysOnTop = true
			Billboard.Name = Target.Name
			Billboard.Adornee = Head

			InfoTag.BackgroundTransparency = 1
			InfoTag.Size = UDim2.new(1, 0, 1, 0)
			InfoTag.TextSize = NameTagSize or 12
			InfoTag.TextColor3 = Color3.new(255, 255, 255)
			InfoTag.Font = Enum.Font.ArialBold
			InfoTag.AnchorPoint = Vector2.new(0.5, 0.5)
			InfoTag.Position = UDim2.new(0.5, 0, 0.5, 0)
			InfoTag.TextXAlignment = "Center"
			InfoTag.RichText = true
			InfoTag.TextTransparency = NameTagTransparency or 0.2
			InfoTag.ZIndex = 100

			repeat Wait(0.2) 
				InfoTag.Text = Format("<b>%s</b> <font color='rgb(200, 200, 200)'>(%s)</font>\n[%s] [%s / 100]", tostring(Target.DisplayName), tostring(Target.Name), tostring(math.floor((Local.Character.Head.Position - Head.Position).Magnitude)), tostring(Char.Humanoid.Health))
			until Char.Humanoid.Health == 0 or not Billboard or not Head or not Target

			Billboard:Destroy()
		end
	end)
end

ESPSettings.RemoveInfo = function(Target)
	if ESPSettings.Holder:FindFirstChild(Target.Name) then
		ESPSettings.Holder:FindFirstChild(Target.Name):Destroy()
	end
end

Command.Add({
	Aliases = { "esp", },
	Description = "See players through walls",
	Arguments = {},
	Plugin = false,
	Task = function()

		local AddHighlight = function(Bool, Transparency, Fill, Player)
			Spawn(function()
				if Player and Player.Character and Player ~= Local.Player then
					local Char = Player.Character;
					local Humanoid = Char:WaitForChild("Humanoid");
					local Find = Char:FindFirstChildOfClass("Highlight");

					if ESPSettings.TargetsOnly and Player.Team == Local.Player.Team then
						if Find then
							Find:Destroy();
						end

						ESPSettings.RemoveInfo(Player);
					else
						if Bool then
							local Highlight = Instance.new("Highlight", Char);
							ESPSettings.RemoveInfo(Player);
							ESPSettings.InfoESP(Player);

							if Find then
								Find:Destroy()
							end

							Highlight.OutlineTransparency = Transparency;
							Highlight.FillTransparency = Fill;
							Highlight.FillColor = Player.TeamColor.Color;
							ESPSettings.Outline = Transparency;
							ESPSettings.Fill = Fill;
						else
							ESPSettings.RemoveInfo(Player);

							if Find then
								Find:Destroy();
							end
						end
					end
				end
			end)
		end

		local SetESP = function(Bool, Transparency, Fill)
			ESPSettings.Outline = Transparency
			ESPSettings.Fill = Fill

			for Index, Player in next, Services.Players:GetPlayers() do
				local Character = Character(Player)

				if Character then
					Spawn(function()
						AddHighlight(Bool, Transparency, Fill, Player);
					end)
				end
			end
		end

		if not Screen:FindFirstChild("ESP") then
			local Main = Tab.new({ Title = "ESP", Drag = true })
			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			Library.new("Toggle", { Title = "Enabled",
				Description = "Switch to enable the ESP",
				Default = false,
				Parent = MainTab,
				Callback = function(Boolean)
					SetESP(Boolean, ESPSettings.Outline, ESPSettings.Fill)
					ESPSettings.Current = Boolean
				end,
			})

			Library.new("Toggle", { Title = "Targets Only",
				Description = "Shows ESP for targets only",
				Default = false,
				Parent = MainTab,
				Callback = function(Boolean)
					ESPSettings.TargetsOnly = Boolean
					SetESP(ESPSettings.Current, ESPSettings.Outline, ESPSettings.Fill)
				end,
			})

			Library.new("Input", { Title = "Outline Transparency",
				Description = "Change the transparency of the outlines",
				Default = 0,
				Parent = MainTab,
				Callback = function(Input)
					Outline = SetNumber(Input)
					SetESP(ESPSettings.Current, Outline, ESPSettings.Fill)
				end,
			})

			Library.new("Input", { Title = "Fill Transparency",
				Description = "Change the transparency of the ESP Fill",
				Default = 0.5,
				Parent = MainTab,
				Callback = function(Input)
					Fill = SetNumber(Input);
					SetESP(ESPSettings.Current, ESPSettings.Outline, Fill);
				end,
			})

			Library.new("Input", { Title = "Name Tag Transaparency",
			Description = "The transparency of player name tags",
			Default = 0.2,
			Parent = MainTab,
			Callback = function(Input)
					ESPSettings.NameTagTransparency = SetNumber(Input);
					
					for Index, Billboard in next, ESPSettings.Holder:GetChildren() do
						local NameTag = Billboard:FindFirstChildOfClass("TextLabel");

						if NameTag then
							NameTag.TextTransparency = SetNumber(Input)
						end
					end
				end,
			})

			Library.new("Input", { Title = "Name Tag Size",
			Description = "The Size of player name tags",
			Default = 12,
			Parent = MainTab,
			Callback = function(Input)
					ESPSettings.NameTagSize = SetNumber(Input);
					
					for Index, Billboard in next, ESPSettings.Holder:GetChildren() do
						local NameTag = Billboard:FindFirstChildOfClass("TextLabel");

						if NameTag then
							NameTag.TextSize = SetNumber(Input)
						end
					end
				end,
			})


			for Index, Player in next, Services.Players:GetPlayers() do
				local Char = Character(Player);
				AddHighlight(ESPSettings.Current, ESPSettings.Outline, ESPSettings.Fill, Player);

				Connect(Player.CharacterAdded, function(Char)
					AddHighlight(ESPSettings.Current, ESPSettings.Outline, ESPSettings.Fill, Player);
				end)
			end

			Connect(Services.Players.PlayerAdded, function(Player)
				local Char = Character(Player)
				AddHighlight(ESPSettings.Current, ESPSettings.Outline, ESPSettings.Fill, Player);

				Connect(Player.CharacterAdded, function(Char)
					AddHighlight(ESPSettings.Current, ESPSettings.Outline, ESPSettings.Fill, Player);
				end)
			end)

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("ESP"), Speed = 0.3 })
		end
	end,
})

local Aimbot = {
	Camlock = false,
	Part = "Head",
	PartIsRandom = false,
	TeamCheck = true,
	Held = false,
	Key = Enum.KeyCode.E,
	Prediction = 0,
	Wallcheck = false,
	FOV = {
		Radius = 100,
	},
	Target = nil,
}

Aimbot.BehindWall = function(Target) 
	if Target and Target.Character and Target ~= Local.Player then 
		local Walls = workspace.CurrentCamera:GetPartsObscuringTarget({Local.Character.Head.Position, Target.Character.Head.Position}, {Local.Character, Target.Character})

		if #Walls == 0 then
			return false
		elseif #Walls > 0 then
			return true
		end
	end
end

Aimbot.Closest = function()
	local Distance = 9e9;
	local Target = nil;

	for Index, Player in next, Services.Players:GetPlayers() do
		if Aimbot.TeamCheck and Player.Team == Local.Player.Team then  
		else
			if Player ~= Local.Player and Player.Character and Player.Character:FindFirstChild(Aimbot.Part) then

				local Character = Player.Character
				local Location, Visible = workspace.CurrentCamera:WorldToViewportPoint(Character:FindFirstChild(Aimbot.Part).Position)

				if Aimbot.Wallcheck and Aimbot.BehindWall(Player) then

				else
					if Visible then
						local Magnitude = (Vector2.new(Local.Mouse.X, Local.Mouse.Y) - Vector2.new(Location.X, Location.Y)).Magnitude
						if Magnitude < Aimbot.FOV.Radius and Magnitude < Distance then
							Distance = Magnitude;
							Target = Player; 
						end
					end
				end
			end
		end
	end

	return Target
end

Command.Add({
	Aliases = { "aimbot", },
	Description = "Aimbot UI",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Aimbot") then
			local Main = Tab.new({ Title = "Aimbot", Drag = true })
			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			Library.new("Toggle", { Title = "Enabled",
				Description = "Toggle to enable the Aimbot",
				Default = false,
				Parent = MainTab,
				Callback = function(Boolean)
					Aimbot.Camlock = Boolean
				end,
			})

			Library.new("Toggle", { Title = "Team Check",
				Description = "If enabled, it won't lock on to people who are in the same team as you",
				Default = true,
				Parent = MainTab,
				Callback = function(Boolean)
					Aimbot.TeamCheck = Boolean
				end,
			})

			Library.new("Toggle", { Title = "Wall Check",
				Description = "Checks if the person you are trying to lock onto, is / is not behind a wall",
				Default = false,
				Parent = MainTab,
				Callback = function(Boolean)
					Aimbot.Wallcheck = Boolean
				end,
			})

			Library.new("Input", { Title = "FOV Radius",
				Description = "The radius how far your target has to be, to lock your camera to them",
				Default = "100",
				Parent = MainTab,
				Callback = function(Value)
					if Value and tonumber(Value) then
						Aimbot.FOV.Radius = tonumber(Value)
					end
				end,
			})

			Library.new("Input", { Title = "Prediction",
				Description = "How far away will mouse be from player, useful for games like Da Hood (Recommended: 0 - 0.5)",
				Default = "0",
				Parent = MainTab,
				Callback = function(Value)
					if Value and tonumber(Value) then
						Aimbot.Prediction = tonumber(Value)
					end
				end,
			})

			local Search = Library.new("Dropdown", { 
				Title = "Part",
				Description = "The part that the aimbot will lock onto",
				Parent = MainTab,
				Options = { 
					["Root"] = "HumanoidRootPart", 
					["Head"] = "Head",
				},
				Callback = function(Option)
					Aimbot.Part = Option
				end,
			})

			Library.new("Bind", { Title = "Keybind",
				Description = "The key to press, to lock your camera to a target",
				Parent = MainTab,
				Callback = function(Value)
					Aimbot.Key = Value
				end,
			})

			Spawn(function() 
				repeat Wait() 
					if Aimbot.PartIsRandom then
						local Table = { "HumanoidRootPart", "Head" }
						Aimbot.Part = Table[math.random(1, 2)]
					else
						Aimbot.Part = Aimbot.Part
					end
				until false
			end)

			Spawn(function()
				Connect(Services.Input.InputBegan, function(Key, Processed)
					if Key == Aimbot.Key and Aimbot.Camlock and not Processed then
						local Closest = Aimbot.Closest()

						if Closest and Closest.Character and Closest.Character:FindFirstChildOfClass("Humanoid") and Closest.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
							local TargetPart = Closest.Character:FindFirstChild(Aimbot.Part)
							Aimbot.Held = true

							repeat Wait()
								local TargetPart = Closest.Character:FindFirstChild(Aimbot.Part)
								local LookAt = TargetPart.CFrame + (TargetPart.Velocity * Aimbot.Prediction + Vector3.new(0, 0.1, 0))
								workspace.CurrentCamera.CFrame = CFrame.lookAt(workspace.CurrentCamera.CFrame.Position, LookAt.Position)
							until not Aimbot.Held or not Closest
						end
					end
				end)

				Connect(Services.Input.InputEnded, function(Key, Processed)
					if Key == Aimbot.Key and Aimbot.Camlock and not Processed then
						Aimbot.Held = false
					end
				end)

				local Circle = nil

				if Drawing and Drawing.new then
					Circle = Drawing.new("Circle")

					repeat Wait()
						if Aimbot.Camlock then
							Circle.Radius = Aimbot.FOV.Radius;
							Circle.Position = Vector2.new(Local.Mouse.X, Local.Mouse.Y);
							Circle.Visible = true;
						else
							Circle.Visible = false;
						end
					until not Circle
				end
			end)


			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Aimbot"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "gameinfo", },
	Description = "Gives info about the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Game Info") then
			local Main = Tab.new({ Title = "Game Info", Drag = true })
			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			Library.new("Label", { Title = "Game Name",
				Description = Services.Market:GetProductInfo(game.PlaceId).Name,
				Parent = MainTab,
			})

			Library.new("Label", { Title = "Place Id",
				Description = tostring(game.PlaceId),
				Parent = MainTab,
			})

			if game.CreatorType == Enum.CreatorType.User then
				Library.new("Label", { Title = "Owner",
					Description = Format("%s (USER)", Services.Players:GetNameFromUserIdAsync(game.CreatorId)),
					Parent = MainTab,
				})
			else
				Library.new("Label", { Title = "Owner",
					Description = Format("%s (GROUP)", game.GroupService:GetGroupInfoAsync(game.CreatorId).Name),
					Default = false,
					Parent = MainTab,
				})
			end

			local DistributedText = Library.new("Label", { Title = "Game Time",
				Description = math.floor(workspace.DistributedGameTime),
				Parent = MainTab,
			})

			Library.new("Label", { Title = "Respect Filtering Enabled",
				Description = tostring(Services.Sound.RespectFilteringEnabled),
				Parent = MainTab,
			})

			if request and typeof(request) == 'function' then
				local UniverseBody = request({
					Url = Format("https://apis.roblox.com/universes/v1/places/%s/universe", tostring(game.PlaceId)),
					Method = "GET"
				})
				local UniverseId = JSONDecode(Services.Http, UniverseBody.Body)["universeId"]
				local GameInfo = JSONDecode(Services.Http, request({
					Url = Format("https://games.roblox.com/v1/games?universeIds=%s", tostring(UniverseId)),
					Method = "GET"
				}).Body)["data"][1]

				Library.new("Label", { Title = "Visits",
					Description = tostring(GameInfo["visits"]),
					Parent = MainTab,
				})

				Library.new("Label", { Title = "Playing",
					Description = tostring(GameInfo["playing"]),
					Parent = MainTab,
				})

				Library.new("Label", { Title = "Created",
					Description = tostring(GameInfo["created"]),
					Parent = MainTab,
				})

				Library.new("Label", { Title = "Updated",
					Description = tostring(GameInfo["updated"]),
					Parent = MainTab,
				})

				Library.new("Label", { Title = "Favorites",
					Description = tostring(GameInfo["favoritedCount"]),
					Parent = MainTab,
				})

				Library.new("Label", { Title = "Description",
					Description = tostring(GameInfo["description"]),
					Parent = MainTab,
				})
			end

			Spawn(function()
				repeat Wait(1)
					DistributedText.Content.Description.Text = math.floor(workspace.DistributedGameTime)
				until false
			end)

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Game Info"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "players", },
	Description = "Get a list of info on players",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Players") then
			local Main = Tab.new({
				Title = "Players",
				Drag = true
			})

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			local MakeTab = function(Player)
				if Player then
					local Name = Player.Name
					local Display = Player.DisplayName
					local Age = Player.AccountAge
					local UserId = Player.UserId
					local Team = Player.Team

					local New, Button = Library.new("Switch", { Title = Display, Description = Format("@%s", Name), Parent = MainTab })
					Library.new("Section", { Title = "Information", Parent = New })

					Library.new("Label", { 
						Title = "Account Age",
						Description = Format("%s days", tostring(Age)),
						Parent = New,
					})

					Library.new("Label", { 
						Title = "User Id",
						Description = tostring(UserId),
						Parent = New,
					})

					Library.new("Label", { 
						Title = "Team",
						Description = Team,
						Parent = New,
					})

					Library.new("Section", { Title = "Actions", Parent = New })

					Library.new("Button", { 
						Title = "Goto",
						Description = "Teleports you to the target",
						Parent = New,
						Callback = function()
							GetRoot(Local.Character).CFrame = GetRoot(Character(Player)).CFrame
						end,
					})

					Library.new("Toggle", { 
						Title = "Spectate",
						Description = "Makes you view the player",
						Parent = New,
						Default = false,
						Callback = function(Bool)
							local Humanoid = GetHumanoid(Character(Player))

							if Humanoid then
								if Bool then
									Local.Camera.CameraSubject = Humanoid
								else
									Local.Camera.CameraSubject = GetHumanoid(Local.Character)
								end
							end
						end,
					})

					Library.new("Input", { 
						Title = "Whisper",
						Description = "Whisper something to them",
						Parent = New,
						Default = Blank,
						Callback = function(Message)
							Chat(Format("/w %s %s", Name, Message))
						end,
					})

					Connect(Services.Players.PlayerRemoving, function(PlayerInstance)
						if PlayerInstance == Player then
							Button:Destroy()
						end
					end)
				end
			end

			for Index, Player in next, Services.Players:GetPlayers() do
				MakeTab(Player)
			end

			Connect(Services.Players.PlayerAdded, function(Player)
				MakeTab(Player)
			end)

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Players"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "logs" },
	Description = "Shows all the stuff Cmd has logged (Http, Joins, Leaves, etc.)",
	Arguments = {},
	Plugin = false,
	Task = function()
		if not Screen:FindFirstChild("Logs") then
			local Order = 99999999

			local Main = Tab.new({
				Title = "Logs",
				Drag = true
			})

			local SetOrder = function(LibraryInstance)
				Order = Order - 1
				LibraryInstance.LayoutOrder = Order
				return LibraryInstance
			end

			local Tabs = Main.Tabs
			local MainTab = Tabs.Main.Scroll

			Library.new("Section", { Title = "Logs", Parent = MainTab })
			local Chat = Library.new("Switch", { Title = "Chat", Description = "Logs everytime someone chats", Parent = MainTab })
			local Joins = Library.new("Switch", { Title = "Joins", Description = "Logs when someone joins the game", Parent = MainTab })
			local Leaves = Library.new("Switch", { Title = "Leaves", Description = "Logs when someone leaves the game", Parent = MainTab })
			local Http = Library.new("Switch", { Title = "Http", Description = "Logs all Http requests made by other scripts", Parent = MainTab })

			if AutoLogger then
				for Index, Info in next, AutoLogger do
					local Message, Player = Info[1], Info[2]
					SetOrder(Library.new("Label", { Title = Format("%s (@%s)", Player.DisplayName, Player.Name), Description = Format('said "%s"', Message), Parent = Chat }))
				end
			end

			Connect(Services.Players.PlayerAdded, function(Player)
				SetOrder(Library.new("Label", { Title = Format("%s (@%s)", Player.DisplayName, Player.Name), Description = "has joined the game", Parent = Joins }))

				Connect(Player.Chatted, function(Message)
					SetOrder(Library.new("Label", { Title = Format("%s (@%s)", Player.DisplayName, Player.Name), Description = Format('said "%s"', Message), Parent = Chat }))
				end)
			end)

			Connect(Services.Players.PlayerRemoving, function(Player)
				SetOrder(Library.new("Label", { Title = Format("%s (@%s)", Player.DisplayName, Player.Name), Description = "has left the game", Parent = Leaves }))
			end)

			for Index, Player in next, Services.Players:GetPlayers() do
				Connect(Player.Chatted, function(Message)
					SetOrder(Library.new("Label", { Title = Format("%s (@%s)", Player.DisplayName, Player.Name), Description = Format('said "%s"', Message), Parent = Chat }))
				end)
			end

			pcall(function()

				local Httpget

				Httpget =
					hookfunction(
						game.HttpGet,
						newcclosure(
							function(self, url)
								SetOrder(Library.new("Label", { Title = "HttpGet logged", Description = url, Parent = Http }))
								return Httpget(self, url)
							end
						)
					)

				local Httppost
				Httppost =
					hookfunction(
						game.HttpPost,
						newcclosure(
							function(self, url)
								SetOrder(Library.new("Label", { Title = "HttpPost logged", Description = url, Parent = Http }))
								return Httppost(self, url)
							end
						)
					)

				if (game.HttpGet ~= game.HttpGetAsync) then
					local HttpgetAsync
					HttpgetAsync =
						hookfunction(
							game.HttpGetAsync,
							newcclosure(
								function(self, url)
									SetOrder(Library.new("Label", { Title = "HttpGetAsync request logged", Description = url, Parent = Http }))
									return HttpgetAsync(self, url)
								end
							)
						)
				end

				if (game.HttpPost ~= game.HttpPostAsync) then
					local HttppostAsync
					HttppostAsync =
						hookfunction(
							game.HttpPostAsync,
							newcclosure(
								function(self, url)
									SetOrder(Library.new("Label", { Title = "HttpPostAsync request logged", Description = url, Parent = Http }))
									return HttppostAsync(self, url)
								end
							)
						)
				end
			end)

			Library.new("Section", { Title = "Save", Parent = MainTab })

			Library.new("Button", { 
				Title = "Save logs",
				Description = "Saves everything that is logged in your exploit's workspace folder",
				Parent = MainTab,
				Callback = function()
					local Logged = Format("Cmd LOGS\nPLACE ID - %s\nTIME - %s", game.PlaceId, os.date())

					local Each = function(Tab, Name)
						Logged = Logged .. "\n\n" .. string.upper(Name)
						for Index, Log in next, Tab:GetChildren() do
							if Log.Name == "Label" and Log:IsA("Frame") then
								local Username, Message = Log.Content.Title.Text, Log.Content.Description.Text;
								Logged = Format("%s\n%s: %s", Logged, Username, Message)
							end
						end
					end

					Each(Chat, "Chat");
					Each(Joins, "Joins");
					Each(Leaves, "Leaves");
					Each(Http, "Http");

					writefile(Format("%s-%s.txt", game.PlaceId, os.date():gsub(":", Blank)), Logged);
					Utils.Notify("Success", "Success!", "Your logs should be saved into your exploit folder!", 5);
				end,
			})

			Tweens.Open({ Canvas = Main, Speed = 0.3 })
		else
			Tweens.Open({ Canvas = Screen:FindFirstChild("Logs"), Speed = 0.3 })
		end
	end,
})

Command.Add({
	Aliases = { "notify", "send", "notification" },
	Description = "Send a notification using Cmd's Utility System",
	Arguments = { 
		{ Name = "Mode", Type = "String" },
		{ Name = "Title", Type = "String" },
		{ Name = "Description", Type = "String" },
		{ Name = "Duration", Type = "Number" },
	},
	Plugin = false,
	Task = function(Mode, Title, Description, Duration)
		Utils.Notify(Mode, Title, Description, Duration)
	end,
})

Command.Add({
	Aliases = { "chat", "say" },
	Description = "Say something in chat",
	Arguments = { 
		{ Name = "Text", Type = "String" }
	},
	Plugin = false,
	Task = function(Input)
		Chat(Input)
	end,
})

Command.Add({
	Aliases = { "spamchat" },
	Description = "Repeatedly spam a message in chat",
	Arguments = { 
		{ Name = "Text", Type = "String" }
	},
	Plugin = false,
	Task = function(Input)
		Env().Spam = true

		repeat Wait(1)
			Chat(Input)
		until not Env().Spam
	end,
})

Command.Add({
	Aliases = { "unspamchat" },
	Description = "Stops spamming the chat",
	Arguments = { 
		{ Name = "Text", Type = "String" }
	},
	Plugin = false,
	Task = function(Input)
		Env().Spam = false
	end,
})

Command.Add({
	Aliases = { "flood" },
	Description = "Flood the chat",
	Arguments = { },
	Plugin = false,
	Task = function()
		Env().Flood = true
		local Character = "⸻"

		repeat Wait(1)
			Chat(Character:rep(180))
		until not Env().Flood
	end,
})

Command.Add({
	Aliases = { "unflood" },
	Description = "Stops flooding the chat",
	Arguments = { },
	Plugin = false,
	Task = function()
		Env().Flood = false
	end,
})

Command.Add({
	Aliases = { "fieldofview", "fov" },
	Description = "Set your field of view amount",
	Arguments = { 
		{ Name = "FOV", Type = "Number" }
	},
	Plugin = false,
	Task = function(Input)
		workspace.Camera.FieldOfView = SetNumber(Input)
	end,
})

Command.Add({
	Aliases = { "walkspeed", "speed", "ws" },
	Description = "Set your walkspeed amount",
	Arguments = { 
		{ Name = "Speed", Type = "Number" }
	},
	Plugin = false,
	Task = function(Input)
		local Amount = SetNumber(Input)

		GetHumanoid(Local.Character).WalkSpeed = Amount
	end,
})

Command.Add({
	Aliases = { "hipheight" },
	Description = "Set your hipheight amount",
	Arguments = { 
		{ Name = "Hipheight", Type = "Number" }
	},
	Plugin = false,
	Task = function(Input)
		local Amount = SetNumber(Input)

		GetHumanoid(Local.Character).HipHeight = Amount
	end,
})


Command.Add({
	Aliases = { "jumppower", "power", "jp" },
	Description = "Set your jumppower amount",
	Arguments = { 
		{ Name = "Jump Power Amount", Type = "Number" }
	},
	Plugin = false,
	Task = function(Input)
		local Amount = SetNumber(Input)
		local Humanoid = GetHumanoid(Local.Character)

		Humanoid.JumpPower = Amount
		Humanoid.UseJumpPower = true
	end,
})

Command.Add({
	Aliases = { "prefix" },
	Description = "Set the prefix for the command bar & chat",
	Arguments = {
		{ Name = "Prefix", Type = "String" }
	},
	Plugin = false,
	Task = function(Prefix)
		if Prefix and #Prefix == 1 then
			Settings.Prefix = Prefix
			Utils.Notify("Success", "Success!", Format("Set your command bar to %s", Prefix))
		else
			Utils.Notify("Error", "Error!", "Failed to set prefix")
		end
	end,
})

Command.Add({
	Aliases = { "saveprefix" },
	Description = "Save the prefix for the command bar & chat",
	Arguments = {
		{ Name = "Prefix", Type = "String" }
	},
	Plugin = false,
	Task = function(Prefix)
		if Prefix and #Prefix == 1 then
			Data.SetSetting("Prefix", Prefix)
			Utils.Notify("Success", "Success!", Format("Set your command bar to %s", Prefix))
		else
			Utils.Notify("Error", "Error!", "Failed to set prefix")
		end
	end,
})

Command.Add({
	Aliases = { "infinitejump", "infjump" },
	Description = "Lets you jump in the air",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().InfJump = true

		Connect(Services.Input.InputBegan, function(Key)
			if Key.KeyCode == Enum.KeyCode.Space and Env().InfJump then
				GetHumanoid(Local.Character):ChangeState("Jumping")
				Wait()
				GetHumanoid(Local.Character):ChangeState("Seated")
			end
		end)

		Utils.Notify("Success", "Success!", "Infinite Jump is enabled!", 5)
	end,
})

Command.Add({
	Aliases = { "uninfinitejump", "uninfjump" },
	Description = "Stops the infinite jump command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().InfJump = false
		Utils.Notify("Success", "Success!", "Infinite Jump is disabled", 5)
	end,
})

Command.Add({
	Aliases = { "badges" },
	Description = "Touches all badge collectors in the game, if they have the word 'badge' in them",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Amount = 0

		if firetouchinterest then
			for Index, BadgeGiver in next, workspace:GetDescendants() do
				if BadgeGiver.Name:lower():find("badge") and BadgeGiver:FindFirstChildOfClass("TouchTransmitter") then
					firetouchinterest(Local.Character.HumanoidRootPart, BadgeGiver, 0)
					firetouchinterest(Local.Character.HumanoidRootPart, BadgeGiver, 1)
					Amount = Amount + 1
				end
			end

			Utils.Notify("Success", "Success!", Format("Found %s badge givers!", tostring(Amount)))
		else
			Utils.Notify("Error", "Error!", "Your executor doesnt support this command, missing function : firetouchinterst()", 5)
		end
	end,
})

Command.Add({
	Aliases = { "admin" },
	Description = "Give the target access to use Cmd's commands",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)

		for Index, Player in next, Target do
			Command.Whitelist(Player)
			Chat(Format("/w %s You are now admin! Prefix is '%s'", Player.Name, Settings.Prefix))
		end
	end,
})

Command.Add({
	Aliases = { "unadmin" },
	Description = "Unadmin the target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)

		for Index, Player in next, Target do
			Command.RemoveWhitelist(Player)
			Chat(Format("/w %s You are no longer whitelisted to use commands.", Player.Name))
		end
	end,
})

Command.Add({
	Aliases = { "goto", "to" },
	Description = "Teleports you to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)

		for Index, Player in next, Target do
			local Root = GetRoot(Player.Character)

			if Root then
				GetRoot(Local.Character).CFrame = Root.CFrame
			end
		end
	end,
})

Command.Add({
	Aliases = { "gotopart", "topart" },
	Description = "Teleports you to your target",
	Arguments = {
		{ Name = "Part Name", Type = "String" }
	},
	Plugin = false,
	Task = function(Name)
		for Index, Part in next, workspace:GetChildren() do
			if Part.Name == Name and Part:IsA("BasePart") then
				GetRoot(Local.Character).CFrame = Part.CFrame
			end
		end
	end,
})

Command.Add({
	Aliases = { "loopgoto", "loopto" },
	Description = "Repeatedly teleports you to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)

		for Index, Player in next, Target do
			local Root = GetRoot(Player.Character)

			if Root then
				Env().LoopGoto = true

				repeat Wait()
					GetRoot(Local.Character).CFrame = Root.CFrame
				until not Env().LoopGoto
			end
		end
	end,
})

Command.Add({
	Aliases = { "unloopgoto", "unloopto" },
	Description = "Stops the loopgoto command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().LoopGoto = false
	end,
})

Command.Add({
	Aliases = { "godmode", "god" },
	Description = "Touching any kill bricks won't kill you",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Part in next, workspace:GetDescendants() do
			if Part:IsA("BasePart") then
				Part.CanTouch = false
			end
		end
	end,
})


Command.Add({
	Aliases = { "serverfreeze", "freezewalk" },
	Description = "Freezes your character on the server but lets you walk on the client, lets you kill enemies without them seeing you",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Character = Local.Character
		local Root = GetRoot(Character)

		if R6Check(Local.Player) then
			local Clone = Root:Clone()
			Root:Destroy()
			Clone.Parent = Character
		else
			Character.LowerTorso.Anchored = true
			Character.LowerTorso.Root:Destroy()
		end

		Utils.Notify("Success", "Success!", "Server freeze is now activated, reset to stop it.", 10)
	end,
})

Command.Add({
	Aliases = { "massplay" },
	Description = "Uses all the boomboxes in your inventory and plays them all at the same time",
	Arguments = {
		{ Name = "Sound Id", Type = "String" }
	},
	Plugin = false,
	Task = function(SoundId)
		local Settings = {
			[1] = "PlaySong",
			[2] = SoundId
		}

		for i, Boombox in next, Local.Backpack:GetChildren() do
			if (Boombox.Name == "Radio" or Boombox.Name == "Boombox") or (Boombox:FindFirstChild("Server") and Boombox:FindFirstChild("Client")) then
				Boombox.Parent = Local.Character
				Boombox.Remote:FireServer(Unpack(Settings))
			end
		end
	end,
})

Command.Add({
	Aliases = { "sync" },
	Description = "Repeatedly plays all the sounds in game",
	Arguments = {
		{ Name = "Delay", Type = "String" }
	},
	Plugin = false,
	Task = function(Time)
		local Cooldown = SetNumber(Time, 0.1, math.huge)
		Env().Sync = true

		if not Services.Sound.RespectFilteringEnabled then
			Env().Sync = true
			repeat Wait(Cooldown)
				for Index, Sound in next, workspace:GetDescendants() do
					if Sound:IsA("Sound") then
						Sound.Volume = 10
						Sound:Play()
					end
				end
			until not Env().Sync
		else
			Utils.Notify("Error", "Error!", "Respect Filtering Enabled is on, so this command wont work.", 5)
		end
	end,
})


Command.Add({
	Aliases = { "unsync" },
	Description = "Stops the sync command",
	Arguments = {},
	Plugin = false,
	Task = function(Time)
		Env().Sync = false
	end,
})

Command.Add({
	Aliases = { "dex" },
	Description = "Opens up an explorer showing you all instances in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))()
	end,
})


Command.Add({
	Aliases = { "cameranoclip", "camnoclip" },
	Description = "Clips your camera through walls",
	Arguments = {},
	Plugin = false,
	Task = function()
		Local.Player.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
	end,
})

Command.Add({
	Aliases = { "thirdperson", "third" },
	Description = "Lets you view in third person mode",
	Arguments = {},
	Plugin = false,
	Task = function()
		Local.Player.CameraMaxZoomDistance = 10
		Local.Player.CameraMode = "Classic"
	end,
})

Command.Add({
	Aliases = { "thirdperson", "third" },
	Description = "Lets you view in third person mode",
	Arguments = {},
	Plugin = false,
	Task = function()
		Local.Player.CameraMode = "LockFirstPerson"
	end,
})

Command.Add({
	Aliases = { "maxzoom", "camzoom" },
	Description = "Set the maximum distance your camera can zoom into",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Plugin = false,
	Task = function(Amount)
		Local.Player.CameraMaxZoomDistance = SetNumber(Amount)
	end,
})

Command.Add({
	Aliases = { "minimumzoom", "minzoom" },
	Description = "Set the MINIMUM distance your camera can zoom into",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Plugin = false,
	Task = function(Amount)
		Local.Player.CameraMinZoomDistance = SetNumber(Amount)
	end,
})

Command.Add({
	Aliases = { "autorespawn" },
	Description = "If you die you automatically get teleported to where you died",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoRespawn = true

		local Teleport = function() 
			Spawn(function() 
				local Character = Local.Player.Character

				if Character and Env().AutoRespawn then
					local Humanoid = Character:WaitForChild("Humanoid")
					local Pos;

					Connect(Humanoid.Died, function() 
						if Env().AutoRespawn then
							Pos = GetRoot(Character).CFrame
						end
					end)

					Local.Player.CharacterAdded:Wait()
					local Root = Local.Player.Character:WaitForChild("HumanoidRootPart")
					Root.CFrame = Pos or Root.CFrame
				end
			end)
		end

		Teleport()
		Connect(Local.Player.CharacterAdded, Teleport)
	end,
})

Command.Add({
	Aliases = { "unautorespawn" },
	Description = "Stops the automatic respawn command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoRespawn = false
	end,
})

Command.Add({
	Aliases = { "enableinventory", "enableinv" },
	Description = "Enables the inventory gui if it's hidden",
	Arguments = {},
	Plugin = false,
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, true)
	end,
})

Command.Add({
	Aliases = { "disableinventory", "disableinv" },
	Description = "Disables the inventory gui if it's shown",
	Arguments = {},
	Plugin = false,
	Task = function()
		Services.Starter:SetCoreGuiEnabled(2, false)
	end,
})

Command.Add({
	Aliases = { "attachpart" },
	Description = "Click on a part to attach it to you",
	Arguments = {},
	Plugin = false,
	Task = function()
        SetEnv("AttachParts", true);

		Connect(Local.Mouse.Button1Down, function() 
			local Part = Local.Mouse.Target
			local Attachment, Position, Orientation, Attachment2 = Instance.new("Attachment"), Instance.new("AlignPosition"), Instance.new("AlignOrientation"), Instance.new("Attachment")
			
			Attachment.Name = "Cmd"
			Position.Name = "Cmd"
			Orientation.Name = "Cmd"
			Attachment2.Name = "Cmd"

			if Env().AttachParts and Part and not Part.Anchored then
				local Char = Local.Character;
				local LocalRoot = Char.HumanoidRootPart;

				if LocalRoot then
					Utils.Notify("Success", "Success!", "Part should be attached", 5)
                    Part.CanCollide = false

					Attachment.Parent = Part;
					Position.Parent = Part;
					Orientation.Parent = Part;
					Attachment2.Parent = LocalRoot;

					Position.Responsiveness = 200;
					Orientation.Responsiveness = 200;

					Position.MaxForce = 9e9;
					Orientation.MaxTorque = 9e9;

					Position.Attachment0 = Attachment
					Position.Attachment1 = Attachment2
					Orientation.Attachment1 = Attachment2
					Orientation.Attachment0 = Attachment
				end
			end
		end)

	end,
})

Command.Add({
	Aliases = { "attachparts" },
	Description = "Attaches every part that you have Network Ownership over",
	Arguments = {},
	Plugin = false,
	Task = function()
		isnetworkowner = isnetworkowner or function(part) return true end 

		for Index, Part in next, workspace:GetDescendants() do
			if Part and Part:IsA("BasePart") and not Part.Anchored and isnetworkowner(Part) then
				local Attachment, Position, Orientation, Attachment2 = Instance.new("Attachment"), Instance.new("AlignPosition"), Instance.new("AlignOrientation"), Instance.new("Attachment")
				local Char = Local.Character;
				local LocalRoot = Char.HumanoidRootPart;
				
				Attachment.Name = "Cmd"
				Position.Name = "Cmd"
				Orientation.Name = "Cmd"
				Attachment2.Name = "Cmd"

				if LocalRoot then
                    Part.CanCollide = false

					Attachment.Parent = Part;
					Position.Parent = Part;
					Orientation.Parent = Part;
					Attachment2.Parent = LocalRoot;

					Position.Responsiveness = 200;
					Orientation.Responsiveness = 200;

					Position.MaxForce = 9e9;
					Orientation.MaxTorque = 9e9;

					Position.Attachment0 = Attachment
					Position.Attachment1 = Attachment2
					Orientation.Attachment1 = Attachment2
					Orientation.Attachment0 = Attachment
				end
			end
		end
	end,
})

Command.Add({
	Aliases = { "unattachparts" },
	Description = "Stops the attachparts command",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Classes = { "Attachment", "AlignPosition", "AlignOrientation" }

		for Index, Part in next, workspace:GetDescendants() do
			if Part and Part:IsA("BasePart") and not Part.Anchored then
				for Index, Child in next, Part:GetChildren() do
					if Child.Name == "Cmd" and Discover(Classes, Child.ClassName) then
						Child:Destroy() 
					end
				end
			end
		end
	end,
})

Command.Add({
	Aliases = { "uafling" },
	Description = "Flings with unanchored parts",
	Arguments = {},
	Plugin = false,
	Task = function(Target)
		local Targets = GetPlayer(Target)
    
        for Index, Target in next, Targets do
            Command.Parse("attachparts")
            Command.Parse(Format("fling %s", Target.Name))
            task.wait(3)
			Command.Parse("unattachparts")
        end
	end,
})

Command.Add({
	Aliases = { "blackhole" },
	Description = "Creates a blackhole that teleports parts to it",
	Arguments = {},
	Plugin = false,
	Task = function()
		isnetworkowner = isnetworkowner or function(part) return true end 
		SetEnv("Blackhole", true)

		pcall(function() 
			Blackhole:Destroy()
		end)

		Blackhole = Instance.new("Part");
		Blackhole.Parent = workspace
		Blackhole.Anchored = true
		Blackhole.CFrame = GetRoot(Local.Character).CFrame * CFrame.new(0, 5, 5)
		Blackhole.CanCollide = false

		repeat task.wait(1)
			for Index, Part in next, workspace:GetDescendants() do
				if Part and Part:IsA("BasePart") and not Part.Anchored and isnetworkowner(Part) and not Services.Players:GetPlayerFromCharacter(Part:FindFirstAncestorOfClass("Model") or Part.Parent) then
					local Attachment, Position, Orientation, Attachment2 = Instance.new("Attachment"), Instance.new("AlignPosition"), Instance.new("AlignOrientation"), Instance.new("Attachment")
					local Char = Local.Character;
					
					Attachment.Name = "Cmd"
					Position.Name = "Cmd"
					Orientation.Name = "Cmd"
					Attachment2.Name = "Cmd"

                    Part.CanCollide = false

					Attachment.Parent = Part;
					Position.Parent = Part;
					Orientation.Parent = Part;
					Attachment2.Parent = Blackhole;

					Position.Responsiveness = 200;
					Orientation.Responsiveness = 200;

					Position.MaxForce = 9e9;
					Orientation.MaxTorque = 9e9;

					Position.Attachment0 = Attachment
					Position.Attachment1 = Attachment2
					Orientation.Attachment1 = Attachment2
					Orientation.Attachment0 = Attachment
				end
			end
		until not Env().Blackhole or not Blackhole
	end,
})

Command.Add({
	Aliases = { "unblackhole" },
	Description = "Stops the blackhole command",
	Arguments = {},
	Plugin = false,
	Task = function()
		SetEnv("Blackhole", false)
		Blackhole:Destroy()
	end,
})

Command.Add({
	Aliases = { "fullbright", "fb" },
	Description = "Makes the game bright",
	Arguments = {},
	Plugin = false,
	Task = function()
		Services.Lighting.ClockTime = 12
		Services.Lighting.Brightness = 1
		Services.Lighting.GlobalShadows = false
		Services.Lighting.FogEnd = 9e9

		Connect(PropertyChanged(Services.Lighting, "ClockTime"), function() 
    		Services.Lighting.ClockTime = 12
		end) 

		Connect(PropertyChanged(Services.Lighting, "Brightness"), function() 
    		Services.Lighting.Brightness = 1
		end) 

		Connect(PropertyChanged(Services.Lighting, "GlobalShadows"), function() 
    		Services.Lighting.GlobalShadows = false
		end) 

		Connect(PropertyChanged(Services.Lighting, "FogEnd"), function() 
  			Services.Lighting.FogEnd = 9e9
		end) 
	end,
})

Command.Add({
	Aliases = { "deleteunanchored", "deleteua" },
	Description = "Sends every unanchored part that you have Network Ownership over to the void",
	Arguments = {},
	Plugin = false,
	Task = function()
		isnetworkowner = isnetworkowner or function(part) return true end 

		for Index, Part in next, workspace:GetDescendants() do
			if Part and Part:IsA("BasePart") and not Part.Anchored and isnetworkowner(Part) and not Services.Players:GetPlayerFromCharacter(Part:FindFirstAncestorOfClass("Model") or Part.Parent) then
				local Pos = Instance.new("BodyPosition", Part)
				Part.CFrame = CFrame.new(0, workspace.FallenPartsDestroyHeight + 10, 0)
				Pos.MaxForce = Vector3.new(1, 1, 1) * math.huge
				Pos.Position = Part.Position
				Pos.P = 1e9
			end
		end
	end,
})

Command.Add({
	Aliases = { "setsimulationradius", "setsimradius", "ssr" },
	Description = "Sets the simulation radius if your executor supports it (HEAVILY RECOMMENDED TO USE)",
	Arguments = {
		{ Name = "Amount (Higher the better)", Type = "Number" }
	},
	Plugin = false,
	Task = function(Amount)
		if setsimulationradius then
			setsimulationradius(SetNumber(Amount), SetNumber(Amount))
			Utils.Notify("Success", "Success!", Format("Your simulation radius is now set to %s", Amount or '0'))

		else
			Utils.Notify("Error", "Error!", "Your executor does not support this command, missing function: setsimulationradius")
		end
	end,
})


Command.Add({
	Aliases = { "unattachpart" },
	Description = "Stops the attach part command",
	Arguments = {},
	Plugin = false,
	Task = function()
        SetEnv("AttachParts", false);
        Utils.Notify("Success", "Success!", "Attach Parts is now disabled")
	end,
})

Command.Add({
	Aliases = { "bang" },
	Description = "please stop",
	Arguments = {
        { Name = "Target", Type = "Player" };
        { Name = "Speed", Type = "Number" };
    },
	Plugin = false,
	Task = function(Target, Speed) 
        local Targets = GetPlayer(Target);
        SetEnv("Bang", true);
        
        if Targets then
            local Target = Targets[1]

            if Target and Target.Character then
                local Root = GetRoot(Target.Character);
                local Animation = Instance.new("Animation");

                if R6Check(Local.Player) then
                    Animation.AnimationId = "rbxassetid://148840371"
                else
                    Animation.AnimationId = "rbxassetid://5918726674"
                end

                BangAnim = GetHumanoid(Local.Character):LoadAnimation(Animation);
                BangAnim:Play(Speed or 0.1, Speed or 1, Speed or 1)

                repeat task.wait() 
                    GetRoot(Local.Character).CFrame = GetRoot(Target.Character).CFrame * CFrame.new(0, 0, 1.2);
                until not Env().Bang 
            else
                Utils.Notify("Error", "Error!", "No player found, please try again");
            end
        end
	end,
})

Command.Add({
	Aliases = { "unbang" },
	Description = "Stops the bang command",
	Arguments = {},
	Plugin = false,
	Task = function() 
        SetEnv("Bang", false);
        BangAnim:Stop()
	end,
})


Command.Add({
	Aliases = { "controlnpc" },
	Description = "Click on an NPC to control them (WONT WORK ON EVERY NPC)",
	Arguments = {},
	Plugin = false,
	Task = function()
        SetEnv("ControlNpc", true);

		Connect(Local.Mouse.Button1Down, function() 
			local Npc = Local.Mouse.Target.Parent
			local Attachment, Position, Orientation, Attachment2 = Instance.new("Attachment"), Instance.new("AlignPosition"), Instance.new("AlignOrientation"), Instance.new("Attachment")

			Attachment.Name = "Cmd"
			Position.Name = "Cmd"
			Orientation.Name = "Cmd"
			Attachment2.Name = "Cmd"

			if Env().ControlNpc and Npc and Npc:FindFirstChildOfClass("Humanoid") and not Services.Players:GetPlayerFromCharacter(Npc) then
				local Root = Npc:FindFirstChild("HumanoidRootPart");
				local Char = Local.Character;
				local LocalRoot = Char.HumanoidRootPart;

				if Root and LocalRoot then
					Utils.Notify("Success", "Success!", "Controlling NPC...", 5)
					for Index, BodyPart in next, Npc:GetDescendants() do
						if BodyPart:IsA("BasePart") then
							Wait()
							BodyPart.CanCollide = false
						end
					end

					for Index, BodyPart in next, Char:GetDescendants() do
						if BodyPart:IsA("BasePart") then
							if (BodyPart.Name ~= "HumanoidRootPart" and BodyPart.Name ~= "UpperTorso" and BodyPart.Name ~= "Head") then
								BodyPart:Destroy()
							end
						end
					end

					LocalRoot.CFrame = Root.CFrame
					Char.Head.Anchored = true

					Attachment.Parent = Root;
					Position.Parent = Root;
					Orientation.Parent = Root;
					Attachment2.Parent = LocalRoot;

					Position.Responsiveness = 200;
					Orientation.Responsiveness = 200;

					Position.MaxForce = 9e9;
					Orientation.MaxTorque = 9e9;

					Position.Attachment0 = Attachment
					Position.Attachment1 = Attachment2
					Orientation.Attachment1 = Attachment2
					Orientation.Attachment0 = Attachment

				end
			end
		end)

	end,
})

Command.Add({
	Aliases = { "uncontrolnpc" },
	Description = "Stops the controlnpc command",
	Arguments = {},
	Plugin = false,
	Task = function()
        SetEnv("ControlNpc", false);
        Utils.Notify("Success", "Success!", "Control NPCs is now disabled")
	end,
})


Command.Add({
	Aliases = { "invisible", "invis" },
	Description = "Turns you invisible",
	Arguments = {},
	Plugin = false,
	Task = function()
		if Services.Lighting:FindFirstChild(Local.Player.Name) then return end 
		Local.Character.Archivable = true
		Original = Local.Character
		Invisible = Local.Character:Clone()
		OriginalPosition = Original.HumanoidRootPart.CFrame

		Original.HumanoidRootPart.CFrame = CFrame.new(1000, 1000, 1000)
		Wait(0.1)
		Original.HumanoidRootPart.Anchored = true
		Invisible.HumanoidRootPart.CFrame = OriginalPosition
		Invisible.Name = Format("%s-ghosst", Local.Player.Name)

		for Index, BodyPart in next, Invisible:GetChildren() do
			if BodyPart:IsA("BasePart") then
				BodyPart.Transparency = 0.5
			end
		end

		Invisible.Parent = workspace
		Original.Parent = game.Lighting	
		Local.Player.Character = Invisible
		workspace.CurrentCamera.CameraSubject = Invisible:FindFirstChildOfClass("Humanoid")
		Invisible.Animate.Disabled = true
		Invisible.Animate.Disabled = false
	end,
})

Command.Add({
	Aliases = { "visible", "vis" },
	Description = "Turns you visible",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Original = Services.Lighting:FindFirstChild(Local.Player.Name)
		local Invisible = Local.Character
		local InvisiblePosition = Invisible.HumanoidRootPart.CFrame

		if Original and Invisible then 
			Local.Player.Character = Original
			Local.Player.Character.Parent = workspace
			Original.HumanoidRootPart.Anchored = false
			Original.HumanoidRootPart.CFrame = InvisiblePosition
			Wait(0.1)
			workspace.CurrentCamera.CameraSubject = Original.Humanoid
			Invisible:Destroy()
		end
	end,
})

Command.Add({
	Aliases = { "dupetools", "dupe" },
	Description = "Dupe your tools",
	Arguments = {
		{ Name = "Amount", Type = "Number" } 
	},
	Plugin = false,
	Task = function(Amount)
		local Amount = Amount or 1
		local Pos = Vector3.new(0, math.random(50000, 100000), 0)

		for Index = 1, Amount do
			Wait(0.1)
			local Tools = GetTools();
			local Char = Local.Player.Character;
			local Root = GetRoot(Char);

			Root.Position = Pos;
			Wait(0.2)

			for Index, Tool in next, Tools do
				if Tool and Tool:FindFirstChild("Handle") then
					local Handle = Tool.Handle
					Tool.Parent = Local.Player.Character
					Wait(0.01)
					Tool.Parent = workspace
					Wait(0.01)
					Handle.Anchored = true
				end
			end

			Local.Player.Character.Humanoid.Health = 0
			Local.Player.CharacterAdded:Wait()
		end

		for Index, Tool in next, workspace:GetChildren() do
			if Tool and Tool:FindFirstChild("Handle") then
				Tool.Handle.Anchored = false
				Tool.Parent = Local.Player.Character
			end
		end
	end,
})


Command.Add({
	Aliases = { "view", "spectate" },
	Description = "View your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)

		for Index, Player in next, Target do
			local Humanoid = GetHumanoid(Player.Character)

			if Humanoid then
				Local.Camera.CameraSubject = Humanoid
			end
		end
	end,
})

Command.Add({
	Aliases = { "unview", "unspectate" },
	Description = "View yourself",
	Arguments = {},
	Plugin = false,
	Task = function()
		Local.Camera.CameraSubject = GetHumanoid(Local.Character)
	end,
})

Command.Add({
	Aliases = { "showwalls" },
	Description = "Shows all the invisible walls",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Wall in next, workspace:GetDescendants() do
			if Wall:IsA("BasePart") and Wall.Transparency == 1 and Wall.Name ~= "HumanoidRootPart" then
				Insert(Env().HiddenWalls, Wall)
				Wall.Transparency = 0
			end
		end
	end,
})

Command.Add({
	Aliases = { "hidewalls" },
	Description = "Undoes the show walls command",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Wall in next, Env().HiddenWalls do
			Wall.Transparency = 1
		end
	end,
})

Command.Add({
	Aliases = { "buildingtools", "btools" },
	Description = "Gives you building tools",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index = 1, 4 do
			local Tool = Instance.new("HopperBin", Local.Backpack)
			Tool.BinType = Index
		end
	end,
})

Command.Add({
	Aliases = { "f3x" },
	Description = "F3X",
	Arguments = {},
	Plugin = false,
	Task = function()
		loadstring(game:GetObjects("rbxassetid://6695644299")[1].Source)()
	end,
})

Command.Add({
	Aliases = { "reload" },
	Description = "Reloads Cmd",
	Arguments = {},
	Plugin = false,
	Task = function()
		Foreach(Blurred, function(Index, Self) 
			Self.root.Parent = nil
		end)

		loadstring(game:HttpGet("https://raw.githubusercontent.com/lxte/cmd/main/testing-main.lua"))()
	end,
})

Command.Add({
	Aliases = { "removecmd" },
	Description = "Removes Cmd",
	Arguments = {},
	Plugin = false,
	Task = function()
		Screen.Parent = nil

		Foreach(Blurred, function(Index, Self) 
			Self.root.Parent = nil
		end)
	end,
})

Command.Add({
	Aliases = { "respawn", "re" },
	Description = "Respawns your character",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Humanoid = GetHumanoid(Local.Character)
		local Old = GetRoot(Local.Character).CFrame

		if Humanoid then
			Humanoid.Health = 0
			Local.Player.CharacterAdded:Wait()
			Local.Player.Character:WaitForChild("HumanoidRootPart").CFrame = Old
		end
	end,
})

Command.Add({
	Aliases = { "rejoin", "rj" },
	Description = "Rejoins the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId)
		Utils.Notify("Success", "Success!", "Rejoining..")
	end,
})

Command.Add({
	Aliases = { "serverhop", "shop" },
	Description = "Teleports you to the LARGEST available server",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Servers = JSONDecode(Services.Http, game:HttpGetAsync("https://games.roblox.com/v1/games/".. game.PlaceId .."/servers/Public?sortOrder=Asc&limit=100")).data
		local Players = 0
		local Jobid = nil

		if Servers and #Servers > 1 then
			for Index, Server in next, Servers do
				local Playing, Max = Server.playing, Server.maxPlayers
				if (Playing > Players) and (Playing < Max) then
					Players = Playing
					Jobid = Server.id
				end
			end
		end

		if Jobid then
			Utils.Notify("Success", "Success!", Format("Serverhopping, player count: %s", tostring(Players)))
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, Jobid)
		end
	end,
})

Command.Add({
	Aliases = { "serverhop2", "shop2" },
	Description = "Teleports you to the SMALLEST available server",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Servers = JSONDecode(Services.Http, game:HttpGetAsync("https://games.roblox.com/v1/games/".. game.PlaceId .."/servers/Public?sortOrder=Asc&limit=100")).data
		local Players = Services.Players.MaxPlayers
		local Jobid = nil

		if Servers and #Servers > 1 then
			for Index, Server in next, Servers do
				local Playing, Max = Server.playing, Server.maxPlayers
				if (Playing < Players) and (Playing < Max) then
					Players = Playing
					Jobid = Server.id
				end
			end
		end

		if Jobid then
			Utils.Notify("Success", "Success!", Format("Serverhopping, player count: %s", tostring(Players)))
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, Jobid)
		end
	end,
})

Command.Add({
	Aliases = { "serverhop3", "shop3" },
	Description = "Teleports you to the server with the best ping",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Servers = JSONDecode(Services.Http, game:HttpGetAsync("https://games.roblox.com/v1/games/".. game.PlaceId .."/servers/Public?sortOrder=Asc&limit=100")).data
		local Ping = math.huge
		local Jobid = nil

		if Servers and #Servers > 1 then
			for Index, Server in next, Servers do
				local ping = Server.ping
				if (ping < Ping) then
					Ping = ping
					Jobid = Server.id
				end
			end
		end

		if Jobid then
			Utils.Notify("Success", "Success!", Format("Serverhopping, ping: %s", tostring(Ping)))
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, Jobid)
		end
	end,
})


Command.Add({
	Aliases = { "rejoinre", "rjre" },
	Description = "Rejoins and teleports you to where you were before teleporting",
	Arguments = {},
	Plugin = false,
	Task = function()
		local QueueTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)
		local Done = false
		local Run
		local CF = GetRoot(Local.Character).CFrame

		if not Done then
			Done = not Done
			local Run = "spawn(function() repeat Wait() until game:IsLoaded() local Player = game:GetService('Players').LocalPlayer local Character = Player.Character or Player.CharacterAdded:Wait() Character:WaitForChild('HumanoidRootPart').CFrame = CFrame.new(" ..tostring(CF) .. ") end)"
			QueueTeleport(Run)
			Services.Teleport:TeleportCancel()
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, Services.LocalPlayer)
		end
	end,
})

Command.Add({
	Aliases = { "rejoinreload" },
	Description = "Rejoins and reruns Cmd",
	Arguments = {},
	Plugin = false,
	Task = function()
		local QueueTeleport = queue_on_teleport or (fluxus and fluxus.queue_on_teleport);
		local Done = false
		local CF = GetRoot(Local.Character).CFrame
		local Run

		if not Done then
			Done = not Done
			local Run = "loadstring(game:HttpGet('https://raw.githubusercontent.com/lxte/cmd/main/testing-main.lua'))()"
			QueueTeleport(Run)
			Services.Teleport:TeleportCancel()
			Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, Local.Player)
		end
	end,
})

Command.Add({
	Aliases = { "tickgoto", "tto" },
	Description = "Teleports you to a player for a set amount of seconds",
	Arguments = {
		{ Name = "Target", Type = "Player" }, 
		{ Name = "Time", Type = "Number" }, 
	},
	Plugin = false,
	Task = function(Player, Time)
		local OldCFrame = GetRoot(Local.Character).CFrame 
		local Seconds = SetNumber(Time)

		for i, Player in next, GetPlayer(Player) do
			if Character(Player) and GetHumanoid(Character(Player)) then
				Local.Character:SetPrimaryPartCFrame(GetRoot(Character(Player)).CFrame)
				Wait(Seconds)
				GetRoot(Local.Character).CFrame = OldCFrame
				break
			end
		end
	end,
})

Command.Add({
	Aliases = { "antisit", "nosit" },
	Description = "Makes you not able to sit in chairs",
	Arguments = {},
	Plugin = false,
	Task = function()
		GetHumanoid(Local.Character):SetStateEnabled("Seated", false)
		GetHumanoid(Local.Character).Sit = true

		Utils.Notify("Success", "Success!", "Anti sit is enabled!", 5)
	end,
})

Command.Add({
	Aliases = { "unantisit", "unnosit" },
	Description = "Stops the anti sit command",
	Arguments = {},
	Plugin = false,
	Task = function()
		GetHumanoid(Local.Character):SetStateEnabled("Seated", true)
		GetHumanoid(Local.Character).Sit = false

		Utils.Notify("Success", "Success!", "Anti sit is disabled!", 5)
	end,
})

Command.Add({
	Aliases = { "antifling" },
	Description = "Makes you a harder target to fling",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AntiFling = true
		Utils.Notify("Success", "Success!", "Antifling is now enabled", 5)

		repeat Wait()
			for _, Players in next, Services.Players:GetPlayers() do
				if Players and Players ~= Local.Player and Players.Character then
					pcall(function()
						for i, Part in next, Players.Character:GetChildren() do
							if Part:IsA("BasePart") and Part.CanCollide then
								Part.CanCollide = false
								if Part.Name == "Torso" then
									Part.Massless = true
								end
								Part.Velocity = Vector3.new()
								Part.RotVelocity = Vector3.new()
							end
						end
					end)
				end
			end
		until not Env().AntiFling
	end,
})

Command.Add({
	Aliases = { "unantifling" },
	Description = "Stops the antifling command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AntiFling = false
		Utils.Notify("Success", "Success!", "Antifling is now disabled", 5)
	end,
})

Command.Add({
	Aliases = { "rawset" },
	Description = "Set the value of an instance's property",
	Arguments = { 
		{ Name = "Instance", Type = "String" }, 
		{ Name = "Value", Type = "String" }, 
		{ Name = "Amount", Type = "String" }
	},
	Plugin = false,
	Task = function(Object, Value, Amount)
		local instance = StringToInstance(Object)

		if Amount == "nil" then
			Amount = nil
		elseif Amount == "false" then
			Amount = false
		end

		if not instance:FindFirstChild(Value) and Value then
			instance[Value] = Amount
		end
	end,
})

Command.Add({
	Aliases = { "loop", "spam" },
	Description = "Loop fire a specific command",
	Arguments = { 
		{ Name = "Delay (OPTIONAL)", Type = "Number" }, 
		{ Name = "Command Name", Type = "String" }, 
		{ Name = "Arguments", Type = "String" }, 
	},
	Plugin = false,
	Task = function(Delay, Name, Argumemts)
		local Arguments = nil;

		if tonumber(Delay) then
			Arguments = Minimum(FullArgs, 3)
		else
			Name = Delay
			Delay = 0.05
			Arguments = Minimum(FullArgs, 2)
		end

		Env().Loop = true

		repeat Wait(Delay or 0.1)
			Command.Run(Name, Arguments)
		until not Env().Loop
	end,
})

Command.Add({
	Aliases = { "repeat" },
	Description = "Repeat a command for the amount of times you input",
	Arguments = { 
		{ Name = "Repeat amount", Type = "Number" }, 
		{ Name = "Delay", Type = "Number" }, 
		{ Name = "Command Name", Type = "String" }, 
		{ Name = "Arguments", Type = "String" }, 
	},
	Plugin = false,
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

		for Index = 1, tonumber(RepeatAmount) or 1 do
			Command.Run(Name, Arguments or {})
			task.wait(Delay or 0)
		end

		Utils.Notify("Success", "Success!", Format("Repeated %s %s times", Name or '?', tostring(RepeatAmount) or 1), 5)
	end,
})

Command.Add({
	Aliases = { "unloop", "unspam" },
	Description = "Stops all the commands that are currently being looped",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().Loop = false
		Utils.Notify("Success", "Success!", "Stopped looping the commands that are being looped!")
	end,
})

Command.Add({
	Aliases = { "gravity" },
	Description = "Set the gravity in-game",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Plugin = false,
	Task = function(Amount)
		local Number = SetNumber(Amount)

		workspace.Gravity = Number
		Utils.Notify("Success", "Success!", Format("Set gravity to %s", tostring(Number)))
	end,
})

Command.Add({
	Aliases = { "setunanchoredgravity", "sug" },
	Description = "Sets the gravity for unanchored parts",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Plugin = false,
	Task = function(Amount)
		local Gravity = SetNumber(Amount)

		Spawn(function()
			while true do
				Local.Player.MaximumSimulationRadius = math.pow(math.huge, math.huge) * math.huge
				Local.Player.SimulationRadius = math.pow(math.huge, math.huge) * math.huge
				Wait()
			end
		end)

		local function SetGrav(Part)
			if Part:FindFirstChild("BodyForce") then
				return
			end

			CreateInstance("BodyForce", {
				Parent = Part, Force = Part:GetMass() * Vector3.new(Gravity, workspace.Gravity, Gravity)
			})
		end

		for i, Descendant in next, workspace:GetDescendants() do
			if Descendant:IsA("Part") and Descendant.Anchored == false then
				if not (Descendant:IsDescendantOf(Local.Character)) then
					SetGrav(Descendant)
				end
			end
		end

		Connect(workspace.DescendantAdded, function(Part)
			if Part:IsA("Part") and Part.Anchored == false then
				if not (Part:IsDescendantOf(Local.Character)) then
					SetGrav(Part)
				end
			end
		end)

		Utils.Notify("Success", "Success!", Format("Set gravity for unanchored parts to %s", tostring(Gravity)))
	end,
})

Command.Add({
	Aliases = { "pushforce" },
	Description = "Makes it easier to push unanchored parts",
	Arguments = {},
	Plugin = false,
	Task = function()		
		for Index, Part in next, Local.Character:GetDescendants() do
			if Part:IsA("Part") then
				Part.CustomPhysicalProperties = PhysicalProperties.new(math.huge, 0.5, 0.5)
			end
		end

		Utils.Notify("Success", "Success!", "Push force is enabled!", 5)
	end,
})

Command.Add({
	Aliases = { "xray" },
	Description = "Lets you see through walls",
	Arguments = {},
	Plugin = false,
	Task = function()		
		for Index, Part in next, workspace:GetDescendants() do
			if Part:IsA("BasePart") and not Part.Parent:FindFirstChild("Humanoid") and not Part.Parent.Parent:FindFirstChild("Humanoid") then
				Part.LocalTransparencyModifier = 0.7
			end
		end

		Utils.Notify("Success", "Success!", "XRay is enabled!", 5)
	end,
})

Command.Add({
	Aliases = { "unxray" },
	Description = "Stops the XRay command",
	Arguments = {},
	Plugin = false,
	Task = function()		
		for Index, Part in next, workspace:GetDescendants() do
			if Part:IsA("BasePart") and not Part.Parent:FindFirstChild("Humanoid") and not Part.Parent.Parent:FindFirstChild("Humanoid") then
				Part.LocalTransparencyModifier = 0
			end
		end

		Utils.Notify("Success", "Success!", "XRay is disabled!", 5)
	end,
})

Command.Add({
	Aliases = { "clearterrain" },
	Description = "Clears all the terrain in the game",
	Arguments = {},
	Plugin = false,
	Task = function()	
		Utils.Popup("Clear Terrain", "Are you sure you want to clear all the terrain?", function()
			workspace.Terrain:Clear()
		end)
	end,
})

Command.Add({
	Aliases = { "getplayer" },
	Description = "Just used to test the GetPlayer function",
	Arguments = {
		{ Name = "Player", Type = "Player" },
	},
	Plugin = false,
	Task = function(Player)	
		Foreach(GetPlayer(Player), function(Index, Player) 
			print(Index, Player)
		end)
	end,
})

Command.Add({
	Aliases = { "fakelag" },
	Description = "Makes it seem like you're lagging",
	Arguments = {},
	Plugin = false,
	Task = function()	
		Env().Fakelag = true

		repeat
			GetRoot(Local.Character).Anchored = true
			Wait(.05)
			GetRoot(Local.Character).Anchored = false
			Wait(.05)
		until not Env().Fakelag or not Local.Character
	end,
})

Command.Add({
	Aliases = { "unfakelag" },
	Description = "Stops the fake lag command",
	Arguments = {},
	Plugin = false,
	Task = function()	
		Env().Fakelag = false
	end,
})

Command.Add({
	Aliases = { "fpsbooster" },
	Description = "Deletes all textures and more to save fps",
	Arguments = {},
	Plugin = false,
	Task = function()	
		Utils.Popup("FPS Booster", "Are you sure you want to enable this? This can't be undone", function()
			local Boost = function()
				for Index, Child in next, workspace:GetDescendants() do
					if Child:IsA("Decal") or Child:IsA("Texture") then
						Child:Destroy()
					elseif Child:IsA("BasePart") then
						Child.Material = Enum.Material.Plastic
						Child.Reflectance = 0
					elseif Child:IsA("ParticleEmitter") or Child:IsA("Trail") then
						Child.Lifetime = NumberRange.new(0)
					elseif Child:IsA("Explosion") then
						Child.BlastPressure = 1
						Child.BlastRadius = 1
					elseif
						Child:IsA("Fire") or Child:IsA("SpotLight") or Child:IsA("Smoke") or Child:IsA("Sparkles")
					then
						Child.Enabled = false
					elseif Child:IsA("MeshPart") then
						Child.Material = "Plastic"
						Child.Reflectance = 0
						Child.TextureID = 0
					elseif Child:IsA("SpecialMesh") then
						Child.TextureId = 0
					end
				end

				local Terrain = workspace.Terrain

				if sethiddenproperty then
					sethiddenproperty(Services.Lighting, "Technology", 2)
					sethiddenproperty(Terrain, "Decoration", false)
				end

				Terrain.WaterWaveSize = 0
				Terrain.WaterWaveSpeed = 0
				Terrain.WaterReflectance = 0
				Terrain.WaterTransparency = 0
				Services.Lighting.GlobalShadows = 0
				Services.Lighting.FogEnd = 9e9
				Services.Lighting.Brightness = 0
			end

			Boost()
		end)
	end,
})

Command.Add({
	Aliases = { "swim" },
	Description = "Allows you to swim in the air",
	Arguments = {
		{ Name = "Speed", Type = "Number" },
	},
	Plugin = false,
	Task = function(Speed)
		Speed = SetNumber(Speed)
		workspace.Gravity = 0

		GetHumanoid(Local.Character):ChangeState(Enum.HumanoidStateType.Swimming)
		GetHumanoid(Local.Character).WalkSpeed = Speed

		for Index, Enum in next, Enum.HumanoidStateType:GetEnumItems(Enum.HumanoidStateType) do
			GetHumanoid(Local.Character):SetStateEnabled(Enum, false)
		end
	end,
})

Command.Add({
	Aliases = { "unswim" },
	Description = "Stops the swim command",
	Arguments = {},
	Plugin = false,
	Task = function()
		GetHumanoid(Local.Character).WalkSpeed = 16
		workspace.Gravity = 198

		for Index, Enum in next, Enum.HumanoidStateType.GetEnumItems(Enum.HumanoidStateType) do
			GetHumanoid(Local.Character):SetStateEnabled(Enum, true)
		end
	end,
})

Command.Add({
	Aliases = { "replicationlag" },
	Description = "Set your replication lag amount",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Plugin = false,
	Task = function(Amount)
		settings():GetService("NetworkSettings").IncommingReplicationLag = SetNumber(Amount)
	end,
})

Command.Add({
	Aliases = { "setfps" },
	Description = "Set your FPS maximum",
	Arguments = {
		{ Name = "Amount", Type = "Number" },
	},
	Plugin = false,
	Task = function(Amount)
		Amount = SetNumber(Amount, 30, 9999)
		if setfpscap then
			setfpscap(Amount)
			Utils.Notify("Success", "Success!", Format("FPS cap is set to %s", tostring(Amount)), 5)
		else
			Utils.Notify("Error", "Error!", "Your executor doesn't support this command, missing function : setfpscap()", 5)
		end
	end,
})

Command.Add({
	Aliases = { "triggerbot" },
	Description = "Clicks automatically when your mouse in on a player",
	Arguments = {
		{ Name = "Delay", Type = "Number" },
	},
	Plugin = false,
	Task = function(Delay)
		Delay = SetNumber(Delay, 0, 100)

		local Toggle = Enum.KeyCode.E
		Utils.Notify("Success", "Success!", "Ran triggerbot, press <b>E</b> to toggle it")

		Connect(Services.Input.InputBegan, function(Input)
			if Input.KeyCode == Toggle then
				Env().Trigger = not Env().Trigger
				Utils.Notify("Success", "Success!", Format("Trigger bot is set to %s", tostring(Env().Trigger)))
			end
		end)

		while Wait() do
			if Local.Mouse.Target then
				if Services.Players:GetPlayerFromCharacter(Local.Mouse.Target.Parent) and Env().Trigger then
					Wait(Delay)
					mouse1click()
				end
			end
		end
	end,
})

Command.Add({
	Aliases = { "unlockfps" },
	Description = "Unlocks your FPS count",
	Arguments = {},
	Plugin = false,
	Task = function()
		if setfpscap then
			setfpscap(99999)
			Utils.Notify("Error", "Error!", "FPS Unlocked!", 5)
		else
			Utils.Notify("Error", "Error!", "Your executor doesn't support this command, missing function : setfpscap()", 5)
		end
	end,
})

Command.Add({
	Aliases = { "sit" },
	Description = "Makes you sit",
	Arguments = {},
	Plugin = false,
	Task = function()
		GetHumanoid(Local.Character).Sit = true
	end,
})

Command.Add({
	Aliases = { "antikick" },
	Description = "If a LOCALSCRIPT tries kicking you, it won't work",
	Arguments = {},
	Plugin = false,
	Task = function()
		local OldNamecall
		OldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
			local Method = getnamecallmethod()
			if Self == Local.Player and (Method == "Kick" or Method == "kick") then
				return
			end
			return OldNamecall(Self, ...)
		end))

		Utils.Notify("Success", "Success!", "Anti Kick enabled!", 5)
	end,
})

Command.Add({
	Aliases = { "antiteleport" },
	Description = "If a LocalScript tries teleporting you, it won't work",
	Arguments = {},
	Plugin = false,
	Task = function()
		local OldNameCall
		OldNameCall = hookmetamethod(game, "__namecall", newcclosure(function(Self, ...)
			if Self == Services.TeleportService and getnamecallmethod():lower() == "teleport" or getnamecallmethod() == "TeleportToPlaceInstance" then
				return
			end

			return OldNameCall(Self, ...)
		end))

		Utils.Notify("Success", "Success!", "Anti Teleport enabled!", 5)
	end,
})

Command.Add({
	Aliases = { "anticframeteleport", "acframetp", "acftp" },
	Description = "If a script tries to teleport you somewhere, it shouldn't work",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AntiCFrame = true

		local Allowed, Old = nil, nil 
		Utils.Notify("Success", "Success!", "Now no scripts should be able to teleport you!")
		local Root = GetRoot(Local.Character)

		Connect(Root:GetPropertyChangedSignal("CFrame"), function() 
			if Env().AntiCFrame then
				Allowed = true
				Root.CFrame = Old
				Wait();
				Allowed = false
			end
		end)

		repeat Wait();
			Old = Root.CFrame
		until not Root
	end,
})

Command.Add({
	Aliases = { "unanticframeteleport", "unacframetp", "unacftp" },
	Description = "Stops the Anti CFrame Teleport Command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AntiCFrame = false

		Utils.Notify("Success", "Success!", "Anti CFrame Teleport disabled")
	end,
})

Command.Add({
	Aliases = { "antivoid" },
	Description = "Sets the void's height to a low value",
	Arguments = {},
	Plugin = false,
	Task = function()
		workspace.FallenPartsDestroyHeight = -9e9
		Utils.Notify("Success", "Success!", "Anti Void enabled")
	end,
})

Command.Add({
	Aliases = { "nodelay", "nod" },
	Description = "Removes the delay from proximity prompts (the time taken to fire one)",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Proximity in next, workspace:GetDescendants() do
			if Proximity:IsA("ProximityPrompt") then
				Proximity.HoldDuration = 0
			end
		end
	end,
})

Command.Add({
	Aliases = { "nopurchaseprompts", "noprompts", "nopp" },
	Description = "Blocks purchase prompts from appearing",
	Arguments = {},
	Plugin = false,
	Task = function()
		game:GetService("CoreGui").PurchasePrompt.Enabled = false
		Utils.Notify("Success", "Success!", "Purchase prompts are now hidden")
	end,
})

Command.Add({
	Aliases = { "purchaseprompts", "prompts", "pp" },
	Description = "Allows purchase prompts to appear",
	Arguments = {},
	Plugin = false,
	Task = function()
		game:GetService("CoreGui").PurchasePrompt.Enabled = true
		Utils.Notify("Success", "Success!", "Purchase prompts are now shown")
	end,
})


Command.Add({
	Aliases = { "checkgrabber" },
	Description = "If someones using a tool grabber, it will tell you which one is doing that",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Tool = Local.Backpack:FindFirstChildOfClass("Tool")
		local Grabber = nil
		Tool.Parent = Local.Character
		Tool.Parent = workspace

		wait(2)

		if Tool and Tool.Parent ~= workspace and Tool.Parent ~= nil then
			if Tool.Parent:IsA("Backpack") and Tool.Parent.Parent ~= Local.Player then
				Grabber = Tool.Parent.Parent.Name
			elseif Tool.Parent:IsA("Model") and Tool.Parent ~= Local.Character then
				Grabber = Tool.Parent.Name
			end
		elseif Tool.Parent == workspace then
			Local.Character.Humanoid:EquipTool(Tool)
			Utils.Notify("Information", "Info", "No grabber has been found", 5)
		end

		if Grabber then
			Utils.Notify("Information", "Info", Format("Grabber found, username - %s", Grabber), 5)
		end
	end,
})

Command.Add({
	Aliases = { "gotospawn", "tospawn" },
	Description = "Teleports you to a spawnpoint",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Spawn in next, workspace:GetDescendants() do
			if Spawn:IsA("SpawnLocation") then
				GetRoot(Local.Character).CFrame = Spawn.CFrame * CFrame.new(0, 10, 0)
			end
		end
	end,
})

Command.Add({
	Aliases = { "headstand" },
	Description = "Stand on your target's head",
	Arguments = {
		{ Name = "Target", Type = "Player" },
	},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)

		for Index, Player in next, Target do
			SetEnv("HeadStand", true)

			local Char = Character(Player)
			Local.Camera.CameraSubject = Char.Humanoid

			repeat
				Wait()
				Local.Character:FindFirstChild("HumanoidRootPart").CFrame =
					Char:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(0, 5, 0)
			until not Env().HeadStand or not Local.Character or not Char or not Char.HumanoidRootPart

			break
		end
	end,
})

Command.Add({
	Aliases = { "unheadstand" },
	Description = "Stops the headstand command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().HeadStand = false
	end,
})

Command.Add({
	Aliases = { "follow" },
	Description = "Follows your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local LocalHumanoid = GetHumanoid(Local.Character)
		local Target = GetPlayer(Player)
		Env().Follow = true

		for Index, Player in next, Target do
			local Char = Character(Player)
			local Root = GetRoot(Char)

			if LocalHumanoid and Root then
				repeat Wait()
					LocalHumanoid:MoveTo(Root.Position)
				until not Root or not LocalHumanoid or not Env().Follow
			end
		end
	end,
})

Command.Add({
	Aliases = { "unfollow" },
	Description = "Stops following your target",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().Follow = false
	end,
})

Command.Add({
	Aliases = { "toolfling" },
	Description = "Fling people using tools",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Random = GetTools();
		local Tool = Random[math.random(#Random)];
		Tool.Parent = Local.Character;

		if not Random or #Random == 0 then
			return
		end

		Tool.Handle.Massless = true
		Tool.GripPos = Vector3.new(0, -10000, 0)
		Utils.Notify("Success", "Success!", "Walk up to a person to fling them", 5)

	end,
})

Command.Add({
	Aliases = { "teleportposition", "tppos" },
	Description = "Teleports you to the XYZ CFrame you input",
	Arguments = {
		{ Name = "X", Type = "Number" },
		{ Name = "Y", Type = "Number" },
		{ Name = "Z", Type = "Number" },
	},
	Plugin = false,
	Task = function(X, Y, Z)
		X, Y, Z = SetNumber(X), SetNumber(Y), SetNumber(Z)

		GetRoot(Local.Character).CFrame = CFrame.new(X, Y, Z)
	end,
})

Command.Add({
	Aliases = { "unpushforce" },
	Description = "Stops the pushforce command",
	Arguments = {},
	Plugin = false,
	Task = function()		
		for Index, Part in next, Local.Character:GetDescendants() do
			if Part:IsA("Part") then
				Part.CustomPhysicalProperties = PhysicalProperties.new(1, 0.5, 0.5)
			end
		end

		Utils.Notify("Success", "Success!", "Push force is disabled!", 5)
	end,
})

Command.Add({
	Aliases = { "noclip" },
	Description = "Lets you walk through walls",
	Arguments = {},
	Plugin = false,
	Task = function()
        SetEnv("Noclip", true)
        repeat task.wait(0.1)
		    for i, v in next, Local.Character:GetDescendants() do
			    if v:IsA("BasePart") then
			    	v.CanCollide = false
		    	end
		    end
        until not Env().Noclip
	end,
})

Command.Add({
	Aliases = { "clip" },
	Description = "Stops noclipping",
	Arguments = {},
	Plugin = false,
	Task = function()
        SetEnv("Noclip", false);
        task.wait(0.5);

		for i, v in next, Local.Character:GetDescendants() do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end,
})

Command.Add({
	Aliases = { "saveinstance" },
	Description = "Copies the game into an editable rbxl file",
	Arguments = {},
	Plugin = false,
	Task = function()
		if saveinstance then
			saveinstance()
			Utils.Notify("Success", "Success!", "Saving...")
		else
			Utils.Notify("Error", "Error!", "Your executor doesn't support saveinstance!", 5)
		end
	end,
})

Command.Add({
	Aliases = { "fireremote", "firer" },
	Description = "Fires the remote you put",
	Arguments = {
		{ Name = "Remote Path", Type = "String" }, 
		{ Name = "Remote Arguments", Type = "String" }, 
	},
	Plugin = false,
	Task = function(Path, Arguments)
		local Args = Minimum(FullArgs, 2)
		local Remote = StringToInstance(Path)

		if Remote then
			if Remote:IsA("RemoteEvent") then
				Remote:FireServer(Args)
			elseif Remote:IsA("BindableEvent") then
				Remote:Fire(Args)
			elseif Remote:IsA("RemoteFunction") then
				Remote:InvokeServer(Args)
			end
		end
	end,
})

Command.Add({
	Aliases = { "fireremotes" },
	Description = "Fires all remotes in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Amount = 0

		for i, Remote in next, game:GetDescendants() do
			if Remote:IsA("BindableEvent") then
				Amount = Amount + 1
				Remote:Fire()
			elseif Remote:IsA("RemoteEvent") then
				Amount = Amount + 1
				Remote:FireServer()
			elseif Remote:IsA("RemoteFunction") then
				Amount = Amount + 1
				Remote:InvokeServer()
			end
		end

		Utils.Notify("Information", "Remotes", Format("Fired %s remotes", tostring(Amount)), 5)

	end,
})

Command.Add({
	Aliases = { "fireclickdetectors", "fcd" },
	Description = "Fires all click detectors in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Amount = 0

		if fireclickdetector then
			for i, ClickDetector in next, workspace:GetDescendants() do
				if ClickDetector:IsA("ClickDetector") then
					Amount = Amount + 1
					fireclickdetector(ClickDetector)
				end
			end
			Utils.Notify("Information", "Click Detectors", "Fired " .. tostring(Amount) .. " click detectors", 5)
		else
			Utils.Notify("Error", "Error!", "Your executor doesnt support this command, missing function : fireclickdetector()", 5)
		end
	end,
})

Command.Add({
	Aliases = { "firetouchinterests", "fti" },
	Description = "Fires all touch interests in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Amount = 0

		if firetouchinterest then
			for i, Touch in next, workspace:GetDescendants() do
				if Touch:IsA("TouchTransmitter") then
					Amount = Amount + 1
					firetouchinterest(Local.Character.HumanoidRootPart, Touch.Parent, 0)
					firetouchinterest(Local.Character.HumanoidRootPart, Touch.Parent, 1)
				end
			end
			Utils.Notify("Information", "Touch Interests", Format("Fired %s touch intersts", tostring(Amount)), 5)
		else
			Utils.Notify("Error", "Error!", "Your executor doesnt support this command, missing function : firetouchinterst()", 5)
		end
	end,
})

Command.Add({
	Aliases = { "fireproximityprompts", "fpp" },
	Description = "Fires all proximity prompts in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Amount = 0

		if fireproximityprompt then
			for i, Prox in next, workspace:GetDescendants() do
				if Prox:IsA("ProximityPrompt") then
					Amount = Amount + 1
					fireproximityprompt(Prox, 0)
					task.wait()
					fireproximityprompt(Prox, 1)
				end
			end
			Utils.Notify("Information", "Proximity Prompts", Format("Fired %s proximity prompts", tostring(Amount)), 5)
		else
			Utils.Notify("Error", "Error!", "Your executor doesnt support this command, missing function : fireproximityprompt()", 5)
		end
	end,
})

Command.Add({
	Aliases = { "setfflag", "fflag" },
	Description = "Set an fflag's value, to see FFlags go to github.com/MaximumADHD/Roblox-FFlag-Tracker",
	Arguments = {
		{ Name = "FFlag", Type = "String" },
		{ Name = "Value", Type = "String" },
	},
	Plugin = false,
	Task = function(FFlag, Value)
		if setfflag then

			if Value == "nil" then
				Value = nil
			elseif Value == "false" then
				Value = false
			elseif tonumber(Value) then
				Value = SetNumber(Value)
			end

			setfflag(FFlag, Value)
		else
			Utils.Notify("Error", "Error!", "Your executor doesn't support this command, missing functions : setfflag()", 5)
		end
	end,
})

Command.Add({
	Aliases = { "loadstring" },
	Description = "What you input into the Command Bar will be ran as code",
	Arguments = {
		{ Name = "Code", Type = "String" },
	},
	Plugin = false,
	Task = function(Code)
		loadstring(Code)()
	end,
})

Command.Add({
	Aliases = { "url" },
	Description = "Run scripts using their URL",
	Arguments = {
		{ Name = "URL", Type = "String" },
	},
	Plugin = false,
	Task = function(URL)
		loadstring(game:HttpGet(URL))()
	end,
})

Command.Add({
	Aliases = { "animationspeed", "animspeed" },
	Description = "Set your character's animation speed",
	Arguments = { { Name = "Amount", Type = "Number" } },
	Plugin = false,
	Task = function(Amount)
		Amount = SetNumber(Amount, 2, math.huge);	
		SetEnv("AnimSpeed", true);

		Utils.Notify("Success", "Success!", Format("Set your animation speed to %s", tostring(Amount)))

		repeat Wait()
			for Index, Track in next, Local.Character:FindFirstChild("Humanoid"):GetPlayingAnimationTracks() do
				Track:AdjustSpeed(Amount)
			end
		until not Env().AnimSpeed
	end,
})

Command.Add({
	Aliases = { "unanimationspeed", "unanimspeed" },
	Description = "Set your character's animation speed back to normal",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AnimSpeed = false

		for Index, Track in next, Local.Character:FindFirstChild("Humanoid"):GetPlayingAnimationTracks() do
			Track:AdjustSpeed(2)
		end
	end,
})

Command.Add({
	Aliases = { "vehicleseat", "vseat" },
	Description = "Sits you in a vehicle seat, useful for trying to find cars in games",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Seat in next, workspace:GetDescendants() do
			if Seat:IsA("VehicleSeat") then
				Seat:Sit(GetHumanoid(Local.Character))
				break
			end
		end
	end,
})

Command.Add({
	Aliases = { "vehiclegoto", "vgoto", "vto" },
	Description = "Teleports your vehicle to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }	
	},
	Plugin = false,
	Task = function(Player)	
		local Targets = GetPlayer(Player)

		for Index, Target in next, Targets do
			local Character = Character(Target)
			local Root = GetRoot(Character)

			GetHumanoid(Local.Character).SeatPart:FindFirstAncestorWhichIsA("Model"):PivotTo(Root.CFrame)
		end
	end,
})


Command.Add({
	Aliases = { "vehiclespeed", "vspeed" },
	Description = "Set the speed of the vehicle you're in",
	Arguments = {
		{ Name = "Speed", Type = "Number" }	
	},
	Plugin = false,
	Task = function(Speed)	
		local Amount = SetNumber(Speed, -math.huge, math.huge)

		if VehicleSpeed then
			VehicleSpeed = VehicleSpeed:Disconnect()
		end

		VehicleSpeed = Connect(Services.Run.Stepped, function()
			local Hum = GetHumanoid(Local.Character)

			if Hum.SeatPart then
				Hum.SeatPart:ApplyImpulse(Hum.SeatPart.CFrame.LookVector * Vector3.new(Amount, Amount, Amount))
			end
		end)
	end,
})

Command.Add({
	Aliases = { "unvehiclespeed", "unvspeed" },
	Description = "Stops the vehicle speed command",
	Arguments = {},
	Plugin = false,
	Task = function()	
		if VehicleSpeed then
			VehicleSpeed = VehicleSpeed:Disconnect()
		end
	end,
})

Command.Add({
	Aliases = { "seat" },
	Description = "Sits you in a random seat in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Seat in next, workspace:GetDescendants() do
			if Seat:IsA("Seat") then
				Seat:Sit(GetHumanoid(Local.Character))
				break
			end
		end
	end,
})

Command.Add({
	Aliases = { "airwalk" },
	Description = "Lets you walk in the air",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Part = CreateInstance("Part", {
			Parent = workspace,
			Size = Vector3.new(7, 2, 3),
			Transparency = 1,
			Anchored = true,
			Name = "AW",
		})

		while Part do
			Wait()
			Part.CFrame = Local.Character.HumanoidRootPart.CFrame + Vector3.new(0, -4, 0)
		end
	end,
})

Command.Add({
	Aliases = { "unairwalk" },
	Description = "Stops the airwalk command",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Part = workspace:FindFirstChild("AW")

		if Part then
			Part:Destroy()
		end
	end,
})

Command.Add({
	Aliases = { "climb" },
	Description = "Lets you climb in the air",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Part = CreateInstance("TrussPart", {
			Transparency = 1,
			Size = Vector3.new(2, 10, 2),
			Parent = workspace,
			CanCollide = true,
			Name = "ClimbPart",
		})

		while Part do
			Wait()
			Part.CFrame = Local.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -1.5)
		end
	end,
})

Command.Add({
	Aliases = { "unclimb" },
	Description = "Stops the climb command",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Part = workspace:FindFirstChild("ClimbPart")

		if Part then
			Part:Destroy()
		end
	end,
})

Command.Add({
	Aliases = { "freecam" },
	Description = "Spectate the game freely",
	Arguments = {},
	Plugin = false,
	Task = function(Speed)
		local Free = Modules.Freecam

		if typeof(Free) == "table" then
			Modules.Freecam:EnableFreecam()
		else
			Utils.Notify("Error", "Error!", "Freecam failed to load", 5)
		end
	end,
})

Command.Add({
	Aliases = { "unfreecam" },
	Description = "Stops free camming",
	Arguments = {},
	Plugin = false,
	Task = function(Speed)
		local Free = Modules.Freecam

		if typeof(Free) == "table" then
			Modules.Freecam:StopFreecam()
		else
			Utils.Notify("Error", "Error!", "Freecam failed to load", 5)
		end
	end,
})

Command.Add({
	Aliases = { "bhop" },
	Description = "Bunny hop",
	Arguments = {},
	Plugin = false,
	Task = function()
		Modules.Bhop.Start()
	end,
})


Command.Add({
	Aliases = { "fly" },
	Description = "Lets you fly around the map",
	Arguments = {
		{ Name = "Speed", Type = "Number" }
	},
	Plugin = false,
	Task = function(Speed)
		local Speed = tonumber(Speed) or 10

		Fly(true, Speed)
	end,
})

Command.Add({
	Aliases = { "unfly" },
	Description = "Stops flying",
	Arguments = {},
	Plugin = false,
	Task = function()
		Fly(false)
	end,
})

Command.Add({
	Aliases = { "reach" },
	Description = "Set the reach for the item you're holding",
	Arguments = {
		{ Name = "Size", Type = "Number" }
	},
	Plugin = false,
	Task = function(Input)
		local Num = SetNumber(Input)
		local Tool = Local.Character:FindFirstChildOfClass("Tool")
		local Handles = {}

		if Tool then
			for Index, Handle in next, Tool:GetChildren() do
				if Handle:IsA("Part") then
					Insert(Handles, Handle)
				end
			end

			for Index, Handle in next, Handles do
				if Handle then
					if Handle:FindFirstChild("OriginalSize") then
						if Handle:FindFirstChildOfClass("Highlight") then
							Handle:FindFirstChildOfClass("Highlight"):Destroy()
						end
						Handle.Size = Handle.OriginalSize.Value
					end
					Instance.new("Highlight", Handle)
					local Vector3Value = Instance.new("Vector3Value", Handle)
					Vector3Value.Name = "OriginalSize"
					Vector3Value.Value = Handle.Size
					Handle.Massless = true
					Handle.Size = Vector3.new(Handle.Size.X, Handle.Size.Y, Num)
				end
			end
		else
			Utils.Notify("Error", "Error!", "Please equip a tool before running this command")
		end
	end,
})

Command.Add({
	Aliases = { "unreach" },
	Description = "Disables reach",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Tool = Local.Character:FindFirstChildOfClass("Tool")
		local Handles = {}

		if Tool then
			for Index, Handle in next, Tool:GetChildren() do
				if Handle:IsA("Part") then
					Insert(Handles, Handle)
				end
			end

			for Index, Handle in next, Handles do
				if Handle:FindFirstChild("OriginalSize") then
					Handle:FindFirstChildOfClass("Highlight"):Destroy()
					Handle.Size = Handle.OriginalSize.Value
					Handle.OriginalSize:Destroy()
				else
					Utils.Notify("Error", "Error!", "Tool does not have reach enabled")
				end
			end
		else
			Utils.Notify("Error", "Error!", "Please equip the tool you want to use and run this command again")
		end
	end,
})

Command.Add({
	Aliases = { "aura" },
	Description = "Set the size of the tool you're holding",
	Arguments = {
		{ Name = "Size", Type = "Number" }
	},
	Plugin = false,
	Task = function(Input)
		local Num = SetNumber(Input)

		local Tool = Local.Character:FindFirstChildOfClass("Tool")
		local Handles = {}

		if Tool then
			for Index, Handle in next, Tool:GetChildren() do
				if Handle:IsA("Part") then
					Insert(Handles, Handle)
				end
			end

			for Index, Handle in next, Handles do
				if Handle then
					if Handle:FindFirstChild("OriginalSize") then
						if Handle:FindFirstChildOfClass("Highlight") then
							Handle:FindFirstChildOfClass("Highlight"):Destroy()
						end
						Handle.Size = Handle.OriginalSize.Value
					end
					Instance.new("Highlight", Handle)
					local Vector3Value = Instance.new("Vector3Value", Handle)
					Vector3Value.Name = "OriginalSize"
					Vector3Value.Value = Handle.Size
					Handle.Massless = true
					Handle.Size = Vector3.new(Num, Num, Num)
				end
			end
		else
			Utils.Notify("Error", "Error!", "Please equip the tool you want to use and run this command again")
		end
	end,
})

Command.Add({
	Aliases = { "unaura" },
	Description = "Sets your tool's size back to the original",
	Arguments = {},
	Plugin = false,
	Task = function(Input)
		Command.Parse("unreach")
	end,
})

Command.Add({
	Aliases = { "spoof" },
	Description = "Spoof an instance's property",
	Arguments = {
		{ Name = "Instance", Type = "String" };
		{ Name = "Propery", Type = "String" };
		{ Name = "Value", Type = "String" };

	},
	Plugin = false,
	Task = function(Parent, Property, Value)
		local Instance = StringToInstance(Parent)

		if Value == "nil" then
			Value = nil
		elseif Value == "false" then
			Value = false
		end

		if Instance and Property and Value then
			Spoof(Instance, Property, Value)
			Utils.Notify("Success", "Success!", Format("Spoofing %s and setting the value to %s", Property, tostring(Value)))
		else
			Utils.Notify("Error", "Error!", "One or more arguments missing when trying to spoof")
		end
	end,
})

Command.Add({
	Aliases = { "freegamepasses", "freegp" },
	Description = "Returns true if the UserOwnsGamePassAsync function gets used",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Hook
		Hook = hookfunction(Services.Market.UserOwnsGamePassAsync, newcclosure(function(self, ...)
			return true
		end))

		Utils.Notify("Success", "Success!", "Free gamepasses is now enabled, to disable rejoin. Keep in mind this command won't work in every game", 10)
	end,
})

Command.Add({
	Aliases = { "bringunanchored", "bringua", "bua" },
	Description = "Brings all unanchored parts to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player)

		for Index, Target in next, Targets do
			local Character = Character(Target)
			local Root = GetRoot(Character)

			for Index, Part in next, workspace:GetDescendants() do
				if Part:IsA("BasePart") and not Part.Anchored and not Services.Players:GetPlayerFromCharacter(Part.Parent) and not Part:IsDescendantOf(Local.Character) then
					local Pos = Instance.new("BodyPosition", Part)
					Part.CFrame = CFrame.new(Root.Position)
					Pos.MaxForce = Vector3.new(1, 1, 1) * math.huge
					Pos.Position = Part.Position
					Pos.P = 1e9
				end
			end
		end
	end,
})

Command.Add({
	Aliases = { "stand" },
	Description = "Turns you into someone's stand",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player)
		Env().Stand = true

		for Index, Target in next, Targets do
			local Anim = CreateInstance("Animation", {AnimationId = "rbxassetid://3337994105"})
			local Load = Local.Character.Humanoid:LoadAnimation(Anim)
			Local.Camera.CameraSubject = Target.Character:FindFirstChildOfClass("Humanoid")
			Load:Play()
			Command.Parse("airwalk")

			repeat Wait()
				Local.Character:FindFirstChild("HumanoidRootPart").CFrame = Target.Character:FindFirstChild("HumanoidRootPart").CFrame * CFrame.new(2.2, 1.2, 2.3)
			until not Env().Stand or not Target

			Load:Stop()
			Env().Stand = false
			Command.Parse("unairwalk")
			Local.Camera.CameraSubject = GetHumanoid(Local.Character)

			break
		end
	end,
})

Command.Add({
	Aliases = { "unstand" },
	Description = "Stops the stand command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().Stand = false
	end,
})

Command.Add({
	Aliases = { "stare" },
	Description = "Stares at your target",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player)
		Env().Stand = true

		for Index, Target in next, Targets do
			local Char = Character(Target)
			local Root = GetRoot(Char)

			if Target ~= Local.Player and Char then
				Utils.Notify("Success", "Success!", Format("Staring at %s", Target.Name))
				Stare = Connect(Services.Run.Stepped, function()
					if Local.Character and Character then
						local Pos = Vector3.new(Root.Position.X, Local.Character.PrimaryPart.Position.Y, Root.Position.Z) 
						local New = CFrame.new(Local.Character.PrimaryPart.Position, Pos)
						Local.Character:SetPrimaryPartCFrame(New)
					end
				end)

				break
			end
		end
	end,
})

Command.Add({
	Aliases = { "unstare" },
	Description = "Stops staring",
	Arguments = {},
	Plugin = false,
	Task = function()
		if Stare then
			Stare:Disconnect()
		end
	end,
})

Command.Add({
	Aliases = { "savetools" },
	Description = "Saves your tools",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Tool in next, GetTools() do
			Tool.Parent = Services.Players
		end
	end,
})

Command.Add({
	Aliases = { "loadtools" },
	Description = "Loads your saved tools",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Tool in next, Services.Players:GetChildren() do
			if Tool:IsA("Tool") then
				Tool.Parent = Local.Backpack
			end
		end
	end,
})

Command.Add({
	Aliases = { "trip" },
	Description = "Makes your character trip",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Humanoid = GetHumanoid(Local.Character);
		local Root = GetRoot(Local.Character);

		Humanoid:ChangeState(0)
		Root.Velocity = Root.CFrame.LookVector * 20
	end,
})

Command.Add({
	Aliases = { "lay" },
	Description = "Lay on the floor",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Humanoid = GetHumanoid(Local.Character) 
		local Root = GetRoot(Local.Character)
		Humanoid.Sit = true
		Wait(.1)
		Root.CFrame = Root.CFrame * CFrame.Angles(math.pi * .5, 0, 0)

		for _, v in next, Humanoid:GetPlayingAnimationTracks() do
			v:Stop()
		end
	end,
})

Command.Add({
	Aliases = { "autorejoin", "autorj" },
	Description = "Automatically rejoins you if you get kicked",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoRejoin = true
		Utils.Notify("Success", "Success!", "Auto rejoin enabled!")

		Connect(Services.GuiService.ErrorMessageChanged, function()
			if Env().AutoRejoin then
				Services.Teleport:TeleportToPlaceInstance(game.PlaceId, game.JobId)
			end
		end)
	end,
})

Command.Add({
	Aliases = { "unautorejoin", "unautorj" },
	Description = "Stops the autorejoin command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoRejoin = false
		Utils.Notify("Success", "Success!", "Auto rejoin disabled!")
	end,
})

Command.Add({
	Aliases = { "friend" },
	Description = "Sends a friend request to your target",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player)

		for Index, Target in next, Targets do
			Local.Player:RequestFriendship(Target)
		end
	end,
})

Command.Add({
	Aliases = { "listen" },
	Description = "Listen to your target's voice chat",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player)

		for Index, Target in next, Targets do
			local Root = GetRoot(Character(Target))

			if Root then
				Services.Sound:SetListener(Enum.ListenerType.ObjectPosition, Root)
			end
		end
	end,
})

Command.Add({
	Aliases = { "unlisten" },
	Description = "Stops listening",
	Arguments = {},
	Plugin = false,
	Task = function()
		Services.Sound:SetListener(Enum.ListenerType.Camera)
	end,
})

Command.Add({
	Aliases = { "swordkill" },
	Description = "Kill targets using sword",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player);
		local Tools = GetTools();
		local Sword;

		for Index, Tool in next, Tools do
			if Lower(Tool.Name):find("sword") and Tool:FindFirstChild("Handle") then
				Sword = Tool
				break
			end
		end

		local Handle = Sword.Handle

		for Index, Target in next, Targets do
			if Target ~= Local.Player and Local.Character and not Local.Character:FindFirstChild("ForceField") then
				Sword.Parent = Local.Character
				local Char = Character(Target)

				for Index = 1, 10 do
					if Char and Char:FindFirstChildOfClass("Humanoid").Health == 0 then
						break
					end
					Sword:Activate()
					Wait()
					Sword:Activate()

					if firetouchinterest then
						firetouchinterest(GetRoot(Char), Handle, 0)
						Wait()
						firetouchinterest(GetRoot(Char), Handle, 1)
						Wait()
					else
						GetRoot(Char).CFrame = GetRoot(Local.Character).CFrame * CFrame.new(0, 0, -2)
						Wait()
					end
				end
			end
		end
	end,
})


Command.Add({
	Aliases = { "scare" },
	Description = "Teleports you to your target for 1 second",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player)

		for Index, Target in next, Targets do
			Command.Parse(Format("tickgoto %s, 1", Target.Name))
			Wait(1)
		end
	end,
})

Command.Add({
	Aliases = { "bringnpcs" },
	Description = "Brings all npcs in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Npc in next, GetPlayer("npc") do
			if Npc:FindFirstChild("HumanoidRootPart") then
				Npc.HumanoidRootPart.CFrame = GetRoot(Local.Character).CFrame
			elseif Npc:FindFirstChild("Torso") then
				Npc.Torso.CFrame = GetRoot(Local.Character).CFrame
			end
		end
	end,
})

Command.Add({
	Aliases = { "freezenpcs" },
	Description = "Freezes all npcs in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Npc in next, GetPlayer("npc") do
			if Npc:FindFirstChild("HumanoidRootPart") then
				Npc.HumanoidRootPart.Anchored = true
			elseif Npc:FindFirstChild("Torso") then
				Npc.Torso.Anchored = true
			end
		end
	end,
})

Command.Add({
	Aliases = { "killnpcs" },
	Description = "Kills all npcs in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Npc in next, GetPlayer("npc") do
			if Npc:FindFirstChildOfClass("Humanoid") then
				Npc:FindFirstChildOfClass("Humanoid").Health = 0
			end
		end
	end,
})

Command.Add({
	Aliases = { "errorchat" },
	Description = "Sends an error message in the chat",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index = 1, 3 do
			Chat("\0")
		end
	end,
})

Command.Add({
	Aliases = { "flingnpcs" },
	Description = "Flings all npcs in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Npc in next, GetPlayer("npc") do
			if Npc:FindFirstChildOfClass("Humanoid") then
				Npc:FindFirstChildOfClass("Humanoid").HipHeight = 1024
			end
		end
	end,
})

Command.Add({
	Aliases = { "voidnpcs" },
	Description = "Voids all npcs in the game",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Npc in next, GetPlayer("npc") do
			if Npc:FindFirstChildOfClass("Humanoid") then
				Npc:FindFirstChildOfClass("Humanoid").HipHeight = -1024
			end
		end
	end,
})

Command.Add({
	Aliases = { "follownpcs" },
	Description = "Makes all npcs in the game follow you",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().NpcFollow = true

		repeat Wait()
			for Index, Npc in next, GetPlayer("npc") do
				if Npc:FindFirstChildOfClass("Humanoid") then
					Npc:FindFirstChildOfClass("Humanoid"):MoveTo(GetRoot(Local.Character).Position)
				end
			end
		until not Env().NpcFollow
	end,
})

Command.Add({
	Aliases = { "unfollownpcs" },
	Description = "Stops making all npcs in the game follow you",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().NpcFollow = false
	end,
})

Command.Add({
	Aliases = { "equiptools" },
	Description = "Equips all tools in your inventory",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Tool in next, GetTools() do
			Tool.Parent = Local.Character
		end
	end,
})


Command.Add({
	Aliases = { "clientbring", "cbring" },
	Description = "Brings everyone to you on your client",
	Arguments = {
		{ Name = "Target", Type = "Player" };
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player)
		Env().ClientBring = true

		repeat Wait()
			for Index, Target in next, Targets do
				pcall(function()
					local Character = Character(Target);
					local Root = GetRoot(Character);

					Root.CFrame = GetRoot(Local.Character).CFrame * CFrame.new(0, 0, -3)
				end)
			end
		until not Env().ClientBring
	end,
})

Command.Add({
	Aliases = { "unclientbring", "uncbring" },
	Description = "Stops bringing everyone on your screen",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		Env().ClientBring = false
	end,
})

Command.Add({
	Aliases = { "controllock", "ctrllock" },
	Description = "Sets your Shiftlock keybinds to the control keys",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Bound = Local.Player.PlayerScripts.PlayerModule.CameraModule.MouseLockController.BoundKeys
		Bound.Value = "LeftControl,RightControl"
		Utils.Notify("Success", "Success!", "Set your Shiftlock keybinds to Ctrl")
	end,
})

Command.Add({
	Aliases = { "autoreport" },
	Description = "Automatically reports players to get them banned",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Report = {
			kid = "Bullying",
			youtube = "Offsite Links",
			date = "Dating",
			hack = "Cheating/Exploiting",
			idiot = "Bullying",
			fat = "Bullying",
			exploit = "Cheating/Exploiting",
			cheat = "Cheating/Exploiting",
			noob = "Bullying",
			clown = "Bullying",
		}

		local CheckIfReportable = function(Message)
			local RuleBreaker, Reason = nil, nil
			for Blocked, R in next, Report do
				if Message:lower():find(Blocked) then
					RuleBreaker = Blocked
					Reason = R
				end
			end

			return RuleBreaker, Reason
		end

		local ChattedCheck = function(Player)
			if Player == Local.Player then return end

			Connect(Player.Chatted, function(Message)
				if CheckIfReportable(Message) then
					local Word, RuleBreaker = CheckIfReportable(Message)
					Utils.Notify("Information", Format("Reported %s", Player.Name), Format("Reason - %s", RuleBreaker))

					if reportplayer then
						reportplayer(Plr, Reason, Format("Saying %s", Word))
					else
						Services.Players:ReportAbuse(Plr, Reason, Format("Saying %s", Word))
					end
				end
			end)
		end

		for Index, Player in next, Services.Players:GetPlayers() do
			ChattedCheck(Player)
		end

		Connect(Services.Players.PlayerAdded, function(Player)
			ChattedCheck(Player)
		end)
	end,
})

Command.Add({
	Aliases = { "spoofws" },
	Description = "Spoof your walkspeed amount",
	Arguments = {
		{ Name = "Spoofed Speed", Type = "Number" };

	},
	Plugin = false,
	Task = function(Spoofed)
		Spoofed = SetNumber(Spoofed)
		Spoof(GetHumanoid(Local.Character), "WalkSpeed", Spoofed)
		Utils.Notify("Success", "Success!", Format("Spoofed WalkSpeed to %s", tostring(Spoofed)))
	end,
})

Command.Add({
	Aliases = { "fling" },
	Description = "Fling your target, must have character collisions enabled to work [not finished]",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player);

		for Index, Target in next, Targets do
			Fling(Target)
		end

		Utils.Notify("Success", "Success", "Finished flinging!")

	end,
})

Command.Add({
	Aliases = { "clickfling" },
	Description = "Click on your target, and it will fling them",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		Connect(Local.Mouse.Button1Down, function() 
			local Target = Local.Mouse.Target

			if Target and Services.Players:GetPlayerFromCharacter(Target.Parent) then
				Fling(Services.Players:GetPlayerFromCharacter(Target.Parent))
			end
		end)
	end,
})

Command.Add({
	Aliases = { "trap" },
	Description = "Whenever someone touches the selected tool, it will fling them",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		local Tool = GetTools()[math.random(#GetTools())]
		Tool.Parent = Local.Character
		Tool.GripForward = Vector3.new(0, 0, 0)
		Tool.GripPos = Vector3.new(0, 0, 0)
		Tool.GripRight = Vector3.new(0, 0, 0)
		Tool.GripUp = Vector3.new(0, 0, 0)
		Tool.Grip = CFrame.new(0, 2, 25)

		local Handle = Tool:FindFirstChildOfClass("Part")
		if Handle then
			Connect(Handle.Touched, function(Target)
				local Char = Target.Parent

				if Char and Services.Players:GetPlayerFromCharacter(Char) then
					Fling(Services.Players:GetPlayerFromCharacter(Char))
				end
			end)
		end

	end,
})

Command.Add({
	Aliases = { "mute" },
	Description = "Mutes your target's boombox",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player);

		if Services.Sound.RespectFilteringEnabled then
			Utils.Notify("Error", "Error!", "RespectFilteringEnabled is on, so this won't work")
			return
		end

		for Index, Target in next, Targets do
			for Index, Descendant in next, Target.Character:GetDescendants() do
				if Descendant:IsA("Sound") and Descendant.Playing then
					Descendant.Playing = false
				end
			end
		end

	end,
})

Command.Add({
	Aliases = { "glitch" },
	Description = "Glitches your target's boombox",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		local Targets = GetPlayer(Player);
		Env().Glitch = true

		if Services.Sound.RespectFilteringEnabled then
			Utils.Notify("Error", "Error!", "RespectFilteringEnabled is on, so this won't work")
			return
		end

		for Index, Target in next, Targets do
			Spawn(function()
				repeat Wait()
					for Index, Descendant in next, Target.Character:GetDescendants() do
						if Descendant:IsA("Sound") then
							Descendant.Playing = false
							Wait(0.2)
							Descendant.Playing = true
						end
					end
				until not Env().Glitch
			end)
		end

	end,
})

Command.Add({
	Aliases = { "unglitch" },
	Description = "Stops glitching your target's boombox",
	Arguments = {
		{ Name = "Target", Type = "Player" }
	},
	Plugin = false,
	Task = function(Player)
		Env().Glitch = false
	end,
})

Command.Add({
	Aliases = { "noaudio" },
	Description = "Mutes every sound in the game",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		for Index, Sound in next, workspace:GetDescendants() do
			if Sound:IsA("Sound") then
				Sound.Volume = 0
			end
		end

		Utils.Notify("Success", "Success!", "Muted every sound in the game", 5)
	end,
})

Command.Add({
	Aliases = { "audio" },
	Description = "Unmutes every sound in the game",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		for Index, Sound in next, workspace:GetDescendants() do
			if Sound:IsA("Sound") then
				Sound.Volume = 1
			end
		end

		Utils.Notify("Success", "Success!", "Unmuted every sound in the game", 5)
	end,
})

Command.Add({
	Aliases = { "setspawn" },
	Description = "Once executed, when you die it teleports you to your old position",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		local Old = GetRoot(Local.Character).CFrame
		Env().SetSpawn = true

		pcall(function()
			Detection = Detection:Disconnect() 
		end)

		Detection = Connect(Local.Player.CharacterAdded, function()
			if Env().SetSpawn then
				Local.Player.Character:WaitForChild("HumanoidRootPart").CFrame = Old
			end	
		end)
	end,
})

Command.Add({
	Aliases = { "unsetspawn" },
	Description = "Stops the setspawn command",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		Env().SetSpawn = false
		Detection = Detection:Disconnect()
	end,
})

Command.Add({
	Aliases = { "loopfling" },
	Description = "Repeatedly fling your target",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)[1]
		Env().Loopfling = true

		repeat Wait() 
			local Character = Target.Character

			if Character and Character:FindFirstChild("HumanoidRootPart") then
				Fling(Target)
			end

		until not Env().Loopfling or not Target
	end,
})


Command.Add({
	Aliases = { "unloopfling" },
	Description = "Stops flinging your target",
	Arguments = {},
	Plugin = false,
	Task = function(Player)
		Env().Loopfling = false
	end,
})

Env().Earthquake = false
Command.Add({
	Aliases = { "earthquake" },
	Description = "Shakes all unanchored parts in the game to give an earthquake effect",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().Earthquake = true

		Utils.Notify("Success", "Earthquake!", "Please wait...", 5)

		Spawn(function()
			while Wait() do
				pcall(function()
					Local.Player.MaximumSimulationRadius = math.pow(math.huge, math.huge) * math.huge
					sethiddenproperty(Local.Player, "SimulationRadius", math.pow(math.huge, math.huge) * math.huge)
				end)
			end
		end)

		for Index, Part in next, workspace:GetDescendants() do
			if Part:IsA("BasePart") and not Part.Anchored and not Part.Parent:FindFirstChildOfClass("Humanoid") and not Part.Parent.Parent:FindFirstChildOfClass("Humanoid") then
				for Index = 1, 10 do
					local Velocity = CreateInstance("BodyVelocity", {
						MaxForce = Vector3.new(math.huge, math.huge, math.huge),
						P = 10000000,
						Name = "EarthquakeBodyVelocity",
						Parent = Part
					})

					Spawn(function()
						repeat Wait(0.1)
							Velocity.Velocity = Vector3.new(math.random(-20, 20), math.random(-5, 5), math.random(-20, 20))
						until not Velocity
					end)
				end
			end
		end
	end,
})

Command.Add({
	Aliases = { "unearthquake" },
	Description = "Stops the earthquake command",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, BodyVelocity in next, workspace:GetDescendants() do
			if BodyVelocity:IsA("BodyVelocity") and BodyVelocity.Name == "EarthquakeBodyVelocity" then
				BodyVelocity:Destroy()
			end
		end

		Utils.Notify("Success", "Success!", "Stopped the earthquake command!", 5)
	end,
})

Command.Add({
	Aliases = { "grabtools" },
	Description = "Grabs all dropped tools",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Amount = 0

		for i, Tools in next, workspace:GetChildren() do
			if Tools:IsA("Tool") then
				GetHumanoid(Local.Character):EquipTool(Tools)
				Amount = Amount + 1
			end
		end

		Utils.Notify("Success", "Success!", Format("Grabbed %s tools", tostring(Amount)), 5)
	end,
})

Command.Add({
	Aliases = { "autograbtools" },
	Description = "Automatically grabs tools once they are dropped",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoGrabTools  = true
		Command.Parse("grabtools")

		Connect(workspace.ChildAdded, function(Child)
			if Child:IsA("Tool") and Env().AutoGrabDeleteTools then
				GetHumanoid(Local.Character):EquipTool(Child)
			end
		end)

		Utils.Notify("Success", "Success!", "Auto grab tools activated!", 5)
	end,
})

Command.Add({
	Aliases = { "unautograbtools" },
	Description = "Stops the auto grab tools command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoGrabTools = false
		Utils.Notify("Success", "Success!", "Auto grab tools disabled!", 5)
	end,
})

Command.Add({
	Aliases = { "grabdeletetools", "gdt" },
	Description = "Grabs all dropped tools and deletes them",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Amount = 0

		for i, Tools in next, workspace:GetChildren() do
			if Tools:IsA("Tool") then
				GetHumanoid(Local.Character):EquipTool(Tools)
				Tools:Destroy()
				Amount = Amount + 1
			end
		end

		Utils.Notify("Success", "Success!", Format("Deleted %s tools", tostring(Amount)), 5)
	end,
})

Command.Add({
	Aliases = { "autograbdeletetools", "autogdt" },
	Description = "Automatically deletes tools once they are dropped",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoGrabDeleteTools  = true
		Command.Parse("grabdeletetools")

		Connect(workspace.ChildAdded, function(Child)
			if Child:IsA("Tool") and Env().AutoGrabDeleteTools then
				GetHumanoid(Local.Character):EquipTool(Child)
				Child:Destroy()
			end
		end)

		Utils.Notify("Success", "Success!", "Auto grab delete tools activated!", 5)
	end,
})

Command.Add({
	Aliases = { "unautograbtools" },
	Description = "Stops the auto grab tools command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().AutoGrabDeleteTools  = false
		Utils.Notify("Success", "Success!", "Auto grab delete tools disabled!", 5)
	end,
})

Command.Add({
	Aliases = { "annoy" },
	Description = "Annoys your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }	
	},
	Plugin = false,
	Task = function(Player)
		local Target = GetPlayer(Player)
		Env().Annoy = true

		for Index, Player in next, Target do
			Local.Camera.CameraSubject = Player.Character:FindFirstChildOfClass("Humanoid")

			repeat Wait()
				local R1, R2, R3 = math.random(-3, 3)
				Local.Character.HumanoidRootPart.CFrame =
					Player.Character.HumanoidRootPart.CFrame + Vector3.new(R1, R2, R3)
			until not Env().Annoy

			break
		end
	end,
})

Command.Add({
	Aliases = { "unannoy" },
	Description = "Stops annoying your target",
	Arguments = {
		{ Name = "Target", Type = "Player" }	
	},
	Plugin = false,
	Task = function(Player)
		Env().Annoy = false
	end,
})

Command.Add({
	Aliases = { "activatealltools", "aat" },
	Description = "Activates all tools in your inventory",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Tools = GetTools();

		for i, Tool in next, Tools do
			Tool.Parent = Local.Character

			if mouse1click then
				mouse1click()
			else
				Tool:Activate()
			end

			Wait()
			Tool.Parent = Local.Backpack
		end
	end,
})

Command.Add({
	Aliases = { "activatetool", "at" },
	Description = "Activates the specific tool in your inventory with the same name you input",
	Arguments = {
		{ Name = "Tool Name", Type = "String" }
	},
	Plugin = false,
	Task = function(Input)
		if Input then
			for i, Tool in next, Local.Backpack:GetChildren() do
				if Tool:IsA("Tool") and Find(Lower(Tool.Name), Lower(Input)) then
					Tool.Parent = Local.Character
					if mouse1click then
						mouse1click()
					end
					Tool:Activate()
					Wait()
					Tool.Parent = Local.Backpack
				end
			end
		end
	end,
})

Command.Add({
	Aliases = { "deletetools" },
	Description = "Deletes all tools in your inventory",
	Arguments = {},
	Plugin = false,
	Task = function()
		for i, Tool in next, GetTools() do
			if Tool:IsA("Tool") then
				Tool:Destroy()
			end
		end
	end,
})

Command.Add({
	Aliases = { "droptools" },
	Description = "Drops all tools in your inventory",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Tools = GetTools();

		for i, Tool in next, GetTools() do
			Tool.Parent = Local.Character
			Wait()
			Tool.Parent = workspace
		end
	end,
})

Command.Add({
	Aliases = { "clickteleport", "clicktp" },
	Description = "Teleports you where ever you click",
	Arguments = {},
	Plugin = false,
	Task = function()
		local CTPTool = CreateInstance("Tool", {
			Parent = Local.Player.Backpack,
			Name = "ClickTP",
			RequiresHandle = false
		})

		Connect(CTPTool.Activated, function()
			local Position = Local.Mouse.Hit + Vector3.new(0, 2.5, 0)
			Position = CFrame.new(Position.X, Position.Y, Position.Z)
			Local.Character:SetPrimaryPartCFrame(Position)
		end)

		local TweenTool = CreateInstance("Tool", {
			Parent = Local.Player.Backpack,
			Name = "Tween ClickTP", 
			RequiresHandle = false
		})

		Connect(TweenTool.Activated, function()
			local Position = Local.Mouse.Hit + Vector3.new(0, 2.5, 0)
			local TweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, false, 0)

			Tween(Local.Character.HumanoidRootPart, TweenInfo, { CFrame = CFrame.new(Position.X, Position.Y, Position.Z)} )
		end)
	end,
})

Command.Add({
	Aliases = { "maxslopeangle", "msa" },
	Description = "Changes your character's MaxSlopeAngle",
	Arguments = {
		{ Name = "Amount", Type = "Number" }
	},
	Plugin = false,
	Task = function(Amount)
		Amount = SetNumber(Amount)

		GetHumanoid(Local.Character).MaxSlopeAngle = Amount
		Utils.Notify("Success", "Success!", Format("Set MaxSlopeAngle to %s", tostring(Amount)), 5)
	end,
})

Command.Add({
	Aliases = { "spin" },
	Description = "Makes you spin",
	Arguments = {
		{ Name = "Spin Speed", Type = "Number" }
	},
	Plugin = false,
	Task = function(Amount)
		local Amount = SetNumber(Amount)
		local Angular = GetRoot(Local.Character):FindFirstChild("Spin")

		if Angular then
			Angular:Destroy()
		end

		local Spin = CreateInstance("BodyAngularVelocity", {
			MaxTorque = Vector3.new(0, 9e9, 0),
			AngularVelocity = Vector3.new(0, Amount, 0),
			Name = "Spin",
			Parent = GetRoot(Local.Character),
		})
	end,
})

Command.Add({
	Aliases = { "unspin" },
	Description = "Stops spinning",
	Arguments = {},
	Plugin = false,
	Task = function()
		local Angular = GetRoot(Local.Character):FindFirstChild("Spin")

		if Angular then
			Angular:Destroy()
		end
	end,
})

Command.Add({
	Aliases = { "r6" },
	Description = "Shows a prompt that will switch your character rig type into R6",
	Arguments = {},
	Plugin = false,
	Task = function()
		PromptChangeRigType("R6")
	end,
})

Command.Add({
	Aliases = { "r15" },
	Description = "Shows a prompt that will switch your character rig type into R15",
	Arguments = {},
	Plugin = false,
	Task = function()
		PromptChangeRigType("R15")
	end,
})

Command.Add({
	Aliases = { "walkfling", "wfling" },
	Description = "Fling without spinning",
	Arguments = {
		{ Name = "Power", Type = "Number" },
		{ Name = "Closest Distance", Type = "Number" },
	},
	Plugin = false,
	Task = function(Power, Distance)
		Power = tonumber(Power) or 10000; Distance = Distance or 5
		Walkfling(Power, Distance, true)
	end,
})

Command.Add({
	Aliases = { "unwalkfling", "unwfling" },
	Description = "Stops the walk fling command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Walkfling(10000, 5, false)
	end,
})

Command.Add({
	Aliases = { "fastcarts" },
	Description = "Makes all carts in the game fast",
	Arguments = {},
	Plugin = false,
	Task = function()
		for i, v in next, workspace:GetDescendants() do
			if v:IsA("Model") and v:FindFirstChild("Up") and v:FindFirstChild("Down") and v:FindFirstChild("On") then
				Spawn(function()
					pcall(function()
						if v.Up:FindFirstChildOfClass("ClickDetector") then
							while v do
								Wait()
								fireclickdetector(v.Up:FindFirstChildOfClass("ClickDetector"))
							end
						end
					end)
				end)
			end
		end
	end,
})

Command.Add({
	Aliases = { "slowcarts" },
	Description = "Makes all carts in the game slow",
	Arguments = {},
	Plugin = false,
	Task = function()
		for i, v in next, workspace:GetDescendants() do
			if v:IsA("Model") and v:FindFirstChild("Up") and v:FindFirstChild("Down") and v:FindFirstChild("On") then
				Spawn(function()
					pcall(function()
						if v.Up:FindFirstChildOfClass("ClickDetector") then
							while v do
								Wait()
								fireclickdetector(v.Down:FindFirstChildOfClass("ClickDetector"))
							end
						end
					end)
				end)
			end
		end
	end,
})

Command.Add({
	Aliases = { "playanimation" },
	Description = "Plays animation using its ID",
	Arguments = {
		{ Name = "Animation ID", Type = "String" }
	},
	Plugin = false,
	Task = function(Animation)
		Services.StarterPlayer.AllowCustomAnimations = true

		local Anim = Instance.new("Animation")
		Anim.AnimationId = Format("rbxassetid://%s", Animation)
		local Dance = GetHumanoid(Local.Character):LoadAnimation(Anim)
		Insert(Env().Animations, Dance)
		Dance:Play()
	end,
})

Command.Add({
	Aliases = { "stopanimations" },
	Description = "Stops all the animations that were ran using the playanimation command",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, Animation in next, Env().Animations do
			if Animation then
				Animation:Stop()
			end
		end
	end,
})

Command.Add({
	Aliases = { "freezeanimations" },
	Description = "Freezes your character's animations",
	Arguments = {},
	Plugin = false,
	Task = function()
		Local.Character.Animate.Disabled = true
	end,
})

Command.Add({
	Aliases = { "unfreezeanimations" },
	Description = "Unfreezes your character's animations",
	Arguments = {},
	Plugin = false,
	Task = function()
		Local.Character.Animate.Disabled = false
	end,
})

Command.Add({
	Aliases = { "freeze" },
	Description = "Freezes your character",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, BodyPart in next, Local.Character:GetChildren() do
			if BodyPart:IsA("BasePart") then
				BodyPart.Anchored = true
			end
		end
	end,
})

Command.Add({
	Aliases = { "unfreeze" },
	Description = "Unfreezes your character",
	Arguments = {},
	Plugin = false,
	Task = function()
		for Index, BodyPart in next, Local.Character:GetChildren() do
			if BodyPart:IsA("BasePart") then
				BodyPart.Anchored = false
			end
		end
	end,
})

Command.Add({
	Aliases = { "lockmouse", "lockm" },
	Description = "Locks your mouse in the center",
	Arguments = {},
	Plugin = false,
	Task = function()
		Services.Input.MouseBehavior = Enum.MouseBehavior.LockCenter
	end,
})

Command.Add({
	Aliases = { "unlockmouse", "unlockm" },
	Description = "Unlocks your mouse",
	Arguments = {},
	Plugin = false,
	Task = function()
		Services.Input.MouseBehavior = Enum.MouseBehavior.Default
	end,
})

Command.Add({
	Aliases = { "hitbox" },
	Description = "Set everyone's character hitbox in the server",
	Arguments = {
		{ Name = "Size", Type = "Number" }
	},
	Plugin = false,
	Task = function(Size)
		Size = tonumber(Size) or 10
		Env().Hitbox = false
		Wait(0.1)
		Env().Hitbox = true

		repeat Wait(0.1)
			for Index, Player in next, Services.Players:GetPlayers() do
				local Char = Character(Player)
				local Root = GetRoot(Char)

				if Char and Root and Player ~= Local.Player then
					Root.Size = Vector3.new(Size, Size, Size);
					Root.Transparency = 0.7;
					Root.CanCollide = false;
				end
			end
		until not Env().Hitbox
	end,
})

Command.Add({
	Aliases = { "unhitbox" },
	Description = "Set everyone's character hitbox back to normal",
	Arguments = {},
	Plugin = false,
	Task = function(Size)
		Env().Hitbox = false

		Wait(0.2)

		for Index, Player in next, Services.Players:GetPlayers() do
			local Char = Character(Player)
			local Root = GetRoot(Char)

			if Char and Root and Player ~= Local.Player then
				Root.Size = Vector3.new(5, 5, 5)
				Root.Transparency = 1
			end
		end
	end,
})

Command.Add({
	Aliases = { "time" },
	Description = "Set game's time",
	Arguments = {
		{ Name = "Time", Type = "Number" }
	},
	Plugin = false,
	Task = function(Time)
		local Time = Time or SetNumber(Time);

		Services.Lighting.ClockTime = Time
	end,
})

Command.Add({
	Aliases = { "nofog" },
	Description = "Removes the ingame fog",
	Arguments = {},
	Plugin = false,
	Task = function(Time)
		Services.Lighting.FogStart = 9e9
		Services.Lighting.FogEnd = 9e9
	end,
})

Command.Add({
	Aliases = { "tpwalk" },
	Description = "More undetectable walkspeed changer",
	Arguments = {
		{ Name = "Speed", Type = "Number" }
	},
	Plugin = false,
	Task = function(Speed)
		Speed = SetNumber(Speed, 0, math.huge)
		SetEnv("TPWalk", true)

		repeat Wait()
			if GetHumanoid(Local.Character).MoveDirection.Magnitude > 0 then
				Local.Character:TranslateBy(GetHumanoid(Local.Character).MoveDirection * Speed * Services.Run.Heartbeat:Wait() * 10)
			end
		until not Env().TPWalk or not Local.Character
	end,
})

Command.Add({
	Aliases = { "untpwalk" },
	Description = "Stops the tpwalk command",
	Arguments = {},
	Plugin = false,
	Task = function()
		Env().TPWalk = false
	end,
})

Command.Add({
	Aliases = { "remotespy", "rspy" },
	Description = "Runs remote spy",
	Arguments = {},
	Plugin = false,
	Task = function()
		loadstring(game:HttpGet("https://github.com/exxtremestuffs/SimpleSpySource/raw/master/SimpleSpy.lua"))()
	end,
})

Spawn(function()
	if Checks.File then
		xpcall(function()
			for Index, File in next, listfiles("Cmd/Plugins") do
				loadstring(readfile(File))();
			end
		end, function(Reason)
			warn(Format("[PLUGIN ERROR] : Error running plugin\nERROR: %s", Reason));
		end)

		local CustomAliases = JSONDecode(Services.Http, Data.get("CustomAliases.json") or "[]");

		for Alias, CommandName in next, CustomAliases do
			local Cmd = Command.Find(CommandName);

			if Cmd then
				local Aliases = Cmd[1]
				Aliases[#Aliases + 1] = Alias
			end
		end
	end
end)

Event.New("Executed", nil);
Event.New("Chat", Local.Player.Chatted);
Event.New("Respawn", Local.Player.CharacterAdded);
Event.New("Died", nil, true, "Health", function(Humanoid) if Humanoid and Humanoid.Health == 0 then return true end end);
Event.New("Damaged", nil, true, "Health", function(Humanoid) if Humanoid and Humanoid.Health > 0 and Humanoid.Health < OldHealth then OldHealth = Humanoid.Health; return true end end);	
Event.New("Leaving", Services.Players.PlayerRemoving, false, false, false, function(Connection) if Connection == Local.Player then return true end end);	

Spawn(function()
	SetUIScale(Settings.ScaleSize)

	for Index, Table in next, Commands do
		Autofills.Add(Table)
	end
end)

Connect(PropertyChanged(Box, "Text"), function()
	Autofills.Recommend(Box.Text)
	Autofills.Search(Box.Text)
end)

Connect(Local.Player.Chatted, function(Message)
	if Sub(Message, 1, 1) == Settings.Prefix and Screen.Parent then
		Command.Parse(Message);
	end
end)

Connect(Services.Input.InputBegan, function(Key, Processed)
	if Key.KeyCode == Enum.KeyCode.Tab and pressTab.TextTransparency ~= 1 and Recommend.Text ~= Blank and Processed and Screen.Parent then
		local Text = Recommend.Text;
		Wait();
		Box.Text = Text;
		Box.CursorPosition = #Text + 1;
	end
end)

Connect(Local.Mouse.KeyDown, function(Key)
	if Key == Settings.Prefix and Screen.Parent and Box.Focused then
		Library.Bar(true)
		Wait()
		Box.Text = Blank
		Box:CaptureFocus();
	end
end)

Connect(Services.Input.InputBegan, function(Key, Processed)
	if Processed or not Screen.Parent then return end
	local Bind = Settings.Binds[Key]

	if Bind then
		Command.Parse(Bind.Start);
	end
end)

Connect(Services.Input.InputEnded, function(Key, Processed)
	if Processed or not Screen.Parent then return end
	local Bind = Settings.Binds[Key]

	if Bind then
		Command.Parse(Bind.End);
	end
end)

Connect(Box.FocusLost, function(Enter)
	if Enter then
		Command.Parse(Box.Text);
	end

	Library.Bar(false)
end)

Connect(PropertyChanged(Screen, "Parent"), function() 
	if not Screen.Parent then
		Foreach(Blurred, function(Index, Self) 
			Self.root.Parent = nil
		end)
	end
end)

do
	local Functional = function() 
		Open.Visible = true
		Library.Drag(Open);
		Library.Hover(Open);

		Connect(Open.Title.MouseButton1Click, function()
			Library.Bar(true);
			Wait();
			Box.Text = Blank;
			Box:CaptureFocus();
		end)
	end

	xpcall(function()
		if Discover( { Enum.Platform.Android, Enum.Platform.Android }, Services.Input:GetPlatform()) then
			Functional()
		end

	end, function() 
		if Services.Run:IsStudio() then
			Functional()
		end
	end)

	Genv().CmdLoaded = true;
	Genv().CmdPath = Screen;

	-- Toggles loaded (from the options table)
	for Index, Target in next, Services.Players:GetPlayers() do
		Connect(Target.Chatted, function(Message) 
			if Options.Logging then
				AutoLogger[Randomize(25)] = { Message, Target };
			end
		end)
	end

	Connect(Services.Players.PlayerAdded, function(Target) 
		Connect(Target.Chatted, function(Message) 
			if Options.Logging then
				AutoLogger[Randomize(25)] = { Message, Target };
			end
		end)
	end)

	if Options.AntiInterfere then
		local Blacklisted = { "KCoreUI", "Cmdr" };

		for Index, Screen in next, Local.Player.PlayerGui:GetChildren() do
			if Discover(Blacklisted, Screen.Name) then
				Screen:Destroy();
			end
		end
	end

	if Options.AutoSimRadius and setsimulationradius then
		HighSimulationRadius();
	end
end

Autofills.Search(Blank);
Library.LoadTheme(Settings.Themes);

Utils.Notify("Information", "IMPORTANT", "Join the discord server - https://discord.gg/GCeBDhm9WN", 15);
Utils.Notify("Success", "Loaded!", Format("Loaded in %.2f seconds", tick() - LoadTime), 5);

Spawn(function()
	if Methods.Check() then
		Utils.Notify("Information", "Vulnerability found!", "This game has a vulnerability that can be exploited using Cmd, use the <b>vuln</b> command for more information", 15)

		Command.Add({
			Aliases = { "vuln" },
			Description = "Using the vulnerability feature built into Cmd, you can use bonus commands on players",
			Arguments = {},
			Plugin = false,
			Task = function()
				if not Screen:FindFirstChild("Vuln") then

					local Main = Tab.new({
						Title = "Vuln",
						Drag = true
					})

					local Tabs = Main.Tabs
					local MainTab = Tabs.Main.Scroll

					Library.new("Input", { 
						Title = "Kill",
						Description = "Kill your target",
						Parent = MainTab,
						Default = Blank,
						Callback = function(Message)
							local Plr = GetPlayer(Message)

							for Index, Target in next, Plr do
								if Character(Target) then
									Methods.Destroy(Character(Target).Head)
								end
							end
						end,
					})

					Library.new("Input", { 
						Title = "Sink",
						Description = "Sink your target to the ground",
						Parent = MainTab,
						Default = Blank,
						Callback = function(Message)
							local Plr = GetPlayer(Message)

							for Index, Target in next, Plr do
								if Character(Target) then
									Methods.Destroy(GetRoot(Character(Target)))
								end
							end
						end,
					})

					Library.new("Input", { 
						Title = "Bald",
						Description = "Turns your target bald",
						Parent = MainTab,
						Default = Blank,
						Callback = function(Message)
							local Plr = GetPlayer(Message)

							for Index, Target in next, Plr do
								if Character(Target) then
									for i, v in next, Character(Target):GetChildren() do
										if v:IsA("Accessory") then
											Methods.Destroy(v)
										end
									end
								end
							end
						end,
					})

					Library.new("Input", { 
						Title = "Fat",
						Description = "Turns your target fat",
						Parent = MainTab,
						Default = Blank,
						Callback = function(Message)
							local Plr = GetPlayer(Message)

							for Index, Target in next, Plr do
								if Character(Target) then
									for i, v in next, Character(Target):GetChildren() do
										if v:IsA("CharacterMesh") then
											Methods.Destroy(v)
										end
									end
								end
							end
						end,
					})

					Library.new("Input", { 
						Title = "Naked",
						Description = "Turns your target naked",
						Parent = MainTab,
						Default = Blank,
						Callback = function(Message)
							local Plr = GetPlayer(Message)
							local Classes = { "Shirt", "Pants", "ShirtGraphics" }

							for Index, Target in next, Plr do
								if Character(Target) then
									for i, v in next, Character(Target):GetChildren() do
										if Classes[v.ClassName] then
											Methods.Destroy(v)
										end
									end
								end
							end
						end,
					})

					Library.new("Input", { 
						Title = "Punish",
						Description = "Makes your target's character not able to reset",
						Parent = MainTab,
						Default = Blank,
						Callback = function(Message)
							local Plr = GetPlayer(Message)
							local Classes = { "Shirt", "Pants", "ShirtGraphics" }

							for Index, Target in next, Plr do
								if Character(Target) then
									Methods.Destroy(Character(Target))
								end
							end
						end,
					})

					Library.new("Button", { 
						Title = "BTools",
						Description = "Give yourself BTools",
						Parent = MainTab,
						Callback = function()
							local DestroyTool = CreateInstance("Tool", {
								Parent = Local.Backpack,
								RequiresHandle = false,
								Name = "Delete",
								ToolTip = "Btools (Delete)",
								TextureId = "https://www.roblox.com/asset/?id=12223874",
								CanBeDropped = false
							})

							local BtoolsEquipped = false
							Connect(DestroyTool.Equipped, function()
								BtoolsEquipped = true
							end)

							Connect(DestroyTool.Unequipped, function()
								BtoolsEquipped = false
							end)

							Connect(DestroyTool.Activated, function()
								local Explosion = CreateInstance("Explosion", {
									Parent = workspace,
									BlastPressure = 0,
									BlastRadius = 0,
									DestroyJointRadiusPercent = 0,
									ExplosionType = Enum.ExplosionType.NoCraters,
									Position = Local.Mouse.Target.Position
								})
								Methods.Destroy(Local.Mouse.Target)
							end)
						end,
					})

					Library.new("Button", { 
						Title = "Clear Map",
						Description = "Gets rid of the map",
						Parent = MainTab,
						Callback = function()
							for i, v in next, workspace:GetChildren() do
								Methods.Destroy(v)
							end
						end,
					})

					Library.new("Button", { 
						Title = "Break Game",
						Description = "Deletes every remote and script in the game",
						Parent = MainTab,
						Callback = function()
							for i, v in next, Services.Replicated:GetChildren() do
								Methods.Destroy(v)
							end
						end,
					})

					Tweens.Open({ Canvas = Main, Speed = 0.3 })
				else
					Tweens.Open({ Canvas = Screen:FindFirstChild("Vuln"), Speed = 0.3 })
				end
			end,
		})
	end
end)

xpcall(function()
	repeat task.wait()
	until Modules.Blur

	Connect(PropertyChanged(Bar, "Visible"), function() 
		pcall(function()
			if Blurred["Bar"] and Blurred["Autofill"] and Blurred["Bar"].root and Settings.Blur then
				if Bar.Visible then
					Wait(.1)
					Blurred["Bar"].root.Parent = workspace.CurrentCamera
				else
					Blurred["Bar"].root.Parent = nil
				end
			end
		end)
	end)

	Connect(PropertyChanged(Autofill, "Visible"), function() 
		pcall(function()
			if Blurred["Bar"] and Blurred["Autofill"] and Blurred["Bar"].root and Settings.Blur then
				if Autofill.Visible then
					Wait(.1)
					Blurred["Autofill"].root.Parent = workspace.CurrentCamera
				else
					Blurred["Autofill"].root.Parent = nil
				end
			end
		end)
	end)

	Blurred["Bar"] = Modules.Blur.new(Bar, 5)
	Blurred["Autofill"] = Modules.Blur.new(Autofill, 5)

	Blurred["Bar"].root.Parent = nil
	Blurred["Autofill"].root.Parent = nil
end, function(Result)
	warn(Format("Error occured trying to load the UI Blur Module (%s)", Result))
end)
