-- =========================================================================
-- Mac Bolo Rules Locked Turn Fix — the Mac Bolo Rules mod with every part
-- on at its default and nothing for the host to change, and with every
-- turn rate about 0.1% faster, as a stopgap for a drawing bug.
--
-- Shell pushback. A tank a shell hits and survives slides along the
-- shell's direction of travel. WinBolo slides every tank the same
-- distance, whatever its armour. Mac Bolo pushes a weakened tank harder:
-- about 7 pixels at full armour, rising to about 14 on the last hit a tank
-- survives. tank_slide_mac turns the Mac Bolo push on. tank_slide_step is
-- then the push at full armour and tank_slide_armour_bonus the extra push
-- at zero armour, scaled by the armour missing before the hit. Both, and
-- tank_bump_decay_shift, are read per 40 ms, so a push travels
-- step * 2^shift in all, in a slide that moves every tick.
--
-- Pillbox shell cap. Mac Bolo keeps twelve shell slots for the pillbox
-- shells in the air at one tank. pill_shell_cap turns WinBolo's version of
-- that limit on, at pill_max_shells_at_tank, twelve.
--
-- Tank clearance. Use the original direction-dependent tank boxes and
-- pixel nudges against solid tiles, allowing close passes beside pills.
--
-- Pillbox aiming and massage. Use Mac Bolo's integer distance and lead
-- calculation. Below one square (as its pixel distance measures it), the
-- unsigned lead wraps and the pill aims roughly 32 squares along a moving
-- tank's heading. Passing closely beside a pill can therefore evade its
-- shots. There is no heading restriction; stopping or being obstructed
-- removes the lead. Beyond that distance the same formula leads normally.
-- This overrides the older pill_massage_range/cosine approximation.
--
-- Angry pillbox fire rate. A pillbox that is hit, or whose base is shot,
-- halves the ticks between its shots. Mac Bolo floors that at 4 and fires
-- one tick after the count runs out, so an angry pillbox's fastest is a
-- shot every 5 ticks. WinBolo fires as the count runs out, and floors it
-- at pill_attack_min_ticks, 6 by default. This part sets it to 5.
--
-- Base defence. When a base is shot, every allied pillbox near it gets
-- angry and fires faster. WinBolo has always counted "near" as a square:
-- up to 9 map squares away on each axis, edge included, which reaches a
-- pillbox 9 across and 9 down, about 12.7 squares off. Mac Bolo counts it
-- as a circle of radius 7 with the edge left out, so a pillbox exactly 7
-- away, or at 5 across and 5 down, stays calm.
--
-- Tank hits and mines. In Mac Bolo a shell that hits a tank does not
-- touch the map square at all; only a shell that hits the ground or
-- terrain sets off a mine. tank_hit_sets_off_mines at 0 plays that way,
-- and 0 is now WinBolo's own default. In WinBolo 2.1 a shell that hit a
-- tank also set off any mine on the square where it burst, so a tank that
-- laid mines as it ran could have them set off by the shots of the tank
-- chasing it. The Tank Hits Set Off Mines mod sets 1 to play that way.
-- This part keeps the rule at 0, so it only changes the round when
-- another script on the list sets 1.
--
-- Starts. The engine tells on_choose_start which start the lobby put the
-- seat on: the start its player picked by hand, else one on the team's
-- side, else the engine's own spread of the field. That start is the
-- seat's for its first tank of the round only, so a later spawn is told
-- nothing. The mod hands the lobby's start straight back, so the round's
-- opening tanks go where the lobby put them, and every spawn the lobby has
-- no start for is Mac Bolo's.
--
-- The Mac Bolo pick (randstart) looks only at starts on deep sea with no
-- mine, going round them from a random one. It takes the first with
-- nothing near it at all: no tank and no pillbox, whoever owns them. If
-- every start has something near it, it takes one with no enemy tank and no
-- enemy pillbox near it. If none is free of enemies, it takes the first
-- usable start it looked at, or the map's first start if none is usable.
-- The engine then moves the tank off the start to the nearest clear
-- square, as Mac Bolo does.
--
-- "Near" is Mac Bolo's own distance: under 16 squares for a tank and under
-- 9 for a pillbox, measured as a circle. A dead tank does not count. A dead
-- pillbox does; one being carried does not.
--
-- "Enemy" is the game's own alliances, including those made and broken in
-- play. A neutral pillbox counts as an enemy one. Mac Bolo judges every
-- pillbox near a start by the owner of the first one (BOLO BUG 3), so a
-- friendly pillbox there hides an enemy one; the mod judges each pillbox
-- by its own owner.
--
-- Turn rates. With the Mac Bolo tank collision boxes on, a tank whose
-- heading is exactly halfway between two of the 16 directions (8, 24 ...
-- 248, out of 256) drives the higher direction but is drawn as the lower
-- one, so a tank stopped on 72 looks east and drives east-south-east. The
-- classic turn rates (1, 0.5 and 0.25 a tick, an eighth of that while a
-- turn starts) add up to exact whole numbers, so a turning tank stops on
-- these headings often. Every turn rate here is its classic value times
-- 1 + 1/1024, about 0.1% faster, which nobody can feel. The factor is a
-- power-of-two fraction, so every heading a tank can reach stays exact: a
-- turn that would stop on 72 stops 1/128 or 3/128 to one side of it
-- instead. That is enough to survive the server cutting the heading down
-- to 1/256 when it sends it to the other players, which a smaller nudge
-- does not. Only a tank that has turned about 16 whole circles more one
-- way than the other since it spawned can still land on a halfway heading,
-- and a script that teleports a tank to face exactly halfway still shows
-- the bug. Once WinBolo itself is fixed, put the classic turn rates back.
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
  description = "Includes pillbox massage, base defence circle, etc etc. " ..
                "Turn rates are about 0.1% faster to work around a WinBolo bug.",
  api = 1,
  updated = "2026-10-30T13:47Z",
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

    -- Angry pillbox fire rate: Mac Bolo's fastest, a shot every 5 ticks.
    pill_attack_min_ticks = 5,

    -- Base defence: a circle of radius 7 round a shot base, edge left out.
    pill_base_defend_shape = 1,
    pill_base_defend_range = 7,

    -- Tank hits and mines: a shell that hits a tank leaves the mines on
    -- its square alone.
    tank_hit_sets_off_mines = 0,

    -- Turn rates: the classic rates times 1 + 1/1024, so a turning tank
    -- does not stop exactly halfway between two directions (see above).
    turn_road = 1.0009765625,
    turn_grass = 1.0009765625,
    turn_forest = 0.50048828125,
    turn_river = 0.250244140625,
    turn_swamp = 0.250244140625,
    turn_crater = 0.250244140625,
    turn_rubble = 0.250244140625,
    turn_boat = 1.0009765625,
    turn_deep_sea = 0.50048828125,
    turn_refuel_base = 1.0009765625,
  },

  callbacks = {
    on_choose_start = "Keeps the lobby's start for an opening tank; else Mac Bolo's pick: a start with no tank or pill near, else none of the enemy's.",
  },
}

-- ---- Starts --------------------------------------------------------------

-- Mac Bolo's ranges, in map squares: a tank under 16 squares from a
-- start, or a pillbox under 9, is near it.
local TANK_NEAR = 16
local PILL_NEAR = 9

-- Whether a point dx, dy world units away is under squares map squares
-- off, as a circle.
local function within(dx, dy, squares)
  local r = squares * 256
  return dx * dx + dy * dy < r * r
end

-- A map square's middle in world units, where a tank put on it stands.
local function square_middle(m)
  return m * 256 + 128
end

-- Whether seat q is on seat p's side, by the game's own alliances.
local function is_friend(p, q)
  return q == p or game.allied(p, q) == true
end

-- What is near start s for seat p: whether any tank or pill is, and whether
-- an enemy tank or enemy pill is.
local function survey(p, s)
  local sx, sy = square_middle(s.x), square_middle(s.y)
  local any, enemy = false, false

  for q = 0, game.max_tanks() - 1 do
    if q ~= p then
      local t = game.tank(q)
      if t and not t.dead and within(t.wx - sx, t.wy - sy, TANK_NEAR) then
        any = true
        if not is_friend(p, q) then
          enemy = true
        end
      end
    end
  end

  -- A pillbox being carried is not on the map. A dead one still counts.
  for n = 1, game.num_pills() do
    local pill = game.pill(n)
    if pill and not pill.in_tank and
        within(square_middle(pill.x) - sx, square_middle(pill.y) - sy, PILL_NEAR) then
      any = true
      if pill.owner == game.NEUTRAL or not is_friend(p, pill.owner) then
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

  local offset = math.random(count) - 1
  local no_enemy = nil
  local first_usable = nil

  for i = 0, count - 1 do
    local n = (offset + i) % count + 1
    local s = game.start(n)
    if s and usable(s) then
      local any, enemy = survey(p, s)
      if not any then
        return n                 -- nothing near at all
      end
      if not enemy then
        no_enemy = n             -- no enemy near: Mac Bolo keeps the last
      end
      if first_usable == nil then
        first_usable = n
      end
    end
  end

  -- With none free of enemies, the first usable start looked at, else the
  -- map's first start. The engine moves the tank to the nearest clear
  -- square.
  return no_enemy or first_usable or 1
end
