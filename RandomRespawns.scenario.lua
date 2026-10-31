-- =========================================================================
-- Random Respawns — every spawn after a seat's first goes to a start
-- picked at random.
--
-- Starts. The engine tells on_choose_start which start the lobby put the
-- seat on: the start its player picked by hand, else one on the team's
-- side, else the engine's own spread of the field. That start is the
-- seat's for its first tank of the round only, so a later spawn is told
-- nothing. The mod hands the lobby's start straight back, so the round's
-- opening tanks go where the lobby put them. Every spawn the lobby has no
-- start for goes to one of the map's starts, each as likely as any other,
-- whatever is near it. The engine then moves the tank off the start to
-- the nearest clear square, as it does with any start.
--
-- A seat that joins once the round is running has no lobby start, so its
-- first tank is placed at random too.
--
-- kind = "mod", so it leaves the win condition alone and can be added to
-- any round, beside a scenario or on its own. bound = false, so it runs
-- over whatever map is loaded.
-- =========================================================================

scenario = {
  name = "Random Respawns",
  author = "Claude",
  description = "Respawns go to a random start. Opening tanks keep the " ..
                "start the lobby gave them.",
  api = 1,
  updated = "2026-10-31T17:40Z",
  kind = "mod",
  bound = false,

  callbacks = {
    on_choose_start = "Keeps the lobby's start for an opening tank; else picks one of the map's starts at random.",
  },
}

-- lobby is the start the lobby chose for this tank, counted as game.start
-- counts, or nil when it chose none. The lobby chooses for each seat's
-- first tank of the round and for no spawn after it.
function on_choose_start(p, lobby)
  if lobby ~= nil then
    return lobby
  end

  -- game.start answers nil for a slot with no live start.
  local live = {}
  for n = 1, game.num_starts() do
    if game.start(n) then
      live[#live + 1] = n
    end
  end

  -- With no live start, the engine picks.
  if #live == 0 then
    return nil
  end
  return live[math.random(#live)]
end
