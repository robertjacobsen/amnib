amnibdb = {}
local inviteKeywords = {
	["inv"] = true,
	["invite"] = true,
	["inviter"] = true,
	["'invite' without the quotes"] = true
}
local defaultText = "Invites for %s have started. For an invite, please whisper me 'invite' without the quotes.";

local function GreenPrint(green, text)
	if not text or not green then return end
	ChatFrame1:AddMessage(string.format("|cff33ff99%s|r: %s", green, text))
end

local function Print(text) 
	if not text then return end
	GreenPrint("amnib", text)
end

-- [[ Initialization of the SavedVariable ]]
local addon = CreateFrame"Frame"
addon:RegisterEvent"PLAYER_LOGIN"
addon:SetScript("OnEvent", function(self)
	if amnibdb.accept == nil then
		amnibdb.accept = true
	end
	
	local invites = "enabled"
	if not amnibdb.accept then
		invites = "disabled"
	end
	local instanceText = ""
	if amnibdb.instance then 
		instanceText = string.format(" for %s", amnibdb.instance)
	end
	Print(string.format("Auto-invites are currently %s%s.", invites, instanceText))

	if not amnibdb.text then
		amnibdb.text = defaultText
	end
end)

local version = "1.3"

local inviter = CreateFrame"Frame"
inviter:RegisterEvent"CHAT_MSG_WHISPER"
inviter:SetScript("OnEvent", function(self, event, what, who)
	if amnibdb.accept and inviteKeywords[what] then
		InviteUnit(who)
	end
end)

local function toggleAcceptInvites(value)
	if value == amnibdb.accept then return end
	amnibdb.accept = value
	if value then
		Print("Auto-invites enabled, type /ib stop to disable.")
	else
		Print("Auto-invites disabled, type /ib start <instance> to enable.")
	end
end

local function broadcastInvite()
	SendChatMessage(string.format(amnibdb.text, amnibdb.instance), "GUILD")
	toggleAcceptInvites(true)
end

local function massInvite(units) 
	for u in units do
		InviteUnit(u)	
	end
end

SlashCmdList['INVITE_BROADCAST'] = function(args)
	local cmd, params = string.match(args, '^(%a+)%s*(.*)')
	if cmd == 'start' then 
		if params and params ~= "" then 
			broadcastInvite(params)
			amnibdb.instance = params
		end
		toggleAcceptInvites(true)
	elseif cmd == 'stop' then
		amnibdb.instance = nil
		toggleAcceptInvites(false)
	elseif cmd == 'announce' then 
		if amnibdb.instance and amnibdb.accept then 
			broadcastInvite(amnibdb.instance)
		else
			Print("You have no instance invites started. To start an invite, please use /ib start <instance>.")
		end
	elseif cmd == 'text' then
		if params and params ~= "" then
			amnibdb.text = params
		end
		GreenPrint("Current invite message", string.format(amnibdb.text, amnibdb.instance))
	elseif cmd == 'resettext' then
		amnibdb.text = defaultText
		GreenPrint("Current invite message", string.format(amnibdb.text, amnibdb.instance))
	elseif cmd == "version" then 
		Print("Amnith's Invite Broadcaster version: "..version)
	elseif cmd == 'massinv' then
		local units = string.gmatch(params, '(%a+)')
		massInvite(units)
	else
		GreenPrint("Amnith's Invite Broadcaster", "/ib, /amnib")
		GreenPrint("/ib start <instance>", "Starts the auto-invites and broadcasts to the guild if instance specified.")
		GreenPrint("/ib stop", "Stops the auto-invites.")
		GreenPrint("/ib announce", "Announces the previously started instance invite.")
		GreenPrint("/ib version", "Shows you what version you are using.")
		GreenPrint("/ib text", "Shows current text to broadcast.")
		GreenPrint("/ib text <text>", "Allows to set the text for invites. %s specifies the instance.")
		GreenPrint("/ib resettext", "Resets invite text to default.")
	end
end
SLASH_INVITE_BROADCAST1 = '/ib'
SLASH_INVITE_BROADCAST2 = '/amnib'
