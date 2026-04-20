/// @description Range + LOS gate; fire on cooldown.

// Sort by depth
event_inherited()

if (game_is_ended()) exit;

var _dt = delta_time / 1000000;
if (fire_timer > 0) fire_timer = max(0, fire_timer - _dt);
if (stop_ttl   > 0) stop_ttl   = max(0, stop_ttl   - _dt);

// Frozen by the stop code — no targeting or firing.
if (stop_ttl > 0) exit;

if (!instance_exists(obj_hero)) exit;
var _hero = instance_find(obj_hero, 0);
if (point_distance(x, y, _hero.x, _hero.y) > TOWER_DETECTION_RANGE) exit;

// Walls block the shot. `false, true` = non-precise, exclude self.
if (collision_line(x, y, _hero.x, _hero.y, obj_wall, false, true) != noone) exit;

if (fire_timer <= 0) {
    var _y_shift = -130;
    var _p   = instance_create_depth(x, y + _y_shift, -50000000, obj_projectile);
    var _dir = point_direction(x, y + _y_shift, _hero.x, _hero.y);
    _p.vx = lengthdir_x(TOWER_PROJECTILE_SPEED, _dir);
    _p.vy = lengthdir_y(TOWER_PROJECTILE_SPEED, _dir);
    fire_timer = TOWER_FIRE_COOLDOWN;

    // Quieter than the full-volume explosions/pings — towers fire often.
    audio_play_sound(sfx_shoot, 1, false, 0.6, 0, random_range(0.93, 1.07));
}
