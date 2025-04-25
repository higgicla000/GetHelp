local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage.Remotes

local DisplayGui = script.Parent
local TextBox = DisplayGui.ScrollingFrame.TextBox

Remotes.Display.OnClientEvent:Connect(function(FilteredPrompt, FilteredResponse)
	if FilteredPrompt and FilteredPrompt ~= "" then -- Filtered prompt is not nil or empty
		if TextBox.Text == "" then
			TextBox.Text = "You" .. " said: ".. FilteredPrompt
		else
			TextBox.Text = TextBox.Text .. "\n" .. "You" .. " said: ".. FilteredPrompt
		end
	end
	
	if FilteredResponse and FilteredResponse ~= "" then -- Filtered response is not nil or empty
		if TextBox.Text == "" then
			TextBox.Text = "Patient said: ".. FilteredResponse
		else
			TextBox.Text = TextBox.Text .. "\n\n" .. "Patient said: ".. FilteredResponse
		end
	end
end)