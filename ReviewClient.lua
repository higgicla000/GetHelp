local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer

local ReviewGui = script.Parent
local RestartButton = ReviewGui.Frame.RestartButton

RestartButton.Activated:Connect(function()
	LocalPlayer:Kick()
end)