-- =========================================================================
-- Mac Bolo Parachute Speed — the one Mac Bolo rule that slows a builder's
-- parachute back to his tank, on its own, with nothing for the host to
-- change.
--
-- A builder who dies parachutes back in, flying straight at his tank. Mac
-- Bolo moves him every other tick by its trig table shifted down, so his
-- speed depends on his heading: 1.41 to 2.5 world units a tick, 1.92 on
-- average. WinBolo moves him lgm_helicopter_speed a tick, rounded on each
-- axis: 2.83 to 3.61 at the default 3. This mod sets 2, which is 1.41 to
-- 2.24, 2.09 on average. The rule is a whole number, so 2 is the nearest
-- it comes to Mac Bolo.
--
-- There is no settings table, so the lobby's details dialog has nothing to
-- set, and every round with this mod on plays the same.
--
-- kind = "mod", so it leaves the win condition alone and can be added to
-- any round, beside a scenario or on its own. bound = false, so it runs
-- over whatever map is loaded.
-- =========================================================================

scenario = {
  name = "Mac Bolo Parachute Speed",
  author = "claude",
  description = "Builders parachute back to their tanks at about Mac Bolo's speed, " ..
                "slower than WinBolo's.",
  api = 1,
  updated = "2026-11-02T22:24Z",
  kind = "mod",
  bound = false,

  rules = {
    -- Parachute speed: the nearest whole number to Mac Bolo's.
    lgm_helicopter_speed = 2,
  },
}
