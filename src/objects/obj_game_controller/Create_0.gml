/// @description Owns HP, drives signal system, renders HUD.

#macro HP_MAX 3

hp             = HP_MAX;
game_over      = false;
game_over_time = 0;       // seconds since game over started (for ease-in of text)

signals_init();
