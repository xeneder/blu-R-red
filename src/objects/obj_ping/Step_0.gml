/// @description Grow radius along a bezier ease-out. Notify mines as the
///              leading edge crosses them (blue pings only). Destroy on fade.

var _dt = delta_time / 1000000;
lifetime += _dt;

// Derive total life from speed so radius growth feels framerate-independent.
if (life_total <= 0) life_total = max_radius / SIGNAL_PING_SPEED;

var _t = clamp(lifetime / life_total, 0, 1);
radius_prev = radius;
radius = bezier_ease(_t, BEZIER_EASE_OUT) * max_radius;

// World-interacting blue pings (player-emitted, not mine echoes) trigger
// receivers once each, the frame their leading edge sweeps over them.
if (ping_color == SIGNAL.BLUE && activates_mines) {
    with (obj_mine) {
        var _d = point_distance(x, y, other.x, other.y);
        if (_d <= other.radius && _d > other.radius_prev) {
            mine_reveal(id);
        }
    }
    with (obj_totem) {
        var _d = point_distance(x, y, other.x, other.y);
        if (_d <= other.radius && _d > other.radius_prev) {
            totem_trigger(id);
        }
    }
}

// Fade + despawn after reaching full radius. Extra tail for the fade pass.
if (_t >= 1 && lifetime >= life_total * 1.4) instance_destroy();
