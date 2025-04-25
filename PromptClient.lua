local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage.Remotes

local PromptGui = script.Parent
local TextBox = PromptGui.Frame.TextBox
local SubmitButton = PromptGui.Frame.SubmitButton
	
local FilteredPrompt = "" -- The text that will get prompted to the AI when the SubmitButton is pressed

local PlaceholderText = "Type here..."

local EndGui = LocalPlayer.PlayerGui.EndGui

function IsAllHashtags(String) -- Returns true if every character in a string is a hashtag
	for i = 1, #String do
		if String:sub(i, i) ~= "#" then
			return false
		end
	end
	return true
end

local function OnFocusLost(EnterPressed, InputObject)
	SubmitButton.Visible = false

	if TextBox.Text ~= "" then
		if Remotes.FilterPrompt then
			Remotes.FilterPrompt:FireServer(TextBox.Text)
		else -- FilterPrompt is nil, adds placeholder text back
			TextBox.Text = PlaceholderText
		end
	else -- Player didnt type anything, adds placeholder text back
		TextBox.Text = PlaceholderText
	end
end

local function OnFocused()
	SubmitButton.Visible = false

	if TextBox.Text == PlaceholderText or IsAllHashtags(TextBox.Text) then -- Clear placeholder or hashtags
		TextBox.Text = ""
	end
end

TextBox.FocusLost:Connect(OnFocusLost)
TextBox.Focused:Connect(OnFocused)

Remotes.UpdatePrompt.OnClientEvent:Connect(function(FilteredText) -- UpdatePrompt returns filtered string, otherwise (if error) returns nil
	if FilteredText ~= nil or FilteredText ~= "" then
		if not IsAllHashtags(FilteredText) then
			TextBox.Text = FilteredText
			SubmitButton.Visible = true
			
			FilteredPrompt = FilteredText
		else -- Message was all hashtags
			TextBox.Text = FilteredText
			FilteredPrompt = ""
		end
	else
		TextBox.Text = PlaceholderText
		FilteredPrompt = ""
	end
end)

SubmitButton.Activated:Connect(function()
	if (FilteredPrompt ~= nil or FilteredPrompt ~= "") and not IsAllHashtags(FilteredPrompt) then
		Remotes.Prompt:FireServer(FilteredPrompt)
		FilteredPrompt = ""
		TextBox.Text = PlaceholderText
		SubmitButton.Visible = false
		EndGui.Enabled = true
	end
end)