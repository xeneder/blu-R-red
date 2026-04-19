/// @description Owns HP, drives signal system, renders HUD.

#macro HP_MAX 3

hp             = HP_MAX;
game_over      = false;
game_over_time = 0;       // seconds since game over started (for ease-in of text)

signals_init();

// --- Shared AI navigation grid ---
// Singleton. Every crawler mp_grid_path's against this one. ai_grid_refresh()
// is called here on init, on every door mask-toggle (see obj_door_closed's
// Step), and on any obj_wall child's Clean Up.
ai_grid = -1;
var _gw = room_width  div AI_GRID_CELL;
var _gh = room_height div AI_GRID_CELL;
ai_grid = mp_grid_create(0, 0, _gw, _gh, AI_GRID_CELL, AI_GRID_CELL);
ai_grid_refresh();
