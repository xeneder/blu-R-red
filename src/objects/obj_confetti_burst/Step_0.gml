/// @description Integrate particle motion, cull when all are dead.

var _dt = delta_time / 1000000;
var _n  = array_length(particles);
var _alive = 0;
for (var _i = 0; _i < _n; _i++) {
    var _p = particles[_i];
    if (_p.age >= _p.life) continue;
    _p.age       += _dt;
    _p.vy        += BURST_GRAVITY * _dt;
    _p.px        += _p.vx * _dt;
    _p.py        += _p.vy * _dt;
    _p.rot       += _p.rot_speed * _dt;
    _alive++;
}
if (_alive == 0) instance_destroy();
