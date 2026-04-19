/// @description General-purpose easing & animation helpers.
/// Bezier easing follows CSS `cubic-bezier()` semantics: two control points
/// (x1, y1) and (x2, y2), with endpoints pinned at (0, 0) and (1, 1).
///
/// The presets below expand into the four control-point arguments so you can
/// write fluent call sites like:
///
///     bezier_ease(t, BEZIER_EASE_IN_OUT)
///     anim_bezier_pingpong(t, period, BEZIER_SMOOTH)

#macro BEZIER_LINEAR      0.00, 0.00, 1.00, 1.00
#macro BEZIER_EASE        0.25, 0.10, 0.25, 1.00
#macro BEZIER_EASE_IN     0.42, 0.00, 1.00, 1.00
#macro BEZIER_EASE_OUT    0.00, 0.00, 0.58, 1.00
#macro BEZIER_EASE_IN_OUT 0.42, 0.00, 0.58, 1.00
#macro BEZIER_SMOOTH      0.25, 0.46, 0.45, 0.94
#macro BEZIER_BOUNCE_OUT  0.34, 1.56, 0.64, 1.00
#macro BEZIER_SNAP_IN     0.75, 0.00, 0.95, 0.25

/// @desc Evaluate a cubic bezier easing curve at time `_t` in [0, 1].
/// @param {Real} _t   Normalised time.
/// @param {Real} _x1  First control-point X.
/// @param {Real} _y1  First control-point Y.
/// @param {Real} _x2  Second control-point X.
/// @param {Real} _y2  Second control-point Y.
/// @returns {Real}    Eased value. May briefly overshoot [0, 1] for bouncy curves.
function bezier_ease(_t, _x1, _y1, _x2, _y2) {
    if (_t <= 0) return 0;
    if (_t >= 1) return 1;

    // Solve bezier_x(u) = _t for u via Newton-Raphson, then evaluate bezier_y(u).
    var _cx = 3 * _x1;
    var _bx = 3 * (_x2 - _x1) - _cx;
    var _ax = 1 - _cx - _bx;

    var _u = _t;
    repeat (8) {
        var _fx  = ((_ax * _u + _bx) * _u + _cx) * _u - _t;
        var _dfx = (3 * _ax * _u + 2 * _bx) * _u + _cx;
        if (abs(_dfx) < 0.00001) break;
        _u -= _fx / _dfx;
        if (_u < 0) _u = 0; else if (_u > 1) _u = 1;
    }

    var _cy = 3 * _y1;
    var _by = 3 * (_y2 - _y1) - _cy;
    var _ay = 1 - _cy - _by;
    return ((_ay * _u + _by) * _u + _cy) * _u;
}

/// @desc Triangle wave: rises 0->1 then falls 1->0 over `_period` units of `_t`.
/// @returns {Real} value in [0, 1].
function anim_pingpong(_t, _period) {
    var _p = frac(_t / _period);
    return (_p < 0.5) ? (_p * 2) : (2 - _p * 2);
}

/// @desc Bezier-smoothed ping-pong — softer, more organic than a raw triangle.
/// @returns {Real} value in [0, 1] (may overshoot for bouncy curves).
function anim_bezier_pingpong(_t, _period, _x1, _y1, _x2, _y2) {
    return bezier_ease(anim_pingpong(_t, _period), _x1, _y1, _x2, _y2);
}

/// @desc Bezier-smoothed ping-pong from a caller-managed phase in [0, 1].
///       Use this when the period changes over time — advance `_phase`
///       yourself at the current rate so the curve never jumps.
function anim_bezier_pingpong_phase(_phase, _x1, _y1, _x2, _y2) {
    var _tri = (_phase < 0.5) ? (_phase * 2) : (2 - _phase * 2);
    return bezier_ease(_tri, _x1, _y1, _x2, _y2);
}

/// @desc Bezier-smoothed wave centred on zero. Great for bobbing around a baseline.
/// @returns {Real} value in [-1, 1].
function anim_bezier_wave(_t, _period, _x1, _y1, _x2, _y2) {
    return anim_bezier_pingpong(_t, _period, _x1, _y1, _x2, _y2) * 2 - 1;
}

/// @desc Bezier-eased interpolation from `_current` toward `_target`.
///       `_step` is the raw lerp amount; it is passed through the bezier curve
///       before being applied. Drop-in replacement for `lerp()` with a feel.
function bezier_approach(_current, _target, _step, _x1, _y1, _x2, _y2) {
    var _eased = bezier_ease(clamp(_step, 0, 1), _x1, _y1, _x2, _y2);
    return lerp(_current, _target, _eased);
}

/// @desc Linear move-towards: step `_current` at most `_step` units toward `_target`.
function approach(_current, _target, _step) {
    if (_current < _target) return min(_current + _step, _target);
    if (_current > _target) return max(_current - _step, _target);
    return _target;
}

/// @desc Clamp a 2D vector's magnitude to at most 1. Returns a struct
///       { h, v, magnitude } — feed raw movement input through this to keep
///       diagonals at unit speed while preserving partial-tilt analog values.
function vec2_clamp_unit(_h, _v) {
    var _m = sqrt(_h * _h + _v * _v);
    if (_m > 1) return { h: _h / _m, v: _v / _m, magnitude: 1 };
    return { h: _h, v: _v, magnitude: _m };
}

/// @desc Draw a flat-shaded ring (annulus) at (_x, _y). Uses a triangle strip
///       so thickness is honoured exactly — unlike draw_circle(outline:true)
///       which only draws a one-pixel stroke.
/// @param {Real} _inner      Inner radius (hole).
/// @param {Real} _outer      Outer radius.
/// @param {Constant.Color} _col
/// @param {Real} _alpha
/// @param {Real} [_segments] Tessellation. 32 is plenty for most rings.
function draw_ring(_x, _y, _inner, _outer, _col, _alpha, _segments = 32) {
    if (_outer <= 0 || _alpha <= 0) return;
    _inner = max(0, _inner);
    draw_primitive_begin(pr_trianglestrip);
    for (var _i = 0; _i <= _segments; _i++) {
        var _ang = 2 * pi * _i / _segments;
        var _cx = cos(_ang), _sy = sin(_ang);
        draw_vertex_color(_x + _cx * _outer, _y + _sy * _outer, _col, _alpha);
        draw_vertex_color(_x + _cx * _inner, _y + _sy * _inner, _col, _alpha);
    }
    draw_primitive_end();
}
