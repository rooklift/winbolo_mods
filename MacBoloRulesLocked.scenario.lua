-- =========================================================================
-- Mac Bolo Rules Locked — the Mac Bolo Rules mod with every part on, at its
-- default numbers, and nothing for the host to change.
--
-- It plays what the Mac Bolo Rules mod plays when the host leaves every
-- setting alone: shell pushback (28 at full armour, 32 more at zero, shift
-- 2), the pillbox shell cap at twelve, the Mac Bolo tank collision boxes,
-- Mac Bolo pillbox aiming and massage, the base defence circle of radius
-- 7, tank hits that do not set off mines, and the Mac Bolo start pick for
-- spawns, with the opening tanks on the starts the lobby chose. The Mac
-- Bolo Rules mod says what each part does.
--
-- There is no settings table, so the lobby's details dialog has nothing to
-- set, and every round with this mod on plays the same rules. A host who
-- wants to change a part plays the Mac Bolo Rules mod instead.
--
-- kind = "mod", so it leaves the win condition alone and can be added to
-- any round, beside a scenario or on its own. bound = false, so it runs
-- over whatever map is loaded.
-- =========================================================================

scenario = {
  name = "Mac Bolo Rules",
  description = "Plays the Mac Bolo shell pushback, pillbox shell cap, " ..
                "tank clearance, pillbox massage, base defence circle, " ..
                "tank hits that do not set off mines and spawn starts. " ..
                "Nothing can be changed in the lobby.",
  api = 1,
  updated = "2026-10-28T13:34Z",
  kind = "mod",
  bound = false,

  rules = {
    -- Shell pushback: the Mac Bolo push, harder on a weakened tank.
    tank_slide_mac = 1,
    tank_slide_step = 28,
    tank_slide_armour_bonus = 32,
    tank_bump_decay_shift = 2,

    -- Pillbox shell cap: twelve pillbox shells in the air at one tank.
    pill_shell_cap = 1,
    pill_max_shells_at_tank = 12,

    -- Tank clearance: the Mac Bolo tank boxes against solid squares.
    tank_collision_mac = 1,

    -- Pillbox aiming: Mac Bolo's lead, with the massage bug up close.
    pill_aim_mac = 1,

    -- Base defence: a circle of radius 7 round a shot base, edge left out.
    pill_base_defend_shape = 1,
    pill_base_defend_range = 7,

    -- Tank hits and mines: a shell that hits a tank leaves the mines on
    -- its square alone.
    tank_hit_sets_off_mines = 0,
  },

  callbacks = {
    on_choose_start = "Keeps the lobby's start for an opening tank; else picks a start with no tank or pill near, else none of the enemy's.",
  },
}

-- ---- Starts --------------------------------------------------------------

-- The seat's lobby team, or 0 when it has none.
local function team_of(p)
  local slot = game.lobby_slot(p)
  return slot and slot.team or 0
end

-- Whether seat q is on seat p's side: p itself, or a seat on p's team.
local function is_friend(p, my_team, q)
  if q == p then
    return true
  end
  return my_team ~= 0 and team_of(q) == my_team
end

local function distance(x1, y1, x2, y2)
  return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
end

-- What is near start s for seat p: whether any tank or pill is, and whether
-- an enemy tank or enemy pill is.
local function survey(p, my_team, s, tank_range, pill_range)
  local any, enemy = false, false

  for q = 0, game.max_tanks() - 1 do
    if q ~= p then
      local t = game.tank(q)
      if t and distance(s.x, s.y, t.mx, t.my) <= tank_range then
        any = true
        if not is_friend(p, my_team, q) then
          enemy = true
        end
      end
    end
  end

  -- A pill being carried or with no armour left is no danger.
  for n = 1, game.num_pills() do
    local pill = game.pill(n)
    if pill and not pill.in_tank and pill.armour > 0 and
        distance(s.x, s.y, pill.x, pill.y) <= pill_range then
      any = true
      if pill.owner ~= game.NEUTRAL and not is_friend(p, my_team, pill.owner) then
        enemy = true
      end
    end
  end

  return any, enemy
end

-- A start a tank can be put on: deep sea with no mine.
local function usable(s)
  return game.map_tile(s.x, s.y) == game.TERRAIN.deep_sea and
         not game.is_mine(s.x, s.y)
end

-- lobby is the start the lobby chose for this tank, counted as game.start
-- counts, or nil when it chose none. The lobby chooses for each seat's
-- first tank of the round and for no spawn after it.
function on_choose_start(p, lobby)
  -- The opening placement is the lobby's: each player's start, picked by
  -- hand or by the team's side, is the one handed back. A spawn the lobby
  -- chose nothing for is Mac Bolo's.
  if lobby ~= nil then
    return lobby
  end

  local count = game.num_starts()
  if count == 0 then
    return nil
  end

  local tank_range = game.rule("start_tank_range")
  local pill_range = game.rule("start_pill_range")
  local my_team = team_of(p)
  local offset = math.random(count) - 1
  local no_enemy = nil

  for i = 0, count - 1 do
    local n = (offset + i) % count + 1
    local s = game.start(n)
    if s and usable(s) then
      local any, enemy = survey(p, my_team, s, tank_range, pill_range)
      if not any then
        return n                 -- pass one: nothing near at all
      end
      if not enemy and no_enemy == nil then
        no_enemy = n             -- pass two's answer, kept in case pass one finds none
      end
    end
  end

  return no_enemy                -- nil leaves the pick to the engine
end
