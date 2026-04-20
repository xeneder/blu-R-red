/// @description Rotated-rect draw per particle. Holds opaque for most of the
///              lifetime, then fades the last ~30% so they vanish, not pop.

var _n = array_length(particles);
for (var _i = 0; _i < _n; _i++) {
    var _p = particles[_i];
    if (_p.age >= _p.life) continue;

    var _fade_start = _p.life * 0.7;
    var _alpha = (_p.age < _fade_start)
        ? 1
        : 1 - (_p.age - _fade_start) / (_p.life - _fade_start);

    draw_rect_rot(_p.px, _p.py, _p.w, _p.h, _p.rot, _p.col, _alpha);
}
