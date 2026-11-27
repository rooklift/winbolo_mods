-- =========================================================================
-- Mac Bolo Lite — Mac Bolo minus the two most annoying parts. It is the
-- Mac Bolo Rules mod with every part on at its default and nothing for
-- the host to change, except that spawns and parachute speed stay as
-- WinBolo has them. It also leaves the builder blast area as WinBolo has
-- it, and it starts every pillbox calm whatever the map says.
--
-- Written for WinBolo 2.2.2 or later. Where this mod leaves a rule alone
-- it plays that version's default, and an older server's defaults differ:
-- its pillbox shells fly an eighth of a square further and its builder
-- blast circle is 128 world units, not 144.
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
-- Pillbox shell cap. No more than pill_max_shells_at_tank pillbox shells
-- are in the air at any one tank. A pillbox whose nearest target already
-- has that many coming loses its shot and reloads. pill_shell_cap turns
-- the limit on, and this mod sets it to twelve.
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
-- Starting pillbox fire rate. A map gives each pillbox its own ticks
-- between shots, and 50 is as common as the calm 100. WinBolo starts a
-- pillbox at the map's number and lets it cool to calm, one tick slower
-- every pill_cooldown_ticks, so a 50 fires fast for the round's first half
-- minute. This mod sets every such pillbox to one tick short of calm
-- before the round's first tick, and it cools the last tick within a
-- second. It is set one short, not to calm itself, because the cooldown
-- the map's number started is still counting and would carry a pillbox
-- set to calm one tick past it.
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
-- Tree growth. WinBolo's own tree growth rate now more or less matches
-- Mac Bolo's, so this mod leaves tree_grow_ticks and
-- tree_grow_initial_ticks alone.
--
-- Parachute speed. A builder who dies parachutes back in, flying straight
-- at his tank. Mac Bolo flies him slower than WinBolo does, but this mod
-- leaves lgm_helicopter_speed alone, so he comes back at WinBolo's speed.
--
-- Builder blast. A shell or mine that goes off on open ground kills a
-- builder near it. Mac Bolo counts "near" as a box: under 128 world units
-- from the explosion on each axis. WinBolo counts it as a circle of radius
-- 144, which has about the box's area. This mod leaves lgm_blast_shape
-- alone, so the circle applies.
--
-- Starts. WinBolo picks every start itself, as it does with no mod on:
-- the round's opening tanks go where the lobby put them, and every later
-- spawn uses the engine's own pick, not Mac Bolo's.
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
  name = "Mac Bolo Lite",
  author = "jm, canuck, rooklift, claude",
  description = "Mac Bolo minus two annoying parts. " ..
                "Includes pillbox massage, base defence circle, etc. " ..
                "Spawns and parachute speed use WinBolo's own logic in this version. " ..
                "The builder blast area is WinBolo's circle too, not Mac Bolo's box.",
  api = 1,
  updated = "2026-11-27T00:00Z",
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

    -- Superbooms: Mac Bolo's threshold, more than 60 shells and mines.
    big_explosion_threshold = 60,
  },

  -- What the callback below does, in a line a player reads: the lobby's
  -- details dialog lists it under "What this mod implements:".
  callbacks = {
    on_setup = "Starts every pillbox at the calm firing rate, whatever the map says.",
  },
}

-- Once, after the rules above are applied and before the round's first
-- tick. A pillbox the map started faster than calm is set to one tick
-- short of calm; one already calm is left alone.
function on_setup()
  local calm = game.rule("pill_attack_ticks")
  for n = 1, game.num_pills() do
    local pill = game.pill(n)
    if pill ~= nil and pill.speed < calm then
      game.set_pill_speed(n, calm - 1)
    end
  end
end
