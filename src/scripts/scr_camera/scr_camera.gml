/// @description Smooth-follow camera framework.
///
/// Usage:
///   var _cam = new Camera(0, 1366, 768);
///   _cam.set_target(instance_find(obj_hero, 0));  // follow an instance
///   _cam.snap_to_target();                        // no smoothing on first frame
///   // each frame (e.g. End Step):
///   _cam.update();
///
///   _cam.shake(8);                                // optional screen shake

function Camera(_view_index = 0, _width = 1366, _height = 768) constructor {
    view_index  = _view_index;
    width       = _width;
    height      = _height;
    x           = 0;       // camera centre in world coords
    y           = 0;
    target_x    = 0;
    target_y    = 0;
    target_inst = noone;
    smoothness  = 0.15;    // 0 = frozen, 1 = snap instantly
    shake_mag   = 0;
    shake_decay = 0.85;

    view_enabled = true;
    view_visible[view_index] = true;
    camera_set_view_size(view_camera[view_index], width, height);

    /// @param {Id.Instance} _inst
    static set_target = function(_inst) {
        target_inst = _inst;
    };

    /// @param {Real} _x
    /// @param {Real} _y
    static set_position = function(_x, _y) {
        target_inst = noone;
        target_x = _x;
        target_y = _y;
    };

    static snap_to_target = function() {
        __sync_target();
        x = target_x;
        y = target_y;
        __apply_view(0, 0);
    };

    /// @param {Real} _magnitude  Peak shake offset in pixels.
    static shake = function(_magnitude) {
        shake_mag = max(shake_mag, _magnitude);
    };

    static update = function() {
        __sync_target();

        x = lerp(x, target_x, smoothness);
        y = lerp(y, target_y, smoothness);

        var _sx = 0, _sy = 0;
        if (shake_mag > 0.1) {
            _sx = random_range(-shake_mag, shake_mag);
            _sy = random_range(-shake_mag, shake_mag);
            shake_mag *= shake_decay;
        } else {
            shake_mag = 0;
        }

        __apply_view(_sx, _sy);
    };

    static __sync_target = function() {
        if (target_inst != noone && instance_exists(target_inst)) {
            target_x = target_inst.x;
            target_y = target_inst.y;
        }
    };

    static __apply_view = function(_sx, _sy) {
        var _cx = x - width  * 0.5 + _sx;
        var _cy = y - height * 0.5 + _sy;
        _cx = clamp(_cx, 0, max(0, room_width  - width));
        _cy = clamp(_cy, 0, max(0, room_height - height));
        camera_set_view_pos(view_camera[view_index], _cx, _cy);
    };
}
