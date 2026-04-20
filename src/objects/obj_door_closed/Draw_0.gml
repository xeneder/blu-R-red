/// @description Draw the two halves sliding into the walls, clipped at the
///              door-frame edges, plus a bezier crossfade between the
///              "locked" and "unlocked" lock icons.
///
/// Sprite layout (all bottom-center pivot):
///   spr_door_closed_left   — content on the LEFT half of the canvas
///                            (source-x 0..half_w is the art, half_w..full_w is empty)
///   spr_door_closed_right  — content on the RIGHT half of the canvas
///                            (source-x 0..half_w is empty, half_w..full_w is the art)
///   spr_door_closed_lock_* — full-frame canvas with the icon centred
///
/// `draw_sprite_part` is TOP-LEFT anchored (x,y = world position of the
/// cut's top-left, pivot-independent). `draw_sprite_ext` is origin-anchored,
/// but since the lock sprite is centred on a full-frame canvas with a
/// bottom-center pivot, drawing at the door's own (x, y) lands the icon
/// exactly at the frame centre — no extra math needed.

var _mask    = spr_door_blocked;
var _full_w  = sprite_get_width(_mask);
var _full_h  = sprite_get_height(_mask);
var _frame_x = x - sprite_get_xoffset(_mask);
var _frame_y = y - sprite_get_yoffset(_mask);
var _half_w  = _full_w * 0.5;

var _p     = open_progress;
var _vis_w = (1 - _p) * _half_w;

if (_vis_w > 0) {
    // Left half — art lives in source-x [0, half_w]. As it slides LEFT, crop
    // the left edge of the art by p*half_w; the visible slice anchors at the
    // frame's left edge.
    draw_sprite_part(spr_door_closed_left, 0,
                     _p * _half_w, 0, _vis_w, _full_h,
                     _frame_x, _frame_y);

    // Right half — art lives in source-x [half_w, full_w]. As it slides
    // RIGHT, crop the right edge of the art by p*half_w; the visible slice
    // starts at the frame's midline and moves right by p*half_w.
    draw_sprite_part(spr_door_closed_right, 0,
                     _half_w, 0, _vis_w, _full_h,
                     _frame_x + _half_w + _p * _half_w, _frame_y);
}

// Lock icons — two-phase animation so both sprites are transparent when the
// door is fully open (and, symmetrically, opaque when fully closed):
//   first half  of open_progress: crossfade locked → unlocked
//   second half of open_progress: unlocked fades out to transparency
// Closing plays the same curve in reverse.
var _lock_x   = _frame_x + _half_w + _p * _half_w;
var _cross_t  = bezier_ease(clamp(_p * 2,       0, 1), BEZIER_EASE_IN_OUT);
var _fade_t   = bezier_ease(clamp(_p * 2 - 1,   0, 1), BEZIER_EASE_IN_OUT);
var _locked_alpha   = 1 - _cross_t;
var _unlocked_alpha = _cross_t * (1 - _fade_t);

draw_sprite_ext(spr_door_closed_lock_locked,   0, _lock_x, y, 1, 1, 0, c_white, _locked_alpha);
draw_sprite_ext(spr_door_closed_lock_unlocked, 0, _lock_x, y, 1, 1, 0, c_white, _unlocked_alpha);
