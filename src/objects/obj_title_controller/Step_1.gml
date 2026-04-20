/// @description Begin Step — poll input (no obj_camera in this room), advance
///              transition, watch for Confirm to start the game.

ctrl_update();

var _dt = delta_time / 1000000;
title_time += _dt;

if (transition_state != GC_TRANSITION.NONE) {
    transition_t += _dt;
    if (transition_t >= TRANSITION_DURATION) {
        if (transition_state == GC_TRANSITION.FADING_OUT) {
            // Hand the "start faded-in" baton to obj_game_controller — its
            // Create reads this flag and drives the matching fade-in.
            global.restart_fade_in = true;
            room_goto(room_game);
            exit;
        } else {
            transition_state = GC_TRANSITION.NONE;
            transition_t     = 0;
        }
    }
} else if (ctrl_pressed(CTRL.CONFIRM)) {
    transition_state = GC_TRANSITION.FADING_OUT;
    transition_t     = 0;
}
