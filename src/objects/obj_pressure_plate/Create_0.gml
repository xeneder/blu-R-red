/// @description Floor-depth activator. Finds its paired door via door_id and
///              drives its `is_open` state from the press state below.

if (!variable_instance_exists(id, "door_id")) door_id = 0;

// Floor layer — characters draw above the plate regardless of their y.
depth = 0;

pressed     = false;
linked_door = noone;

// --- Press-down animation (fg sprite translates 11px on press) ---
#macro PLATE_PRESS_OFFSET    11
#macro PLATE_ANIM_DURATION   0.22

pressed_anim_from = 0;       // 0 = up, 1 = fully pressed
pressed_anim_to   = 0;
pressed_anim_t    = 1;       // 1 = idle (no anim in progress)
press_offset      = 0;       // lerped 0..1, multiplied by PLATE_PRESS_OFFSET in Draw

// One-shot lookup: the door whose door_id matches ours.
var _target = door_id;
with (obj_door_closed) {
    if (door_id == _target) other.linked_door = id;
}
