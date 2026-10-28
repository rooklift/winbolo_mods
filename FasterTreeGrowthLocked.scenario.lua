-- =========================================================================
-- Faster Tree Growth Locked — the Faster Tree Growth mod fixed at 2x, with
-- nothing for the host to change.
--
-- How trees grow in the stock game. Every frame the server picks one map
-- square at random, once for each tank in the game, and scores it by what is
-- around it: forest and grass count for it, road and buildings count against
-- it. The best square found so far is held, and a wait of tree_grow_ticks
-- (3000) starts again each time a better one turns up. When the wait runs
-- out with nothing better found, that square becomes forest and the search
-- starts over. Until the search finds a square worth growing on, the wait is
-- tree_grow_initial_ticks (30000) instead.
--
-- This mod halves both waits, to 1500 and 15000: the Faster Tree Growth
-- mod's default. There is no settings table, so the lobby's details dialog
-- has nothing to set, and every round with this mod on grows trees the same.
--
-- The waits are read from the rules as the round has them, not from the
-- stock numbers, so a map or a scenario that has already changed them is
-- halved from its own values. Soccer's "trees never grow" stays so.
--
-- kind = "mod", so it leaves the win condition alone and can be added to
-- any round, beside a scenario or on its own. bound = false, so it runs
-- over whatever map is loaded.
-- =========================================================================

scenario = {
  name = "Faster Tree Growth",
  description = "Trees grow back twice as fast.",
  api = 1,
  updated = "2026-10-28T14:01Z",
  kind = "mod",
  bound = false,

  callbacks = {
    on_setup = "Halves the tree growing waits.",
  },
}

-- How many times faster trees grow than in the stock game.
local MULTIPLIER = 2

-- The two rules that time tree growth.
local WAITS = { "tree_grow_ticks", "tree_grow_initial_ticks" }

-- Once, before the round's first tick and after every rules block has been
-- applied. Rules go back to the stock table at every round start, so this
-- divides the round's own values each time and never divides twice.
function on_setup()
  for _, name in ipairs(WAITS) do
    local wait = math.floor(game.rule(name) / MULTIPLIER + 0.5)
    if wait < 1 then
      wait = 1
    end
    game.set_rule(name, wait)
  end
end
