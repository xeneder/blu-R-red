/// @description Advance the playback clock. Ends the cycle when every
///              symbol (including its trailing gap) has finished.

event_inherited();

if (!playback_active) exit;

playback_t += delta_time / 1000000;

var _per_symbol = TOTEM_SYMBOL_SHOW + TOTEM_SYMBOL_GAP;
var _total_time = string_length(playback_pattern) * _per_symbol;

// One-shot SFX at the start of each symbol's show window.
var _current_i = floor(playback_t / _per_symbol);
if (_current_i != playback_last_symbol_i && _current_i < string_length(playback_pattern)) {
    var _char = string_char_at(playback_pattern, _current_i + 1);
    var _snd  = (_char == "B") ? sfx_totem_show_blue : sfx_totem_show_red;
    audio_play_sound(_snd, 1, false);
    playback_last_symbol_i = _current_i;
}

if (playback_t >= _total_time) {
    playback_active = false;
    playback_t      = 0;
}
