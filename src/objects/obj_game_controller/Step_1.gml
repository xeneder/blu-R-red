/// @description Begin Step — tick signal buffer timeout, game-over clock,
///               scene transition, and watch for the restart confirm press.

var _dt = delta_time / 1000000;

signal_tick(_dt);

if (game_over) game_over_time += _dt;

// --- Scene transition ---------------------------------------------------
if (transition_state != GC_TRANSITION.NONE) {
    transition_t += _dt;
    if (transition_t >= TRANSITION_DURATION) {
        if (transition_state == GC_TRANSITION.FADING_OUT) {
            // Hand the "start faded-in" baton to the fresh controller that
            // Create will build after the room resets.
            global.restart_fade_in = true;
            room_restart();
            exit;
        } else {
            transition_state = GC_TRANSITION.NONE;
            transition_t     = 0;
        }
    }
} else if (game_over && game_over_time >= RESTART_INPUT_DELAY && ctrl_pressed(CTRL.CONFIRM)) {
    transition_state = GC_TRANSITION.FADING_OUT;
    transition_t     = 0;
}
