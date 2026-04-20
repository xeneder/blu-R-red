/// @description Begin Step — tick signal buffer timeout, game-over clock,
///               scene transition, and watch for the restart confirm press.

var _dt = delta_time / 1000000;

signal_tick(_dt);

if (game_over) game_over_time += _dt;
if (victory)   victory_time   += _dt;

// --- Victory confetti shower (GUI-space rain) --------------------------
if (victory) {
    // Spawn new particles at a fixed rate.
    confetti_spawn_accum += VICTORY_SHOWER_SPAWN_PER_SEC * _dt;
    var _gw = display_get_gui_width();
    while (confetti_spawn_accum >= 1) {
        confetti_spawn_accum -= 1;
        array_push(confetti_shower, {
            px        : random(_gw),
            py        : -20,
            vx        : random_range(-40, 40),
            vy        : random_range(90, 180),
            rot       : random(360),
            rot_speed : random_range(-360, 360),
            w         : random_range(6, 10),
            h         : random_range(12, 20),
            col       : confetti_color(),
            age       : 0,
            life      : random_range(VICTORY_SHOWER_LIFE_MIN, VICTORY_SHOWER_LIFE_MAX),
        });
    }

    // Integrate + cull. Walk backwards so array_delete doesn't trip indexing.
    var _gh = display_get_gui_height();
    for (var _i = array_length(confetti_shower) - 1; _i >= 0; _i--) {
        var _p = confetti_shower[_i];
        _p.age       += _dt;
        _p.vy        += VICTORY_SHOWER_GRAVITY * _dt;
        _p.px        += _p.vx * _dt;
        _p.py        += _p.vy * _dt;
        _p.rot       += _p.rot_speed * _dt;
        if (_p.age >= _p.life || _p.py > _gh + 40) {
            array_delete(confetti_shower, _i, 1);
        }
    }
}

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
} else {
    // Confirm-to-restart from either end state, once its intro fade has settled.
    var _end_active = game_over || victory;
    var _end_time   = game_over ? game_over_time : victory_time;
    if (_end_active && _end_time >= RESTART_INPUT_DELAY && ctrl_pressed(CTRL.CONFIRM)) {
        transition_state = GC_TRANSITION.FADING_OUT;
        transition_t     = 0;
    }
}
