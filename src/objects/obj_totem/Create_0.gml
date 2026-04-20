/// @description Totem state. `show_code` is an editor property — the index
///              into global.signals.codes whose pattern this totem plays
///              back when pinged with blue.

event_inherited();

// `show_code` arrives from the instance editor (see the object's properties).
// If left unset somehow, default to the first code.
if (!variable_instance_exists(id, "show_code")) show_code = 0;

// --- Playback state ---
playback_active         = false;
playback_pattern        = "";
playback_t              = 0;
playback_last_symbol_i  = -1;   // tracks which symbol's SFX has been fired
