amnibdb = {}
local acceptInvites = true
local currentInstance = nil

local function Print(pre, green, text)
	if green == "" then green = "amnib" end
	ChatFrame1:AddMessage(string.format("%s|cff33ff99%s|r: %s", pre, green, text))
end

-- [[ Initialization of the SavedVariable ]]
local addon = CreateFrame"Frame"
addon:RegisterEvent"PLAYER_LOGIN"
addon:SetScript("OnEvent", function(self)
	if amnibdb.accept == nil then
		amnibdb.accept = true
	end
	
	if amnibdb.instance then 
		currentInstance = amnibdb.instance
	end

	acceptInvites = amnibdb.accept
	local invites = "enabled"
	if not amnibdb.accept then
		invites = "disabled"
	end
	local instanceText = ""
	if currentInstance then 
		instanceText = string.format(" for %s", currentInstance)
	end
	Print("", "", string.format("Auto-invites are currently %s%s.", invites, instanceText))
end)

local version = "1.2.2"

local inviter = CreateFrame"Frame"
inviter:RegisterEvent"CHAT_MSG_WHISPER"
inviter:SetScript("OnEvent", function(self)
	if arg1 == "invite" and acceptInvites then
		InviteUnit(arg2)
	end
end)



local function showHelp(invites)
	Print("", "", "/ib, /amnib")
	Print("- ", "/ib start <instance>",  "Starts the auto-invites and broadcasts to the guild if instance specified.")
	Print("- ", "/ib stop", "Stops the auto-invites.")
	Print("- ", "/ib announce", "Announces the previously started instance invite.")
	Print("- ", "/ib version", "Shows you what version you are using.")
end

local function toggleAcceptInvites(value)
	if value == acceptInvites then return end
	acceptInvites = value
	amnibdb.accept = value
	if value then 
		Print("", "", "Auto-invites enabled, type /ib stop to disable.")
	else
		Print("", "", "Auto-invites disabled, type /ib start to enable.")
	end
end

local function broadcastInvite(instance)
	if not instance then return end

	SendChatMessage(string.format("Invites for %s have started. For an invite, please whisper me 'invite' without the quotes.", instance), "GUILD")
	toggleAcceptInvites(true)
end

SlashCmdList['INVITE_BROADCAST'] = function(arg1)
	if string.sub(arg1, 0, 5) == "start" then 
		local where = string.sub(arg1, 7)
		if where ~= "" then 
			broadcastInvite(where)
			currentInstance = where
			amnibdb.instance = where
		end
		toggleAcceptInvites(true)
	elseif arg1 == "stop" then
		toggleAcceptInvites(false)
		currentInstance = nil
		amnibdb.instance = nil
	elseif arg1 == "announce" then 
		if currentInstance and acceptInvites then 
			broadcastInvite(currentInstance)
		else
			Print("", "", "You have no instance invites started. To start an invite, please use /ib start <instance>.")
		end
	elseif arg1 == "version" then 
		Print("", "", "Amnith's Invite Broadcaster version: "..version)
	else
		showHelp()
	end
end
SLASH_INVITE_BROADCAST1 = '/ib'
SLASH_INVITE_BROADCAST2 = '/amnib'
