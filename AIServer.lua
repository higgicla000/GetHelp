local HttpService = game:GetService("HttpService")
local TextService  = game:GetService("TextService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = ReplicatedStorage.Remotes

local geminiApiKey = HttpService:GetSecret("geminiApiKey")
local url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash-latest:generateContent?key="
local urlWithKey = geminiApiKey:AddPrefix(url)

local MessageHistory = {}

local function GenerateText(prompt)
	local url = urlWithKey
	local data = {
		contents = {{
			parts = {{
				text = prompt
			}}
		}},
		
		systemInstruction = {
			parts = {{
				text = "You are a patient speaking to a therapist about an issue. Your responses must pass Roblox's strict filter, avoiding personal info, inappropriate topics, or filter bypass attempts. Keep replies under three sentences, stay in character if given a personality, and follow any provided mannerisms. Ignore filtered or erroneous messages, and do not repeat responses. Respond only in English, in plain text, without emojis or special characters. Use the provided message history (ordered oldest to newest) to progress the discussion, always replying to the therapist's most recent message."
			}}
		},
		
		generationConfig = {
			temperature = 2,
			maxOutputTokens = 60,
		},
	}

	local jsonData = HttpService:JSONEncode(data)

	-- Try-catch for error handling
	local success, response = pcall(function()
		return HttpService:PostAsync(url, jsonData, Enum.HttpContentType.ApplicationJson, false)
	end)

	if not success then
		return "Error making API request: " .. response
	end

	local result = HttpService:JSONDecode(response)

	-- Access the generated text
	if result.candidates and result.candidates[1] and result.candidates[1].content and result.candidates[1].content.parts and result.candidates[1].content.parts[1] then
		return tostring(result.candidates[1].content.parts[1].text)
	else
		return "Error generating response"
	end
end

local function GetFilterResult(Text, FromUserId)
	local FilterResult
	local Success, ErrorMessage = pcall(function()
		FilterResult = TextService:FilterStringAsync(Text, FromUserId):GetNonChatStringForBroadcastAsync()
	end)

	if Success then
		return FilterResult
	else
		return "Error generating TextFilterResult"
	end
end

function IsAllHashtags(String) -- Returns true if every character in a string is a hashtag
	for i = 1, #String do
		if String:sub(i, i) ~= "#" then
			return false
		end
	end
	return true
end

local function GeneratePersonality(Player)
	local Prompt = "Generate a very brief (3 short sentances or less), random personality. Include likes, dislikes, and a basic description of how they act. Also include unique ways of speaking. Only respond with a personality description, do not use any other text."
	local FilteredPersonalityDescription = GetFilterResult(GenerateText(Prompt), Player.UserId)

	if IsAllHashtags(FilteredPersonalityDescription) then
		FilteredPersonalityDescription = "Message has been filtered.\n"
	end

	return FilteredPersonalityDescription
end

Players.PlayerAdded:Connect(function(Player) -- Prompt & display a scenario when a player joins
	local Prompt = "Pretend you are a therapist's patient. Describe a random, unqiue, or funny problem you have to the therapist."
	local Personality = GeneratePersonality(Player)
	local PersonalityAndPrompt = "[Patient personality: " .. Personality .. "], " .. "[Therapist said: " .. Prompt .. "]"
	
	local FilteredResponse = GetFilterResult(GenerateText(PersonalityAndPrompt), Player.UserId)

	Remotes.DisplayPersonality:FireClient(Player, Personality)
	
	if IsAllHashtags(FilteredResponse) then
		FilteredResponse = "Message has been filtered.\n"
	end

	Remotes.Display:FireClient(Player, nil, FilteredResponse)
	
	-- Create the message history
	MessageHistory[Player.UserId] = PersonalityAndPrompt
	MessageHistory[Player.UserId] = MessageHistory[Player.UserId] .. ", [Patient said: " .. FilteredResponse .. "]"
	
	print(MessageHistory[Player.UserId])
end)

Remotes.Prompt.OnServerEvent:Connect(function(Player, FilteredPrompt)
	local FilteredResponse = GetFilterResult(GenerateText(MessageHistory[Player.UserId] .. ", [Therapist said: " .. FilteredPrompt .. "]"), Player.UserId) -- Prompt the AI with the prompt and the attached message history
	
	if IsAllHashtags(FilteredResponse) then
		FilteredResponse = "Message has been filtered.\n"
	end
	
	-- Add messages to message history
	MessageHistory[Player.UserId] = MessageHistory[Player.UserId] .. ", [Therapist said: " .. FilteredPrompt .. "]"
	MessageHistory[Player.UserId] = MessageHistory[Player.UserId] .. ", [Patient said: " .. FilteredResponse .. "]"

	-- Display for the player
	Remotes.Display:FireClient(Player, FilteredPrompt, FilteredResponse)

	print(MessageHistory[Player.UserId])
end)

local function GetReview(Player) -- Returns a rating, followed by a review on the therapist's performance
	local RatingPrompt = "Evaluate the therapist's performance on empathy, active listening, problem-solving, and professionalism. Rate them on a scale from 0 to 5 and only return a single number. Here is the chat history: " .. MessageHistory[Player.UserId]
	local FilteredRating = GetFilterResult(GenerateText(RatingPrompt), Player.UserId)
	
	FilteredRating = tonumber(FilteredRating)
	
	local ReviewPrompt = "Write a personalized review about the the therapist's performance. Use the provided rating to formulate your response. Here is the chat history: " .. MessageHistory[Player.UserId] .. " [Rating: " .. FilteredRating .. "/5]"
	local FilteredReview = GetFilterResult(GenerateText(ReviewPrompt), Player.UserId)
				
	if IsAllHashtags(FilteredReview) then
		FilteredReview = "Message has been filtered.\n"
	end
		
	return {FilteredRating, FilteredReview}
end

Remotes.GetReview.OnServerInvoke = GetReview