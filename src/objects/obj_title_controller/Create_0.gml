/// @description Title screen init — starts faded-in from black, plays BGM.

title_time = 0;   // clock for the prompt pulse

// Fade in from black every time we enter the title (first launch, or
// future "return to title" flows).
transition_state = GC_TRANSITION.FADING_IN;
transition_t     = 0;

// BGM — start if not already playing, un-duck if we came back from a
// game-over (gameplay ducks to 0.25 on death).
//if (!audio_is_playing(bgm_main)) audio_play_sound(bgm_main, 1, true);
//audio_sound_gain(bgm_main, 1, 300);
