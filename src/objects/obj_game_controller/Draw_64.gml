/// @description Draw GUI — hearts row + game-over overlay.

#macro HUD_HEART_SIZE     48
#macro HUD_HEART_GAP      12
#macro HUD_MARGIN         28
#macro HUD_LOST_ALPHA     0.18

var _sw = sprite_get_width(spr_heart);
var _sh = sprite_get_height(spr_heart);
var _xscale = HUD_HEART_SIZE / _sw;
var _yscale = HUD_HEART_SIZE / _sh;

for (var _i = 0; _i < HP_MAX; _i++) {
    var _hx = HUD_MARGIN + _i * (HUD_HEART_SIZE + HUD_HEART_GAP);
    var _hy = HUD_MARGIN;
    var _alpha = (_i < hp) ? 1 : HUD_LOST_ALPHA;
    draw_sprite_ext(spr_heart, 0, _hx, _hy, _xscale, _yscale, 0, c_white, _alpha);
}

draw_set_color(c_black);
draw_set_font(fnt_main);
draw_text(120, 120, fps)


// --- Game over overlay ----------------------------------------------------
if (game_over) {
    var _gw = display_get_gui_width();
    var _gh = display_get_gui_height();

    // Fade-in using an ease-out bezier so text resolves softly.
    var _t     = clamp(game_over_time / 0.8, 0, 1);
    var _fade  = bezier_ease(_t, BEZIER_EASE_OUT);

    draw_set_color(c_black);
    draw_set_alpha(_fade * 0.65);
    draw_rectangle(0, 0, _gw, _gh, false);

    draw_set_alpha(_fade);
    draw_set_color(c_white);
    draw_set_font(fnt_main);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // SDF font scales cleanly — we're leaning on that here.
    draw_text_transformed(_gw * 0.5, _gh * 0.5, "GAME OVER", 3.5, 3.5, 0);

    // "PRESS CONFIRM" prompt — pulses subtly once the overlay settles so
    // the player reads it as interactive rather than pure titling.
    var _prompt_reveal = clamp((game_over_time - RESTART_INPUT_DELAY) / 0.4, 0, 1);
    if (_prompt_reveal > 0) {
        var _pulse = 0.75 + 0.25 * (0.5 + 0.5 * sin(game_over_time * 4));
        draw_set_alpha(_fade * _prompt_reveal * _pulse);
        draw_text_transformed(_gw * 0.5, _gh * 0.5 + 120,
                              "PRESS CONFIRM", 1.2, 1.2, 0);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
}

// --- Scene transition overlay (drawn over everything, including game over) ---
if (transition_state != GC_TRANSITION.NONE) {
    var _gw2  = display_get_gui_width();
    var _gh2  = display_get_gui_height();
    var _tt   = clamp(transition_t / TRANSITION_DURATION, 0, 1);
    var _trans_alpha = (transition_state == GC_TRANSITION.FADING_OUT)
        ? bezier_ease(_tt, BEZIER_EASE_IN_OUT)
        : 1 - bezier_ease(_tt, BEZIER_EASE_IN_OUT);

    draw_set_color(c_black);
    draw_set_alpha(_trans_alpha);
    draw_rectangle(0, 0, _gw2, _gh2, false);
    draw_set_alpha(1);
}