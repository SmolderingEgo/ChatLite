-- Chat Lite: built-in short lines.
-- Each rule reads one of Blizzard's own chat strings (GlobalStrings), so it works
-- in any client language. {1}, {2}... are the values from that string, in order.
-- A rule whose string doesn't exist on this client is skipped.
-- Order matters: the "multiple" versions come before the single ones.

local _, ns = ...

local function Money(s) return ns.Money(s) end

ns.RULE_DEFS = {
    -- Loot: you
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_SELF_MULTIPLE",            t = "+ {1} x{2}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_SELF",                     t = "+ {1}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_PUSHED_SELF_MULTIPLE",     t = "+ {1} x{2}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_PUSHED_SELF",              t = "+ {1}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE", t = "+ {1} x{2} (bonus roll)" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_BONUS_ROLL_SELF",          t = "+ {1} (bonus roll)" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_CREATED_SELF_MULTIPLE",    t = "Crafted {1} x{2}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_CREATED_SELF",             t = "Crafted {1}" },
    -- Loot: other people
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_MULTIPLE", who = {1},                 t = "{1}: + {2} x{3}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM", who = {1},                          t = "{1}: + {2}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_PUSHED_MULTIPLE", who = {1},          t = "{1}: + {2} x{3}" },
    { cat = "loot", event = "CHAT_MSG_LOOT", g = "LOOT_ITEM_PUSHED", who = {1},                   t = "{1}: + {2}" },

    -- Loot rolls. quiet = hidden when "Quiet rolls" is on.
    -- Specific versions first: "You won" before "%s won", auto-pass before pass.
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_NEED_SELF",        t = "Need: {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_GREED_SELF",       t = "Greed: {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_DISENCHANT_SELF",  t = "Disenchant: {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_TRANSMOG_SELF",    t = "Transmog: {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_PASSED_SELF_AUTO", t = "Pass (can't use): {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_PASSED_SELF",      t = "Pass: {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_NEED", who = {1},             t = "{1}: Need {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_GREED", who = {1},            t = "{1}: Greed {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_DISENCHANT", who = {1},       t = "{1}: Disenchant {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_TRANSMOG", who = {1},         t = "{1}: Transmog {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_PASSED_AUTO", who = {1},      t = "{1}: Pass {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_PASSED_AUTO_FEMALE", who = {1}, t = "{1}: Pass {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_PASSED", who = {1},           t = "{1}: Pass {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_ALL_PASSED",       t = "All passed: {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_ROLLED_NEED", who = {3},      t = "  {3}: Need {1} {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_ROLLED_GREED", who = {3},     t = "  {3}: Greed {1} {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_ROLLED_DE", who = {3},        t = "  {3}: Disenchant {1} {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_ROLLED_TRANSMOG", who = {3},  t = "  {3}: Transmog {1} {2}", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_YOU_WON_NO_SPAM_NEED",  t = "You won {2} (Need {1})" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_YOU_WON_NO_SPAM_GREED", t = "You won {2} (Greed {1})" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_YOU_WON_NO_SPAM_DE",    t = "You won {2} (Disenchant {1})" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_YOU_WON",          t = "You won {1}" },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_WON_NO_SPAM_NEED", who = {1},  t = "{1} won {3} (Need {2})", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_WON_NO_SPAM_GREED", who = {1}, t = "{1} won {3} (Greed {2})", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_WON_NO_SPAM_DE", who = {1},    t = "{1} won {3} (Disenchant {2})", quiet = true },
    { cat = "rolls", event = "CHAT_MSG_LOOT", g = "LOOT_ROLL_WON", who = {1},              t = "{1} won {2}", quiet = true },
    -- Roll starting: "[Loot]: [Item]". Must stay after every other roll rule, because
    -- its pattern matches any "[Loot]: ..." line; f returns false unless the rest is
    -- just an item link, so unknown lines are left alone.
    { cat = "rolls", event = "CHAT_MSG_LOOT", fmt = "|HlootHistory:%d|h[Loot]|h: %s", quiet = true,
      f = function(a)
          local item = a[1] or ""
          if item:match("^|c[^|]*|Hitem:.-|h|r$") or item:match("^|Hitem:.-|h$") then
              return "Roll: " .. item
          end
          return false
      end },

    -- Quest sharing replies
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_ALREADY_DONE_S", who = {1}, t = "{1}: quest done" },
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_ONQUEST_S", who = {1},      t = "{1}: has quest" },
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_ACCEPTED_S", who = {1},     t = "{1}: accepted" },
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_DECLINED_S", who = {1},     t = "{1}: declined" },
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_BUSY_S", who = {1},         t = "{1}: busy" },
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_LOG_FULL_S", who = {1},     t = "{1}: quest log full" },
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_INVALID_S", who = {1},      t = "{1}: can't take it" },
    { cat = "quests", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_PUSH_TOO_FAR_S", who = {1},      t = "{1}: too far" },

    -- Collections. fmt = English fallback if this client has no such GlobalString.
    { cat = "collect", event = "CHAT_MSG_SYSTEM", g = "ERR_LEARN_TRANSMOG_S",
      fmt = "%s has been added to your appearance collection.", t = "+ {1} (appearance)" },

    -- Money (guild-bank versions first: the plain ones would match them too)
    { cat = "money", event = "CHAT_MSG_MONEY", g = "YOU_LOOT_MONEY_GUILD",
      f = function(a) return "+ " .. Money(a[1]) .. " (" .. Money(a[2]) .. " to guild bank)" end },
    { cat = "money", event = "CHAT_MSG_MONEY", g = "YOU_LOOT_MONEY",
      f = function(a) return "+ " .. Money(a[1]) end },
    { cat = "money", event = "CHAT_MSG_MONEY", g = "LOOT_MONEY_SPLIT_GUILD",
      f = function(a) return "+ " .. Money(a[1]) .. " share (" .. Money(a[2]) .. " to guild bank)" end },
    { cat = "money", event = "CHAT_MSG_MONEY", g = "LOOT_MONEY_SPLIT",
      f = function(a) return "+ " .. Money(a[1]) .. " share" end },
    -- "You gained: 68s 89c" (quest/vendor money). Unsure which event sends it, so watch both.
    { cat = "money", event = "CHAT_MSG_SYSTEM", g = "ERR_QUEST_REWARD_MONEY_S", t = "+ {1}" },
    { cat = "money", event = "CHAT_MSG_SYSTEM", fmt = "You gained: %s", f = function(a) return "+ " .. Money(a[1]) end },
    { cat = "money", event = "CHAT_MSG_MONEY",  fmt = "You gained: %s", f = function(a) return "+ " .. Money(a[1]) end },

    -- Currency
    { cat = "currency", event = "CHAT_MSG_CURRENCY", g = "CURRENCY_GAINED_MULTIPLE_BONUS", t = "+ {1} x{2} (bonus)" },
    { cat = "currency", event = "CHAT_MSG_CURRENCY", g = "CURRENCY_GAINED_MULTIPLE",       t = "+ {1} x{2}" },
    { cat = "currency", event = "CHAT_MSG_CURRENCY", g = "CURRENCY_GAINED",                t = "+ {1}" },

    -- Experience
    { cat = "xp", event = "CHAT_MSG_COMBAT_XP_GAIN", g = "COMBATLOG_XPGAIN_EXHAUSTION1",          t = "+{2} XP ({1}, {3} {4})" },
    { cat = "xp", event = "CHAT_MSG_COMBAT_XP_GAIN", g = "COMBATLOG_XPGAIN_FIRSTPERSON",          t = "+{2} XP ({1})" },
    { cat = "xp", event = "CHAT_MSG_COMBAT_XP_GAIN", g = "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED",  t = "+{1} XP" },
    { cat = "xp", event = "CHAT_MSG_SYSTEM",         g = "ERR_QUEST_REWARD_EXP_I",                t = "+{1} XP (quest)" },

    -- Reputation
    { cat = "rep", event = "CHAT_MSG_COMBAT_FACTION_CHANGE", g = "FACTION_STANDING_INCREASED_ACH_BONUS", t = "+{2} {1} (+{3} bonus)" },
    { cat = "rep", event = "CHAT_MSG_COMBAT_FACTION_CHANGE", g = "FACTION_STANDING_INCREASED",           t = "+{2} {1}" },
    { cat = "rep", event = "CHAT_MSG_COMBAT_FACTION_CHANGE", g = "FACTION_STANDING_DECREASED",           t = "-{2} {1}" },
    { cat = "rep", event = "CHAT_MSG_COMBAT_FACTION_CHANGE", g = "FACTION_STANDING_INCREASED_GENERIC",   t = "+ {1}" },
    { cat = "rep", event = "CHAT_MSG_COMBAT_FACTION_CHANGE", g = "FACTION_STANDING_DECREASED_GENERIC",   t = "- {1}" },

    -- Skill-ups
    { cat = "skill", event = "CHAT_MSG_SKILL", g = "SKILL_RANK_UP", t = "{1} {2}" },

    -- Friends and guildmates online / offline
    { cat = "online", event = "CHAT_MSG_SYSTEM", g = "ERR_FRIEND_ONLINE_SS", who = {2}, t = "|Hplayer:{1}|h{2}|h online" },
    { cat = "online", event = "CHAT_MSG_SYSTEM", g = "ERR_FRIEND_OFFLINE_S", who = {1}, t = "{1} offline" },
}

-- Events where loot icons are added after the rewrite.
ns.ICON_EVENTS = { CHAT_MSG_LOOT = true, CHAT_MSG_CURRENCY = true }
