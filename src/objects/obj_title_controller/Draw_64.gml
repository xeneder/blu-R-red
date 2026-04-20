/// @description Title screen — background wash, logo, pulsing prompt,
///              transition overlay on top.

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// --- Background wash (same mood as the room_game background). ---
draw_set_color(make_color_rgb(20, 25, 35));
draw_set_alpha(1);
draw_rectangle(0, 0, _gw, _gh, false);

// --- Logo (drawn at its own pivot). ---
draw_sprite(spr_logo, 0, _gw * 0.5, _gh * 0.4);

// --- Pulsing "PRESS CONFIRM" prompt. ---
var _pulse = 0.6 + 0.4 * (0.5 + 0.5 * sin(title_time * 3));

draw_set_font(fnt_main);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_set_alpha(_pulse);
draw_text_transformed(_gw * 0.5, _gh * 0.7, "PRESS CONFIRM TO START", 1.4, 1.4, 0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);

// --- Scene transition overlay. ---
if (transition_state != GC_TRANSITION.NONE) {
    var _tt = clamp(transition_t / TRANSITION_DURATION, 0, 1);
    var _trans_alpha = (transition_state == GC_TRANSITION.FADING_OUT)
        ? bezier_ease(_tt, BEZIER_EASE_IN_OUT)
        : 1 - bezier_ease(_tt, BEZIER_EASE_IN_OUT);

    draw_set_color(c_black);
    draw_set_alpha(_trans_alpha);
    draw_rectangle(0, 0, _gw, _gh, false);
    draw_set_alpha(1);
}
