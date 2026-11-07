-- Chat Lite: options panel (Game Menu > Options > AddOns > Chat Lite, or /cl).

local _, ns = ...

local function Header(parent, text, y)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", 16, y)
    fs:SetText(text)
    return fs
end

local checks = {}
local function Check(parent, label, key, x, y, onChange)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(26, 26)
    cb:SetPoint("TOPLEFT", x, y)
    local fs = cb:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    fs:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    fs:SetText(label)
    cb:SetScript("OnClick", function(self)
        ns.db[key] = self:GetChecked() and true or false
        if onChange then onChange() end
    end)
    cb.key = key
    checks[#checks + 1] = cb
    return cb
end

function ns.BuildOptions()
    if not (Settings and Settings.RegisterCanvasLayoutCategory) then return end
    local db = ns.db

    local panel = CreateFrame("Frame")
    panel:Hide()

    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Chat Lite")
    local sub = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
    sub:SetText("Changes apply to new chat lines. Lines during boss fights and M+ may show unchanged (Blizzard restriction).")

    local L, R = 16, 300

    Header(panel, "Short lines", -64)
    Check(panel, "Loot", "loot", L, -84)
    Check(panel, "Money", "money", L, -110)
    Check(panel, "Currency", "currency", L, -136)
    Check(panel, "Experience", "xp", L, -162)
    Check(panel, "Reputation", "rep", R, -84)
    Check(panel, "Skill-ups", "skill", R, -110)
    Check(panel, "Friends online / offline", "online", R, -136)
    Check(panel, "Loot rolls", "rolls", R, -162)
    Check(panel, "Quest sharing replies", "quests", L, -188)
    Check(panel, "Appearances collected", "collect", L, -214)
    Check(panel, "First names only (in these lines)", "firstNames", R, -214)
    Check(panel, "Quiet rolls (hide other people's rolls)", "rollsQuiet", R, -188)

    Header(panel, "Look", -250)
    Check(panel, "Item icons on loot lines", "lootIcons", L, -270)
    Check(panel, "Icons on every item link", "iconsEverywhere", R, -270, ns.EnsureHooks)
    Check(panel, "No brackets around names", "names", L, -296, ns.EnsureHooks)

    local sizeLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    sizeLabel:SetPoint("TOPLEFT", R + 4, -302)
    sizeLabel:SetText("Icon size (0 = chat font)")
    local size = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    size:SetSize(36, 20)
    size:SetPoint("LEFT", sizeLabel, "RIGHT", 10, 0)
    size:SetAutoFocus(false)
    size:SetNumeric(true)
    size:SetMaxLetters(2)
    local function SaveSize(self)
        db.iconSize = math.min(64, tonumber(self:GetText()) or 0)
        self:SetText(tostring(db.iconSize))
        self:ClearFocus()
    end
    size:SetScript("OnEnterPressed", SaveSize)
    size:SetScript("OnEditFocusLost", SaveSize)

    Header(panel, "Your rules   (find => replace, one per line)", -336)
    Check(panel, "Use my rules", "customOn", L, -356, ns.EnsureHooks)

    local box = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    box:SetPoint("TOPLEFT", 18, -386)
    box:SetPoint("RIGHT", panel, "RIGHT", -24, 0)
    box:SetHeight(120)
    box:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12, insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    box:SetBackdropColor(0, 0, 0, 0.6)
    box:EnableMouse(true)

    local sf = CreateFrame("ScrollFrame", nil, box, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", 8, -8)
    sf:SetPoint("BOTTOMRIGHT", -28, 8)

    local eb = CreateFrame("EditBox", nil, sf)
    eb:SetMultiLine(true)
    eb:SetAutoFocus(false)
    eb:SetFontObject(ChatFontNormal)
    eb:SetWidth(400)
    eb:SetScript("OnEscapePressed", eb.ClearFocus)
    sf:SetScrollChild(eb)
    sf:SetScript("OnSizeChanged", function(_, w) eb:SetWidth(w) end)
    box:SetScript("OnMouseDown", function() eb:SetFocus() end)

    local status = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")

    local save = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    save:SetSize(110, 22)
    save:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -6)
    save:SetText("Save rules")
    status:SetPoint("LEFT", save, "RIGHT", 10, 0)

    local function ShowStatus(count, errors)
        local s = ("%d rule%s active."):format(count, count == 1 and "" or "s")
        if #errors > 0 then
            s = s .. "  |cffff5555Couldn't read line " .. table.concat(errors, ", ") .. ".|r"
        end
        status:SetText(s)
    end

    save:SetScript("OnClick", function()
        db.customText = eb:GetText()
        ShowStatus(ns.ParseRules(db.customText))
        ns.EnsureHooks()
        eb:ClearFocus()
    end)

    Header(panel, "Try it   (type a line, see what Chat Lite turns it into)", -552)
    local test = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    test:SetPoint("TOPLEFT", 22, -572)
    test:SetPoint("RIGHT", panel, "RIGHT", -24, 0)
    test:SetHeight(20)
    test:SetAutoFocus(false)
    local result = panel:CreateFontString(nil, "ARTWORK", "ChatFontNormal")
    result:SetPoint("TOPLEFT", test, "BOTTOMLEFT", -4, -8)
    result:SetPoint("RIGHT", panel, "RIGHT", -24, 0)
    result:SetJustifyH("LEFT")
    test:SetScript("OnTextChanged", function(self)
        local ok, out = pcall(ns.Process, self:GetText())
        result:SetText(ok and out or "")
    end)
    test:SetScript("OnEnterPressed", test.ClearFocus)
    test:SetScript("OnEscapePressed", test.ClearFocus)

    panel:SetScript("OnShow", function()
        for _, cb in ipairs(checks) do cb:SetChecked(db[cb.key]) end
        size:SetText(tostring(db.iconSize or 0))
        eb:SetText(db.customText or "")
        ShowStatus(ns.ParseRules(db.customText))
    end)

    local category = Settings.RegisterCanvasLayoutCategory(panel, "Chat Lite")
    Settings.RegisterAddOnCategory(category)
    ns.categoryID = category:GetID()
end
