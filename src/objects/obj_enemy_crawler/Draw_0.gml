/// @description Bezier-eased squash/stretch. Stronger & faster while moving.

var _amt      = is_moving ? CRAWLER_MOVE_SQUASH : CRAWLER_IDLE_SQUASH;
var _bob_01   = anim_bezier_pingpong_phase(bob_phase, BEZIER_EASE_IN_OUT);

// Peaks at the "landing" end of the cycle.
var _squash_t = bezier_ease(1 - _bob_01, BEZIER_EASE_IN);
var _squash   = _squash_t * _amt;
var _xscale   = (1 + _squash) * facing_x;
var _yscale   = (1 - _squash);

draw_sprite_ext(sprite_index, image_index,
                x, y,
                _xscale, _yscale, 0, c_white, 1);
