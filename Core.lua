-- Chat Lite: core.
-- Two places where chat gets changed:
--  1. Message filters (per event): built-in short lines + loot icons.
--  2. A wrapper on each chat window's AddMessage: your own rules, bracket-free
--     names, and icons on every item link. Only installed if one of those is on.
-- Midnight: chat text can arrive as a "secret value" during encounters and M+.
-- Secret text is never touched, so those lines just show as Blizzard wrote them.

local ADDON, ns = ...

ns.defaults = {
    -- built-in short lines
    loot = true, money = true, currency = true, xp = true, rep = true, skill = true, online = true,
    rolls = true, quests = true, rollsQuiet = false, collect = true, firstNames = true,
    -- look
    lootIcons = true, iconsEverywhere = false, iconSize = 0, names = true,
    -- your rules
    customOn = true,
    customText = [==[
# Your own find => replace rules. One per line, run top to bottom.
# Plain text by default. Links and colors are protected, so a rule only
# changes the words you see and never breaks a link.
# Leave the right side empty to delete the text.
# Start a line with ~ to use a Lua pattern (%1, %2 in the replacement).
# Remove the # in front of an example to turn it on.
#
# General - Stormwind City => General
# Trade - City => Trade
# ~%[(%d)%. [^%]]*%] => [%1]
]==],
}

local db
local TAG = "|cff33ff99Chat Lite|r: "

---------------------------------------------------------------- helpers

local function IsSecret(v)
    return issecretvalue ~= nil and issecretvalue(v)
end
ns.IsSecret = IsSecret

local function Esc(s)
    return (s:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?]", "%%%0"))
end

-- Turn a Blizzard format string ("You receive loot: %s.") into a Lua pattern.
-- Returns the pattern and, for each capture, which format argument it is
-- (handles reordered "%2$s" strings in other languages).
local function Compile(fmt)
    local parts, order, argn, i = { "^" }, {}, 0, 1
    while i <= #fmt do
        local c = fmt:sub(i, i)
        if c == "%" then
            local s, e, pos, _, conv = fmt:find("^%%(%d*%$?)([%.%d]*)([sdfi])", i)
            if s then
                argn = argn + 1
                local idx = argn
                if pos:sub(-1) == "$" then idx = tonumber(pos:sub(1, -2)) end
                order[#order + 1] = idx
                if conv == "s" then
                    parts[#parts + 1] = "(.-)"
                elseif conv == "f" then
                    parts[#parts + 1] = "(%-?[%d%.]+)"
                else
                    parts[#parts + 1] = "(%-?%d+)"
                end
                i = e + 1
            else
                parts[#parts + 1] = "%%"
                i = i + ((fmt:sub(i + 1, i + 1) == "%") and 2 or 1)
            end
        else
            parts[#parts + 1] = Esc(c)
            i = i + 1
        end
    end
    parts[#parts + 1] = "$"
    return table.concat(parts), order
end

---------------------------------------------------------------- money

local function CoinString(copper)
    local f = (C_CurrencyInfo and C_CurrencyInfo.GetCoinTextureString) or GetCoinTextureString
    if f then
        local ok, s = pcall(f, copper)
        if ok and s then return s end
    end
    if GetMoneyString then
        local ok, s = pcall(GetMoneyString, copper, true)
        if ok and s then return s end
    end
    return nil
end

local MONEY_PARTS
local function MoneyToCopper(s)
    if not MONEY_PARTS then
        MONEY_PARTS = {}
        for _, spec in ipairs({ { "GOLD_AMOUNT", 10000 }, { "SILVER_AMOUNT", 100 }, { "COPPER_AMOUNT", 1 } }) do
            local fmt = _G[spec[1]]
            if type(fmt) == "string" then
                local p = Esc(fmt):gsub("%%%%d", "([%%d,]+)")
                MONEY_PARTS[#MONEY_PARTS + 1] = { p, spec[2] }
            end
        end
    end
    local total, found = 0, false
    for _, part in ipairs(MONEY_PARTS) do
        local n = s:match(part[1])
        if n then
            total = total + (tonumber((n:gsub(",", ""))) or 0) * part[2]
            found = true
        end
    end
    return found and total or nil
end

function ns.Money(s)
    if type(s) ~= "string" then return "" end
    local copper = MoneyToCopper(s)
    return (copper and CoinString(copper)) or s
end

---------------------------------------------------------------- icons

local function IconTag(icon)
    if not icon then return "" end
    return ("|T%s:%d|t"):format(tostring(icon), db.iconSize or 0)
end

local function ItemIcon(id)
    id = tonumber(id)
    if id and C_Item and C_Item.GetItemIconByID then return C_Item.GetItemIconByID(id) end
end

local function CurrencyIcon(id)
    id = tonumber(id)
    if id and C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo then
        local info = C_CurrencyInfo.GetCurrencyInfo(id)
        return info and info.iconFileID
    end
end

-- Put an icon in front of each link of this type (before its color code),
-- unless there's already an icon right there.
local function Decorate(msg, linkType, getIcon)
    local pattern = "|H" .. linkType .. ":(%d+)"
    local out, pos = {}, 1
    while true do
        local s, e, id = msg:find(pattern, pos)
        if not s then break end
        local insertAt = s
        local before = msg:sub(1, s - 1)
        local colorStart = before:find("|c%x%x%x%x%x%x%x%x$") or before:find("|cn[^|:]*:$")
        if colorStart and colorStart >= pos then insertAt = colorStart end
        local already = msg:sub(math.max(1, insertAt - 2), insertAt - 1) == "|t"
        out[#out + 1] = msg:sub(pos, insertAt - 1)
        if not already then out[#out + 1] = IconTag(getIcon(id)) end
        out[#out + 1] = msg:sub(insertAt, e)
        pos = e + 1
    end
    if pos == 1 then return msg end
    out[#out + 1] = msg:sub(pos)
    return table.concat(out)
end

local function AddIcons(msg)
    return Decorate(Decorate(msg, "item", ItemIcon), "currency", CurrencyIcon)
end

---------------------------------------------------------------- built-in rules

local byEvent = {}

local function CompileRules()
    wipe(byEvent)
    for _, def in ipairs(ns.RULE_DEFS) do
        local fmt = def.g and _G[def.g]
        if type(fmt) ~= "string" then fmt = def.fmt end
        if type(fmt) == "string" then
            local pat, order = Compile(fmt)
            -- Roll strings can start with a clickable "|HlootHistory:%d|h[Loot]|h: "
            -- tag. Its %d is a roll ID, not something we show, so skip it.
            local shift = fmt:find("^|HlootHistory:%%d") and 1 or 0
            byEvent[def.event] = byEvent[def.event] or {}
            table.insert(byEvent[def.event], { cat = def.cat, pat = pat, order = order, shift = shift,
                t = def.t, f = def.f, quiet = def.quiet, who = def.who })
        end
    end
end

local function Fill(rule, caps)
    local args = {}
    for k, v in ipairs(caps) do
        local idx = (rule.order[k] or k) - (rule.shift or 0)
        if idx >= 1 then args[idx] = v end
    end
    -- "First names only": shorten the player-name values of this rule
    -- (Forever names are "First Last"). Never touches links or normal chat.
    if db.firstNames and rule.who then
        for _, i in ipairs(rule.who) do
            local name = args[i]
            if type(name) == "string" and not name:find("|", 1, true) then
                args[i] = name:match("^(%S+)%s") or name
            end
        end
    end
    if rule.f then return rule.f(args) end
    return (rule.t:gsub("{(%d)}", function(n) return args[tonumber(n)] or "" end))
end

-- Returns the new text, or nil to hide the line.
local function Rewrite(event, msg)
    local out = msg
    local rules = byEvent[event]
    if rules then
        -- Some clients put a "[Loot]: " style tag in front; try without it too.
        local body = msg:match("^%[[^%]|]+%]:%s*(.+)$")
        for _, rule in ipairs(rules) do
            if db[rule.cat] then
                local caps = { msg:match(rule.pat) }
                if not caps[1] and body then caps = { body:match(rule.pat) } end
                if caps[1] then
                    local res = Fill(rule, caps)
                    if res ~= false then
                        if rule.quiet and db.rollsQuiet then return nil end
                        out = res
                        break
                    end
                end
            end
        end
    end
    if db.lootIcons and ns.ICON_EVENTS[event] then out = AddIcons(out) end
    return out
end

local function Filter(_, event, msg, ...)
    if type(msg) ~= "string" or IsSecret(msg) then return false end
    local ok, out = pcall(Rewrite, event, msg)
    if not ok then return false end
    if out == nil then return true end
    if out ~= msg then return false, out, ... end
    return false
end

---------------------------------------------------------------- your rules

local customRules, customErrors = {}, {}

function ns.ParseRules(text)
    wipe(customRules); wipe(customErrors)
    local n = 0
    for line in ((text or "") .. "\n"):gmatch("([^\n]*)\n") do
        n = n + 1
        line = line:gsub("\r", ""):match("^%s*(.-)%s*$")
        if line ~= "" and line:sub(1, 1) ~= "#" then
            local find, repl = line:match("^(.-)%s*=>%s*(.*)$")
            if not find or find == "" then
                customErrors[#customErrors + 1] = n
            else
                local isPat = find:sub(1, 1) == "~"
                local pat = isPat and find:sub(2) or Esc(find)
                local rep = isPat and repl or repl:gsub("%%", "%%%%")
                if pat ~= "" and pcall(string.gsub, "test line [1. test]", pat, rep) then
                    customRules[#customRules + 1] = { pat = pat, rep = rep }
                else
                    customErrors[#customErrors + 1] = n
                end
            end
        end
    end
    return #customRules, customErrors
end

-- Hide link codes, colors and textures behind placeholders, run the rules on
-- what's left (the words you see), then put the codes back.
local PROTECT = { "|H[^|]*|h", "|h", "|cn[^|:]*:", "|c%x%x%x%x%x%x%x%x", "|r", "|T[^|]*|t", "|A[^|]*|a", "|K[^|]*|k", "|n" }

local function ApplyCustom(text)
    local saved = {}
    local function keep(tok)
        saved[#saved + 1] = tok
        return "\001" .. ("\002"):rep(#saved) .. "\001"
    end
    for _, p in ipairs(PROTECT) do text = text:gsub(p, keep) end
    for _, r in ipairs(customRules) do
        local ok, out = pcall(string.gsub, text, r.pat, r.rep)
        if ok then text = out end
    end
    text = text:gsub("\001(\002+)\001", function(s) return saved[#s] or "" end)
    return (text:gsub("[\001\002]", ""))
end

---------------------------------------------------------------- whole-line processing

local function StripBrackets(text)
    return (text:gsub("(|HB?N?player:[^|]*|h)%[(.-)%]|h", "%1%2|h"))
end

function ns.Process(text)
    if db.names then text = StripBrackets(text) end
    if db.customOn and #customRules > 0 then text = ApplyCustom(text) end
    if db.iconsEverywhere then text = AddIcons(text) end
    return text
end

function ns.NeedsHook()
    return db and (db.names or db.iconsEverywhere or (db.customOn and #customRules > 0))
end

local hooked = {}
local function HookFrame(f)
    if not f or hooked[f] or f == _G.ChatFrame2 or f == _G.COMBATLOG then return end
    hooked[f] = true
    local orig = f.AddMessage
    f.AddMessage = function(self, text, ...)
        if type(text) == "string" and not IsSecret(text) and ns.NeedsHook() then
            local ok, out = pcall(ns.Process, text)
            if ok and type(out) == "string" then text = out end
        end
        return orig(self, text, ...)
    end
end

function ns.EnsureHooks()
    if not ns.NeedsHook() then return end
    for i = 1, (NUM_CHAT_WINDOWS or 10) do HookFrame(_G["ChatFrame" .. i]) end
    if CHAT_FRAMES then
        for _, name in ipairs(CHAT_FRAMES) do HookFrame(_G[name]) end
    end
end

---------------------------------------------------------------- startup

local AddFilter = (ChatFrameUtil and ChatFrameUtil.AddMessageEventFilter) or ChatFrame_AddMessageEventFilter

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, name)
    if name ~= ADDON then return end
    self:UnregisterEvent("ADDON_LOADED")

    ChatLiteDB = ChatLiteDB or {}
    for k, v in pairs(ns.defaults) do
        if ChatLiteDB[k] == nil then ChatLiteDB[k] = v end
    end
    db = ChatLiteDB
    ns.db = db

    CompileRules()
    ns.ParseRules(db.customText)

    if AddFilter then
        local events = {}
        for event in pairs(byEvent) do events[event] = true end
        for event in pairs(ns.ICON_EVENTS) do events[event] = true end
        -- securecall keeps Blizzard's filter table from being marked as addon-written
        for event in pairs(events) do securecall(AddFilter, event, Filter) end
    else
        print(TAG .. "no chat filter API found on this client; built-in short lines are off.")
    end

    ns.EnsureHooks()
    if FCF_OpenTemporaryWindow then
        hooksecurefunc("FCF_OpenTemporaryWindow", function() ns.EnsureHooks() end)
    end

    if ns.BuildOptions then ns.BuildOptions() end
end)

SLASH_CHATLITE1 = "/chatlite"
SLASH_CHATLITE2 = "/cl"
SlashCmdList.CHATLITE = function()
    if ns.categoryID and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(ns.categoryID)
    else
        print(TAG .. "options panel not available.")
    end
end
