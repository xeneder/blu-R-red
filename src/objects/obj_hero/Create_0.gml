/// @description Hero state & animation tuning.

// --- Movement ---
move_speed = 6;             // pixels per frame at full stick / full digital input
facing_x   = 1;             // -1 or +1, flips sprite horizontally

// --- Animation state (written by Step, read by Draw) ---
bob_phase   = 0;            // 0..1 bob cycle position, advanced at the current period's rate
move_factor = 0;            // smoothed 0..1, "how much is the hero currently moving"

// --- Visual tuning ---
IDLE_BOB_AMPLITUDE = 2;     // px of float at rest
MOVE_BOB_AMPLITUDE = 6;     // px of float at full speed
IDLE_BOB_PERIOD    = 1.4;   // seconds per full up-down while idle
MOVE_BOB_PERIOD    = 0.42;  // seconds per full up-down while running
SQUASH_AMOUNT      = 0.10;  // max scale delta at "landing" frame

SHADOW_RADIUS_X = 22;
SHADOW_RADIUS_Y = 6;
SHADOW_ALPHA    = 0.35;
SHADOW_Y_OFFSET = 0;        // tweak if your sprite origin isn't at the feet

// --- Signal-eye blink (overlay flash when emitting a ping) ---
EYE_BLINK_DURATION = 0.28;  // seconds
eye_blink_ttl      = 0;
eye_blink_signal   = SIGNAL.BLUE;
