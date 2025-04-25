local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage.Remotes

local EndGui = script.Parent
local EndButton = EndGui.EndButton

local DisplayGui = LocalPlayer.PlayerGui.DisplayGui
local PromptGui = LocalPlayer.PlayerGui.PromptGui
local ReviewGui = LocalPlayer.PlayerGui.ReviewGui

EndButton.Activated:Connect(function()
	DisplayGui.Enabled = false
	PromptGui.Enabled = false
	EndGui.Enabled = false
	
	local FilteredReview = Remotes.GetReview:InvokeServer(LocalPlayer)

	ReviewGui.Frame.TextBox.Text = FilteredReview[1] .. "/5, " .. FilteredReview[2]
	ReviewGui.Enabled = true
end)