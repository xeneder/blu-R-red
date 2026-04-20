/// @description Three-layer stack — bg → fg (slides down when pressed) → light.

draw_sprite(spr_pressure_plate_bg, 0, x, y);

var _fg_dy = press_offset * PLATE_PRESS_OFFSET;
draw_sprite(spr_pressure_plate_fg, 0, x, y + _fg_dy);

var _light = pressed ? spr_pressure_plate_light_active
                     : spr_pressure_plate_light_inactive;
draw_sprite(_light, 0, x, y);
