/// @description Begin Step — tick signal buffer timeout + game-over clock.

var _dt = delta_time / 1000000;

signal_tick(_dt);

if (game_over) game_over_time += _dt;
