# makefun-roblox-brainrot

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/kanashit12/makefun-roblox-brainrot/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/kanashit12/makefun-roblox-brainrot/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Brainrot Bazaar — a 3D Roblox brainrot game for make.fun's "Make the best AI Roblox brainrot game" bounty ($1,000 in USDC).

## What it is

A sunny meme bazaar island where you collect absurd, original brainrot characters that earn coins every second. Brainrots ride a central conveyor belt — click one to buy it and it walks to your market stall. Climb six rarities (Common → Brainrot God), hunt Golden / Diamond / Rainbow / Lava mutations, steal rivals' brainrots by carrying them home (they can slap you to knock it loose), survive the Tsunami of Nonsense that sweeps the map every 4 minutes, and rebirth for a permanent income multiplier. 24 original characters, 8 stalls, DataStore saves.

## Run it

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

`main.ts` (Node 22, standard library only) copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to the output directory and writes `dossier.json` with `vendor/makefun-roblox.ts` (the kit's copy, unchanged). Two runs produce byte-identical output.

Rebuild the place from source with Rojo 7.7:

```sh
rojo build default.project.json --output game.rbxl
```

## Status — what is done, what is not

Done on this Linux VM: the full game (13 Luau scripts, all syntax-checked with the Luau 0.747 compiler), the 3D world in `default.project.json` (153 instances: 8 stalls, conveyor, spawn, fountain, palms, lamps), a real binary `game.rbxl` built by Rojo 7.7.0, and a deterministic `main.ts` handoff verified by two identical runs.

NOT done — needs a Windows or macOS machine with Roblox Studio and a Roblox account that can already publish:

- **Screenshots**: `screenshots/` holds labelled placeholder diagrams, NOT Studio captures. Replace all three with real captures of the game running in Studio (16:9, each ≤ 256 KiB).
- **PLAY.json**: still the starter's zeros. Fill it with the published place after publishing (`place_id`, `universe_id`).
- **Publish**: open the Rojo project in Studio, publish as a Public experience, upload its icon + thumbnail (the first thumbnail must match one screenshot).
- **Recordings**: this build was made in an agent the kit's `record` command does not record, so there are no sealed recordings. Rebuilding in a recorded harness (Claude Code, Codex, Gemini CLI, Superbot, …) with `record` running is required for a submittable entry.

## Layout

- `main.ts` — the entrypoint the grader runs (Node 22, stdlib only).
- `default.project.json` — the Rojo project: the 3D world + script mounts.
- `game.rbxl` — the place, built by Rojo 7.7.0 from `src/` + `default.project.json`.
- `src/shared/` — `Defs.luau` (24 characters, rarities, mutations, tuning) and `ModelFactory.luau` (builds the character models, no external assets).
- `src/server/` — `init.server.luau`, `Game.luau`, `Conveyor.luau`, `Economy.luau`, `Steal.luau`, `Wave.luau`, `Save.luau`, `StallLayout.luau`, `Walker.luau`.
- `src/client/` — `Game.client.luau`, `HUD.luau` (ScreenGui over the 3D world).
- `screenshots/` — placeholder diagrams (see above); `PLAY.json` — publish link placeholder.

---

Entered on [make.fun](https://make.fun/?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards
