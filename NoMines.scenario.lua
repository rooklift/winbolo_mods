-- =========================================================================
-- No Mines — nobody can lay a mine, from the tank or with the builder.
--
-- How mines get laid in the stock game. A tank drops one of the mines it
-- carries on the square under it, and a builder sent out with a mine order
-- takes lgm_cost_mine (1) mines from the tank and lays one where he was
-- sent. The mod closes each road separately, because the engine asks a
-- script about the second and not about the first.
--
-- The tank. No policy is asked before a tank drops a mine, so the mod has
-- tanks carry none: tank_full_mines, the most a tank can hold, is 0. A tank
-- is then built with no mines whatever the game type, a base hands none
-- over, and a drop with nothing to drop does nothing. lgm_cost_mine goes to
-- 0 beside it only because the rules refuse a cost above what a tank can
-- hold.
--
-- The builder. With the cost at 0 a mine order would be free, so can_build
-- refuses every one. It is turned down the way an order on an impossible
-- square is.
--
-- The rules are a rules block and not on_setup writes, because the round's
-- opening tanks are built before on_setup runs and would keep the mines
-- they were built with.
--
-- What is left alone. Mines the map came with stay where they are and go
-- off as they always did, and so do any a scenario lays itself. Bases keep
-- and restock their own mines; no tank can take them.
--
-- kind = "mod", so it leaves the win condition alone and can be added to
-- any round, beside a scenario or on its own. bound = false, so it runs
-- over whatever map is loaded. A script above this one on the list that
-- sets tank_full_mines itself wins, and tanks would carry mines again, so
-- keep this one above it.
-- =========================================================================

scenario = {
  name = "No Mines",
  author = "Claude",
  description = "Nobody can lay mines: tanks carry none and builders " ..
                "refuse mine orders. Mines already on the map stay.",
  api = 1,
  updated = "2026-11-18T15:21Z",
  kind = "mod",
  bound = false,

  rules = {
    tank_full_mines = 0,
    lgm_cost_mine = 0,
  },

  callbacks = {
    can_build = "Refuses every builder order to lay a mine.",
  },
}

-- Asked before a builder order goes ahead. Returning nothing for the other
-- orders leaves them to the ordinary rule and to any other script.
function can_build(p, action, x, y, n)
  if action == "mine" then
    return false
  end
end
