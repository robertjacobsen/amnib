amnibdb = {}

local version = "4.2"
local defaultText = "Invites for <INSTANCE> have started. For an invite, please whisper me '<KEYWORD>' without the quotes.";
local inviteKeywords = {
	["inv"] = true,
	["invite"] = true,
	["'invite' without the quotes"] = true
}

local function GreenPrint(green, text)
	if not text or not green then return end
	ChatFrame1:AddMessage(string.format("|cff33ff99%s|r: %s", green, text))
end

local function Print(text) 
	if not text then return end
	GreenPrint("amnib", text)
end

local function Error(text)
	if not text then return end
	ChatFrame1:AddMessage(string.format("|cffff0000amnib|r: %s", text))
end

local function Status()
	local invites = "enabled"
	if not amnibdb.accept then
		invites = "disabled"
	end
	local instanceText = ""
	if amnibdb.instance then 
		instanceText = string.format(" for %s", amnibdb.instance)
	end
	Print(string.format("Auto-invites are currently %s%s.", invites, instanceText))
end

local addon = CreateFrame"Frame"
addon:RegisterEvent"PLAYER_LOGIN"
addon:SetScript("OnEvent", function(self)
	if amnibdb.accept == nil then
		amnibdb.accept = false 
	end
	
	if not amnibdb.text then
		amnibdb.text = defaultText
	end

	if not amnibdb.keywords then
		amnibdb.keywords = inviteKeywords
	end

	if not amnibdb.default then
		amnibdb.default = "invite"
	end

	Status()
end)


local inviter = CreateFrame"Frame"
inviter:RegisterEvent"CHAT_MSG_WHISPER"
inviter:SetScript("OnEvent", function(self, event, what, who)
	if amnibdb.accept and amnibdb.keywords[what] then
		InviteUnit(who)
	end
end)

local function toggleAcceptInvites(value)
	if value == amnibdb.accept then return end
	amnibdb.accept = value
	Status()
end

local function broadcastInvite()
	SendChatMessage(amnibdb.text:gsub('\<INSTANCE\>', amnibdb.instance):gsub('\<KEYWORD\>', amnibdb.default), "GUILD")
	toggleAcceptInvites(true)
end

local function massInvite(units) 
	for u in units do
		InviteUnit(u)	
	end
end

SlashCmdList['INVITE_BROADCAST'] = function(args)
	local cmd, params = args:match'^(%a+)%s*(.*)'
	if cmd == 'start' then 
		if params and params ~= "" then 
			amnibdb.instance = params
			toggleAcceptInvites(true)
		end
		if amnibdb.instance then
			broadcastInvite()
		else
			Error"Need an instance specified to broadcast invites."
		end
	elseif cmd == 'stop' then
		amnibdb.instance = nil
		toggleAcceptInvites(false)
	elseif cmd == 'announce' then 
		if amnibdb.instance and amnibdb.accept then 
			broadcastInvite()
		else
			Error"You have no instance invites started. To start an invite, please use /ib start <instance>."
		end
	elseif cmd == 'text' then
		if params and params ~= "" then
			amnibdb.text = params
		end
		GreenPrint("Current invite message", amnibdb.text:format(amnibdb.instance))
	elseif cmd == 'resettext' then
		amnibdb.text = defaultText
		GreenPrint("Current invite message", amnibdb.text:format(amnibdb.instance))
	elseif cmd == "version" then 
		Print(string.format("Amnith's Invite Broadcaster version: %s", version))
	elseif cmd == 'massinv' or cmd == 'mi' then
		massInvite(params:gmatch'(%a+)')
	elseif cmd == 'keyword' then
		local subcmd, word = params:match'(%a+)%s*(.*)'
		if subcmd == 'add' and word and word ~= "" then 
			amnibdb.keywords[word] = true
		elseif subcmd == 'del' and word and word ~= "" then 
			if word == amnibdb.default then 
				Error"You cannot remove the default invite keyword."
			else
				amnibdb.keywords[word] = nil
			end
		elseif subcmd == 'default' and word and word ~= "" then
			if amnibdb.keywords[word] then 
				amnibdb.default = word
				Print(string.format("%s is now the default keyword", word))
			else
				Error(string.format("There is no such keyword '%s'.", word))
			end
		end

		local keywords = {}
		table.foreach(amnibdb.keywords, function(key, val) 
			if key == amnibdb.default then
				key = string.format("|cffff8000%s|r", key)
			end
			table.insert(keywords, key)
		end)
		GreenPrint("Current invite keywords", table.concat(keywords, ', '))
	elseif cmd == 'status' then
		Status()
	else
		GreenPrint("Amnith's Invite Broadcaster", "/ib, /amnib")
		GreenPrint("/ib start <instance>", "Starts the auto-invites and broadcasts to the guild if instance specified.")
		GreenPrint("/ib stop", "Stops the auto-invites.")
		GreenPrint("/ib status", "Shows the current status of the invite broadcaster.")
		GreenPrint("/ib announce", "Announces the previously started instance invite.")
		GreenPrint("/ib massinv <player1> [player2] [player3] [...]", "Performs a mass invite for all players passed.")
		GreenPrint("/ib text", "Shows current text to broadcast.")
		GreenPrint("/ib text <text>", "Allows to set the text for invites. <INSTANCE> specifies the instance, <KEYWORD> specifies the default invite keyword.")
		GreenPrint("/ib resettext", "Resets invite text to default.")
		GreenPrint("/ib keyword [<add|del|default> keyword]", "With no parameters, lists current auto-invite keywords. Otherwise adds or removes given keyword, or sets it to the standard for broadcasting.")
		GreenPrint("/ib version", "Shows you what version you are using.")
	end
end
SLASH_INVITE_BROADCAST1 = '/ib'
SLASH_INVITE_BROADCAST2 = '/amnib'
