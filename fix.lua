--[[
  Incase you are having any problems with loading Cmd (which most likely is caught by the file saving) then run this.
]]

local Http = game:GetService("HttpService");
local JSONEncode, JSONDecode = Http.JSONEncode, Http.JSONDecode
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

local Options = { -- for the settings tab
	Notifications = true,
	AntiInterfere =  false,
	Recommendation = true,
	Popups = true,
	Logging = false,
}

local Folders = { "Cmd", "Cmd/Data", "Cmd/Plugins", "Cmd/Logs" }

for Index, Check in next, Folders do
	if not isfolder(Check) then
		makefolder(Check);
        task.wait(.05);
	end
end

local Data = {};
Data.new = function(Name, Info)
	writefile(string.format('Cmd/Data/%s', Name), Info)
end

Data.SaveTheme = function(ThemeTable)
	local Themes = {}

	for Index, Color in next, ThemeTable do
		Themes[Index] = tostring(Color)
	end

	Data.new("Themes.json", JSONEncode(Http, Themes));
end

Data.new("Settings.json", JSONEncode(Http, Settings));
Data.new("CustomAliases.json", JSONEncode(Http, {}));
Data.new("Scale.json", "1");
Data.new("Waypoints.json", JSONEncode(Http, {}));
Data.new("Toggles.json", JSONEncode(Http, Options));
Data.SaveTheme(Settings.Themes);

game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Done",
    Text = "Please run Cmd again!"
})
