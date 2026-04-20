/// @description Door state + sliding animation setup.

#macro DOOR_ANIM_DURATION 0.45

// Gameplay state. Flip via a matching pressure plate (see obj_pressure_plate)
// or the debug key in Step.
is_open            = false;
is_open_prev       = false;

// door_id — instance-editor property, matched against obj_pressure_plate.door_id.
if (!variable_instance_exists(id, "door_id")) door_id = 0;

// Animation state.
open_progress      = 0;       // 0 = fully closed, 1 = fully open
anim_from          = 0;
anim_to            = 0;
anim_t             = 1;       // 1 = idle (no animation in progress)

// If an instance was placed with is_open pre-set to true, start there
// instead of animating open on the first frame.
if (is_open) {
    open_progress = 1;
    anim_to       = 1;
    is_open_prev  = true;
    sprite_index  = -1;       // disables collision bbox
}
