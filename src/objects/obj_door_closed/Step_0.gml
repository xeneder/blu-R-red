/// @description Toggle state, advance animation, manage collision mask, and
///              push the hero out if the door closed on them.

// Sort depth
event_inherited()

// --- Debug toggle (temporary) ---------------------------------------------
if (keyboard_check_pressed(ord("O"))) is_open = !is_open;

// --- Seed a new animation on state change ---------------------------------
if (is_open != is_open_prev) {
    anim_from    = open_progress;
    anim_to      = is_open ? 1 : 0;
    anim_t       = 0;
    is_open_prev = is_open;
}

// --- Advance animation with a bezier in-out curve -------------------------
if (anim_t < 1) {
    anim_t = min(1, anim_t + (delta_time / 1000000) / DOOR_ANIM_DURATION);
    open_progress = lerp(anim_from, anim_to, bezier_ease(anim_t, BEZIER_EASE_IN_OUT));
}

// --- Toggle collision mask at the halfway point ---------------------------
// Closed half of the cycle blocks the hero; open half is passable. This
// means a door mid-close starts re-blocking the instant it passes 50%.
var _collision_active = (open_progress < 0.5);
sprite_index = _collision_active ? spr_door_blocked : -1;

// --- Push the hero out if the door closed on them -------------------------
// move_and_collide handles the "hero walks into closed door" case. This
// handles the opposite: the door's solid region moved over a stationary hero.
if (_collision_active && instance_exists(obj_hero)) {
    var _hero = instance_find(obj_hero, 0);
    if (place_meeting(x, y, _hero)) {
        var _push_l = _hero.bbox_right  - bbox_left;
        var _push_r = bbox_right        - _hero.bbox_left;
        var _push_u = _hero.bbox_bottom - bbox_top;
        var _push_d = bbox_bottom       - _hero.bbox_top;
        var _min = min(_push_l, _push_r, _push_u, _push_d);

        if      (_min == _push_l) _hero.x -= _push_l;
        else if (_min == _push_r) _hero.x += _push_r;
        else if (_min == _push_u) _hero.y -= _push_u;
        else                      _hero.y += _push_d;
    }
}
