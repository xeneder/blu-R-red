/// @description World-space confetti burst — fired from the flag pickup.
///              Particles are coloured rotated rectangles with gravity.

#macro BURST_PARTICLE_COUNT   34
#macro BURST_GRAVITY          520    // px/s^2

particles = [];
for (var _i = 0; _i < BURST_PARTICLE_COUNT; _i++) {
    var _ang = random(360);
    var _spd = random_range(150, 380);
    array_push(particles, {
        px        : x,
        py        : y,
        // Slight upward bias so the burst reads as "celebration pop", not a flat ring.
        vx        : lengthdir_x(_spd, _ang),
        vy        : lengthdir_y(_spd, _ang) - random_range(100, 240),
        rot       : random(360),
        rot_speed : random_range(-480, 480),
        w         : random_range(5, 10),
        h         : random_range(10, 18),
        col       : confetti_color(),
        age       : 0,
        life      : random_range(1.4, 2.6),
    });
}
