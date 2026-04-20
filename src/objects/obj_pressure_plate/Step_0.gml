/// @description Press state follows whether the hero or a crawler is on top;
///              push the new state to the linked door only when it flips.

var _now_pressed = place_meeting(x, y, obj_hero)
                || place_meeting(x, y, obj_enemy_crawler);

if (_now_pressed != pressed) {
    pressed = _now_pressed;
    if (instance_exists(linked_door)) {
        linked_door.is_open = pressed;
    }

    // Seed a new fg-slide animation from the current position.
    pressed_anim_from = press_offset;
    pressed_anim_to   = pressed ? 1 : 0;
    pressed_anim_t    = 0;
}

// Advance the animation with a bezier ease-in-out.
if (pressed_anim_t < 1) {
    pressed_anim_t = min(1, pressed_anim_t + (delta_time / 1000000) / PLATE_ANIM_DURATION);
    press_offset = lerp(pressed_anim_from, pressed_anim_to,
                        bezier_ease(pressed_anim_t, BEZIER_EASE_IN_OUT));
}
