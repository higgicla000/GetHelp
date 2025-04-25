local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage.Remotes

local PersonalityGui = script.Parent
local DisplayGui = LocalPlayer.PlayerGui.DisplayGui
local PromptGui = LocalPlayer.PlayerGui.PromptGui
-- local EndGui = LocalPlayer.PlayerGui.EndGui

local TextBox = PersonalityGui.Frame.TextBox
local CloseButton = PersonalityGui.Frame.CloseButton


Remotes.DisplayPersonality.OnClientEvent:Connect(function(Personality)
	TextBox.Text = Personality
end)

CloseButton.Activated:Connect(function()
	PersonalityGui.Enabled = false
	DisplayGui.Enabled = true
	PromptGui.Enabled = true
	-- EndGui.Enabled = true
end)