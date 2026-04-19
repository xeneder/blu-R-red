/// @description Each particle is a disc whose inner radius catches up to its
///              outer radius over time — so the disc thins into a ring and
///              vanishes. Outer uses ease-out (pops), inner uses ease-in
///              (lags then accelerates). Alpha fades with ease-in too.

var _n = array_length(particles);
for (var _i = 0; _i < _n; _i++) {
    var _p = particles[_i];
    if (_p.age >= _p.life) continue;

    var _t     = _p.age / _p.life;
    var _outer = _p.max_size * bezier_ease(_t, BEZIER_EASE_OUT);
    var _inner = _p.max_size * bezier_ease(_t, BEZIER_EASE_IN);
    var _alpha = (1 - bezier_ease(_t, BEZIER_EASE_IN)) * 0.95;

    draw_ring(_p.px, _p.py, _inner, _outer, c_white, _alpha, 20);
}
