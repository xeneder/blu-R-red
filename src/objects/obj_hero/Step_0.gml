/// @description Read input, move with diagonal normalisation, advance animation.

// Analog-first input; scr_controls already falls back to digital when the
// stick is idle and keyboard/D-pad are pressed.
var _v2 = vec2_clamp_unit(ctrl_axis_h(), ctrl_axis_v());

x += _v2.h * move_speed;
y += _v2.v * move_speed;

// Bezier-eased ramp so the squash / bob response doesn't snap on/off.
move_factor = bezier_approach(move_factor, _v2.magnitude, 0.18, BEZIER_EASE_OUT);

if (abs(_v2.h) > 0.1) facing_x = sign(_v2.h);

// Advance bob phase at the rate dictated by the *current* period. Integrating
// the rate avoids the phase jump you'd get from dividing a monotonic clock
// by a changing period while idle/move blend.
var _period = lerp(IDLE_BOB_PERIOD, MOVE_BOB_PERIOD, move_factor);
bob_phase = frac(bob_phase + (delta_time / 1000000) / _period);
