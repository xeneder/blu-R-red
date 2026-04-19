/// @description Spawn a handful of circle particles that hollow out over time.

#macro EXPLOSION_PARTICLE_COUNT  14
#macro EXPLOSION_DAMPING_PER_SEC 0.04   // velocity remaining after 1 second

particles = [];
for (var _i = 0; _i < EXPLOSION_PARTICLE_COUNT; _i++) {
    var _ang = random(360);
    var _spd = random_range(60, 180);
    array_push(particles, {
        px       : x,
        py       : y,
        vx       : lengthdir_x(_spd, _ang),
        vy       : lengthdir_y(_spd, _ang),
        age      : 0,
        life     : random_range(0.45, 0.85),
        max_size : random_range(16, 32),
    });
}
