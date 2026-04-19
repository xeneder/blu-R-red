/// @description Shadow + bezier-smoothed floating + squash-stretch.

// Bob amplitude blends between idle & move; the period itself is already
// baked into bob_phase (Step advances it at the current rate), so we read
// the phase directly — no period-jump artefact when switching states.
var _bob_amp    = lerp(IDLE_BOB_AMPLITUDE, MOVE_BOB_AMPLITUDE, move_factor);

// 0 = ground, 1 = top of arc. Ease-in-out hangs at the peak and snaps into
// the landing — nicer than sin() and far nicer than a raw triangle.
var _bob_01     = anim_bezier_pingpong_phase(bob_phase, BEZIER_EASE_IN_OUT);
var _bob_offset = -_bob_01 * _bob_amp;

// Squash hits at the landing (_bob_01 near 0), bezier'd so it punches in sharp
// and releases soft. Scaled by move_factor so idle floating stays pristine.
var _squash_t = bezier_ease(1 - _bob_01, BEZIER_EASE_IN);
var _squash   = _squash_t * move_factor * SQUASH_AMOUNT;
var _xscale   = (1 + _squash) * facing_x;
var _yscale   = (1 - _squash);

// --- Shadow: shrinks & fades as the hero rises (fakes a high key light). ---
var _shadow_t     = bezier_ease(_bob_01, BEZIER_EASE_IN_OUT);
var _shadow_scale = lerp(1.00, 0.78, _shadow_t);
var _shadow_alpha = lerp(SHADOW_ALPHA, SHADOW_ALPHA * 0.55, _shadow_t);

var _sx = SHADOW_RADIUS_X * _shadow_scale;
var _sy = SHADOW_RADIUS_Y * _shadow_scale;
var _sy_pos = y + SHADOW_Y_OFFSET;

draw_set_alpha(_shadow_alpha);
draw_set_color(c_black);
draw_ellipse(x - _sx, _sy_pos - _sy, x + _sx, _sy_pos + _sy, false);
draw_set_alpha(1);
draw_set_color(c_white);

// --- Hero sprite ---
draw_sprite_ext(sprite_index, image_index,
                x, y + _bob_offset,
                _xscale, _yscale, 0, c_white, 1);
