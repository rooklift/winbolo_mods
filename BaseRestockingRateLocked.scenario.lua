-- =========================================================================
-- Base Restocking Rate Locked — the Base Restocking Rate mod fixed at 200%,
-- with nothing for the host to change.
--
-- How bases restock in the stock game. The server keeps one restock timer
-- for every player in the game, staggered so they run out at even spacing.
-- Each time one runs out, every base on the map that is short of full adds
-- one armour, one shell and one mine to its own stock, and that timer starts
-- again from base_regen_ticks (1000). More players means more timers, so
-- bases restock more often in a bigger game.
--
-- This mod halves that wait, to 500, so bases restock twice as often: the
-- Base Restocking Rate mod's default. There is no settings table, so the
-- lobby's details dialog has nothing to set, and every round with this mod
-- on restocks the same.
--
-- Only the bases' own stock is changed. How fast a base hands its stock to
-- a tank parked on it is a separate set of rules and is left alone, as are
-- the stock limits.
--
-- The wait is read from the rules as the round has them, not from the stock
-- number, so a map or a scenario that has already changed it is scaled from
-- its own value.
--
-- kind = "mod", so it leaves the win condition alone and can be added to
-- any round, beside a scenario or on its own. bound = false, so it runs
-- over whatever map is loaded.
-- =========================================================================

scenario = {
  name = "Base Restocking Rate",
  description = "Bases refill their own stock twice as often.",
  api = 1,
  updated = "2026-10-28T14:01Z",
  kind = "mod",
  bound = false,

  callbacks = {
    on_setup = "Halves the wait between base restocks.",
  },
}

-- The restocking rate, as a percentage of the stock game's.
local PERCENT = 200

-- Once, before the round's first tick and after every rules block has been
-- applied. Rules go back to the stock table at every round start, so this
-- scales the round's own value each time and never scales twice.
function on_setup()
  local wait = math.floor(game.rule("base_regen_ticks") * 100 / PERCENT + 0.5)
  if wait < 1 then
    wait = 1
  end
  game.set_rule("base_regen_ticks", wait)
end
