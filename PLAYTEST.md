# PLAYTEST

## Feel goals
- Running feels quick, not slow
- Floating down under the napkin feels calm and easy to steer
- Aiming feels steady
- Throwing feels fun: a clear arc and a juicy splat

## Changes
| Date | Version | Who | What they said | Change | Stats | Keep? |
|---|---|---|---|---|---|---|
| 2026-11-25 | 0.0.1 | Kid | "feels less slow" | `run_speed` 6 → 7 | — | keep |
| 2026-11-25 | 0.0.1 | Kid | "too hard from far away, they snipe me" | `bot_accuracy_far` 0.3 → 0.2 | — | keep |
| 2026-11-25 | 0.0.1 | Kid | "the start was kinda boring" | `storm_wait` 45 → 35 | — | keep |
| 2026-11-25 | 0.0.1 | Kid | "farming was slow" | `pickaxe_swing_every` 0.4 → 0.3 | — | keep |
| 2026-11-25 | 0.0.1 | Kid | "ok" (sounds fine) | new `sfx_volume` 0.7, `storm_hum_volume` 0.6 | — | keep |
| 2026-11-25 | 0.0.1 | Kid | full match after G6 (sound + touch): "ok", no fix named | — | — | keep |
| 2026-11-26 | 0.3.0 | Maintainer | "no guns, a kid-friendly food fight" | Renamed: `pickaxe_swing_every` → `spoon_swing_every` (0.3 kept); `bot_accuracy_*` → `bot_miss_far` 3 m / `bot_miss_near` 0.6 m (tomatoes now really fly, so bots miss by meters, not by chance); new `throw_*`, `tomato_*`, `towel_*` | — | test |
| 2026-11-26 | 0.3.0 | Maintainer | "a lunchroom food fight, all small kindergartners" | Start on a table, no sky drop (`drop_height` removed); new `napkin_open_speed` 7.5; `glide_fall` 8 → 3; `crumbs_*` → `trays_*`, `towel_*` → `napkin_*` | — | test |
