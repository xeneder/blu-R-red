/// @description Advance the playback clock. Ends the cycle when every
///              symbol (including its trailing gap) has finished.

event_inherited();

if (!playback_active) exit;

playback_t += delta_time / 1000000;

var _per_symbol = TOTEM_SYMBOL_SHOW + TOTEM_SYMBOL_GAP;
var _total_time = string_length(playback_pattern) * _per_symbol;

if (playback_t >= _total_time) {
    playback_active = false;
    playback_t      = 0;
}
