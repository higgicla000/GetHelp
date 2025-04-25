local TextService = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Remotes

local function GetFilterResult(Text, FromUserId)
	local FilterResult
	local Success, ErrorMessage = pcall(function()
		FilterResult = TextService:FilterStringAsync(Text, FromUserId)
	end)

	if Success then
		return FilterResult
	else
		warn("Error generating TextFilterResult:", ErrorMessage)
	end
end

-- Fired when client submits input from the TextBox
local function OnInputReceived(Player, Text)
	if Text ~= "" then
		local FilterResult = GetFilterResult(Text, Player.UserId)
		if FilterResult then
			local Success, FilteredText = pcall(function()
				return FilterResult:GetNonChatStringForBroadcastAsync()
			end)

			if Success then
				Remotes.UpdatePrompt:FireClient(Player, FilteredText)
			else
				Remotes.UpdatePrompt:FireClient(Player, nil)
			end
		else
			Remotes.UpdatePrompt:FireClient(Player, nil)
		end
	end
end

Remotes.FilterPrompt.OnServerEvent:Connect(OnInputReceived)