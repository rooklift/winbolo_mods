-- =========================================================================
-- Mac Bolo Except Spawns — the Mac Bolo Rules mod with every part on at
-- its default and nothing for the host to change, with every turn rate
-- about 0.1% faster, as a stopgap for a drawing bug, and with WinBolo's
-- own spawn logic in place of Mac Bolo's.
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
-- Pillbox shell range. A Mac Bolo pillbox's shell starts half a square
-- out and flies 32 steps of about a quarter square, so it falls 2143 to
-- 2175 world units (256 to a square) from the pillbox, by direction.
-- WinBolo's starts 160 out and flies pill_fire_length, 8.5 by default,
-- which ends it 2208 out, a quarter square further. This mod sets
-- pill_fire_length to 8.25, which ends it 2144 out.
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
-- terrain sets off a mine. WinBolo's own default, tank_hit_sets_off_mines
-- at 0, already plays that way, so this mod does not set the rule. With
-- the Tank Hits Set Off Mines mod also on the list, its 1 applies.
--
-- Superbooms. A tank that dies carrying enough shells and mines goes up in
-- a big explosion, which craters a 2 x 2 block and hurts any pillbox in
-- it. WinBolo needs more than 20 shells and mines together; Mac Bolo needs
-- more than 60, three quarters of the 80 a full tank holds. This mod sets
-- big_explosion_threshold to 60.
--
-- Starts. WinBolo picks every start itself, as it does with no mod on:
-- the round's opening tanks go where the lobby put them, and every later
-- spawn uses the engine's own pick, not Mac Bolo's.
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
  name = "Mac Bolo Except Spawns",
  author = "jm, canuck, rooklift, claude",
  description = "Includes pillbox massage, base defence circle, etc etc. " ..
                "Turn rates are about 0.1% faster to work around a WinBolo bug. " ..
                "Spawns use WinBolo's own logic.",
  api = 1,
  updated = "2026-11-02T20:52Z",
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

    -- Pillbox shell range: a shell falls 2144 world units out, not 2208.
    pill_fire_length = 8.25,

    -- Base defence: a circle of radius 7 round a shot base, edge left out.
    pill_base_defend_shape = 1,
    pill_base_defend_range = 7,

    -- Superbooms: Mac Bolo's threshold, more than 60 shells and mines.
    big_explosion_threshold = 60,

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
}
