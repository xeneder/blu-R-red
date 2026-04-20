/// @description Owns HP, drives signal system, renders HUD.

#macro HP_MAX 3

hp             = HP_MAX;
game_over      = false;
game_over_time = 0;       // seconds since game over started (for ease-in of text)

// --- Victory state ---
#macro VICTORY_SHOWER_SPAWN_PER_SEC   22
#macro VICTORY_SHOWER_LIFE_MIN        3.0
#macro VICTORY_SHOWER_LIFE_MAX        5.0
#macro VICTORY_SHOWER_GRAVITY         120

victory              = false;
victory_time         = 0;
confetti_shower      = [];
confetti_spawn_accum = 0;

// --- Scene transition state ---
// If we just came back from a room_restart, start with a black-to-clear
// fade-in. Otherwise idle. global.restart_fade_in is set by the fade-OUT
// just before it calls room_restart().
transition_state = GC_TRANSITION.NONE;
transition_t     = 0;
if (variable_global_exists("restart_fade_in") && global.restart_fade_in) {
    global.restart_fade_in = false;
    transition_state = GC_TRANSITION.FADING_IN;
}

signals_init();

// --- BGM — restart cleanly so the post-death gain duck is cleared. ---
audio_stop_sound(bgm_main);
audio_play_sound(bgm_main, 1, true);

// --- Shared AI navigation grid ---
// Singleton. Every crawler mp_grid_path's against this one. ai_grid_refresh()
// is called here on init, on every door mask-toggle (see obj_door_closed's
// Step), and on any obj_wall child's Clean Up.
ai_grid = -1;
var _gw = room_width  div AI_GRID_CELL;
var _gh = room_height div AI_GRID_CELL;
ai_grid = mp_grid_create(0, 0, _gw, _gh, AI_GRID_CELL, AI_GRID_CELL);
ai_grid_refresh();
