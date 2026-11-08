# Chat Lite

A light World of Warcraft chat cleanup addon for WoW Forever and retail (Midnight). Same messages, shorter and tidier.

## What it does

**Short lines** (each can be turned off):

Styled after the old Better Loot Message addon (original code, same idea).

| Before | After |
|---|---|
| You receive loot: [Linen Cloth]x3. | + [Linen Cloth] x3 |
| Kraxxas Ragathiel receives loot: [Copper Ore]. | + Kraxxas : [Copper Ore] |
| Kraxxas Ragathiel creates: [Linen Bag]. | + Kraxxas : [Linen Bag] (craft) |
| You loot 5 Gold, 20 Silver | + 5g 20s (coin icons) |
| You receive currency: [Valorstones] x10. | + [Valorstones] x10 |
| Hogger dies, you gain 120 experience. | Hogger : +120 xp |
| Your Stormwind reputation has increased by 250. | Stormwind + 250 |
| You are now Friendly with Stormwind. | Stormwind : Friendly |
| Your skill in Herbalism has increased to 152. | Herbalism = 152 |
| [Fine Leather Pants] has been added to your appearance collection. | + [Fine Leather Pants] (appearance) |
| You have selected Greed for: [Axe] | Greed: [Axe] |
| Greed Roll - 95 for [Axe] by Kylora Owlsong | Kylora: Greed 95 [Axe] |
| Shiro White has completed that quest. | Shiro: quest done |
| [Bob] has come online. | Bob online |

Player names in these lines are first names only (Forever names are "First Last"); switch it off in `/cl`. Normal chat is never shortened.

**Quiet rolls** hides everyone else's rolls and the "won" line, so a drop is just your choice and who got it.

**Look:** item and currency icons on loot lines (optionally on every item link in chat), no brackets around player names.

**Your rules:** write your own `find => replace` lines in the options panel. Plain text by default; links and colors are protected, so a rule only changes the words you see. Start a line with `~` for a Lua pattern.

```
General - Stormwind City => General
Trade - City => Trade
~%[(%d)%. [^%]]*%] => [%1]
```

The **Try it** box in the panel shows what any line turns into.

Open the options with `/cl`, `/chatlite`, or Game Menu > Options > AddOns > Chat Lite.

## Installing

WowUp: Get Addons → Install from URL → `https://github.com/SmolderingEgo/ChatLite`. Or download the zip from Releases into `Interface/AddOns`.

## Midnight limits

- During boss fights and Mythic+, Blizzard can lock chat text so addons can't change it. Those lines show as normal; Chat Lite never errors on them.
- If `/r` (reply) ever stops working in instances, turn off **No brackets** and **Use my rules** and `/reload`. Those two change every chat line, which is the part most likely to clash with Blizzard's protected code.

## Credits

Loot icons idea from Stanzilla's Chat Loot Icons (public domain). All code here is original.
