/// @description Base totem sprite + a bezier-pulsed eye overlay per symbol.

draw_self();

if (!playback_active) exit;

var _per_symbol = TOTEM_SYMBOL_SHOW + TOTEM_SYMBOL_GAP;
var _current_i  = floor(playback_t / _per_symbol);
var _local_t    = playback_t - _current_i * _per_symbol;

// Out-of-bounds or gap phase — nothing to draw right now.
if (_current_i >= string_length(playback_pattern)) exit;
if (_local_t >= TOTEM_SYMBOL_SHOW) exit;

// Symmetric pulse over the show window: bezier-smoothed 0 → 1 → 0.
var _t01   = _local_t / TOTEM_SYMBOL_SHOW;
var _alpha = anim_bezier_pingpong_phase(_t01, BEZIER_EASE_IN_OUT);

var _char = string_char_at(playback_pattern, _current_i + 1);
var _spr  = (_char == "B") ? spr_totem_eye_blue : spr_totem_eye_red;

draw_sprite_ext(_spr, 0, x, y, 1, 1, 0, c_white, _alpha);
