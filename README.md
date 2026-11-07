# Chat Lite

A light World of Warcraft chat cleanup addon for WoW Forever and retail (Midnight). Same messages, shorter and tidier.

## What it does

**Short lines** (each can be turned off):

| Before | After |
|---|---|
| You receive loot: [Linen Cloth]x3. | + 🧵[Linen Cloth] x3 |
| Bob receives loot: [Copper Ore]. | Bob: + ⛏️[Copper Ore] |
| You loot 5 Gold, 20 Silver, 3 Copper | + 5🟡 20⚪ 3🟤 |
| You receive currency: [Valorstones] x10. | + [Valorstones] x10 |
| Hogger dies, you gain 120 experience. | +120 XP (Hogger) |
| Your Stormwind reputation has increased by 250. | +250 Stormwind |
| Your skill in Herbalism has increased to 152. | Herbalism 152 |
| [Bob] has come online. | Bob online |
| You have selected Greed for: [Axe] | Greed: [Axe] |
| Greed Roll - 95 for [Axe] by Kylora | Kylora: Greed 95 |
| Kylora won: [Axe] | Kylora won [Axe] |
| Shiro has completed that quest. | Shiro: quest done |
| [Fine Leather Pants] has been added to your appearance collection. | + [Fine Leather Pants] (appearance) |
| You gained: 68s 89c | + 68s 89c |

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
