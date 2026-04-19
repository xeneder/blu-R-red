/// @description Read input, move with diagonal normalisation, advance animation.

// Sort depth
event_inherited()

// Freeze all hero logic on game over — no movement, no signals, no animation.
if (game_is_over()) exit;

// Analog-first input; scr_controls already falls back to digital when the
// stick is idle and keyboard/D-pad are pressed.
var _v2 = vec2_clamp_unit(ctrl_axis_h(), ctrl_axis_v());

// move_and_collide slides along walls and honours every child of obj_wall —
// obj_door_blocked always, and obj_door_closed while its mask is active.
// Knockback is additive: the player can still nudge against it but the
// hit's impulse carries for a few frames before KNOCKBACK_DAMP wins.
move_and_collide(_v2.h * move_speed + knockback_vx,
                 _v2.v * move_speed + knockback_vy, obj_wall);
knockback_vx *= KNOCKBACK_DAMP;
knockback_vy *= KNOCKBACK_DAMP;
if (abs(knockback_vx) < 0.1) knockback_vx = 0;
if (abs(knockback_vy) < 0.1) knockback_vy = 0;

// Tick i-frame timer.
if (iframe_ttl > 0) iframe_ttl = max(0, iframe_ttl - delta_time / 1000000);

// Bezier-eased ramp so the squash / bob response doesn't snap on/off.
move_factor = bezier_approach(move_factor, _v2.magnitude, 0.18, BEZIER_EASE_OUT);

if (abs(_v2.h) > 0.1) facing_x = sign(_v2.h);

// --- Signal pings ----------------------------------------------------------
// Only flash the eye when the signal actually went out (cooldown may reject).
if (ctrl_pressed(CTRL.ACTION_1) && signal_emit(x, y, SIGNAL.BLUE) != noone) {
    eye_blink_signal = SIGNAL.BLUE;
    eye_blink_ttl    = EYE_BLINK_DURATION;
}
if (ctrl_pressed(CTRL.ACTION_2) && signal_emit(x, y, SIGNAL.RED) != noone) {
    eye_blink_signal = SIGNAL.RED;
    eye_blink_ttl    = EYE_BLINK_DURATION;
}

if (eye_blink_ttl > 0) {
    eye_blink_ttl = max(0, eye_blink_ttl - delta_time / 1000000);
}

// Advance bob phase at the rate dictated by the *current* period. Integrating
// the rate avoids the phase jump you'd get from dividing a monotonic clock
// by a changing period while idle/move blend.
var _period = lerp(IDLE_BOB_PERIOD, MOVE_BOB_PERIOD, move_factor);
bob_phase = frac(bob_phase + (delta_time / 1000000) / _period);
